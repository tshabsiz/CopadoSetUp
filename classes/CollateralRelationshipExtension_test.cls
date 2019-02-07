@isTest
public class CollateralRelationshipExtension_test {
    public static testmethod void TestCollateralRelationshipExtensionSave() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralRelationshipProvider);
        CollateralRelationshipExtension CollateralRelationshipExtension = new CollateralRelationshipExtension(CollateralRelationshipController);
        CollateralRelationshipExtension.save();
        Test.stopTest();
    }
    
   public static testmethod void TestCollateralRelationshipExtensionUpdate() {
       Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralRelationshipProvider);
        CollateralRelationshipExtension CollateralRelationshipExtension = new CollateralRelationshipExtension(CollateralRelationshipController);
        CollateralRelationshipExtension.save();
      	CollateralRelationshipExtension.save();
       Test.stopTest();
    }
    
    public static testmethod void TestCollateralRelationshipExtensionCallWebservice() {
       	Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(AcmCollateralTestData.TestCollateralRelationshipProvider);
        CollateralRelationshipExtension CollateralRelationshipExtension = new CollateralRelationshipExtension(CollateralRelationshipController);
        CollateralRelationshipExtension.save();
      	CollateralRelationshipExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralRelationshipExtensionCallWebserviceWithError() {
       	Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        Collateral_Relationship__c collateralRelationship = AcmCollateralTestData.TestCollateralRelationshipProvider;
        collateralRelationship.isPrimaryRelationship__c = true;
        update collateralRelationship;
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(collateralRelationship);
        CollateralRelationshipExtension CollateralRelationshipExtension = new CollateralRelationshipExtension(CollateralRelationshipController);
        CollateralRelationshipExtension.save();
      	CollateralRelationshipExtension.CallWebService();
        Test.stopTest();
    }
    
    public static testmethod void TestCollateralRelationshipExtensionCallWebserviceWithHttpRequest() {
        Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        Collateral_Relationship__c collateralRelationship = AcmCollateralTestData.TestCollateralRelationshipProvider;
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(collateralRelationship);
        CollateralRelationshipExtension CollateralRelationshipExtension = new CollateralRelationshipExtension(CollateralRelationshipController);   
        CollateralRelationshipExtension.save();
      	CollateralRelationshipExtension.CallWebService();
        Test.stopTest();
    }
    
     public static testmethod void TestCollateralFacilityExtensionValidationOptions() {
        
        // When Beneficairy has no SDS
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        Collateral_Relationship__c collateralRelationship = AcmCollateralTestData.TestCollateralRelationshipBeneficiaryNotPrimary;
        collateralRelationship.Relationship__c = AcmCollateralTestData.TestAccountWithoutSDS.Id;
        ApexPages.StandardController CollateralRelationshipController = new ApexPages.StandardController(collateralRelationship);
        CollateralRelationshipExtension CollateralRelationshipExtension = new CollateralRelationshipExtension(CollateralRelationshipController);   
        CollateralRelationshipExtension.save();
      	CollateralRelationshipExtension.CallWebService();
        Test.stopTest();
    } 
}