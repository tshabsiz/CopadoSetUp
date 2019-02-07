/**
* Date   : 2017-03-01
* Author : Rudolf Niehaus - CloudSmiths
* Desc   : Controller for the lightning component lscTransferCase.cmp: Transfere an 
           email type case to a new queue and update the initial values from the service mapping table
		   based on te new queue name
**/
public class lscTransferCaseExt {
    
    @AuraEnabled
    public static void transferCase(String caseId, String qname){
       
       Case actionCase = [Select Id, Team__c, Department__c, Queue__c From Case Where Id = :caseId];
        
       list<Service_Mapping__c> sm = [Select Id, Queue_Name__c, Queue__c, Team__c, Department__c, Business_Hours__c, Full_Department__c  
                                      From Service_Mapping__c  
                                      Where Queue__c = :qname Order By Effective_Date__c DESC limit 1];
        
        
        if(sm.size() > 0){
        
		String queueId = [Select Id From Group Where DeveloperName = :sm[0].Queue_Name__c AND Type = 'Queue'].Id;
        
            if(String.isNotBlank(queueId)){
                system.debug('64666666666666666');
                //reset values based on new queue selection
                actionCase.OwnerId = queueId;
                actionCase.Full_Department__c = sm[0].Full_Department__c;
                actionCase.Service_Mapping_Entry__c = sm[0].Id;
                actionCase.Queue__c = actionCase.Queue__c;
                actionCase.Team__c = sm[0].Team__c;
                actionCase.Department__c = sm[0].Department__c;
                actionCase.Business_Hours__c = sm[0].Business_Hours__c;
                actionCase.Email_Action__c = 'Transferred';
                
                try{
                    update actionCase;
                }catch(DMLException ex){
                    System.debug('Error when a user transfer an email type case');
                    System.debug('lscTransferCaseExt -> transferCase() -> update actionCase');
                    System.debug('Additional Info:' + ex.getMessage());
                }
            }
        }
    }

}