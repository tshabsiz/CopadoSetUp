/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class wTimeline implements System.Comparable {
    global static advpm.wTimeline.SortDirection SORT_DIR;
    global static advpm.wTimeline.SortField SORT_FIELD;
    global Datetime t_date {
        get;
        set;
    }
    global advpm.wTabIcon t_icon {
        get;
        set;
    }
    global Id t_id {
        get;
        set;
    }
    global Boolean t_isRichText {
        get;
        set;
    }
    global Datetime t_lastmodified {
        get;
        set;
    }
    global Long t_order {
        get;
        set;
    }
    global Event t_proxydate {
        get;
    }
    global Boolean t_showDateOnly {
        get;
        set;
    }
    global String t_status {
        get;
        set;
    }
    global advpm__Offer_And_Demand__c t_status_proxy {
        get;
    }
    global String t_title {
        get;
        set;
    }
    global advpm__Offer_And_Demand__c t_title_proxy {
        get;
    }
    global String t_type {
        get;
        set;
    }
    global Id t_userid {
        get;
        set;
    }
    global String t_username {
        get;
        set;
    }
    global wTimeline() {

    }
    global Integer compareTo(Object other) {
        return null;
    }
global enum SortDirection {ASCENDING, DESCENDING}
global enum SortField {tDate, tLastModified, tStatus, tTitle, tType, tUser}
}
