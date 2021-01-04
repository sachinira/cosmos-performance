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
    cosmosdb:Database database = {};
    cosmosdb:Container container = {};

    resource function post database(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string createDatabaseId = string `database_${uuid.toString()}`;
        var response = azureCosmosClient->createDatabase(createDatabaseId);
        if (response is cosmosdb:Database){
            var result = caller->respond(<@untainted>response);
            self.database = response;
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function post container(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string databaseId = self.database.id;
        string createContainerId = string `container_${uuid.toString()}`;
        cosmosdb:PartitionKey pk = {
            paths: ["/id"], 
            keyVersion: 2
        };
        var response = azureCosmosClient->createContainer(databaseId, createContainerId, pk);
        if (response is cosmosdb:Container){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function post document(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string databaseId = "database_00528cb142f74787874ab799229ead88";
        //change
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
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function post storedprocedure(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string databaseId = "database_00528cb142f74787874ab799229ead88";
        //change
        string createContainerId = string `container_${uuid.toString()}`;
        string createSprocBody = "function (){\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello,  World\");\r\n}"; 
        cosmosdb:StoredProcedure storedProcedure = {
            id: string `sproc_${uuid.toString()}`, 
            body:createSprocBody
        };
        var response = azureCosmosClient->replaceStoredProcedure(databaseId, createContainerId, storedProcedure);
        if (response is cosmosdb:StoredProcedure){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function post userdefinedfunction(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string databaseId = "database_00528cb142f74787874ab799229ead88";
        //change
        string createContainerId = string `container_${uuid.toString()}`;
        string createUDFBody = "function tax(income){\r\n    if (income == undefined) \r\n        throw 'no input';\r\n    if ((income < 1000) \r\n        return income * 0.1;\r\n    else if ((income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
        cosmosdb:UserDefinedFunction createUdf = {
        id: string `udf_${uuid.toString()}`, 
        body: createUDFBody
        };
        var response = azureCosmosClient->createUserDefinedFunction(databaseId, createContainerId, createUdf);
        if (response is cosmosdb:UserDefinedFunction){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function post trigger(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string databaseId = "database_00528cb142f74787874ab799229ead88";
        //change
        string createContainerId = string `container_${uuid.toString()}`;
        string createTriggerBody = "function tax(income){\r\n    if (income == undefined) \r\n        throw 'no input';\r\n    if ((income < 1000) \r\n        return income * 0.1;\r\n    else if ((income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}";
        string createTriggerOperation = "All"; 
        string createTriggerType = "Post";         
        cosmosdb:Trigger createTrigger = {
            id:string `trigger_${uuid.toString()}`, 
            body:createTriggerBody, 
            triggerOperation:createTriggerOperation, 
            triggerType: createTriggerType
        };
        var response = azureCosmosClient->createTrigger(databaseId, createContainerId, createTrigger);
        if (response is cosmosdb:Trigger){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function post user(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string databaseId = "database_00528cb142f74787874ab799229ead88";
        string userId = string `user_${uuid.toString()}`;
        var response = azureCosmosClient->createUser(databaseId, userId);
        if (response is cosmosdb:User){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function post permission(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 

        string databaseId = "database_00528cb142f74787874ab799229ead88";
        string permissionUserId = "";//;test_user.id;//given userid
        string permissionId = string `permission_${uuid.toString()}`;
        string permissionMode = "All";
        string permissionResource = "";//string `dbs/${database?.resourceId.toString()}/colls/${container?.resourceId.toString()}`;
        cosmosdb:Permission createPermission = { //dbname container name
            id: permissionId, 
            permissionMode: permissionMode, 
            resourcePath: permissionResource
        };
        var response = azureCosmosClient->createPermission(databaseId, permissionUserId, createPermission); 
        if (response is cosmosdb:Permission){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
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
