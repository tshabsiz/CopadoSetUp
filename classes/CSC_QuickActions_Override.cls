/*
* 2017-03-23 - RN - CloudSmiths
* Implements the QuickActionDefaultsHandler interface in order to override field values 
* on standard quick actions
* 2017-03-24 - RN - CloudSmiths: Default the Email Quick action's From address to the relevant Org Wide Address based on the queue
* 2017-06-08 - RN - CloudSmiths: Prevent From address to be overwitten by the Org wide email addresses
*/
global class CSC_QuickActions_Override implements QuickAction.QuickActionDefaultsHandler {  
    
    public string customLabelValue{get;set;}
    
    global CSC_QuickActions_Override(){}
    
    //Entry point  
    global void onInitDefaults(QuickAction.QuickActionDefaults[] defaults){ 
        
        QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = null;
        
        //RN - Check if the quick action is the standard Case Feed email action
        for (Integer j = 0; j < defaults.size(); j++) {  
            
            if (defaults.get(j) instanceof QuickAction.SendEmailQuickActionDefaults && 
                defaults.get(j).getTargetSObject().getSObjectType() == EmailMessage.sObjectType &&  
                defaults.get(j).getActionName().equals('Case.Email') && defaults.get(j).getActionType().equals('Email')) { 
                    
                    sendEmailDefaults = (QuickAction.SendEmailQuickActionDefaults)defaults.get(j);
                    
                    break;
                }  
        }  
        
        //get related Case and instance of the new email message object
        if (sendEmailDefaults != null) { 
            
            Case c = [Select Id, Email_From_Address__c, Email_Sender_Name__c, Service_Mapping_Entry__r.Response_From_Email_Address__c 
                      From Case Where Id =:sendEmailDefaults.getContextId()];
            
            EmailMessage emailMessage = (EmailMessage)sendEmailDefaults.getTargetSObject();
			
            //Replace first part of the email body HTML
            //Check if Page load and user click the quick action buttom OR else the user clicked on the reply/reply All link
            //if (sendEmailDefaults.getInReplyToId() == null) {
                
      			//strip body up until '<b>Sent:</b>'
                String strippedBody = getStrippedHeaderHtml(emailMessage.HtmlBody,'<b>Sent:</b>');
                
                //re-build body with new header
                String newHeader = getHtmlHeader(c.Email_From_Address__c,c.Email_Sender_Name__c);
                
                newHeader+=strippedBody;
                
                emailMessage.HtmlBody = newHeader;
                emailMessage.ToAddress = c.Email_From_Address__c;
                
            //}else{
                
                //get the reply to message and overwrite the FROM header peace
                ///EmailMessage replyMessage = [Select Id, FromAddress, FromName, HtmlBody From EmailMessage Where Id = :sendEmailDefaults.getInReplyToId()];
                
                //strip body up until '<b>Sent:</b>'
                ///String strippedBody = getStrippedHeaderHtml(replyMessage.HtmlBody,'<b>Sent:</b>');
                
                //re-build body with new header
                ///String newHeader = getHtmlHeader(replyMessage.FromAddress,replyMessage.FromName);
                
                ///newHeader+=strippedBody;
                
                ///emailMessage.HtmlBody = newHeader;
                ///emailMessage.ToAddress = replyMessage.FromAddress;
                
            //}
            
             //update the From address field with the relevant org wide email address for the queue the case belong to
            if(String.isNotBlank(c.Service_Mapping_Entry__r.Response_From_Email_Address__c)){
                
                list<OrgWideEmailAddress> orgwide = [Select Id, Address From OrgWideEmailAddress Where 
                                                     Address = :c.Service_Mapping_Entry__r.Response_From_Email_Address__c limit 1];
                
                if(orgwide.size() > 0){
                    emailMessage.FromAddress = orgwide[0].Address;
                }else{
                    emailMessage.FromAddress = UserInfo.getUserEmail();
                }
                
            }else{
                emailMessage.FromAddress = UserInfo.getUserEmail();
            }
        }  
        
    }  
    
    //RN -------------- Private methods ------------------------------------------
    private String getStrippedHeaderHtml(String body, String stripStopText){
    	String stripHeader = body;
        Integer x = stripHeader.indexOf(stripStopText);
        
        if(x > 0){
        	stripHeader = stripHeader.substring(x);
        }
       
        return stripHeader;
    }
    private String getHtmlHeader(String emailAddress, String senderName){
    	String newHeader =  '<html>' +
                    '<body>' +
                    '<br clear="none">' +
                    '<br clear="none">' +
                    '<br clear="none">------- The Original Message --------<br clear="none">' +
                    '<b>From:</b> ' + senderName + ' [' + emailAddress + ']<br clear="none">';
        return newHeader;
    }
}