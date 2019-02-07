public class BxdAccountPermission extends BxdPermissionHandler {
    public Account theObject { get; set; }
    public BxdAccountPermission(ApexPages.StandardController stdController){
        this.theObject = (Account)stdController.getRecord();
    }
    
    public PageReference actionViewRoute(){
        createBoxPermissions(theObject.Id);
        
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+theObject.Id); 
        standardPage.setRedirect(true);
             
        //Redirect.
        return standardPage;
    }
    
    public void createBoxPermissions(Id theRecordId){
        super.createPermissionForUser(theRecordId);   
    }
}