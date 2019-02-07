/**
* Author : Genevieve Dielwart
* Date   : 2017-08-23
* Desc   : Test class for the evImportDelegates_Controller class
**/
@isTest
public class evImportDelegates_Controller_Test {
    static testMethod void testImportDelegatesNewContact(){
        //Create Event
        RecordType rt = [select Id, Name from RecordType where DeveloperName='Function'];
        Event__c event = new Event__c();
        event.RecordTypeId = rt.Id;
        event.Name = 'Test Event for Import';
        event.Type__c = 'Breakfast';
        event.Registration_Process__c = 'Simple';
        event.Registration_Type__c = 'Personal Invitation Only';
        event.Country__c = 'South Africa';
        event.City__c = 'Johannesburg';
        event.Capacity__c = 100;
        event.Start_Date__c = Date.Today();
        event.End_Date__c = Date.Today();
        event.Duration__c = 1;
        event.Duration_Units__c = 'Day(s)';
        event.I_have_read_Absa_Event_Governance__c = true;
        insert event;
        system.debug('inserted event:' + event);
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
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('eventid', event.Id);
        ApexPages.currentPage().getParameters().put('host', etm.Id);
        
        evImportDelegates_Controller controller = new evImportDelegates_Controller();
        for(evImportDelegates_Controller.PendingDelegate pd: controller.PendingDelegates)
        {
            pd.doImport = true;
            pd.ActualMatch = 'New';
        }
        controller.selectedEvent = event.Id;
        controller.selectedTeamMember = etm.Id;
        controller.createDelegates();
        Test.stopTest();
    }
    
    static testMethod void testImportDelegatesExistingContact(){
        //Create Event
        RecordType rt = [select Id, Name from RecordType where DeveloperName='Function'];
        Event__c event = new Event__c();
        event.RecordTypeId = rt.Id;
        event.Name = 'Test Event for Import';
        event.Type__c = 'Breakfast';
        event.Registration_Process__c = 'Simple';
        event.Registration_Type__c = 'Personal Invitation Only';
        event.Country__c = 'South Africa';
        event.City__c = 'Johannesburg';
        event.Capacity__c = 100;
        event.Start_Date__c = Date.Today();
        event.End_Date__c = Date.Today();
        event.Duration__c = 1;
        event.Duration_Units__c = 'Day(s)';
        event.I_have_read_Absa_Event_Governance__c = true;
        insert event;
        system.debug('inserted event:' + event);
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
        newD.Mobile_Phone__c = '2711 237 1434';
        insert newD;
        
        //Create existing Contact and account
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact c = new Contact(FirstName='FN1',LastName='LN1',Email='fn1@test.com',MobilePhone='27 11 1234567', AccountId=acc.Id);
        insert c;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('eventid', event.Id);
        ApexPages.currentPage().getParameters().put('host', etm.Id);
        evImportDelegates_Controller controller = new evImportDelegates_Controller();
        for(evImportDelegates_Controller.PendingDelegate pd: controller.PendingDelegates)
        {
            pd.doImport = true;
            pd.ActualMatch = c.Id;
        }
        controller.selectedEvent = event.Id;
        controller.selectedTeamMember = etm.Id;
        controller.createDelegates();
        Test.stopTest();
    }
    
    static testMethod void testImportDelegatesExistingContactComplexEvent(){
        //Create Event
        RecordType rt = [select Id, Name from RecordType where DeveloperName='Default'];
        Event__c event = new Event__c();
        event.RecordTypeId = rt.Id;
        event.Name = 'Test Event for Import';
        event.Type__c = 'Customer';
        event.Registration_Process__c = 'Complex';
        event.Registration_Type__c = 'Personal Invitation Only';
        event.Country__c = 'South Africa';
        event.City__c = 'Johannesburg';
        event.Capacity__c = 100;
        event.Start_Date__c = Date.Today();
        event.End_Date__c = Date.Today();
        event.Duration__c = 1;
        event.Duration_Units__c = 'Day(s)';
        event.I_have_read_Absa_Event_Governance__c = true;
        insert event;
        system.debug('inserted event:' + event);
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
        newD.Mobile_Phone__c = '2711 237 1434';
        insert newD;
        
        //Create existing Contact and account
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact c = new Contact(FirstName='FN1',LastName='LN1',Email='fn1@test.com',MobilePhone='27 11 1234567', AccountId=acc.Id);
        insert c;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('eventid', event.Id);
        ApexPages.currentPage().getParameters().put('host', etm.Id);
        evImportDelegates_Controller controller = new evImportDelegates_Controller();
        for(evImportDelegates_Controller.PendingDelegate pd: controller.PendingDelegates)
        {
            pd.doImport = true;
            pd.ActualMatch = c.Id;
        }
        controller.selectedEvent = event.Id;
        controller.selectedTeamMember = etm.Id;
        controller.createDelegates();
        Test.stopTest();
    }
    
    static testMethod void testImportDelegatesNoItemsForProcessing(){
        //Create Event
        RecordType rt = [select Id, Name from RecordType where DeveloperName='Function'];
        Event__c event = new Event__c();
        event.RecordTypeId = rt.Id;
        event.Name = 'Test Event for Import';
        event.Type__c = 'Breakfast';
        event.Registration_Process__c = 'Simple';
        event.Registration_Type__c = 'Personal Invitation Only';
        event.Country__c = 'South Africa';
        event.City__c = 'Johannesburg';
        event.Capacity__c = 100;
        event.Start_Date__c = Date.Today();
        event.End_Date__c = Date.Today();
        event.Duration__c = 1;
        event.Duration_Units__c = 'Day(s)';
        event.I_have_read_Absa_Event_Governance__c = true;
        insert event;
        system.debug('inserted event:' + event);
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
        
        
        
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('eventid', event.Id);
        ApexPages.currentPage().getParameters().put('host', etm.Id);
        
        evImportDelegates_Controller controller = new evImportDelegates_Controller();
        controller.setNumberOfInvitesUsed(5);
        controller.setNumberOfInvites('10');
        string lv = controller.getDefaultListValue();
        for(evImportDelegates_Controller.PendingDelegate pd: controller.PendingDelegates)
        {
            pd.doImport = true;
            pd.ActualMatch = 'New';
        }
        controller.setSelectedEvent(event.Id);
        //controller.selectedEvent = event.Id;
        controller.setSelectedTeamMember(etm.Id);
        string tm = controller.getSelectedTeamMember();
        string sev = controller.getSelectedEvent();
        controller.setDefaultListValue('');
        PageReference pr = controller.TeamMemberSelected();
        pr = controller.goBack();
        List<Pending_Delegate__c> l = controller.getPendingDelegatesList();
        controller.createDelegates();
        Test.stopTest();
    }
    
    static testMethod void testImportDelegatesRemoveDelegates(){
        //Create Event
        RecordType rt = [select Id, Name from RecordType where DeveloperName='Function'];
        Event__c event = new Event__c();
        event.RecordTypeId = rt.Id;
        event.Name = 'Test Event for Import';
        event.Type__c = 'Breakfast';
        event.Registration_Process__c = 'Simple';
        event.Registration_Type__c = 'Personal Invitation Only';
        event.Country__c = 'South Africa';
        event.City__c = 'Johannesburg';
        event.Capacity__c = 100;
        event.Start_Date__c = Date.Today();
        event.End_Date__c = Date.Today();
        event.Duration__c = 1;
        event.Duration_Units__c = 'Day(s)';
        event.I_have_read_Absa_Event_Governance__c = true;
        insert event;
        system.debug('inserted event:' + event);
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
        newD.Mobile_Phone__c = '2711 237 1434';
        insert newD;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('eventid', event.Id);
        ApexPages.currentPage().getParameters().put('host', etm.Id);
        
        evImportDelegates_Controller controller = new evImportDelegates_Controller();
        for(evImportDelegates_Controller.PendingDelegate pd: controller.PendingDelegates)
        {
            pd.doImport = true;
            pd.ActualMatch = 'New';
        }
        controller.selectedEvent = event.Id;
        controller.selectedTeamMember = etm.Id;
        controller.removeDelegates();
        Test.stopTest();
    }
}