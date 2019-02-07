/**
* 2018-02-27
* Rudolf Niehaus - CloudSmiths
* 
**/
public class lscLinkCaseExt {
    
    @AuraEnabled
    public static list<Case> getRelatedCase(String parentCaseId){
        
        list<Case> lstCases = new list<Case>();
        list<Case> parentCase = [Select Id, Email_From_Address__c, Email_Sender_Name__c, Web_Email__c,Web_Name__c From Case Where Id = :parentCaseId limit 1];
        
        if(parentCase.size() > 0){
            
            lstCases = [Select Id, Subject, Status, CaseNumber,Owner.Name,Service_Type__c, Department__c, 
                        Service_Category__c, Service_Sub_Category__c, Channel__c,Case_Related_To_Email__c,   
                        Description, Contact.Name, Contact.Email, Web_Email__c, 
                        Web_Name__c, Email_From_Address__c, IsClosed, CreatedDate, Account.Name 
                        From Case 
                        Where ( Email_From_Address__c = :parentCase[0].Email_From_Address__c OR 
                               Contact.Name = :parentCase[0].Email_Sender_Name__c OR 
                               Web_Email__c = :parentCase[0].Web_Email__c OR 
                               Web_Name__c = :parentCase[0].Web_Name__c ) AND
                        RecordType.DeveloperName != 'CSC_Emails' AND 
                        Id != :parentCaseId AND  
                        IsClosed = false 
                        Order by CreatedDate Desc Limit 10];
        }
        
        return lstCases;
    }
    
    @AuraEnabled
    public static list<Case> searchCases(String searchCaseNumber, String searchSubject){
        
        list<Case> relatedCases = new list<Case>();
        
        String  sql = 'Select Id, Subject, Status, CaseNumber,Owner.Name,Service_Type__c, Department__c,Case_Related_To_Email__c,' + 
            'Service_Category__c, Service_Sub_Category__c, Channel__c,' +
            'Description, Contact.Name, Contact.Email, Web_Email__c,' + 
            'Web_Name__c, Email_From_Address__c, IsClosed, CreatedDate, Account.Name ' +
            'From Case Where RecordType.DeveloperName != \'CSC_Emails\' AND IsClosed = false';
        
        if(String.isNotBlank(searchCaseNumber) && String.isNotBlank(searchSubject)){
            sql+= ' AND (CaseNumber like \'' + searchCaseNumber + '%\' AND Subject like \'' + searchSubject + '%\')';
        }else{
            if(String.isNotBlank(searchCaseNumber)){
                sql+= ' AND CaseNumber like \'' + searchCaseNumber + '%\'';
            }else{
                sql+= ' AND Subject like \'' + searchSubject + '%\'';
            }
        }
        
        sql+= ' Order by CreatedDate Desc Limit 10';
        
        relatedCases = Database.query(sql);
        
        return relatedCases;
    }
    
    @AuraEnabled
    public static void linkEmailToCase(String selectedCaseId, String linkCaseId){
        
        list<Attachment> lstAttachments = new list<Attachment>();
        list<FeedItem> feedList = new list<FeedItem>();
        
        list<Case> selectedCase = [Select Id, Case_Related_To_Email__c From Case Where Id = :selectedCaseId];
        list<Case> linkedCase = [Select Id, Email_Action__c, Email_Status__c, Status From Case Where Id = :linkCaseId];
        
        //Link current email message type 
        list<EmailMessage> em = [Select Id, TextBody, HtmlBody, Headers, Subject, MessageDate,  
                                 FromName, FromAddress, ToAddress, CcAddress, BccAddress, 
                                 Incoming, HasAttachment, Status 
                                 From EmailMessage 
                                 Where ParentId = :linkCaseId AND isOriginalEmail__c = true  
                                 Order By CreatedDate Asc Limit 1];
        
        if( em.size() > 0 ){
            
            //if there are email body blob attchments then add all att to the list for this email message
            if(em[0].HasAttachment){
                for (Attachment att :[Select Id, Name, Body From Attachment Where ParentId = :em[0].Id and Name = 'Email Body.html']) {
                    lstAttachments.add(att);
                }
            }
            
            
            list<Case> updateCheckList = new list<Case>();
            
            //clone message as we need to keep the original email type case with its email message
            //and then link the message to the seleted related case
            EmailMessage emsg = new EmailMessage();
            emsg.FromAddress = em[0].FromAddress;
            emsg.FromName = em[0].FromName;
            emsg.HtmlBody = em[0].HtmlBody;
            emsg.TextBody = em[0].TextBody;
            emsg.Headers = em[0].Headers;
            emsg.CcAddress = em[0].CcAddress;
            emsg.BccAddress = em[0].BccAddress;
            emsg.Incoming = em[0].Incoming;
            emsg.MessageDate = em[0].MessageDate;
            emsg.Subject = em[0].Subject;
            
            emsg.ParentId = selectedCaseId;
            
            //clone only the FeedItems pointing to the content and link to the related cases
            for(CollaborationGroupFeed  f : [Select RelatedRecordId, Type, Body, ParentId From CollaborationGroupFeed  
                              Where ParentId = :linkCaseId and Type = 'ContentPost']){
                                  
                                  FeedItem post = new FeedItem();
                                  post.ParentId = selectedCaseId;
                                  post.Body = f.Body;
                                  post.RelatedRecordId = f.RelatedRecordId;
                                  post.Type = 'ContentPost';
                                  
                                  feedList.add(post);
             }
            
            //Now insert all new EmailMessages so we can get the records Id's in order
            //to link the attatchment list to the parent records
            try{
                insert emsg;
            }catch(DMLException ex){
                System.debug('CSC Support : There was an error inserting the cloned EmailMessages for selected related cases');
                System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> insert emsg');
                System.debug(ex.getMessage());
            }
            
            try{
                insert  lstAttachments;
            }catch(DMLException ex){
                System.debug('CSC Support : There was an error inserting the cloned Attachments for selected related cases');
                System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> insert  lstAttachments');
                System.debug(ex.getMessage());
            }
            
            try{
                insert feedList;
            }catch(DMLException ex){
                System.debug('CSC Support : There was an error inserting the cloned FeedItems with the related Case id as parentid');
                System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> update feedList');
                System.debug(ex.getMessage());
            }
            
            //update existing case
            linkedCase[0].Email_Action__c = 'Linked to Existing Case';
            linkedCase[0].Email_Status__c = 'Actioned';
            linkedCase[0].Status = 'Closed Resolved';
            
            try{
                update linkedCase[0];
            }catch(DMLException ex){
                System.debug('CSC Support : There was an error updating the original email type case after it was linked to related cases');
                System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> update linkedCase[0]');
                System.debug(ex.getMessage());
            }
            
            
            selectedCase[0].Case_Related_To_Email__c = linkCaseId;
            
            try{
                update selectedCase[0];
            }catch(DMLException ex){
                System.debug('CSC Support : There was an error updating the selected cases relationship to the email');
                System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> update selectedCase[0]');
                System.debug(ex.getMessage());
            }
        } 
    }
    
}