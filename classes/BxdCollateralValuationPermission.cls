public class BxdCollateralValuationPermission extends BxdPermissionHandler {
    private Collateral_Valuation__c valuation { get; set; }
    private String boxServiceName { get; set; }
    
    /**
	* BxdCollateralValuationPermission constructor - used to initialize Collateral_Valuation__c object
	**/
    public BxdCollateralValuationPermission(ApexPages.StandardController stdController){
        boxServiceName = 'BxdCollateralValuationService';
        this.valuation = (Collateral_Valuation__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Collateral_Valuation__c to its view
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(valuation.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+valuation.Id + '&boxService=' + boxServiceName);
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Collateral_Valuation__c
	**/
    public void createBoxPermissions(Id valuationId){
        super.createPermissionForUser(valuationId);
    }
}