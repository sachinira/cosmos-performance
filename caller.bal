import ballerina/http;
import ballerina/log;
import ballerinax/cosmosdb;
import ballerina/config;
import ballerina/system;

cosmosdb:AzureCosmosConfiguration configuration = {
    baseUrl : getConfigValue("BASE_URL"), 
    keyOrResourceToken : getConfigValue("KEY_OR_RESOURCE_TOKEN"), 
    tokenType : getConfigValue("TOKEN_TYPE"), 
    tokenVersion : getConfigValue("TOKEN_VERSION")
};

cosmosdb:Client azureCosmosClient = new(configuration);

service /create on new http:Listener(9090) {
    resource function post database(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string createDatabaseId = string `database_${uuid.toString()}`;
        var response = azureCosmosClient->createDatabase(createDatabaseId);
        if (response is cosmosdb:Database){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError("Error at h1_h1_passthrough");
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function post container(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string databaseId = "database_00528cb142f74787874ab799229ead88";
        string createContainerId = string `container_${uuid.toString()}`;
        cosmosdb:PartitionKey pk = {
            paths: ["/id"], 
            keyVersion: 2
        };
        var response = azureCosmosClient->createContainer(databaseId, createContainerId, pk);
        if (response is cosmosdb:Container){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError("Error at h1_h1_passthrough");
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function post document(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string databaseId = "database_00528cb142f74787874ab799229ead88";
        string createContainerId = string `container_${uuid.toString()}`;
        cosmosdb:Document createDoc = {
            id: string `document_${uuid.toString()}`, 
            documentBody :{
                "LastName": "keeeeeee",  
            "Parents": [  
                {  
                "FamilyName": null,  
                "FirstName": "Thomas"  
                },  
                {  
                "FamilyName": null,  
                "FirstName": "Mary Kay"  
                }  
            ],  
            "Children": [  
                {  
                "FamilyName": null,  
                "FirstName": "Henriette Thaulow",  
                "Gender": "female",  
                "Grade": 5,  
                "Pets": [  
                    {  
                    "GivenName": "Fluffy"  
                    }  
                ]  
                }  
            ],  
            "Address": {  
                "State": "WA",  
                "County": "King",  
                "City": "Seattle"  
            },  
            "IsRegistered": true, 
            "AccountNumber": 1234
            }, 
            partitionKey : [1234]  
        };
        var response = azureCosmosClient->createDocument(databaseId, createContainerId, createDoc);
        if (response is cosmosdb:Document){
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError("Error at h1_h1_passthrough");
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }
}

isolated function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}
