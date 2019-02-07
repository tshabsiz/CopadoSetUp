@isTest
public class Batch_UpdateAttendeeSharing_Test 
{

    static testMethod void muyUnitTest()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Call_Report callReportFactory = ZZTEST_DataFactoryFacade.callReport;
        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

        User u = userFactory.getBarclaysStandardUser();
        
        User user1 = [Select ID from User where ID=:UserInfo.getUserId()];
        System.runAs(user1)
        {
            Call_Report__c callRep  = callReportFactory.getInsertedProduct(ZZTEST_F_Call_Report.CallReportRecordType.DEFAULT_CALL_REPORT, 
                                                                           dataContainer);
            
            
            Attendee__c att = new Attendee__c(Call_Report__c = callRep.Id, Barclays_Attendee__c=u.Id);
            insert att;
            
            SYstem.debug('att '+att);
            Test.startTest();
            Database.executeBatch(new Batch_UpdateAttendeeSharing('Select Id,Call_Report__r.ID, Barclays_Attendee__c, CreatedDate FROM Attendee__c '));
            
            Test.stopTest();
        }
        

      
    }
}