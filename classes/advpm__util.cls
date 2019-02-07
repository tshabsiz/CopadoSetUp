/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class util {
    global static Boolean isAloha {
        get;
    }
    global static Boolean isHomePageView {
        get;
    }
    global static Boolean isInlineLayout {
        get;
    }
    global static Boolean isLightning {
        get;
    }
    global static Boolean isMobile {
        get;
    }
    global static Boolean isPortal {
        get;
    }
    global static Boolean isSF1 {
        get;
    }
    global static Boolean isWebstore {
        get;
    }
    global static String NOACCESS_MSG;
    global util() {

    }
    global static Integer CountHolidays(Set<Date> listOfHolidays, String adjust, Date minDate, Date maxDate) {
        return null;
    }
    global static Boolean IsNull(String s) {
        return null;
    }
    global static Set<Date> ListOfHolidays() {
        return null;
    }
    global static Set<Date> ListOfHolidays(Date minDate, Date maxDate) {
        return null;
    }
    global static void LogError(Exception ex) {

    }
    global static void LogError(String msg) {

    }
    global static void LogError(Exception ex, Boolean showLineNo) {

    }
    global static void LogError(Exception ex, Boolean showLineNo, Boolean showTrace) {

    }
    global static void LogInfo(String msg) {

    }
    global static void LogInfo(String msg, Boolean throwErr) {

    }
    global static Date NearBusinessDay(Set<Date> listOfHolidays, String adjust, Date currDate) {
        return null;
    }
    global static Datetime NearBusinessDay(Set<Date> listOfHolidays, String adjust, Datetime currDate) {
        return null;
    }
    global static Boolean OptionCheckedCookieState(String cookieName, Boolean defaultReturnValue) {
        return null;
    }
    global static Boolean checkHasDeleteAccess(Id recId, Schema.DescribeSObjectResult dr) {
        return null;
    }
    global static Boolean checkHasEditAccess(Id recId, Schema.DescribeSObjectResult dr) {
        return null;
    }
    global static Double divide(Double dividend, Double divisor) {
        return null;
    }
    global static advpm__Rate__c findDefaultRate_NewWithMC(Map<String,advpm__Rate__c> map_rates, Id matId, Id tkId, Map<String,String> map_currIsoCode) {
        return null;
    }
    global static advpm__Rate__c findDefaultRate_New(Map<String,List<advpm__Rate__c>> map_rates, Id matId, Id tkId) {
        return null;
    }
    global static advpm__Rate__c findDefaultRate(List<advpm__Rate__c> rates, Id tkId) {
        return null;
    }
    global static Map<String,Map<String,advpm.wTabIcon>> getAllTabIcons() {
        return null;
    }
    global static Boolean getIsSystemAdvoDocTemplate(String baseObject) {
        return null;
    }
    global static String getJSON_ObjectDetails(Id recId) {
        return null;
    }
    global static String getObjectApiName(String objLabel) {
        return null;
    }
    global static Schema.DescribeSObjectResult getSObjectDescribe(Id recId) {
        return null;
    }
    global static advpm.wTabIcon getTabIcon(String sObjName) {
        return null;
    }
    global static advpm.wTabIcon getTabIcon(String sObjName, Boolean iconLtng) {
        return null;
    }
    global static String getTabIconName(String iconUrl) {
        return null;
    }
    global static String getTabIconUrl(String objName, Boolean themeLE) {
        return null;
    }
    global static Map<String,advpm.wTabIcon> getTabIcons(String sObjName) {
        return null;
    }
global class CustomErrorMessage {
    global String errHeading {
        get;
        set;
    }
    global String errMessage {
        get;
        set;
    }
    global CustomErrorMessage(String h, String m) {

    }
}
}
