//RN - 2017-08-23 : Add new fields to the Event object
@isTest 
public class evTestDataGenerator 
{
    
    public Account                      TestAccount;
    public Id                           TestpricebookId;
    public Product2                     TestProduct2;
    public PricebookEntry               TestPricebookEntry;
    public User                         TestUser;
    public Attachment                   TestAttachment;
    public Contact                      TestContact;
    Public Event__c                     TestEvent;
    Public Event_Booking__c             TestEventBooking;
    Public Delegate__c                  TestDelegate;
    Public Event_Session__c             TestSession;
    Public Event_Session__c             TestSession2;
    Public Event_Session_Booking__c     TestSessionBooking;
    Public Product2                     Testproduct;
    Public EM_Printer__c                TestPrinter;
    Public Event_Configuration__c       TestBadgeEventConfig;
    Public Event_Team_Member__c			TestEventTeamMemmber;
    
    
    public static Map <String, Schema.RecordTypeInfo> mapEventConfigurationRecordTypes = Event_Configuration__c.sObjectType.getDescribe().getRecordTypeInfosByName();  
    
    public evTestDataGenerator()
    {
        TestAccount = new Account
            (
                Name='Bhalisa Delegate Private Account', 
                BillingStreet='Test Street', 
                BillingCity = 'Test City', 
                BillingPostalCode='9111', 
                BillingCountryCode='ZA'
            );
        insert TestAccount;
        
        
        
        TestContact = new Contact
            (
                FirstName = 'Existing',
                LastName ='Contact',
                AccountId = TestAccount.Id,
                email = 'newsomeone@somewhere.com'
            );
        
        insert TestContact;
        
        Testproduct = new Product2
            (
                Name = 'Test Product',
                IsActive = true, 
                Family = 'Training', 
                ProductCode = 'My Code',
                CurrencyIsoCode = 'ZAR'
            );
        insert Testproduct;
        

        Id standardPricebookId = test.GetStandardPriceBookId();
        
        TestPricebookEntry = new PricebookEntry
            (
                UseStandardPrice = false, 
                Pricebook2Id = standardPricebookId, 
                IsActive = true, 
                Product2Id = Testproduct.Id, 
                UnitPrice = 200.00, 
                CurrencyIsoCode = 'ZAR'
            );
        insert TestPricebookEntry;
        
        
        TestBadgeEventConfig =  new Event_Configuration__c
            (
                name = 'Test',
                Badge_Gutter__c = 20,
                Badge_Optional__c = 'Test',
                Badge_Title__c = 'Test',
                Badge_Width__c  = 20,
                Badge_X__c  = 20,
                Badge_Y__c  = 20,
                recordTypeId = mapEventConfigurationRecordTypes.get('Event Badges').getRecordTypeId() 
            );
        
        Insert TestBadgeEventConfig;
        
        TestEvent  = new Event__c
            (
                Name = 'Test Event', 
                Capacity__c = 2, 
                Start_Date__c = Date.today(),  
                End_Date__c = Date.today()+3,
                Discount_2__c = 10, 
                Discount__c = 5, 
                Discount_Threshold__c = 1, 
                Discount_Threshold_2__c = 2, 
                Online_Processing__c = 'Create Opportunity; Optional Payment' ,
                Currencyisocode='ZAR',
                Allow_Booking_Online_for_New_Customers__c = true,
                ID_Number_Passport_at_Booking__c = 'No',
                Use_Ticket_Types_Batches__c = True,
                City__C = 'Johannesburg',
                Country__c = 'South Africa',
                Booking_confirmation_fields__C = 'Name',
                Booking_confirmation_mandatory_fields__C = 'Name',
                Dietary_Requirements_Requiring_Payment__c =  'Kosher',
                Check_In_Confirmation_Fields__c = 'Name',
                Check_In_Confirmation_Mandatory_Fields__c =  'Company',
                Registration_Process__c = 'Simple',
                Registration_Type__c = 'Personal Invitation Only',
                Badge_Style__c = TestBadgeEventConfig.id,
                I_have_read_Absa_Event_Governance__c  = true
            );
        insert TestEvent;
        
        TestEventBooking = new Event_Booking__c
            (
                Event__c=TestEvent.Id
            );
        insert TestEventBooking; 
        
        
        TestEventTeamMemmber = new Event_Team_Member__c
            (
                Event__c=TestEvent.Id,
                Event_Team_Member_Role__c = 'Host',
                Team_Member__c = system.UserInfo.getuserid()
            );
        
        //insert TestEventTeamMemmber;
        
        TestDelegate = new Delegate__c
            (
                Event_Booking__c = TestEventBooking.id,
                Contact__C =  TestContact.id,
                Status__c = 'Attended', 
                Event__c=TestEvent.Id
            );
        insert TestDelegate;   
        
        TestPrinter = new EM_Printer__c
            (
                name = 'Printer',
                Type__c = 'Initiate from Salesforce',
                URL__c = 'http://localhost'
            );
        insert Testprinter;
        
        TestSession = new Event_Session__c
            (
                Name = 'Test Session',
            	Event_Function__c = TestEvent.Id,
                Type__c = 'Group',
                Date__c = Date.today(),
                Start_Time__c =  time.newInstance(00, 000 , 000, 000),
                end_time__c =  time.newInstance(00, 000 , 000, 000)
            );
        
        insert TestSession;
        
         TestSession2 = new Event_Session__c
            (
                Name = 'Test Session',
            	Event_Function__c = TestEvent.Id,
                Type__c = 'Group',
                Date__c = Date.today(),
                Start_Time__c =  time.newInstance(00, 000 , 000, 000),
                end_time__c =  time.newInstance(00, 000 , 000, 000)
            );
        
        insert TestSession2;
        
        TestSessionBooking = new Event_Session_Booking__c 
            (
                Session__c = TestSession.Id,
                Delegate__c = TestDelegate.Id,
                Invitation_Status__c = 'Confirmed',
                isSpeaker__c = false
            );
        
        insert TestSessionBooking;
        
    } 
}