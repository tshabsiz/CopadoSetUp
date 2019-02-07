public class BxdCollateralService implements BxdServiceInterface {
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
	* createBoxFolderSync - this method takes in a collateral record id then create a box folder for this record
	**/
    public String createBoxFolderSync(Id recordId){
        
        String folderId = createBoxFolderForRecord(recordId, true);
        folderHandler.commitBoxChanges();
        
        return folderId;
    }
    
    /**
    * createBoxFolderTrigger - prepares a set of collateralValuation records id, then pass it to createBoxFolder
	**/
    public static  void createBoxFolderTrigger(List<Collateral__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(Collateral__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolder(recordsSet);
        }  
    }
    
    /**
    * createBoxFolder - this method executes asynchronously, it create box folder for each collateral record, then save box changes after
	**/
    @Future(callout = true)
    public static  void createBoxFolder(Set<String> collateralSet) {               
        List<Collateral__c> collateralList = new List<Collateral__c>([SELECT Id, Name FROM Collateral__c where Id in: collateralSet]);

        for (Collateral__c collateral : collateralList) {
            try{
                createBoxFolderForRecord(collateral.Id, false);
            }catch (Exception e) {
                System.debug('***COLLATERAL FAILED ON Box.com '+e);
            }           
        }
        
        system.debug('***COMMIT COLLATERAL SERVICE');
        folderHandler.commitBoxChanges();    
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for collateral record passed.
    * It also create collaboration on the record, add collaborator as Editor
	**/
    public static String createBoxFolderForRecord(Id recordId, Boolean collaborate) {
        String folderId;
        if(recordId != null){
            folderId = folderHandler.createBoxFolderForRecord(recordId);
            
            if(collaborate){
                try{
                    Id userId = UserInfo.getUserId();
                    box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
                    String collabId = folderHandler.createCollaborationOnRecord(userId, recordId, collabType);
                    system.debug('collateral new collaboration id: ' + collabId);
                } catch (Exception e){
                    system.debug('Collaboration issue on collateral: '+e);
                }    
            }
        }
        
        return folderId;
    }
    
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }    
}