@isTest
public class Time_Trigger_test 
{
    public static testMethod void testUpdate()
    {
        Date weekstart = Date.today().toStartOfWeek();
        Cloudsmiths_TestDataClass  TDC = new Cloudsmiths_TestDataClass();
        advpm__Timekeeper__c testTimekeeper = new advpm__Timekeeper__c(advpm__Staff__c = UserInfo.getUserId());
        insert testTimekeeper;
        
        List<advpm__Time__c> testTime = new List<advpm__Time__c>();
        
        for(Integer i = 0; i < 8; i++)
        {
            testTime.add(new advpm__Time__c(advpm__Entry_Date__c = weekstart.addDays(i), advpm__Timekeeper__c = testTimekeeper.Id, advpm__Matter__c =  TDC.TestMatter.id));
        }
       
        insert testTime;
    }
}