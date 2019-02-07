/**
_____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
\____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/


*** CHANGE LOG ***

18/07/2017 - DF    - Created Class.

**/
@isTest
public class Time_QuotaNotification_Test 
{
    public static testMethod void testUpdate()
    {
        
        advpm__Timekeeper__c TestTimeKeeper = new advpm__Timekeeper__c
            (
                name =  'Test',
                advpm__Alias__c = 'Test',
                advpm__Staff__c =  system.UserInfo.getUserId(),
                Weekly_Quota_Notification__c = true
                
            );
        insert TestTimeKeeper;
        Test.StartTest();
        Time_QuotaNotification sh1 = new Time_QuotaNotification();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Time_QuotaNotification', sch, sh1); 
        Test.stopTest(); 
        
    }
    
}