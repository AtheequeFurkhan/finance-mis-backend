import ballerina/config;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;

public client class Client {
    private final mysql:Client dbClient;

    public function init() returns error? {
        string host = config:getAsString("database.host", "localhost");
        int port = config:getAsInt("database.port", 3306);
        string user = config:getAsString("database.user", "finance_user");
        string password = config:getAsString("database.password", "");
        string database = config:getAsString("database.database", "finance_mis");

        mysql:Options options = {
            ssl: {
                mode: mysql:SSL_PREFERRED
            }
        };

        self.dbClient = check new (host, user, password, database, port, options);
        log:printInfo("Database connection established");
    }

    # Retrieves financial transactions based on provided filters
    # + startDate - Start date for filtering transactions
    # + endDate - End date for filtering transactions
    # + department - Optional department filter
    # + return - Array of Transaction records or error
    public function getTransactions(string? startDate = (), string? endDate = (), string? department = ()) returns Transaction[]|error {
        sql:ParameterizedQuery query = `
            SELECT id, transaction_date, description, amount, department, category, transaction_type
            FROM financial_transactions
            WHERE 1=1
        `;

        // Add filters if provided
        if startDate is string {
            query = sql:queryConcat(query, ` AND transaction_date >= ${startDate}`);
        }

        if endDate is string {
            query = sql:queryConcat(query, ` AND transaction_date <= ${endDate}`);
        }

        if department is string {
            query = sql:queryConcat(query, ` AND department = ${department}`);
        }

        query = sql:queryConcat(query, ` ORDER BY transaction_date DESC`);

        stream<Transaction, sql:Error?> resultStream = self.dbClient->query(query);

        Transaction[] transactions = [];
        error? e = resultStream.forEach(function(Transaction transaction) {
            transactions.push(transaction);
        });

        if e is error {
            return e;
        }

        return transactions;
    }

    # Gets budget vs. actual spending data for reporting
    # + fiscalYear - Fiscal year to query
    # + department - Optional department filter
    # + return - Array of BudgetVsActual records or error
    public function getBudgetVsActual(int fiscalYear, string? department = ()) returns BudgetVsActual[]|error {
        sql:ParameterizedQuery query = `
            SELECT department, category, SUM(budget_amount) as budget_amount, 
                   SUM(actual_amount) as actual_amount,
                   fiscal_year, fiscal_quarter
            FROM budget_vs_actual
            WHERE fiscal_year = ${fiscalYear}
        `;

        if department is string {
            query = sql:queryConcat(query, ` AND department = ${department}`);
        }

        query = sql:queryConcat(query, ` 
            GROUP BY department, category, fiscal_year, fiscal_quarter
            ORDER BY fiscal_quarter, department, category
        `);

        stream<BudgetVsActual, sql:Error?> resultStream = self.dbClient->query(query);

        BudgetVsActual[] budgetData = [];
        error? e = resultStream.forEach(function(BudgetVsActual data) {
            budgetData.push(data);
        });

        if e is error {
            return e;
        }

        return budgetData;
    }

    # Gets key financial KPIs
    # + period - Period for which to retrieve KPIs (monthly, quarterly, yearly)
    # + return - Array of FinancialKPI records or error
    public function getFinancialKPIs(string period) returns FinancialKPI[]|error {
        sql:ParameterizedQuery query = `
            SELECT kpi_name, kpi_value, target_value, period, period_value, last_updated
            FROM financial_kpis
            WHERE period = ${period}
            ORDER BY period_value DESC, kpi_name
        `;

        stream<FinancialKPI, sql:Error?> resultStream = self.dbClient->query(query);

        FinancialKPI[] kpis = [];
        error? e = resultStream.forEach(function(FinancialKPI kpi) {
            kpis.push(kpi);
        });

        if e is error {
            return e;
        }

        return kpis;
    }

    public function close() returns error? {
        return self.dbClient.close();
    }
}

public function initClient() returns Client|error {
    Client client = new ();
    return client;
}
