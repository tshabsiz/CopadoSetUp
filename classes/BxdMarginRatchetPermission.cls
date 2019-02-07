public class BxdMarginRatchetPermission extends BxdPermissionHandler {
    private Margin_Ratchet__c ratchet { get; set; }
    private String boxServiceName { get; set; }
    
    /**
	* BxdMarginRatchetPermission constructor - used to initialize Margin_Ratchet__c object
	**/
    public BxdMarginRatchetPermission(ApexPages.StandardController stdController){
        boxServiceName = 'BxdMarginRatchetService';
        this.ratchet = (Margin_Ratchet__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Margin_Ratchet__c to its view
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(ratchet.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id=' + ratchet.Id + '&boxService=' + boxServiceName);
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Margin_Ratchet__c
	**/
    public void createBoxPermissions(Id ratchetId){
        super.createPermissionForUser(ratchetId);
    }
}