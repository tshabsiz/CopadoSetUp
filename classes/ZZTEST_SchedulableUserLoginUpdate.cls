/**
* @Author: Mohsin Wadee
* @Company: Barclays Africa
* @Description: Unit Test for SchedulableUserLoginUpdate class.
* Tests executed:
* 1 - Schedule the SchedulableUserLoginUpdate for a future date, and ensure it's queued.
* History
* <Date> <Authors Name> <Brief Description of Change>
* 30-Oct-2015, Mohsin Wadee, Class created.
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_SchedulableUserLoginUpdate {
	public static String CRON_EXP = '00 00 00 31 10 ? 2022';
    
    static testMethod void test()
    {    
        Test.startTest();
        
        // Schedule the test job.
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new SchedulableUserLoginUpdate());
        
        // Get information from the CronTrigger API object.
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expresssions are the same.
        System.assertEquals(CRON_EXP, ct.CronExpression);

        // Verify the job has not run.
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run.
        System.assertEquals('2022-10-31 00:00:00', String.valueOf(ct.NextFireTime));
        
        Test.stopTest();
        
        // Test the other interface methods which are usually not called directly.
        SchedulableUserLoginUpdate sch = new SchedulableUserLoginUpdate();
        sch.execute((SchedulableContext) null);
    }
}