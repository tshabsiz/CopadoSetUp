/**
* Date   : 18-05-2016
* Author : RN - CloudSmiths
* Desc   : Controller that links an Email type Case from a quick action button to an existing case based on the sender
* 
* 2016-09-07 RN - Add select criteria when we link the email to an existing case to ensure we only link teh original email
				  that was sent
* 2016-12-06 RN - Add Case search criteria on Subject and Case Number
* 2017-03-30 RN - Link Support Case back to Email, the reversal for Email to Case
**/

public class CSC_Quick_Action_Link_Case_Cont {

    public list<Case> relatedCases{get;set;}
    public list<CaseWrapper> lstCaseWrapper {get;set;}
    public Case c {get;set;}
    public String caseItem {get;set;}
    public String searchSubject{get;set;}
    public String searchCaseNumber{get;set;}
    
    private Case linkCase = new Case();
    
    public CSC_Quick_Action_Link_Case_Cont(ApexPages.StandardController controller){
        
       //controller.addFields(new string[]{'Email_From_Address__c','Email_Sender_Name__c','Web_Email__c','Web_Name__c'}); 
       this.linkCase = (Case)controller.getRecord();
       this.linkCase = [Select Id, Email_From_Address__c,Email_Sender_Name__c,Web_Email__c,Web_Name__c From Case Where Id = :this.linkCase.Id];
        
       relatedCases = [Select Id, Subject, Status, CaseNumber,Owner.Name,Service_Type__c, Department__c, 
                       Service_Category__c, Service_Sub_Category__c, Channel__c,Case_Related_To_Email__c,   
                       Description, Contact.Name, Contact.Email, Web_Email__c, 
                       Web_Name__c, Email_From_Address__c, IsClosed, CreatedDate, Account.Name    
                       From Case 
                       Where (Email_From_Address__c = :linkCase.Email_From_Address__c OR 
                              Contact.Name = :linkCase.Email_Sender_Name__c OR 
                              Web_Email__c = :linkCase.Web_Email__c OR 
                              Web_Name__c = :linkCase.Web_Name__c) AND
                       RecordType.DeveloperName != 'CSC_Emails' 
                       Order by CreatedDate Desc Limit 6];
        
        lstCaseWrapper = new list<CaseWrapper>();
        
        for(Case c :relatedCases){
            
            Case aCase = c;
            
            CaseWrapper wrapperCase = new CaseWrapper(aCase,false);
            
            lstCaseWrapper.add(wrapperCase);            
        }
        
    }
    
    public PageReference searchCases(){
        String  sql = 'Select Id, Subject, Status, CaseNumber,Owner.Name,Service_Type__c, Department__c,Case_Related_To_Email__c,' + 
                      'Service_Category__c, Service_Sub_Category__c, Channel__c,' +
                      'Description, Contact.Name, Contact.Email, Web_Email__c,' + 
                      'Web_Name__c, Email_From_Address__c, IsClosed, CreatedDate, Account.Name ' +
            		  'From Case Where RecordType.DeveloperName != \'CSC_Emails\'';
        			  
        if(String.isNotBlank(searchCaseNumber) && String.isNotBlank(searchSubject)){
            sql+= ' AND (CaseNumber like \'' + searchCaseNumber + '%\' AND Subject like \'' + searchSubject + '%\')';
        }else{
			if(String.isNotBlank(searchCaseNumber)){
            	sql+= ' AND CaseNumber like \'' + searchCaseNumber + '%\'';
            }else{
                sql+= ' AND Subject like \'' + searchSubject + '%\'';
            }
        }
        
        sql+= ' Order by CreatedDate Desc Limit 6';
        
        system.debug('SQL:' + sql);
        
        relatedCases = Database.query(sql);
        
        lstCaseWrapper = new list<CaseWrapper>();
        
        for(Case c :relatedCases){
            
            Case aCase = c;
            
            CaseWrapper wrapperCase = new CaseWrapper(aCase,false);
            
            lstCaseWrapper.add(wrapperCase);            
        }
        
    	return null;
    }
    
    public PageReference linkEmailToCase(){
        
        list<EmailMessage> lstLinkMessages = new list<EmailMessage>();
        list<Attachment> lstAttachments = new list<Attachment>();
        list<FeedItem> feeList = new list<FeedItem>();
        
        //Link current email message type 
        list<EmailMessage> em = [Select Id, TextBody, HtmlBody, Headers, Subject, MessageDate,  
                           FromName, FromAddress, ToAddress, CcAddress, BccAddress, 
                           Incoming, HasAttachment, Status 
                           From EmailMessage 
                           Where ParentId = :this.linkCase.Id AND isOriginalEmail__c = true  
                           Order By CreatedDate Asc Limit 1];
        
        if( em.size() > 0 ){
            
            //if there are email body blob attchments then add all to the list for this email message
            if(em[0].HasAttachment){
                for (Attachment att :[Select Id, Name, Body From Attachment Where ParentId = :em[0].Id and Name = 'Email Body.html']) {
                   lstAttachments.add(att);
                }
            }
            
            //Loop through all the selected related Cases
            list<Case> updateCheckList = new list<Case>();
            
            for(CaseWrapper cw :lstCaseWrapper){
                if(cw.IsChecked){
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
                    
                    emsg.ParentId = cw.wCase.Id;
                    
                    lstLinkMessages.add(emsg);
                    
                     //clone only the FeedItems pointing to the content and link to the related cases
 					for(FeedItem f : [Select RelatedRecordId, Type, Body, ParentId From FeedItem 
                                      Where ParentId = :linkCase.Id and Type = 'ContentPost']){
  
                    	FeedItem post = new FeedItem();
                        post.ParentId = cw.wCase.Id;
                        post.Body = f.Body;
                        post.RelatedRecordId = f.RelatedRecordId;
                        post.Type = 'ContentPost';
                        
                        feeList.add(post);
                	}
                    
                    cw.wCase.Case_Related_To_Email__c = this.linkCase.Id;
                    updateCheckList.add(cw.wCase);
                }
            }
            
            //check if the user selected at least one related case
            if(lstLinkMessages.size() > 0){
                //Now insert all new EmailMessages so we can get the records Id's in order
                //to link the attatchment list to the parent records
                
                try{
                    insert lstLinkMessages;
                }catch(DMLException ex){
                    System.debug('CSC Support : There was an error inserting the cloned EmailMessages for selected related cases');
                    System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> insert lstLinkMessages');
                    System.debug(ex.getMessage());
                }
                
                //loop through inserted EmailMessages, clone attachments and link to parent emailmessage
                list<Attachment> insertAtt = new list<Attachment>();
                
                for(EmailMessage msg :lstLinkMessages){
                    for(Attachment a :lstAttachments){
                        Attachment newAttachment = new Attachment();
                        newAttachment.ParentId = msg.Id;
                        newAttachment.Name = a.Name;
                        newAttachment.Body = a.Body;
                        
                        insertAtt.add(newAttachment);
                    }
                     
                }
				try{
                    insert  insertAtt;
                }catch(DMLException ex){
                    System.debug('CSC Support : There was an error inserting the cloned Attachments for selected related cases');
                    System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> insert  insertAtt');
                    System.debug(ex.getMessage());
                }
                
                try{
                    insert feeList;
                }catch(DMLException ex){
                    System.debug('CSC Support : There was an error inserting the cloned FeedItems with the related Case id as parentid');
                    System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> update feeList');
                    System.debug(ex.getMessage());
                }
               
                //update existing case
                 this.linkCase.Email_Action__c = 'Linked to Existing Case';
                 this.linkCase.Email_Status__c = 'Actioned';
                 this.linkCase.Status = 'Closed Resolved';
                
                try{
                    update this.linkCase;
                }catch(DMLException ex){
                    System.debug('CSC Support : There was an error updating the original email type case after it was linked to related cases');
                    System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> update this.linkCase');
                    System.debug(ex.getMessage());
                }
                
                try{
                    if(updateCheckList.size()>0){
                    	update updateCheckList;
                    }
                }catch(DMLException ex){
                    System.debug('CSC Support : There was an error updating the selected cases relationship to the email');
                    System.debug('CSC_Quick_Action_Link_Case_Cont -> linkEmailToCase() -> update updateCheckList');
                    System.debug(ex.getMessage());
                }
                
            }else{
                 return null;
            }
        }    
        
        return null;
    }
    
	 //NESTED CLASSES
    //Cases wrapper class to keep track of selected related Case
    public class CaseWrapper{
        
        public Case wCase {get;set;}
        public Boolean IsChecked {get;set;}
        
        public CaseWrapper(Case rec, Boolean chk){
            this.wCase = rec;
            this.IsChecked = chk;
        }
    }
}