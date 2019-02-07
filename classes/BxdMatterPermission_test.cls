@isTest
public class BxdMatterPermission_test {
    public static testMethod void TestConditionPermissionController()
    {       
        BXDtesclassdata.setupBoxFolder();
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestMatter);
        BxdMatterPermission matt = new BxdMatterPermission(sc);
        
        //Main method.
        PageReference actionView = matt.actionViewRoute();
        system.assert(actionView != null);
    }
}