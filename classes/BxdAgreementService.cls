/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Service the Agreement folder creation, agreement folders are linked to an agreement record. Folders are created from trigger calls and visualforce createBoxFolderSync
* @Date:        2017
*/
public class BxdAgreementService implements BxdServiceInterface {
    private static String AGREEMENT_FOLDER = 'Agreements';
    private static FolderHandler folderHandler = new FolderHandler();
    private static String folderId;
    
    /**
	* createBoxFolderSync - this method takes in a agreement record id then add it to a set then pass this set to createBoxFolder
	**/
    public String createBoxFolderSync(Id recordId){
        Set<String> agreementSet = new Set<String>(); 
        agreementSet.Add(recordId);
        
        createBoxFolder(agreementSet, true);
        
        system.debug('####*CREATE MANUAL BOX FOLDER BxdAgreementService*#### '+folderId);
        return folderId;
    }
    
    /**
    * createBoxFolderTrigger - prepares a set of agreement records id, then pass it to createBoxFolderTrigger
	**/
    public static  void createBoxFolderTrigger(List<Agreement__c> agreementList) {
        Set<String> agreementSet = new Set<String>(); 
        for(Agreement__c ag : agreementList){
            agreementSet.Add(ag.id);             
        }
        
        createBoxFolderTrigger(agreementSet);
    }
    
    /**
    * createBoxFolderTrigger - this method executes asynchronously, pass the agreement records id set to createBoxFolder
	**/
    @Future(callout = true)
    public static  void createBoxFolderTrigger(Set<String> agreementSet) {
        createBoxFolder(agreementSet, false);
    }
    
    /**
    * createBoxFolder - this method create box folder for each agreement record, then save box changes after
	**/    
    public static void createBoxFolder(Set<String> agreementSet, Boolean collaborate) {
        Agreement__c agreement;       
        List<Agreement__c> agreementList = new List<Agreement__c>([SELECT Id, Name, Matter_Deal__c, RecordTypeId FROM Agreement__c where id in: agreementSet Order by Matter_Deal__c ASC]);
        
        System.debug('### BxdAgreementService : createBoxFolderTrigger : agreementList : '+agreementList);
        
        //Agreement Folder Structure
        Box_Folder_Structure__c agreementStructure;
        String parentFolderId;
        String customKey;
        List<Custom_FRUP__c> details = new List<Custom_FRUP__c>();
        if(agreementList !=null && !agreementList.isEmpty()) 
        {
            agreement = agreementList[0];
            agreementStructure = folderHandler.getFolderStructure(Agreement__c.SObjectType, agreement.RecordTypeId);
            
            if(agreement != null && agreementStructure != null && agreement.Matter_Deal__c != null && agreementStructure.Folder_Name__c != null){
                //build custom frup where query
                String queryWhere = '%' + agreement.Matter_Deal__c + '%'; 
                
                //select the custom frup
                details = [SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c 
                           FROM Custom_FRUP__c WHERE CustomKey__c like :queryWhere];
                
                //Set the parent folder for agreements
                parentFolderId = folderHandler.getBoxFolderIdByRecordId(agreement.Matter_Deal__c);
                
                //set the folder name
                AGREEMENT_FOLDER = agreementStructure.Folder_Name__c;
                
                //Set the custom key to fetch Custom FRUP
                customKey = agreement.Matter_Deal__c + ' - ' + AGREEMENT_FOLDER;
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
        
        //Keep parent folder
        String staticAgreeentFolderId;
        for (Agreement__c agreementObject : agreementList) {
            staticAgreeentFolderId = createBoxFolderForRecord(agreementObject, customKey, parentFolderId, staticAgreeentFolderId, frupMap, collaborate);             
        }
        
        // persist Box changes
        folderHandler.commitBoxChanges();
        if(!String.isBlank(staticAgreeentFolderId)) {
            //add to custom folder details
            Custom_FRUP__c cfd = new Custom_FRUP__c(CustomKey__c = customKey, FolderId__c = staticAgreeentFolderId, ParentFolderId__c = parentFolderId);
            insert cfd;
        }
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for agreement record, dependant on the frup.
    * It also create collaboration on the record, add collaborator as Editor
	**/
    public static String createBoxFolderForRecord(Agreement__c agreement, String customKey, String parentFolderId, String staticAgreeentFolderId, Map<String, List<Custom_FRUP__c>> customFRUPMap, Boolean collaborate) {
        if(agreement != null && !String.isBlank(parentFolderId)){
            //get the custom frup from map
            List<Custom_FRUP__c> frups = customFRUPMap.get(customKey);
            if ((frups != null && !frups.isEmpty()) || !String.isBlank(staticAgreeentFolderId)){
                if (frups != null && !frups.isEmpty()) {
                    Custom_FRUP__c details = frups[0];
                    folderId = createBoxFolder(agreement, details.FolderId__c);
                } else if(!String.isBlank(staticAgreeentFolderId)){
                    folderId = createBoxFolder(agreement, staticAgreeentFolderId);     
                }
                //link folder to record
                folderHandler.linkBoxFolderToSalesforceRecord(agreement.Id, folderId);
            } else {
                //create holding folder
                staticAgreeentFolderId = folderHandler.createBoxFolder(AGREEMENT_FOLDER, parentFolderId);
                //create record folder
                folderId = createBoxFolder(agreement, staticAgreeentFolderId);
                folderHandler.linkBoxFolderToSalesforceRecord(agreement.Id, folderId);
            } 
        }
        
        if(collaborate){
            try{
                Id userId = UserInfo.getUserId();
                box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
                String collabId = folderHandler.createCollaborationOnRecord(userId, agreement.Id, collabType);
                system.debug('matter new collaboration id: ' + collabId);
            } catch (Exception e){
                system.debug('Collaboration issue on agreement: '+e);
            }    
        }
        
        return staticAgreeentFolderId;
    }
    
    /**
    * createBoxFolder - this method create box folder for agreement record received
	**/
    private static String createBoxFolder(Agreement__c agreement, String parentFolderId){
        String boxFolderId = folderHandler.createBoxFolder(agreement.Name, parentFolderId);
        if(boxFolderId == null) {
            String timestamp = 'hhmmssSSS';
            timestamp = Datetime.now().format(timestamp);
            String folderName = agreement.Name + '_' + agreement.Id + '_' + timestamp;
            //Attempt to create folder again with record id
            boxFolderId = folderHandler.createBoxFolder(folderName, parentFolderId);
        }
        return boxFolderId;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}