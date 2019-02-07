@isTest
public class BxdConditionPermission_test {
    public static testMethod void TestConditionPermissionController()
    {       
        BXDtesclassdata.setupBoxFolder();
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.testCondition);
        BxdConditionPermission cond = new BxdConditionPermission(sc);
        
        //Main method.
        PageReference actionView = cond.actionViewRoute();
        test.setCurrentPage(actionView);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testDataClass.testCondition);
        BxdConditionPermission ext = new BxdConditionPermission(stdController);
        //test.setCurrentPage(pageRef);
        cond.actionViewRoute();
        system.assert(actionView != null);
    }
}