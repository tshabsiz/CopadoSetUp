public class BxdConditionOccurrencePermission extends BxdPermissionHandler {
    private Condition_Occurrence__c occurrenceObject { get; set; }
    private String boxServiceName { get; set; }
    
    /**
	* BxdConditionOccurrencePermission constructor - used to initialize Condition_Occurrence__c object
	**/
    public BxdConditionOccurrencePermission(ApexPages.StandardController stdController){
        boxServiceName = 'BxdConditionService';
        this.occurrenceObject = (Condition_Occurrence__c)stdController.getRecord();
    }
    
    /**
	* actionViewRoute - used to redirect instance of Condition_Occurrence__c to its view
	**/
    public PageReference actionViewRoute(){
        createPermission(occurrenceObject.Id);
        PageReference standardPage = new PageReference('/apex/BxdDocuments?Id='+occurrenceObject.Id + '&boxService=' + boxServiceName);
        standardPage.setRedirect(true);
        
        //Prevent infinite loop. Force override.
        standardPage.getParameters().put('nooverride','1');
        
        //Redirect.
        return standardPage;
    }
    
    /**
	* createBoxPermissions - used to call createBoxPermission in BxdConditionOccurrenceService to grant access to the passed instance of Condition_Occurrence__c
	**/    
    public static void createPermission(Id occurrenceId) {
        System.debug('### BxdConditionOccurrencePermission : createPermission : '+occurrenceId);
        BxdConditionOccurrenceService.createBoxPermission(occurrenceId);
    }  
}