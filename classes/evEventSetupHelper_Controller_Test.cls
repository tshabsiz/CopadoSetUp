/**
* @author Deshan Pillay
* @date 20/08/2018
* @description Test class for evEventSetupHelper_Controller class.
*/
@isTest
public class evEventSetupHelper_Controller_Test {
    
    public static testMethod void testClass()
    {
        evTestDataGenerator TestData = new evTestDataGenerator();
        evEventSetupHelper_Controller.getEvent(TestData.Testevent.Id);
    }

}