import ballerina/http;
//import ballerina/log;
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

service /list on new http:Listener(9090) {
    resource function post database(http:Caller caller, http:Request clientRequest) {
        
    }

    resource function post container(http:Caller caller, http:Request clientRequest) {
        
    }

    resource function post document(http:Caller caller, http:Request clientRequest) {
        
    }

    resource function post storedprocedure(http:Caller caller, http:Request clientRequest) {
        
    }

    resource function post userdefinedfunction(http:Caller caller, http:Request clientRequest) {
       
    }

    resource function post trigger(http:Caller caller, http:Request clientRequest) {
       
    }

    resource function post permission(http:Caller caller, http:Request clientRequest) {
        
    }
}

isolated function getConfigValue(string key) returns string {
    return (system:getEnv(key) != "") ? system:getEnv(key) : config:getAsString(key);
}
