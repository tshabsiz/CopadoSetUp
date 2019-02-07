/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Service the Condition folder creation, conditions folder are not linked to a condition record, they are linked to a custom frup
* @Date:        2017
*/
public class BxdConditionService implements BxdServiceInterface {
    private static final String CONDITION_FOLDER = 'Conditions';
    private static final String CONDITION_TYPE_FOLDER = 'Condition';
    private static FolderHandler folderHandler = new FolderHandler();  
    private static PermissionHandler permissionHandler = new PermissionHandler();  
    private static String folderId;
    
    /**
	* createBoxFolderSync - this method takes in a conditionOccurrence record id then call createFolderForRecord to create a folder for this record
	**/
    public String createBoxFolderSync(Id conditionOccurrenceId){
        List<Condition_Occurrence__c> occurences = [SELECT Id, Name, Condition__c FROM Condition_Occurrence__c WHERE Id=:conditionOccurrenceId];
        if(!occurences.isEmpty()){
            //Get condition from occurence, if occurence exists that means condition exist aswell
            Condition_Occurrence__c occurence = occurences[0];
            List<Condition__c> conditions = [SELECT Id, Name, Agreement__c, RecordTypeId FROM Condition__c WHERE Id=:occurence.Condition__c];
            Condition__c condition = conditions[0];
            //manual create condition folder
            createFolderForRecord(condition);
            system.debug('## Condition ' + condition.Name);
        }
        
        system.debug('####* CREATE MANUAL BOX FOLDER BxdConditionService *#### '+folderId);
        return folderId;
    }
    
    /**
    * createFolderForRecord - this method create box folder for condition record passed dependant on the frup, then save box changes after
	**/
    public static void createFolderForRecord(Condition__c condition) {
        if(condition != null){
            List<Custom_FRUP__c> customFolders = new List<Custom_FRUP__c>();
            //Select custom folder name for this record type
            String conditionFolderType;
            String conditionFolderName = CONDITION_FOLDER;
            String conditionTypeFolderName = CONDITION_TYPE_FOLDER;
            
            //get folder structure
            List<Box_Folder_Structure__c> folderStructures = folderHandler.getFolderStructures(Condition__c.SObjectType, condition.RecordTypeId, true);
            for(Box_Folder_Structure__c structure : folderStructures){
                if(structure.Custom__c){
                    //Conditions
                    conditionFolderName = structure.Folder_Name__c;
                } else {
                    //Condition Precedent, Information Undertakin etc
                    conditionTypeFolderName = structure.Folder_Name__c;
                    conditionFolderType = structure.Folder_Type__c;
                }
            }
            
            //Get existing parent folder
            String parentFolderId = folderHandler.getBoxFolderIdByRecordId(condition.Agreement__c);
            if(!String.isBlank(parentFolderId)){
                String customKey = condition.Agreement__c + ' - ' + conditionFolderName;
                List<Custom_FRUP__c> frups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE FolderId__c != NULL AND CustomKey__c =:customKey];
                
                //check if we have not created Conditions folder before
                if (frups == null || frups.isEmpty()){
                    //create holding folder
                    String staticConditionFolderId = folderHandler.createBoxFolderOrGetExistingFolder(conditionFolderName, parentFolderId);
                    
                    //add to custom folder details
                    Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticConditionFolderId, ParentFolderId__c = parentFolderId);
                    customFolders.add(cfd);
                    
                    //create condition type folder
                    String conditionKey = condition.Agreement__c + ' - ' + conditionFolderType;
                    List<Custom_FRUP__c> conditionFrups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE FolderId__c != NULL AND CustomKey__c =:conditionKey];
                    
                    //only create if it this condition type folder doesn't exist
                    if (conditionFrups == null || conditionFrups.isEmpty()){
                        folderId = folderHandler.createBoxFolderOrGetExistingFolder(conditionTypeFolderName, staticConditionFolderId);
                        Custom_FRUP__c conditionFrup = new Custom_FRUP__c(CustomKey__c = conditionKey, FolderId__c = folderId, ParentFolderId__c = staticConditionFolderId);
                        customFolders.add(conditionFrup);
                    }  
                } else {
                    //create new type of condition folder
                    Custom_FRUP__c cfd = frups[0];                 
                    String conditionKey = condition.Agreement__c + ' - ' + conditionFolderType;
                    List<Custom_FRUP__c> conditionFrups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE FolderId__c != NULL AND CustomKey__c =:conditionKey];
                    
                    //only create if it this condition type folder doesn't exist
                    if (conditionFrups == null || conditionFrups.isEmpty()){
                        folderId = folderHandler.createBoxFolderOrGetExistingFolder(conditionTypeFolderName, cfd.FolderId__c);
                        Custom_FRUP__c conditionFrup = new Custom_FRUP__c(CustomKey__c = conditionKey, FolderId__c = folderId, ParentFolderId__c = cfd.FolderId__c);
                        customFolders.add(conditionFrup);
                    }                   
                } 
                system.debug('## Created Condition Box Folder: '+folderId);
            }  
            
            // Show error for debug purposes
            System.debug(LoggingLevel.DEBUG, 'Condition Service most recent error: ' + folderHandler.recentBoxErrors());
            
            // persist Box changes
            folderHandler.commitBoxChanges();
            // insert
            if(!customFolders.isEmpty()){
                upsert customFolders;
            }
        }
    }
    
    /**
    * createBoxPermission - used to call createConditionPermission in BxdPermissionHandler passing condition id, dependant on the frup
	**/
    public static void createBoxPermission(Id conditionId){
        Condition__c condition = [SELECT Id, Name, Agreement__c, RecordTypeId FROM Condition__c WHERE Id=:conditionId LIMIT 1];
        String conditionTypeName = Schema.SObjectType.Condition__c.getRecordTypeInfosById().get(condition.RecordTypeId).getName(); 
        
        if(conditionTypeName != null && condition != null && condition.Agreement__c != null){
            String conditionKey = condition.Agreement__c + ' - ' + conditionTypeName;
            system.debug('##CONDITION KEY '+conditionKey);
            
            List<Custom_FRUP__c> conditionFrups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE CustomKey__c =:conditionKey];
            if (conditionFrups != null && !conditionFrups.isEmpty()){
                Custom_FRUP__c detail = conditionFrups[0];
                permissionHandler.createConditionPermission(condition.Id, detail);
            }  
        }                      
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super(true);
        }
    }
    
    private class PermissionHandler extends BxdPermissionHandler {
        private PermissionHandler() {
        }
    }
}