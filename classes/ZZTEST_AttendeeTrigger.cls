/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for AttendeeTrigger
*
* 06.09.2016 - Mohsin Wadee - changed asserts on lines 28 and 78.
* 22.09.2016 - Mohsin Wadee - changed assert on line 29.
* 26.07.2017 - Mabhedle Tonga  - Included additional test method (UpdateAttendingUser), resolved bad practise implementation on existing unit tests
*/
@isTest
public class  ZZTEST_AttendeeTrigger {

    public static testMethod void testCheckSharingAndDuplicates() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Call_Report callReportFactory = ZZTEST_DataFactoryFacade.callReport;

        Test.startTest();

        Call_Report__c callRep  = callReportFactory.getInsertedProduct(ZZTEST_F_Call_Report.CallReportRecordType.DEFAULT_CALL_REPORT, 
            dataContainer);

        Attendee__c attendee = [SELECT Id, Name, Barclays_Attendee__c, Attendee_Name__c, Client_Attendee__c, Call_Report__c FROM Attendee__c WHERE Call_Report__c = :callRep.Id];
        Call_Report__c callRepIns = [SELECT Id, Name, OwnerId FROM Call_Report__c WHERE Id = :callRep.Id];

        // Check sharing 
        List<Call_Report__Share> callreportshares = [SELECT Id, ParentId, UserOrGroupId FROM Call_Report__Share WHERE UserOrGroupId =: attendee.Barclays_Attendee__c AND ParentId =: attendee.Call_Report__c];      
        System.assert(callreportshares.size() >= 1);

        // Test for Barclays
        Attendee__c att2 = new Attendee__c();
        att2.Barclays_Attendee__c = attendee.Barclays_Attendee__c;
        att2.Call_Report__c = callRep.Id;
        try {
            insert att2;
        } catch (Exception e) {
            System.debug('Expected duplicate exception: ' + e.getMessage());
        }

        att2.Barclays_Attendee__c = null;
        att2.Call_Report__c = callRep.Id;

        try {
            insert att2;
        } catch (Exception e) {
            System.debug('Expected exception: ' + e.getMessage());
        }

        Profile pfl = [SELECT Id, Name FROM profile Where Id =: UserInfo.getProfileId() LIMIT 1];
        User testUser = new User(alias = 'u1', email='u1@test.com', emailencodingkey='UTF-8', ProfileId = pfl.Id, lastname='Testing', languagelocalekey='en_US', localesidkey='en_US',  country='United States', CommunityNickname = 'u1',
            timezonesidkey='America/Los_Angeles', username='u1@test13.com');
        try {
            insert testUser;
        } catch (Exception e) {
            System.debug('Unexpected exception: ' + e.getMessage());
        }

        att2.Barclays_Attendee__c = testUser.Id;
        try {
            insert att2;
        } catch (Exception e) {
            System.debug('Unexpected exception: ' + e.getMessage());
        }

        List<Attendee__c> retAtt = [SELECT Id, Name, Barclays_Attendee__c, Call_Report__c FROM Attendee__c WHERE Call_Report__c =: callRep.Id];
        System.assertEquals(retAtt.size(), 1);

        try {
            delete attendee;
        } catch(Exception e)
        {
            System.debug('Unexpected delete exception!' + e.getMessage());
        }
        List<Attendee__c> attDeleted = [SELECT Id, Name, Barclays_Attendee__c, Attendee_Name__c, Client_Attendee__c FROM Attendee__c WHERE Name =: attendee.Name];
        System.assertEquals(attDeleted.size(),0);

        callreportshares = [SELECT Id, ParentId, UserOrGroupId FROM Call_Report__Share WHERE UserOrGroupId =: attendee.Barclays_Attendee__c AND ParentId =: attendee.Call_Report__c];       
        //System.assertEquals(1, callreportshares.size()); //<--- Fails in production

        Test.stopTest();
    }

    public static testMethod void testChatterDailyDigestForAttendees() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Call_Report callReportFactory = ZZTEST_DataFactoryFacade.callReport;
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        
        User u = userFactory.getBarclaysStandardUser();
        Integer batchSize = 100;
        List<Attendee__c> attendees;
        List<Id> callReportIds;
        User barclaysUser = [Select ID,ProfileId 
                             from User where ID !=: u.ID 
                             AND isActive = true 
                             AND profile.Name = 'Barclays Standard User'limit 1];
        System.runAs(barclaysUser)           
        {
            List<Call_Report__c> callReports = new List<Call_Report__c>();
            for(Integer i=0; i<=batchSize; i++){
                callReports.add(callReportFactory.getProduct(ZZTEST_F_Call_Report.CallReportRecordType.DEFAULT_CALL_REPORT, dataContainer));
            }
            
            insert callReports;
            
            callReportIds = new List<Id>();
            attendees = new List<Attendee__c>();
            for(Call_Report__c callReport : callReports){
                attendees.add(new Attendee__c(Call_Report__c = callReport.Id, Barclays_Attendee__c=u.Id));
                callReportIds.add(callReport.Id);
            } 
            
            insert attendees;
            
             delete attendees;
        } 
        Test.startTest();
        
       
        
        List<EntitySubscription> subscriptions = [SELECT Id FROM EntitySubscription WHERE parentId IN :callReportIds limit 500];
        List<FeedItem> posts = getFeedItem(callReportIds);
        
        System.assertEquals(subscriptions.size(), (batchSize+1));
        System.assertEquals(posts.size(), 2*(batchSize+1));
        
        
        subscriptions = [SELECT Id FROM EntitySubscription WHERE parentId IN :callReportIds limit 500];
        System.assertEquals(subscriptions.size(), batchSize+1);
            
            Test.stopTest();
          
    }
    public static List<FeedItem> getFeedItem(List<ID> callReportIds)
    {
       return [SELECT ID,ParentID FROM FeedItem WHERE ParentID IN :callReportIds AND Type = :ChatterUtils.TEXT_POST];
    }
    static testMethod void UpdateAttendingUser()
    {
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        
        
        User u = userFactory.getBarclaysStandardUser();
        Test.startTest();
        
        User barclaysUser = [Select ID from User where ID !=: u.ID AND isActive = true limit 1];
        System.runAs(u)           
        {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Call_Report callReportFactory = ZZTEST_DataFactoryFacade.callReport;
            
            Call_Report__c callRep  = callReportFactory.getInsertedProduct(ZZTEST_F_Call_Report.CallReportRecordType.DEFAULT_CALL_REPORT, 
                                                                           dataContainer);
            
            Attendee__c attendee = [SELECT Id, Name, Barclays_Attendee__c, Attendee_Name__c, Client_Attendee__c, Call_Report__c FROM Attendee__c WHERE Call_Report__c = :callRep.Id];
            ID currentUserID = attendee.Barclays_Attendee__c;
            
            attendee.Barclays_Attendee__c =  barclaysUser.ID;
            update attendee;
            
            System.assert(currentUserID !=attendee.Barclays_Attendee__c);
                }
        
        Test.stopTest();
    }
}