/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class Calendar_Main {
    @RemoteAction
    global static void deleteEvent(Id eventId) {

    }
    @RemoteAction
    global static void deleteTask(Id taskId) {

    }
    @RemoteAction
    global static void deleteTime(Id timeId) {

    }
    @ReadOnly
    @RemoteAction
    global static List<advpm.Calendar_Item> getCalendarEventItems2(Date da0, Date da1, String optionsStr, advpm__Advologix_Planner_Options__c setting) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static List<advpm.Calendar_Item> getCalendarEventItems(Date da0, Date da1, String matId, Boolean showEvents, Boolean showMyActivitiesOnly, Boolean showMyMattersOnly, Boolean showActivitiesWithMattersOnly) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static List<advpm.Calendar_Item> getCalendarKeydateItems2(Date da0, Date da1, String optionsStr, advpm__Advologix_Planner_Options__c setting) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static List<advpm.Calendar_Item> getCalendarKeydateItems(Date da0, Date da1, String matId, Boolean showMatterDates, Boolean showSubMatterActs, Boolean showMyActivitiesOnly, Boolean showMyMattersOnly, Boolean showActivitiesWithMattersOnly) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static List<advpm.Calendar_Item> getCalendarTaskItems2(Date da0, Date da1, String optionsStr, advpm__Advologix_Planner_Options__c setting) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static List<advpm.Calendar_Item> getCalendarTaskItems(Date da0, Date da1, String matId, Boolean showTasks, Boolean showMyActivitiesOnly, Boolean showMyMattersOnly, Boolean showActivitiesWithMattersOnly) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static List<advpm.Calendar_Item> getCalendarTimeItems2(Date da0, Date da1, String optionsStr, advpm__Advologix_Planner_Options__c setting) {
        return null;
    }
    @ReadOnly
    @RemoteAction
    global static List<advpm.Calendar_Item> getCalendarTimeItems(Date da0, Date da1, String matId, Boolean showTime, Boolean showMyActivitiesOnly, Boolean showMyMattersOnly, Boolean showActivitiesWithMattersOnly) {
        return null;
    }
    @RemoteAction
    global static void savePlannerOptions(Boolean showMatterDates, Boolean showTasks, Boolean showEvents, Boolean showTime, Boolean showMyActivitiesOnly, Boolean showMyMattersOnly, Boolean showActivitiesWithMattersOnly, Boolean showSubMatterActs) {

    }
    @RemoteAction
    global static void savePlannerOptionsS1(Boolean showMatterDates, Boolean showTasks, Boolean showEvents, Boolean showTime, Boolean showMyActivitiesOnly, Boolean showMyMattersOnly, Boolean showActivitiesWithMattersOnly, Boolean showSubMatterActs) {

    }
    @RemoteAction
    global static void savePlannerOptionsS1_new(advpm__Advologix_Planner_Options__c setting) {

    }
    @RemoteAction
    global static void savePlannerOptions_new(advpm__Advologix_Planner_Options__c setting) {

    }
    @RemoteAction
    global static void updateItem(String dt_m, String dt_d, String dt_y, String item, Boolean lineItemsExist, Boolean milestonesExist) {

    }
}
