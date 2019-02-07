/**
 * 
 * 26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist 
 * 
 * */
@Istest
public class BxdMatterSpend_test {  
    public static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();  
    public static Account 				    TestAccount;
    public static advpm__Matter__c 		    TestMatter;
    public static DateTime todaysDate_nextMonth = System.now().addMonths(1);
    
    public static testmethod void testSpendDocumentFolderCreation(){
        setup();
        test.StartTest();
        Matter_Spend_Document__c TestSpendDocument = new Matter_Spend_Document__c(
            Matter__c = TestMatter.Id,
            Law_Firm__c = TestAccount.Id,
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '123',
            BU_Corporate_Code__c = '123'
        );
        insert TestSpendDocument;
        test.StopTest();   
    }
   
    public static void setup(){
        //USER RECORD
        User TestUser = createUser('Barclays Standard User','AdvoUser@fakeddomain11235z.co.za');
        insert TestUser;
        
        //ACCOUNT
        TestAccount = new Account
        (
            Name = 'The name for testing '+ generateRandomString(6), 
            Type = 'Client',
            Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'),
            RecordTypeId = mapAccountRecordTypes.get('On/Off Panel Law Firm').getRecordTypeId() //Added
        );
        Insert TestAccount; 
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
    }
    
        //New user
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
                   Username = username,
                   Can_Approve_Spend_Schedules__c = true
           );
        } 
        catch(Exception e) 
        {
            system.assertEquals('List has no rows for assignment to SObject Profile', e.getMessage());
        }
        return newUser;
    } 
    
    public static testmethod void testCreatePermission(){
        setup();
        
        Matter_Spend_Schedule__c schedule = new Matter_Spend_Schedule__c(
            Status__c = 'Approved'
        );
        insert schedule;
        
        Matter_Spend_Document__c TestSpendDocument = new Matter_Spend_Document__c(
            Matter__c = TestMatter.Id,
            Law_Firm__c = TestAccount.Id,
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '123',
            BU_Corporate_Code__c = '123',
            Matter_Spend_Schedule__c = schedule.Id
        );
        insert TestSpendDocument;
        test.StartTest();
        BxdMatterSpendScheduleService scr = new BxdMatterSpendScheduleService();
        scr.createBoxFolderSync(TestSpendDocument.Id);
        BxdMatterSpendScheduleService.createViewerPermission(schedule);
        test.StopTest(); 
        
    }
    
    public static testmethod void testUpdateRemoveFromSchedule(){
        setup();
        
        Matter_Spend_Schedule__c schedule = new Matter_Spend_Schedule__c(
            Status__c = 'Approved'
        );
        insert schedule;
        
        Matter_Spend_Document__c TestSpendDocument = new Matter_Spend_Document__c(
            Matter__c = TestMatter.Id,
            Law_Firm__c = TestAccount.Id,
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '123',
            BU_Corporate_Code__c = '123',
            Matter_Spend_Schedule__c = schedule.Id
        );
        insert TestSpendDocument;
        test.StartTest();
        TestSpendDocument.Matter_Spend_Schedule__c = null;
        Update TestSpendDocument;
        test.StopTest(); 
        
    }
    
    public static testmethod void testUpdateAddToSchedule(){
        setup();
        Matter_Spend_Document__c TestSpendDocument = new Matter_Spend_Document__c(
            Matter__c = TestMatter.Id,
            Law_Firm__c = TestAccount.Id,
            Total_Amount_Excl_VAT__c = 100,
            Total_Amount_Non_VATable__c = 50,
            GL_Account__c = '123',
            BU_Corporate_Code__c = '123'
        );
        insert TestSpendDocument;
        test.StartTest();
        Matter_Spend_Schedule__c schedule = new Matter_Spend_Schedule__c(
            Status__c = 'Approved'
        );
        insert schedule;
        
        TestSpendDocument.Matter_Spend_Schedule__c = schedule.Id;
        Update TestSpendDocument;
        test.StopTest(); 
        
    }
    
    public static testmethod void testBoxLink(){
        setup();
        
        Matter_Spend_Schedule__c schedule = new Matter_Spend_Schedule__c(
            Status__c = 'Approved'
        );
        insert schedule;
        
        test.StartTest();
        BxdMatterSpendScheduleService.getBoxFolderLink(schedule);
        test.StopTest(); 
        
    }
    
    //Generate String
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'; 
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length()); 
            randStr += chars.substring(idx, idx+1);
        }
        return randStr; 
    }
}