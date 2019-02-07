public class BxdMatterSpendDocumentService {
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
    * createBoxFolderTrigger - prepares a set of matterSpendDocument records id, then pass it to createBoxFolder
	**/
    public static  void createBoxFolderTrigger(List<Matter_Spend_Document__c> spendDocuments) {
        Set<Id> spendIds = new Set<Id>(); 
        for(Matter_Spend_Document__c spend : spendDocuments){
            spendIds.Add(spend.id);           
        }
        
        createBoxFolder(spendIds);
    }

	/**
    * createBoxFolder - this method executes asynchronously, it calls createFolder for each matterSpendDocument record in the set
	**/    
    @Future(callout = true)
    public static void createBoxFolder(Set<Id> spendDocumentIds) {
        List<Matter_Spend_Document__c> spendindDocuments = new List<Matter_Spend_Document__c>();
        
        //Get documents.
        spendindDocuments = [
            SELECT
            Id, 
            Name, 
            Matter__c, 
            Legal_Quote__c, 
            Law_Firm__c, 
            RecordTypeId, Type__c
            FROM Matter_Spend_Document__c
            WHERE
            Id IN :spendDocumentIds
        ];
        
        //Loop through each document.
        for(Matter_Spend_Document__c spending : spendindDocuments){
            createFolder(spending);
        }
    }
    
    
    /**
	* createFolder - this method creates a box folder for matterSpendDocument record by calling createBoxFolder in BxdFolderHandler, this is dependant on the frup 
	* It also sets the collaborationType to Viewer Uploader and creates a shared link for the folder
	**/
    public static void createFolder(Matter_Spend_Document__c matterSpendDocument) {
        if(matterSpendDocument != null){
            if(matterSpendDocument != null){
                String folderId;
                String INVOICE_FOLDER = matterSpendDocument.Type__c + 's';
                List<Custom_FRUP__c> customFolders = new List<Custom_FRUP__c>();
                
                //Get existing parent folder
                String parentFolderId = folderHandler.getBoxFolderIdByRecordId(matterSpendDocument.Matter__c);
                
                String customKey = matterSpendDocument.Matter__c + ' - ' + INVOICE_FOLDER;
                List<Custom_FRUP__c> frups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE CustomKey__c =:customKey];
                if (frups == null || frups.isEmpty()){
                    //create holding folder
                    String staticQuoteRequestFolderId = folderHandler.createBoxFolder(INVOICE_FOLDER, parentFolderId);
                    //create record folder
                    folderId = folderHandler.createBoxFolder(matterSpendDocument.Name, staticQuoteRequestFolderId);
                    folderHandler.linkBoxFolderToSalesforceRecord(matterSpendDocument.Id, folderId);
                    //add to custom folder details
                    Custom_FRUP__c details = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticQuoteRequestFolderId, ParentFolderId__c = parentFolderId);
                    customFolders.add(details);
                } else {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(matterSpendDocument.Name, details.FolderId__c);
                    folderHandler.linkBoxFolderToSalesforceRecord(matterSpendDocument.Id, folderId);
                }
                //set collaboration le
                box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.VIEWERUPLOADER;
                BxdCollaborationRequest collabRequest = BxdCollaborationRequest.getRequest();
                collabRequest.recordId = matterSpendDocument.Id;
                
                //create response shared link
                String folderLink = createSharedLink(folderId, collabRequest);
                String tempFolderId = folderHandler.getBoxFolderIdByRecordId(matterSpendDocument.Id);
                folderHandler.commitBoxChanges();
                // insert
                if(!customFolders.isEmpty()){
                    insert customFolders;
                }
                //update link
                if(!String.isBlank(folderLink)){
                    String url = folderLink;
                    url = url.replace(tempFolderId, folderId);
                    matterSpendDocument.Box_Folder_Link__c = folderLink;            
                    update matterSpendDocument;
                } 
            }                   
        }
    }
    
    
    /**
    * afterUpdateBox - this method loops through the matterSpendDocument recods list then calls moveFolderToSpendSchedule or moveFolderFromSpendSchedule
    **/
    public static void afterUpdateBox(List<Matter_Spend_Document__c> inputNewList, Map<Id, Matter_Spend_Document__c> inputOldMap) 
    {
        for(Matter_Spend_Document__c spendDocument : inputNewList){
            Id oldDocumentScheduleId = inputOldMap.get(spendDocument.Id).Matter_Spend_Schedule__c;
            
            if(!String.isBlank(spendDocument.Matter_Spend_Schedule__c) && String.isBlank(oldDocumentScheduleId)){
                system.debug('****Move Spend Folder to Schedule '+spendDocument.Matter_Spend_Schedule__c);
                moveFolderToSpendSchedule(spendDocument.Id, spendDocument.Matter_Spend_Schedule__c);
            }			
            
            if(String.isBlank(spendDocument.Matter_Spend_Schedule__c) && !String.isBlank(oldDocumentScheduleId)){  
                system.debug('****Move Spend Folder from Schedule '+oldDocumentScheduleId);
                moveFolderFromSpendSchedule(spendDocument.Id, oldDocumentScheduleId);
            }
        }
    }
    
    /**
    * createSharedLink - it calls getBoxFolderURL in BxdFolderHandler for the passed folderId then returns the url 
    **/
    private static String createSharedLink(String folderId, BxdCollaborationRequest collabRequest) {
        PageReference res = folderHandler.getBoxFolderURL(collabRequest.recordId, false);
        if(res != null){
            return res.getUrl();
        }
        return '';
    }
    
    /**
    * moveFolderToSpendSchedule - this method executes asynchronously, it gets the folderId of the matterSpendDocument record, then move the folder to spendSchedule as the new parent folder
    **/
    @Future(callout = true)
    private static void moveFolderToSpendSchedule(Id spendDocumentId, Id scheduleId) {
        //Get Spend box folder
        String spendFolderId = folderHandler.getBoxFolderIdByRecordId(spendDocumentId);
        //Get Schedule box folder
        String scheduleFolderId = folderHandler.getBoxFolderIdByRecordId(scheduleId);
        if(!String.isBlank(spendFolderId) && !String.isBlank(scheduleFolderId)){
            Boolean moved = folderHandler.moveBoxFolder(spendFolderId, scheduleFolderId);
            system.debug('FOLDER MOVED '+moved);
        }
        folderHandler.commitBoxChanges();
    }
    
    /**
    * moveFolderFromSpendSchedule - this method executes asynchronously, it gets the folderId of the matterSpendDocument record, then move the folder from spendSchedule to a different parent folder, dependant on the frup 
    **/
    @Future(callout = true)
    private static void moveFolderFromSpendSchedule(Id spendDocumentId, Id scheduleId) {
        Matter_Spend_Document__c spendDocument = [
            SELECT
            Id, 
            Name, 
            Matter__c, 
            Type__c
            FROM Matter_Spend_Document__c
            WHERE
            Id =:spendDocumentId
        ];
        //Get static box folder
        String INVOICE_FOLDER = spendDocument.Type__c + 's';
        String customKey = spendDocument.Matter__c + ' - ' + INVOICE_FOLDER;
        List<Custom_FRUP__c> frups = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c FROM Custom_FRUP__c WHERE CustomKey__c =:customKey];
        if (frups != null && !frups.isEmpty()){
            Custom_FRUP__c details = frups[0];
            //Get Spend box folder
            String spendFolderId = folderHandler.getBoxFolderIdByRecordId(spendDocument.Id);
            Boolean moved = folderHandler.moveBoxFolder(spendFolderId, details.FolderId__c);
            system.debug('FOLDER MOVED '+moved);
        }
        folderHandler.commitBoxChanges();
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}