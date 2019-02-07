/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MyMattersController {
    @AuraEnabled
    global static advpm__Advologix_Planner_Options__c getCurrentUserOptions() {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static advpm.MyMattersController.Response mattersWithListView(List<Map<String,Object>> request, String portalLoginContactId, Boolean isMobile, String whereClause, Boolean listViewEnabled) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static advpm.MyMattersController.Response matters(List<Map<String,Object>> request, String portalLoginContactId, Boolean isMobile) {
        return null;
    }
    @AuraEnabled
    global static void saveEnhancedViewState(Boolean state) {

    }
    @RemoteAction
    global static void saveMyMattersOptionsS1Mobile_new(advpm.MyMattersController.wTableSettings setting) {

    }
    @RemoteAction
    global static void saveMyMattersOptionsS1_new(advpm.MyMattersController.wTableSettings setting) {

    }
    @RemoteAction
    global static void saveMyMattersOptions_new(advpm.MyMattersController.wTableSettings setting) {

    }
global class Response {
}
global class wTableSettings {
    global List<List<String>> aaSorting {
        get;
        set;
    }
    global String iLength {
        get;
        set;
    }
    global String listId {
        get;
        set;
    }
    global wTableSettings() {

    }
}
}
