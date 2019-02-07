public class BxdFacilityPermission extends BxdPermissionHandler {
    private Facility__c facility { get; set; }
    
    /**
	* BxdFacilityPermission constructor - used to initialize Facility__c object
	**/
    public BxdFacilityPermission(ApexPages.StandardController stdController){
        this.facility = (Facility__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Facility__c to its view
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(facility.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+facility.Id); 
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Facility__c
	**/
    public void createBoxPermissions(Id facilityId){
        super.createPermissionForUser(facilityId);   
    }
}