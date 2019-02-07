public class BxdTriggerPermission extends BxdPermissionHandler {
    private Trigger__c triggerObject { get; set; }
    
    /**
	* BxdTriggerPermission constructor - used to initialize Trigger__c object
	**/
    public BxdTriggerPermission(ApexPages.StandardController stdController){
        this.triggerObject = (Trigger__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Trigger__c to its view
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(triggerObject.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+triggerObject.Id); 
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Trigger__c
	**/
    public void createBoxPermissions(Id triggerId){
        super.createPermissionForUser(triggerId);   
    }
}