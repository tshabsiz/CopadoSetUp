@isTest
public class AcmMitigantCRUDService_test {
    public static testmethod void createOrUpdateMitigantsList_test() {
        
        // Putting this outside Test.startTest() and Test.stopTest() since not doing so will give a callout exception
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AcmCollateralTestData.MockHttpResponseGenerator());
        
        // Query all the required lists
        List<Acm_Collateral_Status__c> AcmStatuses = [SELECT Id, Collateral_No__c, Name, Collateral_Id__c,Collateral_Message__c, Collateral_Owner__c,Status__c FROM Acm_Collateral_Status__c];
        List<Collateral__c> collaterals = [SELECT Id,Collateral_Type1__r.deprecated__c,Collateral_Type1__r.Collateral_Purpose__c,Acm_External_Id__c, Name, OwnerId, Collateral_Group__c,Collateral_Group__r.Credit_Code__c, Scope__c, Saved_To_Acm__c, Beneficiary__c, Account__c, CurrencyIsoCode, Collateral_Type1__c,Collateral_Type1__r.Credit_Code__c,Expiry_Date__c, Country__c, Signature_Date__c, Physical_Location__c,
                                    Status__c, Comments__c, Asset_Description__c, Value__c, Value_Type__c, Value_Limit__c, Asset__c,
                                    Asset_Type__c, Collateral_No__c, Document_Type__c, Document_Name__c, Document_Expiry_Date__c, Manager__c,
                                    Document_Description__c, Document_Status__c, Supporting_Documentation_Uploaded__c, 
                                    Has_Underlying_Assets__c FROM Collateral__c];
            
        List<Collateral_Relationship__c> collateralRelationships =  [SELECT Collateral__c,relationship__r.CIF__c,Relationship__c,isPrimaryRelationship__c,Collateral_Type__c,Active__c, Relationship_Type__c,relationship__r.SDS__c FROM Collateral_Relationship__c];
        List<Collateral_Facility__c> collateralFacilities = [SELECT Collateral__c, Saved_To_Acm__c,Active__c, Facility_Client__c, AcmFacility__c,AcmFacility__r.Facility_Id__c, AcmFacility__r.Bank_Application_key__c FROM Collateral_Facility__c];
        List<Collateral_Monitoring__c> collateralMonitorings = [Select id,Collateral_Type__c,Account_Number__c,Account_Type__c From Collateral_Monitoring__c];
        
        
        AcmMitigantCRUDService.createOrUpdateMitigantsList(AcmStatuses, collaterals, collateralRelationships, collateralFacilities,collateralMonitorings);
        
        Test.stopTest();
    }
    
    public static testmethod void createOrUpdateMitigants_test() {
        Test.startTest();
        AcmCollateralTestData acmCollateralTestData = new AcmCollateralTestData();
        
        List<Collateral__c> collaterals = [SELECT Id,Collateral_Type1__r.deprecated__c,Collateral_Type1__r.Collateral_Purpose__c,Acm_External_Id__c, Name, OwnerId, Collateral_Group__c,Collateral_Group__r.Credit_Code__c, Scope__c, Saved_To_Acm__c, Beneficiary__c, Account__c, CurrencyIsoCode, Collateral_Type1__c,Collateral_Type1__r.Credit_Code__c,Expiry_Date__c, Country__c, Signature_Date__c, Physical_Location__c,
                                           Status__c, Comments__c, Asset_Description__c, Value__c, Value_Type__c, Value_Limit__c, Asset__c,
                                           Asset_Type__c, Collateral_No__c, Document_Type__c, Document_Name__c, Document_Expiry_Date__c, Manager__c,
                                           Document_Description__c, Document_Status__c, Supporting_Documentation_Uploaded__c, 
                                           Has_Underlying_Assets__c FROM Collateral__c];
        
        AcmMitigantCRUDService.createOrUpdateMitigants(collaterals.get(0).Id);
        Test.stopTest();
    }
}