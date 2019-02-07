@isTest
public class FacilityControllerExtension_test {
    public static testmethod void TestCollateralFacilityExtensionSave() {
        Test.startTest();
       	AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGeneratorFacilities());
        ApexPages.StandardController facilityControllerExtensionController = new ApexPages.StandardController(acmCollateralTestData.TestFacility);
        
        FacilityControllerExtension facilityControllerExtension = new FacilityControllerExtension(facilityControllerExtensionController);
        
        // Test Update fields
        facilityControllerExtension.save();
        facilityControllerExtension.UpdateFacilityFields();
        Test.stopTest();
    }
}