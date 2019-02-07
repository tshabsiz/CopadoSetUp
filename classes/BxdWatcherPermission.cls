public class BxdWatcherPermission extends BxdPermissionHandler {
    private Watcher__c watcher { get; set; }
    private String boxServiceName { get; set; }
    
    /**
	* BxdWatcherPermission constructor - used to initialize Watcher__c object
	**/
    public BxdWatcherPermission(ApexPages.StandardController stdController){
        boxServiceName = 'BxdWatcherService';
        this.watcher = (Watcher__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Watcher__c to its view
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(watcher.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id=' + watcher.Id + '&boxService=' + boxServiceName);
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Watcher__c
	**/
    public void createBoxPermissions(Id watcherId){
        super.createPermissionForUser(watcherId);
    }
}