@isTest
public class BxdConditionOccurrencePermission_test {
    public static testMethod void TestConditionPermissionController()
    {       
        BXDtesclassdata.setupBoxFolder();
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestConditionOccurrence);
        BxdConditionOccurrencePermission cond = new BxdConditionOccurrencePermission(sc);
        
        //Main method.
        PageReference actionView = cond.actionViewRoute();
        system.assert(actionView != null);
    }
}