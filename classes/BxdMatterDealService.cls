/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Service the Legal Matter, Litigation Matter and Deal object with folder creation, participants collaboration and legal hold
* @Date:        2017
*/
public class BxdMatterDealService implements BxdServiceInterface {
    private static final String DEAL_RECORDTYPE_NAME = 'Deal';
    private static final String LEGAL_HOLD_ASSIGNMENT_TYPE = 'folder';
    private static FolderHandler folderHandler = new FolderHandler();
    private static PolicyHandler policyHander = new PolicyHandler();
    private static PermissionHandler permissionHander = new PermissionHandler();
    
    /**
	* createBoxFolderSync - this method takes in a matter record id then call createBoxFolderForRecord passing the matter record, then save box changes
	**/
    public static String createBoxFolderSync(Id recordId) {
        //Select matter record
        advpm__Matter__c matter = [SELECT Id, Name, Matter_ID__c, RecordTypeId, Owner.Id  FROM advpm__Matter__c WHERE Id=:recordId];
        
        MatterDealHelper helper = createBoxFolderForRecord(matter, true);
        
        //commit box changes
        folderHandler.commitBoxChanges();
        
        //update matter
        matter.External_Collaboration_Id__c = helper.externalFolderId;
        update matter;
        
        return helper.folderURL;
    }
    
    /**
    * createBoxFolderForRecord - used to create a box folder for matter record, dependant on the folder structure creates an external box folder or conventional box folder
    * It also create collaboration on the record, add collaborator as an editor
	**/
    public static MatterDealHelper createBoxFolderForRecord(advpm__Matter__c matter, Boolean createCollaboration) {
        String folderId;
        String externalFolderId;
        String folderURL;
        if(matter != null){
            //create matter or deal folder
            folderId = folderHandler.createBoxFolderForRecord(matter.Id);

            //matter failed to create, attempt to create again with unique name
            if(String.isBlank(folderId)){
                //get the root folder for matters
                String matterParentFolderId = folderHandler.getObjectFolderByBoxFolderId(matter.Id);
                
                //create the folder with matter id
                folderId = folderHandler.createBoxFolder(matter.Name + ' - [' + matter.Matter_ID__c + ']', matterParentFolderId);
                
                //link folder to salesforce record
                folderHandler.linkBoxFolderToSalesforceRecord(matter.Id, folderId);
            }
            
            //only create subfolders and collaboration if we have a folder
            if(!String.isBlank(folderId)){
                List<Box_Folder_Structure__c> folderStructures = folderHandler.getFolderStructures(advpm__Matter__c.SObjectType, matter.RecordTypeId, true);
                
                if(!folderStructures.isEmpty()){
                    for(Box_Folder_Structure__c structure : folderStructures){
                        if(!String.isBlank(structure.External_Collaboration_Id__c)){
                            //get the Deal RecordType Id as we don't want to give co-owner permission for Deal objects
                            Id DealRecordTypeId = advpm__Matter__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(DEAL_RECORDTYPE_NAME).getRecordTypeId();
                            
                            //build collaboration helper with user detail
                            BxdExternalCollaborationHelper externalHelper;  
                            if(DealRecordTypeId == matter.RecordTypeId){
                                //for Deal we don't need a co-owner
                                externalHelper = new BxdExternalCollaborationHelper(null, structure.Folder_Name__c + ' - ' + matter.Name, folderId, structure.External_Collaboration_Id__c, null, null);
                            } else {
                                //for Matter we need a co-owner email
                                externalHelper = new BxdExternalCollaborationHelper(UserInfo.getUserEmail(), structure.Folder_Name__c + ' - ' + matter.Name, folderId, structure.External_Collaboration_Id__c, null, null);
                            }
                            
                            //set the external collaboration folder on matter
                            externalHelper = folderHandler.createExternalBoxFolder(externalHelper);
                            externalFolderId = externalHelper.folderId;
                        } else {
                            folderHandler.createBoxFolder(structure.Folder_Name__c, folderId);
                        }      
                    }
                }
                
                //create collaboration for matter owner
                Id matterOwner = UserInfo.getUserId(); 
                if(createCollaboration && matterOwner != null){     
                    //give them editor access on box as this should be standard
                    box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
                    String collabId = folderHandler.createCollaborationOnRecord(matterOwner, matter.Id, collabType);
                    
                    system.debug('***Internal Collaboration Id: ' + collabId);
                    
                    //get URL link for the matter folder
                    folderURL = getBoxFolderLink(matter.Id);
                } 
            } else {
                System.debug('***BoxFolderCreationFailed: ' + folderHandler.recentBoxErrors());
            }           
        } 
        
        //send back Matter/Deal folder information
        return new MatterDealHelper(folderId, externalFolderId, folderURL);
    }
    
    /**
    * createParticipantCollaberation - Create collaboration for each participant provided they have contact details
	* It also create permissions for each participant provided user is part of staff, calls createPermissionForUser in BxdPermissionHandler
	**/
    @Future (callout = true)
    public static void createParticipantCollaberation(Set<String> Set_id) {
        Map<String,String> contactEmailMap = new Map<String,String>();
        Set<String> ContactIds = new Set<String>();
        String folderId;
        
        List<advpm__Participant__c> lst_participant = new List<advpm__Participant__c>([Select id,advpm__Staff__c,advpm__Matter__c,advpm__Contact__c From advpm__Participant__c where id in:Set_id]);
        for(advpm__Participant__c p:lst_participant){
            ContactIds.add(p.advpm__Contact__c);
        }
        
        List<Contact> lst_Contact = new List<Contact>([Select Id, Email from Contact where id in:ContactIds]);
        for(Contact c:lst_Contact){          
            contactEmailMap.put(c.Id, c.Email);
        }
        
        for(advpm__Participant__c p:lst_participant){           
            box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
            if(contactEmailMap.get(p.advpm__Contact__c)!=null){
                folderid = folderHandler.getBoxFolderIdByRecordId(p.advpm__Matter__c);
                String collabId = folderHandler.createCollaboration(folderId, contactEmailMap.get(p.advpm__Contact__c), collabType);
            }
            if(p.advpm__Staff__c !=null){
                permissionHander.createPermissionForUser(p.advpm__Matter__c,p.advpm__Staff__c);
            }
        }
    }	 
    
    /**
    * createLegalHoldPolicyAssignment - Create policy agreement for the matter identified by the received recordId if legal hold is true,
    * folder structure has content, folder structure legal hold policy id is not blank and folder id is not blank  
	**/
    @Future(callout = true)
    public static void createLegalHoldPolicyAssignment(Id recordId){
        advpm__Matter_Legal_Hold_Acknowledgement__c legalHold = [SELECT Id, advpm__Matter__c FROM advpm__Matter_Legal_Hold_Acknowledgement__c WHERE Id=:recordId];
        
        Id matterId = legalHold.advpm__Matter__c;
        advpm__Matter__c matter = [SELECT Id, advpm__Legal_Hold__c, RecordTypeId, Box_Legal_Hold_Assignment_Id__c FROM advpm__Matter__c WHERE Id=:matterId];   
        
        if(matter != null){
            String folderId = folderHandler.getBoxFolderIdByRecordId(matter.Id);
            Box_Folder_Structure__c structure = folderHandler.getFolderStructure(advpm__Matter__c.SObjectType, matter.RecordTypeId);
            
            if(matter.advpm__Legal_Hold__c && structure != null && !String.isBlank(structure.Legal_Hold_Policy_Id__c) && !String.isBlank(folderId)){
                BxdLegalHoldAssignment assignment = policyHander.createPolicyAssignment(structure.Legal_Hold_Policy_Id__c, folderId, LEGAL_HOLD_ASSIGNMENT_TYPE);
                if(assignment != null & !String.isBlank(assignment.id)){
                    //Update matter
                    matter.Box_Legal_Hold_Assignment_Id__c = assignment.id;
                    update matter;
                    //Upodate legal hold
                    legalHold.Box_Assignment_Id__c = assignment.id;
                    update legalHold;
                }
            }  
        }                              
    }
    
    /**
    * removeLegalHoldPolicyAssignment - Delete policy agreement of the matter identified by the recived recordId, provided matter legal hold is false and legal hold agreement id is not blank
	**/
    @Future(callout = true)
    public static void removeLegalHoldPolicyAssignment(Id recordId){
        advpm__Matter__c matter = [SELECT Id, Name, advpm__Legal_Hold__c, RecordTypeId, Box_Legal_Hold_Assignment_Id__c FROM advpm__Matter__c WHERE Id=:recordId];   
        
        if(matter != null && !matter.advpm__Legal_Hold__c && !String.isBlank(matter.Box_Legal_Hold_Assignment_Id__c)){
            BxdLegalHoldAssignment assignment = policyHander.deletePolicyAssignment(matter.Box_Legal_Hold_Assignment_Id__c);
            if(assignment != null){
                matter.Box_Legal_Hold_Assignment_Id__c = null;
                update matter;
            }
        }
    }
    
    /**
    * getBoxFolderLink - request folder url of the passed matterId bby calling getBoxFolderURL in BxdFolderHandler
	**/
    public static String getBoxFolderLink(Id matterId) {
        PageReference res = folderHandler.getBoxFolderURL(matterId, false);
        if(res != null){
            return res.getUrl();
        }
        return '';
    }
    
    /**
	* Wrapper class for BxdMatterDealService responses. 
	**/
	public class MatterDealHelper
	{
		public String folderId { get; set; }
        public String externalFolderId { get; set; }
		public String folderURL { get; set; } 

		public MatterDealHelper(String folderId, String externalFolderId, String folderURL)
		{
			this.folderId = folderId;
			this.externalFolderId = externalFolderId;
            this.folderURL = folderURL;
		}
	}
    
    /**
    * FolderHandler - wrapper class for BxdFolderHandler
	**/
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            //the specific constructor in parent will be initialized 
            super();
        }
    }
    
    /**
    * PolicyHandler - wrapper class for BxdPolicyHandler
	**/
    private class PolicyHandler extends BxdPolicyHandler {
        private PolicyHandler() {
            //the specific constructor in parent will be initialized 
            super(true);
        }
    }
    
    /**
    * PermissionHandler - wrapper class for BxdPermissionHandler
	**/
    private class PermissionHandler extends BxdPermissionHandler {
        //the specific constructor in parent will be initialized 
        private PermissionHandler() {
        }
    }
}