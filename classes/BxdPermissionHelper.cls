/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Help with folder permissions , this is to protect BxdPermissionHandler from making callout to BoxAPI when initialised 
* @Date:        2018
*/
public class BxdPermissionHelper {
    //init BxdFolderHandler
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
    * FolderHandler - verify that a collaboration is still valid
    **/
    public static void validateCollaboration(Id salesforceUser, Id salesforceRecord, String boxCollaboration, box.Toolkit.CollaborationType collaborationType) {
        //check if collaboration was not found
        Boolean notFound = folderHandler.checkCollaboration(boxCollaboration);
        
        if(notFound){
            String boxUser;
            String folderId;
            box__FRUP__c frup = folderHandler.getBoxUser(salesforceUser);
            if(frup != null){
                boxUser = frup.box__Box_user__c;
                folderId = folderHandler.getBoxFolderIdByRecordIdForCustomUI(salesforceRecord);
                System.debug('***BOX USER ' + boxUser + ' - BOX FOLDER ' + folderId);              
                
                //create missing collaboration
                if(!String.isBlank(folderId) && !String.isBlank(boxUser)){
                    folderHandler.createCollaborationOnUser(folderId, boxUser, collaborationType);
                }
            }
        }  
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