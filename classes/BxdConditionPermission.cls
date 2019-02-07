public class BxdConditionPermission extends BxdPermissionHandler {
    private Condition__c condition { get; set; }
    
    /**
	* BxdConditionPermission constructor - used to initialize Condition__c object
	**/
    public BxdConditionPermission(ApexPages.StandardController stdController){
        this.condition = (Condition__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Condition__c to its view
	**/
    public PageReference actionViewRoute(){
        PageReference standardPage;
        if(ApexPages.currentPage().getParameters().get('redirect') == '0'){           
            createPermission(condition.id);
            standardPage = new PageReference('/apex/BxdDocuments?Id='+condition.Id); 
            standardPage.setRedirect(true);
        } else {
            createFolder(condition.id);
            standardPage = new PageReference('/apex/Condition_BoxDocument_RelatedList?Id='+condition.Id+'&redirect=0');
            standardPage.setRedirect(true);
        }
        
        //Redirect
        return standardPage;
    }
    
    /**
    * createFolder - used to make an external call to createFolderForRecord in BxdConditionService, a box folder for record will be created
	**/
    public static void createFolder(Id conditionId) {
        System.debug('### BxdConditionPermission : createFolder : '+conditionId);
        Condition__c condition = [SELECT Id, Name, Agreement__c, RecordTypeId FROM Condition__c WHERE Id=:conditionId LIMIT 1];
        BxdConditionService.createFolderForRecord(condition);
    }
    
    /**
	* createBoxPermissions - used to call createBoxPermission in BxdConditionService to grant access to the passed instance of Condition__c
	**/    
    public static void createPermission(Id conditionId) {
        System.debug('### BxdConditionPermission : createPermission : '+conditionId);
        BxdConditionService.createBoxPermission(conditionId);
    }   
}