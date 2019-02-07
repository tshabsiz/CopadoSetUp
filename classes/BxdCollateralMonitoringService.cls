public class BxdCollateralMonitoringService implements BxdServiceInterface {
    private static final String MONITORING_FS = 'Collateral Monitoring Master';
    private static String MONITORING_FOLDER = 'Monitorings';
    private static FolderHandler folderHandler = new FolderHandler();
    private static PermissionHandler permissionHandler = new PermissionHandler();  
    private static String folderId;
    
    /**
	* createBoxFolderSync - this method takes in a collateralMonitoring record id then add it to a set then pass this set to createBoxFolder
	**/
    public String createBoxFolderSync(Id recordId){
        Set<String> monitoringSet = new Set<String>(); 
        monitoringSet.Add(recordId);
        
        createBoxFolder(monitoringSet);
        
        system.debug('####*CREATE MANUAL BOX FOLDER BxdCollateralMonitoringService*#### '+folderId);
        return folderId;
    }
    
    /**
    * createBoxFolderTrigger - prepares a set of collateralMonitoring records id, then pass it to createBoxFolderTrigger
	**/
    public static  void createBoxFolderTrigger(List<Collateral_Monitoring__c> recordList) {
        if(recordList != null && !recordList.isEmpty()){
            Set<String> recordsSet = new Set<String>();
            for(Collateral_Monitoring__c objectRecord : recordList){
                recordsSet.Add(objectRecord.Id);             
            }
            
            createBoxFolderTrigger(recordsSet);
        }  
    }
    
    /**
    * createBoxFolderTrigger - this method executes asynchronously, pass the collateralMonitoring records id set to createBoxFolder
	**/
    @Future(callout = true)
    public static  void createBoxFolderTrigger(Set<String> monitoringSet) {
        createBoxFolder(monitoringSet);
    }
    
    /**
    * createBoxFolder - this method create box folder for each collateralMonitoring record, then save box changes after
	**/
    public static  void createBoxFolder(Set<String> recordsSet) {
        Collateral_Monitoring__c monitoring;
        List<Collateral_Monitoring__c> recordsList = new List<Collateral_Monitoring__c>([SELECT Id, Name, Collateral__c FROM Collateral_Monitoring__c where Id in: recordsSet]);
        
        Box_Folder_Structure__c monitoringStructure;
        String parentFolderId;
        String customKey;      
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
        
        if(recordsList !=null && !recordsList.isEmpty()) {
            monitoring = recordsList[0];
            monitoringStructure = folderHandler.getFolderStructure(MONITORING_FS);
            if(monitoring != null && monitoringStructure != null && monitoring.Collateral__c != null && monitoringStructure.Folder_Name__c != null) {
                customKey = monitoring.Collateral__c + ' - ' + monitoringStructure.Folder_Name__c;
                
                String queryWhere = '%' + monitoring.Collateral__c + '%';
                details = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c 
                           FROM Custom_FRUP__c WHERE CustomKey__c like :queryWhere];
                
                parentFolderId = folderHandler.getBoxFolderIdByRecordId(monitoring.Collateral__c);
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
        System.debug('FRUP MAP '+frupMap);   
        //Keep parent folder
        String staticMonitoringFolderId;
        for (Collateral_Monitoring__c monitoringObject : recordsList) {
            staticMonitoringFolderId = createBoxFolderForRecord(monitoringObject, monitoringStructure, parentFolderId, staticMonitoringFolderId, frupMap);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        //add to custom folder details
        if(!String.isBlank(staticMonitoringFolderId)) {
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticMonitoringFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for collateralMonitoring record, dependant on the frup.
	**/
    public static String createBoxFolderForRecord(Collateral_Monitoring__c monitoring, Box_Folder_Structure__c monitoringStructure, String parentFolderId, String staticMonitoringFolderId, Map<String, List<Custom_FRUP__c>> customFRUPMap) {
        if(monitoring != null && !String.isBlank(parentFolderId)){
            //Select custom folder name for this record type                
            if(monitoringStructure != null){
                MONITORING_FOLDER = monitoringStructure.Folder_Name__c;
            }
            
            String customKey = monitoring.Collateral__c + ' - ' + MONITORING_FOLDER;
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            System.debug('***FRUP '+frups);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticMonitoringFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = folderHandler.createBoxFolder(monitoring.Id, monitoring.Name, details.FolderId__c);
                } else if(!String.isBlank(staticMonitoringFolderId)){
                    folderId = folderHandler.createBoxFolder(monitoring.Id, monitoring.Name, staticMonitoringFolderId);      
                }
                //link folder to record
                System.debug('**EXISTING MONITORING: '+monitoring.Id+ ' and folder: '+folderId);
                folderHandler.linkBoxFolderToSalesforceRecord(monitoring.Id, folderId);
            } else {
                //create holding folder
                staticMonitoringFolderId = folderHandler.createBoxFolder(MONITORING_FOLDER, parentFolderId);
                //create record folder
                folderId = folderHandler.createBoxFolder(monitoring.Id, monitoring.Name, staticMonitoringFolderId);
                System.debug('**NEW LINKING MONITORING: '+monitoring.Id+ ' and folder: '+folderId);
                folderHandler.linkBoxFolderToSalesforceRecord(monitoring.Id, folderId);
            } 
            System.debug('***CREATED FOLDER '+folderId);
        }
        
        System.debug('***STATIC FOLDER '+staticMonitoringFolderId);
        
        return staticMonitoringFolderId;
    }
    
    /**
    * createBoxPermission - used to make an external call to createPermissionForUser in BxdPermissionHandler
	**/
    public static void createBoxPermission(Id monitoringId){
        if (monitoringId != null){
            permissionHandler.createPermissionForUser(monitoringId);
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