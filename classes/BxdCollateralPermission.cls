public class BxdCollateralPermission extends BxdPermissionHandler {
    private Collateral__c collateral { get; set; }
    private String boxServiceName { get; set; }
    
    /**
	* BxdCollateralPermission constructor - used to initialize Collateral__c object
	**/
    public BxdCollateralPermission(ApexPages.StandardController stdController){
        boxServiceName = 'BxdCollateralService';
        this.collateral = (Collateral__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Collateral__c to its view
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(collateral.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id=' + collateral.Id + '&boxService=' + boxServiceName);

        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Collateral__c
	**/    
    public void createBoxPermissions(Id collateralId){
        super.createPermissionForUser(collateralId);   
    }
}