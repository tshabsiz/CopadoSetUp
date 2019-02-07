@isTest
public class BxdDrawDownPermission_test {
    public static testMethod void TestDrawDownPermissionController()
    {
        BxdDocumentTestData  testDataClass = new BxdDocumentTestData();
        ApexPages.StandardController sc = new ApexPages.standardController(testDataClass.TestDrawdown);
        BxdDrawDownPermission page = new BxdDrawDownPermission(sc);
        
        //Main method.
        PageReference actionView = page.actionViewRoute();
        system.assert(actionView != null);
    }
}