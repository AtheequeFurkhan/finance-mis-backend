import finance_mis_backend.api;
import finance_mis_backend.db;

import ballerina/config;
import ballerina/http;
import ballerina/log;

public function main() returns error? {
    log:printInfo("Starting Finance MIS Backend Service");

    // Initialize database client
    db:Client dbClient = check db:initClient();

    // Start HTTP service
    int port = config:getAsInt("api.port", 9090);
    http:Listener listener = check new (port);

    api:FinanceMisService service = new (dbClient);
    check listener.attach(service, "/finance-mis/v1");
    check listener.start ();

    log:printInfo(string `Finance MIS Backend Service started on port ${port}`);

    // Keep the service running
    runtime:sleep(2147483647);
}
