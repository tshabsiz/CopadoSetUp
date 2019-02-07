global class AcmReportCollateralSchedule implements System.Schedulable {
    
    global void execute(SchedulableContext SC) {
        boolean FalseVar = false;
		List<Acm_Collateral_Status__c>  AcmCollateralStatuses = [SELECT Id, Collateral_Id__c, hasError__c, Collateral_No__c, Name, Collateral_Owner__c,Collateral_Message__c, Status__c FROM Acm_Collateral_Status__c where Email_Sent__c = :FalseVar];
        List<Acm_Collateral_Status__c> AcmCollateralStatusestoUpdate = new List<Acm_Collateral_Status__c>();

        String fileString = setHeaders();
        for(Acm_Collateral_Status__c acmCollateralStatus : AcmCollateralStatuses) {
            fileString = fileString + CreateLineOnFile(acmCollateralStatus.hasError__c, acmCollateralStatus.Collateral_No__c, acmCollateralStatus.Name, acmCollateralStatus.Collateral_Owner__c, acmCollateralStatus.Collateral_Message__c);
            acmCollateralStatus.Email_Sent__c = true;
            AcmCollateralStatusestoUpdate.add(acmCollateralStatus);
        }
        
        if(AcmCollateralStatuses.size() > 0) {
            SendEmail(fileString);
            update AcmCollateralStatusestoUpdate;
        }
    }
    
        
    public String setHeaders() {
       	return 'Collateral No, Collatera Name , Collateral Owner, Status, ERROR DETAILS \n';
    }
    
    public String CreateLineOnFile(boolean hasError, String CollateralNo,  String CollateralName, String CollateralOwner, String CollateralMessage) {
        String recordString = '';
        if(!hasError) {
            recordString = CollateralNo+','+CollateralName+','+CollateralOwner+',SENT TO ACM SUCCESSFULLY, NONE \n';
        } else {
            recordString = CollateralNo+','+CollateralName+','+CollateralOwner+',COULD NOT SEND TO ACM,' + CollateralMessage + '\n';
        }  
        return recordString;
    }
    
    public void SendEmail(String finalstr) {
        // Get admin email from the custom settings
        // Populate impersonation details
        AcmIntegration__c acmIntegration = [Select admin_email__c FROM AcmIntegration__c LIMIT 1];
        String admin_email = acmIntegration.admin_email__c;
        
        
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