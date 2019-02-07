public class BxdCollateralValuationService implements BxdServiceInterface {
    private static final String VALUATION_FS = 'Collateral Valuation Master';
    private static String VALUATION_FOLDER = 'Valuations';
    private static FolderHandler folderHandler = new FolderHandler();
    private static String folderId;
    
    /**
	* createBoxFolderSync - this method takes in a valuation record id then add it to a set then pass this set to createBoxFolder
	**/
    public String createBoxFolderSync(Id recordId){
        Set<String> valuationSet = new Set<String>(); 
        valuationSet.Add(recordId);
        
        createBoxFolder(valuationSet, true);
        
        system.debug('####*CREATE MANUAL BOX FOLDER BxdCollateralValuationService*#### '+folderId);
        return folderId;
    }
    
    /**
    * createBoxFolderTrigger - prepares a set of collateralValuation records id, then pass it to createBoxFolderTrigger
	**/
    public static  void createBoxFolderTrigger(List<Collateral_Valuation__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(Collateral_Valuation__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolderTrigger(recordsSet);
        }  
    }
    
    /**
    * createBoxFolderTrigger - this method executes asynchronously, pass the valuation records id set to createBoxFolder
	**/
    @Future(callout = true)
    public static  void createBoxFolderTrigger(Set<String> valuationSet) {
        createBoxFolder(valuationSet, false);
    }
    
    /**
    * createBoxFolder - this method create box folder for each valuation record, then save box changes after
	**/
    public static  void createBoxFolder(Set<String> recordsSet, Boolean collaborate) {
        Collateral_Valuation__c valuation;
        List<Collateral_Valuation__c> recordsList = new List<Collateral_Valuation__c>([SELECT Id, Name, Collateral__c FROM Collateral_Valuation__c where Id in: recordsSet]);
        
        Box_Folder_Structure__c valuationStructure;
        String parentFolderId;
        String customKey;      
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
        
        if(recordsList !=null && !recordsList.isEmpty()) {
            valuation = recordsList[0];
            valuationStructure = folderHandler.getFolderStructure(VALUATION_FS);
            System.debug('##VALUATION STRUCT '+valuationStructure);
            
            if(valuation != null && valuationStructure != null && valuation.Collateral__c != null && valuationStructure.Folder_Name__c != null) {
                customKey = valuation.Collateral__c + ' - ' + valuationStructure.Folder_Name__c;
                
                String queryWhere = '%' + valuation.Collateral__c + '%';
                details = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c 
                           FROM Custom_FRUP__c WHERE CustomKey__c like :queryWhere];
                
                parentFolderId = folderHandler.getBoxFolderIdByRecordId(valuation.Collateral__c);
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
        System.debug('##FRUP MAP '+frupMap);   
        //Keep parent folder
        String staticValuationFolderId;
        for (Collateral_Valuation__c valuationObject : recordsList) {
            staticValuationFolderId = createBoxFolderForRecord(valuationObject, valuationStructure, parentFolderId, staticValuationFolderId, frupMap, collaborate);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        if(!String.isBlank(staticValuationFolderId)) {
            //add to custom folder details
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticValuationFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for valuation record, dependant on the frup.
    * It also create collaboration on the record
	**/
    public static String createBoxFolderForRecord(Collateral_Valuation__c valuation, Box_Folder_Structure__c valuationStructure, String parentFolderId, String staticValuationFolderId, Map<String, List<Custom_FRUP__c>> customFRUPMap, Boolean collaborate) {
        if(valuation != null && !String.isBlank(parentFolderId)){
            String folderId;
            //Select custom folder name for this record type                
            if(valuationStructure != null){
                VALUATION_FOLDER = valuationStructure.Folder_Name__c;
            }
            
            String customKey = valuation.Collateral__c + ' - ' + VALUATION_FOLDER;
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            System.debug('***FRUP HERE1 '+frups);
            System.debug('***STATIC FOLDER '+staticValuationFolderId);
            System.debug('***CUSTOM KEY HERE '+customKey);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticValuationFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(valuation.Id, valuation.Name, details.FolderId__c);
                } else if(!String.isBlank(staticValuationFolderId)){
                    folderId = folderHandler.createBoxFolder(valuation.Id, valuation.Name, staticValuationFolderId);      
                }
                //link folder to record
                System.debug('**EXISTING LINKING VALUATION: '+valuation.Id+ ' and folder: '+folderId);
                folderHandler.linkBoxFolderToSalesforceRecord(valuation.Id, folderId);
            } else {
                //create holding folder
                staticValuationFolderId = folderHandler.createBoxFolder(VALUATION_FOLDER, parentFolderId);
                //create record folder
                folderId = folderHandler.createBoxFolder(valuation.Id, valuation.Name, staticValuationFolderId);
                System.debug('**NEW LINKING VALUATION: '+valuation.Id+ ' and folder: '+folderId);
                folderHandler.linkBoxFolderToSalesforceRecord(valuation.Id, folderId);
            } 
            System.debug('***NEW FOLDER '+folderId);
        }
        
        if(collaborate){
            try{
                Id userId = UserInfo.getUserId();
                box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
                String collabId = folderHandler.createCollaborationOnRecord(userId, valuation.Id, collabType);
                system.debug('matter new collaboration id: ' + collabId);
            } catch (Exception e){
                system.debug('Collaboration issue on valuation: '+e);
            }    
        }
        
        System.debug('***STATIC FOLDER '+staticValuationFolderId);
        
        return staticValuationFolderId;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}