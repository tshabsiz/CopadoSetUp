/**
* Author: Rudolf Niehaus - CloudSmiths
* Date:   2017-08-10
* Desc:   
**/
public class Payments_QA_SWIFT_Ext {
    
    public String selectedType {get;set;}
    public list<SelectOption> typeOptions {get;set;}
    public SWIFT_Message__c newSWIFT {get;set;}
    public Case parentCase {get;set;}
    public String userId {get;set;}
    private String approvers = '';
    
    public Payments_QA_SWIFT_Ext(ApexPages.StandardController controller){
        
        Case cont = (Case)controller.getRecord();
        
        parentCase = [Select Id, SWIFTMessageType__c, SWIFT_BIC_Code__c, SWIFT_GBP_Reference__c,
                      SWIFTTransactionReference__c, SWIFTPaymentMessage__c, SWIFTQueryMessage__c  
                      From Case Where Id = :cont.Id];
        
        newSWIFT = new SWIFT_Message__c();
        
        typeOptions = new list<SelectOption>();
        selectedType = '';
        //userId = UserInfo.getUserId();
        
        //get message response types from the custom metadata object
        list<SWIFT_Type_Mapping__mdt> msgTypes = [Select MessageResponseTypes__c From SWIFT_Type_Mapping__mdt 
                                                  Where MessageType__c = :parentCase.SWIFTMessageType__c limit 1];
        if(msgTypes.size() > 0){
            
            String mdtValue = msgTypes[0].MessageResponseTypes__c; 
            list<String> types = mdtValue.split(',');
            
            for(String s :types){
                typeOptions.add(new SelectOption(s,s));
                //set deafault message type
                if(String.isBlank(selectedType)){
                    selectedType = s;
                }
            }
            
        }else{
            //default all options if no entry were found
            typeOptions.add(new SelectOption('199', '199'));
            typeOptions.add(new SelectOption('195', '195'));
            typeOptions.add(new SelectOption('196', '196'));
            typeOptions.add(new SelectOption('192', '192'));
            typeOptions.add(new SelectOption('292', '292'));
            typeOptions.add(new SelectOption('295', '295'));
            typeOptions.add(new SelectOption('299', '299'));
            typeOptions.add(new SelectOption('999', '999'));
        } 
        
         //get valid approvers
        for(SWIFT_Approvers__mdt msgApprovers :[Select ApproverEmail__c From SWIFT_Approvers__mdt]){
            approvers+= msgApprovers.ApproverEmail__c + ',';
        }
    }
    
    public PageReference sendSWIFT(){
        
        newSWIFT.Case__c = parentCase.Id;
        newSWIFT.MessageType__c = selectedType;
        //newSWIFT.OriginalMessage__c = '';
        newSWIFT.QueryMessage__c = parentCase.SWIFTQueryMessage__c;
        newSWIFT.Approver__c = userId;
        newSWIFT.ValidApprovers__c = approvers;
        newSWIFT.DestinationAddress__c = newSWIFT.DestinationAddress__c.toUpperCase();
        try{
            insert newSWIFT;
        }catch(DMLException ex){
            System.debug('There was an Error inserting a new SWIFT outbound Message from the quick action button');
            System.debug(ex.getMessage());
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an Error inserting a new SWIFT Message'));
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
        }
        
        //clear values on form 
        newSWIFT = new SWIFT_Message__c();
        
        return null;
    }
}