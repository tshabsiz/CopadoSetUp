/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for PipelineReport class
*                 Tests executed:
*                 1 - testPrepareOptyCountWithNoOpportunity()
*                   Tests totals counting when there is no opportunity
*                 2 - testPrepareOptyCount()
*                   Tests totals counting
*                 3 - testMoveLast()
*                   Tests moving to the last page with pagination
*                 4 - testMoveFirst()
*                   Tests moving to the first page with pagination
*                 5 - testMovePrevious()
*                   Tests moving to previous page with pagination
*                 6 - testMoveNext()
*                   Tests moving to next page with pagination
*                 7 - testPrepareQueryWithCloseDateString()
*                   Tests query preparation with close date filter
*                 8 - testPrepareQueryWithAccountSegmentOption()
*                   Tests query preparation with account segment filter
*                 9 - testPrepareQueryWithAccountClientRegionOption()
*                   Tests query preparation with client region filter
*                 10 - testPrepareQueryWithOptyStageOption()
*                   Tests query preparation with opportunity stage filter
*                 11 - testPrepareQueryWithOppOwnerId()
*                   Tests query preparation with opportunity owner filter
*                 12 - testPrepareQueryWithBankerId()
*                   Tests query preparation with banker filter
*                 13 - testPrepareQueryWithUserTeamOption()
*                   Tests query preparation with user's team filter
*                 14 - testPrepareQueryWithProduct()
*                   Tests query preparation with product filter
*                 15 - testPrepareQueryWithBothProducts()
*                   Tests query preparation with 2 levels of product filter
*                 16 - testPrepareQueryWith3Products()
*                   Tests query preparation with 3 levels of product filter
*                 17 - testPrepareQueryWithBuyingGroupId()
*                   Tests query preparation with buying group filter
*                 18 - testPrepareQueryWithNoParameter()
*                   Tests query preparation with no filter
*                 19 - testPrepareQueryWithSorting()
*                   Tests query preparation with sorting
*                 20 - testConstructor()
*                   Tests constructor logic
*                 21 - testGetData()
*                   Tests method preparing data for front end
*                 22 - testShowExcelPage()
*                   Tests method showing excel page
*                 23 - testGetExcelData()
*                   Tests preparation of excel data
*                 24 - testPrepareBuyingGroupsJsonNoTypeSelected()
*                   Tests method preparing json of buying groups when no type is selected
*                 25 - testPrepareBuyingGroupsJson()
*                   Tests method preparing json of buying groups
*                 26 - testGetProductsLevel1()
*                   Tests method for obtaining products level 1
*                 27 - testGetProductsLevel2()
*                   Tests method for obtaining products level 2
*                 28 - testGetProductsLevel3()
*                   Tests method for obtaining products level 3
*                 29 - testGetOpportunityStageValues()
*                   Tests method preparing opportunity stage values
*                 30 - testGetAccountClientRegionValues()
*                   Tests method preparing client region values
*                 31 - testGetAccountSegmentValues()
*                   Tests method preparing segment values
*                 32 - testPrepareCoverageTeamJson()
*                   Tests method preparing json with coverage team data
*                 33 - testPrepareBankersJson()
*                   Tests method preparing json with bankers data
*                 34 - testPrepareCurrencyIsoCode()
*                   Tests preparation of currency iso code
*                 35 - testPrepareDateFromString()
*                   Tests method parsing date from string
*                 36 - testAddAnd()
*                   Tests method adding 'AND' to query
*                 37 - testGetSubqueryByProductLevel3()
*                   Tests preparation of subquery for product level 3
*                 38 - testGetSubqueryByProductLevel2()
*                   Tests preparation of subquery for product level 2
*                 39 - testGetSubqueryByProductLevel1()
*                   Tests preparation of subquery for product level 1
*                 40 - testGetSubqueryByCoverageTeam()
*                   Tests preparation of subquery for coverage team
*                 41 - testPrepareQueryWithAccountClientCountryOption()
*                   Tests query preparation with client country filter
*                 42 - testGetAccountClientCountryValues()
*                   Tests method preparing client country values
*                 43 - testGetOrgTypes()
*                   Tests preparation of select options for Relationship Type filter
*                 44 - testGetPipelineValues()
*                   Tests preparation of select options for Pipeline Segmentation filter
*                 45 - testGetOpportunityStageValuesByPipeline()
*                   Tests preparation of select options for Stage filter for selected Pipeline Segmentation
*                 46 - testPrepareQueryWithPipelineOption()
*                   Tests query preparation for Pipeline Segmentation
*                 47 - testgetteamRoleValues()
                    Tests method preparing team role values
*                 48 - testPrepareQueryWithRoleOption()
                    Tests query preparation with role filter
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 24.11.2015    Caro Reinecke   Replaced Buying Group with Relationship Group
* 3.12.2015     Marek Cech      testPrepareOptyCount changed according to calculation in OpportunityLineItem trigger
* 07-Dec-2015   Mohsin Wadee    testPrepareOptyCount method calls 
*                               ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem.
* 10-Dec-2015   Mohsin Wadee US-0775 Replace method call ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem
*       with ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem
* 13.01.2016   Caro Reinecke    Added test methods 38 & 39 for Country Filter 
* 24.02.2016   Marta Malinowska Added test methods 40-43 for Relationship Type and Pipeline Segmentation filters
* 08.07.2016   Mohsin Wadee     Demarked testPrepareOptyCount() as test method.
* 18.09.2016   Dino Scarcella   Added test methods 44 & 45 for Opportunity Team Member Role Filter
* 22.05.2017   Mabhedle Tonga   Added test methods for Opportunity Country,User teams, and Opportunity Team member Name
* 31.05.2017   Mabhedle Tonga   Added additional filter on report.(TB Region,Sub Stage,Product Partner Approval,Product Partner)
* 20.11.2017   Dino Scarcella   Added additional product level 3 filter
*---------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_PipelineReportController {

    private static final String QUERY_SPLIT = 'FROM Opportunity';

    //private exception class for testing json validity
    private class ZZTEST_PipelineReportControllerException extends Exception {
    }
    
    public static testMethod void testPrepareOptyCountWithNoOpportunity() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(
            ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        Test.startTest();
        
        ctrl.prepareOptyCount();
        
        Test.stopTest();
        
        System.assertEquals(0, ctrl.facilitySize);
        System.assertEquals(0, ctrl.incomeThisYear);
        System.assertEquals(0 , ctrl.annualisedIncome);
        System.assertEquals(0, ctrl.weightedIncomeThisYear);
        System.assertEquals(0, ctrl.weightedAnnualisedIncome);
    }
    
    public static void testPrepareOptyCount() {
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunityLineItem opportunityLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        
        Opportunity opty1 = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        opty1.Probability = 10;
        opty1.StageName = 'Opportunity Identified';
        opty1.CloseDate = Date.newInstance(Date.today().year(), 6, 4);
        opty1.Accountable_Banker__c = userFactory.getBarclaysStandardUser().Id;
        opty1.Private_Side__c = false;
        opty1.The_accountable_banker_has_been_cleared__c = true;
        
        Opportunity opty2 = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        opty2.Probability = 20;
        opty2.StageName = 'Client Engaged';
        opty2.CloseDate = Date.newInstance(Date.today().year(), 6, 4);
        opty2.Accountable_Banker__c = userFactory.getBarclaysStandardUser().Id;
        opty2.Private_Side__c = false;
        opty2.The_accountable_banker_has_been_cleared__c = true;
        
        List<Opportunity> optys = new List<Opportunity>{opty1, opty2};
        insert optys;
        
        OpportunityLineItem oli1 = opportunityLineItemFactory.getProduct(
            ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
        oli1.Recurring_Fees__c = 100;
        oli1.Balance__c = 500000;
        oli1.Margin__c = 2;
        oli1.Estimated_Utilisation__c = 5;
        oli1.OpportunityId = opty1.Id;
        
        OpportunityLineItem oli2 = opportunityLineItemFactory.getProduct(
            ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
        oli2.Recurring_Fees__c = 200;
        oli2.Balance__c = 700000;
        oli2.Margin__c = 3;
        oli2.Estimated_Utilisation__c = 7;
        oli2.OpportunityId = opty2.Id;
        
        List<OpportunityLineItem> olis = new List<OpportunityLineItem>{oli1, oli2};
        insert olis;
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        Test.startTest();
        
        ctrl.prepareOptyCount();
        
        Test.stopTest();
        
        Decimal expectedFacilitySize = 
            oli1.Balance__c.round(System.RoundingMode.HALF_UP) + 
            oli2.Balance__c.round(System.RoundingMode.HALF_UP);
        System.assertEquals(expectedFacilitySize, ctrl.facilitySize.round(System.RoundingMode.HALF_UP));
        
        System.assertEquals(2934.00, ctrl.incomeThisYear);
        System.assertEquals(5570.00, ctrl.annualisedIncome);
        System.assertEquals(498.00, ctrl.weightedIncomeThisYear);
        System.assertEquals(944.00, ctrl.weightedAnnualisedIncome);
    }
    
    public static testMethod void testMoveLast() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //another full page available test
        ctrl.optyCount = PipelineReportController.QUERY_LIMIT + 5;
        PageReference result = ctrl.moveLast();
        System.assertEquals(null, result);
        System.assertEquals(5, ctrl.queryOffset);
        
        //not enought record for another full page test
        ctrl.optyCount = PipelineReportController.QUERY_LIMIT - 1;
        result = ctrl.moveLast();
        System.assertEquals(null, result);
        System.assertEquals(0, ctrl.queryOffset);
    }
    
    public static testMethod void testMoveFirst() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.queryOffset = 15;
        PageReference result = ctrl.moveFirst();
        System.assertEquals(null, result);
        System.assertEquals(0, ctrl.queryOffset);
    }
    
    public static testMethod void testMovePrevious() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //move available test
        ctrl.queryOffset =  PipelineReportController.QUERY_LIMIT + 5;
        
        Test.startTest();
        PageReference result = ctrl.movePrevious();
        
        System.assertEquals(null, result);
        System.assertEquals(5, ctrl.queryOffset);
        
        //move NOT available test
        ctrl.queryOffset =  PipelineReportController.QUERY_LIMIT - 1;
        result = ctrl.movePrevious();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(0, ctrl.queryOffset);
    }
    
    public static testMethod void testMoveNext() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //move available test
        ctrl.optyCount = 100;
        ctrl.queryOffset = 15;
        
        Test.startTest();
        PageReference result = ctrl.moveNext();
        System.assertEquals(null, result);
        
        Integer expectedOffset = 15 + PipelineReportController.QUERY_LIMIT;
        System.assertEquals(expectedOffset, ctrl.queryOffset);
        
        //move NOT available test
        ctrl.optyCount = 16;
        ctrl.queryOffset = 15;
        
        result = ctrl.moveNext();
        Test.stopTest();
        System.assertEquals(null, result);
        
        System.assertEquals(15, ctrl.queryOffset);
    }
    
    public static testMethod void testPrepareQueryWithCloseDateString() { 
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.closeDateString = '2015-06';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('CloseDate <= :endDate'));
        
        Date expectedStart = Date.newInstance(2015, 6, 1);
        Date expectedEnd = Date.newInstance(2015, 6, 30);
        
        System.assertEquals(expectedStart, ctrl.startDate);
        System.assertEquals(expectedEnd, ctrl.endDate);
    }
    
    public static testMethod void testPrepareQueryWithAccountSegmentOption() { 
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.accountSegmentOptionsJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('Account.Segment__c = \'something\''));
    }
    
    public static testMethod void testPrepareQueryWithAccountClientRegionOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.accountClientRegionOptionsJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('Account.Client_Region__c = \'something\''));
    }
    
    public static testMethod void testPrepareQueryWithAccountClientCountryOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.accountClientCountryOptionsJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('Account.Client_Country__c = \'something\''));
    }
    
    public static testMethod void testPrepareQueryWithOptyStageOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.optyStageOptionsJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('StageName = \'something\''));
    }
    
    public static testMethod void testPrepareQueryWithOppOwnerId() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.oppOwnerIdsJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('OwnerId = \'something\''));
    }
    
    public static testMethod void testPrepareQueryWithBankerId() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.bankerIdsJson = '["something1", "something2"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        
        System.debug(split[1]);
        String expected = '( Account.OwnerId = \'something1\' OR Account.OwnerId = \'something2\')';
        System.assertEquals(true, split[1].contains(expected));
    }
    
    public static testMethod void testPrepareQueryWithUserTeamOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.userTeamOptionsJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('AccountId IN :accounts'));
    }
    
    public static testMethod void testPrepareQueryWithProduct() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.productLevel1OptionsJson = '["product1"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains(
            '(SELECT OpportunityId From OpportunityLineItem WHERE Product2Id = \'product1\')'));
    }
    
    public static testMethod void testPrepareQueryWithBothProducts() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.productLevel1OptionsJson = '["product1"]';
        ctrl.productLevel2OptionsJson = '["product2"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains(
            '(SELECT OpportunityId From OpportunityLineItem WHERE Product_Level_2__c = \'product2\')'));
    }
    
    public static testMethod void testPrepareQueryWith3Products() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.productLevel1OptionsJson = '["product1"]';
        ctrl.productLevel2OptionsJson = '["product2"]';
        ctrl.productLevel3OptionsJson = '["product3"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains(
            '(SELECT OpportunityId From OpportunityLineItem WHERE Product_Level_3__c = \'product3\')'));
    }
    
    public static testMethod void testPrepareQueryWithBuyingGroupId() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, 
            dataContainer);

        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.orgTypeJson = '["' + PipelineReportController.TYPE_EXISTING + '"]';
        ctrl.orgIdJson = '["' + acc1.Id + '"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('Account.Id = \'' + acc1.Id + '\''));
    }
    
    public static testMethod void testPrepareQueryWithRoleOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.teamRoleOptionsJson = '["something1", "something2"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('TeamMemberRole IN (\'something1\',\'something2\')'));
    }
    
    public static testMethod void testPrepareQueryWithNoParameter() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('LIMIT'));
    }
    
    public static testMethod void testPrepareQueryWithSorting() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.sortColumn = 'column1';
        ctrl.sortOrder = 'ASC';
        
        Test.startTest();
        String result = ctrl.prepareQuery(false, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('ORDER BY column1 ASC NULLS LAST'));
    }
    
    public static testMethod void testConstructor() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        System.assertNotEquals(null, ctrl.bankersJson);
        System.assertNotEquals(null, ctrl.coverageTeamJson);
        System.assertNotEquals(null, ctrl.currencyIsoCode);
        System.assertEquals(false, ctrl.keepOffset);
        System.assertEquals(0, ctrl.queryOffset);
    }
    
    public static testMethod void testGetData() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        
        
        User user1 = [Select id from User where ID=:UserInfo.getUserId()];
        
        
        Opportunity opty;
        System.runAs(user1)
        {
            opty = opportunityFactory.getInsertedProduct(
            ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
        
        }
        
        SYstem.debug(opty);
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        Test.startTest();
        PageReference pr = ctrl.prepareData();
        List<Opportunity> result = ctrl.optys;
        Test.stopTest();
        
        System.assertEquals(null, pr);
        
       
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(opty.Id, result[0].Id);
    }
    
    public static testMethod void testShowExcelPage() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        Test.startTest();
        PageReference result = ctrl.showExcelPage();
        Test.stopTest();
        
        System.assertEquals(false, result.getRedirect());
        System.assertEquals('/apex/pipelinereportexcel', result.getUrl());
    }
    
    public static testMethod void testGetExcelData() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        
        User user1 = [Select id from User where ID=:UserInfo.getUserId()];
        
        Opportunity opty;
        System.runAs(user1)
        {
            opty = opportunityFactory.getInsertedProduct(
            ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
        }
       
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        Test.startTest();
        List<Opportunity> result = ctrl.getExcelData();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(opty.Id, result[0].Id);
    }
    
    public static testMethod void testPrepareBuyingGroupsJsonNoTypeSelected() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, 
            dataContainer);
            
        Account acc2 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, 
            dataContainer);
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        Test.startTest();
        String result = ctrl.getBuyingGroupJson();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals('[]', result);
    }
    
    public static testMethod void testPrepareBuyingGroupsJson() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        
        Account acc1;
        Account acc2;
        Opportunity opty1;
        
        User user1 = [SELECT ID FROM User WHERE id = :UserInfo.getUserId()];
        System.runAs(user1)
        {
            //unwanted account
            acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, 
                                                     dataContainer);
            
            //expected account
            acc2 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, 
                                                     dataContainer);
            
            opty1 = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
                                                  dataContainer);
            opty1.AccountId = acc2.Id;
            insert opty1;
        }
        
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        ctrl.orgTypeJson = '["' + PipelineReportController.TYPE_EXISTING + '"]';
        
        Test.startTest();
        String result = ctrl.getBuyingGroupJson();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(true, result.contains(acc2.Id));
        System.assertEquals(false, result.contains(acc1.Id));
    }
    
    public static testMethod void testGetProductsLevel1() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        
        Product2 product1 = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, 
            dataContainer);
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        Test.startTest();
        List<SelectOption> result = ctrl.getProductsLevel1();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(product1.Name, result[0].getLabel());
        System.assertEquals(product1.Id, result[0].getValue());
    }
    
    public static testMethod void testGetProductsLevel2() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        
        //selected product
        Product2 product1 = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, 
            dataContainer);
        
        //unselected product
        Product2 product2 = new Product2();
        product2.Name = 'Tomas Kakadu';
        insert product2;
    
        //expected result
        Product_Level_2__c prodLvl21 = new Product_Level_2__c();
        prodLvl21.Name = 'product1';
        prodLvl21.Product__c = product1.Id;
        prodLvl21.Active__c = true;
        
        //product (level 2) with unselected product
        Product_Level_2__c prodLvl22 = new Product_Level_2__c();
        prodLvl22.Name = 'product2';
        prodLvl22.Product__c = product2.Id;
        prodLvl22.Active__c = true;
        
        //product (level 2) of selected product, but not active
        Product_Level_2__c prodLvl23 = new Product_Level_2__c();
        prodLvl23.Name = 'product3';
        prodLvl23.Product__c = product1.Id;
        prodLvl23.Active__c = false;
        
        List<Product_Level_2__c> productsLvl2 = new List<Product_Level_2__c>{prodLvl21, prodLvl22, prodLvl23};
        insert productsLvl2;
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.productLevel1OptionsJson = '["' + product1.Id + '"]';
        
        Test.startTest();
        List<SelectOption> result = ctrl.getProductsLevel2();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(prodLvl21.Name, result[0].getLabel());
        System.assertEquals(prodLvl21.Id, result[0].getValue());
    }

    public static testMethod void testGetProductsLevel3() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        
        Product2 product1 = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, 
            dataContainer);
    
        Product_Level_2__c prodLvl2 = new Product_Level_2__c();
        prodLvl2.Name = 'product1';
        prodLvl2.Product__c = product1.Id;
        prodLvl2.Active__c = true;

        insert prodLvl2;
        
        Product_Level_3__c prodLvl3 = new Product_Level_3__c();
        prodLvl3.Name = 'product1';
        prodLvl3.Product_Level_2__c = prodLvl2.Id;
        prodLvl3.Active__c = true;
        
        insert prodLvl3;
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.productLevel1OptionsJson = '["' + product1.Id + '"]';
        ctrl.productLevel2OptionsJson = '["' + prodLvl2.Id + '"]';
        
        Test.startTest();
        List<SelectOption> result = ctrl.getProductsLevel3();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(prodLvl3.Name, result[0].getLabel());
        System.assertEquals(prodLvl3.Id, result[0].getValue());
    }
    
    public static testMethod void testGetOpportunityStageValues() {
        Schema.DescribeFieldResult f = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //testing values
        List<SelectOption> result = ctrl.getOpportunityStageValues();
        for (SelectOption so: result) {
            System.assertEquals(true, expected.contains(so.getLabel() + so.getValue()));
        }
    }
    
    public static testMethod void testGetAccountClientRegionValues() {
        Schema.DescribeFieldResult f = Account.Client_Region__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //testing values
        List<SelectOption> result = ctrl.getAccountClientRegionValues();
        for (SelectOption so: result) {
            System.assertEquals(true, expected.contains(so.getLabel() + so.getValue()));
        }
    }
    
     public static testMethod void testGetAccountClientCountryValues() {
        Schema.DescribeFieldResult f = Account.Client_Country__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //testing values
        List<SelectOption> result = ctrl.getAccountClientCountryValues();
        for (SelectOption so: result) {
            System.assertEquals(true, expected.contains(so.getValue() + so.getLabel()));
        }
    }
    
    public static testMethod void testgetteamRoleValues() {
        Schema.DescribeFieldResult f = OpportunityTeamMember.TeamMemberRole.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //testing values
        List<SelectOption> result = ctrl.getteamRoleValues();
        for (SelectOption so: result) {
            System.assertEquals(true, expected.contains(so.getLabel() + so.getValue()));
        }
    }
    
    public static testMethod void testGetAccountSegmentValues() {
        //expected result preparation
        Schema.DescribeFieldResult f = Account.Segment__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //testing values
        List<SelectOption> result = ctrl.getAccountSegmentValues();
        for (SelectOption so: result) {
            System.assertEquals(true, expected.contains(so.getLabel() + so.getValue()));
        }
    }
    
    public static testMethod void testPrepareCoverageTeamJson() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //null check
        ctrl.prepareCoverageTeamJson();
        System.assertNotEquals(null, ctrl.coverageTeamJson);
        
        //JSON validity check
        List<String> result;
        try {
            result = (List<String>) JSON.deserializeStrict(ctrl.coverageTeamJson, List<String>.class);
            throw new ZZTEST_PipelineReportControllerException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_PipelineReportControllerException);
        }
    
        //values test
        Schema.DescribeFieldResult f = User.Team__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        for (Schema.PicklistEntry e: p) {
            System.assertEquals(true, ctrl.coverageTeamJson.contains(e.getLabel()));
        }
    }
    
    public static testMethod void testPrepareBankersJson() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //null check
        ctrl.prepareBankersJson();
        System.assertNotEquals(null, ctrl.bankersJson);
        
        //JSON validity check
        List<User> result;
        try {
            result = (List<User>) JSON.deserializeStrict(ctrl.bankersJson, List<User>.class);
            throw new ZZTEST_PipelineReportControllerException();
        } catch (Exception e) {
            System.assertEquals(true, e instanceof ZZTEST_PipelineReportControllerException);
        }
    }
    
    public static testMethod void testPrepareCurrencyIsoCode() {
        List<User> users = [SELECT Id, DefaultCurrencyIsoCode FROM User WHERE Id = :UserInfo.getUserId()];
        
        String expected = 'ZAR';
        users[0].DefaultCurrencyIsoCode = expected;
        update users;
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.prepareCurrencyIsoCode();
        System.assertEquals(expected, ctrl.currencyIsoCode);
    }

    public static testMethod void testPrepareDateFromString() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        Date expected = Date.newInstance(2015, 6, 1);
        String closeDateString = '2015-06';
        Date result = ctrl.prepareDateFromString(closeDateString);
        System.assertEquals(true, result.isSameDay(expected));
    }

    public static testMethod void testAddAnd() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //AND added test
        String query = 'SOMETHING...WHERE';
        String result = ctrl.addAnd(query);
        System.assertEquals(false, result.endsWith(' AND'));
        
        //AND not added test
        query = 'SOMETHING...';
        result = ctrl.addAnd(query);
        System.assertEquals(true, result.endsWith(' AND'));
    }
    
    public static testMethod void testGetSubqueryByProductLevel3() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        List<String> productsLvl3 = new List<String>{'something1', 'something2'};
        
        Test.startTest();
        String result = ctrl.getSubqueryByProductLevel3(productsLvl3);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        
        String expected = '(SELECT OpportunityId From OpportunityLineItem WHERE Product_Level_3__c = \'something1\'' +
        ' OR Product_Level_3__c = \'something2\')';
        System.assertEquals(expected, result);
    }
    
    public static testMethod void testGetSubqueryByProductLevel2() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        List<String> productsLvl2 = new List<String>{'something1', 'something2'};
        
        Test.startTest();
        String result = ctrl.getSubqueryByProductLevel2(productsLvl2);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        
        String expected = '(SELECT OpportunityId From OpportunityLineItem WHERE Product_Level_2__c = ' +
            '\'something1\' OR Product_Level_2__c = \'something2\')';
        System.assertEquals(expected, result);
    }
    
    public static testMethod void testGetSubqueryByProductLevel1() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        List<String> productsLvl1 = new List<String>{'something1', 'something2'};
        
        Test.startTest();
        String result = ctrl.getSubqueryByProductLevel1(productsLvl1);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        
        String expected = '(SELECT OpportunityId From OpportunityLineItem WHERE Product2Id = \'something1\'' +
        ' OR Product2Id = \'something2\')';
        System.assertEquals(expected, result);
    }
    
    public static testMethod void testGetSubqueryByCoverageTeam() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        
        //user with no account in his team
        User u1 = userFactory.getBarclaysStandardUser();
        u1.Team__c = 'Eastern Cape';
        update u1;
        
        //user with 1 account in his team
        List<User> users = [SELECT Id, Team__c FROM User WHERE Id = :UserInfo.getUserId()];
        System.assertEquals(1, users.size());
        users[0].Team__c = 'fake team';
        update users;
        
        Account acc1;
        System.runAs(users[0])
        {
            acc1 = accountFactory.getInsertedProduct(
                ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        }
        
        
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        List<String> userTeamOptions = new List<String>{'fake team'};
        
        Test.startTest();
        
        //1 account match test
        ctrl.getSubqueryByCoverageTeam(userTeamOptions);
        System.assertEquals(1, ctrl.accounts.size());
        System.assertEquals(acc1.Id, ctrl.accounts[0].Id);
        
        userTeamOptions = new List<String>{'Eastern Cape', 'Western Cape'};
        //0 account match test
        ctrl.getSubqueryByCoverageTeam(userTeamOptions);
        System.assertEquals(0, ctrl.accounts.size());
        
        Test.stopTest();
    }

    public static testMethod void testGetOrgTypes() {   
        Set<String> expected = new Set<String>();
        expected.add(PipelineReportController.TYPE_PROSPECT);
        expected.add(PipelineReportController.TYPE_EXISTING);

        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //testing values
        List<SelectOption> result = ctrl.getOrgTypes();
        for(SelectOption so : result) {
            System.assertEquals(true, expected.contains(so.getValue()));
        }
    }

    public static testMethod void testGetPipelineValues() {   
        Set<String> expected = new Set<String>();
        expected.add(PipelineReportController.ALL_OPEN_OPPS);
        expected.add(PipelineReportController.ALL_OPPS_MORE_THAN_50);
        expected.add(PipelineReportController.ALL_CLOSED_OPPS);

        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        //testing values
        List<SelectOption> result = ctrl.getPipelineValues();
        for(SelectOption so : result) {
            System.assertEquals(true, expected.contains(so.getValue()));
        }
    }

    public static testMethod void testGetOpportunityStageValuesByPipeline() {
        Set<String> expected = new Set<String>();
        for(OpportunityStage stage : [SELECT Id, MasterLabel, IsClosed, DefaultProbability
                                        FROM OpportunityStage WHERE IsActive = true AND IsClosed = false]){
            expected.add(stage.MasterLabel);
        }
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();

        ctrl.pipelineOptionsJson = '["' + PipelineReportController.ALL_OPEN_OPPS + '"]';
        
        //testing values
        List<SelectOption> result = ctrl.getOpportunityStageValues();
        for (SelectOption so: result) {
            System.assertEquals(true, expected.contains(so.getValue()));
        }
    }

    public static testMethod void testPrepareQueryWithPipelineOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.pipelineOptionsJson = '["' + PipelineReportController.ALL_OPEN_OPPS + '"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains(
            'IsClosed = false'));
    }
    
    public static Set<String> prepareExpectedFromPicklistEntries(List<Schema.PicklistEntry> p) {
        Set<String> expected = new Set<String>();
        expected.add(Label.lbl_Select);
        
        for (Schema.PicklistEntry e:p) {
            expected.add(e.getLabel() + e.getValue());
        }
        return expected;
    }
    
    public static testMethod void testGetOpportunityCountryValues() {   
        //expected result preparation
        Schema.DescribeFieldResult f = Opportunity.Opportunity_Country__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        ///testing values
        List<SelectOption> result = ctrl.getOpportunityCountryValues();
        integer index=0;
        
			for(SelectOption so : result)
            {
                System.assertEquals(true, expected.contains(so.getValue()+so.getLabel()));
           }
 
    }
    public static testMethod void testGgetUserTeamNameValues() {   
        //expected result preparation
        Schema.DescribeFieldResult f = User.Team__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        System.debug('expected '+expected);
        ///testing values
        List<SelectOption> result = ctrl.getUserTeamNameValues();
        integer index=0;
        
			for(SelectOption so : result)
            {
                System.assertEquals(true, expected.contains(so.getValue()+so.getLabel()));
           }
 
    }
    public static testMethod void testPrepareQueryWithTeamNameOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.teamNameOptionsJson = '["something1", "something2"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
    }
    
    public static testMethod void testGetOpportunitySubStageValues() {   
        //expected result preparation
        Schema.DescribeFieldResult f = Opportunity.SubStage__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        ///testing values
        List<SelectOption> result = ctrl.getOpportunitySubStageValues();
        
        for(SelectOption so : result)
        {
            System.assertEquals(true, expected.contains(so.getValue()+so.getLabel()));
        }
        
    }
    public static testMethod void testGetOpportunityApprovalStatusValues() {   
        //expected result preparation
        Schema.DescribeFieldResult f = Opportunity.ProductPartnerApprovalStatus__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        ///testing values
        List<SelectOption> result = ctrl.getOpportunityApprovalStatusValues();
                
        for(SelectOption so : result)
        {
            System.assertEquals(true, expected.contains(so.getValue()+so.getLabel()));
        } 
    }
    
     public static testMethod void testGetAccountTBRegionValues() {   
        //expected result preparation
        Schema.DescribeFieldResult f = Account.Transactional_Banking_Region__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        Set<String> expected = prepareExpectedFromPicklistEntries(p);
        
        //controller initialization
         PageReference page1 = Page.PipelineReport;
         Test.setCurrentPage(page1);
         PipelineReportController ctrl = new PipelineReportController();
         ///testing values
         List<SelectOption> result = ctrl.getTBRegionValues();
         
         for(SelectOption so : result)
         {
             System.assertEquals(true, expected.contains(so.getValue()+so.getLabel()));
         } 
     }
    
    public static testMethod void testPrepareQueryWithOpportunityCountryOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.opportunityCountryJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
    }   
        public static testMethod void testPrepareQueryWithSubStageOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.optySubStageOptionsJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
    }
    public static testMethod void testPrepareQueryWithApprovalStatusOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.optyApprovalStatusOptionJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);       
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
    }
    
        public static testMethod void testPrepareQueryWithTBRegionOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.TBRegionOptionJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
    }
    public static testMethod void testPrepareQueryWithProductPartnerOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.productPartnerIdsJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
        System.assertEquals(true, split[1].contains('ProductPartner__c = \'something\''));
    }
    public static testMethod void testPrepareQueryWithTeamMemberIDOption() {
        PageReference page1 = Page.PipelineReport;
        Test.setCurrentPage(page1);
        PipelineReportController ctrl = new PipelineReportController();
        
        ctrl.teamMemberIdsJson = '["something"]';
        
        Test.startTest();
        String result = ctrl.prepareQuery(true, true, false);
        Test.stopTest();
        
        String[] split = result.split(QUERY_SPLIT, 2);
        
        System.assertEquals(2, split.size());
        System.assertEquals(true, split[0].contains('SELECT'));
    }
}