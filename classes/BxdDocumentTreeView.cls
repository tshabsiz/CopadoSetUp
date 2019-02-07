public class BxdDocumentTreeView {   
    private static FolderHandler folderHandler = new FolderHandler();
    private final static String BOX_FILE_URL = 'https://account.box.com/file/';
    private final static String BOX_RESTRICTED_SCOPE = 'base_explorer item_preview';
    private final static String BOX_RESTRICTED_TYPE = 'folder';
    public Id BxdOwnerId {get; set;}
    public String folderId {get;set;}
    public String accessToken {get;set;}
    public String fileBaseURL {get; private set;}
    
    public BxdDocumentTreeView() {
        BxdOwnerId = ApexPages.currentPage().getParameters().get('Id');
        fileBaseURL = BOX_FILE_URL;
        System.debug('TreeView OWNER ' + BxdOwnerId);
        if (BxdOwnerId != null) {
            //Box FOLDER and TOKEN
            folderId = folderHandler.getBoxFolderIdByRecordIdForCustomUI(getParentTree(BxdOwnerId));
            accessToken = folderHandler.downscopeBoxToken(folderHandler.getBoxApi().getAccessToken(), BOX_RESTRICTED_SCOPE, folderId, BOX_RESTRICTED_TYPE);
        }
    }
    
    private Id getParentTree(Id recordId) {
        Schema.SObjectType ObjType =  recordId.getSobjectType();
        Schema.DescribeSObjectResult ObjTypeDesc = ObjType.getDescribe();
        System.debug('***Tree View Parent Object Name '+ObjTypeDesc.getName());
        
        if (ObjTypeDesc.getName() == 'Account') {
            return recordId;
        }  
        
        if (ObjTypeDesc.getName() == 'advpm__Matter__c') {
            return recordId;
        } 
        
        if (ObjTypeDesc.getName() == 'Agreement__c')
        {
            return getAgreementParent(recordId);
        }
        if (ObjTypeDesc.getName() == 'Condition__c')
        {
            
        }
        if (ObjTypeDesc.getName() == 'Condition_Occurrence__c')
        {
            
        }  
        if (ObjTypeDesc.getName() == 'Collateral__c')
        {
            
        }  
        if (ObjTypeDesc.getName() == 'DrawDown__c')
        {
            
        } 
        if (ObjTypeDesc.getName() == 'Facility__c')
        {
            
        } 
        if (ObjTypeDesc.getName() == 'Facility_Tranche__c')
        {
            
        }
        if (ObjTypeDesc.getName() == 'SPV_Items__c')
        {
            
        }
        if (ObjTypeDesc.getName() == 'Agency_Transfer__c')
        {
            
        }
        if (ObjTypeDesc.getName() == 'Collateral_Valuation__c')
        {
            
        }
        if (ObjTypeDesc.getName() == 'Collateral_Monitoring__c')
        {
            
        }
        if (ObjTypeDesc.getName() == 'Watcher__c')
        {
            
        }
        if (ObjTypeDesc.getName() == 'Trigger__c')
        {
            
        }
        if (ObjTypeDesc.getName() == 'Margin_Ratchet__c')
        {
            
        }
        
        return recordId;
    }
    
    private Id getAgreementParent(Id recordId) {
        Agreement__c agreement = [SELECT Id, Name, Matter_Deal__c, RecordTypeId FROM Agreement__c where id =: recordId LIMIT 1];
        return agreement.Matter_Deal__c;
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {           
            super(true, null);
        }
    }
}