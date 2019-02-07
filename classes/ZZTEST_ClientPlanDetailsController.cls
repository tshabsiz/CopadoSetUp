/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanDetailsController
*                 Tests executed:
*                 1 - testQueryPlan()
*                   Tests querying of client plan
*                 2 - testQueryPlanWithWrongId()
*                   Tests errors handling during querying of client plan
*                 3 - testSaveErrors()
*                   Tests errors handling during saving
*                 4 - testSave()
*                   Tests save method
*                 5 - testAddMemberErrors()
*                   Tests error handling during adding a team member
*                 6 - testAddMember()
*                   Tests adding a team member
*                 7 - testRemoveMember()
*                   Tests removing a team member
*                 8 - testGetRoleOptions()
*                   Tests preparation of role select options
*                 9 - testGetStageOptions()
*                   Tests preparation of stage select options
*                 10 - testGetExpansionPolicyOptions()
*                   Tests preparation of expansion policy select options
*                 11 - testGetDGOptions()
*                   Tests preparation of DG select options
*                 12 - testCountProgressFromEmptyPlanObject()
*                   Tests progress counting when plan fields are null
*                 13 - testCountProgressFromFilledPlanObject()
*                   Tests progress counting when plan fields are filled
*                 14 - testCountPlanProgress()
*                   Tests progress counting
*                 15 - testQueryTeamMembers()
*                   Tests querying of team members
*                 15 - testErrorMessages()
*                   Tests of methods handling error messaged
* History
* 07/03/2018 - Tracy de Bruin  - Add Custom Setting test data (ConditionSchedulingSettings__c) in
									testCountProgressFromFilledPlanObject()
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanDetailsController {
    
    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        
        insert ap;
    }

    static testMethod void testQueryPlan() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        Test.startTest();
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        Test.stopTest();
        
        System.assertEquals(plan.Id, ctrl.planId);
        System.assertNotEquals(null, ctrl.plan);
        System.assertEquals(plan.Id, ctrl.plan.Id);
        System.assertEquals(true, ctrl.planLoaded);
    }
    
    static testMethod void testQueryPlanWithWrongId() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', 'asdfasdf');
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        Test.startTest();
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        Test.stopTest();
        
        System.assertEquals(null, ctrl.plan);
        System.assertEquals(false, ctrl.planLoaded);
    }
    
    static testMethod void testSaveErrors() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        
        ctrl.plan.Id = null;
        
        Test.startTest();
        PageReference result = ctrl.save();
        Test.stopTest();
        
        System.assertEquals(null, result);
        
        List<Client_Plan__c> resultPlans = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        System.assertEquals(1, resultPlans.size());
        System.assertEquals(plan.Relationship__c, resultPlans[0].Relationship__c);
        System.assertEquals(Label.errMsg_ErrorDuringSaving, ctrl.errorMessage);
    }
    
    static testMethod void testSave() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        
        String co = 'some strategy';
        ctrl.plan.Client_Overview__c = co;
        
        Test.startTest();
        PageReference result = ctrl.save();
        Test.stopTest();
        
        System.assertEquals(null, result);
        
        Client_Plan__c resultPlan = [SELECT Id, Client_Overview__c FROM Client_Plan__c LIMIT 1];
        System.assertEquals(plan.Id, resultPlan.Id);
        System.assertEquals(co, resultPlan.Client_Overview__c);
    }
    
    static testMethod void testAddMemberErrors() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        
        //no member to add set
        PageReference result = ctrl.addMember();
        
        System.assertEquals(null, result);
        System.assertEquals(Label.errMsg_ErrorAddingTeamMember, ctrl.errorMessage);
        
        List<Account_Team_Member__c> queryResult = [SELECT Team_Role__c, Team_Member__c, Organisation__c 
            FROM Account_Team_Member__c];
        System.assertEquals(0, queryResult.size());
        
        //dml exception - account not set
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getBarclaysStandardUser();
        
        Account_Team_Member__c tm1 = new Account_Team_Member__c();
        tm1.Team_Member__c = u1.Id;
        ctrl.memberToAdd = tm1;
        
        result = ctrl.addMember();
        
        System.assertEquals(null, result);
        queryResult = [SELECT Team_Role__c, Team_Member__c, Organisation__c 
            FROM Account_Team_Member__c];
        System.assertEquals(0, queryResult.size());
    }
    
    static testMethod void testAddMember() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getExistingUserByProfile('Barclays Standard User');
        
        Account_Team_Member__c tm1 = new Account_Team_Member__c();
        tm1.Organisation__c = plan.Relationship__c;
        tm1.Team_Role__c = 'role1';
        tm1.Team_Member__c = u1.Id;
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        ctrl.memberToAdd = tm1;
        
        Test.startTest();
        PageReference result = ctrl.addMember();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertNotEquals(null, ctrl.members);
        System.assertEquals(1, ctrl.members.size());
        System.assertEquals(tm1.Team_Role__c, ctrl.members[0].Team_Role__c);
        
        List<Account_Team_Member__c> queryResult = [SELECT Team_Role__c, Team_Member__c, Organisation__c 
            FROM Account_Team_Member__c];
        System.assertEquals(1, queryResult.size());
        System.assertEquals(tm1.Team_Role__c, queryResult[0].Team_Role__c);
        System.assertEquals(tm1.Organisation__c, queryResult[0].Organisation__c);
    }
    
    static testMethod void testRemoveMember() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getExistingUserByProfile('Barclays Standard User');
        User u2 = userFactory.getExistingUserByProfile('Barclays Administrator');
        
        Account_Team_Member__c tm1 = new Account_Team_Member__c();
        tm1.Organisation__c = plan.Relationship__c;
        tm1.Team_Role__c = 'role1';
        tm1.Team_Member__c = u1.Id;
        
        Account_Team_Member__c tm2 = new Account_Team_Member__c();
        tm2.Organisation__c = plan.Relationship__c;
        tm2.Team_Role__c = 'role2';
        tm2.Team_Member__c = u2.Id;
        
        List<Account_Team_Member__c> tms = new List<Account_Team_Member__c>{tm1, tm2};
        insert tms;
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        System.assertEquals(2, ctrl.members.size());
        
        ctrl.memberRowToDelete = 0;
        
        Test.startTest();
        PageReference result = ctrl.removeMember();
        Test.stopTest();
        
        System.assertEquals(null, result);
        System.assertEquals(1, ctrl.members.size());
        System.assertEquals(tms[1].Team_Role__c, ctrl.members[0].Team_Role__c);
        
        List<Account_Team_Member__c> storedTMs = [SELECT Id, Team_Role__c FROM Account_Team_Member__c];
        System.assertEquals(1, storedTMs.size());
        System.assertEquals(tms[1].Id, storedTMs[0].Id);
    }
    
    static testMethod void testGetRoleOptions() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
    
        Schema.DescribeFieldResult f = Account_Team_Member__c.Team_Role__c.getDescribe();
        List<SelectOption> expected = prepareSelectOptionsFromDescribeFieldResult(f);
        List<SelectOption> result = ctrl.getRoleOptions();
        
        System.assertEquals(expected.size(), result.size());
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testGetStageOptions() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
    
        Schema.DescribeFieldResult f = Client_Plan__c.Status__c.getDescribe();
        List<SelectOption> expected = prepareSelectOptionsFromDescribeFieldResult(f);
        List<SelectOption> result = ctrl.getStageOptions();
        
        System.assertEquals(expected.size(), result.size());
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testGetExpansionPolicyOptions() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
    
        Schema.DescribeFieldResult f = Client_Plan__c.Expansion_Policy__c.getDescribe();
        List<SelectOption> expected = prepareSelectOptionsFromDescribeFieldResult(f);
        List<SelectOption> result = ctrl.getExpansionPolicyOptions();
        
        System.assertEquals(expected.size(), result.size());
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testGetDGOptions() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
    
        Schema.DescribeFieldResult f = Client_Plan__c.DG__c.getDescribe();
        List<SelectOption> expected = prepareSelectOptionsFromDescribeFieldResult(f);
        List<SelectOption> result = ctrl.getDGOptions();
        
        System.assertEquals(expected.size(), result.size());
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i].getLabel(), result[i].getLabel());
            System.assertEquals(expected[i].getValue(), result[i].getValue());
        }
    }
    
    static testMethod void testCountProgressFromEmptyPlanObject() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        Integer result = ctrl.countProgressFromPlanObject();
        
        System.assertEquals(0, result);
    }
    
    static testMethod void testCountProgressFromFilledPlanObject() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //CUSTOM SETTING
        if(ConditionSchedulingSettings__c.getInstance('Default') == null)
        {            
            ConditionSchedulingSettings__c TestConditionSchedulingSetting  = new ConditionSchedulingSettings__c(
                name = 'Default',
                Business_Hours__c = 'Monday to Friday 07:30 - 17:00',
                Months_In_Advance__c  = 12.0
            );
            insert TestConditionSchedulingSetting;
        }
        
        plan.Client_Overview__c = 'asdfasdfasdfasdfasddf';
        plan.DG__c = 'a';
        plan.Expansion_Policy__c = 'Expand';
        plan.FAIS_Status__c = 'a';
        plan.Financial_Year_End__c = 'January';
        plan.Latest_Audited_Financial_Statement__c = Date.today();
        plan.Sector_Overview__c = 'asdfasdfasdfasdfasdff';
        plan.Status__c = 'a';
        plan.TFL__c = 1;
        plan.RoRWA_Existing__c = 1.2;
        
        update plan;
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        Integer result = ctrl.countProgressFromPlanObject();
        
        System.assertEquals(36, result);
    }
    
    static testMethod void testCountPlanProgress() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getExistingUserByProfile('Barclays Standard User');
        
        Account_Team_Member__c tm1 = new Account_Team_Member__c();
        tm1.Organisation__c = plan.Relationship__c;
        tm1.Team_Role__c = 'role1';
        tm1.Team_Member__c = u1.Id;
        insert tm1;
        
        List<Client_Score__c> cs = new List<Client_Score__c>();
        Client_Score__c cs1 = new Client_Score__c();
        cs1.Client_Plan__c = plan.Id;
        cs1.Score_Type__c = 'Strength';
        Client_Score__c cs2 = new Client_Score__c();
        cs2.Client_Plan__c = plan.Id;
        cs2.Score_Type__c = 'Weakness';
        Client_Score__c cs3 = new Client_Score__c();
        cs3.Client_Plan__c = plan.Id;
        cs3.Score_Type__c = 'Opportunity';
        Client_Score__c cs4 = new Client_Score__c();
        cs4.Client_Plan__c = plan.Id;
        cs4.Score_Type__c = 'Threat';
        cs.add(cs1);
        cs.add(cs2);
        cs.add(cs3);
        cs.add(cs4);
        insert cs;
        
        Financial_Information__c fi1 = new Financial_Information__c();
        fi1.Relationship__c = plan.Relationship__c;
        fi1.Year__c = String.valueOf(Date.today().year() - 1);
        
        Financial_Information__c fi2 = new Financial_Information__c();
        fi2.Relationship__c = plan.Relationship__c;
        fi2.Year__c = String.valueOf(Date.today().year());
        
        List<Financial_Information__c> fis = new List<Financial_Information__c>{fi1, fi2};
        insert fis;
        
        List<Country_Presence__c> cps = new List<Country_Presence__c>();
        for (Integer i = 0; i < 6; i++) {
            Country_Presence__c cp = new Country_Presence__c();
            cp.Client_Plan__c = plan.Id;
            cps.add(cp);
        }
        insert cps;
        
        List<Client_Plan_Relationship__c> arps = new List<Client_Plan_Relationship__c>();
        for (Integer i = 0; i < 6; i++) {
            Client_Plan_Relationship__c arp = new Client_Plan_Relationship__c();
            arp.Client_Plan__c = plan.Id;
            arp.Contact__c = cont.Id;
            arps.add(arp);
        }
        insert arps;
        
        List<Budget_Revenue__c> brs = new List<Budget_Revenue__c>();
        for (Integer i = 0; i < 3; i++) {
            Budget_Revenue__c br = new Budget_Revenue__c();
            br.Client_Plan__c = plan.Id;
            brs.add(br);
        }
        insert brs;
        
        Client_Plan_Revenue_By_Product__c rbp = new Client_Plan_Revenue_By_Product__c();
        rbp.Client_Plan__c = plan.Id;
        rbp.F12_Deposits__c = 1234;
        rbp.H12_Deposits__c = 1234;
        insert rbp;
        
        List<Potential_Opportunity__c> uos = new List<Potential_Opportunity__c>();
        for (Integer i = 0; i < 3; i++) {
            Potential_Opportunity__c uo = new Potential_Opportunity__c();
            uo.Client_Plan__c = plan.Id;
            uo.Name = 'opty' + i;
            uos.add(uo);
        }
        insert uos;
        
        List<Client_Plan_Strategy__c> ss = new List<Client_Plan_Strategy__c>();
        for (Integer i = 0; i < 6; i++) {
            Client_Plan_Strategy__c s = new Client_Plan_Strategy__c();
            s.Client_Plan__c = plan.Id;
            ss.add(s);
        }
        insert ss;
        
        List<Opportunity> optys = new List<Opportunity>();
        for (Integer i = 0; i < 3; i++) {
            Opportunity o = new Opportunity();
            o.AccountId = plan.Relationship__c;
            o.Name = 'opty ' + i;
            o.StageName = 'Client Engaged';
            o.CloseDate = Date.today();
            o.Client_Plan_Strategy__c = ss[0].Id;
            optys.add(o);
        }
        insert optys;
        
        List<Organisation_Structure_Item__c> osis = new List<Organisation_Structure_Item__c>();
        for (Integer i = 0; i < 6; i++) {
            Organisation_Structure_Item__c osi = new Organisation_Structure_Item__c();
            osi.Client_Plan__c = plan.Id;
            osis.add(osi);
        }
        insert osis;
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        
        System.assertEquals(64, ctrl.planProgress);
    }
    
    static testMethod void testQueryTeamMembers() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
    
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getExistingUserByProfile('Barclays Standard User');
        User u2 = userFactory.getExistingUserByProfile('Barclays Administrator');
        
        //data we want to get
        Account_Team_Member__c m1 = new Account_Team_Member__c();
        m1.Organisation__c = plan.Relationship__c;
        m1.Team_Member__c = u1.Id;
        m1.Team_Role__c = 'role1';
        insert m1;
        
        //data we don't want to get
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Account_Team_Member__c m2 = new Account_Team_Member__c();
        m2.Organisation__c = acc1.Id;
        m2.Team_Member__c = u2.Id;
        m2.Team_Role__c = 'role2';
        insert m2;
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        Test.startTest();
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        Test.stopTest();
        
        System.assertNotEquals(null, ctrl.members);
        System.assertEquals(1, ctrl.members.size());
        System.assertEquals(m1.Id, ctrl.members[0].Id);
    }
    
    static testMethod void testErrorMessages() {
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        
        System.assertEquals(null, ctrl.errorMessage);
        
        String expected = 'This is an error message';
        ctrl.setErrorMessage(expected);
        System.assertEquals(expected, ctrl.errorMessage);
        
        String result = ctrl.getErrorMessage();
        System.assertEquals(expected, result);
        System.assertEquals(null, ctrl.errorMessage);
        
        System.assertEquals(null, ctrl.getErrorMessage());
    }
    
    static testMethod void testRetrieveSpearData() {
    	// Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('SPEARResponse');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        
    	Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
    	
    	PageReference pr = Page.ClientPlanDetails;
        pr.getParameters().put('planId', plan.Id);
        Test.setCurrentPage(pr);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(plan);
        ClientPlanDetailsController ctrl = new ClientPlanDetailsController(stdController);
        
        Test.startTest();
        ctrl.getSPEARData();
        ctrl.DGLastPulledFromSPEARMillis = 147869308;
        Test.stopTest();
        
        System.assertEquals(ctrl.spear.RatingsFeed.size(), 1);
        SPEAR.Rating r = ctrl.spear.RatingsFeed[0];
        System.assertEquals(r.RatingId, 20064);
        System.assertEquals(r.ObligorSdsId, '40428032');
        System.assertEquals(r.GroupSdsId, null);
        System.assertEquals(r.ObligorName, 'Hirslanden AG');
        System.assertEquals(r.SanctioningUnit, 'Public Sector');
        System.assertEquals(r.ModelName, 'External Rating Agency');
        System.assertEquals(r.ModelVersion, null);
        System.assertEquals(r.Source, 'FACT');
        System.assertEquals(r.Comment, null);
        System.assertEquals(r.CompletedOn, '2015-11-09T12:08:23');
        System.assertEquals(r.CountryCap, null);
        System.assertEquals(r.CountryOfAssets, 'ZA');
        System.assertEquals(r.CountryOfIncorporation, 'GB');
        System.assertEquals(r.TTCPDYear1, 0.0272848089028861);
        System.assertEquals(r.PITPDYear1, 0.01375);
        System.assertEquals(r.PITPDYear2, 0.04787);
        System.assertEquals(r.PITPDYear3, 0.08087);
        System.assertEquals(r.PITPDYear4, 0.11296);
        System.assertEquals(r.PITPDYear5, 0.14303);
        System.assertEquals(r.TTCDGYear1, 15);
        System.assertEquals(r.PITDGYear1, 13);
        System.assertEquals(r.PITDGYear2, 14);
        System.assertEquals(r.PITDGYear3, 13);
        System.assertEquals(r.PITDGYear4, 13);
        System.assertEquals(r.PITDGYear5, 13);
        System.assertEquals(r.AgencyRatings.size(), 2);
        SPEAR.AgencyRating ar = r.AgencyRatings[0];
        System.assertEquals(ar.AgencyName, 'Moodys');
        System.assertEquals(ar.Type, 'global');
        System.assertEquals(ar.RatingDate, '2014-04-01T00:00:00');
        System.assertEquals(ar.Grade, 'B2');
        
        System.assertEquals(ctrl.offset != null, true);  
        System.assertEquals(ctrl.getSDSClients.size(), 1);
        System.assertEquals(ctrl.getSelectedSDSClient, '');
    }
    
    private static List<SelectOption> prepareSelectOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            options.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        return options;
    }
    
}