/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 *** CHANGE LOG ***
 
 07/06/2017 - TD    - Created Class.
 30/08/2017 - PG    - Moved Tracy's timekeeper idenificiaiton logic to the constructor.   Was getting set to late for page render on first load.
 20/09/2017 - PG    - Added Business Unit logic
------------------------------------------------------------------------------------------------------
@ Modified By   : Tracy de Bruin  
@ Date          : 13/09/2017
@ Description   : Add 'None' to Matter dropdown for Matter Owner and Participant level
------------------------------------------------------------------------------------------------------           
**/
public with sharing class TimeSheetEntries_Cont {

    public List<advpm__Time__c> timeEntryList { get; set; }
    public Set<String> timeEntrySet;
    public List<TimesheetEntriesWrapper> timesheetEntriesWrapperList { get; set; }
    public Map<String, List<advpm__Time__c>> weeklyTimesMap;
    public advpm__Timekeeper__c timeKeeperLoggedIn { get; set; }
    public User UserLoggedIn { get; set; }
    public List<advpm__Time__c> timeEntryDeleteList;
    public List<advpm__Time__c> timeEntryInsertList;
    public Integer counter { get; set; }
    public List<Work_Category__c> workCategories { get; set; }
    public Date startDate = null;
    public Date endDate = null;
    public List <SelectOption> matterSelectOptionList = new List <SelectOption>();
    public Boolean lockDateIndicator { get; set; }
    public advpm__Time__c evt { get {if (evt == null) evt = new advpm__Time__c(); return evt;} set; }
    public Decimal totalMonday { get; set; }
    public Decimal totalTuesday { get; set; }
    public Decimal totalWednesday { get; set; }
    public Decimal totalThursday { get; set; }
    public Decimal totalFriday { get; set; }
    public Decimal totalSaturday { get; set; }
    public Decimal totalSunday { get; set; }
    public Decimal grandTotal { get; set; }
    public Boolean hasError { get; set; }
    public Map<String, String> matterBusinessUnits { get; set; }

    Public String WeekSelect { get; set; }

/*   TESTING ON Auto populate for Business for legal Matter Select */

    Public TimeSheetEntries_Cont(){}

    Public Boolean HideFields { get; set; }
    Public string MatterIDSelct {

        get {
            String MatterIDSelct = Apexpages.currentPage().getParameters().get('MatterIDSelct');
            return MatterIDSelct;
        }
        set {

        }
    }

    Public Pagereference BusinessUnits() {

        String Matter = Apexpages.currentPage().getParameters().get('Unit');
        system.debug('**MatterIDSelct**' + MatterIDSelct);

        advpm__Matter__c[] matterUnit = [Select id,Business_Unit_Cluster_Segment__c,RecordType.name from advpm__Matter__c where name = :Matter];

        system.debug('****' + matterUnit[0].RecordType.name);
        if (matterUnit[0].RecordType.name == 'Legal') {

            for (TimesheetEntriesWrapper timeItem : timesheetEntriesWrapperList) {

                timeItem.timeEntryItem.Business_Unit_Cluster_Segment__c = matterUnit[0].Business_Unit_Cluster_Segment__c;
                system.debug('*Unit***' + timeItem.timeEntryItem.Business_Unit_Cluster_Segment__c);
            }
        }
        system.debug('*Legal***' + timesheetEntriesWrapperList);
        return null;
    }

    @RemoteAction
    public static List<Auto> searchMatters(String inputTerm) {
        List<Auto> data = new List<Auto>();

        List<advpm__Matter__c> matters = [
                SELECT
                        Id,
                        Name,
                        Business_Unit_Cluster_Segment__c,
                        Business_Unit_Cluster_Segment__r.Name
                FROM advpm__Matter__c
                WHERE
                        Name LIKE :'%' + inputTerm + '%'
                LIMIT 25
        ];

        for (advpm__Matter__c matter : matters) {
            data.add(new Auto(matter.Name, matter.Id, matter.Business_Unit_Cluster_Segment__r.Name, matter.Business_Unit_Cluster_Segment__c));
        }

        System.debug(matters);

        return data;
    }

    public Decimal getWeekItemTotal() {
        Decimal total = 0;
        return total;
    }

    //Populate Category drop down
    public List <SelectOption> getCategoryList() {
        List<SelectOption> categorySelectOptionList = new List <SelectOption>();
        List<Work_Category__c> categoryList = workCategories.clone();
        if (categoryList.size() > 0) {
            categorySelectOptionList.add(new SelectOption('', '---None---'));
            for (Work_Category__c eachCategory : categoryList) {
                categorySelectOptionList.add(new SelectOption(eachCategory.Id, eachCategory.Name));
            }
        }
        return categorySelectOptionList;
    }

    //Populate Matter drop down based on Participant and Matter owner
    public List <SelectOption> getMatterList() {

        matterSelectOptionList = new List <SelectOption>();
        matterSelectOptionList.add(new SelectOption('', '---None---'));
        Set<Id> matterIds = new Set<Id>();

        //Participant level
        List <advpm__Participant__c> participantList = [
                SELECT Id, name, advpm__Matter__r.Business_Unit_Cluster_Segment__c, advpm__Matter__c,advpm__Matter__r.Name, advpm__Matter__r.createdById, advpm__Staff__c
                FROM advpm__Participant__c
                WHERE advpm__Staff__c = :UserLoggedIn.id
        ];

        //Have participants.
        if (participantList.size() > 0) {
            for (advpm__Participant__c eachMatter : participantList) {
                //Add to set.
                matterIds.add(eachMatter.advpm__Matter__c);

                //Populate Business Unit Map.
                if (!matterBusinessUnits.containsKey(eachMatter.advpm__Matter__c)) {
                    matterBusinessUnits.put(eachMatter.advpm__Matter__c, eachMatter.advpm__Matter__r.Business_Unit_Cluster_Segment__c);
                }
            }
        }

        //Beginning
        Date rangeDate = Date.today().addMonths(-12);

        return matterSelectOptionList;
    }

    //Constructor
    public TimeSheetEntries_Cont(ApexPages.StandardController controller) {
        System.debug('### TimeSheetEntries_Cont');

        //Default values.
        hasError = false;
        matterBusinessUnits = new Map<String, String>();
        matterBusinessUnits.put('blank', '');

        workCategories = [SELECT Id, Name, Description__c, Allocated__c FROM Work_Category__c];

        System.debug('### TimeSheetEntries_Cont : workCategories');

        //Get date from URL Parameter for Email Alert if no time captured last week
        if (ApexPages.currentPage().getParameters().get('date') != null && ApexPages.currentPage().getParameters().get('date') != ' ' && ApexPages.currentPage().getParameters().get('date') != '') {
            //  WeekSelect = ApexPages.currentPage().getParameters().get('date');

            evt.advpm__Entry_Date__c = date.parse(ApexPages.currentPage().getParameters().get('date'));
        }

        System.debug('### TimeSheetEntries_Cont : timeKeepers');

        UserLoggedIn = [select id, name from user where id = :UserInfo.getUserId() limit 1];

        //Blank variable.
        List<advpm__Timekeeper__c> timeKeepers = new List<advpm__Timekeeper__c>();
        timeKeepers = [
                SELECT
                        Id,
                        advpm__Staff__c,
                        advpm__Staff__r.Name
                FROM advpm__Timekeeper__c
                WHERE
                        advpm__Staff__c = :UserLoggedIn.id
        ];

        System.debug('### TimeSheetEntries_Cont : timeKeepers 2');

        if (!timeKeepers.isEmpty()) {
            timeKeeperLoggedIn = timeKeepers[0];
        } else {
            hasError = true;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Unable to locate a timekeeper record for your user.   Please contact your system administrator for assistance.'));
        }
    }

    public PageReference changeDate() {
        resetTotals();
        shouldLock();
        timesheetEntriesWrapperList = null;
        return null;
    }


    public List<TimesheetEntriesWrapper> getTimesheetDataTable() {
        System.debug('### getTimesheetDataTable');

        // TESTING ON Auto populate for Business for legal Matter Select
        String Matter = Apexpages.currentPage().getParameters().get('Unit');
        system.debug('**Matter**' + Matter);

        shouldLock();

        //Set the first row in Visualforce Page
        counter = 0;
        timeEntryList = new list<advpm__Time__c>();

        if (timesheetEntriesWrapperList == null) {

            timesheetEntriesWrapperList = new list<TimesheetEntriesWrapper>();

            //Get existing Time Entries
            weeklyTimesMap = new Map<String, List<advpm__Time__c>>();
            for (advpm__Time__c eachTimeEntry : [
                    SELECT id, name, advpm__Matter__c, advpm__Matter__r.Name, Category__c, Category__r.Description__c, Category__r.Name,Cluster__c,Segment__c,Business_Unit_Cluster_Segment__c,advpm__Billing_Status__c,advpm__Timekeeper__c,advpm__Entry_Date__c, advpm__Time_In_Hours__c,advpm__Description__c
                    FROM advpm__Time__c
                    WHERE advpm__Timekeeper__c = :timeKeeperLoggedIn.Id
                    AND advpm__Entry_Date__c >= :startDate AND advpm__Entry_Date__c <= :endDate
                    ORDER BY Category__r.Name ASC
            ]) {
                //Create unique identifier
                //CategoryId#MatterId#Cluster#Segnment#BusinessUnit
                String tempUniqueIdentifier = eachTimeEntry.Category__c + '#' + eachTimeEntry.advpm__Matter__c + '#' + eachTimeEntry.Cluster__c + '#' + eachTimeEntry.Segment__c + '#' + eachTimeEntry.Business_Unit_Cluster_Segment__c ;

                if (!weeklyTimesMap.containsKey(tempUniqueIdentifier)) {
                    weeklyTimesMap.put(tempUniqueIdentifier, new List<advpm__Time__c>{
                            eachTimeEntry
                    });
                } else {
                    weeklyTimesMap.get(tempUniqueIdentifier).add(eachTimeEntry);
                }
            }

            //Loop through Map and create wrapper entries for each keySet
            if (weeklyTimesMap != null && weeklyTimesMap.size() > 0) {
                resetTotals();

                for (String eachKey : weeklyTimesMap.keySet()) {
                    List<advpm__Time__c> eachList = weeklyTimesMap.get(eachKey);
                    TimesheetEntriesWrapper timesheetEntriesWrapperItem = new TimesheetEntriesWrapper(eachList);
                    timesheetEntriesWrapperItem.timeEntryItem = weeklyTimesMap.get(eachKey)[0];
                    timesheetEntriesWrapperItem.counterWrap = counter++;
                    timesheetEntriesWrapperList.add(timesheetEntriesWrapperItem);

                    totalMonday += checkTime(timesheetEntriesWrapperItem.mondayHours.advpm__Time_In_Hours__c);
                    grandTotal += checkTime(timesheetEntriesWrapperItem.mondayHours.advpm__Time_In_Hours__c);

                    totalTuesday += checkTime(timesheetEntriesWrapperItem.tuesdayHours.advpm__Time_In_Hours__c);
                    grandTotal += checkTime(timesheetEntriesWrapperItem.tuesdayHours.advpm__Time_In_Hours__c);

                    totalWednesday += checkTime(timesheetEntriesWrapperItem.wednesdayHours.advpm__Time_In_Hours__c);
                    grandTotal += checkTime(timesheetEntriesWrapperItem.wednesdayHours.advpm__Time_In_Hours__c);

                    totalThursday += checkTime(timesheetEntriesWrapperItem.thursdayHours.advpm__Time_In_Hours__c);
                    grandTotal += checkTime(timesheetEntriesWrapperItem.thursdayHours.advpm__Time_In_Hours__c);

                    totalFriday += checkTime(timesheetEntriesWrapperItem.fridayHours.advpm__Time_In_Hours__c);
                    grandTotal += checkTime(timesheetEntriesWrapperItem.fridayHours.advpm__Time_In_Hours__c);

                    totalSaturday += checkTime(timesheetEntriesWrapperItem.saturdayHours.advpm__Time_In_Hours__c);
                    grandTotal += checkTime(timesheetEntriesWrapperItem.saturdayHours.advpm__Time_In_Hours__c);

                    totalSunday += checkTime(timesheetEntriesWrapperItem.sundayHours.advpm__Time_In_Hours__c);
                    grandTotal += checkTime(timesheetEntriesWrapperItem.sundayHours.advpm__Time_In_Hours__c);
                }
            }
        }

        return timesheetEntriesWrapperList;
    }

    private Decimal checkTime(Decimal timeEntered) {
        if (timeEntered < 24) {
            return timeEntered;
        }
        return 0;
    }

    private void shouldLock() {

        //Determine lock date (Should lock 2 weeks going back) 
        if (WeekSelect == null) {
            WeekSelect = String.Valueof(system.today());
        }
        Date selectedDate = Date.newInstance(integer.Valueof(WeekSelect.Left(4)), integer.Valueof(WeekSelect.mid(5, 2)), integer.Valueof(WeekSelect.mid(8, 2)));
        Date selectedDate_weekStart = selectedDate.toStartofWeek();

        String dayOfWeek = ((Datetime) selectedDate_weekStart).format('E');

        //Determine day of week, standard startofweek is SAT-SUN, we need SUN-MON
        if (dayOfWeek == 'Sun') {
            startDate = selectedDate_weekStart.addDays(1);
        } else {
            startDate = selectedDate_weekStart;
        }

        endDate = startDate.addDays(6);

        //Lock indicator to disable all components on VF Page 2 weeks before/after current date

        //Temporary disable
    }

    private void resetTotals() {
        totalMonday = 0;
        totalTuesday = 0;
        totalWednesday = 0;
        totalThursday = 0;
        totalFriday = 0;
        totalSaturday = 0;
        totalSunday = 0;
        grandTotal = 0;
    }

    //Add new empty row
    public PageReference AddTimeEntry() {
        TimesheetEntriesWrapper timesheetEntriesWrapperItem = new TimesheetEntriesWrapper(new List<advpm__Time__c>());
        counter++;
        timesheetEntriesWrapperItem.counterWrap = counter;
        timesheetEntriesWrapperList.add(timesheetEntriesWrapperItem);

        return null;
    }

    //Remove a time entry for the week
    public PageReference RemoveTimeEntry() {
        //Remove existing row from table, before inserting/updating Time Entry and update counter in wrapper class
        Integer param = Integer.valueOf(Apexpages.currentpage().getParameters().get('index'));
        timeEntryDeleteList = new list<advpm__Time__c >();
        TimesheetEntriesWrapper wrapVar;

        for (Integer i = 0; i < timesheetEntriesWrapperList.size(); i++) {
            if (timesheetEntriesWrapperList[i].counterWrap == param) {
                wrapVar = timesheetEntriesWrapperList[i];

                if (wrapVar.mondayHours != null) {
                    timeEntryDeleteList.add(wrapVar.mondayHours);
                    totalMonday -= wrapVar.mondayHours.advpm__Time_In_Hours__c;
                    grandTotal -= wrapVar.mondayHours.advpm__Time_In_Hours__c;
                }
                if (wrapVar.tuesdayHours != null) {
                    timeEntryDeleteList.add(wrapVar.tuesdayHours);
                    totalTuesday -= wrapVar.tuesdayHours.advpm__Time_In_Hours__c;
                    grandTotal -= wrapVar.tuesdayHours.advpm__Time_In_Hours__c;
                }
                if (wrapVar.wednesdayHours != null) {
                    timeEntryDeleteList.add(wrapVar.wednesdayHours);
                    totalWednesday -= wrapVar.wednesdayHours.advpm__Time_In_Hours__c;
                    grandTotal -= wrapVar.wednesdayHours.advpm__Time_In_Hours__c;
                }
                if (wrapVar.thursdayHours != null) {
                    timeEntryDeleteList.add(wrapVar.thursdayHours);
                    totalThursday -= wrapVar.thursdayHours.advpm__Time_In_Hours__c;
                    grandTotal -= wrapVar.thursdayHours.advpm__Time_In_Hours__c;
                }
                if (wrapVar.fridayHours != null) {
                    timeEntryDeleteList.add(wrapVar.fridayHours);
                    totalFriday -= wrapVar.fridayHours.advpm__Time_In_Hours__c;
                    grandTotal -= wrapVar.fridayHours.advpm__Time_In_Hours__c;
                }
                if (wrapVar.saturdayHours != null) {
                    timeEntryDeleteList.add(wrapVar.saturdayHours);
                    totalSaturday -= wrapVar.saturdayHours.advpm__Time_In_Hours__c;
                    grandTotal -= wrapVar.saturdayHours.advpm__Time_In_Hours__c;
                }
                if (wrapVar.sundayHours != null) {
                    timeEntryDeleteList.add(wrapVar.sundayHours);
                    totalSunday -= wrapVar.sundayHours.advpm__Time_In_Hours__c;
                    grandTotal -= wrapVar.sundayHours.advpm__Time_In_Hours__c;
                }

                timesheetEntriesWrapperList.remove(i);
            }
        }

        if (timeEntryDeleteList != null) {

            try {
                delete timeEntryDeleteList;

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, 'Time record(s) deleted successfully'));
                return null;
            } catch (Exception e) {
                //If no information captured, no index, so no need to dispaly error
                if (e.getMessage().contains('Missing id at index: 0')) {
                    System.debug(e.getMessage());
                } else {
                    ApexPages.addMessages(e);
                }
            }
        }

        counter--;

        PageReference standardPage = new PageReference('/');
        standardPage.setRedirect(true);

        //Redirect.
        return standardPage;
    }

    //Save all time entries
    public PageReference SaveTimeEntry() {
        timeEntryInsertList = new list<advpm__Time__c >();
        timeEntrySet = new Set<String>();
        Integer rowCount = 0;
        //Get all time entries based on the cloned temp time entries used on the VF Page
        if (!timesheetEntriesWrapperList.isEmpty()) {
            for (TimesheetEntriesWrapper eachTimesheetEntriesWrapper : timesheetEntriesWrapperList) {
                rowCount++;

                if (!timeEntrySet.contains(eachTimesheetEntriesWrapper.timeEntryItem.Category__c + '#' + eachTimesheetEntriesWrapper.timeEntryItem.advpm__Matter__c + '#' + eachTimesheetEntriesWrapper.timeEntryItem.Cluster__c + '#' + eachTimesheetEntriesWrapper.timeEntryItem.Segment__c + '#' + eachTimesheetEntriesWrapper.timeEntryItem.Business_Unit_Cluster_Segment__c + '#' + startDate))
                {
                    timeEntryInsertList.add(createTimeEntry(eachTimesheetEntriesWrapper.timeEntryItem, eachTimesheetEntriesWrapper.mondayHours, startDate));
                    timeEntryInsertList.add(createTimeEntry(eachTimesheetEntriesWrapper.timeEntryItem, eachTimesheetEntriesWrapper.tuesdayHours, startDate.addDays(1)));
                    timeEntryInsertList.add(createTimeEntry(eachTimesheetEntriesWrapper.timeEntryItem, eachTimesheetEntriesWrapper.wednesdayHours, startDate.addDays(2)));
                    timeEntryInsertList.add(createTimeEntry(eachTimesheetEntriesWrapper.timeEntryItem, eachTimesheetEntriesWrapper.thursdayHours, startDate.addDays(3)));
                    timeEntryInsertList.add(createTimeEntry(eachTimesheetEntriesWrapper.timeEntryItem, eachTimesheetEntriesWrapper.fridayHours, startDate.addDays(4)));
                    timeEntryInsertList.add(createTimeEntry(eachTimesheetEntriesWrapper.timeEntryItem, eachTimesheetEntriesWrapper.saturdayHours, startDate.addDays(5)));
                    timeEntryInsertList.add(createTimeEntry(eachTimesheetEntriesWrapper.timeEntryItem, eachTimesheetEntriesWrapper.sundayHours, startDate.addDays(6)));

                    timeEntrySet.add(eachTimesheetEntriesWrapper.timeEntryItem.Category__c + '#' + eachTimesheetEntriesWrapper.timeEntryItem.advpm__Matter__c + '#' + eachTimesheetEntriesWrapper.timeEntryItem.Cluster__c + '#' + eachTimesheetEntriesWrapper.timeEntryItem.Segment__c + '#' + eachTimesheetEntriesWrapper.timeEntryItem.Business_Unit_Cluster_Segment__c + '#' + startDate);
                } else {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Duplicate Time Entry at Row ' + rowCount + ', please update existing Time'));
                    return null;
                }
            }
        }

        if (!timeEntryInsertList.isEmpty()) {
            try {
                upsert timeEntryInsertList id;
                timesheetEntriesWrapperList = null;

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Time record(s) added successfully'));
                return null;

            } catch (Exception e) {
                ApexPages.addMessages(e);
            }
        }

        return null;
    }

    public advpm__Time__c createTimeEntry(advpm__Time__c placHolderTime, advpm__Time__c timesheetWrap, Date EntryDate) {
        //Create time entries based on hours captured and temp time entry for category, cluster etc.
        if (timesheetWrap != null) {
            Decimal timeHours = timesheetWrap.advpm__Time_In_Hours__c;
            String timeEntryName = timesheetWrap.advpm__Matter__r.Name; //String.valueOf(timesheetWrap.advpm__Entry_Date__c);

            timesheetWrap.name = timeEntryName;
            timesheetWrap.advpm__Billing_Status__c = 'Unprocessed';
            timesheetWrap.advpm__Entry_Date__c = EntryDate;
            timesheetWrap.Category__c = placHolderTime.Category__c;

            timesheetWrap.advpm__Matter__c = placHolderTime.advpm__Matter__c;

            timesheetWrap.Cluster__c = placHolderTime.Cluster__c;
            timesheetWrap.Segment__c = placHolderTime.Segment__c;
            //timesheetWrap.Business_Unit_Legal__c = placHolderTime.Business_Unit_Legal__c; Business_Unit_Cluster_Segment__c
            timesheetWrap.Business_Unit_Cluster_Segment__c = placHolderTime.Business_Unit_Cluster_Segment__c;
            timesheetWrap.advpm__Description__c = placHolderTime.advpm__Description__c;
            timesheetWrap.advpm__Timekeeper__c = placHolderTime.advpm__Timekeeper__c;

            if(timeKeeperLoggedIn != null){
                if (placHolderTime.advpm__Timekeeper__c == null) {
                    timesheetWrap.advpm__Timekeeper__c = timeKeeperLoggedIn.id;
                } else {
                    timesheetWrap.advpm__Timekeeper__c = placHolderTime.advpm__Timekeeper__c;
                }
            }
        }
        return timesheetWrap;
    }

    public PageReference CancelPage() {
        pagereference pf = new pagereference('/home/home.jsp');
        return pf;
    }

    public class TimesheetEntriesWrapper {
        public advpm__Time__c timeEntryItem { get; set; }

        public String matterName { get; set; }
        public String matterId { get; set; }
        public String businessName;
        public String businessId;

        public Integer counterWrap { get; set; }
        public decimal totalForWeek { get; set; }
        public advpm__Time__c mondayHours { get; set; }
        public advpm__Time__c tuesdayHours { get; set; }
        public advpm__Time__c wednesdayHours { get; set; }
        public advpm__Time__c thursdayHours { get; set; }
        public advpm__Time__c fridayHours { get; set; }
        public advpm__Time__c saturdayHours { get; set; }
        public advpm__Time__c sundayHours { get; set; }


        public TimesheetEntriesWrapper(List<advpm__Time__c> weekTimeList) {
            totalForWeek = 0;
            Decimal defaultHours = 0;
            timeEntryItem = new advpm__Time__c();

            //Set default hours to 0.00
            if (weekTimeList.size() > 0) {
                mondayHours = new advpm__Time__c();
                mondayHours.advpm__Time_In_Hours__c = defaultHours;
                tuesdayHours = new advpm__Time__c();
                tuesdayHours.advpm__Time_In_Hours__c = defaultHours;
                wednesdayHours = new advpm__Time__c();
                wednesdayHours.advpm__Time_In_Hours__c = defaultHours;
                thursdayHours = new advpm__Time__c();
                thursdayHours.advpm__Time_In_Hours__c = defaultHours;
                fridayHours = new advpm__Time__c();
                fridayHours.advpm__Time_In_Hours__c = defaultHours;
                saturdayHours = new advpm__Time__c();
                saturdayHours.advpm__Time_In_Hours__c = defaultHours;
                sundayHours = new advpm__Time__c();
                sundayHours.advpm__Time_In_Hours__c = defaultHours;
            }

            //Loop through the list of times and identify which day of the week, add hours to related time record
            for (advpm__Time__c eachTime : weekTimeList) {
                if (eachTime.advpm__Time_In_Hours__c == null) {
                    eachTime.advpm__Time_In_Hours__c = defaultHours;
                }

                timeEntryItem = eachTime;
                DateTime tempDateEntry = eachTime.advpm__Entry_Date__c;
                String dayOfWeek = tempDateEntry.format('E');

                if (dayOfWeek == 'Mon') {
                    mondayHours = eachTime;
                } else if (dayOfWeek == 'Tue') {
                    tuesdayHours = eachTime;
                } else if (dayOfWeek == 'Wed') {
                    wednesdayHours = eachTime;
                } else if (dayOfWeek == 'Thu') {
                    thursdayHours = eachTime;
                } else if (dayOfWeek == 'Fri') {
                    fridayHours = eachTime;
                } else if (dayOfWeek == 'Sat') {
                    saturdayHours = eachTime;
                } else if (dayOfWeek == 'Sun') {
                    sundayHours = eachTime;
                }
            }

            if (mondayHours == null) {
                mondayHours = timeEntryItem.clone(false, false, false, false);
                mondayHours.advpm__Time_In_Hours__c = defaultHours;
            }

            if (tuesdayHours == null) {
                tuesdayHours = timeEntryItem.clone(false, false, false, false);
                tuesdayHours.advpm__Time_In_Hours__c = defaultHours;
            }

            if (wednesdayHours == null) {
                wednesdayHours = timeEntryItem.clone(false, false, false, false);
                wednesdayHours.advpm__Time_In_Hours__c = defaultHours;
            }

            if (thursdayHours == null) {
                thursdayHours = timeEntryItem.clone(false, false, false, false);
                thursdayHours.advpm__Time_In_Hours__c = defaultHours;
            }

            if (fridayHours == null) {
                fridayHours = timeEntryItem.clone(false, false, false, false);
                fridayHours.advpm__Time_In_Hours__c = defaultHours;
            }

            if (saturdayHours == null) {
                saturdayHours = timeEntryItem.clone(false, false, false, false);
                saturdayHours.advpm__Time_In_Hours__c = defaultHours;
            }

            if (sundayHours == null) {
                sundayHours = timeEntryItem.clone(false, false, false, false);
                sundayHours.advpm__Time_In_Hours__c = defaultHours;
            }

            totalForWeek = mondayHours.advpm__Time_In_Hours__c + tuesdayHours.advpm__Time_In_Hours__c + wednesdayHours.advpm__Time_In_Hours__c + thursdayHours.advpm__Time_In_Hours__c + fridayHours.advpm__Time_In_Hours__c + saturdayHours.advpm__Time_In_Hours__c + sundayHours.advpm__Time_In_Hours__c;
        }
    }

    public class Auto {
        public String label { get; set; }
        public String value { get; set; }
        public String buLabel { get; set; }
        public String buValue { get; set; }

        public Auto(String iLabel, String iValue, String buLabel, String buValue) {
            this.label = iLabel;
            this.value = iValue;
            this.buLabel = buLabel;
            this.buValue = buValue;
        }
    }

}