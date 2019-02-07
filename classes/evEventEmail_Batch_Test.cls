@istest
public class evEventEmail_Batch_Test 
{
    static testMethod void evEventEmail_Batch_Test() 
    {  
        evTestDataGenerator generator = new evTestDataGenerator();
        
        evEventEmail_Batch testbatch3 =  new evEventEmail_Batch(); 
        Account account = new Account();
        account.Name='Test Account ZxZ';
        account.BillingStreet='Test Street';
        account.BillingCity = 'Test City';
        account.BillingCountry='Canada';
        account.BillingState='Ontario';
        account.BillingPostalCode='9111';
        
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName ='Contact';
        contact.AccountId = account.Id;
        contact.email='sample1@nowhere.com';
        contact.mobilephone = '27 11 1234567';
        insert contact;
        
        Contact contact2 = new Contact();
        contact2.FirstName = 'Test 2';
        contact2.LastName ='Contact 2';
        contact2.AccountId = account.Id;
        contact2.mobilephone = '27 11 1234567';
        contact2.email='sample2@nowhere.com';
        
        insert contact2;
        
        Event__c event  = new Event__c(); 
        event.Name = 'Test Event';
        event.Capacity__c = 2;
        event.Start_Date__c = Date.today();
        event.End_Date__c = Date.today()+3;
        event.Online_Processing__c = 'Do Not Create Opportunity';
        //event.Registration_Confirmation_Fields__c = 'First Name';
        event.Registration_Process__c = 'Simple';
        event.I_have_read_Absa_Event_Governance__c = true;
        insert event;       
        
        Delegate__c delegate = new Delegate__c();
        delegate.Status__c = null;
        delegate.Invitation_Status__c = 'Approved';
        delegate.Event__c = event.Id;
        delegate.Contact__c = contact.Id; 
        insert delegate;    
        
        Delegate__c delegate2 = new Delegate__c();
        delegate.Invitation_Status__c = 'Approved';
        delegate2.Status__c = 'Attended';
        delegate2.Event__c = event.Id;
        delegate2.Contact__c = contact2.Id; 
        insert delegate2;       
        
        EM_Event_Email_Configuration__c emailConfig = new EM_Event_Email_Configuration__c();
        emailconfig.Event__c = event.Id;
        emailconfig.Active__c = true;
        //DH this should be the ID of an org wide email address record.... //emailConfig.Send_From__c= 'test@test.com';
        emailconfig.Send_From__c = 'LoggedInUser';
        emailconfig.Delegate_Attendance_Status__c ='Attended';
        emailconfig.Delegate_Invitation_Status__c = 'Proposed';
        emailconfig.Delegate_Registration_Status__c ='Pending';
        emailconfig.Delegate_RSVP_Status__c ='Invited';
        emailconfig.Survey_Status__c = 'Both';

        emailConfig.Send_From_Name__c = 'Test'; 
        emailconfig.Start_Days__c = 4;
        emailconfig.Start_Before_After__c = 'Before Start Date';
        emailconfig.Start_Send_Time__c= '00:00';

        emailconfig.Stop_Days__c = 4;
        emailconfig.Stop_Before_After__c= 'After End Date';
        emailconfig.Stop_Send_Time__c= '23:30';
        emailconfig.Stop_Send_Date__c =  date.today().adddays(1);

        insert emailconfig;


        Test.startTest();
        
        evEventEmail_Batch testbatch =  new evEventEmail_Batch(); 
        
        database.executeBatch(testbatch);



/*        
       EM_Event_Email_Configuration__c emailConfig2 = new EM_Event_Email_Configuration__c();
        emailconfig2.Event__c = event.Id;
        emailconfig.Start_Days__c = 4;
        emailconfig.Start_Before_After__c = 'Before';
        emailconfig.Delegate_Attendance_Status__c ='Attended';
        emailconfig2.Survey_Status__c = 'Both';
        emailconfig.Delegate_Attendance_Status__c ='Attended';
        emailconfig.Delegate_Invitation_Status__c ='Approved';
        emailconfig.Delegate_Registration_Status__c ='Pending';
        emailconfig.Delegate_RSVP_Status__c ='Invited';
        emailconfig2.SMS_Text__c = 'Test';
        emailconfig2.Active__c = true;
        emailconfig2.Start_Days__c = 0;
        emailconfig2.Start_Days__c = 5;
        emailconfig2.Send_From__c= 'test@test.com';
        emailconfig2.Send_From_Name__c = 'Test'; 
        emailconfig2.Start_Before_After__c = 'Before Start Date';
        emailconfig2.Start_Send_Time__c= '00:00';
        emailconfig2.Stop_Before_After__c= 'After End Date';
        emailconfig2.Stop_Send_Time__c= '23:30';
        insert emailconfig2;
        evEventEmail_Batch testbatch2 =  new evEventEmail_Batch(); 
        database.executeBatch(testbatch2);

*/
        Test.stopTest();
    }
    
     static testMethod void evSingleEventEmail_Batch_Test() 
    {  
        evTestDataGenerator generator = new evTestDataGenerator();
        
        evEventEmail_Batch testbatch3 =  new evEventEmail_Batch(); 
        Account account = new Account();
        account.Name='Test Account ZxZ';
        account.BillingStreet='Test Street';
        account.BillingCity = 'Test City';
        account.BillingCountry='Canada';
        account.BillingState='Ontario';
        account.BillingPostalCode='9111';
        
        insert account;
        
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName ='Contact';
        contact.AccountId = account.Id;
        contact.email='sample1@nowhere.com';
        contact.mobilephone = '27 11 1234567';
        insert contact;
        
        Contact contact2 = new Contact();
        contact2.FirstName = 'Test 2';
        contact2.LastName ='Contact 2';
        contact2.AccountId = account.Id;
        contact2.mobilephone = '27 11 1234567';
        contact2.email='sample2@nowhere.com';
        
        insert contact2;
        
        Event__c event  = new Event__c(); 
        event.Name = 'Test Event';
        event.Capacity__c = 2;
        event.Start_Date__c = Date.today();
        event.End_Date__c = Date.today()+3;
        event.Online_Processing__c = 'Do Not Create Opportunity';
        //event.Registration_Confirmation_Fields__c = 'First Name';
        event.Registration_Process__c = 'Simple';
         event.I_have_read_Absa_Event_Governance__c = true;
        insert event;       
        
        Delegate__c delegate = new Delegate__c();
        delegate.Status__c = null;
        delegate.Invitation_Status__c = 'Approved';
        delegate.Event__c = event.Id;
        delegate.Contact__c = contact.Id; 
        insert delegate;    
        
        Delegate__c delegate2 = new Delegate__c();
        delegate.Invitation_Status__c = 'Approved';
        delegate2.Status__c = 'Attended';
        delegate2.Event__c = event.Id;
        delegate2.Contact__c = contact2.Id; 
        insert delegate2;       
        
        EM_Event_Email_Configuration__c emailConfig = new EM_Event_Email_Configuration__c();
        EM_Event_Email_Configuration__c emailConfig2 = new EM_Event_Email_Configuration__c();
        EM_Event_Email_Configuration__c emailConfig3 = new EM_Event_Email_Configuration__c();
        
        emailconfig.Event__c = event.Id;
        emailconfig.Active__c = true;
        //DH this should be the ID of an org wide email address record.... //emailConfig.Send_From__c= 'test@test.com';
        emailconfig.Send_From__c = 'LoggedInUser';
        emailconfig.Delegate_Attendance_Status__c ='Attended';
        emailconfig.Delegate_Invitation_Status__c = null;
        emailconfig.Delegate_Registration_Status__c =null;
        emailconfig.Delegate_RSVP_Status__c =null;
        emailconfig.Survey_Status__c = 'Both';

        emailConfig.Send_From_Name__c = 'Test'; 
        emailconfig.Start_Days__c = 4;
        emailconfig.Start_Before_After__c = 'Before Start Date';
        emailconfig.Start_Send_Time__c= '00:00';

        emailconfig.Stop_Days__c = 4;
        emailconfig.Stop_Before_After__c= 'After End Date';
        emailconfig.Stop_Send_Time__c= '23:30';
        emailconfig.Stop_Send_Date__c =  date.today().adddays(1);
        
        emailconfig.Attach_Speaker_Schedule__c =  true;

        insert emailconfig;
        
        emailconfig2 = emailconfig.clone(false);
        emailconfig2.Attach_Speaker_Schedule__c =  false;
		emailconfig2.Attach_Delegate_Schedule__c =  true;
        
        insert emailconfig2;
        
        emailconfig3 = emailconfig.clone(false);
        emailconfig3.SMS_Text__c = 'Test SMS';
        
        insert emailconfig3;
        
        Test.startTest();
        
        database.executebatch(new evEventEmail_Batch(emailconfig.id),100);
        database.executebatch(new evEventEmail_Batch(emailconfig2.id),100);
        database.executebatch(new evEventEmail_Batch(emailconfig3.id),100);

        Test.stopTest();

    }
}