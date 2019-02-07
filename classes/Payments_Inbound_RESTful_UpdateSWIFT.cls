/**
* Date:  2017-06-29
* Autor: Rudolf Niehaus - CloudSmiths
* Desc:  RESTful Apex service for the SWIFT integration
**/
@RestResource(urlMapping='/updateSWIFT/*')
global Without Sharing class Payments_Inbound_RESTful_UpdateSWIFT{
    
    @HttpPost
    global static String updateSWIFTMessage(String salesforceID, String status, String description ){
        
        boolean validationOk = true;
        String errorMessage = '';
        map<String, Schema.RecordTypeInfo> swiftRecordTypeMap = SWIFT_Message__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        //Generate pretty JSON file
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        
        //check JSON values
        if(String.isBlank(salesforceID) || salesforceID.length() < 15){
            validationOk = false;
            errorMessage = 'Missing or invalid Value salesforceID'; 
        }
        if(String.isBlank(description)){
            validationOk = false;
            errorMessage = 'Missing Value description'; 
        }
        if(status.equalsIgnoreCase('ack')){
            validationOk = false;
            errorMessage = 'Missing Value status';  
        }
        
        if(!validationOk){
            gen.writeBooleanField('status',false);
            gen.writeStringField('description', 'Failed : ' + errorMessage);
            gen.writeEndObject();
            return gen.getAsString();
        }
        
        //Get related Case
        list<Case> relatedCase = [Select Id From Case Where Id = :salesforceID];
        
        if(relatedCase.size() == 0){
            gen.writeBooleanField('status',false);
            gen.writeStringField('description', 'Failed : There is no Case in Salesforce for this ID ' + salesforceID);
            gen.writeEndObject();
            return gen.getAsString();
        }
        
        //New SWIFT
        SWIFT_Message__c SWIFT = new SWIFT_Message__c();
        SWIFT.Case__c = relatedCase[0].Id;
        SWIFT.QueryMessage__c = description;
        Swift.RejectMessage__c  =true;
        Swift.StatusUpdate__c = status;
        SWIFT.RecordTypeId = swiftRecordTypeMap.get('SWIFT Inbound').getRecordTypeId();
        
        try{
            
            insert SWIFT;
            
            gen.writeBooleanField('status',true);
            gen.writeStringField('description','Successful : SWIFT message in Salesforce updated for ID ' + salesforceID);
            
            
        }catch(DMLException e){
            System.debug('INBOUND API Error : There was an error insertig a new SWIFt message->Payments_Inbound_RESTful_UpdateSWIFT'); 
            System.debug(e.getMessage()); 
            gen.writeBooleanField('status',false);
            gen.writeStringField('description',e.getMessage());
            gen.writeEndObject();
            return gen.getAsString();
        }  
        
        //pass JSON back to poster
        gen.writeEndObject();
        return gen.getAsString();
    }
}