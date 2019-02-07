@isTest
public class evArchiveEvent_Controller_Test {
    
    public static testMethod void testClass()
    {
        evTestDataGenerator TestData = new  evTestDataGenerator();
        
        ApexPages.StandardController sc = new ApexPages.standardController(TestData.TestEvent);
        evArchiveEvent_Controller ae = new evArchiveEvent_Controller(sc);
        ae.archiveEvent();
        
    }

}