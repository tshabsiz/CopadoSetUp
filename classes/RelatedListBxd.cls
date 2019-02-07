public with sharing class RelatedListBxd {
    public Id BxdOwnerId {get; set;}
    public Integer Pagesize = 10;       
    public Boolean sorted;
    public Boolean ordered;
    public Boolean filtered;
    public Boolean filteredClick;
    public Boolean showStyle {get; set;}
    public Boolean showNew {get;set;}
    public String sortOrder;
    public String sortField; 
    public String documentNumber {get;set;}
    public String boxServiceName {get; set;}
    public BoxDocumentViewHelper viewHelper;
    public BoxDocument__c boxDocument {get;set;}
    public ApexPages.StandardController sc {get; set;}
    public String DocusignUrlRedirect {get; set;}
    private String IsFramed {get; set;}
    
    public RelatedListBxd()
    {       
        if (boxDocument == null)
        {
            boxDocument = new BoxDocument__c();    
        }
        
        BxdOwnerId = ApexPages.currentPage().getParameters().get('Id');
        IsFramed = ApexPages.currentPage().getParameters().get('IsFramed');
        boxServiceName = ApexPages.currentPage().getParameters().get('boxService');
        System.debug('**OWNER ID: ' + BxdOwnerId);
        System.debug('**OWNER SERVICE: ' + boxServiceName);
        System.debug('**OWNER IFRAMED: ' + IsFramed);
        setStyleByRecordType(BxdOwnerId);
        
        if (sortField == null)
        {
            sortField = 'Upload_Date__c';
        }
        
        if (filtered == null)
        {
            filtered = false;
        }
        // Create Custom Recipient List
        CreateCustomRecipientList();
    }
    
    public ApexPages.StandardSetController ssc
    {	
        get 
        {
            if (ssc == null|| sorted || filteredClick)
            {
                viewHelper = BoxDocumentViewHelper.getInstance(); 
                String Query = viewHelper.QueryCreator(null, BxdOwnerId, this);
                System.debug('QUERY : ' + Query);
                ssc = new ApexPages.StandardSetController(Database.query(Query));   
                ssc.setPageSize(Pagesize);
                sorted = false;
                filteredClick = false;
            }
            return ssc;
        }
        private set;                
    }
    
    public void sortList()
    {
        sorted = true;
        sortField  = ApexPages.currentPage().getParameters().get('sortField'); //need to create get and set for this
        system.debug('sortList');
        system.debug(sortField);
    }
    
    public void clearFilterList()
    {
        system.debug('clearFilterList');
        boxDocument = new BoxDocument__c();
        documentNumber = null;
        filtered = false;
        filteredClick = true;
        
    }
    
    public void filterList() 
    {
        system.debug('filterList');
        filtered = true;
        filteredClick = true;
        
    }
    
    public List<BoxDocument__c> bxdRecords
    {  
        get
        {
            if (ssc != null)
            {
                return (List<BoxDocument__c>)ssc.getRecords();    
            }
            else
            {
                return null;
            }
            
        }
        set;     
    }
    
    public List<BoxDocument__c> AgreementsbxdRecords
    {  
        get
        {
            if (ssc != null)
            {
                List<BoxDocument__c> uploadedRecords = new List<BoxDocument__c>();
                for(BoxDocument__c bxdDoc : (List<BoxDocument__c>)ssc.getRecords()){
                    if(bxdDoc.box_location__c != null) {
                        uploadedRecords.add(bxdDoc);
                    }
                }
                return uploadedRecords;    
            }
            else
            {
                return null;
            }
            
        }
        set;     
    }
    
    public void sendDocumentstoDocusign() {
        List<Attachment> attachments = new List<Attachment>();
        List<BxdKnowledgeItem> files = new List<BxdKnowledgeItem>();
        System.debug('bxd.Box_Filename__c testing');
        for(BoxDocument__c bxd : bxdRecords ) {
            if(bxd.send_to_docusign__c == true && (bxd.Box_Unique_Id__c != null || bxd.Box_Unique_Id__c !='') &&  (bxd.Box_Location__c != '' || bxd.Box_Location__c != null)) {
                System.debug('bxd.Box_Filename__c ' + bxd.Box_Filename__c);
                String boxName = (bxd.Box_Filename__c == null || bxd.Box_Filename__c == '')  ? bxd.Name : bxd.Box_Filename__c;
                System.debug('BoxName : ' + boxName );
                BxdKnowledgeItem file = new BxdKnowledgeItem(bxd.Box_Unique_Id__c, boxName , null, bxd.Box_Location__c, null, null);
                files.add(file);
            }
        }
        
        // Get box folder contents
        if(files.size() > 0) {        
            files  = BxdKnowledgeService.downloadFiles(files, true);
            // attach all the files to the object
            for(BxdKnowledgeItem file : files) {
                if(file.content != null) {
                    Attachment attach = new Attachment(); // Make an attachment
                    attach.Name = file.name;
                    attach.Body = file.content;
                    attach.ParentID = BxdOwnerId;
                    attachments.add(attach);
                    System.debug('Adding file : ' + file.name);
                } else {
                    System.debug('Could not Add file : ' + file.content);
                }
            }
            insert attachments;
        }
    }
    
    public void CreateCustomRecipientList() {
        // Create Docusign redirect URL
        if(BxdOwnerId != null ) {
            Schema.SObjectType ObjTypeA =  BxdOwnerId.getSobjectType();
            Schema.DescribeSObjectResult ObjTypeDescA = ObjTypeA.getDescribe();
            if(ObjTypeDescA.getName() == 'Agreement__c') {
                String customRecipientList = '';
                Agreement__c dAgreement = [SELECT Id, Matter_Deal__c FROM Agreement__c WHERE Id=:BxdOwnerId];
                List<advpm__Participant__c> participants = [SELECT Id, Users_Email_Address_del__c, Signing_Authority__c,advpm__Staff__r.Name  FROM advpm__Participant__c WHERE advpm__Matter__c =:dAgreement.Matter_Deal__c AND Signing_Authority__c = true];
                // Get Team Lead and Add as an approver
                List<User> managers = new List<User>();
                try {
                    managers = [SELECT Id, Email, Name FROM User where Id =:CloudSmiths_Utils.determineApprover()];
                    if(managers.size() > 0) {
                        User manager = managers.get(0);
                        customRecipientList = customRecipientList + customRecipientList +  'Email~' + manager.Email + ';FirstName~'+manager.Name+ ';Role~Approver;RoutingOrder~1;,';
                    }
                } catch(Exception e) {
                    System.debug('#DOCUSIGN : UNABLE TO FIND TEAM LEAD FOR LOGGED IN USER '+ e.getMessage());
                }
                
                // Add all signers
                for(advpm__Participant__c p : participants) {
                    customRecipientList = customRecipientList +  'Email~' + p.Users_Email_Address_del__c + ';FirstName~'+p.advpm__Staff__r.Name+ ';Role~Signer 1;RoutingOrder~2;,';
                }
                
                DocusignUrlRedirect = customRecipientList;
                System.debug('#DS: Custom Recpient List : ' + DocusignUrlRedirect);
            }
        }
    }
    
    public Boolean hasNext  
    {  
        get  
        {  
            return ssc.getHasNext();  
        }  
        set;  
    } 
    
    public Boolean hasPrevious  
    {  
        get  
        {  
            return ssc.getHasPrevious();  
        }  
        set;  
    } 
    
    public Integer pageNumber  
    {  
        get  
        {  
            return ssc.getPageNumber();  
        }  
        set;  
    }
    
    public void previous()  
    {  
        ssc.previous();  
    } 
    
    public void next()  
    {  
        ssc.next();  
    }   
    
    public PageReference editnew()
    {
        return new PageReference('/apex/BoxDocumentEditStep1?BxdOwnerId='+BxdOwnerId + '&IsFramed=' + IsFramed + '&boxService=' + boxServiceName);      
    }
    
    public PageReference edit()
    { 
        String bxdId = ApexPages.currentPage().getParameters().get('bxdId');
        return new PageReference('/apex/BoxDocumentEditStep3?bxdId=' + bxdId + '&BxdOwnerId=' + BxdOwnerId + '&IsFramed=' + IsFramed);   
    }
    
    public PageReference view()
    {
        String bxdId = ApexPages.currentPage().getParameters().get('bxdId');
        return new PageReference('/apex/BoxDocumentView?bxdId=' + bxdId + '&BxdOwnerId=' + BxdOwnerId + '&IsFramed=' + IsFramed);        
    }
    
    public void setStyleByRecordType(Id RecordId){       
        try{
            showNew = true;
            Schema.SObjectType ObjType =  RecordId.getSobjectType();
            Id FinancialCovenantTypeId = ObjType.getDescribe().getRecordTypeInfosByName().get('Financial Covenant').getRecordTypeId();
            if (String.valueOf(ObjType) == 'Condition__c'){
                showNew = false;
                Condition__c condition = [SELECT Id, RecordTypeId FROM Condition__c WHERE Id=:RecordId LIMIT 1];
                if(FinancialCovenantTypeId == condition.RecordTypeId){
                    showStyle = false;
                    return;
                }
            } else if(String.valueOf(ObjType) == 'Condition_Occurrence__c'){
                Condition_Occurrence__c occurence = [SELECT Id, RecordTypeId FROM Condition_Occurrence__c WHERE Id=:RecordId LIMIT 1];
                if(FinancialCovenantTypeId == occurence.RecordTypeId){
                    showStyle = false;
                    return;
                }               
            } 
        } catch (Exception e){       
        }
        showStyle = true;
        return;
    }
}