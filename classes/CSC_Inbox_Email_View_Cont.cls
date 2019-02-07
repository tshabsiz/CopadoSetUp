/**
* Date   : 09-04-2016
* Author : RN - CloudSmiths
* Desc   : Controller that push the email body and related attachments to the Service console VF custom component.
**/
public class CSC_Inbox_Email_View_Cont {

    public list<EmailMessage> em {get;set;}
    public list<Attachment> att {get;set;}
    public boolean isNotEmpty {get;set;}
    public boolean hasEmailBodyBlob {get;set;}
    public String caseID;
    public String bodyContent{get;set;}
    
     public CSC_Inbox_Email_View_Cont(ApexPages.StandardController controller){
     	
         String conId = ApexPages.currentPage().getParameters().get('Id');
         caseID = conId;
         if(conId != null){
             em = [Select Id, TextBody, HtmlBody, Headers, Subject, 
              FromName, FromAddress, ToAddress, CcAddress, BccAddress, 
              Incoming, HasAttachment, Status FROM EmailMessage 
              Where ParentId = :conId AND isOriginalEmail__c = true];
              
             if(em.size() > 0){
                 
                 isNotEmpty = true;
                 
                 att = [Select Id, Name, Body From Attachment Where ParentId = :em[0].Id and Name = 'Email Body.html'];
                 if(att.size() > 0){
                     hasEmailBodyBlob = true;
                     bodyContent = att[0].Body.toString();
                 }else{
                      hasEmailBodyBlob = false;
                 }
             }else{
                 isNotEmpty = false;
             }	             
         }
     }
}