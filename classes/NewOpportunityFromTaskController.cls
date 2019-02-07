public class NewOpportunityFromTaskController {
    public static Map<Id, String> recordtypemap {get;set;}
    
    @AuraEnabled
    public static List<String> fetchRecordTypeValues(){
        List<Schema.RecordTypeInfo> recordtypes = Opportunity.SObjectType.getDescribe().getRecordTypeInfos();    
        recordtypemap = new Map<Id, String>();
        for(RecordTypeInfo rt : recordtypes){
            if(rt.getName() != 'Master' && rt.isAvailable())
            recordtypemap.put(rt.getRecordTypeId(), rt.getName());
        }
        return recordtypemap.values();
    }
    
    @AuraEnabled
    public static Task getTaskFields(Id recId){
        return [SELECT Status, WhatId, What.RecordType.Name, Campaign__c FROM Task WHERE Id =: recId];
    }
    
    @AuraEnabled
    public static Id getRecTypeId(String recordTypeLabel){
        Id recid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(recordTypeLabel).getRecordTypeId();        
        return recid;
    }      
}