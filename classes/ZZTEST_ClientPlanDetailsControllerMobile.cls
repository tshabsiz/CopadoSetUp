/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanDetailsControllerMobile
*                 Tests executed:
*                 1 - testGetClientPlan()
*                   Tests querying of client plan
*                 2 - testGetTeamMembers()
*                   Tests getter of account team members
*                 3 - testGetMetadata()
*                   Tests getter of fields' metadata
*                 4 - testSaveClientPlanInfo()
*                   Tests saving of client plan fields
*                 5 - testRemoveTeamMember()
*                   Tests removing of account team member
*                 6 - testGetUsers()
*                   Tests getter of user records
*                 7 - testGetRoleOptions()
*                   Tests getter of account team role options
*                 8 - testAddTeamMember()
*                   Tests adding of account team member
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanDetailsControllerMobile {

    @testSetup static void setup() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getBarclaysStandardUser();
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
    }
    
    static testMethod void testGetClientPlan() {
    
        //preparing test data
        Account acc = [SELECT Id FROM Account LIMIT 1];
        delete acc;
        
        User u1 = [SELECT Id FROM User LIMIT 1];
    
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c plan = new Client_Plan__c();
        plan.Relationship__c = acc1.Id;
        plan.Client_Overview__c = 'asdfasdfasdfasdfasddf';
        plan.DG__c = 'a';
        plan.Expansion_Policy__c = 'Expand';
        plan.FAIS_Status__c = 'a';
        plan.Financial_Year_End__c = 'a';
        plan.Latest_Audited_Financial_Statement__c = Date.today();
        plan.Sector_Overview__c = 'asdfasdfasdfasdfasdff';
        plan.Status__c = 'a';
        plan.TFL__c = 1;
        insert plan;
        
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        
        Account_Team_Member__c tm1 = new Account_Team_Member__c();
        tm1.Organisation__c = plan.Relationship__c;
        tm1.Team_Role__c = 'role1';
        tm1.Team_Member__c = u1.Id;
        insert tm1;
        
        Financial_Information__c fi1 = new Financial_Information__c();
        fi1.Relationship__c = acc1.Id;
        fi1.Year__c = String.valueOf(Date.today().year() - 1);
        
        Financial_Information__c fi2 = new Financial_Information__c();
        fi2.Relationship__c = acc1.Id;
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
        
        //testing - null plan Id
        Map<String, Object> result = ClientPlanDetailsControllerMobile.getClientPlan(null);
        System.assertEquals(null, result);
        
        //working code
        result = ClientPlanDetailsControllerMobile.getClientPlan(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(2, result.keyset().size());
        
        Object planResult = result.get('plan');
        System.assertNotEquals(null, planResult);
        System.assertEquals(true, planResult instanceof Client_Plan__c);
        
        Object progressResult = result.get('planProgress');
        System.assertNotEquals(null, progressResult);
        System.assertEquals(true, progressResult instanceof Integer);
        
        Integer progress = (Integer) progressResult;
        System.assertEquals(100, progress);
    }
    
    static testMethod void testGetTeamMembers() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        User u = [SELECT Id FROM User LIMIT 1];
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        String memberId = prepareTeamMember(acc.Id, u.Id);
    
        List<Account_Team_Member__c> result = ClientPlanDetailsControllerMobile.getTeamMembers(null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanDetailsControllerMobile.getTeamMembers('asdfsdf');
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanDetailsControllerMobile.getTeamMembers(plan.Id);
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals(u.Id, result[0].Team_Member__c);
        System.assertEquals('Some role', result[0].Team_Role__c);
    }
    
    static testMethod void testGetMetadata() {
    
        //preparing expected
        Schema.DescribeFieldResult fieldResult = Client_Plan__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> statusOptions = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            statusOptions.add(f.getLabel());
        }
        
        fieldResult = Client_Plan__c.Expansion_Policy__c.getDescribe();
        entries = fieldResult.getPicklistValues();
        List<String> policyOptions = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            policyOptions.add(f.getLabel());
        }
        
        fieldResult = Client_Plan__c.DG__c.getDescribe();
        entries = fieldResult.getPicklistValues();
        List<String> dgOptions = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            dgOptions.add(f.getLabel());
        }
        
        //getting result
        Map<String, List<String>> result = ClientPlanDetailsControllerMobile.getMetadata();
        System.assertEquals(3, result.keyset().size());
        
        //testing status
        List<String> statusResult = result.get('stage');
        System.assertNotEquals(null, statusResult);
        System.assertEquals(statusOptions.size(), statusResult.size());
        
        for (Integer i = 0; i < statusOptions.size(); i++) {
            System.assertEquals(statusOptions[i], statusResult[i]);
        }
        
        //testing policy
        List<String> policyResult = result.get('expansionPolicy');
        System.assertNotEquals(null, policyResult);
        System.assertEquals(policyOptions.size(), policyResult.size());
        
        for (Integer i = 0; i < policyOptions.size(); i++) {
            System.assertEquals(policyOptions[i], policyResult[i]);
        }
        
        //testing dg
        List<String> dgResult = result.get('dg');
        System.assertNotEquals(null, dgResult);
        System.assertEquals(dgOptions.size(), dgResult.size());
        
        for (Integer i = 0; i < dgOptions.size(); i++) {
            System.assertEquals(dgOptions[i], dgResult[i]);
        }
    }
    
    static testMethod void testSaveClientPlanInfo() {
        Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
        
        //not-existing planId test
        Boolean result = ClientPlanDetailsControllerMobile.saveClientPlanInfo(null, null, null, null, null);
        System.assertEquals(true, result);
        
        //null values test
        result = ClientPlanDetailsControllerMobile.saveClientPlanInfo(plan.Id, null, null, null, null);
        System.assertEquals(false, result);
        
        List<Client_Plan__c> resultPlans = [
            SELECT Status__c, Expansion_Policy__c, DG__c, LGD__c
            FROM Client_Plan__c
            WHERE Id = :plan.Id
        ];
        System.assertNotEquals(null, resultPlans);
        System.assertEquals(1, resultPlans.size());
        System.assertEquals(null, resultPlans[0].Status__c);
        System.assertEquals(null, resultPlans[0].Expansion_Policy__c);
        System.assertEquals(null, resultPlans[0].DG__c);
        System.assertEquals(null, resultPlans[0].LGD__c);
        
        //not-null values test
        result = ClientPlanDetailsControllerMobile.saveClientPlanInfo(plan.Id, 'Status 1', 'Policy 1', 'DG 1', 2);
        System.assertEquals(false, result);
        
        resultPlans = [
            SELECT Status__c, Expansion_Policy__c, DG__c, LGD__c
            FROM Client_Plan__c
            WHERE Id = :plan.Id
        ];
        System.assertNotEquals(null, resultPlans);
        System.assertEquals(1, resultPlans.size());
        System.assertEquals('Status 1', resultPlans[0].Status__c);
        System.assertEquals('Policy 1', resultPlans[0].Expansion_Policy__c);
        System.assertEquals('DG 1', resultPlans[0].DG__c);
        System.assertEquals(2, resultPlans[0].LGD__c);
    }
    
    static testMethod void testRemoveTeamMember() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        User u = [SELECT Id FROM User LIMIT 1];
        
        String memberId = prepareTeamMember(acc.Id, u.Id);
        
        //not-existing memberId
        Boolean result = ClientPlanDetailsControllerMobile.removeTeamMember(null);
        System.assertEquals(true, result);
        
        result = ClientPlanDetailsControllerMobile.removeTeamMember('asdfasdf');
        System.assertEquals(true, result);
        
        //existing memberId
        result = ClientPlanDetailsControllerMobile.removeTeamMember(memberId);
        System.assertEquals(false, result);
        
        List<Account_Team_Member__c> members = [
            SELECT Id
            FROM Account_Team_Member__c
            WHERE Organisation__c = :acc.Id
        ];
        System.assertEquals(0, members.size());
    }
    
    static testMethod void testGetUsers() {
        User u = [SELECT Id FROM User LIMIT 1];
        
        //null params test
        List<User> result = ClientPlanDetailsControllerMobile.getUsers(null, null, null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanDetailsControllerMobile.getUsers('1', null, null);
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        //limitation test
        result = ClientPlanDetailsControllerMobile.getUsers('0', null, new List<String>());
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanDetailsControllerMobile.getUsers('asdf', null, new List<String>());
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
        
        result = ClientPlanDetailsControllerMobile.getUsers('1', null, new List<String>());
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        
        //name restriction test
        result = ClientPlanDetailsControllerMobile.getUsers('1', 'bar', new List<String>());
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
    }
    
    static testMethod void testGetRoleOptions() {
        
        Schema.DescribeFieldResult fieldResult = Account_Team_Member__c.Team_Role__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
        List<String> expected = new List<String>();

        for (Schema.PicklistEntry f: entries) {
            expected.add(f.getLabel());
        }
        
        List<String> result = ClientPlanDetailsControllerMobile.getRoleOptions();
        System.assertNotEquals(null, result);
        System.assertEquals(expected.size(), result.size());
        
        for (Integer i = 0; i < expected.size(); i++) {
            System.assertEquals(expected[i], result[i]);
        }
    }
    
    static testMethod void testAddTeamMember() {
        User u = [SELECT Id FROM User LIMIT 1];
        Client_Plan__c plan = [SELECT Id, Relationship__c FROM Client_Plan__c LIMIT 1];
        
        //not-existing planId
        Boolean result = ClientPlanDetailsControllerMobile.addTeamMember(null, null, null);
        System.assertEquals(true, result);
        
        List<Account_Team_Member__c> resultData = [
            SELECT Id
            FROM Account_Team_Member__c
        ];
        System.assertEquals(0, resultData.size());
        
        //not-existing userId
        result = ClientPlanDetailsControllerMobile.addTeamMember(plan.Id, 'adsfasdf', null);
        System.assertEquals(true, result);
        
        resultData = [
            SELECT Id
            FROM Account_Team_Member__c
        ];
        System.assertEquals(0, resultData.size());
        
        //working code
        result = ClientPlanDetailsControllerMobile.addTeamMember(plan.Id, u.Id, 'Some role');
        System.assertEquals(false, result);
        
        resultData = [
            SELECT Team_Member__c, Team_Role__c, Organisation__c
            FROM Account_Team_Member__c
        ];
        System.assertEquals(1, resultData.size());
        System.assertEquals(u.Id, resultData[0].Team_Member__c);
        System.assertEquals('Some role', resultData[0].Team_Role__c);
        System.assertEquals(plan.Relationship__c, resultData[0].Organisation__c);
    }
    
    private static String prepareTeamMember(String accId, String userId) {
    
        Account_Team_Member__c atm = new Account_Team_Member__c();
        atm.Organisation__c = accId;
        atm.Team_Member__c = userId;
        atm.Team_Role__c = 'Some role';
        insert atm;
        
        return atm.Id;
    }
    
}