/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AdvologixSecurityUtil {
    global AdvologixSecurityUtil() {

    }
    global static void checkAccessError(Schema.SObjectType objType, String opr) {

    }
    global static void checkAccessError(Schema.SObjectType objType, List<String> fieldsToCheck) {

    }
    global static void checkAccessError(Schema.SObjectType objType, String opr, List<String> fieldsToCheck) {

    }
    global static void checkAccessError(Schema.SObjectType objType, String opr, List<String> fieldsToCheck, Boolean throwError) {

    }
    global static Boolean hasCreateAccess(Schema.SObjectType objType) {
        return null;
    }
    global static Schema.DescribeFieldResult hasCreateAccess(Schema.SObjectType objType, List<String> fieldsToCheck) {
        return null;
    }
    global static Boolean hasDeleteAccess(Schema.SObjectType objType) {
        return null;
    }
    global static advpm.AdvologixSecurityUtil.SecurityResponseItem hasNoAccess(Schema.SObjectType objType, String opr) {
        return null;
    }
    global static advpm.AdvologixSecurityUtil.SecurityResponseItem hasNoAccess(Schema.SObjectType objType, String opr, List<String> fieldsToCheck) {
        return null;
    }
    global static Boolean hasReadAccess(Schema.SObjectType objType) {
        return null;
    }
    global static Schema.DescribeFieldResult hasReadAccess(Schema.SObjectType objType, List<String> fieldsToCheck) {
        return null;
    }
    global static Boolean hasUpdateAccess(Schema.SObjectType objType) {
        return null;
    }
    global static Schema.DescribeFieldResult hasUpdateAccess(Schema.SObjectType objType, List<String> fieldsToCheck) {
        return null;
    }
global class SecurityResponseItem {
    global Boolean hasAccess {
        get;
        set;
    }
    global String message {
        get;
        set;
    }
    global SecurityResponseItem(Boolean a, String m) {

    }
}
}
