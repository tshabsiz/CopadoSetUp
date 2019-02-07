public class BxdSPVItemPermission extends BxdPermissionHandler {
    private SPV_Items__c spvItem{ get; set; }
    
    /**
	* BxdSPVItemPermission constructor - used to initialize SPV_Items__c object
	**/
    public BxdSPVItemPermission(ApexPages.StandardController stdController){
        this.spvItem = (SPV_Items__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of SPV_Items__c to its view 
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(spvItem.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+spvItem.Id); 
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of SPV_Items__c
	**/
    public void createBoxPermissions(Id spvItemRecordId){
        super.createPermissionForUser(spvItemRecordId);   
    }
}