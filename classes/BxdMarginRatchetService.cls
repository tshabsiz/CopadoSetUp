public class BxdMarginRatchetService implements BxdServiceInterface {
    private static String RATCHET_FOLDER = 'Margin Ratchets';
    private static FolderHandler folderHandler = new FolderHandler();
    private static String folderId;
    
    /**
	* createBoxFolderSync - this method takes in a marginRatchet record id then add it to a set then pass this set to createBoxFolder
	**/
    public String createBoxFolderSync(Id recordId){
        Set<String> ratchetSet = new Set<String>(); 
        ratchetSet.Add(recordId);
        
        createBoxFolder(ratchetSet);
        
        system.debug('####*CREATE MANUAL BOX FOLDER BxdMarginRatchetService*#### '+folderId);
        return folderId;
    }
    
    /**
    * createBoxFolderTrigger - prepares a set of marginRatchet records id, then pass it to createBoxFolderTrigger
	**/
    public static  void createBoxFolderTrigger(List<Margin_Ratchet__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(Margin_Ratchet__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolderTrigger(recordsSet);
        }  
    }
    
    /**
    * createBoxFolderTrigger - this method executes asynchronously, pass the marginRatchet records id set to createBoxFolder
	**/
    @Future(callout = true)
    public static  void createBoxFolderTrigger(Set<String> ratchetSet) {
        createBoxFolder(ratchetSet);
    }
    
    /**
    * createBoxFolder - this method create box folder for each marginRatchet record, then save box changes after
	**/
    public static  void createBoxFolder(Set<String> recordsSet) {
        Margin_Ratchet__c ratchet;
        List<Margin_Ratchet__c> recordsList = new List<Margin_Ratchet__c>([SELECT Id, Name, Agreement__c, Facility__c, Facility_Tranche__c, RecordTypeId FROM Margin_Ratchet__c where Id in: recordsSet]);
        
        Box_Folder_Structure__c ratchetStructure;
        String parentFolderId;
        String customKey;
        String queryWhere;
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
        
        if(recordsList !=null && !recordsList.isEmpty())
        {
            ratchet = recordsList[0];
            
            String recordTypeName = Margin_Ratchet__c.sObjectType.getDescribe().getRecordTypeInfosById().get(ratchet.RecordTypeId).getName();
            
            System.debug(' ## RATCHET RECORD TYPE:'+recordTypeName);
            
            ratchetStructure = folderHandler.getFolderStructure(recordTypeName);
            if(ratchet != null && ratchetStructure != null && ratchetStructure.Folder_Name__c != null){
                 RATCHET_FOLDER = ratchetStructure.Folder_Name__c;
                System.debug('RATCHET FOLDER '+ RATCHET_FOLDER);    
                if(ratchet.Agreement__c != null && ratchet.Facility__c != null && ratchet.Facility_Tranche__c != null){
                    customKey = ratchet.Facility_Tranche__c + ' - ' + RATCHET_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(ratchet.Facility_Tranche__c);
                    queryWhere = '%' + ratchet.Facility_Tranche__c + '%';
                } else if(ratchet.Agreement__c != null && ratchet.Facility__c != null){
                    customKey = ratchet.Facility__c + ' - ' + RATCHET_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(ratchet.Facility__c);
                    queryWhere = '%' + ratchet.Facility__c + '%';
                } else if(ratchet.Agreement__c != null){
                    customKey = ratchet.Agreement__c + ' - ' + RATCHET_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(ratchet.Agreement__c);
                    queryWhere = '%' + ratchet.Agreement__c + '%';
                }
                
                details = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c 
                           FROM Custom_FRUP__c WHERE CustomKey__c like :queryWhere];
                
            }           
            System.debug('### PARENT FOLDERID: '+parentFolderId);
            System.debug('### customKey : '+customKey);
        }
        
        Map<String, List<Custom_FRUP__c>> frupMap = new Map<String, List<Custom_FRUP__c>>();
        List<Custom_FRUP__c> lst;
        for(Custom_FRUP__c l : details) {
            if(frupMap.get(l.CustomKey__c)==null){
                lst = new List<Custom_FRUP__c>();
            }            
            lst.Add(l);
            frupMap.put(l.CustomKey__c,lst);       
        }
        System.debug('###FRUP MAP '+frupMap);   
        //Keep parent folder
        String staticRatchetFolderId;
        for (Margin_Ratchet__c ratchetObject : recordsList) {
            staticRatchetFolderId = createBoxFolderForRecord(ratchetObject, parentFolderId, staticRatchetFolderId, customKey, frupMap);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        if(!String.isBlank(staticRatchetFolderId)) {
            //add to custom folder details
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticRatchetFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for marginRatchet record, dependant on the frup
	**/
    public static String createBoxFolderForRecord(Margin_Ratchet__c ratchet, String parentFolderId, String staticRatchetFolderId, String customKey, Map<String, List<Custom_FRUP__c>> customFRUPMap) {
        if(ratchet != null && !String.isBlank(parentFolderId)){
            
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticRatchetFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(ratchet.Id, ratchet.Name, details.FolderId__c);
                } else if(!String.isBlank(staticRatchetFolderId)){
                    folderId = folderHandler.createBoxFolder(ratchet.Id, ratchet.Name, staticRatchetFolderId);      
                }
                //link folder to record
                folderHandler.linkBoxFolderToSalesforceRecord(ratchet.Id, folderId);
            } else {
                //create holding folder
                staticRatchetFolderId = folderHandler.createBoxFolder(RATCHET_FOLDER, parentFolderId);
                //create record folder
                folderId = folderHandler.createBoxFolder(ratchet.Id, ratchet.Name, staticRatchetFolderId);
                folderHandler.linkBoxFolderToSalesforceRecord(ratchet.Id, folderId);
            } 
            System.debug('### record folder : '+folderId);
        }
        
        System.debug('### static folder : '+staticRatchetFolderId);
        
        return staticRatchetFolderId;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}