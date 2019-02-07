/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: This class helps to protect BxdMatterDealService as that class make callouts when initialized
* @Date:        2017
*/
public class BxdMatterService {
    private static final String LITIGATION_RECORDTYPE_NAME = 'Litigation Matter';
    private static FolderHandler folderHandler = new FolderHandler();
    
    /**
    * createBoxFolderTrigger - prepares a set of matter records id, then pass it to createBoxFolder
	**/
    public static  void createBoxFolderTrigger(List<advpm__Matter__c> matterList) {
        Set<String> matterSet = new Set<String>();
        for(advpm__Matter__c matter : matterList){
            matterSet.Add(matter.Id);             
        }
        
        createBoxFolder(matterSet);
    }
        
    /**
    * createBoxFolder - this method executes asynchronously, it create box folder for each matter record, then save box changes after
	**/
    @Future(callout = true)
    public static  void createBoxFolder(Set<String> matterSet) {               
        List<advpm__Matter__c> matterList = new List<advpm__Matter__c>([SELECT Id, Name, Matter_ID__c, RecordTypeId, Imported_Data__c, Owner.Id FROM advpm__Matter__c where Id in: matterSet]);

        for (advpm__Matter__c matter : matterList) {
            try{
                //We don't want to create folders for Litigation Matter from here as they are creating synchronously in BxdMatterDealService
                Id LitigationRecordTypeId = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(LITIGATION_RECORDTYPE_NAME).getRecordTypeId();
                
                //check that we don't create folders for litigation recordtypes or imported data
                if(LitigationRecordTypeId != matter.RecordTypeId || (matter != null && matter.Imported_Data__c)){
                    //create matter folder
                    BxdMatterDealService.MatterDealHelper helper = BxdMatterDealService.createBoxFolderForRecord(matter, true);
                    
                    //set collaboration folder id
                    matter.External_Collaboration_Id__c = helper.externalFolderId;
                }
            }catch (Exception e) {
                System.debug('***BxdMatterService Matter Folder Creation Failed: '+e);
            }           
        }
        
        system.debug('***Commit Box Changes in BxdMatterService');
        folderHandler.commitBoxChanges(); 
        
        //update matters
        update matterList;
    }
    
    /**
    * FolderHandler - wrapper class for BxdFolderHandler
	**/
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}