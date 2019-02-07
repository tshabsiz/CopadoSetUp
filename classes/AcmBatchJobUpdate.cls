global class AcmBatchJobUpdate implements Database.Batchable<sObject> {
    
   global Database.QueryLocator start(Database.BatchableContext BC){
     String sendStatus = 'Sent to ACM';
     String query = 'SELECT Id, Collateral_Id__c, hasError__c, Collateral_No__c, Name, Collateral_Owner__c,Collateral_Message__c, Status__c FROM Acm_Collateral_Status__c where (Email_Sent__c = false AND Status__c = :sendStatus) OR hasError__c = true';
     return Database.getQueryLocator(query);
   }
    
   global void execute(Database.BatchableContext info, List<Acm_Collateral_Status__c> AcmCollateralStatuses){
		List<Acm_Collateral_Status__c> AcmCollateralStatusestoUpdate = new List<Acm_Collateral_Status__c>();
       
        for(Acm_Collateral_Status__c acmCollateralStatus : AcmCollateralStatuses) {
            acmCollateralStatus.Email_Sent__c = true;
            AcmCollateralStatusestoUpdate.add(acmCollateralStatus);
        }
        Database.Update(AcmCollateralStatusestoUpdate, false);
   }
    
   global void finish(Database.BatchableContext info) {
   }
}