public class BxdAgencyTransferPermission extends BxdPermissionHandler {
    private Agency_Transfer__c agencyTransfer { get; set; }
    
    /**
	* BxdAgencyTransferPermission constructor - used to initialize agencyTransfer object
	**/
    public BxdAgencyTransferPermission(ApexPages.StandardController stdController){
        this.agencyTransfer = (Agency_Transfer__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Agency_Transfer__c to its view 
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(agencyTransfer.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+agencyTransfer.Id); 
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Agency_Transfer__c 
	**/
    public void createBoxPermissions(Id agencyTransferId){
        super.createPermissionForUser(agencyTransferId);  
    }
}