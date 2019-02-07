@isTest
public class CollateralRelationshipDelete_test {
    public static testmethod void TestCollateralRelationshipDeleteExtension() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralRelationshipProvider);
        CollateralRelationshipDeleteExtension collateralRelationshipDeleteExtension = new CollateralRelationshipDeleteExtension(CollateralRelationshipController);
        collateralRelationshipDeleteExtension.deleteAction();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralRelationshipDeleteExtensionCancel() {
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralRelationshipProvider);
        CollateralRelationshipDeleteExtension collateralRelationshipDeleteExtension = new CollateralRelationshipDeleteExtension(CollateralRelationshipController);
        collateralRelationshipDeleteExtension.cancel();
    }
    
    public static testmethod void TestCollateralRelationshipDeleteExtensionCallWebserviceWithHttpRequest() {
       	Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralRelationshipProvider);
        CollateralRelationshipDeleteExtension collateralRelationshipDeleteExtension = new CollateralRelationshipDeleteExtension(CollateralRelationshipController);
        collateralRelationshipDeleteExtension.deleteAction();
      	collateralRelationshipDeleteExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralRelationshipDeleteExtensionCallWebserviceWithError() {
       	Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        
        Collateral_Relationship__c collateralRelationship = AcmCollateralTestData.TestCollateralRelationshipProvider;
        collateralRelationship.isPrimaryRelationship__c = true;
        update collateralRelationship;
        
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(collateralRelationship);
        CollateralRelationshipDeleteExtension collateralRelationshipDeleteExtension = new CollateralRelationshipDeleteExtension(CollateralRelationshipController);
        collateralRelationshipDeleteExtension.deleteAction();
      	collateralRelationshipDeleteExtension.CallWebService();
        Test.stopTest();
    }
}