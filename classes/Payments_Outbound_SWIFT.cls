/**
* Date:  2017-08
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  RESTful Apex service for the SWIFT integration
**/
public class Payments_Outbound_SWIFT {

    public static String msgId = '';
    public static String msgName = '';
    
    public static void postToSWIFT(SWIFT_Message__c newMsg){
        
        msgId = newMsg.Id;
        msgName = newMsg.Name;
        String answers = '';
        String destinationAddress = '';
        Integer messageType = 0;
        String narrative = '';
        String narrativeOrig = '';
        String queries = '';
        String relatedReference = '';
        String salesforceId = '';
        String senderAddress = newMsg.Sender_Address__c;
        
        Long swiftId = 0;
        
        if(String.isNotBlank(newMsg.OriginalSWIFTId__c)){
            swiftId = Long.valueOf(newMsg.OriginalSWIFTId__c);
        }
        
        String transactionReference = '';
        
        //validation
        if(String.isNotBlank(newMsg.Answers__c)){
            answers = newMsg.Answers__c;
        }
        if(String.isNotBlank(newMsg.DestinationAddress__c)){
            destinationAddress = newMsg.DestinationAddress__c;
        }
        if(String.isNotBlank(newMsg.MessageType__c)){
            messageType = Integer.valueOf(newMsg.MessageType__c);
        }
        if(String.isNotBlank(newMsg.Narrative_OriginalMsg__c)){
            narrativeOrig = newMsg.Narrative_OriginalMsg__c;
        }
        if(String.isNotBlank(newMsg.Narrative__c))
        {
            narrative = newMsg.Narrative__c;
        }
        if(String.isNotBlank(newMsg.Queries__c)){
            queries = newMsg.Queries__c;
        }
        if(String.isNotBlank(newMsg.RelatedReference__c)){
            relatedReference = newMsg.RelatedReference__c;
        }
        if(String.isNotBlank(newMsg.Id)){
            salesforceId = newMsg.Case__c;
        }
        if(String.isNotBlank(newMsg.TransactionReference__c)){
            transactionReference = newMsg.TransactionReference__c;
            
            if(String.isNotBlank(newMsg.DateOfOriginalMessage__c ) && String.isNotBlank(newMsg.MT_the_Original_Message__c )){
                transactionReference = transactionReference+' ; '+newMsg.MT_the_Original_Message__c + '\n' + newMsg.DateOfOriginalMessage__c;
            }
        }
        
        //build JSON file
        JSONGenerator gen = JSON.createGenerator(true);
       
        gen.writeStartObject();
        
        gen.writeStringField('answers', answers);
        gen.writeStringField('destinationAddress', destinationAddress);
        gen.writeNumberField('messageType',messageType);
        gen.writeStringField('narrativeOriginalMsg',narrativeOrig);
        gen.writeStringField('narrative',narrative);
        gen.writeStringField('queries',queries);
        gen.writeStringField('relatedReference',relatedReference);
        gen.writeStringField('salesforceId',salesforceId);
        gen.writeStringField('senderAddress',senderAddress);
        gen.writeNumberField('swiftId', swiftId );
        gen.writeStringField('transactionReference',transactionReference);
        
        gen.writeEndObject();
        
        System.debug(gen.getAsString());
        
        doHttpPost(gen.getAsString(), msgId, msgName);            
        
    }
    
    @future (callout=true)
    private static void doHttpPost(String jsonBody, String msgId, String msgName) {
        
        //get api settings for Sf 2 SWIFT
        list<Integration_Settings_General__mdt> mdt = [Select ClientID__c, ClientSecret__c, ContentType__c, EndPoint__c 
                                                       From Integration_Settings_General__mdt  
                                                      Where DeveloperName = 'SF_2_SWIFT'];
        if(mdt.size() > 0){
            try{                        
                HttpRequest req = new HttpRequest();
                req.setMethod('POST');
                req.setTimeout(120000);
                req.setEndpoint(mdt[0].EndPoint__c);
                req.setHeader('Content-Type', mdt[0].ContentType__c);
                req.setHeader('X-IBM-Client-Id', mdt[0].ClientID__c);
                req.setHeader('X-IBM-Client-Secret', mdt[0].ClientSecret__c);
                req.setBody(jsonBody);
                
                Http http = new Http();
                HttpResponse response =  http.send(req);
                
                //handle response
                String jsonstr = response.getBody();
                System.debug(jsonstr);
                map<String, Object> objMap = (map<String, Object>)JSON.deserializeUntyped(jsonstr);
    
                logResults(objMap, msgId, msgName);            

                
            }catch(System.CalloutException e) {
                System.debug('CalloutException!');
                System.debug(e.getMessage());
            }
        }else{
            System.debug('There are no settings defined for the Sf to SWIFt API');
        }
    }
    
    public static void logResults(map<String, Object> theResult, String msgId, String msgName){
        
        
        String message = (String)theResult.get('message');
        String swiftMessage = (String)theResult.get('swiftMessage');
        String salesforceId = (String)theResult.get('salesforceId');
        Boolean success = (Boolean)theResult.get('sucess');
        
        SWIFT_Message__c updateMsg = [Select StatusUpdate__c From SWIFT_Message__c Where Id = :msgId];
        
        if(success != null){
            if(success){
                 updateMsg.StatusUpdate__c = 'Approved and Sent:\n' + swiftMessage;
            }else{
                updateMsg.StatusUpdate__c = 'Failed : \n' + message;
                updateMsg.RejectMessage__c = true;
                updateMsg.ApproveMessage__c = false;
            }        
        }else{
            updateMsg.StatusUpdate__c = 'No Information Available';
            updateMsg.RejectMessage__c = true;
            updateMsg.ApproveMessage__c = false;
        }
        
        try{
            update updateMsg;
        }catch(DMLexception ex){
            System.debug(ex.getMessage());
        }
        
        //Create new feeditem on the parent case

        FeedItem logmsg = new Feeditem();
        logmsg.ParentId = salesforceId;
        if(success != null){
            if(success){
                 logmsg.Body = msgName + ' Approved and Sent : ' + swiftMessage;
                 logmsg.Title = msgName + 'Approved and Sent : ' + swiftMessage;
            }else{
                logmsg.Title = msgName + ' Failed : ' + message;
                logmsg.Body = msgName + ' Failed : ' + message;
            }        
        }else{
            logmsg.Title = 'No Information Available';
            logmsg.Body = 'No Information Available';
        }
        try{
            insert logmsg;
        }catch(DMLexception ex){
            System.debug(ex.getMessage());
        }
    }
}