public class BxdDrawdownService {
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
    * createBoxFolder - this method executes asynchronously, pass the drawDown record id to createBoxFolderForRecord
	**/
    @Future(callout = true)
    public static void createBoxFolder(Id recordId) {
        createBoxFolderForRecord(recordId);
    }
	    
    /**
    * createBoxFolderForRecord - this method create box folder for the passed drawDown record id by calling createBoxFolderForRecord in BxdFolderHandler
	**/
    public static String createBoxFolderForRecord(Id recordId) {
        String folderId;
        if(recordId != null){
            folderId = folderHandler.createBoxFolderForRecord(recordId);
            folderHandler.commitBoxChanges();
        }
        return folderId;
    }
    
  
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }    
}