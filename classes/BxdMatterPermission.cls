public class BxdMatterPermission extends BxdPermissionHandler {
    private advpm__Matter__c matter { get; set; }
    private String boxServiceName { get; set; }
    
    /**
	* BxdMatterPermission constructor - used to initialize advpm__Matter__c object
	**/
    public BxdMatterPermission(ApexPages.StandardController stdController){
        boxServiceName = 'BxdMatterDealService';
        this.matter = (advpm__Matter__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of advpm__Matter__c to its view
	**/    
    public PageReference actionViewRoute(){
        createBoxPermissions(matter.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+matter.Id + '&boxService=' + boxServiceName);
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createPermissionForUser in BxdPermissionHandler to grant access to the passed instance of advpm__Matter__c
	**/    
    public void createBoxPermissions(Id matterRecordId){
        super.createPermissionForUser(matterRecordId);   
    }
}