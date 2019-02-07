/**
 * 
 * 26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist
 * 
 * */
@isTest
public class BxdMatterDealService_test {
    public static Map <String, Schema.RecordTypeInfo> mapParticipantRecordTypes = advpm__Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName();  
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();   
    public static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();    
    public static advpm__Matter__c TestMatter;
    public static User TestUser;
    public static DateTime todaysDate_nextMonth = System.now().addMonths(1);
    
    public static testMethod void removeLegalHoldPolicyAssignmentWithInvalidBoxLegalHoldAssignmentId_ShouldNotUpdateMatter(){
        // Setup Fixture
        BXDtesclassdata.setupBoxFolder(); 
        setupMatter();
        //Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();   
        
        // Expectations
        String expectedBoxLegalHoldAssignmentId = '';
        
        // Exercise SUT
        Test.startTest();
        BxdMatterDealService.removeLegalHoldPolicyAssignment(TestMatter.Id);
        String actualBoxLegalHoldAssignmentId = TestMatter.Box_Legal_Hold_Assignment_Id__c;
    }
    
    public static testMethod void removeLegalHoldPolicyAssignmentWithValidBoxLegalHoldAssignmentId_ShouldNotUpdateMatter(){
        // Setup Fixture
        BXDtesclassdata.setupBoxFolder();
        setupMatter();
        //Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();   
        
        
        // Expectations        
        String expectedBoxLegalHoldAssignmentId = 'irrelevantId';
        
        // Exercise SUT
        Test.startTest();
        Id matterId = TestMatter.Id;
        BxdMatterDealService.removeLegalHoldPolicyAssignment(matterId);
        String actualBoxLegalHoldAssignmentId = TestMatter.Box_Legal_Hold_Assignment_Id__c;
        advpm__Matter__c matterAfterUpdate = Database.query('SELECT Box_Legal_Hold_Assignment_Id__c FROM advpm__Matter__c WHERE Id =:matterId');

        Test.stopTest();
    }
    
    private static void setupFixture(){
        // Mockout BoxPlatformApiConnection authenticate
        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));
    }
    
    public static void setupBoxFolderStructure(){
        	Box_Folder_Structure__c  LegalInstance = new Box_Folder_Structure__c();
            LegalInstance.Name='Legal Instance';
            LegalInstance.Custom__c = false;
            LegalInstance.Folder_Level__c = 3;
            LegalInstance.Folder_Name__c = '';
            LegalInstance.Folder_Type__c = 'Legal';
            LegalInstance.Main_Record_Type__c = 'Legal; Legal Quote';
            LegalInstance.Legal_Hold_Policy_Id__c = '627385';
            LegalInstance.Legal_Hold_Policy_Name__c = 'Legal Management';
            LegalInstance.Parent_Lookup__c = '';
            LegalInstance.Static_Folder__c = true;
            LegalInstance.Webhook_Triggers__c = '';
            LegalInstance.Webhook_URL__c = '';
			Insert LegalInstance;
        
        Box_Folder_Structure__c  LitigationInstance = new Box_Folder_Structure__c();
            LitigationInstance.Name='Litigation Instance';
            LitigationInstance.Custom__c = false;
            LitigationInstance.Folder_Level__c = 3;
            LitigationInstance.Folder_Name__c = '';
            LitigationInstance.Folder_Type__c = 'Litigation Matter';
            LitigationInstance.Main_Record_Type__c = 'Litigation Matter';
            LitigationInstance.Legal_Hold_Policy_Id__c = '627385';
            LitigationInstance.Legal_Hold_Policy_Name__c = 'Legal Management';
            LitigationInstance.Parent_Lookup__c = '';
            LitigationInstance.Static_Folder__c = true;
            LitigationInstance.Webhook_Triggers__c = '';
            LitigationInstance.Webhook_URL__c = '';
			Insert LitigationInstance;
        
        Box_Folder_Structure__c  LegalHold = new Box_Folder_Structure__c();
            LegalHold.Name='Legal - Legal Hold';
            LegalHold.Custom__c = false;
            LegalHold.Folder_Level__c = 3;
            LegalHold.Folder_Name__c = '';
            LegalHold.Folder_Type__c = 'Read-Only Legal Hold (Legal RT)';
            LegalHold.Main_Record_Type__c = 'Legal RT';
            LegalHold.Legal_Hold_Policy_Id__c = '627385';
            LegalHold.Legal_Hold_Policy_Name__c = 'Legal Management';
            LegalHold.Parent_Lookup__c = '';
            LegalHold.Static_Folder__c = true;
            LegalHold.Webhook_Triggers__c = '';
            LegalHold.Webhook_URL__c = '';
			Insert LegalHold;
        
        Box_Folder_Structure__c  LitigationLegalHold = new Box_Folder_Structure__c();
            LitigationLegalHold.Name='Litigation - Legal Hold';
            LitigationLegalHold.Custom__c = false;
            LitigationLegalHold.Folder_Level__c = 3;
            LitigationLegalHold.Folder_Name__c = '';
            LitigationLegalHold.Folder_Type__c = 'Read-Only Legal Hold (Litigation RT)';
            LitigationLegalHold.Main_Record_Type__c = 'Litigation RT';
            LitigationLegalHold.Legal_Hold_Policy_Id__c = '627385';
            LitigationLegalHold.Legal_Hold_Policy_Name__c = 'Legal Management';
            LitigationLegalHold.Parent_Lookup__c = '';
            LitigationLegalHold.Static_Folder__c = true;
            LitigationLegalHold.Webhook_Triggers__c = '';
            LitigationLegalHold.Webhook_URL__c = '';
			Insert LitigationLegalHold;
    }
    
    public static testMethod void testCreateLegalHoldPolicyAssignment(){
        setupBoxFolderStructure();
        BXDtesclassdata.setupBoxFolder();
        setupMatter();
        //Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();   
        
        Test.startTest();
        TestMatter.advpm__Legal_Hold__c = true;
        Update TestMatter;
        Test.stopTest();
    }
         
    public static testMethod void testCreateBoxFolderSynchronously(){
        // Exercise SUT
        BXDtesclassdata.setupBoxFolder();
        setupMatter();
        //Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();  
        
        Test.startTest();
        BxdMatterDealService.createBoxFolderSync(TestMatter.Id);
        Test.stopTest();
    }
    
    public static testMethod void testCreateParticipantCollaberation(){
        // Exercise SUT
        BXDtesclassdata.setupBoxFolder();
        setupMatter();
        //Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();  
        
        List<advpm__Participant__c> testParticipants = new List<advpm__Participant__c>();
        Contact c = CSC_TestDataFactory.getDefaultEmailSupportContact();
        Insert c;
        
        Test.startTest();
        advpm__Participant__c participant = createParticipant(TestMatter.Id,'Part2', null, 'Legal');
        participant.advpm__Contact__c = c.Id;
        testParticipants.add(createParticipant(TestMatter.Id,'Part3', TestUser.Id, 'Legal'));
        testParticipants.add(participant);
        insert testParticipants;
        Test.stopTest();
    }
    
	public static advpm__Participant__c createParticipant(String matterId, String name, String userId, String role)
    {
        return new advpm__Participant__c(
            advpm__Matter__c = matterId,
            Name = name,
            advpm__Staff__c = userId,
            advpm__Role__c = role,
            RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId()
        );
    }
    
    public static User createUser(string profile, string username)
    {
        username = Math.random()+ username;
        user newUser;
        try 
        {
            Profile userProfile = [select Name from Profile where Name = :profile];
            newUser = new User(Alias = 'test',
                               Email = 'one@test.sbsa.co.za',
                               Emailencodingkey = 'UTF-8',
                               Lastname = profile + ' User',
                               Languagelocalekey = 'en_US',
                               City = 'Johannesburg',
                               Country = 'South Africa',
                               Division__c = 'Barclays',
                               BRID__c = String.valueOf(Math.random()).left(9),
                               Localesidkey = 'en_US',
                               Profileid = userProfile.Id,
                               Timezonesidkey = 'America/Los_Angeles',
                               Username = username);
        } 
        Catch(Exception e) 
        {
            system.assertEquals('List has no rows for assignment to SObject Profile', e.getMessage());
        }
        return newUser;
    } 
    
    Public static void setupMatter(){
        
        TestUser = createUser('Barclays Standard User','AdvoUser@fakeddomain11235z.co.za');
        insert TestUser;
         /**
        * ACCOUNTS
        **/
        List<Account> accounts = new List<Account>();

       Account TestAccount = new Account
        (
            Name = 'testCreateBoxFolderSynchronously' , 
            Type = 'Client',
            Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'),
            SDS__c = 'test',
            RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId() //Added
        );
        insert TestAccount; 
        
        //PRODUCT
        Product2 TestProduct2 = new Product2
        (
            Name = 'Corporate Finance',
            ProductCode = 'Pro-X',
            isActive = true
        );
        insert TestProduct2;
        
        //PRODUCT LEVEL 2 
        Product_Level_2__c TestProductLevel2 =  new Product_Level_2__c
        (
            Name = 'SUB100',
            Active__c = true,
            Product__c = TestProduct2.id
        );
        insert TestProductLevel2;
        
        //MATTER
       TestMatter = new advpm__Matter__c 
        (
            advpm__Primary_Account__c = TestAccount.id,
            Name = 'Test',
            Standard__c = true,
            advpm__Status__c = 'Open',
            advpm__Type__c='Syndicated',
            Start_Date__c = date.today(),
            RecordTypeId = mapMatterRecordTypes.get('Deal').getRecordTypeId(),
            Division__c = 'CIB',
            Coverage_Area__c = 'Corporate Banking',
            Product_Area__c = 'Corporate Finance',
            Product2__c = TestProductLevel2.Id,
            OwnerId = TestUser.Id
        );
        insert TestMatter; 
        
        //settings
        box__Folder_Details__c folderDetails = new box__Folder_Details__c 
        (
            Name = 'Disclaimer',
            box__FolderId__c = '123456789'
        );
        insert folderDetails;
    }
}