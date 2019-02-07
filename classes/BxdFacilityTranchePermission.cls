public class BxdFacilityTranchePermission extends BxdPermissionHandler {
    private Facility_Tranche__c facilityTranche{ get; set; }
    
    /**
	* BxdFacilityTranchePermission constructor - used to initialize Facility_Tranche__c object
	**/
    public BxdFacilityTranchePermission(ApexPages.StandardController stdController){
        this.facilityTranche = (Facility_Tranche__c) stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Facility_Tranche__c to its view
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(facilityTranche.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+facilityTranche.Id); 
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Facility_Tranche__c
	**/
    public void createBoxPermissions(Id facilityTrancheRecordId){
        super.createPermissionForUser(facilityTrancheRecordId);   
    }
}