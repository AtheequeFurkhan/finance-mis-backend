# Represents a financial transaction record
public type Transaction record {
    int id;
    string transaction_date;
    string description;
    decimal amount;
    string department;
    string category;
    string transaction_type; // "income" or "expense"
};

# Represents a budget vs. actual record
public type BudgetVsActual record {
    string department;
    string category;
    decimal budget_amount;
    decimal actual_amount;
    int fiscal_year;
    int fiscal_quarter;
};

# Represents a financial KPI
public type FinancialKPI record {
    string kpi_name;
    decimal kpi_value;
    decimal target_value;
    string period; // "monthly", "quarterly", "yearly"
    string period_value; // e.g., "2025-08", "2025-Q3", "2025"
    string last_updated;
};