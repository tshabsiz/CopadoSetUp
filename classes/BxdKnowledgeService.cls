/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Service Knowledge Management with box Folder/File creation/copy on Matter Convert to Case and Case import to new Matter
* @Date:        2017
*/
public class BxdKnowledgeService {
    private static Integer MAX_DEPTH = 1;
    private static final String OPEN = 'open';
    private static final String TIMESTAMP_FORMAT = 'yyyy-MM-dd';
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
	* createBoxFolderTrigger - this is called from case trigger to create box folder for the given cases
	**/
    public static  void createBoxFolderTrigger(Set<String> caseSet) {
        
        System.debug('### BxdKnowledgeService : createBoxFolderTrigger : caseSet : '+caseSet);
        
        for (Case knowledgeCase : [SELECT Id, Subject, RecordTypeId FROM Case where id in: caseSet Order by Subject ASC]) {
            createBoxCaseFolder(knowledgeCase.Id, new List<BxdKnowledgeItem>(), null, null);             
        }
    }
    
    /**
	* getBoxFolderFiles - get files from a box folder and level 1 subfolder or whatever is set on MAX_DEPTH
	**/
    public static List<BxdKnowledgeItem> getBoxFolderFiles(Id matterId) {
        List<BxdKnowledgeItem> fileList = new List<BxdKnowledgeItem>();
        
        //get box api with service account
        BoxPlatformApiConnection api = folderHandler.getBoxApi();
        
        //get box folder for the matter
        String folderId = folderHandler.getBoxFolderIdByRecordId(matterId);
        system.debug('THE FOLDER ID '+folderId);
        
        //traverse the box folder to get files
        if(!String.isBlank(folderId)){
            BoxFolder folder = new BoxFolder(api, folderId);
            return listFolder(api, folder, fileList, 0);
        }
        
        return fileList;
    }
    
    /**
	* getBoxFolderFiles - overload method to get files from a box folder and subfolder depeding on the maxDepth that override MAX_DEPTH
	**/
    public static List<BxdKnowledgeItem> getBoxFolderFiles(Id matterId, Integer maxDepth) {
        List<BxdKnowledgeItem> fileList = new List<BxdKnowledgeItem>();
        MAX_DEPTH = maxDepth;   
        
        //get box api with service account
        BoxPlatformApiConnection api = folderHandler.getBoxApi();
        
        //get box folder for the matter
        String folderId = folderHandler.getBoxFolderIdByRecordId(matterId);
        system.debug('THE FOLDER ID '+folderId);
        
        //traverse the box folder to get files
        if(!String.isBlank(folderId)){
            BoxFolder folder = new BoxFolder(api, folderId);
            return listFolder(api, folder, fileList, 0);
        }
        
        return fileList;
    }
    
    /**
	* listFolder - traverse a box folder based on depth to get all uploaded files
	**/
    private static List<BxdKnowledgeItem> listFolder(BoxApiConnection api, BoxFolder folder, List<BxdKnowledgeItem> fileList, Integer depth) {      
        list<BoxItem.Info> children = folder.getChildren();
        for (BoxItem.Info itemInfo : children) {
            if (itemInfo instanceof BoxFolder.Info) {
                //traverse subfolder if we have not reached the MAX_DEPTH
                BoxFolder childFolder = new BoxFolder(api, itemInfo.id);
                if (depth < MAX_DEPTH) {
                    listFolder(api, childFolder, fileList, depth + 1);
                }
            } else if(itemInfo instanceof BoxFile.Info) {
                //if it is a file, set it on KM item
                BxdKnowledgeItem item = new BxdKnowledgeItem(itemInfo.id, itemInfo.name, itemInfo.description == null ? '': itemInfo.description, folderHandler.createBoxFileLink(itemInfo.id, OPEN, true, true), folder.id, null);
                fileList.add(item);
            }
        }
        
        return fileList;
    }
    
    /**
	* createBoxCaseFolder - create Box Folder for Knowledge and upload converted matter into the folder
	**/
    public static Boolean createBoxCaseFolder(Id caseId, List<BxdKnowledgeItem> files, Blob convertedFile, String fileName) {
        BoxPlatformApiConnection api = folderHandler.getBoxApi();
        //Create Case folder
        String folderId = createBoxFolderForRecord(caseId);
 
        //copy files to new folder
        if(!String.isBlank(folderId)){
            BoxFolder folder = new BoxFolder(api, folderId);
            copyFiles(api, folder, files);
        }
        //upload file
        if(convertedFile != null && !String.isBlank(folderId)){
            folderHandler.uploadFileToBox(convertedFile, folderId, !String.isBlank(fileName) ? fileName : 'Case_' + caseId + '.pdf');
        }
        //Create external collaboration
        createExternalCollaboration(caseId, folderId);
        
        folderHandler.commitBoxChanges();
        return true;
    }
    
    /**
	* createBoxFolderForRecord - create Box Folder helper method
	**/
    private static String createBoxFolderForRecord(Id caseId) {
        String folderId;
        if(caseId != null){
            //create folder for case record
            folderId = folderHandler.createBoxFolderForRecord(caseId);
            system.debug('FOLDER ' + folderId);
            
            //create collaboration for current user
            Id userId = UserInfo.getUserId();
            if(userId != null){
                box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
                String collabId = folderHandler.createCollaborationOnRecord(userId, caseId, collabType);
                system.debug('Collaboration: ' + collabId + ' for Folder '+folderId);    
            }                  
        }        
        
        return folderId;
    }
    
    /**
	* copyFiles - copy files from fileList into a destination folder.
	**/
    public static void copyFiles(BoxApiConnection api, BoxFolder destination, List<BxdKnowledgeItem> fileList) {  
        for (BxdKnowledgeItem file : fileList) {
            //Get Box File
            BoxFile fileToCopy = new BoxFile(api, file.id);
            //Copy file
            fileToCopy.copy(destination);
        }
    }
    
    /**
	* getBoxFolderContents - another access to download requested files without filename.
	**/
    public static List<BxdKnowledgeItem> getBoxFolderContents(Id caseId) {
        List<BxdKnowledgeItem> fileList = getBoxFolderFiles(caseId);
        return downloadFiles(fileList, false);
    }
    
    /**
	* downloadFiles - download requested files with or without filename. Make sure the files downloaded are within SF Memory limit
	**/
    public static List<BxdKnowledgeItem> downloadFiles(List<BxdKnowledgeItem> fileList, Boolean requestFilename) {  
        System.debug('###downloadFiles and request name ' + requestFilename);
        for (BxdKnowledgeItem file : fileList) {
            //set downloaded file on her class
            Blob b = folderHandler.downloadFile(file.id);
            file.content = b;
            if(requestFilename){
                try{
                    //attempt to get new filename from box
                    BoxFile boxFile = new BoxFile(folderHandler.getBoxApi(), file.id);
                    BoxFile.Info boxFileInfo = (BoxFile.Info) boxFile.getFileInfo();
                    file.name = boxFileInfo.name;
                } catch (Exception e){  
                    System.debug('Failed to get box current filename: ' + e);
                }               
            }
        }
        return fileList;
    }
    
    /**
	* createExternalCollaboration - create external collaboration for Knowledge Management
	**/
    public static void createExternalCollaboration(Id caseId, String folderId) { 
        Case caseObject = [SELECT Id, RecordTypeId, Subject FROM Case WHERE Id=:caseId];
        
        //get folder structure for case type
        List<Box_Folder_Structure__c> folderStructures = folderHandler.getFolderStructures(Case.SObjectType, caseObject.RecordTypeId, true);
        
        //loop throuh folder structure and create subfolders for case
        if(!folderStructures.isEmpty()) {
            String userEmail = UserInfo.getUserEmail();
            for(Box_Folder_Structure__c structure : folderStructures) {
                System.debug('## createExternalCollaboration FS ' + structure);
                
                //only create if folder used for external collaboration was set on FS else create normal folders
                if(!String.isBlank(structure.External_Collaboration_Id__c) && !String.isBlank(userEmail)){
                    BxdExternalCollaborationHelper external = new BxdExternalCollaborationHelper(userEmail, structure.Folder_Name__c + ' - ' + caseObject.Subject, folderId, structure.External_Collaboration_Id__c, null, null);
                    external = folderHandler.createExternalBoxFolder(external);
                } else {
                    folderHandler.createBoxFolder(structure.Folder_Name__c, folderId);
                }      
            }
        }
    }
    
    /**
	* copyCaseFolderToMatter - make a copy of the case folder and attach it inside the matter folder
	**/
    public static Boolean copyCaseFolderToMatter(Id caseId, Id matterId) { 
        //get box api
        BoxPlatformApiConnection api = folderHandler.getBoxApi();
        
        //get case folder
        BoxFolder caseFolder = new BoxFolder(api, folderHandler.getBoxFolderIdByRecordId(caseId));
        
        //get matter folder
        BoxFolder matterFolder = new BoxFolder(api, folderHandler.getBoxFolderIdByRecordId(matterId));
        
        //copy case folder inside matter folder
        if(caseFolder != null && matterFolder != null){
            try{
                //get the case name and number, TODO: get the name from case folder info if this method is called from a large list > 50 
                Case caseObject = [SELECT Id, Subject, CaseNumber FROM Case WHERE Id=:caseId];
                
                //get today's date
                String timestamp = Datetime.now().format(TIMESTAMP_FORMAT);
                
                //copy folder with new name
                BoxFolder.Info copiedFolderInfo = (BoxFolder.Info) caseFolder.copy(matterFolder, caseObject.Subject + ' - ' + caseObject.CaseNumber + ' - [copy] [' + timestamp + ']');
                
                //return true if the file was copied
                return copiedFolderInfo.Id == null? false : true;
            }catch (Exception e) {
                System.debug('***copyCaseFolderToMatter: ' + e);
            }  
        }
        
        return false;
    }
    
    /**
    * FolderHandler - wrapper class for BxdFolderHandler
	**/
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            //the specific constructor in parent will be initialized
            super(true);
        }
    } 
}