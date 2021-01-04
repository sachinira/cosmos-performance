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
cosmosdb:Database database = {};
cosmosdb:Container container = {};
cosmosdb:Document document = {};
cosmosdb:User user = {};
cosmosdb:Permission permission = {};

service /create on new http:Listener(9090) {
    
    resource function post database(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 
        string createDatabaseId = string `database_${uuid.toString()}`;

        var response = azureCosmosClient->createDatabase(createDatabaseId);
        if (response is cosmosdb:Database){
            var result = caller->respond(<@untainted>response);
            database = <@untainted>response;
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
        string createContainerId = string `container_${uuid.toString()}`;
        cosmosdb:PartitionKey pk = {
            paths: ["/id"], 
            keyVersion: 2
        };

        var response = azureCosmosClient->createContainer(database.id, createContainerId, pk);
        if (response is cosmosdb:Container){
            var result = caller->respond(<@untainted>response);
            container = <@untainted>response;
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
        var documentId = string `document_${uuid.toString()}`;
        cosmosdb:Document createDoc = {
            id: documentId, 
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
            partitionKey : [documentId] 
        };

        var response = azureCosmosClient->createDocument(database.id, container.id, createDoc);
        if (response is cosmosdb:Document){
            var result = caller->respond(<@untainted>response.toString());
            document = <@untainted>response;
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
        string createSprocBody = "function (){\r\n    var context = getContext();\r\n    var response = context.getResponse();\r\n\r\n    response.setBody(\"Hello,  World\");\r\n}"; 
        cosmosdb:StoredProcedure storedProcedure = {
            id: string `sproc_${uuid.toString()}`, 
            body:createSprocBody
        };

        var response = azureCosmosClient->createStoredProcedure(database.id, container.id, storedProcedure);
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
        string createUDFBody = "function tax(income){\r\n    if (income == undefined) \r\n        throw 'no input';\r\n    if ((income < 1000) \r\n        return income * 0.1;\r\n    else if ((income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}"; 
        cosmosdb:UserDefinedFunction createUdf = {
        id: string `udf_${uuid.toString()}`, 
        body: createUDFBody
        };

        var response = azureCosmosClient->createUserDefinedFunction(database.id, container.id, createUdf);
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
        string createTriggerBody = "function tax(income){\r\n    if (income == undefined) \r\n        throw 'no input';\r\n    if ((income < 1000) \r\n        return income * 0.1;\r\n    else if ((income < 10000) \r\n        return income * 0.2;\r\n    else\r\n        return income * 0.4;\r\n}";
        string createTriggerOperation = "All"; 
        string createTriggerType = "Post";         
        cosmosdb:Trigger createTrigger = {
            id:string `trigger_${uuid.toString()}`, 
            body:createTriggerBody, 
            triggerOperation:createTriggerOperation, 
            triggerType: createTriggerType
        };

        var response = azureCosmosClient->createTrigger(database.id, container.id, createTrigger);
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
        string userId = string `user_${uuid.toString()}`;

        var response = azureCosmosClient->createUser(database.id, userId);
        if (response is cosmosdb:User){
            var result = caller->respond(<@untainted>response);
            user = <@untainted>response;

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
        string permissionId = string `permission_${uuid.toString()}`;
        string permissionMode = "All";
        string permissionResource = string `dbs/${database?.resourceId.toString()}/colls/${container?.resourceId.toString()}`;
        cosmosdb:Permission createPermission = { 
            id: permissionId, 
            permissionMode: permissionMode, 
            resourcePath: permissionResource
        };

        var response = azureCosmosClient->createPermission(database.id, user.id, createPermission); 
        if (response is cosmosdb:Permission){
            var result = caller->respond(<@untainted>response);
            permission = <@untainted>response;
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }
}

service /get on new http:Listener(9091) {
    resource function get database(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getDatabase(database.id);

        if (response is cosmosdb:Database){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function get container(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getContainer(database.id, container.id);

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

    resource function get document(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getDocument(database.id, container.id, document.id, [1234]);

        if (response is cosmosdb:Document){
            var result = caller->respond((<@untainted>response).toString());
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function get user(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getUser(database.id, user.id);  

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

    resource function get permission(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getPermission(database.id, user.id, permission.id);  

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
