/**
 * Tests controller evEventEmailConfig_Controller.
 * 
 * @author CloudSmiths
 */ 

@isTest
public class evEventEmailConfig_Controller_test {
    
    /**
     *  Creates test data including 
     *  Event__c records
     *  Delegate__c records
     *  EM_Event_Email_Configuration__c
     *  
     */
    @testSetup static void createData() {
        // Create Events
        List<Event__c> events = new List<Event__c>();
        events.add(createEvent('Test Event', true));
        events.add(createEvent('Test Event 2', true));
        Event__c oldEvent = createEvent('Test Event Old', true);
        oldEvent.Start_Date__c = System.today().addYears(-10);
        oldEvent.End_Date__c = oldEvent.Start_Date__c.addDays(2);
        events.add(oldEvent);
        insert events; 
        
        // Create Delegates for each event
        Contact contact = createAndPersistContact();
        Id contactId = contact.Id;
        List<Delegate__c> delegates = new List<Delegate__c>();
        for (Event__c event : events) {
            delegates.addAll(createDelegates(event, contactId, 2));
            contactId = null;
        }
        insert delegates;
        
        // Create Event Email Configuration record.
        Event__c event = events[0];
        EM_Event_Email_Configuration__c rbatch =  new EM_Event_Email_Configuration__c();
        rbatch.Event__c = event.Id;
        rbatch.SMS_Text__C = 'Test SMS';
        rbatch.Delegate__c = delegates[0].Id;
        insert rbatch; 
    }
    
    
    static testMethod void testAttributeGetters() {
        EM_Event_Email_Configuration__c rbatch =  selectEventEmailConfiguration();
        ApexPages.StandardController sc = new ApexPages.standardController(rbatch); 
        evEventEmailConfig_Controller myPageCon = new evEventEmailConfig_Controller(sc);
        //myPageCon.record.EMail_Template__c = template.Id;
        List<SelectOption> templates = myPageCon.templates;
        System.assert(templates != null && !templates.isEmpty() && templates.size() > 1, 'Expected email templates');
        
        List<SelectOption> addresses =  myPageCon.orgWideAddresses;
        System.assert(addresses != null && !addresses.isEmpty() && addresses.size() > 2, 'Expected org wide email addresses');
        
        // Test the getter of the events attribute
        List<SelectOption> eventOptions = myPageCon.events;
        System.assert(eventOptions != null && !eventOptions.isEmpty(), 'Expected events to be returned ' );
        System.assertEquals(2, eventOptions.size(), 'Number of events');
    }
    
    
    /**
     * Tests method doSave where the data is valid.
     */ 
    static testMethod void doSaveWhereValid() {
        Boolean shouldSucceed = true;
        EM_Event_Email_Configuration__c rbatch = selectEventEmailConfiguration();
       
        // Test Edit
        ApexPages.standardController sc = new ApexPages.standardController(rbatch);
        evEventEmailConfig_Controller myPageCon = new evEventEmailConfig_Controller(sc);
        
        // Set up data in controller attributes
        List<SelectOption> templates = myPageCon.templates;
        List<SelectOption> addresses =  myPageCon.orgWideAddresses;
        List<SelectOption> events = myPageCon.events;
        
        // Get the delegates for each event;
        Map<Id, List<Delegate__c>> delegatesByEventId  = selectDelegates();
        // Test delegate validation for changed delegate
        myPageCon.selectEvent = true;
        Id previousDelegateId = rbatch.Delegate__c;
        List<Delegate__c> delegates = delegatesByEventId.get(rbatch.Event__c);
        System.assert(delegates != null && delegates.size() >=2, 'Expected at least 2 delegates');
       
        // Extract another good delegate
        Delegate__c validDelegate = delegates[1];
        myPageCon.record.Delegate__c = validDelegate.Id;
        String message = myPageCon.validateDelegate();
        System.assert(message == null, 'Expected delegate validation to succeed');
        testDoSave(myPageCon, shouldSucceed);
        
       
        // This should save the record
        myPageCon.record.eMail_Template__c = templates[1].getValue();
        myPageCon.record.SMS_Text__C = null;
        myPageCon.record.Send_From__c = evEventEmailConfig_Controller.EMAIL_VALUE_LOGGED_IN_USER; //LoggedInUser
        testDoSave(myPageCon, shouldSucceed);
        
       
        myPageCon.record.Send_From__c = addresses[3].getValue();
        testDoSave(myPageCon, shouldSucceed);
        
         // Test New
        EM_Event_Email_Configuration__c newRecord = myPageCon.record.clone();
        sc = new ApexPages.standardController(newRecord);
        myPageCon = new evEventEmailConfig_Controller(sc);
        testDoSave(myPageCon, shouldSucceed);
        
        
        // Test cloning
        List<EM_Event_Email_Configuration__c> eventEmailConfigurations = selectEventEmailConfigurationRecords();
        Integer recordCount = eventEmailConfigurations.size();
        Map<String, String> pageParameters =  ApexPages.currentPage().getParameters(); 
        System.assert(pageParameters != null, 'Expected non null ApexPage parameter Map');
        pageParameters.put(evEventEmailConfig_Controller.PARAMETER_CLONE_NAME, evEventEmailConfig_Controller.PARAMETER_CLONE_VALUE_TRUE); // 'clone' , '1'
        rbatch.eMail_Template__c = templates[1].getValue();
        rbatch.SMS_Text__C = null;
        rbatch.Send_From__c = evEventEmailConfig_Controller.EMAIL_VALUE_LOGGED_IN_USER; //LoggedInUser
        testDoSave(rbatch, sc, shouldSucceed);
        eventEmailConfigurations = selectEventEmailConfigurationRecords();
        System.assert(eventEmailConfigurations != null && eventEmailConfigurations.size() ==recordCount + 1, 'Should have inserted an Event Email Configuration record');
    }
    

    /**
     * Tests method doSave failues where the data is not valid and would result in an error message.
     *    
     */ 
    static testMethod void doSaveWhenInvalid() {
        
        EM_Event_Email_Configuration__c rbatch = selectEventEmailConfiguration();
        ApexPages.StandardController sc = new ApexPages.standardController(rbatch); 
        evEventEmailConfig_Controller myPageCon = new evEventEmailConfig_Controller(sc);
        //myPageCon.record.EMail_Template__c = template.Id;
        
        // Set up data in controller attributes
        List<SelectOption> templates = myPageCon.templates;
        List<SelectOption> addresses =  myPageCon.orgWideAddresses;
        List<SelectOption> events = myPageCon.events;
        
        
        // Get the delegates for each event;
        Map<Id, List<Delegate__c>> delegatesByEventId  = selectDelegates();
        // Test delegate validation for changed delegate
        myPageCon.selectEvent = true;
        Id previousDelegateId = rbatch.Delegate__c;
        // extract a bad delegate
        Delegate__c invalidDelegate = null;
        Id anotherEventId;
        for (Id eventId : delegatesByEventId.keySet()) {
            List<Delegate__c> delegates = delegatesByEventId.get(eventId);
            if (delegates != null && delegates.size() >=2) {
                if (eventId != rbatch.Event__c) {
                    invalidDelegate = delegatesByEventId.get(eventId)[1];
                    anotherEventId = eventId;
                    break;
                } 
            }    
        }
        
        Boolean shouldSucceed = false;
        
        // This should not save the record - delegate event and schedule event do not match
        System.assert(invalidDelegate != null, 'Expected to find an invalid delegate');
        myPageCon.record.Delegate__c = invalidDelegate.Id;
        System.assert( myPageCon.record.Delegate__c != previousDelegateId, 'Expected delegate to change');
        String message = myPageCon.validateDelegate();
        System.assert(message != null, 'Expected delegate validation to fail');
        testDoSave(myPageCon, shouldSucceed);
       
        
        // This should not save the record - can't have both email and sms
        myPageCon.record.eMail_Template__c = 'Test SMS';
        myPageCon.record.SMS_Text__c = 'Test SMS';
       testDoSave(myPageCon, shouldSucceed);
        
        // This should not save the record - if email must have send from
        myPageCon.record.eMail_Template__c = 'Test Email';
        myPageCon.record.SMS_Text__c = null;
        myPageCon.record.Send_From__c = null;
        testDoSave(myPageCon, shouldSucceed);
        
         // This should not save the record - if sms must not have send from
        myPageCon.record.eMail_Template__c = null;
        myPageCon.record.SMS_Text__c = 'Test SMS';
        myPageCon.record.Send_From__c = evEventEmailConfig_Controller.EMAIL_VALUE_LOGGED_IN_USER;
        testDoSave(myPageCon, shouldSucceed);
        
        
        // This should not save the record - must have either email or sms
        myPageCon.record.eMail_Template__c = null;
        myPageCon.record.SMS_Text__c = null;
        testDoSave(myPageCon, shouldSucceed);
        
        // This should not save the record - must have either email or sms
        myPageCon.record.eMail_Template__c = '';
        myPageCon.record.SMS_Text__c = '';
        testDoSave(myPageCon, shouldSucceed);
        
        // This should not save the record. 
        myPageCon.record.Send_From__c = 'dasdad';
        testDoSave(myPageCon, shouldSucceed);
        
       // This should not save the record - A DML exception should be thrown and caught.
       myPageCon.record.Delegate_Attendance_Status__c = 'Not defined';
       testDoSave(myPageCon, shouldSucceed);
       
    }
    
    
    /**
     * Selects EM_Event_Email_Configuration__c records.
     * Should be refactored once Selector framework is in place.
     * @return List<EM_Event_Email_Configuration__c>
     */ 
    private static List<EM_Event_Email_Configuration__c> selectEventEmailConfigurationRecords() {
       return [SELECT Id FROM EM_Event_Email_Configuration__c];
    }
    
    /**
     * Instantiates the controller and tests the doSave method.
     * @param eventEmailSchedule EM_Event_Email_Configuration__c to be saved
     * @param sc ApexPages.StandardController
     * @param shouldSucceed Boolean
     * 
     */ 
    private static void testDoSave(EM_Event_Email_Configuration__c eventEmailSchedule, ApexPages.StandardController sc, Boolean shouldSucceed) {
        update eventEmailSchedule;
        evEventEmailConfig_Controller myPageCon = new evEventEmailConfig_Controller(sc);
        testDoSave(myPageCon, shouldSucceed);
    }    
        
    /**
     * Tests the doSave method.
     * @param myPageCon evEventEmailConfig_Controller
     * @param shouldSucceed  Boolean
     * 
     */ 
    private static void testDoSave(evEventEmailConfig_Controller myPageCon,  Boolean shouldSucceed) {
        PageReference pageReference = myPageCon.doSave();
        Boolean havePageReference = (pageReference != null);
        System.assert(havePageReference == shouldSucceed, 'Check for PageReference null');
    }
    
    /**
     * Creates an Event__c 
     * @param name String
     * @param active Boolean
     * @return Event__c
     */ 
    private static Event__c createEvent(String name, Boolean active) {
        Event__c event  = new Event__c(); 
        event.Name = name;
        event.Active__c = active;
        event.Capacity__c = 2;
        event.Start_Date__c = Date.today();
        event.End_Date__c = Date.today() + 3;
        event.Online_Processing__c = 'Do Not Create Opportunity';
        event.Registration_Process__c = 'Simple';
        event.I_have_read_Absa_Event_Governance__c = true;
        return event;
    }
    
    
    private static Contact createAndPersistContact() {
        Contact contact = new Contact(FirstName = 'Test', LastName = 'EmailSchedule');
        insert contact;
        return contact;
    }
    
    /**
     * Creates Delegate__c instances
     * @param event Event__c
     * @param count Integer the number of instances to create
     * @return List<Delegate__c> 
     */ 
    private static List<Delegate__c> createDelegates(Event__c event, Id contactId, Integer count) {
        List<Delegate__c> delegates = new List<Delegate__c>();
        for (Integer i = 0; i < count; i++) {
            Delegate__c delegate = new Delegate__c(Event__c = event.Id, Contact__c =  contactId);
            delegates.add(delegate);
        }
        return delegates;
    }
    
    
    /**
     * Selects an EM_Event_Email_Configuration__c record.
     * @return EM_Event_Email_Configuration__c
     */
    private static EM_Event_Email_Configuration__c selectEventEmailConfiguration() {
        List<EM_Event_Email_Configuration__c> eventEmailConfigurations = 
            [SELECT Id, 
                    Event__c,
                    Delegate__c
                    FROM EM_Event_Email_Configuration__c
                    LIMIT 1];
        System.assert(eventEmailConfigurations.size() == 1, 'Expected 1 EM_Event_Email_Configuration__c record') ;
        return eventEmailConfigurations[0];
    }
    
    
    /**
     * Selects Delegate__records.
     * @return List<Delegate__c>
     */
    private static Map<Id, List<Delegate__c>> selectDelegates() {
        Map<Id, List<Delegate__c>> delegatesByEventId = new Map<Id, List<Delegate__c>>();
        List<Delegate__c> delegates = 
            [SELECT Id, 
                    Event__c
                    FROM Delegate__c
                    ORDER BY CreatedDate
                    ];
        System.assert(delegates.size() > 1, 'ExpectedDelegate records') ;
        for (Delegate__c delegate : delegates) {
            List<Delegate__c> delegateList = delegatesByEventId.get(delegate.Event__c);
            if (delegateList == null) {
                delegateList = new List<Delegate__c>();
                delegatesByEventId.put(delegate.Event__c, delegateList);
            }
            delegateList.add(delegate);
        }
        return delegatesByEventId;
    }
}