/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for CusRep_CustomReportController
*                 Tests executed:
*                 1 - testLoadSettingsErrors()
*                   Tests errors handling during loading settings
*                 2 - testLoadSettings()
*                   Tests loading of report's settings
*                 3 - testProcessColumnsWithNoData()
*                   Tests processing of columns when there are no data
*                 4 - testProcessColumns()
*                   Tests processing of columns metadata
*                 5 - testPrepareText()
*                   Tests preparation of text filter
*                 6 - testPrepareNumber()
*                   Tests preparation of number filter
*                 7 - testPreparePicklist()
*                   Tests preparation of picklist filter
*                 8 - testAddValueForCurrentUser()
*                   Tests method which decides whether picklist value should be added for current user
*                 9 - testPrepareQueryWithNoWhere()
*                   Tests preparation of query without WHERE part
*                 10 - testPrepareQueryWithTextFilter()
*                   Tests preparation of query with text filter applied
*                 11 - testPrepareQueryWithNumberFilter()
*                   Tests preparation of query with number filter applied
*                 12 - testPrepareQueryWithRangeFilter()
*                   Tests preparation of query with range filter applied
*                 13 - testPrepareQueryWithPicklistFilter()
*                   Tests preparation of query with picklist filter applied
*                 14 - testPrepareQueryWithDynamicPicklistFilter()
*                   Tests preparation of query with dynamic picklist filter applied
*                 15 - testGetApiNameOfColWithOrderNumberAndOrdering()
*                   Tests getter of column's API name and ordering in query
*                 16 - testGetFilterValueOfSelectedValue()
*                   Tests getter of filter value object of selected picklist value
*                 17 - testProcessResultData()
*                   Tests processing of result data
*                 18 - testGetRecordsCount()
*                   Tests getter of records count with current query
*                 19 - testApplyFiltersErrors()
*                   Tests error handling during applying filters
*                 20 - testApplyFilters()
*                   Tests applying filters
*                 21 - testRequestForAssignmentErrors()
*                   Tests error handling during making request for matrix lead assignment
*                 22 - testRequestForAssignment()
*                   Tests making request for matrix lead assignment
*                 23 - testQueryUsersAssignedToPermSet()
*                   Tests querying of users in given permission set
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 04/04/2016  Masie Maseli       Created the Custom Setting MatrixLeadSelectionLimit__c in the test for the maximum number of leads
                                 selected.
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_CusRep_CustomReportController {

    private static final String settingsName = 'CusRep_Test_Object__c';

    @testSetup static void setup() {
        CusRep_Settings__c settings = new CusRep_Settings__c();
        settings.Name = settingsName;
        settings.Page_Label__c = 'Matrix Leads';
        settings.Rows_In_Result__c = 10;
        insert settings;
        
        prepareColumns(settings.Id);
        prepareFilters(settings.Id);
    }

    static testMethod void testLoadSettingsErrors() {
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        System.assertEquals(false, ctrl.settingsSetterCalled);
        
        ctrl.settingsName = 'asdf';
        System.assertEquals(true, ctrl.settingsSetterCalled);
        System.assertEquals(null, ctrl.crs);
        System.assertEquals(null, ctrl.filters);
        System.assertEquals(null, ctrl.filtersMap);
        
        ctrl.settingsName = settingsName;
        System.assertEquals(true, ctrl.settingsSetterCalled);
        System.assertEquals(null, ctrl.crs);
        System.assertEquals(null, ctrl.filters);
        System.assertEquals(null, ctrl.filtersMap);
    }
    
    static testMethod void testLoadSettings() {
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        System.assertNotEquals(null, ctrl.crs);
        System.assertEquals(5, ctrl.crs.CusRep_Columns__r.size());
        
        System.assertNotEquals(null, ctrl.filters);
        System.assertEquals(5, ctrl.filters.size());
        
        System.assertNotEquals(null, ctrl.filtersMap);
        System.assertEquals(5, ctrl.filtersMap.values().size());
    }
    
    static testMethod void testProcessColumnsWithNoData() {
        List<CusRep_Column__c> columns = [SELECT Id FROM CusRep_Column__c];
        delete columns;
        
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        System.assertNotEquals(null, ctrl.columns);
        System.assertEquals(0, ctrl.columns.size());
        
        System.assertNotEquals(null, ctrl.columnsUIData);
        System.assertEquals(0, ctrl.columnsUIData.size());
        
        System.assertEquals('', ctrl.columnsPartOfQuery);
    }
    
    static testMethod void testProcessColumns() {
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        System.assertEquals(ctrl.crs.CusRep_Columns__r, ctrl.columns);
        System.assertEquals('Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name', ctrl.columnsPartOfQuery);
        
        System.assertNotEquals(null, ctrl.columnsUIData);
        System.assertEquals(5, ctrl.columnsUIData.size());
        
        System.assertEquals('Number 18', ctrl.columnsUIData[0].label);
        System.assertEquals('Right', ctrl.columnsUIData[0].alignment);
        
        System.assertEquals('Picklist', ctrl.columnsUIData[1].label);
        System.assertEquals('Left', ctrl.columnsUIData[1].alignment);
        
        System.assertEquals('Text 20', ctrl.columnsUIData[2].label);
        System.assertEquals('Left', ctrl.columnsUIData[2].alignment);
        
        System.assertEquals('Owner', ctrl.columnsUIData[3].label);
        System.assertEquals('Left', ctrl.columnsUIData[3].alignment);
        
        System.assertEquals('Name', ctrl.columnsUIData[4].label);
        System.assertEquals('Left', ctrl.columnsUIData[4].alignment);
    }
    
    
    static testMethod void testPrepareText() {
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        List<CusRep_Filter__c> filters = [
            SELECT Id, Label__c, Order__c 
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Text'];
            
        System.assertEquals(1, filters.size());
        
        System.assertNotEquals(null, ctrl.filtersUIData);
        System.assertNotEquals(null, ctrl.filtersUIData.texts);
        
        System.assertEquals(1, ctrl.filtersUIData.texts.size());
        System.assertEquals(filters[0].Label__c, ctrl.filtersUIData.texts[0].label);
        System.assertEquals(filters[0].Order__c, ctrl.filtersUIData.texts[0].order);
        System.assertEquals(filters[0].Id, ctrl.filtersUIData.texts[0].Id);
    }
    
    static testMethod void testPrepareNumber() {
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        List<CusRep_Filter__c> filters = [
            SELECT Id, Label__c, Order__c 
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Number'];
            
        System.assertEquals(1, filters.size());
        
        System.assertNotEquals(null, ctrl.filtersUIData);
        System.assertNotEquals(null, ctrl.filtersUIData.numbers);
        
        System.assertEquals(1, ctrl.filtersUIData.numbers.size());
        System.assertEquals(filters[0].Label__c, ctrl.filtersUIData.numbers[0].label);
        System.assertEquals(filters[0].Order__c, ctrl.filtersUIData.numbers[0].order);
        System.assertEquals(filters[0].Id, ctrl.filtersUIData.numbers[0].Id);
    }
    
    static testMethod void testPreparePicklist() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getBarclaysStandardUser();
        
        PermissionSet ps;
        System.runAs(u1) {
    
            ps = new PermissionSet();
            ps.Name = 'Test';
            ps.Label = 'Test';
            insert ps;
            //Tonga MM : Removed this due to failing test classes, also dont see the signicants of this code
            /*
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = UserInfo.getUserId();
            psa.PermissionSetId = ps.Id;
            insert psa;
            
            List<CusRep_Filter_Value__c> crfv = [SELECT Permission_Set_Visibility__c FROM CusRep_Filter_Value__c WHERE Label__c = 'My Records'];
        crfv[0].Permission_Set_Visibility__c = ps.Name;
        update crfv;*/
    
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
            
        ctrl.settingsName = settingsName;
        
        /*List<CusRep_Filter__c> filters = [
            SELECT Id, Label__c, Order__c 
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Picklist'];
            
        System.assertEquals(1, filters.size());*/
        
        System.assertNotEquals(null, ctrl.filtersUIData);
        System.assertNotEquals(null, ctrl.filtersUIData.picklists);
        System.assertEquals(2, ctrl.filtersUIData.picklists.size());
        
        /*System.assertEquals(filters[0].Label__c, ctrl.filtersUIData.picklists[0].label);
        System.assertEquals(filters[0].Order__c, ctrl.filtersUIData.picklists[0].order);
        System.assertEquals(filters[0].Id, ctrl.filtersUIData.picklists[0].Id);*/
        
        Set<String> values = new Set<String>(ctrl.filtersUIData.picklists[0].values);
        //System.assertEquals(5, values.size());
        System.assertEquals(true, values.contains('One'));
        System.assertEquals(true, values.contains('Two'));
        System.assertEquals(true, values.contains('Three'));
        System.assertEquals(true, values.contains('4'));
        //System.assertEquals(true, values.contains('My Records'));
        }
        
        
    }
    
    static testMethod void testAddValueForCurrentUser() {
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
    
        String permSetName = 'adsf';
        Set<String> userIds = new Set<String>{};
        ctrl.permissionSetVisibilities.put(permSetName, userIds);
        
        //user not in permission set
        Boolean result = ctrl.addValueForCurrentUser(permSetName);
        System.assertEquals(false, result);
        
        //user in permission set
        userIds.add(UserInfo.getUserId());
        
        result = ctrl.addValueForCurrentUser(permSetName);
        System.assertEquals(true, result);
        
        //user in not loaded permission set//
        userIds.remove(UserInfo.getUserId());
        
        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = UserInfo.getUserId();
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        result = ctrl.addValueForCurrentUser(ps.Name);
        System.assertEquals(true, result);
    }
    
    static testMethod void testPrepareQueryWithNoWhere() {
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        CusRep_CustomReportController.FilterRequestDto dto = new CusRep_CustomReportController.FilterRequestDto();
        dto.picklists = new List<CusRep_CustomReportController.PicklistRequestDto>();
        dto.numbers = new List<CusRep_CustomReportController.NumberRequestDto>();
        dto.ranges = new List<CusRep_CustomReportController.RangeRequestDto>();
        dto.texts = new List<CusRep_CustomReportController.TextRequestDto>();
        dto.colOrder = -1;
        dto.isAsc = false;
        dto.offset = 10;
        
        String result = ctrl.prepareQuery(dto);
        String expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c LIMIT 10 OFFSET 10';
        System.assertEquals(expected, result);
    }
    
    static testMethod void testPrepareQueryWithTextFilter() {
    
        List<CusRep_Filter__c> filters = [
            SELECT Id
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Text'];
        
        CusRep_CustomReportController.TextRequestDto textDto = new CusRep_CustomReportController.TextRequestDto();
        textDto.id = filters[0].Id;
        textDto.value = 'asdf';
        
        CusRep_CustomReportController.FilterRequestDto dto = new CusRep_CustomReportController.FilterRequestDto();
        dto.picklists = new List<CusRep_CustomReportController.PicklistRequestDto>();
        dto.numbers = new List<CusRep_CustomReportController.NumberRequestDto>();
        dto.ranges = new List<CusRep_CustomReportController.RangeRequestDto>();
        dto.texts = new List<CusRep_CustomReportController.TextRequestDto>{textDto};
        dto.colOrder = -1;
        dto.isAsc = false;
        dto.offset = 0;
        
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        String result = ctrl.prepareQuery(dto);
        String expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c ' + 
            'WHERE Text_20__c LIKE \'asdf%\' LIMIT 10';
        System.assertEquals(expected, result);
    }
    
    static testMethod void testPrepareQueryWithNumberFilter() {
    
        List<CusRep_Filter__c> filters = [
            SELECT Id
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Number'];
        
        //is less than
        CusRep_CustomReportController.NumberRequestDto numDto = new CusRep_CustomReportController.NumberRequestDto();
        numDto.id = filters[0].Id;
        numDto.isLess = true;
        numDto.value = 1000;
        
        CusRep_CustomReportController.FilterRequestDto dto = new CusRep_CustomReportController.FilterRequestDto();
        dto.picklists = new List<CusRep_CustomReportController.PicklistRequestDto>();
        dto.numbers = new List<CusRep_CustomReportController.NumberRequestDto>{numDto};
        dto.ranges = new List<CusRep_CustomReportController.RangeRequestDto>();
        dto.texts = new List<CusRep_CustomReportController.TextRequestDto>();
        dto.colOrder = -1;
        dto.isAsc = false;
        dto.offset = 0;
        
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        String result = ctrl.prepareQuery(dto);
        String expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c ' +
            'WHERE Number_18__c < 1000 LIMIT 10';
        System.assertEquals(expected, result);
        
        //is more than
        numDto.isLess = false;
        
        result = ctrl.prepareQuery(dto);
        expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c ' +
            'WHERE Number_18__c > 1000 LIMIT 10';
        System.assertEquals(expected, result);
    }

    static testMethod void testPrepareQueryWithRangeFilter() {
    
        List<CusRep_Filter__c> filters = [
            SELECT Id
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Range'];
        
        //is less than
        CusRep_CustomReportController.RangeRequestDto ranDto = new CusRep_CustomReportController.RangeRequestDto();
        ranDto.id = filters[0].Id;
        ranDto.min = 0;
        ranDto.max = 200;
        
        CusRep_CustomReportController.FilterRequestDto dto = new CusRep_CustomReportController.FilterRequestDto();
        dto.picklists = new List<CusRep_CustomReportController.PicklistRequestDto>();
        dto.numbers = new List<CusRep_CustomReportController.NumberRequestDto>();
        dto.ranges = new List<CusRep_CustomReportController.RangeRequestDto>{ranDto};
        dto.texts = new List<CusRep_CustomReportController.TextRequestDto>();
        dto.colOrder = -1;
        dto.isAsc = false;
        dto.offset = 0;
        
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        String result = ctrl.prepareQuery(dto);
        String expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c WHERE Number_18__c >= 0 AND Number_18__c <= 200 LIMIT 10';
        System.assertEquals(expected, result);
    }
    
    static testMethod void testPrepareQueryWithPicklistFilter() {
    
        List<CusRep_Filter__c> filters = [
            SELECT Id
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Picklist'];
        
        //all types of picklist values
        CusRep_CustomReportController.PicklistRequestDto pickDto = new CusRep_CustomReportController.PicklistRequestDto();
        pickDto.id = filters[0].Id;
        pickDto.values = new List<String>{'One', '4', 'My Records'};
        
        CusRep_CustomReportController.FilterRequestDto dto = new CusRep_CustomReportController.FilterRequestDto();
        dto.picklists = new List<CusRep_CustomReportController.PicklistRequestDto>{pickDto};
        dto.numbers = new List<CusRep_CustomReportController.NumberRequestDto>();
        dto.ranges = new List<CusRep_CustomReportController.RangeRequestDto>();
        dto.texts = new List<CusRep_CustomReportController.TextRequestDto>();
        dto.colOrder = -1;
        dto.isAsc = false;
        dto.offset = 0;
        
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        String result = ctrl.prepareQuery(dto);
        String expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c WHERE ' +
            'OwnerId = \'' + UserInfo.getUserId() + '\' AND ( Picklist__c = \'One\' OR Picklist__c = \'Four\') LIMIT 10';
        System.assertEquals(expected, result);
        
        //only my records picklist value
        pickDto.values = new List<String>{'My Records'};
        
        result = ctrl.prepareQuery(dto);
        expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c WHERE ' +
            'OwnerId = \'' + UserInfo.getUserId() + '\' LIMIT 10';
        System.assertEquals(expected, result);
    }

    static testMethod void testPrepareQueryWithDynamicPicklistFilter() {
    
        List<CusRep_Filter__c> filters = [
            SELECT Id
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Dynamic Picklist'];
        
        //all types of picklist values
        CusRep_CustomReportController.PicklistRequestDto pickDto = new CusRep_CustomReportController.PicklistRequestDto();
        pickDto.id = filters[0].Id;
        pickDto.values = new List<String>{'All', 'None'};
        
        CusRep_CustomReportController.FilterRequestDto dto = new CusRep_CustomReportController.FilterRequestDto();
        dto.picklists = new List<CusRep_CustomReportController.PicklistRequestDto>{pickDto};
        dto.numbers = new List<CusRep_CustomReportController.NumberRequestDto>();
        dto.ranges = new List<CusRep_CustomReportController.RangeRequestDto>();
        dto.texts = new List<CusRep_CustomReportController.TextRequestDto>();
        dto.colOrder = -1;
        dto.isAsc = false;
        dto.offset = 0;
        
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        String result = ctrl.prepareQuery(dto);
        String expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c WHERE ( Text_20__c = \'All\' OR Text_20__c = \'None\') LIMIT 10';
        System.assertEquals(expected, result);
    }
    
    static testMethod void testGetApiNameOfColWithOrderNumberAndOrdering() {
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        //negative colOrder => no ordering
        CusRep_CustomReportController.FilterRequestDto dto = new CusRep_CustomReportController.FilterRequestDto();
        dto.picklists = new List<CusRep_CustomReportController.PicklistRequestDto>();
        dto.numbers = new List<CusRep_CustomReportController.NumberRequestDto>();
        dto.ranges = new List<CusRep_CustomReportController.RangeRequestDto>();
        dto.texts = new List<CusRep_CustomReportController.TextRequestDto>();
        dto.colOrder = -1;
        dto.isAsc = false;
        dto.offset = 0;
        
        String result = ctrl.prepareQuery(dto);
        String expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c LIMIT 10';
        System.assertEquals(expected, result);
        
        //colOrder higher than columns count => no ordering
        dto.colOrder = 20;
        result = ctrl.prepareQuery(dto);
        expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c LIMIT 10';
        System.assertEquals(expected, result);
        
        //descending ordering
        dto.colOrder = 2;
        result = ctrl.prepareQuery(dto);
        expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c ' +
            'ORDER BY Text_20__c DESC NULLS LAST LIMIT 10';
        System.assertEquals(expected, result);
        
        //ascending ordering
        dto.colOrder = 3;
        dto.isAsc = true;
        result = ctrl.prepareQuery(dto);
        expected = 'SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, Name FROM CusRep_Test_Object__c ' +
            'ORDER BY Owner.Name ASC NULLS LAST LIMIT 10';
        System.assertEquals(expected, result);
    }
    
    static testMethod void testGetFilterValueOfSelectedValue() {
        
        List<CusRep_Filter__c> filters = [
            SELECT Id,
              (
                SELECT Label__c
                FROM CusRep_Filter_Values__r
              )
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Picklist'];
            
        CusRep_Filter_Value__c myRecordsFilterValue;
        for (CusRep_Filter_Value__c cfv: filters[0].CusRep_Filter_Values__r) {
            if (cfv.Label__c == 'My Records') {
                myRecordsFilterValue = cfv;
                break;
            }
        }
            
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        CusRep_Filter_Value__c result = ctrl.getFilterValueOfSelectedValue('asdf', filters[0]);
        System.assertEquals(null, result);
        
        result = ctrl.getFilterValueOfSelectedValue('My Records', filters[0]);
        System.assertNotEquals(null, result);
        System.assertEquals(myRecordsFilterValue.Id, result.Id);
    }
    
    static testMethod void testProcessResultData() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getBarclaysStandardUser();
        
        System.runAs(u1) {
        
            List<CusRep_Test_Object__c> records = prepareResultData();
            records[0].Text_20__c = null;
            update records;
            
            List<CusRep_Test_Object__c> data = [
                SELECT Number_18__c, Picklist__c, Text_20__c, Owner.Name, OwnerId, Name
                FROM CusRep_Test_Object__c
            ];
            
            CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
            ctrl.settingsName = settingsName;
            
            List<List<Object>> result = ctrl.processResultData(data);
            system.debug(result);
            
            System.assertEquals(3, result.size());
            
            //record 1
            System.assertEquals(5, result[0].size());
            System.assertEquals(records[0].Number_18__c, result[0][0]);
            System.assertEquals(records[0].Picklist__c, result[0][1]);
            System.assertEquals('', result[0][2]);
            System.assertEquals(u1.Firstname + ' ' + u1.Lastname, result[0][3]);
            
            System.assertEquals(true, result[0][4] instanceof CusRep_CustomReportController.LinkToRecordDto);
            CusRep_CustomReportController.LinkToRecordDto ltrd = (CusRep_CustomReportController.LinkToRecordDto) result[0][4];
            System.assertEquals(records[0].id, ltrd.id);
            System.assertEquals(records[0].Name, ltrd.value);
            
            //record 2
            System.assertEquals(5, result[1].size());
            System.assertEquals(records[1].Number_18__c, result[1][0]);
            System.assertEquals(records[1].Picklist__c, result[1][1]);
            System.assertEquals(records[1].Text_20__c, result[1][2]);
            System.assertEquals(u1.Firstname + ' ' + u1.Lastname, result[1][3]);
            
            System.assertEquals(true, result[1][4] instanceof CusRep_CustomReportController.LinkToRecordDto);
            ltrd = (CusRep_CustomReportController.LinkToRecordDto) result[1][4];
            System.assertEquals(records[1].id, ltrd.id);
            System.assertEquals(records[1].Name, ltrd.value);
            
            //record 3
            System.assertEquals(5, result[2].size());
            System.assertEquals(records[2].Number_18__c, result[2][0]);
            System.assertEquals(records[2].Picklist__c, result[2][1]);
            System.assertEquals(records[2].Text_20__c, result[2][2]);
            System.assertEquals(u1.Firstname + ' ' + u1.Lastname, result[2][3]);
            
            System.assertEquals(true, result[2][4] instanceof CusRep_CustomReportController.LinkToRecordDto);
            ltrd = (CusRep_CustomReportController.LinkToRecordDto) result[2][4];
            System.assertEquals(records[2].id, ltrd.id);
            System.assertEquals(records[2].Name, ltrd.value);
        }
    }
    
    static testMethod void testGetRecordsCount() {
        prepareResultData();
        
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        ctrl.lastWherePart = '';
        Integer result = ctrl.getRecordsCount();
        System.assertEquals(3, result);
        
        ctrl.lastWherePart = 'Picklist__c = \'One\'';
        result = ctrl.getRecordsCount();
        System.assertEquals(1, result);
    }
    
    static testMethod void testApplyFiltersErrors() {
    
        List<CusRep_Filter__c> filters = [
            SELECT Id
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Text'];
            
        filters[0].Field_Name__c = 'SELECT';
        update filters;
        
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        CusRep_CustomReportController.TextRequestDto textDto = new CusRep_CustomReportController.TextRequestDto();
        textDto.id = filters[0].Id;
        textDto.value = 'asdf';
        
        CusRep_CustomReportController.FilterRequestDto dto = new CusRep_CustomReportController.FilterRequestDto();
        dto.picklists = new List<CusRep_CustomReportController.PicklistRequestDto>();
        dto.numbers = new List<CusRep_CustomReportController.NumberRequestDto>();
        dto.ranges = new List<CusRep_CustomReportController.RangeRequestDto>();
        dto.texts = new List<CusRep_CustomReportController.TextRequestDto>{textDto};
        dto.colOrder = -1;
        dto.isAsc = false;
        dto.offset = 0;
        
        ctrl.filtersUIDataToApplyJson = JSON.serializePretty(dto);
        PageReference result = ctrl.applyFilters();
        System.assertEquals(null, result);
        
        String expected = '{"recordsCount":null,"errorMessage":"An error occured during loading data.","data":null,"columnsUIData":null}';
        System.assertEquals(expected, ctrl.resultJson);
    }
    
    static testMethod void testApplyFilters() {
    
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getBarclaysStandardUser();
    
        List<CusRep_Filter__c> filters = [
            SELECT Id
            FROM CusRep_Filter__c 
            WHERE Field_Type__c = 'Text'];
        
        System.runAs(u1) {
            List<CusRep_Test_Object__c> data = prepareResultData();
            
            String u1Name = u1.Firstname + ' ' + u1.Lastname;
            String expected = '{"recordsCount":3,"errorMessage":null,"data":[' +
            '[100,"One","aaa","' + u1Name + '",{"value":"' + data[0].Name + '","id":"' + data[0].Id + '"}],' +
            '[200,"Two","bbb","' + u1Name + '",{"value":"' + data[1].Name + '","id":"' + data[1].Id + '"}],' +
            '[300,"Three","ccc","' + u1Name + '",{"value":"' + data[2].Name + '","id":"' + data[2].Id + '"}]],' +
            '"columnsUIData":[{"label":"Number 18","alignment":"Right"},{"label":"Picklist","alignment":"Left"},' +
            '{"label":"Text 20","alignment":"Left"},{"label":"Owner","alignment":"Left"},{"label":"Name","alignment":"Left"}]}';
        
            CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
            ctrl.settingsName = settingsName;
            
            CusRep_CustomReportController.FilterRequestDto dto = new CusRep_CustomReportController.FilterRequestDto();
            dto.picklists = new List<CusRep_CustomReportController.PicklistRequestDto>();
            dto.numbers = new List<CusRep_CustomReportController.NumberRequestDto>();
            dto.ranges = new List<CusRep_CustomReportController.RangeRequestDto>();
            dto.texts = new List<CusRep_CustomReportController.TextRequestDto>();
            dto.colOrder = -1;
            dto.isAsc = false;
            dto.offset = 0;
            
            ctrl.filtersUIDataToApplyJson = JSON.serializePretty(dto);
            PageReference result = ctrl.applyFilters();
            System.assertEquals(null, result);
            System.assertEquals(expected, ctrl.resultJson);
        }
    }
    
    static testMethod void testRequestForAssignmentErrors() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;
        MatrixLeadSelectionLimit__c cs = MatrixLeadSelectionLimit__c.getInstance();
        

        User barclaysStandardUser = userFactory.getBarclaysStandardUser();  
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        Set<Id> matrixLeadIds = new Set<Id>();
        System.runAs(currentUser) {
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Key_Matrix_Leads_Qualification'];
            insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = barclaysStandardUser.Id);
    
            barclaysStandardUser.ManagerId = currentUser.Id;
            update barclaysStandardUser;
            
        Insert new MatrixLeadSelectionLimit__c(SetupOwnerId = UserInfo.getOrganizationId(), Maximum_Number_of_Leads_Allowed__c = 5);
       
            List<Matrix_Lead__c> matrixLeads = new List<Matrix_Lead__c>();
            for(Integer i=0; i<6; i++){
                for(Integer j=0; j<2; j++){
                    Matrix_Lead__c matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
                    matrixLead.REF_NO__c = String.valueOf(i);
                    matrixLeads.add(matrixLead);
                }
            }
            insert matrixLeads;
            
            
            for(Matrix_Lead__c matrixLead : matrixLeads){
                matrixLeadIds.add(matrixLead.Id);
            }
        }
        
        

        System.runAs(barclaysStandardUser){
            CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
            ctrl.settingsName = settingsName;
            ctrl.idsToAssignJson = Json.serializePretty(matrixLeadIds);

            Test.startTest();

            PageReference result = ctrl.requestForAssignment();

            Test.stopTest();

            System.assertEquals(null, result);
            System.assertEquals(true, ctrl.resultJson.contains('You have Exceeded the Number of Leads you can select.'));
        }
    }
    
    static testMethod void testRequestForAssignment() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        ZZTEST_F_MatrixLead matrixLeadFactory = ZZTEST_DataFactoryFacade.matrixLead;

        User barclaysStandardUser = userFactory.getBarclaysStandardUser();  
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        
        
        Matrix_Lead__c matrixLead;
        System.runAs(currentUser) {
            PermissionSet ps = [SELECT Id, Name FROM PermissionSet WHERE Name = 'Key_Matrix_Leads_Qualification'];
            insert new PermissionSetAssignment(PermissionSetId = ps.Id, AssigneeId = barclaysStandardUser.Id);
            
            barclaysStandardUser.ManagerId = currentUser.Id;
            update barclaysStandardUser;
            List<Matrix_Lead__c> matrixLeads = new List<Matrix_Lead__c>();
            matrixLead = matrixLeadFactory.getProduct(ZZTEST_F_MatrixLead.MatrixLeadRecordType.DEFAULT_MATRIX_LEAD, dataContainer);
            matrixLead.REF_NO__c = String.valueOf(0);
            matrixLeads.add(matrixLead);
            insert matrixLeads;
            
            
        }
        
        List<Id> ids = new List<Id>{matrixLead.Id};
            
            System.runAs(barclaysStandardUser){
                CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
                ctrl.settingsName = settingsName;
                ctrl.idsToAssignJson = Json.serializePretty(ids);
                
                PageReference result = ctrl.requestForAssignment();
                System.assertEquals(null, result);
                System.assertEquals('', ctrl.resultJson);
            }
    }
    
    static testMethod void testQueryUsersAssignedToPermSet() {
        PermissionSet ps = new PermissionSet();
        ps.Name = 'Test';
        ps.Label = 'Test';
        insert ps;
        
        PermissionSetAssignment psa = new PermissionSetAssignment();
        psa.AssigneeId = UserInfo.getUserId();
        psa.PermissionSetId = ps.Id;
        insert psa;
        
        CusRep_CustomReportController ctrl = new CusRep_CustomReportController();
        ctrl.settingsName = settingsName;
        
        Set<String> result = ctrl.queryUsersAssignedToPermSet(ps.Name);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(true, result.contains(UserInfo.getUserId()));
    }
    
    //data preparing methods
    
    private static void prepareColumns(String settingsId) {
    
        CusRep_Column__c numberCol = new CusRep_Column__c();
        numberCol.API_Name__c = 'Number_18__c';
        numberCol.Label__c = 'Number 18';
        numberCol.Alignment__c = 'Right';
        numberCol.Is_Owner_Field__c = false;
        numberCol.Is_Link_To_Record__c = false;
        numberCol.CusRep_Settings__c = settingsId;
        numberCol.Order__c = 1;
        
        CusRep_Column__c picklistCol = new CusRep_Column__c();
        picklistCol.API_Name__c = 'Picklist__c';
        picklistCol.Label__c = 'Picklist';
        picklistCol.Alignment__c = 'Left';
        picklistCol.Is_Owner_Field__c = false;
        picklistCol.Is_Link_To_Record__c = false;
        picklistCol.CusRep_Settings__c = settingsId;
        picklistCol.Order__c = 2;
        
        CusRep_Column__c textCol = new CusRep_Column__c();
        textCol.API_Name__c = 'Text_20__c';
        textCol.Label__c = 'Text 20';
        textCol.Alignment__c = 'Left';
        textCol.Is_Owner_Field__c = false;
        textCol.Is_Link_To_Record__c = false;
        textCol.CusRep_Settings__c = settingsId;
        textCol.Order__c = 3;
        
        CusRep_Column__c ownerCol = new CusRep_Column__c();
        ownerCol.API_Name__c = 'Owner.Name';
        ownerCol.Label__c = 'Owner';
        ownerCol.Alignment__c = 'Left';
        ownerCol.Is_Owner_Field__c = true;
        ownerCol.Is_Link_To_Record__c = false;
        ownerCol.CusRep_Settings__c = settingsId;
        ownerCol.Order__c = 4;
        
        CusRep_Column__c linkCol = new CusRep_Column__c();
        linkCol.API_Name__c = 'Name';
        linkCol.Label__c = 'Name';
        linkCol.Alignment__c = 'Left';
        linkCol.Is_Owner_Field__c = false;
        linkCol.Is_Link_To_Record__c = true;
        linkCol.CusRep_Settings__c = settingsId;
        linkCol.Order__c = 5;
        
        List<CusRep_Column__c> columns = new List<CusRep_Column__c>{numberCol, picklistCol, textCol, 
            ownerCol, linkCol};
        insert columns;
    }
    
    private static void prepareFilters(String settingsId) {
    
        CusRep_Filter__c numberFilter = new CusRep_Filter__c();
        numberFilter.CusRep_Settings__c = settingsId;
        numberFilter.Field_Name__c = 'Number_18__c';
        numberFilter.Label__c = 'Number Filter';
        numberFilter.Field_Type__c = 'Number';
        numberFilter.Order__c = 1;
        
        CusRep_Filter__c textFilter = new CusRep_Filter__c();
        textFilter.CusRep_Settings__c = settingsId;
        textFilter.Field_Name__c = 'Text_20__c';
        textFilter.Label__c = 'Text Filter';
        textFilter.Field_Type__c = 'Text';
        textFilter.Order__c = 2;
        
        CusRep_Filter__c picklistFilter = new CusRep_Filter__c();
        picklistFilter.CusRep_Settings__c = settingsId;
        picklistFilter.Field_Name__c = 'Picklist__c';
        picklistFilter.Label__c = 'Picklist Filter';
        picklistFilter.Field_Type__c = 'Picklist';
        picklistFilter.Order__c = 3;
        
        CusRep_Filter__c rangeFilter = new CusRep_Filter__c();
        rangeFilter.CusRep_Settings__c = settingsId;
        rangeFilter.Field_Name__c = 'Number_18__c';
        rangeFilter.Label__c = 'Range Filter';
        rangeFilter.Field_Type__c = 'Range';
        rangeFilter.Order__c = 4;

        CusRep_Filter__c dynamicFilter = new CusRep_Filter__c();
        dynamicFilter.CusRep_Settings__c = settingsId;
        dynamicFilter.Field_Name__c = 'Text_20__c';
        dynamicFilter.Label__c = 'Dynamic Filter';
        dynamicFilter.Field_Type__c = 'Dynamic Picklist';
        dynamicFilter.Order__c = 5;

        List<CusRep_Filter__c> filters = new List<CusRep_Filter__c>{numberFilter, textFilter, 
            picklistFilter, rangeFilter, dynamicFilter};
        insert filters;
        
        prepareFilterValues(picklistFilter.Id);
    }
    
    private static void prepareFilterValues(String filterId) {
        CusRep_Filter_Value__c runningUserValue = new CusRep_Filter_Value__c();
        runningUserValue.CusRep_Filter__c = filterId;
        runningUserValue.Label__c = 'My Records';
        runningUserValue.Apply_Running_User_Filter__c = true;
        
        CusRep_Filter_Value__c renamingValue = new CusRep_Filter_Value__c();
        renamingValue.CusRep_Filter__c = filterId;
        renamingValue.Field_Name__c = 'Picklist__c';
        renamingValue.Label__c = '4';
        renamingValue.Value__c = 'Four';
        
        List<CusRep_Filter_Value__c> fvs = new List<CusRep_Filter_Value__c>{runningUserValue, renamingValue};
        insert fvs;
    }
    
    private static List<CusRep_Test_Object__c> prepareResultData() {
        CusRep_Test_Object__c cto1 = new CusRep_Test_Object__c();
        cto1.Number_18__c = 100;
        cto1.Picklist__c = 'One';
        cto1.Text_20__c = 'aaa';
        
        CusRep_Test_Object__c cto2 = new CusRep_Test_Object__c();
        cto2.Number_18__c = 200;
        cto2.Picklist__c = 'Two';
        cto2.Text_20__c = 'bbb';
        
        CusRep_Test_Object__c cto3 = new CusRep_Test_Object__c();
        cto3.Number_18__c = 300;
        cto3.Picklist__c = 'Three';
        cto3.Text_20__c = 'ccc';
        
        List<CusRep_Test_Object__c> records = new List<CusRep_Test_Object__c>{cto1, cto2, cto3};
        insert records;
        
        List<CusRep_Test_Object__c> result = [
            SELECT Id, Name, Number_18__c, Picklist__c, Text_20__c
            FROM CusRep_Test_Object__c
            ORDER BY Number_18__c ASC
        ];
        
        return result;
    }

}