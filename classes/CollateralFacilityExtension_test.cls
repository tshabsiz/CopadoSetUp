@isTest
public class CollateralFacilityExtension_test {
    public static testmethod void TestCollateralFacilityExtensionSave() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController CollateralFacilityController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralFacility);
        CollateralFacilityExtension collateralFacilityExtension = new CollateralFacilityExtension(CollateralFacilityController);
        collateralFacilityExtension.save();
        Test.stopTest();
    }
    
   public static testmethod void TestCollateralFacilityExtensionUpdate() {
       	Test.startTest();	
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController CollateralFacilityController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralFacility);
        CollateralFacilityExtension collateralFacilityExtension = new CollateralFacilityExtension(CollateralFacilityController);
        collateralFacilityExtension.save();
      	collateralFacilityExtension.save();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralFacilityExtensionCallWebservice() {
        Test.startTest();	
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        ApexPages.StandardController CollateralFacilityController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralFacility);
        CollateralFacilityExtension collateralFacilityExtension = new CollateralFacilityExtension(CollateralFacilityController);
        collateralFacilityExtension.save();
      	collateralFacilityExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralFacilityExtensionCallWebserviceWithError() {
       	Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        Collateral_Facility__c collateralFacility = AcmCollateralTestData.TestCollateralFacility;
        collateralFacility.AcmFacility__c = null;
        update collateralFacility;
        ApexPages.StandardController CollateralFacilityController = new ApexPages.StandardController(collateralFacility);
        CollateralFacilityExtension collateralFacilityExtension = new CollateralFacilityExtension(CollateralFacilityController);
        collateralFacilityExtension.save();
      	collateralFacilityExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralFacilityExtensionCallWebserviceWithHttpRequest() {
        Test.startTest();       	
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        ApexPages.StandardController CollateralFacilityController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralFacilityNotPrimary);
        CollateralFacilityExtension collateralFacilityExtension = new CollateralFacilityExtension(CollateralFacilityController);
        collateralFacilityExtension.save();
      	collateralFacilityExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralFacilityExtensionGetAndCreateFacilities() {
        Test.startTest();       	
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGeneratorFacilities());
        ApexPages.StandardController CollateralFacilityController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralFacility);
        CollateralFacilityExtension collateralFacilityExtension = new CollateralFacilityExtension(CollateralFacilityController);
        collateralFacilityExtension.save();
      	collateralFacilityExtension.GetAndCreateFacilities();
        Test.stopTest();
    } 
        
    public static testmethod void TestCollateralFacilityExtensionValidationOptions() {
        Test.startTest();        
        // When facility is null
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGeneratorFacilities());
        Collateral_Facility__c collateralFacility = AcmCollateralTestData.TestCollateralFacilityNotPrimary;
        collateralFacility.AcmFacility__c = null;
        ApexPages.StandardController CollateralFacilityController = new ApexPages.StandardController(collateralFacility);
        CollateralFacilityExtension collateralFacilityExtension = new CollateralFacilityExtension(CollateralFacilityController);
        collateralFacilityExtension.save();
      	collateralFacilityExtension.CallWebService();
        
        // when scope is not benef
        Collateral_Facility__c collateralFacilityBenef = AcmCollateralTestData.TestCollateralFacilityNotPrimary;
        collateralFacilityBenef.Collateral__c = AcmCollateralTestData.TestCollateral.Id;
         ApexPages.StandardController CollateralFacilityControllerBenef = new ApexPages.StandardController(collateralFacilityBenef);
        CollateralFacilityExtension collateralFacilityExtensionBenef = new CollateralFacilityExtension(CollateralFacilityControllerBenef);
        collateralFacilityExtensionBenef.save();
      	collateralFacilityExtensionBenef.CallWebService();
        Test.stopTest();
    } 
}