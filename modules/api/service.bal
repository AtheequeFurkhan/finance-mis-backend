import finance.mis_backend.db;

import ballerina/http;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowCredentials: false,
        allowHeaders: ["*"],
        allowMethods: ["GET", "POST", "OPTIONS"]
    }
}
service class FinanceMisService {
    private final db:Client dbClient;

    public function init(db:Client dbClient) {
        self.dbClient = dbClient;
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/transactions"
    }
    resource function get transactions(
            http:Caller caller,
            http:Request request,
            string? startDate = (),
            string? endDate = (),
            string? department = ()
    ) returns error? {
        db:Transaction[]|error result = self.dbClient->getTransactions(startDate, endDate, department);

        if result is error {
            http:Response response = new;
            response.statusCode = 500;
            response.setJsonPayload({error:result.message()});
            check caller->respond(response);
            return;
        }

        check caller->respond(result);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/budget-vs-actual"
    }
    resource function get budgetVsActual(
            http:Caller caller,
            http:Request request,
            int fiscalYear,
            string? department = ()
    ) returns error? {
        db:BudgetVsActual[]|error result = self.dbClient->getBudgetVsActual(fiscalYear, department);

        if result is error {
            http:Response response = new;
            response.statusCode = 500;
            response.setJsonPayload({error:result.message()});
            check caller->respond(response);
            return;
        }

        check caller->respond(result);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/kpis"
    }
    resource function get kpis(
            http:Caller caller,
            http:Request request,
            string period
    ) returns error? {
        db:FinancialKPI[]|error result = self.dbClient->getFinancialKPIs(period);

        if result is error {
            http:Response response = new;
            response.statusCode = 500;
            response.setJsonPayload({error:result.message()});
            check caller->respond(response);
            return;
        }

        check caller->respond(result);
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/health"
    }
    resource function get health(http:Caller caller, http:Request request) returns error? {
        check caller->respond({status: "UP", timestamp: time:utcNow()});
    }
}
