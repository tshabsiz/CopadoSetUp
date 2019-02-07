public class BxdWatcherService implements BxdServiceInterface {
    private static String WATCHER_FOLDER = 'Watchers';
    private static String VALUATION_LOOKUP = 'Collateral_Valuation__c';
    private static String MONITORING_LOOKUP = 'Collateral_Monitoring__c';
    private static String TRIGGER_LOOKUP = 'Trigger__c';
    private static String RATCHET_LOOKUP = 'Margin_Ratchet__c';
    private static FolderHandler folderHandler = new FolderHandler();
    private static String folderId;
    
    /**
	* createBoxFolderSync - this method takes in a watcher record id then add it to a set then pass this set to createBoxFolder
	**/
    public String createBoxFolderSync(Id recordId){
        Set<String> watchetSet = new Set<String>(); 
        watchetSet.Add(recordId);
        
        createBoxFolder(watchetSet, true);
        
        system.debug('####*CREATE MANUAL BOX FOLDER BxdWatcherService*#### '+folderId);
        return folderId;
    }
    
    /**
    * createBoxFolderTrigger - prepares a set of watcher records id, then pass it to createBoxFolder
	**/
    public static  void createBoxFolderTrigger(List<Watcher__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(Watcher__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolderTrigger(recordsSet);
        }  
    }
    
    /**
    * createBoxFolderTrigger - this method executes asynchronously, pass the watcher records id set to createBoxFolder
	**/
    @Future(callout = true)
    public static  void createBoxFolderTrigger(Set<String> watchetSet) {
        createBoxFolder(watchetSet, false);
    }
    
    /**
    * createBoxFolder - this method create box folder for each watcher record, then save box changes after
	**/
    public static  void createBoxFolder(Set<String> recordsSet, Boolean collaborate) {
        Watcher__c watcher;
        List<Watcher__c> recordsList = new List<Watcher__c>([SELECT Id, Name, Collateral_Monitoring__r.Collateral__c, Collateral_Valuation__r.Collateral__c, Trigger__r.Agreement__c, Margin_Ratchet__r.Agreement__c, Margin_Ratchet__r.Facility__c, Margin_Ratchet__r.Facility_Tranche__c, RecordTypeId FROM Watcher__c where Id in: recordsSet]);
        
        Box_Folder_Structure__c watcherStructure;
        String parentFolderId;
        String customKey;
        String queryWhere;
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
        
        if(recordsList !=null && !recordsList.isEmpty())
        {
            watcher = recordsList[0];
            
            String recordTypeName = Watcher__c.sObjectType.getDescribe().getRecordTypeInfosById().get(watcher.RecordTypeId).getName();
            
            System.debug(' ## WATCHER RECORD TYPE:'+recordTypeName);
            
            watcherStructure = folderHandler.getFolderStructure(recordTypeName);
            
            if(watcher != null && watcherStructure != null && watcherStructure.Folder_Name__c != null){
                //Get the static parent folder for watchers based on parent lookup
                WATCHER_FOLDER = watcherStructure.Folder_Name__c;
                Id marginRatchetParent = getMarginRatchetParent(watcher.Margin_Ratchet__r.Agreement__c, watcher.Margin_Ratchet__r.Facility__c, watcher.Margin_Ratchet__r.Facility_Tranche__c);
                System.debug('##WATCHER LOOKUP '+watcherStructure.Parent_Lookup__c);
                System.debug('##WATCHER VALUATION PARENT ID ' + watcher.Collateral_Valuation__r.Collateral__c);	
                System.debug('##WATCHER MONITORING PARENT ID ' + watcher.Collateral_Monitoring__r.Collateral__c);	
                System.debug('##WATCHER TRIGGER PARENT ID ' + watcher.Trigger__r.Agreement__c);	
                System.debug('##WATCHER RATCHET PARENT ID ' + marginRatchetParent);	
                if(VALUATION_LOOKUP.equals(watcherStructure.Parent_Lookup__c) && watcher.Collateral_Valuation__r.Collateral__c != null){
                    customKey = watcher.Collateral_Valuation__r.Collateral__c + ' - ' + WATCHER_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(watcher.Collateral_Valuation__r.Collateral__c);
                    queryWhere = '%' + watcher.Collateral_Valuation__r.Collateral__c + '%';
                } else if(MONITORING_LOOKUP.equals(watcherStructure.Parent_Lookup__c) && watcher.Collateral_Monitoring__r.Collateral__c != null){
                    customKey = watcher.Collateral_Monitoring__r.Collateral__c + ' - ' + WATCHER_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(watcher.Collateral_Monitoring__r.Collateral__c);
                    queryWhere = '%' +  watcher.Collateral_Monitoring__r.Collateral__c + '%';
                } else if(TRIGGER_LOOKUP.equals(watcherStructure.Parent_Lookup__c) && watcher.Trigger__r.Agreement__c != null){
                    customKey = watcher.Trigger__r.Agreement__c + ' - ' + WATCHER_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(watcher.Trigger__r.Agreement__c);
                    queryWhere = '%' + watcher.Trigger__r.Agreement__c + '%';
                } else if(RATCHET_LOOKUP.equals(watcherStructure.Parent_Lookup__c) && marginRatchetParent != null){
                    customKey = marginRatchetParent + ' - ' + WATCHER_FOLDER;
                    parentFolderId = folderHandler.getBoxFolderIdByRecordId(marginRatchetParent);
                    queryWhere = '%' + marginRatchetParent + '%';
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
        String staticWatcherFolderId;
        for (Watcher__c watcherObject : recordsList) {
            staticWatcherFolderId = createBoxFolderForRecord(watcherObject, parentFolderId, staticWatcherFolderId, customKey, frupMap, collaborate);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        if(!String.isBlank(staticWatcherFolderId)) {
            //add to custom folder details
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticWatcherFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for watcher record, dependant on the frup.
    * It also create collaboration on the record
	**/
    public static String createBoxFolderForRecord(Watcher__c watcher, String parentFolderId, String staticWatcherFolderId, String customKey, Map<String, List<Custom_FRUP__c>> customFRUPMap, Boolean collaborate) {
        if(watcher != null && !String.isBlank(parentFolderId)){
            
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticWatcherFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(watcher.Id, watcher.Name, details.FolderId__c);
                } else if(!String.isBlank(staticWatcherFolderId)){
                    folderId = folderHandler.createBoxFolder(watcher.Id, watcher.Name, staticWatcherFolderId);      
                }
                //link folder to record
                folderHandler.linkBoxFolderToSalesforceRecord(watcher.Id, folderId);
            } else {
                //create holding folder
                staticWatcherFolderId = folderHandler.createBoxFolder(WATCHER_FOLDER, parentFolderId);
                //create record folder
                folderId = folderHandler.createBoxFolder(watcher.Id, watcher.Name, staticWatcherFolderId);
                folderHandler.linkBoxFolderToSalesforceRecord(watcher.Id, folderId);
            } 
            System.debug('### folder : '+folderId);
        }
        
        if(collaborate){
            try{
                Id userId = UserInfo.getUserId();
                box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
                String collabId = folderHandler.createCollaborationOnRecord(userId, watcher.Id, collabType);
                system.debug('matter new collaboration id: ' + collabId);
            } catch (Exception e){
                system.debug('Collaboration issue on watcher: '+e);
            }    
        }
        
        System.debug('### static folder : '+staticWatcherFolderId);
        
        return staticWatcherFolderId;
    }
    
    /**
    * getMarginRatchetParent - used to search for margin ratchet parent id then return it, between tranche, facility and agreement
	**/
    public static Id getMarginRatchetParent(Id agreement, Id facility, Id tranche){
        if(agreement != null && facility != null && tranche != null){
            return tranche;
        } else if(agreement != null && facility != null){
            return facility;
        } else if(agreement != null){
            return agreement;
        }
        return null;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}