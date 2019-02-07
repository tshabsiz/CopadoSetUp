/* 20170406
 * RN - CloudSmiths
 * Test class for : scheduledResetLimits
 */
@isTest
public class scheduledResetLimits_Test{
    static testMethod void scheduledResetLimits_Test(){
        //test data
        System_Limits_Tracker__c st = new System_Limits_Tracker__c();
        st.Warning_Sent__c = false;
        st.Activate_Rule__c = true; 
        st.Limit_Was_Reset_At__c = System.now();
        st.Use_WorkAround__c = false; 
        st.Enforce_Workaround_Percentage__c = 90; 
        st.Warning_Percentage__c = 60;
        st.X24_Running_Limit__c = 100;
        st.System_Limit__c = 1000;
        st.Name = 'SingleEmail';
        insert st;
        
        Test.startTest();
        	//set the cron instructions : runs every day at 02:00AM
        	String CRON_EXP = '0 0 13 * * ?';
        	String jobId = System.schedule('ResetLimitsDaily',CRON_EXP, new scheduledResetLimits());
        	// Get the information from the CronTrigger API object
      		CronTrigger ct = [select Id, CronExpression, TimesTriggered, NextFireTime from CronTrigger where id = :jobId];
			System.assertEquals(CRON_EXP, ct.CronExpression);
        
        Test.stopTest();
    }
}