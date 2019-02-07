@isTest
public class BxdCollateralPermission_test {
    public static testMethod void TestCollateralPermissionController()
    {
        BXDtesclassdata.setupFolder();
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestCollateral);
        BxdCollateralPermission page = new BxdCollateralPermission(sc);
        
        //Main method.
        PageReference actionView = page.actionViewRoute();
        system.assert(actionView != null);
    }
}