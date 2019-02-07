global class AcmBatchJob implements Database.Batchable<sObject>, Database.AllowsCallouts {
	
   global Database.QueryLocator start(Database.BatchableContext BC){
     String notSendStatus = 'Not Sent to ACM';
     String query = 'SELECT Id, Collateral_Id__c, Status__c FROM Acm_Collateral_Status__c where Status__c = :notSendStatus';
     return Database.getQueryLocator(query);
   }
    
   global void execute(Database.BatchableContext info, List<Acm_Collateral_Status__c> AcmCollateralStatuses) {
        List<String> acmIds = new List<String>();
        for(Acm_Collateral_Status__c acmCollateralStatus : AcmCollateralStatuses) {
            String IdCom = acmCollateralStatus.Id +'-'+acmCollateralStatus.Collateral_Id__c;
            acmIds.add(IdCom);
        }
        AcmService.callService(acmIds);
   }
    
   global void finish(Database.BatchableContext info) {

		List<Acm_Collateral_Status__c>  AcmCollateralStatuses = [SELECT Id,Collateral__r.Name,
                                                                 Collateral__r.Acm_External_Id__c,Collateral__r.Beneficiary__r.Name,
                                                                 Collateral__r.Beneficiary__r.CIF__c,Collateral__r.Beneficiary__r.SDS__c,
                                                                 Collateral__r.Account__r.Name, Collateral__r.Account__r.SDS__c,
                                                                 Collateral__r.Account__r.CIF__c, Collateral__r.Facility_Client__r.Name,
                                                                 Collateral__r.AcmFacility__r.Facility_Id__c,Collateral__r.Scope__c,
                                                                 Collateral__r.Value__c,Collateral__r.CurrencyIsoCode,
                                                                 Collateral_Id__c, hasError__c, Collateral_No__c, Name, 
                                                                 Collateral_Owner__c,Collateral_Message__c, Status__c 
                                                                 FROM Acm_Collateral_Status__c where (Email_Sent__c = false AND Status__c = 'Sent to ACM') OR hasError__c = true];
        List<Acm_Collateral_Status__c> AcmCollateralStatusestoUpdate = new List<Acm_Collateral_Status__c>();

        String fileString = setHeaders();
        for(Acm_Collateral_Status__c acmCollateralStatus : AcmCollateralStatuses) {
            fileString = fileString + createLineOnFile(acmCollateralStatus.hasError__c,
                                                       acmCollateralStatus.Collateral__r.Acm_External_Id__c,
                                                       acmCollateralStatus.Collateral__r.Beneficiary__r.Name,
                                                       acmCollateralStatus.Collateral__r.Beneficiary__r.SDS__c,
                                                       acmCollateralStatus.Collateral__r.Beneficiary__r.CIF__c,
                                                       acmCollateralStatus.Collateral__r.Account__r.Name,
                                                       acmCollateralStatus.Collateral__r.Account__r.SDS__c,
                                                       acmCollateralStatus.Collateral__r.Account__r.CIF__C,
                                                       acmCollateralStatus.Collateral__r.Scope__c,
                                                       acmCollateralStatus.Collateral__r.Facility_Client__r.Name,
                                                       acmCollateralStatus.Collateral__r.AcmFacility__r.Facility_Id__c,
                                                       String.valueOf(acmCollateralStatus.Collateral__r.Value__c),
                                                       acmCollateralStatus.Collateral__r.CurrencyIsoCode,
                                                       acmCollateralStatus.Collateral_No__c, 
                                                       acmCollateralStatus.Name, 
                                                       acmCollateralStatus.Collateral_Owner__c, 
                                                       acmCollateralStatus.Collateral_Message__c);
            acmCollateralStatus.Email_Sent__c = true;
            AcmCollateralStatusestoUpdate.add(acmCollateralStatus);
        }
        
        if(AcmCollateralStatuses.size() > 0) {
            sendEmail(fileString);
            // Call job here to update
            System.scheduleBatch(new AcmBatchJobUpdate(), 'Salesforce ACM Job Update', 1, 10000);
        }
   } 
    
        
    public String setHeaders() {
       	return 'Collateral No, Collatera Name , Collateral Owner, Provider,Beneficiary,Facility Beneficiary,Acm Facility,Value Amount, Currency ,Result Message  \n';
    }
    
    public String createLineOnFile(boolean hasError,
                                   String External_Id, String BeneficiaryName, String BeneficiarySDS, String BeneficiaryCIF,
                                   String ProviderName,String ProviderSDS,String ProviderCIF, String Scope, String FacilityClient, String Facility,
                                   String Value,String CurrencyCode, String CollateralNo,  
                                   String CollateralName, String CollateralOwner, 
                                   String CollateralMessage) {
        String recordString = '';
        recordString = External_Id+','+CollateralName+','+CollateralOwner+','
            +ProviderName+':'+ProviderSDS+':'+ProviderCIF+','+BeneficiaryName+':'+BeneficiarySDS+':'+BeneficiaryCIF+','+ FacilityClient+','+Facility+ ',' +Value+','
            +CurrencyCode+','+ CollateralMessage.replace(',', '-') +'\n';
        return recordString;
    }
    
    public void sendEmail(String finalstr) {
        // Get admin email from the custom settings
        // Populate impersonation details
        AcmIntegration__c acmIntegration = [Select admin_email__c FROM AcmIntegration__c LIMIT 1];
        String admin_email = acmIntegration.admin_email__c;
        
        if(admin_email != NULL || admin_email != '') {
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(finalstr);
            String csvname= 'CollateralAcmReport.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {admin_email};
            String subject ='Collateral Acm Report';
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('Please find Collateral Acm Report');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
        }
    }
}