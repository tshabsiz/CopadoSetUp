public class BoxDocumentDetailController {
    //private
    private static FolderHandler folderHandler = new FolderHandler();
    private final static String BOX_FILE_URL = 'https://account.box.com/file/';
    private final static String BOX_RESTRICTED_SCOPE = 'base_upload';
    private final static String BOX_RESTRICTED_TYPE = 'folder';
    private final static Integer NAME_LENGHT = 79;
    private Id BxdOwnerId;
    private String bxdId;
    private String IsFramed;
    private String boxServiceName;
    private Map<Integer, NavigationPage> steps;
    private Map<String, BxdDocumentHelper> documents;
    //public
    public Integer curStep {get; set;}
    public boolean showUploaded {get; set;}
    public boolean showPrevious {get; set;}
    public boolean allowDelete {get; set;} 
    public String folderId {get;set;}
    public String accessToken {get;set;}
    public String uploadedResponse {get;set;}
    public String OwnerSelectedVal {get; set;} 
    public String fileBaseURL {get; private set;}
    public BoxDocument__c boxDocument {get; set;}
    public List<BxdDocumentHelper> uploadDocuments {get; set;}
    public List<BxdDocumentHelper> supportingDocuments {get; set;}
    
    public BoxDocumentDetailController() {
        //initialize all variables needed for upload or view
        setupSteps();
        showUploaded = false;
        showPrevious = true;
        allowDelete = true;
        bxdId = ApexPages.currentPage().getParameters().get('bxdId');   
        BxdOwnerId = ApexPages.currentPage().getParameters().get('BxdOwnerId'); 
        IsFramed = ApexPages.currentPage().getParameters().get('IsFramed');
        boxServiceName = ApexPages.currentPage().getParameters().get('boxService');
        
        fileBaseURL = BOX_FILE_URL;
        uploadedResponse = '[]';
        OwnerSelectedVal = '' ;
        
        //check if we are using the view (bxdId) or the upload (BxdOwnerId)
        if (bxdId == null||bxdId == ''||bxdId == 'null'){
            //we are on edit new page aka upload page
            boxDocument = new BoxDocument__c();  
            PrePopulateOwner();       
            RenderSec();
            //Box upload
            folderId = folderHandler.getBoxFolderIdByRecordIdForCustomUI(BxdOwnerId);
            accessToken = folderHandler.downscopeBoxToken(folderHandler.getBoxApi().getAccessToken(), BOX_RESTRICTED_SCOPE, folderId, BOX_RESTRICTED_TYPE);
        } else {
            //we are on view or edit page
            curStep = 3;
            BoxDocumentViewHelper viewHelper = BoxDocumentViewHelper.getInstance();
            String Query = viewHelper.QueryCreator(bxdId);
            boxDocument = Database.Query(Query);
            OwnerSelectedVal = boxDocument.Owner_Type__c;
            RenderSec();
            
            //put box document in list for edit of metadata functionality
            documents.put(boxDocument.Box_Unique_Id__c, new BxdDocumentHelper(boxDocument, boxDocument.Name));
            uploadDocuments = documents.values();
            
            //we don't want to delete on view or edit
            allowDelete = false;
            //this will be driven by next button
            showPrevious = false;
            //because we are on edit, the doc should already been uploaded
            showUploaded = true;
        }
        
    }
    
    public PageReference actionBoxCreateFolder(){
        System.debug('***Box - Folder '+folderId+' - Service '+boxServiceName);
        if(String.isBlank(folderId) && !String.isBlank(boxServiceName) && boxServiceName != 'null'){
            System.Type t = Type.forName(boxServiceName);
            BxdServiceInterface boxService = (BxdServiceInterface) t.newInstance();
            folderId = boxService.createBoxFolderSync(BxdOwnerId);
            System.debug('##Manual Created Folder '+folderId);
        }
        
        return null;
    }
    
    private void PrePopulateOwner() {
        Schema.SObjectType ObjType =  BxdOwnerId.getSobjectType();
        Schema.DescribeSObjectResult ObjTypeDesc = ObjType.getDescribe();
        System.debug('***THE NAME '+ObjTypeDesc.getName());
        if (ObjTypeDesc.getName() == 'Account')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Account__c = BxdOwnerId;
        }       
        if (ObjTypeDesc.getName() == 'advpm__Matter__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Matter__c = BxdOwnerId;
        } 
        if (ObjTypeDesc.getName() == 'Agreement__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Agreement__c = BxdOwnerId;
        }
        if (ObjTypeDesc.getName() == 'Condition__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Condition__c = BxdOwnerId;
        }
        if (ObjTypeDesc.getName() == 'Condition_Occurrence__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Condition_Occurrence__c = BxdOwnerId;
        }  
        if (ObjTypeDesc.getName() == 'Collateral__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Collateral__c = BxdOwnerId;
        }  
        if (ObjTypeDesc.getName() == 'DrawDown__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.DrawDown__c = BxdOwnerId;
        } 
        if (ObjTypeDesc.getName() == 'Facility__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Facility__c = BxdOwnerId;
        } 
        if (ObjTypeDesc.getName() == 'Facility_Tranche__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Facility_Tranche__c = BxdOwnerId;
        }
        if (ObjTypeDesc.getName() == 'SPV_Items__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.SPV_Item__c = BxdOwnerId;
        }
        if (ObjTypeDesc.getName() == 'Agency_Transfer__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Agency_Transfer__c = BxdOwnerId;
        }
        if (ObjTypeDesc.getName() == 'Collateral_Valuation__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Collateral_Valuation__c = BxdOwnerId;
        }
        if (ObjTypeDesc.getName() == 'Collateral_Monitoring__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Collateral_Monitoring__c = BxdOwnerId;
        }
        if (ObjTypeDesc.getName() == 'Watcher__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Watcher__c = BxdOwnerId;
        }
        if (ObjTypeDesc.getName() == 'Trigger__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Trigger__c = BxdOwnerId;
        }
        if (ObjTypeDesc.getName() == 'Margin_Ratchet__c')
        {
            OwnerSelectedVal = ObjTypeDesc.getName();
            boxDocument.Margin_Ratchet__c = BxdOwnerId;
        }  
    }
    
    public PageReference save() {
        boxDocument.Owner_Type__c = OwnerSelectedVal;
        
        if (this.bxdId == null && uploadDocuments != null && !uploadDocuments.isEmpty())
        {
            List<BoxDocument__c> boxDocuments = new List<BoxDocument__c>();
            for(BxdDocumentHelper helper : uploadDocuments){
                //set fields on original doc
                helper.boxDocument.Owner_Type__c = boxDocument.Owner_Type__c;
                helper.boxDocument.Account__c = boxDocument.Account__c;
                helper.boxDocument.Matter__c = boxDocument.Matter__c;
                helper.boxDocument.Agreement__c = boxDocument.Agreement__c;
                helper.boxDocument.Condition__c = boxDocument.Condition__c;
                helper.boxDocument.Condition_Occurrence__c = boxDocument.Condition_Occurrence__c;
                helper.boxDocument.Collateral__c = boxDocument.Collateral__c;
                helper.boxDocument.DrawDown__c = boxDocument.DrawDown__c;
                helper.boxDocument.Facility__c = boxDocument.Facility__c;
                helper.boxDocument.Facility_Tranche__c = boxDocument.Facility_Tranche__c;
                helper.boxDocument.SPV_Item__c = boxDocument.SPV_Item__c;
                helper.boxDocument.Agency_Transfer__c = boxDocument.Agency_Transfer__c;
                helper.boxDocument.Collateral_Valuation__c = boxDocument.Collateral_Valuation__c;
                helper.boxDocument.Collateral_Monitoring__c = boxDocument.Collateral_Monitoring__c;
                helper.boxDocument.Watcher__c = boxDocument.Watcher__c;
                helper.boxDocument.Trigger__c = boxDocument.Trigger__c;
                helper.boxDocument.Margin_Ratchet__c = boxDocument.Margin_Ratchet__c;
                helper.boxDocument.Box_Filename__c = helper.filename;
                if(String.isBlank(helper.boxDocument.Name)){
                    helper.boxDocument.Name = truncateDocumentName(helper.filename);
                }
                helper.boxDocument.Upload_Date__c = DateTime.now();
                //Add to document list.
                boxDocuments.add(helper.boxDocument);
            }
            //Insert docs
            upsert boxDocuments;
            boxDocument = new BoxDocument__c();
        }
        else
        {
            //Update document
            upsert(boxDocument);
        }
        
        //return to parent owner 
        return returnPage(!String.isBlank(BxdOwnerId) ? BxdOwnerId : ApexPages.currentPage().getParameters().get('BxdOwnerId'));
    }
    
    private String truncateDocumentName(String name) {
        if(!String.isBlank(name))
        {
            Integer textLength = name.length();
            
            //check that text is not longer than allowed
            if(textLength > NAME_LENGHT)
                return name.substring(0, 79);
        }
        
        return name;
    }
    
    public PageReference Cancel() {
        deleteCancelledBoxFiles();

        //return to parent owner
        return returnPage(ApexPages.currentPage().getParameters().get('BxdOwnerId'));
    }
    
    public PageReference returnPage(String boxOwnerId) {
        System.debug('return page id: ' + boxOwnerId);
        
        //create reference page
        PageReference ret;
        if(IsFramed == '1'){
            ret = new PageReference('/apex/BxdDocumentsFramed?Id=' + boxOwnerId + '&IsFramed=1');
        } else {
            ret = new PageReference('/apex/BxdDocuments?Id='+boxOwnerId);
        } 
        
        // Redirect to agreement layout when on agreement
        Schema.SObjectType ObjTypeA =  BxdOwnerId.getSobjectType();
        Schema.DescribeSObjectResult ObjTypeDescA = ObjTypeA.getDescribe();
        
        if(ObjTypeDescA.getName() == 'Agreement__c') {
            ret = new PageReference('/apex/AgreementBxdDocuments?Id=' + boxOwnerId + '&boxService=BxdAgreementService');
        }
        
        return ret;
    }
    
    private void deleteCancelledBoxFiles() {
        System.debug('***Allow Delete: ' + allowDelete);
        System.debug('***Delete List: ' + uploadDocuments);
        if(allowDelete && !uploadDocuments.isEmpty()) {
            Set<String> files = new Set<String>();
            for(BxdDocumentHelper helper : uploadDocuments) {
                //Add file Id to set for future delete
                System.debug('Cancel: '+helper.boxDocument.Box_Unique_Id__c);
                files.add(helper.boxDocument.Box_Unique_Id__c);
            }
            deleteCancelledBulk(files);
        }
    }
    
    @Future(callout = true)
    public static void deleteCancelledBulk(Set<String> files) {
        for(String fileId : files) {
            folderHandler.deleteFile(fileId);
        }
    }
    
    public PageReference RenderSec()
    {  
        System.debug('Current Owner: ' + OwnerSelectedVal);  
        return null;
    }
    
    public PageReference RefreshAttachments() {
        String jsonString = '{"files" : '+ uploadedResponse + '}';
        BxdUploadResponseParser responseData = BxdUploadResponseParser.parse(jsonString);
        if(responseData != null && !responseData.files.isEmpty()){
            system.debug(responseData.files);
            
            // Store all existing files id in a set
            Set<String> fileIDs = new Set<String>(); 
            for(BxdUploadResponseParser.Files file : responseData.files){
                fileIDs.Add(file.id);    
            }
            
            //Select all Box document in a map
            Map<String, BoxDocument__c> existingDocMap = new Map<String, BoxDocument__c>(); 
            
            for(BoxDocument__c exDocument : [Select ID, Name, Expiry_Date__c, Box_Unique_Id__c, Box_Location__c, Owner_Type__c, PII__c, Status__c, Type__c, Upload_Date__c FROM BoxDocument__c WHERE Box_Unique_Id__c in: fileIDs]){
                existingDocMap.put(exDocument.Box_Unique_Id__c, exDocument);
            }    
            System.debug('***Existing Documents ' + existingDocMap);
            
            //Put all documents in list to show on Metadata step
            for(BxdUploadResponseParser.Files file : responseData.files){
                //set fields on new or existing Box Document
                BoxDocument__c box = existingDocMap.get(file.id);
                if(box == null){
                    box = new BoxDocument__c();
                    box.Box_Location__c = file.url;
                    box.Box_Unique_Id__c = file.id;
                    documents.put(box.Box_Unique_Id__c, new BxdDocumentHelper(box, file.name));
                } else {
                    box.Box_Location__c = file.url;
                    documents.put(box.Box_Unique_Id__c, new BxdDocumentHelper(box, file.name));
                }        
            }
            uploadDocuments = documents.values();
            showUploaded = true;
        }
        
        return null;
    }
    
    public List<SelectOption> getUploadedDocuments() {
        List<SelectOption> uploadOptionList = new List<SelectOption>();
        if(!uploadDocuments.isEmpty()) {
            uploadOptionList.add(new SelectOption( '' ,'---Select---'));
            for(BxdDocumentHelper helper : uploadDocuments) {
                uploadOptionList.add(new SelectOption(helper.boxDocument.Box_Unique_Id__c, helper.filename));
            }
        } else {
            uploadOptionList.add(new SelectOption( '' ,'---No File Uploaded---'));
        }
        return uploadOptionList;
    }
    
    private Boolean getRequiredDocuments() {
        //TODO : If template document becomes generic (e.g not conditions anymore), please use BoxDocumentViewHelper.QueryCreator()
        Id owner = ApexPages.currentPage().getParameters().get('BxdOwnerId');
        List<BoxDocument__c> boxDocuments  = [SELECT Id, Condition__c, Type__c, Box_Location__c,
                                              Name, PII__c, Prerequisite_Document__c, Box_Unique_Id__c,
                                              Condition_Occurrence__c, Owner_Type__c, Expiry_Date__c, 
                                              Condition_Occurrence__r.Name, Condition__r.Name, Document_Number__c, Status__c
                                              FROM BoxDocument__c WHERE Condition_Occurrence__r.Id =: owner AND Prerequisite_Document__c =: true AND Box_Location__c = NULL];
        
        if(!boxDocuments.isEmpty()) {
            for(BoxDocument__c box : boxDocuments) {
                //Add box document to supporting list
                supportingDocuments.add(new BxdDocumentHelper(box, ''));
            }
            return false;
        }
        return true;
    }
    
    private void mapSupportingDocuments(){
        if(!supportingDocuments.isEmpty()){
            for(BxdDocumentHelper source : supportingDocuments) {
                BxdDocumentHelper target = documents.get(source.selected);
                if(target != null){
                    //TODO : swap previous linked here in case user change their mind
                    System.debug('SELECTED '+source.selected);
                    System.debug('LINKED '+source.linkedFile);
                    //Preserve box link and file id
                    source.boxDocument.Box_Location__c = target.boxDocument.Box_Location__c;
                    source.boxDocument.Box_Unique_Id__c = target.boxDocument.Box_Unique_Id__c;
                    //Replace box default document with supporting document
                    target.boxDocument = source.boxDocument;
                    documents.put(source.selected, target);
                    //Keep linked supporting document
                    source.linkedFile = source.selected;
                }                
            }
            //reset upload documents list to current mapping
            uploadDocuments = documents.values();
        }
    }
    
    public PageReference next(){
        NavigationPage nav = steps.get(curStep);
        if(nav == null || nav.next == null){
            return null;
        }
        
        allowDelete = true;
        curStep = nav.next;
        nav = steps.get(curStep);
        
        if(nav.skip){
            curStep = nav.next;
            nav = steps.get(curStep);
            return nav.thePage;
        } else {
            if(curStep == 3){
                mapSupportingDocuments();
            }
            return nav.thePage;
        }
    }
    
    public PageReference previous(){
        NavigationPage nav = steps.get(curStep);
        if(nav == null || nav.previous == null){
            return null;
        }
        
        allowDelete = false;
        curStep = nav.previous;
        nav = steps.get(curStep);
        
        if(nav.skip){
            curStep = nav.previous;
            nav = steps.get(curStep);
            return nav.thePage;
        } else {
            return nav.thePage;
        }
    }
    
    public string getPageTitle(){
        return steps.get(curStep).title;
    }
    
    public string getPageLabel(){
        return steps.get(curStep).label;
    }
    
    private void setupSteps(){
        curStep = 1;
        uploadDocuments = new List<BxdDocumentHelper>();
        supportingDocuments = new List<BxdDocumentHelper>();
        documents = new Map<String, BxdDocumentHelper>();
        steps = new Map<Integer, NavigationPage>();
        Boolean skip = getRequiredDocuments();
        
        NavigationPage np = new NavigationPage();
        np.thePage = Page.BoxDocumentEditStep1;
        np.title = skip ? 'Step 1 of 2:  Upload Files' : 'Step 1 of 3:  Upload Files';
        np.label = '';
        np.previous = null;
        np.next = 2;
        np.skip = false;
        steps.put(1, np);
        
        np = new NavigationPage();
        np.thePage = Page.BoxDocumentEditStep2;
        np.title = 'Step 2 of 3:  Add Supporting Documentation';
        np.label = 'Upload More Files';
        np.previous = 1;
        np.next = 3;
        np.skip = skip;
        steps.put(2, np);
        
        np = new NavigationPage();
        np.thePage = Page.BoxDocumentEditStep3;
        np.title = skip ? 'Step 2 of 2:  Add Metadata' : 'Step 3 of 3:  Add Metadata';
        np.label = skip ? 'Upload More Files' : 'Link Documents';
        np.previous = 2;
        np.next = null;
        np.skip = false;
        steps.put(3, np);
    }
    
    private class NavigationPage {
        public Integer previous {get; set;}
        public Integer next {get; set;}
        public PageReference thePage {get; set;}
        public String title {get; set;}
        public String label {get; set;}
        public Boolean skip {get; set;}
    }
    
    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {            
            super(true, null);
        }
    }
}