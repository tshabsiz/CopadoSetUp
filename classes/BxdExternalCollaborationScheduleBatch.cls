/**
* @Author       Kapeshi.Kongolo@bsg.co.za
* @Company:     BSG
* @Description: Schedulable Batch class for Box External Collaboration that process callout to box to remove collaboration on folders
* @Date:        2018
*/
global class BxdExternalCollaborationScheduleBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    global Database.QueryLocator start(Database.BatchableContext BC){
        DateTime currentTime = System.now();
        System.debug('***Bxd Start ' + currentTime);
        return  Database.getQueryLocator([SELECT Id, Folder_Id__c, Folder_Name__c, Access_Valid_Until__c, Processed__c,
                                          (
                                              SELECT
                                              Id,
                                              Member_Email__c,
                                              Collaboration_Id__c,
                                              External_Collaboration_Request__c
                                              FROM Request_Members__r 
                                          )
                                          FROM External_Collaboration_Request__c
                                          WHERE Access_Valid_Until__c <= TODAY AND Processed__c = false]);
    }
    
    global void execute(Database.BatchableContext info, List<SObject>   scope) {
        //get the scope results
        List<External_Collaboration_Request__c> collaborationRequests =(List<External_Collaboration_Request__c>)scope;
        
        //run service to remove box collaboration on folder
        BxdExternalCollaborationService.removeExternalCollaboration(collaborationRequests);
    }
    
    global void finish(Database.BatchableContext BC) {
        //Get job details.
        AsyncApexJob jobDetails = [SELECT Id, ApexClass.Name, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        String messageBody = 'The batch Apex job ('+jobDetails.ApexClass.Name+') processed ' + jobDetails.TotalJobItems+' batches with '+ jobDetails.NumberOfErrors + ' failures.';
        
        System.debug(messageBody);
    } 
}