/**
* Author : Rudolf Niehaus
* Date   : 2017-08-11/23
* Desc   : Test class for the evAddContactsToEventExt class
**/
@isTest
public class evAddContactsToEventExt_Test {
    
    static testMethod void testAddContactsToEventExtr(){
        
        evTestDataGenerator testData = new evTestDataGenerator();
        
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
        testData.TestEvent.Registration_Process__c = 'Complex';
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
        
         for(Integer x=0;x<=delList.size()-1;x++){
            Event_Team_Members_Delegates__c evtd = new Event_Team_Members_Delegates__c();
            evtd.Delegate__c = delList[x].Id;
            evtd.Event_Team_Member__c = tm.Id;
            evtdList.add(evtd);
         }
        
        insert evtdList;
        
        User u = new User();
        u.Id = UserInfo.getUserId();

        Test.startTest();
        
        PageReference myVfPage = Page.evAddContactsToEvent;
        Test.setCurrentPage(myVfPage);
        
       // String ids = '\'' + contList[0].Id + '\',\'' + contList[1].Id + '\',\'' + contList[2].Id + '\',\'' + contList[3].Id + '\',\'' + contList[4].Id + '\'';
        String ids =  contList[0].Id + ',' + contList[1].Id + ',' + contList[2].Id + ',' + contList[3].Id + ',' + contList[4].Id ;
        ApexPages.currentPage().getParameters().put('recs', ids);
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(contList);
        evAddContactsToEventExt ext = new evAddContactsToEventExt(controller);
        evAddContactsToEventExt.listAWrapper TestWrap = new evAddContactsToEventExt.listAWrapper(c1, true);
       // TestWrap.contact = c1;
        //TestWrap.isChecked =  true;
        
        
        System.runAs(u){
            
            ext.showEvent();
            ext.selectedEvent = testData.TestEvent.Id;
            ext.lstAWrapper.add(TestWrap); 
            ext.addToEvent();
            ext.newHostList();
            ext.refreshLists();
            ext.cancel();
        }
        
        Test.stopTest();
    } 
}