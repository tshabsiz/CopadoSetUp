/**

*** CHANGE LOG ***

31/10/2017 - Patrick Pheme   		- Created Class. 
09/11/2017 - TdB   					- API Name change. Facility_Limit__c  to Limit__c on Agreements Object
27/02/2018 - TdB					- Add additional catch error messages based on Agreement Validation Rules

**/ 

public class FacilityControllerExtension {
    public Facility__c facility;
    public List<Agreement__c> agreements;
    
    public FacilityControllerExtension(ApexPages.StandardController stdController) {
        this.facility = (Facility__c)stdController.getRecord();        
        agreements = [SELECT Matter_Deal__c, Limit__c FROM  Agreement__c WHERE id = :facility.Agreement__c];
        if(facility.Agreement_Account__c == null) {
            if(agreements.size() > 0 ) {
                List<advpm__Matter__c> matters = [SELECT  advpm__Primary_Account__c FROM  advpm__Matter__c WHERE id =:  (agreements.get(0)).Matter_Deal__c];
                if(matters.size() > 0) {
                    System.debug('facility is : ' + matters.get(0));
                    facility.Agreement_Account__c = (matters.get(0)).advpm__Primary_Account__c;
                }
            }
        }
    }
    
    public PageReference save() {
        
        Map<Id,Decimal> agreementFacilityLimit = new  Map<Id,Decimal>();
        Map<Id,Decimal> agreementLimit = new  Map<Id,Decimal>();
        Decimal facilityLimitTotal_temp = 0.00;
        Decimal facilityLimit_temp = 0.00;
        Decimal agreementLimit_temp = 0.00;
        
        PageReference redirectSuccess = null;
        
        try {

            if(facility.Availability__c == null) {
                facility.Availability__c = '';
            }
            upsert facility;
            redirectSuccess = new ApexPages.StandardController(facility).view();
        } catch(Exception e) {
            redirectSuccess = null;
            System.debug('Exception caught : ' + e.getMessage());
            if(e.getMessage().contains('The Total Facility Limit cannot exceed the Agreement Limit'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The Total Facility Limit cannot exceed the Agreement Limit')); 
            }
            else if (e.getMessage().contains('The total facility amount of all parties cannot exceed the facility limit'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The total facility amount of all parties cannot exceed the facility limit')); 
            }
            else if (e.getMessage().contains('Please ensure that the Agreement Limit is not exceeded'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please ensure that the Agreement Limit is not exceeded')); 
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage())); 
            }
            
        }
        return redirectSuccess;
    }
    
    public void GetFacility() {
        String facilityMessage = AcmControllerLogic.ReadCreateCollateralAcmFacilities(facility.Agreement_Account__c);
        if(facilityMessage != ''){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, facilityMessage));   
        }
    }
    
    public PageReference UpdateFacilityFields() {
        List<AcmFacility__c> acmFacilities = [SELECT STARTDATE__c, EXPIRYDATE__c, FACILITYCURRENCY__c, FACILITYAMOUNT__c FROM AcmFacility__c where id =: facility.AcmFacility__c];
        if(acmFacilities.size() > 0) {
            AcmFacility__c acmFacility = acmFacilities.get(0);
            facility.Facility_Limit__c = acmFacility.FACILITYAMOUNT__c;
            facility.CurrencyIsoCode = acmFacility.FACILITYCURRENCY__c;
            if(acmFacility.STARTDATE__c != null) {
                facility.Availability_Start_Date__c = acmFacility.STARTDATE__c;
            }
            
            if(acmFacility.EXPIRYDATE__c != null) {
                facility.Expiry_Date__c = acmFacility.EXPIRYDATE__c;
            }
        }
        return null; 
    }
}