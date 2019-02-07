/**
* 2017-07-06
* Rudolf Niehaus - CloudSmiths
* Desc : When SWIFt message is approved - Change record type to readOnly and send msg to Meridian API
========================================================
* Modified Date : 2018-04-12
* Modified By :Mabhedle Tonga 
* Description : Included newly added field(MT_the_Original_Message__c) when sending swift message to SWIFT
==========================================================================================================
**/
public class Payments_SWIFT_Trigger_Func {
    
    public static void makeReadOnly(list<SWIFT_Message__c> newMessages, map<Id,SWIFT_Message__c> oldMap){ 
        
        list<RecordType> swiftRecs = [Select Id From RecordType Where DeveloperName = 'SWIFT_Inbound'];
        list<RecordType> swiftRecsOut = [Select Id From RecordType Where DeveloperName = 'SWIFT_Outbound'];
             
        for(SWIFT_Message__c s :newMessages){
            if( s.ApproveMessage__c && !oldMap.get(s.Id).ApproveMessage__c ){
                if(swiftRecs.size()>0){
                     s.RecordTypeId = swiftRecs[0].Id;
                }
            }
            if(s.RejectMessage__c && !oldMap.get(s.Id).RejectMessage__c){
                if(swiftRecsOut.size()>0){
                     s.RecordTypeId = swiftRecsOut[0].Id;
                }
            }
            //messages was updated in the rejection state, move it back to await approval
            if(s.RejectMessage__c && oldMap.get(s.Id).RejectMessage__c){
                s.RejectMessage__c = false;
                s.ApproveMessage__c = false;
            }
            
            s.SWIFTMessage__c = constructSWIFT(s);
        }
        
    }
    
    public static void generateSWIFT(list<SWIFT_Message__c> newMessages, map<Id,SWIFT_Message__c> oldMap){ 
        if(newMessages.size() > 0){
            if( newMessages[0].ApproveMessage__c && !oldMap.get(newMessages[0].Id).ApproveMessage__c ){
                 //PUSH TO SWIFT VIA REST API REQUEST  
                 Payments_Outbound_SWIFT.postToSWIFT(newMessages[0]);  
            }     
        }
    }
    
    
    public static void updateSWIFTMessage(list<SWIFT_Message__c> newMessages){
        for(SWIFT_Message__c s :newMessages){
             s.SWIFTMessage__c = constructSWIFT(s);
            if(s.IsOriginalMessage__c){
                s.MessageFlowDirection__c = 'In';
            }else{
                s.MessageFlowDirection__c = 'Out';
            }   
        }
    }    
    //construct Outbound SWIFT message
    public static String constructSWIFT(SWIFT_Message__c newMessages){ 
        /**
         "{20:" + TransactionReference__c + "}" + BR() +
         "{21:" + RelatedReference__c + "}" + BR() + 
         "{75:}" + Queries__c  
        "{1:" + Sender_Address__c + "}" + BR() + 
        "{2:" + DestinationAddress__c + "}" + BR() +           
        "{76:" + Answers__c + "}" + BR() + 
        "{79:" + Narrative__c + "}"
        "{115:" + Narrative__c + "}"
           **/ 
        String theMessage = ''; 
        
        if(String.isNotBlank( newMessages.Sender_Address__c)){
            theMessage = theMessage + '{1:' + newMessages.Sender_Address__c + '\n';
        }
        if(String.isNotBlank(newMessages.DestinationAddress__c)){
             theMessage = theMessage + '{2:' + newMessages.DestinationAddress__c + '\n';
        }
        if(String.isNotBlank(newMessages.TransactionReference__c)){
             theMessage = theMessage + '{20:' + newMessages.TransactionReference__c + '\n';
        }
       if(String.isNotBlank(newMessages.RelatedReference__c)){
             theMessage = theMessage + '{21:' + newMessages.RelatedReference__c + '\n';
        }
        if(String.isNotBlank(newMessages.DateOfOriginalMessage__c ) && String.isNotBlank(newMessages.MT_the_Original_Message__c )){
             theMessage = theMessage + '{11s:' + newMessages.MT_the_Original_Message__c + ' ' + newMessages.DateOfOriginalMessage__c + '\n';
        }
        if(String.isNotBlank(newMessages.Queries__c)){
             theMessage = theMessage + '{75:' + newMessages.Queries__c + '\n';
        }
        if(String.isNotBlank(newMessages.Answers__c)){
             theMessage = theMessage + '{76:' + newMessages.Answers__c + '\n';
        }
        if(String.isNotBlank(newMessages.Narrative__c)){
             theMessage = theMessage + '{77A:' + newMessages.Narrative__c + '\n';
        }
        if(String.isNotBlank(newMessages.Narrative_OriginalMsg__c)){
             theMessage = theMessage + '{79:' + newMessages.Narrative_OriginalMsg__c + '\n';
        }
        return theMessage;
    }
}