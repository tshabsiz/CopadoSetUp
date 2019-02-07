/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class LightningSharing {
    global LightningSharing() {

    }
    @AuraEnabled
    global static Boolean canIEditPerms(Id recordId) {
        return null;
    }
    @AuraEnabled
    global static void deletePerm(Id UserOrGroupID, Id recordId) {

    }
    @AuraEnabled
    global static String doSOSL(String searchString, String objectType) {
        return null;
    }
    @AuraEnabled
    global static String getSharings(Id recordId) {
        return null;
    }
    @AuraEnabled
    global static String objectTypeFromId(Id recordId) {
        return null;
    }
    @AuraEnabled
    global static String upsertPerm(Id UserOrGroupID, Id recordId, String level) {
        return null;
    }
global class SharingPermsException extends Exception {
}
global class sharingHolder {
    global String AccessLevel {
        get;
        set;
    }
    global String RowCause {
        get;
        set;
    }
    global String SubType {
        get;
        set;
    }
    global String UserOrGroupID {
        get;
        set;
    }
    global String UserOrGroupName {
        get;
        set;
    }
    global String UserOrGroupType {
        get;
        set;
    }
    global sharingHolder() {

    }
}
}
