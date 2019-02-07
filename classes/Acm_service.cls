global class Acm_service {
    Map<String, String> headers = new Map<String, String>();
    webservice static String callservice(List<String> acmIds)
    {
        Set<String> Ids = new Set<String>();
        for(String id : acmIds){
            Ids.add(id);
        }
        MakeCall(Ids);
        return 'Updating/Creating Collateral from soap:' ;
    }
    
    public static void MakeCall(set<String> Ids) {
        List<Id> collateralIds = new List<Id>();
        List<Id> statusIds = new List<Id>();
        for(String acmId : Ids) {
            collateralIds.add(Id.valueOf(acmId.split('-')[1]));
            statusIds.add(Id.valueOf(acmId.split('-')[0]));
        }
        
        List<Acm_Collateral_Status__c> AcmStatuses = [SELECT Id, Collateral_No__c, Name, Collateral_Id__c,Collateral_Message__c, Collateral_Owner__c,Status__c FROM Acm_Collateral_Status__c where Id IN:statusIds];
        List<Collateral__c> collaterals = [SELECT Id,Acm_External_Id__c, Name, OwnerId, Collateral_Group__c,Collateral_Group__r.Credit_Code__c, Scope__c, Saved_To_Acm__c, Beneficiary__c, Account__c, CurrencyIsoCode, Collateral_Type1__c,Collateral_Type1__r.Credit_Code__c,Expiry_Date__c, Country__c, Signature_Date__c, Physical_Location__c,
                                    Status__c, Comments__c, Asset_Description__c, Value__c, Value_Type__c, Value_Limit__c, Asset__c,
                                    Asset_Type__c, Collateral_No__c, Document_Type__c, Document_Name__c, Document_Expiry_Date__c, Manager__c,
                                    Document_Description__c, Document_Status__c, Supporting_Documentation_Uploaded__c, 
                                    Has_Underlying_Assets__c FROM Collateral__c WHERE Id IN: collateralIds];
            
        List<Collateral_Relationship__c> collateralRelationships =  [SELECT Collateral__c,Relationship__c,isPrimaryRelationship__c,Collateral_Type__c,Active__c, Relationship_Type__c,relationship__r.SDS__c FROM Collateral_Relationship__c where Collateral__c IN: collateralIds];
        List<Collateral_Facility__c> collateralFacilities = [SELECT Collateral__c, Saved_To_Acm__c,Active__c, Facility_Client__c, Acm_Facility__c,Acm_Facility__r.Facility_Id__c, Acm_Facility__r.Bank_Application_key__c FROM Collateral_Facility__c where Collateral__c IN :collateralIds];
        List<Collateral_Monitoring__c> collateralMonitorings = AcmMitigantCRUDService.getAllMonitoringsForCollateral(collateralIds);

        CallAcm(AcmStatuses, collaterals,collateralRelationships,collateralFacilities,collateralMonitorings);   
    }
    
    public static void CallAcm(List<Acm_Collateral_Status__c> AcmStatuses, List<Collateral__c> collaterals,List<Collateral_Relationship__c> collateralRelationships,List<Collateral_Facility__c> collateralFacilities,List<Collateral_Monitoring__c> collateralMonitorings) {
        AcmMitigantCRUDService.createOrUpdateMitigantsList(AcmStatuses, collaterals, collateralRelationships, collateralFacilities,collateralMonitorings);
    }
}