@isTest
public class BxdExternalCollaborationSchedule_test {
    private static Map <String, Schema.RecordTypeInfo> mapAccountRecordTypes = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
    private static Map <String, Schema.RecordTypeInfo> mapMatterRecordTypes = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName();   
    private static Date todaysDate; 
    
    static testmethod void testSchedulerExternalCollaboration() {
        String CRON_EXP = '0 10 * * * ?';
        
        createTestRecords(2, 2);
        
        Test.startTest();       
        String jobId = BxdExternalCollaborationSchedule.scheduleTheBatch(CRON_EXP);
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
        
        Test.stopTest();
        // Add assert here to validate result
    }
    
    static testmethod void testCreateExternalCollaborationFolder() {
        List<External_Collaboration_Request__c> requests = createTestRecords(2, 2);
        
        Test.startTest();  
        Set<String> requestSet = new Set<String>();
        for(External_Collaboration_Request__c request : requests){
            requestSet.add(request.Id);
        } 
        
        BxdExternalCollaborationService.createApprovedExternalCollaborations(requestSet);        
        Test.stopTest();
    }
    
    public static List<External_Collaboration_Request__c> createTestRecords(Integer numCollabRequests, Integer numContactsPerAccount) {
        // Create box folder structures
        BXDtesclassdata.setupFolder();
        List<External_Collaboration_Request__c> returnedList = new List<External_Collaboration_Request__c>();     
        
        todaysDate = System.Today();
        DateTime todaysDate_nextMonth = System.now().addMonths(1);
        
        //FIRST SETUP - REQUEST OF TYPE CONTACTS
        //Create account
        List<Account> accounts = new List<Account>();
        Account TestAccount = new Account
            (
                Name = generateRandomString(6),
                Type = 'Client',
                Financial_Year_End_Month__c = todaysDate_nextMonth.format('MMMM'), 
                SDS__c = 'test',
                RecordTypeId = mapAccountRecordTypes.get('Prospect').getRecordTypeId() //Added
            );
        accounts.add(TestAccount); 
        
        insert accounts;
        
        //Product - Level 1
        TMG_Product_Level_1__c TestProductLevel1 = new TMG_Product_Level_1__c
        (
            Name = 'Corporate Banking',
            Active__c = true
        );
        insert TestProductLevel1;
        
        //Product - Level 2
        TMG_Product_Level_2__c TestProductLevel2 = new TMG_Product_Level_2__c
        (
            Name = 'Corporate Finance',
            Active__c = true,
            TMG_Product_Level_1__c = TestProductLevel1.id
        );
        insert TestProductLevel2;
        
        //Product - Level 3
        TMG_Product_Level_3__c TestProductLevel3 = new TMG_Product_Level_3__c
        (
            Name = 'SUB100',
            Active__c = true,
            TMG_Product_Level_2__c = TestProductLevel2.id 
        );
        insert TestProductLevel3;
        
        //Matter
        advpm__Matter__c TestMatter = new advpm__Matter__c 
        (
            advpm__Primary_Account__c = TestAccount.id,
            Name = 'Test',
            Standard__c = true,
            advpm__Status__c = 'Open',
            advpm__Type__c='Syndicated',
            External_Collaboration_Id__c = '1838383',
            Start_Date__c = date.today(),
            RecordTypeId = mapMatterRecordTypes.get('Deal').getRecordTypeId(),
            Division__c = 'CIB',
            TMG_Product_Level_1__c = TestProductLevel1.Id,
            TMG_Product_Level_2__c = TestProductLevel2.Id,
            TMG_Product_Level_3__c = TestProductLevel3.Id,
            OwnerId = UserInfo.getUserId()
        );
        insert TestMatter;
        
        //Create contacts per account
        List<Contact> contacts = new List<Contact>();
        for (Integer j = 0; j < accounts.size(); j++) {
            Account acct = accounts[j];            
            // For each account just inserted, add contacts
            for (Integer k = numContactsPerAccount * j; k < numContactsPerAccount * (j + 1); k++) {
                contacts.add(new Contact(firstname='Box Test'+k,
                                         lastname='Box Test'+k,
                                         email='contact_'+generateRandomString(4)+'@'+generateRandomString(4)+'box.com',
                                         AccountId=acct.Id));
            }
        }
        // Insert all contacts for all accounts
        insert contacts;
        
        //Collaboration Requests
        List<External_Collaboration_Request__c> requests = new List<External_Collaboration_Request__c>();       
        for(Integer i = 0; i < numCollabRequests; i++) {
            External_Collaboration_Request__c req = new External_Collaboration_Request__c(Folder_Name__c='External Collab using CONTACTS #' + i);
            req.Deal__c= TestMatter.Id;
            req.Access_Valid_Until__c= DateTime.now();
            req.Processed__c= false;
            req.Access_Level__c= 'PREVIEWER';
            requests.add(req);
        }
        insert requests;
        
        //Create Request Members of Type Contact
        List<Request_Member__c> members = new List<Request_Member__c>();
        for (Integer j = 0; j < numCollabRequests; j++) {
            External_Collaboration_Request__c request = requests[j];            
            // For each request just inserted, add members from contacts
            for (Integer k = 0; k < contacts.size(); k++) {
                Contact c = contacts[k];  
                members.add(new Request_Member__c(Contact__c = c.Id,
                                                  Member_Type__c = 'Contact',
                                                  Collaboration_Id__c=''+k,
                                                  External_Collaboration_Request__c=request.Id));
            }
        }
        // Insert all contacts for all accounts
        insert members;       
        
        
        //SECOND SETUP - REQUEST OF TYPE USER      
        //Create Users
        List<User> users = new List<User>();
        User TestUserA = createUser('Barclays Standard User', 'usera@fakeduser.com', 'boxusera@fakedbox.com'); 
        users.add(TestUserA);  
        
        User TestUserB = createUser('Barclays Standard User', 'userb@fakeduser.com', 'boxuserb@fakedbox.com'); 
        users.add(TestUserB);
        //insert users
        insert users;
        
        //add to returned list
        returnedList.addAll(requests);
        
        //clear request list for new setup
        requests.clear();
        
        //Create request A
        External_Collaboration_Request__c requestA = new External_Collaboration_Request__c();
        requestA.Deal__c= TestMatter.Id;
        requestA.Access_Valid_Until__c= DateTime.now().addDays(-5);
        requestA.Processed__c= false;
        requestA.Access_Level__c= 'VIEWER';
        requestA.Folder_Name__c= 'External Collab using USERS #1';
        requests.add(requestA);
        
        //request B
        External_Collaboration_Request__c requestB = new External_Collaboration_Request__c();
        requestB.Deal__c= TestMatter.Id;
        requestB.Access_Valid_Until__c= DateTime.now().addDays(-10);
        requestB.Processed__c= false;
        requestB.Access_Level__c= 'PREVIEWER_UPLOADER';
        requestB.Folder_Name__c= 'External Collab using USERS #2';
        requests.add(requestB);
        
        //Reference old
        External_Collaboration_Request__c requestOld = new External_Collaboration_Request__c();
        requestOld.Deal__c= TestMatter.Id;
        requestOld.Access_Valid_Until__c= DateTime.now();
        requestOld.Processed__c= false;
        requestOld.Access_Level__c= 'VIEWER_UPLOADER';
        requestOld.Parent_Request__c= requestA.Id;
        requestOld.Folder_Id__c= '0983';
        requestOld.Folder_Name__c= 'External Collab using USERS #2';
        insert requestOld;
        
        User oldUser = createUser('Barclays Standard User', 'justrandom@fakeduser.com', 'veryrandom@fakedbox.com');
        insert oldUser;
        
        Request_Member__c oldMembers = new Request_Member__c(User__c = oldUser.Id,
                                                  Member_Type__c = 'User',
                                                  Collaboration_Id__c='1232',
                                                  External_Collaboration_Request__c=requestOld.Id);
        
        insert oldMembers;
        
        External_Collaboration_Request__c requestC = new External_Collaboration_Request__c();
        requestC.Deal__c= TestMatter.Id;
        requestC.Access_Valid_Until__c= DateTime.now();
        requestC.Processed__c= false;
        requestC.Access_Level__c= 'VIEWER';
        requestC.Parent_Request__c= requestOld.Id;
        requestC.Folder_Id__c= '0983';
        requestC.Folder_Name__c= 'Reference A External Collab using USERS #2';
        requests.add(requestC);
        
        insert requests;
        
        //request D to reference B
        External_Collaboration_Request__c requestD = new External_Collaboration_Request__c();
        requestD.Deal__c= TestMatter.Id;
        requestD.Access_Valid_Until__c= DateTime.now();
        requestD.Processed__c= false;
        requestD.Access_Level__c= 'PREVIEWER';
        requestD.Parent_Request__c= requestOld.Id;
        requestD.Folder_Id__c= '03333';
        requestD.Folder_Name__c= 'Reference  B External Collab using USERS #2';
        insert requestD;
        
        User dUser = createUser('Barclays Standard User', 'justrandom@fakeduser.com', 'veryrandom@fakedbox.com');
        insert dUser;
        
        Request_Member__c dMembers = new Request_Member__c(User__c = dUser.Id,
                                                  Member_Type__c = 'User',
                                                  Collaboration_Id__c='4442',
                                                  External_Collaboration_Request__c=requestD.Id);
        
        insert dMembers;
        
        //REQUEST MEMBERS OF TYPE USER
        members.clear();
        for (Integer j = 0; j < requests.size(); j++) {
            External_Collaboration_Request__c request = requests[j];            
            // For each request just inserted, add members from users
            for (Integer k = 0;k < users.size(); k++) {
                User u = users[k];  
                members.add(new Request_Member__c(User__c = u.Id,
                                                  Member_Type__c = 'User',
                                                  Collaboration_Id__c=''+k,
                                                  External_Collaboration_Request__c=request.Id));
            }
        }
        // Insert all members for all users
        insert members;
        
        
        //THIRD SETUP - REQUEST OF TYPE USER FOR FUTURE DATES      
        //Create Users
        users.clear();
        User TestFutureUserA = createUser('Barclays Standard User', 'future.usera@fakeduser.com', 'Future.A@fakedbox.com'); 
        users.add(TestFutureUserA);  
        
        User TestFutureUserB = createUser('Barclays Standard User', 'future.userb@fakeduser.com', 'Future.B@fakedbox.com'); 
        users.add(TestFutureUserB);
        //insert users
        insert users;
        
        //add to returned list
        returnedList.addAll(requests);
        
        //clear request list
        requests.clear();
        
        //Create request A
        External_Collaboration_Request__c futureRequestA = new External_Collaboration_Request__c();
        futureRequestA.Deal__c= TestMatter.Id;
        futureRequestA.Access_Valid_Until__c= DateTime.now().addDays(1);
        futureRequestA.Processed__c= false;
        futureRequestA.Access_Level__c= 'VIEWER_UPLOADER';
        futureRequestA.Folder_Name__c= 'Future External Collab for USER #1';
        requests.add(futureRequestA);
        
        //request B
        External_Collaboration_Request__c futureRequestB = new External_Collaboration_Request__c();
        futureRequestB.Deal__c= TestMatter.Id;
        futureRequestB.Access_Valid_Until__c= DateTime.now().addDays(365);
        futureRequestB.Processed__c= false;
        futureRequestB.Access_Level__c= 'VIEWER';
        futureRequestB.Folder_Name__c= 'Future External Collab for USER #2';
        requests.add(futureRequestB);
        System.debug('**DAY1==== ' + DateTime.now().addDays(1));
        System.debug('**DAY2==== ' + DateTime.now().addDays(365));
        System.debug('**DAY3==== ' + DateTime.now().addDays(-366));
        
        insert requests;
        
        //REQUEST MEMBERS OF TYPE USER
        members.clear();
        for (Integer j = 0; j < requests.size(); j++) {
            External_Collaboration_Request__c request = requests[j];            
            // For each request just inserted, add members from users
            for (Integer k = 0; k < users.size(); k++) {
                User u = users[k];  
                members.add(new Request_Member__c(User__c = u.Id,
                                                  Member_Type__c = 'User',
                                                  Collaboration_Id__c=''+k,
                                                  External_Collaboration_Request__c=request.Id));
            }
        }
        // Insert all members for all users
        insert members;

        return returnedList;
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
    
    //New user
    public static User createUser(string profile, string username, string email)
    {
        username = Math.random()+ username;
        user newUser;
        try 
        {
            Profile userProfile = [select Name from Profile where Name = :profile];
            
            newUser = new User(Alias = 'test',
                               Email = email,
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
}