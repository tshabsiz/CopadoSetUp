@isTest
public class evDelegateCreation_Controller_test
{
    static testMethod void evDelegateCreation_Controller_test()
    {
        evTestDataGenerator TestData = new  evTestDataGenerator();
        
        TestData.TestEvent.Private_Delegate_Account_Name__c = TestData.TestAccount.id;
        
        update TestData.TestEvent;
        
        evDelegateCreation_Controller Con = new evDelegateCreation_Controller();
        list<string> StringList = new  list<string>();
        StringList.add('Test1');
        StringList.add('Test2');
        
        Con.addSingleQuote(StringList);
        Con.getDelegateRecord(TestData.TestDelegate.Id, TestData.TestContact.Id, TestData.Testevent.Id);
        Con.createEventBooking(TestData.Testevent.Id);
        Con.setNumberOfInvitesUsed(1);
        Con.getDefaultListValue();
        Con.setDefaultListValue('test');
        Con.getSelectedEvent();
        Con.setSelectedEvent('test');
        Con.getSelectedTeamMember();
        Con.SetSelectedTeamMember('test');
        Con.TeamMemberSelected();
        con.setNumberOfInvites('test');
        con.getDelegateWrappersList();
        con.goBack();
        
        con.recordCount = '1';
        
        con.isNumbersOk  = true;
        con.existingNumbers  = 1;
        con.selectedNumbers  = 1; 
        con.allowedNumbers   = 1;
    }
    
    static testMethod void evDelegateCreation_Controller_testImport()
    {
        evTestDataGenerator TestData = new  evTestDataGenerator();
        
        TestData.TestEvent.Private_Delegate_Account_Name__c = TestData.TestAccount.id;
        
        update TestData.TestEvent;
        
        evDelegateCreation_Controller Con = new evDelegateCreation_Controller();
        
        User u = [select Id,Name from User where User.UserName = :system.UserInfo.getUserName()];
        system.debug('user = ' + u);
        Event_Team_Member__c etm =
            [
                SELECT 
                id
                from
                Event_Team_Member__c
                where 
                Team_Member__c =: u.id
            ];
        
        //Create Team Member
        //Create test import record
        Pending_Delegate__c newD = new Pending_Delegate__c();
        newD.Company_Name__c = 'Company1';
        newD.Email__c = 'fn1@test.com';
        newD.First_Name__c = 'FN1';
        newD.Last_Name__c = 'LN1';
        newD.Job_Title__c = 'Job Title 1';
        newD.Mobile_Phone__c = '0831234567';
        insert newD;
        
        Pending_Delegate__c newDMatch = new Pending_Delegate__c();
        newDMatch.Company_Name__c = 'Company1';
        newDMatch.Email__c = TestData.TestContact.email;
        newDMatch.First_Name__c = TestData.TestContact.FirstName;
        newDMatch.Last_Name__c = TestData.TestContact.LastName;
        newDMatch.Job_Title__c = 'Job Title 1';
        newDMatch.Mobile_Phone__c = '0831234567';
        insert newDMatch;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('eventid',TestData.Testevent.Id);
        ApexPages.currentPage().getParameters().put('host', etm.Id);
        
        Con = new evDelegateCreation_Controller();
        for(evDelegateCreation_Controller.DelegateWrapper pd: Con.DelegateWrappers)
        {
            pd.doImport = true;
            pd.ActualMatch = 'New';
        }
        Con.selectedEvent = TestData.Testevent.Id;
        Con.selectedTeamMember = etm.Id;
        Con.createDelegates();   
        
        CON.DelegateWrappers[0].doImport = true;       
        
        Con.removeDelegates();
        Con.GetTeamMembersList();
    }
    
     static testMethod void evDelegateCreation_Controller_testImport2()
    {
        evTestDataGenerator TestData = new  evTestDataGenerator();
        
        TestData.TestEvent.Private_Delegate_Account_Name__c = TestData.TestAccount.id;
        
        update TestData.TestEvent;
        
        evDelegateCreation_Controller Con = new evDelegateCreation_Controller();
        
        User u = [select Id,Name from User where User.UserName = :system.UserInfo.getUserName()];
        system.debug('user = ' + u);
        Event_Team_Member__c etm =
            [
                SELECT 
                id
                from
                Event_Team_Member__c
                where 
                Team_Member__c =: u.id
            ];
        
        //Create Team Member
        //Create test import record
        Pending_Delegate__c newD = new Pending_Delegate__c();
        newD.Company_Name__c = 'Company1';
        newD.Email__c = 'fn1@test.com';
        newD.First_Name__c = 'FN1';
        newD.Last_Name__c = 'LN1';
        newD.Job_Title__c = 'Job Title 1';
        newD.Mobile_Phone__c = '0831234567';
        insert newD;
        
        Pending_Delegate__c newDMatch = new Pending_Delegate__c();
        newDMatch.Company_Name__c = 'Company1';
        newDMatch.Email__c = TestData.TestContact.email;
        newDMatch.First_Name__c = TestData.TestContact.FirstName;
        newDMatch.Last_Name__c = TestData.TestContact.LastName;
        newDMatch.Job_Title__c = 'Job Title 1';
        newDMatch.Mobile_Phone__c = '0831234567';
        insert newDMatch;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('eventid',TestData.Testevent.Id);
        ApexPages.currentPage().getParameters().put('host', etm.Id);
        
        Con = new evDelegateCreation_Controller();
        for(evDelegateCreation_Controller.DelegateWrapper pd: Con.DelegateWrappers)
        {
            pd.doImport = true;
            pd.ActualMatch = TestData.TestContact.id;
        }
        Con.selectedEvent = TestData.Testevent.Id;
        Con.selectedTeamMember = etm.Id;
        Con.createDelegates();   
        
        CON.DelegateWrappers[0].doImport = true;       
        
        Con.removeDelegates();
        Con.GetTeamMembersList();
        Con.getDelegateTypes();
        Con.getPartnerTypes();
    }
    
    static testMethod void evDelegateCreation_Controller_testAd()
    {
        evTestDataGenerator testData = new evTestDataGenerator();
        
        TestData.TestEvent.Private_Delegate_Account_Name__c = TestData.TestAccount.id;
        
        update TestData.TestEvent;
        
        list<Contact> contList = new list<Contact>();
        Contact c1 = new Contact(FirstName = 'Existing1',LastName ='Contact1',AccountId = testData.TestAccount.Id);
        Contact c2 = new Contact(FirstName = 'Existing2',LastName ='Contact2',AccountId = testData.TestAccount.Id);
        Contact c3 = new Contact(FirstName = 'Existing3',LastName ='Contact3',AccountId = testData.TestAccount.Id);
        Contact c4 = new Contact(FirstName = 'Existing4',LastName ='Contact4',AccountId = testData.TestAccount.Id);
        Contact c5 = new Contact(FirstName = 'Existing5',LastName ='Contact5',AccountId = testData.TestAccount.Id);
        
        contList.add(c1);
        contList.add(c2);
        contList.add(c3);
        contList.add(c4);
        contList.add(c5);
        insert contList;
        
        testData.TestEvent.Active__c = true;
        //testData.TestEvent.Registration_Process__c = 'Complex';
        update  testData.TestEvent;
        
        
        Event_Team_Member__c tm =
            [
                SELECT 
                id
                from
                Event_Team_Member__c
                where 
                Team_Member__c =:  UserInfo.getUserId()
            ];
        
        
        
        list<Delegate__c> delList = new list<Delegate__c>();
        for(Integer x=0;x<=contList.size()-1;x++){
            
            Delegate__c del = new Delegate__c();
            del.Contact__c = contList[x].Id;
            del.Event__c = testData.TestEvent.Id;
            del.Event_Booking__c = testData.TestEventBooking.Id;
            del.Invitation_Status__c = 'Proposed';
            delList.add(del);
        }
        
        insert delList;
        
        list<Event_Team_Members_Delegates__c> evtdList = new list<Event_Team_Members_Delegates__c>();
        
        for(Integer x=0;x<=delList.size()-1;x++)
        {
            Event_Team_Members_Delegates__c evtd = new Event_Team_Members_Delegates__c();
            evtd.Delegate__c = delList[x].Id;
            evtd.Event_Team_Member__c = tm.Id;
            evtdList.add(evtd);
        }
        
        insert evtdList;
        
        User u = new User();
        u.Id = UserInfo.getUserId();
        
        Test.startTest();
        
        PageReference myVfPage = Page.evDelegateCreation_AddContacts;
        Test.setCurrentPage(myVfPage);
        
        // String ids = '\'' + contList[0].Id + '\',\'' + contList[1].Id + '\',\'' + contList[2].Id + '\',\'' + contList[3].Id + '\',\'' + contList[4].Id + '\'';
        String ids =  contList[0].Id + ',' + contList[1].Id + ',' + contList[2].Id + ',' + contList[3].Id + ',' + contList[4].Id ;
        ApexPages.currentPage().getParameters().put('recs', ids);
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(contList);
        evDelegateCreation_Controller ext = new evDelegateCreation_Controller(controller);
        
        evDelegateCreation_Controller.DelegateWrapper TestWrap = new evDelegateCreation_Controller.DelegateWrapper();
         TestWrap.ContactRec = c1;
        TestWrap.isChecked =  true;
        
        
        System.runAs(u)
        {
            
            //ext.showEvent();
            ext.selectedEvent = testData.TestEvent.Id;
            ext.lstAWrapper =  new list<evDelegateCreation_Controller.DelegateWrapper>();
            ext.lstAWrapper.add(TestWrap); 
            ext.addToEvent();
            ext.newHostList();
            ext.refreshLists();
            ext.cancel();
        }
        
        Test.stopTest();
    }
    
}