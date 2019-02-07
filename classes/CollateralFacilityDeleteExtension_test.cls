@isTest
public class CollateralFacilityDeleteExtension_test {
    
    public static testmethod void TestCollateralFacilityDeleteExtension() {
       	Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController CollateralFacilityDeleteController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralFacility);
        CollateralFacilityDeleteExtension collateralFacilityDeleteExtension = new CollateralFacilityDeleteExtension(CollateralFacilityDeleteController);
        collateralFacilityDeleteExtension.deleteAction();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralFacilityDeleteExtensionCancel() {
       	Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController CollateralFacilityDeleteController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralFacility);
        CollateralFacilityDeleteExtension collateralFacilityDeleteExtension = new CollateralFacilityDeleteExtension(CollateralFacilityDeleteController);
        collateralFacilityDeleteExtension.cancel();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralFacilityDeleteExtensionCallWebserviceWithHttpRequest() {
       	 Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        ApexPages.StandardController CollateralFacilityDeleteController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralFacility);
        CollateralFacilityDeleteExtension collateralFacilityDeleteExtension = new CollateralFacilityDeleteExtension(CollateralFacilityDeleteController);
        collateralFacilityDeleteExtension.deleteAction();
      	collateralFacilityDeleteExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralFacilityDeleteExtensionCallWebserviceWithOutError() {
        Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        Collateral_Facility__c collateralFacility = AcmCollateralTestData.TestCollateralFacilityNotPrimary;        
        ApexPages.StandardController CollateralFacilityDeleteController = new ApexPages.StandardController(collateralFacility);
        CollateralFacilityDeleteExtension collateralFacilityDeleteExtension = new CollateralFacilityDeleteExtension(CollateralFacilityDeleteController);
        collateralFacilityDeleteExtension.deleteAction();
      	collateralFacilityDeleteExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralFacilityDeleteExtensionCallWebserviceWithError() {
       	Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        
        Collateral_Facility__c collateralFacility = AcmCollateralTestData.TestCollateralFacility;
        collateralFacility.isPrimaryRelationship__c = true;
        update collateralFacility;
        
        ApexPages.StandardController CollateralFacilityDeleteController = new ApexPages.StandardController(collateralFacility);
        CollateralFacilityDeleteExtension collateralFacilityDeleteExtension = new CollateralFacilityDeleteExtension(CollateralFacilityDeleteController);
        collateralFacilityDeleteExtension.deleteAction();
      	collateralFacilityDeleteExtension.CallWebService();
        Test.stopTest();
    }
}