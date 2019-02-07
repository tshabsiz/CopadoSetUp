public class BxdMatterSpendScheduleService implements BxdServiceInterface {
    private static FolderHandler folderHandler = new FolderHandler();
    private static PermissionHandler permissionHander = new PermissionHandler();
    
    /**
	* createBoxFolderSync - this method takes in a matterSpendSchedule record id then request a box folder to be created for this record
	**/
    public String createBoxFolderSync(Id recordId){
        String folderId = createBoxFolderForRecord(recordId);
        system.debug('****MANUAL BOX FOLDER**** '+folderId);
        folderHandler.commitBoxChanges();
        return folderId;
    }

  	/**
    * createBoxFolderTrigger - prepares a set of matterSpendSchedule records id, then pass it to createBoxFolder
	**/    
    public static void createBoxFolderTrigger(List<Matter_Spend_Schedule__c> schedules) {
        Set<Id> inputScheduleIds = new Set<Id>(); 
        for(Matter_Spend_Schedule__c schedule : schedules){
            inputScheduleIds.Add(schedule.id);           
        }      
        createBoxFolder(inputScheduleIds);
    }
    
    /**
    * createBoxFolder - this method executes asynchronously, it create box folder for each matterSpendSchedule record, then save box changes after
	**/
    @Future(callout = true)
    public static void createBoxFolder(Set<Id> inputScheduleIds) {
        
        List<Matter_Spend_Schedule__c> schedules = new List<Matter_Spend_Schedule__c>();
        
        //Get schedules and documents for it.
        schedules = [
            SELECT
            Id,
            Status__c,
            (
                SELECT
                Id,
                Status__c,
                Matter_Spend_Schedule__c
                FROM Matter_Spend_Documents__r
                
            )
            FROM Matter_Spend_Schedule__c
            WHERE
            Id IN :inputScheduleIds
        ];
        
        //Loop through each schedule.
        for(Matter_Spend_Schedule__c schedule : schedules)
        {
            String folderId = createBoxFolderForRecord(schedule.Id);
            if(!String.isBlank(folderId) && schedule.Matter_Spend_Documents__r != null){
                for(Matter_Spend_Document__c spendDocument : schedule.Matter_Spend_Documents__r){
                    moveFolderToSpendSchedule(spendDocument, folderId);
                }
            }          
        }
        folderHandler.commitBoxChanges();
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for matterSpendSchedule record, and creates collaboration on this record assigning the user as an editor
	**/
    public static String createBoxFolderForRecord(Id scheduleId) {
        String folderId;
        if(scheduleId != null){
            folderId = folderHandler.createBoxFolderForRecord(scheduleId);
            
            Id userId = UserInfo.getUserId();
            if(userId != null){
                box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
                String collabId = folderHandler.createCollaborationOnRecord(userId, scheduleId, collabType);
                system.debug('matter new collaboration id: ' + collabId);    
            }                  
        }        
        return folderId;
    }
    
    /**
    * getBoxFolderLink - used to make a call to getBoxFolderURL in BxdFolderHandler to get the link for the given matterSpendSchedule record
	**/
    public static String getBoxFolderLink(Matter_Spend_Schedule__c schedule) {
        PageReference res = folderHandler.getBoxFolderURL(schedule.Id, false);
        if(res != null){
            return res.getUrl();
        }
        return '';
    }
    
    /**
    * createViewerPermission - used to create permission for the user on the given matterSpendSchedule record, by calling createPermissionForUser in BxdPermissionHandler 
	**/
    public static void createViewerPermission(Matter_Spend_Schedule__c schedule) {  
        Id userId = UserInfo.getUserId();
        if(userId != null){
            permissionHander.createPermissionForUser(schedule.Id, userId);   
        }       
    }
    
    /**
    * moveFolderToSpendSchedule - used to call getBoxFolderIdByRecordId in BxdFolderHandler then move the returned folder
	**/
    private static void moveFolderToSpendSchedule(Matter_Spend_Document__c spendDocument, String scheduleFolderId) {
        String spendFolderId = folderHandler.getBoxFolderIdByRecordId(spendDocument.Id);
        if(!String.isBlank(spendFolderId)){
            Boolean moved = folderHandler.moveBoxFolder(spendFolderId, scheduleFolderId);
            system.debug('FOLDER MOVED '+moved);
        }        
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
    
    private class PermissionHandler extends BxdPermissionHandler {
        private PermissionHandler() {
        }
    }
}