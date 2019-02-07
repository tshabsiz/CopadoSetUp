public class BxdDrawDownPermission extends BxdPermissionHandler {
    private Drawdown__c drawdown{ get; set; }
    
    /**
	* BxdDrawDownPermission constructor - used to initialize Drawdown__c object
	**/
    public BxdDrawDownPermission(ApexPages.StandardController stdController){
        this.drawdown = (Drawdown__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Drawdown__c to its view
	**/
    public PageReference actionViewRoute(){
        createBoxPermissions(drawdown.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+drawdown.Id); 
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of Drawdown__c
	**/    
    public void createBoxPermissions(Id drawdownRecordId){
        super.createPermissionForUser(drawdownRecordId);   
    }
}