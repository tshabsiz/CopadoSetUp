/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AdvologixUtilities {
    global static String SFInstance;
    global AdvologixUtilities() {

    }
    global static String CheckNullAndEscape(String s) {
        return null;
    }
    global static String GetRetURL() {
        return null;
    }
    global static System.PageReference GoToRetURL() {
        return null;
    }
    global static String HTML_ENCODE(String input) {
        return null;
    }
    global static Map<String,String> MapValues() {
        return null;
    }
    global static String ToString(Date Value, String format) {
        return null;
    }
    global static String ToString(Datetime Value, String format) {
        return null;
    }
    global static System.PageReference VerifyUrlAndRedirect(System.PageReference pageRef) {
        return null;
    }
    global static Decimal convertCurrency(Map<String,Double> map_ratesByIsoCode, SObject parent, SObject child, Decimal amount) {
        return null;
    }
    global static String getAdvoDocCallbackFunction() {
        return null;
    }
    global static Object getCurrencyCodeFromRateOrMatterOrUserOrg(Id rateId, Id matterId, Id timekeeperId) {
        return null;
    }
    global static Map<String,Double> getCurrencyRatesMap() {
        return null;
    }
    global static String getDefaultPickVal(Schema.DescribeFieldResult FR) {
        return null;
    }
    global static advpm__Rate__c getDefaultRate(Id matterId, Id timekeeperId) {
        return null;
    }
    global static advpm__Rate__c getDefaultRate(Id matterId, Id timekeeperId, String currIsoCode) {
        return null;
    }
    global static List<Schema.SObjectField> getFields(String object_name) {
        return null;
    }
    global static advpm__Advologix_Global_Options__c getGlobalOptions() {
        return null;
    }
    global static String getGlobalTimeDescriptionField() {
        return null;
    }
    global static String getGlobalTimeDescriptionFieldContent() {
        return null;
    }
    global static String getGlobalTimeDescriptionFieldEvent() {
        return null;
    }
    global static String getGlobalTimeDescriptionFieldTask() {
        return null;
    }
    global static String getOrganizationCurrency() {
        return null;
    }
    global static List<System.SelectOption> getPickValues(SObject object_name, String field_name, Boolean first_val_empty) {
        return null;
    }
    global static advpm__Advologix_Planner_Options_S1__c getPlannerDefaults_S1(Map<String,String> params, Boolean isSFMobile) {
        return null;
    }
    global static advpm__Advologix_Planner_Options__c getPlannerDefaults(Map<String,String> params) {
        return null;
    }
    global static Decimal getRateAmount(Id rateId) {
        return null;
    }
    global static advpm__Rate__c getRateById(Id rateId) {
        return null;
    }
    global static String getRelativeTime(Datetime dt) {
        return null;
    }
    global static Decimal getTimeByTimeRounding(Decimal timeInHoursValue) {
        return null;
    }
    global static Decimal getTimeByTimeRounding(Decimal timeInHoursValue, Integer globalIncrementalRoundValue) {
        return null;
    }
    global static String getTimeZoneValue(Datetime date_time) {
        return null;
    }
    global static advpm__Advologix_Timeline_Settings__c getTimelineSettings() {
        return null;
    }
    global static advpm__Advologix_Trigger_Settings__c getTriggerSettings() {
        return null;
    }
    global static Boolean hasAccountingSeedAccess(Map<String,Schema.SObjectType> gd) {
        return null;
    }
    global static Boolean hasObjectAccess(Map<String,Schema.SObjectType> gd, String objName) {
        return null;
    }
    global static Boolean hasObjectAccess(Map<String,Schema.SObjectType> gd, String objName, String fieldName) {
        return null;
    }
    global static Boolean hasObjectAddAccess(Map<String,Schema.SObjectType> gd, String objName) {
        return null;
    }
    global static Boolean hasObjectEditAccess(Map<String,Schema.SObjectType> gd, String objName) {
        return null;
    }
    global static Boolean hasObjectEditAccess(Map<String,Schema.SObjectType> gd, String objName, String fieldName) {
        return null;
    }
    global static Boolean isLicensedUser(String packageNamespace) {
        return null;
    }
    global static String join(List<String> Values, String Delimiter) {
        return null;
    }
    global static String join(Set<String> Values, String Delimiter) {
        return null;
    }
    global static Map<String,advpm__Rate__c> prepareMapDefaultRates(Set<Id> matIds, Set<Id> usrIds, Boolean usrIdsAreTimekeeperIds) {
        return null;
    }
    global static List<SObject> sortList(List<SObject> sOptions) {
        return null;
    }
    global static List<Schema.SObjectField> sortList(List<Schema.SObjectField> sOptions) {
        return null;
    }
    global static List<System.SelectOption> sortList(List<System.SelectOption> sOptions) {
        return null;
    }
    global static List<String> toList(Set<String> lst) {
        return null;
    }
    global static Set<String> toSet(List<String> lst) {
        return null;
    }
    global static String truncate(String str, Integer endIndex) {
        return null;
    }
    global static String truncateWithSuffix(String str, Integer endIndex, String prefix) {
        return null;
    }
global enum RollUpOperation {COUNT, MAX, MIN, SUM}
global class TimeSpan {
    global Long TotalDays {
        get;
        set;
    }
    global Long TotalHours {
        get;
        set;
    }
    global Long TotalMilliseconds {
        get;
        set;
    }
    global Long TotalMinutes {
        get;
        set;
    }
    global TimeSpan(Datetime dtStart, Datetime dtEnd) {

    }
}
}
