/**
* @author Deloitte 
* @date 2015
*
* @group Controller
*
* @description Controller for page that allows users to create BCMS case from day1template
*/

public class BCMSControlPageController {

    public class BarclaysException extends Exception {}

    public String outcomeOfWSCall {get; set;}                       //String holding values of errors and other texts that needs to be paseed back to user
    public Boolean isCreateSuccess {get; set;}                      //Boolean value containing info whether case was created or not / used to disable button
    public Boolean bcmsCreated {get; set;}                          //Id will be populated in case that Onboarding has been already created in BCMS
    public Day_1_Template__c day1Info {get; set;}                   //returning values to be shown on the page - initialized in the controller
    public Id attachId {get; set;}                                  //variable to be pased by java script to controller for saving documents
    public Boolean attestationreceived {get; set;}                  //variable to decide to render attestation section on onboarding recrod
    public String confirmationValue {get; set;}                     //variable to hold information about confirmation or declination for attestation data
    public String declinationReason {get;set;}                      //variable to hold declination reason if banker decline attestation data
    public String sicDescription {get; set;}                        //variable to hold SIC description
    public String iscDescription {get; set;}                        //variable to hold ISC description
    public String legalDescription {get; set;}                      //variable to hold Legal description
    public String legalEntityType {get; set;}                       //variable to hold Legal Entity Type description
    public String personDesignation {get; set;}                     //variable to hold Person Designation description
    public String miFlag {get; set;}                                //variable to hold MIFlag description

    private Id day1Id;
    private String bcmsCaseId;
    private static final String LOAD_PAGE_ERROR = 'Id cannot be null';
    private static final String ATESTATION_RESPONSE = 'AttestationResponse';
    private static final String EVENT_MESSAGE_TYPE = 'EventMessageType';
    private static final String STATIC_RESOURCE_NAME = 'Picklists';
    private static final String FILE_EXTENSION = 'txt';
    private static final String SIC_FILE_NAME = 'SICJSON';
    private static final String ISC_FILE_NAME = 'ISCJSON';
    private static final String LEGAL_FILE_NAME = 'LegalJSON';
    private static final String PERSON_DESIGNATION_FILE_NAME = 'DesignationJSON';
    private static final String MI_FLAG_FILE_NAME = 'MiFlagJSON';
    private static final String CONFIRMED = 'Attestation Data Confirmed';
    private static final String DECLINED = 'Attestation Data Declined';


    /**
    * @description define controller as a derivation of a standard controller. load day1template data and info about existing documents in BCMS
    * @param ApexPages.StandardController stdController
    * @return No return value
    */  
    public BCMSControlPageController(ApexPages.StandardController stdController) {
        day1Id = ApexPages.currentPage().getParameters().get('Id');

        if (String.isBlank(day1Id)) {        
            throw new BarclaysException(LOAD_PAGE_ERROR);
        }

        //initialize all necessary data
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
        day1Info = bcmsIntH.getDay1Record(day1Id);
        bcmsCreated = String.isNotBlank(day1Info.BCMS_Prospect_Id__c);
        attestationreceived = String.isNotBlank(day1Info.BCMSXMLData__c);
        //System.debug('XXXXXXXXX bcmscreated' + bcmsCreated);
            if (bcmsCreated) {
                bcmsCaseId = day1Info.BCMS_Prospect_Id__c;
                //System.debug('XXXXXXXXX bcmscaseId' + bcmsCaseId);
            } 
    }

    /**
    * @description method to handle save functionality - calling method to invoke WS call
    * @param no params
    * @return 
    */  
    public pageReference saveCase() {
        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
        outcomeOfWSCall = bcmsIntH.createBCMSCase(day1Id);
        isCreateSuccess = bcmsIntH.isCreateSuccess;
        return null;
    }

    /**
    * @description method obtaining all fields needed to be shown on VF page
    * @param no params
    * @return da1template record
    */ 
    public List<Attachment> getAssignedAttachments() {
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
        List<Attachment> attachments = bcmsIntH.getDay1Attachments(day1Id);
        return attachments;
    }

    /**
    * @description method to handle adding more docs - calling method to invoke WS call
    * @param no params
    * @return 
    */  
    public pageReference saveDocument() {
        // initialize the helper class
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
        outcomeOfWSCall = bcmsIntH.createBCMSDocument(attachId, bcmsCaseId, day1Id);
        isCreateSuccess = bcmsIntH.isCreateSuccess;
        return null;
    }    

    /**
    * @description method to return SF IDs of documents created in BCMS
    * @param no params
    * @return String JSON savedDocIds
    */  
    public String getSavedDocumentsIdsJson() {
        List<Id> savedDocIds = new List<Id>();
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
        List<BCMSDocumentIdPairing__c> pairings = bcmsIntH.getDocPairing(day1Id);
        
        for (BCMSDocumentIdPairing__c pair : pairings) {
            savedDocIds.add(pair.SFDocumentId__c);
        }
        return JSON.serializePretty(savedDocIds);
    }

    /**
    * @description method to return attestation data in a map getting them to a list so we can show them on the page
    * @param no params
    * @return List of parsedXMLElement
    */  
    public List<ParsedXMLElement> getAttestationDataToShow() {

        Map<String, String> parsedXMLMap = BCMSIntegration_Helper.parseBCMSAtestationXML(day1Info.BCMSXMLData__c);
        List<parsedXMLElement> parsedList = new List<parsedXMLElement>(); 

        if (!parsedXMLMap.isEmpty()) {
            for(String singleNode : parsedXMLMap.keySet()) {
                ParsedXMLElement parsedElement = new ParsedXMLElement();
                parsedElement.nodName = singleNode;
                parsedElement.nodValue = parsedXMLMap.get(singleNode);

                parsedList.add(parsedElement);
            }
        }
        //System.debug('XXXXXXXXX parsedList' + parsedList);
        return parsedList;   
    }

    /**
    * @description method to save attestation confrimation to the XMl and update case in BCMS
    * @param no params
    * @return null
    */      
    public pageReference confirmAttestationData() {
        
        BCMSIntegration_Helper bcmsIntH = new BCMSIntegration_Helper();
        String updatedXML = BCMSIntegration_Helper.updateBCMSXMLNode(day1Info.BCMSXMLData__c, confirmationValue, ATESTATION_RESPONSE);
        updatedXML = BCMSIntegration_Helper.updateBCMSXMLNode(updatedXML, ATESTATION_RESPONSE, EVENT_MESSAGE_TYPE);
        day1Info.BCMSXMLData__c = updatedXML;

        if(confirmationValue == 'true') {
            day1Info.Status__c = CONFIRMED;
        } else {
            day1Info.Status__c = DECLINED;
        }
        update day1Info;
        outcomeOfWSCall = bcmsIntH.updateBcmsCaseHandler(day1Id);
        isCreateSuccess = bcmsIntH.isCreateSuccess;

        return null;
    }

    public void saveSicDescription() {

        day1Info.SIC_Description__c = sicDescription;   
        
        Map<String, String> mapToCompareSIC = BCMSIntegration_Helper.returnPicklistMap(BCMSIntegration_Helper.returnJSONString(STATIC_RESOURCE_NAME, SIC_FILE_NAME, FILE_EXTENSION, STATIC_RESOURCE_NAME));
        day1Info.SIC_Code__c = Integer.valueOf(mapToCompareSIC.get(sicDescription));

        update day1Info;
    }

    public void saveIscDescription() {

        Map<String, String> mapToGetISCCode = BCMSIntegration_Helper.returnPicklistMap(BCMSIntegration_Helper.returnJSONString(STATIC_RESOURCE_NAME, ISC_FILE_NAME, FILE_EXTENSION, STATIC_RESOURCE_NAME));
        day1Info.ISC_Code__c = Integer.valueOf(mapToGetISCCode.get(day1Info.ISC_Description__c));

        update day1Info;
    }

    public void saveLegalDescription() {
      
        Map<String, String> mapToGetLegalCode = BCMSIntegration_Helper.returnPicklistMap(BCMSIntegration_Helper.returnJSONString(STATIC_RESOURCE_NAME, LEGAL_FILE_NAME, FILE_EXTENSION, STATIC_RESOURCE_NAME));
        day1Info.Legal_Entity_Code__c = Integer.valueOf(mapToGetLegalCode.get(day1Info.Legal_Entity__c));

        update day1Info;
    }

    public void savePersonDesignation() {
      
        Map<String, String> mapToGetPersonDesignation = BCMSIntegration_Helper.returnPicklistMap(BCMSIntegration_Helper.returnJSONString(STATIC_RESOURCE_NAME, PERSON_DESIGNATION_FILE_NAME, FILE_EXTENSION, STATIC_RESOURCE_NAME));
        day1Info.Dosp_code__c = Integer.valueOf(mapToGetPersonDesignation.get(day1Info.Dosp__c));

        update day1Info;
    }

    public void saveMiFlag() {
      
        Map<String, String> mapToGetMiFlag = BCMSIntegration_Helper.returnPicklistMap(BCMSIntegration_Helper.returnJSONString(STATIC_RESOURCE_NAME, MI_FLAG_FILE_NAME, FILE_EXTENSION, STATIC_RESOURCE_NAME));
        day1Info.MI_Flag_Code__c = Integer.valueOf(mapToGetMiFlag.get(day1Info.MI_Flag__c.toUpperCase()));

        update day1Info;
    }

    public List<String> getSicPickListToShow() {
        Map<String, String> sicMap = BCMSIntegration_Helper.returnPicklistMap(BCMSIntegration_Helper.returnJSONString(STATIC_RESOURCE_NAME, SIC_FILE_NAME, FILE_EXTENSION, STATIC_RESOURCE_NAME));
        List<String> sicList = new List<String>();

        for (String sic : sicMap.keySet()) {
            sicList.add(sic);
        }
        return sicList;
    }

    /**
    * @description object to get parsed xml to page
    * @param no params
    * @return no return
    */
    public class ParsedXMLElement {
        public String nodName {get; set;}
        public String nodValue {get; set;}
    }

}