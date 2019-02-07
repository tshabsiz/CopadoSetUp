public class CollateralFacilityExtension {
    private Collateral_Facility__c collateralFacility;
    public String facilityMessage { get; set; }
    private ApexPages.StandardController sController;
    private String errorMessage {get ; set; }
    private boolean providerError = false;
    private Collateral__c collateral;
    
    public CollateralFacilityExtension(ApexPages.StandardController stdController) {
        sController = stdController;
        if (!Test.isRunningTest())stdController.addFields(new List<String>{'Facility_Id__c','isPrimaryRelationship__c', 'Collateral__c'});
        this.collateralFacility = (Collateral_Facility__c)stdController.getRecord();
        collateral = AcmMitigantCRUDService.getCollateralFromId(collateralFacility.Collateral__c);
        if(getAccount() != null) {
            collateralFacility.Facility_Client__c = getAccount().Id;
        }
        
        if(collateral.Scope__c != 'Facility') {
         	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Cannot create/edit facility on Collateral with scope : ' + collateral.Scope__c));
        }
    }
    
    public PageReference save() {
        PageReference redirectSuccess = null;
        try {
            
            errorMessage = '';

            List<Collateral_Facility__c> collateralFacs =  new List<Collateral_Facility__c>();
            List<AcmFacility__c> acmFacilities = [SELECT Facility_Id__c FROM AcmFacility__c WHERE Id =:collateralFacility.AcmFacility__c];
            System.debug('Acm fac : ' + acmFacilities);
            if(acmFacilities.size() > 0) {
                AcmFacility__c acmFacility = acmFacilities.get(0);
                if(acmFacility.Facility_Id__c != '' || acmFacility.Facility_Id__c != null  ) {
                    String vv = acmFacility.Facility_Id__c;
                    String hwh = String.valueOf(collateralFacility.Collateral__c);
                    collateralFacs = [SELECT Id, Name, Collateral__c  FROM Collateral_Facility__c where Facility_Id__c =:vv AND collateral__c =:hwh];
                }
            }
			System.debug('Collateral Fac : ' + collateralFacs);
            System.debug('Collateral Fac null : ' + collateralFacility.Id);
            if(collateralFacs.size() >= 2) {
                    errorMessage = 'AllowedProduct/Facility relationship already exists';
                    providerError = true;
            } else if(collateralFacs.size() == 1) {
                if(collateralFacility.Id == null) {
                    errorMessage = 'AllowedProduct/ Facility relationship already exists';
                    providerError = true;
                }
            }
            
            if(collateral.Scope__c != 'Facility') {
         		errorMessage = 'Cannot create facility on Collateral with scope : ' + collateral.Scope__c ;
                providerError = true;
        	} else if(collateralFacility.isPrimaryRelationship__c) {
                errorMessage = 'Cannot update primary Facility on this page, Please edit on collateral';
                providerError = true;
            } 
            
            if(collateralFacility.AcmFacility__c == null) {
                errorMessage = 'Facility is required';
                providerError = true;  
            } else if(!providerError) {
                upsert(collateralFacility);
            }
        } catch(Exception e) {
            errorMessage = e.getMessage();
            System.debug('Exception thrown stuff : ' + errorMessage);
            redirectSuccess = null;
        }
        return redirectSuccess;
    }
    
    public PageReference getAndCreateFacilities() {
        try	{
            facilityMessage = AcmControllerLogic.ReadCreateCollateralAcmFacilities(collateralFacility.Facility_Client__c);
        } catch(Exception e) {
            facilityMessage = 'Empty Response from server';
        }
        
        if(facilityMessage != '') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, facilityMessage));   
        }
        return null; 
    } 
    
    public Account getAccount() {
        List<Collateral__c> collaterals = [SELECT Facility_Client__c FROM Collateral__c where Id = :collateralFacility.Collateral__c];
        if(collaterals.size() > 0) {
            Collateral__c collateral = collaterals.get(0);
            List <Account> accounts = [SELECT Id, Name FROM Account where Id = :collateral.Facility_Client__c];
            if(accounts.size() > 0) {
                return accounts.get(0);
            }
        }
        return null;
    }
    
    public PageReference callWebService() {
        PageReference redirectSuccess = null;
        PageReferenceMessage pageReferenceMessage = new PageReferenceMessage();
        if(errorMessage == '') {
            pageReferenceMessage = AcmControllerLogic.saveToACM(sController, collateral, false, errorMessage);
            if(pageReferenceMessage.message == 'Mitigant successfully created/update') {
                pageReferenceMessage.redirectSuccess = AcmControllerLogic.redirect(sController, false, collateral);
            } else if(pageReferenceMessage.message == 'Not Saving to ACM') {
                redirectSuccess = pageReferenceMessage.redirectSuccess;
            } else {
                System.debug('Message from service : ' + pageReferenceMessage.message);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, pageReferenceMessage.message));
                return null; 
            }
        } else {
            String message = '';
            if(providerError) {
                message = errorMessage;
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));  
            return null;
        }
        redirectSuccess = new ApexPages.StandardController(collateralFacility).view();
        return redirectSuccess;
    }
}