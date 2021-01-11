import ballerina/http;
import ballerina/log;
import ballerinax/cosmosdb;
import ballerina/config;
import ballerina/system;
import ballerina/runtime;

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
cosmosdb:StoredProcedure storedprocedure = {};
cosmosdb:UserDefinedFunction userDefinedFunction = {};
cosmosdb:Trigger trigger = {};

service /create on new http:Listener(9090) {
    
    resource function post database(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 
        string createDatabaseId = string `database_${uuid.toString()}`;

        var response = azureCosmosClient->createDatabase(createDatabaseId);
        if (response is cosmosdb:Database){
            database = <@untainted>response;
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
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
            container = <@untainted>response;
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
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
            document = <@untainted>response;
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
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
            storedprocedure = <@untainted>response;
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
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
            userDefinedFunction = <@untainted>response;
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
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
            trigger = <@untainted>response;
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function post user(http:Caller caller, http:Request clientRequest) {
        var uuid = cosmosdb:createRandomUUIDBallerina(); 
        string userId = string `user_${uuid.toString()}`;

        var response = azureCosmosClient->createUser(database.id, userId);
        if (response is cosmosdb:User){
            user = <@untainted>response;
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
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
            permission = <@untainted>response;
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }
}

service /list on new http:Listener(9091) {
    resource function get database(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getDatabase(database.id);

        if (response is cosmosdb:Database){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get container(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getContainer(database.id, container.id);

        if (response is cosmosdb:Container){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get document(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getDocument(database.id, container.id, document.id, [database.id]);

        if (response is cosmosdb:Document){
            var result = caller->respond((<@untainted>response).toString());
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get user(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getUser(database.id, user.id);  

        if (response is cosmosdb:User){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    #problem
    resource function get permission(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getPermission(database.id, user.id, permission.id);  

        if (response is cosmosdb:Permission){
            var result = caller->respond(<@untainted>response);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get databases(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->listDatabases();

        if (response is stream<cosmosdb:Database>){
            var databaseResult = response.next();
            var result = caller->respond(<@untainted>databaseResult?.value);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get containers(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->listContainers(database.id);

        if (response is stream<cosmosdb:Container>){
            var containerResult = response.next();
            var result = caller->respond(<@untainted>containerResult?.value);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get partitionkeyranges(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->listPartitionKeyRanges(database.id, container.id);

        if (response is stream<cosmosdb:PartitionKeyRange>){
            var partitionKeyrange = response.next();
            var result = caller->respond(<@untainted>partitionKeyrange?.value);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get documents(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->getDocumentList(database.id, container.id);

        if (response is stream<cosmosdb:Document>){
            var documentResult = response.next();
            var result = caller->respond((<@untainted>documentResult?.value).toString());
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get storedprocedures(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->listStoredProcedures(database.id, container.id);

        if (response is stream<cosmosdb:StoredProcedure>){
            var storedProcedure = response.next();
            var result = caller->respond(<@untainted>storedProcedure?.value);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get userdefinedfunctions(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->listUserDefinedFunctions(database.id, container.id);

        if (response is stream<cosmosdb:UserDefinedFunction>){
            var userDefinedFunction = response.next();
            var result = caller->respond(<@untainted>userDefinedFunction?.value);
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get triggers(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->listTriggers(database.id, container.id);

        if (response is stream<cosmosdb:Trigger>){
            var trigger = response.next();
            var result = caller->respond((<@untainted>trigger?.value));
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get users(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->listUsers(database.id);

        if (response is stream<cosmosdb:User>){
            var user = response.next();
            var result = caller->respond((<@untainted>user?.value));
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get permissions(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->listPermissions(database.id, user.id);

        if (response is stream<cosmosdb:Permission>){
            var permission = response.next();
            var result = caller->respond((<@untainted>permission?.value));
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }

    resource function get offers(http:Caller caller, http:Request clientRequest) {
        runtime:sleep(3000);
        var response = azureCosmosClient->listOffers();

        if (response is stream<cosmosdb:Offer>){
            var offer = response.next();
            var result = caller->respond((<@untainted>offer?.value));
        } else {
            log:printError(response.message());
            http:Response res = new;
            res.statusCode = <int>response.detail()["status"];
            res.setPayload(<@untainted>response.message());
            var result = caller->respond(<@untainted>res);
        }
    }  
}

service /deletes on new http:Listener(9092) {
    resource function delete database(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->deleteDatabase(database.id);

        if (response == true){
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError(response.toString());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    } 

    resource function delete container(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->deleteContainer(database.id,container.id);

        if (response == true){
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError(response.toString());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    } 

    resource function delete document(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->deleteDocument(database.id,container.id,document.id, [database.id]);

        if (response == true){
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError(response.toString());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function delete storedprocedure(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->deleteStoredProcedure(database.id,container.id, storedprocedure.id); 

        if (response == true){
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError(response.toString());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function delete userdefinedfunction(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->deleteUserDefinedFunction(database.id,container.id, userDefinedFunction.id);

        if (response == true){
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError(response.toString());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function delete trigger(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->deleteTrigger(database.id,container.id, trigger.id);

        if (response == true){
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError(response.toString());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }

    resource function delete user(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->deleteUser(database.id, user.id);

        if (response == true){
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError(response.toString());
            http:Response res = new;
            res.statusCode = 500;
            res.setPayload((<@untainted error>response).message());
            var result = caller->respond(res);
        }
    }
    
    resource function delete permission(http:Caller caller, http:Request clientRequest) {
        var response = azureCosmosClient->deletePermission(database.id, permission.id, user.id);

        if (response == true){
            var result = caller->respond(<@untainted>response.toString());
        } else {
            log:printError(response.toString());
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
