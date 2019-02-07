@isTest
public class evDelegateSchedule_Controller_Test {
    
    public static testMethod void testClass()
    {
        evTestDataGenerator TestData = new  evTestDataGenerator();
        
        ApexPages.StandardController sc = new ApexPages.standardController(TestData.TestDelegate);
		evDelegateScheduleExtension_Controller dse = new evDelegateScheduleExtension_Controller(sc);
        
    }

}