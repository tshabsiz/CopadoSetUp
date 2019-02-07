/**
 * 2018-02-24
 * Rudolf Niehaus - CloudSmiths
**/
public class lscFlagCaseExt {
    
    @AuraEnabled
    public static void flagCase(String caseId, String theAction){
        
        Case c = [Select Id, Status, Email_Action__c, Email_Status__c From Case Where Id = :caseId];
        c.Email_Action__c = theAction;
        c.Email_Status__c = 'Actioned';
        c.Status = 'Closed Resolved';
        update c;
    }
}