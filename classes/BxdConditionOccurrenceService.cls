public class BxdConditionOccurrenceService {  
    private static PermissionHandler permissionHandler = new PermissionHandler();  
    
    /**
	* createBoxPermission - used to call createConditionPermission in BxdPermissionHandler to grant access to the passed instance of Condition_Occurrence__c, dependant on the frup content
	**/   
    public static void createBoxPermission(Id conditionOccurrenceId){
        Condition_Occurrence__c occurence = [SELECT Id, Name, Condition__r.Agreement__r.Id, RecordTypeId FROM Condition_Occurrence__c WHERE Id=:conditionOccurrenceId LIMIT 1];
        String conditionTypeName = Schema.SObjectType.Condition_Occurrence__c.getRecordTypeInfosById().get(occurence.RecordTypeId).getName();
        if(conditionTypeName != null && occurence != null && occurence.Condition__r.Agreement__r != null){
            String conditionKey = occurence.Condition__r.Agreement__r.Id + ' - ' + conditionTypeName;
            List<Custom_FRUP__c> conditionFrups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE CustomKey__c =:conditionKey];
            if (conditionFrups != null && !conditionFrups.isEmpty()){
                Custom_FRUP__c detail = conditionFrups[0];
                permissionHandler.createConditionPermission(occurence.Id, detail);
            }  
        }                      
    }
    
    private class PermissionHandler extends BxdPermissionHandler {
        private PermissionHandler() {
        }
    }
}