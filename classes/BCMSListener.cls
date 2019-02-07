/**
* @author Deloitte 
* @date 2015
*
* @group WebService / Integration
*
* @description a web service class to receive notifications from BCMS with logic to handle them
*/

global class BCMSListener {

    webservice String caseId;
    webservice String action;
    webservice String xmlPayload;


     //constant value to be shown in chatter message for the owner of the day1template
     private static final String TEXT_FOR_OWNER = 'Hello, your action is required on this onboarding template. Last update done at ' + String.valueOf(System.now()) + ' ';
     private static final String CONFIRMATION_REQUIRED = 'Attestation Data Confirmation Required';
     private static final String ESP_BCMS_CASE_CREATED = 'ESP.BCMS.CASE.CREATED';
     private static final String ESP_ONBOARDING_CLIENT_DETAILS_UPDATED = 'ESP.ONBOARDING.CLIENT.DETAILS.UPDATED';
     private static final String ESP_ONBOARDING_CLIENT_SCREENED = 'ESP.ONBOARDING.CLIENT.SCREENED';
     private static final String ESP_ONBOARDING_INSTRUCTION_SUBMITTED = 'ESP.ONBOARDING.INSTRUCTION.SUBMITTED';
     private static final String ESP_ONBOARDING_CLIENT_RISK_PROFILED = 'ESP.ONBOARDING.CLIENT.RISK.PROFILED';
     private static final String ESP_ONBOARDING_CLIENT_ATTESTATION_REQUIRED = 'ESP.ONBOARDING.CLIENT.ATTESTATION.REQUIRED';
     private static final String ESP_BCMS_CASE_CLOSED = 'ESP.BCMS.CASE.CLOSED';
     private static final String STATUS_CASE_CREATED = 'Case Created';
     private static final String STATUS_DETAILS_UPDATED = 'Details Updated';
     private static final String STATUS_CLIENT_SCREENED = 'Client Status Screened';
     private static final String STATUS_INSTRUCTIONS = 'Instructions Submitted';
     private static final String STATUS_RISK_PROFILED = 'Client Risk Profiled';
     private static final String STATUS_ATTESTATION_REQUIRED = 'Attestation Data Confirmation Required';
     private static final String STATUS_CLOSED = 'Case Closed';

    webService static Boolean BCMSNotificationListener(String caseId, String action, String xmlPayload) {   

        Map<String,String> parsedXML = BCMSIntegration_Helper.parseBCMSAtestationXML(xmlPayload);
        String prospectCaseId;
        Day_1_Template__c day1Temp;
        String attestationResponse;
        String status;

        if(parsedXML.containsKey('ProspectCaseID')) {
            prospectCaseId = parsedXML.get('ProspectCaseID');
            if(String.isNotEmpty(prospectCaseId)) {
                day1Temp = [SELECT Id, Status__c, BCMSXMLData__c, Primary_Legal_Entity__r.OwnerId, BCMS_Client_Id__c FROM Day_1_Template__c WHERE BCMS_Prospect_Id__c =:prospectCaseId LIMIT 1];
            }

            if(parsedXML.containsKey('AttestationResponse')) {
                attestationResponse = parsedXML.get('AttestationResponse');

                if(attestationResponse == ESP_BCMS_CASE_CREATED) {
                    status = STATUS_CASE_CREATED;
                } else if(attestationResponse == ESP_ONBOARDING_CLIENT_DETAILS_UPDATED) {
                    status = STATUS_DETAILS_UPDATED;
                } else if(attestationResponse == ESP_ONBOARDING_CLIENT_SCREENED) {
                    status = STATUS_CLIENT_SCREENED;
                } else if(attestationResponse == ESP_ONBOARDING_INSTRUCTION_SUBMITTED) {
                    status = STATUS_INSTRUCTIONS;
                } else if(attestationResponse == ESP_ONBOARDING_CLIENT_RISK_PROFILED) {
                    status = STATUS_RISK_PROFILED;
                } else if(attestationResponse == ESP_ONBOARDING_CLIENT_ATTESTATION_REQUIRED) {
                    status = STATUS_ATTESTATION_REQUIRED;
                } else if(attestationResponse == ESP_BCMS_CASE_CLOSED) {
                    status = STATUS_CLOSED;
                } 
            }
        }  
        try {
            if(day1Temp != null) {
                day1Temp.Status__c = status;
                day1Temp.BCMSXMLData__c = xmlPayload;
                day1Temp.BCMS_Client_Id__c = caseId;
                Id parentId = day1Temp.Primary_Legal_Entity__r.OwnerId;

                update day1Temp;
                ChatterUtils.createChatterPostWithMention(day1Temp.Id, TEXT_FOR_OWNER, parentId);
            }  
        } catch(exception e) {
            return false;
        }
        return true;  
    }
}