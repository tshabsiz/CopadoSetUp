/**
***** Lightning conversion ********
* @Date 2018-03-15
* @Author Cassius Malepe
* @Updates:
* 2018-04-11 - Rudolf Niehaus - CloudSmiths - Add feature that will convert the email case to a support case 
* 2018-04-12 - Rudolf Niehaus - CloudSmiths - Add logic to replace the pld ApexPage messages to lightning toast notifications
* 2018-04-12 - Rudolf Niehaus - CloudSmiths - Add logic to cater for complaints
* 2018-04-12 - Rudolf Niehaus - CloudSmiths - 
*******************************************

/**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-63 - View CIF Details in Salesforce. This class was built to retrieve the client
*                   details from the ADAPT360 service through REST call. All settings for the service are in 
*                   Custom Meta Data types. Helper methods have been created to set Authority Info for mandates
*                   (makes retrieving this data easier) as well as retrieving the Primary Client. JSON returned
*                   from the REST call is deserialized into the classes created.
*------------------------------------------------------------*/

public class lscNewCaseExt {
    
    private static String BASE_ENDPOINT = '';
    private static String OPERATION_GETALLVIEWS = '';
    private static String OPERATION_GETCLIENTS = '';
    private static Integer TIMEOUT = 0;
    private static String X_IBM_Client_Id = ''; 
    private static String X_IBM_Client_Secret = ''; 
    private static String REGID_FIELD = '';
    private static String QUERYTYPE_FIELD = '';
    private static String CIB_VIEW = '';
    public static List<ClientDetail> Client_Details = new List<ClientDetail>();
    //public static String errors = '';
    public static Case theCase{get;set;}
    public static list<String> queryTypeList = new list<String>();
    public static String qType{get;set;}
    public static String qValue{get;set;}
    public static String relCIF{get;set;}
    public static String cifName{get;set;}
    public static String relName{get;set;}
    public static String recordTypeDescription {get;set;}
    public static String relID{get;set;}
    public static list<Account> rel{get;set;} 
    public static boolean isCSCProfile{get;set;}
    public static boolean isNotCSCProfile{get;set;}
    public static string UDFServiceTypes{get;set;}    
    public static string ResponseMessage{get;set;}    
    public static string ChargesServiceTypes{get;set;}
    public static string vfUrl {get;set;}
    public static string caseOwnerName {get;set;}
    public static boolean isDOSProfile{get;set;}
    private static boolean noAccount = false;
    private static map<String,String> cifNameMap = new map<String,String>();
    private static boolean isComplaint = false;
    private static Response MyResponse = new Response();
    
    
    public class Response{
        public List<ClientDetail> Client_Details_r = new List<ClientDetail>();
        public String errors_r = '';
        public Case theCase_r {get;set;}
        public list<String> queryTypeList_r = new list<String>();
        public String qType_r{get;set;}
        public String qValue_r{get;set;}
        public String relCIF_r{get;set;}
        public String cifName_r{get;set;}
        public String recordTypeDescription_r{get;set;}
        public String relName_r{get;set;}
        public String relID_r{get;set;}
        public list<Account> rel_r{get;set;} 
        public boolean isCSCProfile_r{get;set;}
        public boolean isNotCSCProfile_r{get;set;}
        public string UDFServiceTypes_r{get;set;}
        public string ChargesServiceTypes_r{get;set;}
        public boolean isDOSProfile_r{get;set;}
        public boolean noAccount_r{get;set;}
        public map<String,String> cifNameMap_r = new map<String,String>();
        public boolean isComplaint_r {get;set;}
        public List<Dictionary> accountOptions_r = new List<Dictionary>();
        public List<Dictionary> cifdataOptions_r = new List<Dictionary>();
        public string ResponseMessage_r{get;set;}
        public List<ClientDetail> PrimaryClients_r {get;set;}
        public ClientDetail PrimaryClient_r {get;set;}
        public string vfUrl{get;set;}
        public string caseOwnerName_r{get;set;}
    }
    
    public static Response parse(String json) {
        return (Response) System.JSON.deserialize(json, Response.class);
    }
    
    public static ComplainCase parseCase(String json) {
        return (ComplainCase) System.JSON.deserialize(json, ComplainCase.class);
    }
    
    public static ManualCase parseManualCase(String json) {
        return (ManualCase) System.JSON.deserialize(json, ManualCase.class);
    }
    
    public static DigitalOpsCase parseDigitalOpsCase(String json) {
        return (DigitalOpsCase) System.JSON.deserialize(json, DigitalOpsCase.class);
    }
    
    public static Response MapResponse()
    {
        MyResponse.Client_Details_r = Client_Details;
        //MyResponse.errors_r = errors;
        MyResponse.vfUrl = URL.getSalesforceBaseUrl().getHost().replace('salesforce','visual.force').replace('.my', '');
        MyResponse.theCase_r = theCase;
        MyResponse.queryTypeList_r = queryTypeList;
        MyResponse.qType_r = qType;
        MyResponse.qValue_r = qValue;
        MyResponse.relCIF_r = relCIF;
        MyResponse.cifName_r = cifName;
        MyResponse.relName_r = relName;
        MyResponse.relID_r = relID;
        MyResponse.isCSCProfile_r = isCSCProfile;
        MyResponse.isNotCSCProfile_r = isNotCSCProfile;
        MyResponse.UDFServiceTypes_r = UDFServiceTypes;
        MyResponse.ChargesServiceTypes_r = ChargesServiceTypes;
        MyResponse.isDOSProfile_r = isDOSProfile;
        MyResponse.noAccount_r = noAccount;
        MyResponse.cifNameMap_r = cifNameMap;
        MyResponse.isComplaint_r = isComplaint;
        MyResponse.ResponseMessage_r = ResponseMessage;
        MyResponse.accountOptions_r = accountOptions_c;
        MyResponse.cifdataOptions_r = cifdataOptions_c;       
        MyResponse.PrimaryClients_r = PrimaryClients;
        MyResponse.PrimaryClient_r = PrimaryClient;
        MyResponse.recordTypeDescription_r = recordTypeDescription;
        MyResponse.caseOwnerName_r = caseOwnerName;
        if(MyResponse.accountOptions_r != null && MyResponse.accountOptions_r.size() == 0)
            MyResponse.accountOptions_r.add(new Dictionary('None' , 'None', 'None'));
        
        return MyResponse;
    }
    
    public static void MapToInstance(Response instance)
    {
        Client_Details = instance.Client_Details_r;
        //errors = instance.errors_r;
        //vfUrl = instance.vfUrl;
        theCase = instance.theCase_r;
        queryTypeList = instance.queryTypeList_r;
        qType = instance.qType_r;
        qValue = instance.qValue_r;
        relCIF = instance.relCIF_r;
        cifName = instance.cifName_r;
        relName = instance.relName_r;
        relID = instance.relID_r;
        isCSCProfile = instance.isCSCProfile_r;
        isNotCSCProfile = instance.isNotCSCProfile_r;
        UDFServiceTypes = instance.UDFServiceTypes_r;
        ChargesServiceTypes = instance.ChargesServiceTypes_r;
        isDOSProfile = instance.isDOSProfile_r;
        noAccount = instance.noAccount_r;
        cifNameMap = instance.cifNameMap_r;
        isComplaint = instance.isComplaint_r;
        ResponseMessage = instance.ResponseMessage_r;
        cifdataOptions_c = instance.cifdataOptions_r;
        accountOptions_c = instance.accountOptions_r;
        recordTypeDescription = instance.recordTypeDescription_r;
        caseOwnerName = instance.caseOwnerName_r;
        
        //PrimaryClients = instance.PrimaryClients_r;
        //PrimaryClient = instance.PrimaryClient_r;
    }
    
    
    @AuraEnabled        
    public static String GetRecordTypeIds(){
        List<Schema.RecordTypeInfo> recordtypes = Case.SObjectType.getDescribe().getRecordTypeInfos();    
        List<CaseRecordTypeInformation> caseRecordTypeInformation = new List<CaseRecordTypeInformation>();
        List<RecordType> rtr = [SELECT Id,Name, Description FROM RecordType WHERE SobjectType='Case' and Name  !=: 'Payments'];
        for(RecordType rt : rtr){
                CaseRecordTypeInformation itemdd = new CaseRecordTypeInformation();
                itemdd.recordId = rt.Id;//rt.getRecordTypeId();
                itemdd.label = rt.Name;//rt.getName();
                itemdd.value = rt.Description;//rt.recordtypeid;
                
                caseRecordTypeInformation.add(itemdd);
            }
        return JSON.serialize(caseRecordTypeInformation); 
    }
    
    public class PicklistEntryWrapper1{
        
        public PicklistEntryWrapper1(){            
        }
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
    }   
    
    @AuraEnabled
    public static string cifSelection(string model){
        Response instance = parse(model);
        setSessionVariables();
        getUDFServiceTypes();
        getChargesServiceTypes();
        
        cifSelection();
        MapToInstance(instance);
        return JSON.serialize(MapResponse()); 
    }
    
    @AuraEnabled
    public static string searchSalesforceAccounts(string model){
        system.debug('Neeed                   '+model);
        
        Response instance = parse(model);
        
        setSessionVariables();
        getUDFServiceTypes();
        getChargesServiceTypes();
        
        instance.ResponseMessage_r = '';
        MapToInstance(instance);
        
        searchSalesforceAccounts();
        return JSON.serialize(MapResponse()); 
    }
    
    @AuraEnabled
    public static string fetchAccount(String searchKeyWord) {
        String searchKey = searchKeyWord + '%';
        List < Account > returnList = new List < Account > ();
        List < Account > lstOfAccount = [select Name, CIF__c  from account where Name LIKE: searchKey limit 20];
        
        for (Account acc: lstOfAccount) {
            returnList.add(acc);
        }
        return JSON.serialize(returnList);
    }
    
    @AuraEnabled
    public static string searchUser(String searchKeyWord, Boolean isUserSearch) {
        String searchKey = '%'+searchKeyWord.trim() + '%';
        
        List < sobject > returnList = new List < sobject > ();
        if(isUserSearch){
            returnList = [select Id, Name  from user where Name LIKE: searchKey limit 8];
        }else{
            returnList = [select Id, Name  from group where type = 'queue' And Name LIKE: searchKey limit 8];
        }
        
        return JSON.serialize(returnList);
    }
    
    @AuraEnabled
    public static string accountSelection(string model){
        
        system.debug('model       '+model);
        Response instance = parse(model);
        
        setSessionVariables();
        getUDFServiceTypes();
        getChargesServiceTypes();
        
        instance.ResponseMessage_r = '';
        
        MapToInstance(instance);
        
        
        MapToInstance(instance);
        try{
            accountSelection();
        }catch(Exception  ex)
        {
            ResponseMessage= ex.getMessage();
            //return 'Error : '+ ex.getMessage();    
        }
        return JSON.serialize(MapResponse());        
    }
    
    @AuraEnabled
    public static string newComplainCase(string newComplainCaseModel){
        ComplainCase instance = parseCase(newComplainCaseModel);
        
        instance.ResponseMessage_r = '';
        
        setSessionVariables();
        getUDFServiceTypes();
        getChargesServiceTypes();
        
        Case complainCase = new Case();
        
        if(!string.isBlank(instance.ID)){
            complainCase.ID = instance.ID;
        }
        
        complainCase.AccountId = instance.accountId;
        complainCase.OwnerId = instance.ownerID;
        complainCase.Email_Sender_Name__c = instance.emailSenderName;
        complainCase.Email_From_Address__c = instance.emailFromAddress;
        complainCase.Suppress_Acknowledge_Alert__c = instance.suppressAcknowledgeAlert;
        complainCase.Priority = instance.priority;        
        complainCase.Status = instance.status;
        complainCase.Incident_Date__c = instance.incidentDate;
        complainCase.Origin__c = instance.origin;
        complainCase.Subject = instance.subject;
        complainCase.Description = instance.description;        
        complainCase.Complaint_Service_Category__c = instance.complaintServiceCategory;        
        complainCase.Resolving_Area__c = instance.resolvingArea;        
        complainCase.Complaint_Service_Type__c = instance.complaintServiceType;        
        complainCase.Resolving_Team__c = instance.resolvingTeam;        
        complainCase.Complaint_Service_Sub_Category__c = instance.complaintServiceSubCategory;        
        complainCase.Complaint_Channel__c = instance.complaintChannel;        
        complainCase.Staff_Error__c = instance.staffError;        
        complainCase.MNPI__c = instance.mnip;        
        complainCase.Staff_Error_Description__c = instance.staffErrorDescription;        
        complainCase.Opportunity_Name__c = instance.opportunityName;        
        complainCase.Staff_Member_Name__c = instance.staffMemberName;
        complainCase.Action_Taken__c = instance.actionTaken;
        complainCase.Desired_Action__c = instance.desiredAction;
        complainCase.Root_Cause_Category__c = instance.rootCauseCategory;
        complainCase.Root_Cause__c = instance.rootCause;
        complainCase.Business_Owner_Action__c = instance.businessOwnerAction;        
        complainCase.Resolution_Detail__c = instance.resolutionDetail;
        complainCase.Resolved_In_Favour_Of__c = instance.resolvedInFavourOf;
        complainCase.RecordTypeId = instance.RecordTypeId;
        if(instance.callReportId != null && instance.callReportId != '')
            complainCase.call_Report__c = instance.callReportId;
        
        //complainCase.Queue__c = '-None-';
        
        instance.ResponseMessage_r = '';
        
        try{
            upsert complainCase;
        }catch(Exception  ex)
        {
            ResponseMessage = ex.getMessage();
            //return 'Error : '+ ex.getMessage();    
        }
        //complainCase.emailSenderName;
        
        //
        //MapToInstance(instance);
        
        //to do here
        
          theCase = complainCase;
        //return JSON.serialize(instance);    
        return JSON.serialize(MapResponse()); 
    }
    
    
    @AuraEnabled
    public static string newManualCase(string newManualCaseModel){
       system.debug('newManualCaseModel       '+newManualCaseModel);
        ManualCase instance = parseManualCase(newManualCaseModel);
        
        instance.ResponseMessage_r = '';
        
        setSessionVariables();
        getUDFServiceTypes();
        getChargesServiceTypes();
        
        Case manualCase = new Case();
        
        manualCase.Email_Sender_Name__c = instance.emailSenderName;
        manualCase.Email_From_Address__c = instance.emailFromAddress;
        manualCase.Queue__c = instance.queue;
        manualCase.Subject = instance.subject;
        manualCase.Description = instance.description;
        manualCase.Priority = instance.priority;
        manualCase.Urgent__c = instance.urgent;
        manualCase.AccountId = instance.accountId;
        manualCase.Department__c = instance.department;
        manualCase.Full_Department__c = instance.fullDepartment;
        manualCase.Team_Manager__c = instance.teamManager;
        manualCase.Business_Hours__c = instance.businessHours;
        manualCase.Team__c = instance.team;
        manualCase.Origin = instance.origin;
        manualCase.Service_Category__c = instance.serviceCategory;
        manualCase.Service_Sub_Category__c = instance.serviceSubCategory;
        manualCase.Service_Type__c = instance.serviceType;
        manualCase.Number_of_Requests__c = instance.requests;        
        manualCase.Channel__c = instance.channel;
        manualCase.hWasEmailToCaseAction__c = instance.hWasEmailToCaseAction;
        manualCase.Reason_for_Cancellation__c = instance.reasonforCancellation;
        manualCase.RecordTypeId = instance.recordTypeId;
        manualCase.OwnerId = instance.OwnerId;
        manualCase.Account_Number__c = instance.accountNumber;
        
        if(instance.serviceType != null && instance.serviceType != '' && instance.serviceType != '--None--'&& (UDFServiceTypes.indexOf(instance.serviceType) > -1)){
            
            manualCase.ContactConfirmedWith__c = instance.contactConfirmedWith;
            manualCase.ClientContactTelNo__c = instance.clientContactTelNo;
            manualCase.DateConfirmed__c = instance.dateConfirmed;
            manualCase.ClientAbsaAccountNumber__c = instance.clientAbsaAccountNumber;
            manualCase.ClientIDNumberMandateAUTH__c = instance.clientIDNumberMandateAUTH;
            manualCase.ClientSignatureMandateSIGV__c = instance.clientSignatureMandateSIGV;
            manualCase.BeneficiaryName__c = instance.beneficiaryName;
            manualCase.AmountVerifiedandApproved__c = instance.amountVerifiedandApproved;
            manualCase.BeneficiaryAccNoandBank__c = instance.beneficiaryAccNoandBank;
            manualCase.BeneficiaryACBorBranchCode__c = instance.beneficiaryACBorBranchCode;
            manualCase.IndemnityVerified__c = instance.indemnityVerified;
            manualCase.DisclaimerReadtoClient__c = instance.disclaimerReadtoClient;
            
            manualCase.RSCConfirmsFunds__c = instance.rSCConfirmsFunds;
            manualCase.DuplicationsChecked__c = instance.duplicationsChecked;
            manualCase.TypeofTransferAuthorised__c = instance.typeofTransferAuthorised;
            manualCase.VerifyClientAccountNumberDebit__c = instance.verifyClientAccountNumberDebit;
            manualCase.PaymentAuthPaperMandate__c = instance.paymentAuthPaperMandate;
            manualCase.ThirdPartyPaymentProcessed__c = instance.thirdPartyPaymentProcessed;
            manualCase.WIP__c = instance.wip;
            manualCase.POP__c = instance.pop;
        }
        
        if(instance.serviceType != null && instance.serviceType != '' && instance.serviceType != '--None--'&& (ChargesServiceTypes.indexOf(instance.serviceType) > -1)){
            manualCase.ChargeAccountNo__c = instance.chargeAccountNo;
            manualCase.TransactionCode__c = instance.transactionCode;
            manualCase.Cost_Centre__c = instance.costCentre;
            manualCase.CorpCode__c = instance.corpCode;
            manualCase.DRRef__c = instance.dRRef;
            manualCase.CRRef__c = instance.cRRef;
            manualCase.EffectiveDate__c = instance.effectiveDate;
            manualCase.CRAccountNo__c = instance.cRAccountNo;
        }
        
        
        
        try{
            insert manualCase;
        }catch(Exception  ex)
        {
            ResponseMessage = ex.getMessage();
            
        }
        
        theCase = manualCase;
        return JSON.serialize(MapResponse());
    }
    
    @AuraEnabled
    public static string newDigitalOpsCase(string newDigitalOpsCaseModel){
        DigitalOpsCase instance = parseDigitalOpsCase(newDigitalOpsCaseModel);
        instance.ResponseMessage_r = '';
        
        setSessionVariables();
        getUDFServiceTypes();
        getChargesServiceTypes();
        
        Case digitalOpsCase = new Case();
        
        digitalOpsCase.Email_Sender_Name__c = instance.emailSenderName;
        digitalOpsCase.Email_From_Address__c = instance.emailFromAddress;
        digitalOpsCase.Colleague__c = instance.colleague;
        digitalOpsCase.Status = instance.status;
        digitalOpsCase.User_Type__c = instance.userType;
        digitalOpsCase.ID_V_Complete__c = instance.iDVComplete;
        digitalOpsCase.ID_V__c = instance.iDV;
        digitalOpsCase.NovoFX_Reference__c = instance.novoFXReference;
        digitalOpsCase.BAPS_Reference__c = instance.bAPSReference;
        digitalOpsCase.Queue__c = instance.queue;
        digitalOpsCase.Subject = instance.subject;
        digitalOpsCase.Description = instance.description;
        digitalOpsCase.Priority = instance.priority;
        digitalOpsCase.Department__c = instance.department;
        digitalOpsCase.Full_Department__c = instance.fullDepartment;
        digitalOpsCase.Team_Manager__c = instance.teamManager;
        digitalOpsCase.Business_Hours__c = instance.businessHours;
        digitalOpsCase.Team__c = instance.team;
        digitalOpsCase.Origin = instance.origin;
        digitalOpsCase.Service_Category__c = instance.serviceCategory;
        digitalOpsCase.Service_Sub_Category__c = instance.serviceSubCategory;
        digitalOpsCase.Service_Type__c = instance.serviceType;
        digitalOpsCase.Channel__c = instance.channel;
        digitalOpsCase.RecordTypeId = instance.recordTypeId;
        digitalOpsCase.AccountId = instance.relationshipID;
        digitalOpsCase.OwnerId = instance.OwnerId;
        
        
        
        try{
            insert digitalOpsCase;
        }catch(Exception  ex)
        {
            ResponseMessage = ex.getMessage();
            
        }
        
        theCase = digitalOpsCase;
        return JSON.serialize(MapResponse()); 
        
        
    }
    @AuraEnabled
    public static string NewCase(string model, string serviceType, string channel, string requests,string serviceSubCategory, string fullTeam, string serviceCategory, string department){//, string fulldepartment){
                         system.debug('newCase'+model);
        Response instance = parse(model);
        
        setSessionVariables();
        getUDFServiceTypes();
        getChargesServiceTypes();
        
        instance.ResponseMessage_r = '';
        MapToInstance(instance);
        
        theCase.Service_Type__c = serviceType;//
        theCase.Channel__c = channel;//
        theCase.Number_of_Requests__c = decimal.valueOf(requests);//
        theCase.AccountId = relID;//
        theCase.Service_Sub_Category__c = serviceSubCategory;//
        theCase.Queue__c = fullTeam;
        theCase.Service_Category__c = serviceCategory;//
        theCase.Department__c = department;
        //theCase.Full_Department__c = fulldepartment;
        theCase.RunUDFValidation__c = false;//
        theCase.hWasEmailToCaseAction__c = true;//
        
        if(qtype == 'accountNumber'){
            theCase.Account_Number__c = relName;//
        }
        
        update theCase;
        String strResponse = '';
        
        if(theCase.Service_Type__c != 'Log Complaint'){
            ResponseMessage = lscSupportCaseMainCont.returnSupportCase(theCase.Id, 'true');  
            if(!ResponseMessage.startsWith('ERROR'))
                ResponseMessage = '';
        }else{
            ResponseMessage = lscSupportCaseMainCont.returnSupportCase(theCase.Id, 'true'); 
            if(!ResponseMessage.startsWith('ERROR'))
                ResponseMessage = '';
        }                  
        return JSON.serialize(MapResponse());        
    }
    
    @AuraEnabled
    public static string GetAccount(string model, string recordId, string recordType){
     
        if(!String.isBlank(model))
            Response instance = parse(model);
        
        lscNewCaseExt1( recordId, recordType);
        return JSON.serialize(MapResponse());
    }
    public static Map<String, List<String>> getDependentOptionsImpl(Schema.SObjectField theField, Schema.SObjectField ctrlField) {
		// validFor property cannot be accessed via a method or a property,
		// so we need to serialize the PicklistEntry object and then deserialize into a wrapper.
		List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
		List<PicklistEntryWrapper> depEntries =	wrapPicklistEntries(theField.getDescribe().getPicklistValues());

		// Set up the return container - Map<ControllingValue, List<DependentValues>>
		Map<String, List<String>> objResults = new Map<String, List<String>>();
		List<String> controllingValues = new List<String>();

		for (Schema.PicklistEntry ple : contrEntries) {
			String label = ple.getLabel();
			objResults.put(label, new List<String>());
			controllingValues.add(label);
		}

		for (PicklistEntryWrapper plew : depEntries) {
			String label = plew.label;
			String validForBits = base64ToBits(plew.validFor);
			for (Integer i = 0; i < validForBits.length(); i++) {
				// For each bit, in order: if it's a 1, add this label to the dependent list for the corresponding controlling value
				String bit = validForBits.mid(i, 1);
				if (bit == '1') {
					objResults.get(controllingValues.get(i)).add(label);
				}
			}
		}

		return objResults;
	}

	// Convert decimal to binary representation (alas, Apex has no native method :-(
	//    eg. 4 => '100', 19 => '10011', etc.
	// Method: Divide by 2 repeatedly until 0. At each step note the remainder (0 or 1).
	// These, in reverse order, are the binary.
	public static String decimalToBinary(Integer val) {
		String bits = '';
		while (val > 0) {
			Integer remainder = Math.mod(val, 2);
			val = Integer.valueOf(Math.floor(val / 2));
			bits = String.valueOf(remainder) + bits;
		}
		return bits;
	}

	// Convert a base64 token into a binary/bits representation
	// e.g. 'gAAA' => '100000000000000000000'
	public static String base64ToBits(String validFor) {
		if (String.isEmpty(validFor)) return '';

		String validForBits = '';

		for (Integer i = 0; i < validFor.length(); i++) {
			String thisChar = validFor.mid(i, 1);
			Integer val = base64Chars.indexOf(thisChar);
			String bits = decimalToBinary(val).leftPad(6, '0');
			validForBits += bits;
		}

		return validForBits;
	}


	private static final String base64Chars = '' +
			'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
			'abcdefghijklmnopqrstuvwxyz' +
			'0123456789+/';


	private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
		return (List<PicklistEntryWrapper>)
			JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
	}

	public class PicklistEntryWrapper {
		public String active {get; set;}
		public String defaultValue {get; set;}
		public String label {get; set;}
		public String value {get; set;}
		public String validFor {get; set;}
	}


    
    /*
@AuraEnabled
public static List < String >  getselectOptions(sObject objObject, string fld) {
system.debug('objObject --->' + objObject);
system.debug('fld --->' + fld);
List < String > allOpts = new list < String > ();
// Get the object type of the SObject.
Schema.sObjectType objType = objObject.getSObjectType();

// Describe the SObject using its object type.
Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

system.debug('objDescribe --->' + objDescribe);

// Get a map of fields for the SObject
map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();

// Get the list of picklist values for this field.
list < Schema.PicklistEntry > values =
fieldMap.get(fld).getDescribe().getPickListValues();

// Add these values to the selectoption list.
for (Schema.PicklistEntry a: values) {
allOpts.add(a.getValue());
}
system.debug('allOpts ---->' + allOpts);
allOpts.sort();
return allOpts;
//return JSON.serialize(allOpts);
}
*/
    //RN : CloudSmiths - add standard controller constructor
    public static void lscNewCaseExt1(string recordId, string recordType){
        
        rel = new list<Account>();
        
        
        if(!String.isBlank(recordId) && recordId.startsWith('500')){
            theCase = [Select Id, AccountId, OwnerId, Owner.Name, Owner.Type, Account.Name, Email_Sender_Name__c, Email_From_Address__c,
                       RecordTypeId, Status, Priority, Incident_Date__c, Origin__c, MNPI__c, Opportunity_Name__c,
                       Subject, Description, Queue__c, Type_Of_Complaint__c, Service_Type__c, Severity__c, Service_Sub_Category__c,
                       Service_Category__c, Channel__c, Staff_Error__c, Staff_Error_Description__c, Staff_Member_Name__c,
                       Business_Area__c, Nature_Of_Complaint__c, Impact__c, Root_Cause_Category__c, Root_Cause__c,Resolved_In_Favour_Of__c,
                       Business_Owner_Action__c,Action_Taken__c,Desired_Action__c,Account.CIF__c,
                       Operational_Risk_Event_Reference__c, Suppress_Acknowledge_Alert__c, Department__c, RecordType.Name
                       From Case Where Id = :recordId];
            system.debug('theCase   '+theCase);
            
            caseOwnerName = UserInfo.getFirstName() +' '+ UserInfo.getLastName() ;
            
            if(!String.isBlank(theCase.RecordTypeId)){
                recordTypeDescription = theCase.RecordType.name;
            }
            //complaint via the CSC quick action 
            if(recordType == 'Complaint'){
                RecordType compRecId = [Select Id, Name From RecordType Where DeveloperName = 'Complaint'];
                theCase.RecordTypeId = compRecId.Id;
                isComplaint = true;
                recordTypeDescription = compRecId.name;
                
                if(!String.isBlank(theCase.AccountId)){
                    
                    rel = [Select Id, Name, CIF__c From Account Where ID =: theCase.AccountId];
                    accountOptions_c = new List<Dictionary>{};
                        accountOptions_c.add(new Dictionary(rel[0].Name , rel[0].CIF__c , rel[0].Id));
                }
                
                
            }
        }else{
            
            theCase = new Case();
            
            //Check if a recordType was selected
            
            if(recordType == 'digitalOps'){
                
                theCase.Queue__c = 'DOS - General';
                RecordType compRecId = [Select Id, Name From RecordType Where Developername = 'Digital_Ops_Cases'];
                theCase.RecordTypeId =compRecId.Id;
                recordTypeDescription = compRecId.name;
                
            }
            else if(recordType == 'cscManual')
            {
                RecordType compRecId = [Select Id, Name From RecordType Where Developername = 'CSC_Manual_Cases'];
                theCase.RecordTypeId =compRecId.Id;
                recordTypeDescription = compRecId.name;
            } 
            else if(recordType == 'Complaint')
            {
                theCase.Queue__c = 'Complaints Team';
                RecordType compRecId = [Select Id, Name From RecordType Where Developername = 'Complaint'];
                theCase.RecordTypeId =compRecId.Id;
                recordTypeDescription = compRecId.name;
                
                if(!String.isBlank(recordId) && recordId.startsWith('a0D')){
                    
                    ID RelationshipId = [SELECT Relationship__c FROM Call_Report__c where Id =: recordId   limit 1].Relationship__c;
                    if(!String.isBlank(RelationshipId )){
                        rel = [Select Id, Name, CIF__c From Account Where ID =: RelationshipId];
                        accountOptions_c = new List<Dictionary>{};
                            accountOptions_c.add(new Dictionary(rel[0].Name , rel[0].CIF__c , rel[0].Id));
                    }
                }
            }
            else
            {
                //default to this
                RecordType compRecId = [Select Id, Name From RecordType Where Developername = 'CSC_Manual_Cases'];
                theCase.RecordTypeId =compRecId.Id;
                recordTypeDescription = compRecId.name;
            }
            /*
if(theCase.RecordType != null){

String recId = RecordType;
String AccountID = cas4_lkid;

String recDevName = [Select DeveloperName From RecordType Where Id = :recId limit 1].DeveloperName;

if(recDevName == 'Complaint'){
theCase.Queue__c = 'Complaints Team';
}else if(recDevName == 'Digital_Ops_Cases'){
theCase.Queue__c = 'DOS - General';
}

theCase.RecordTypeId = recId;
theCase.OwnerId = UserInfo.getUserId();
if(!String.isBlank(AccountID))
{
theCase.AccountId = AccountID;    
}


}else{
//default to this
RecordType compRecId = [Select Id, Name From RecordType Where Developername = 'CSC_Manual_Cases'];
theCase.RecordTypeId =compRecId.Id;
recordTypeDescription = compRecId.name;
}
*/
            theCase.OwnerId = UserInfo.getUserId();
            caseOwnerName = UserInfo.getFirstName() +' '+ UserInfo.getLastName() ;
            
        }
        
        //initial value
        if(accountOptions_c == null || accountOptions_c.isEmpty()){
            accountOptions_c = new List<Dictionary>{};
                accountOptions_c.add(new Dictionary('None' , 'None', 'None'));
        }
        cifdataOptions_c = new List<Dictionary>{};
            
            //Determine profile of running user
            Id profileId = userinfo.getProfileId();
        
        String profileName = [Select Id,Name from Profile where Id = :profileId].Name;
        
        if(profileName.contains('CSC')){
            isCSCProfile = true;
            isNotCSCProfile = false;
        }else if(profileName.contains('Digital Ops')){
            isCSCProfile = false;
            isNotCSCProfile = false;
            isDOSProfile = true;
        }else{
            isCSCProfile = false;
            isNotCSCProfile = true;
        }
        
        if(isComplaint){
            isCSCProfile = false;
            isNotCSCProfile = true;
        }
        
        setSessionVariables();
        getUDFServiceTypes();
        getChargesServiceTypes();
    }
    
    //Mabee - Barclays
    public static void addAsTeamMember()
    {
        try
        {
            if(Apexpages.Currentpage().getParameters().get('comptaint') != null)
            {
                List<Case> caseList = new List<Case>();
                caseList.add(theCase);
                CSC_Case_Trigger_Functions.addCreatorAsTeamMember(caseList);
            }
        }
        catch(Exception exc)
        {
            
        }
        
    }
    
    public String isClosed{get;set;}
    public boolean isClosedStatus{get;set;}
    public void CslosedStatus()
    {
        System.debug('CslosedStatus ');
        isClosedStatus =false;
        if(theCase.status.Contains('Closed'))
        {
            isClosedStatus=true;
        }
        System.debug('CslosedStatus '+isClosedStatus);
    }
    
    public PageReference autoPopulateFields(){
        
        CSC_Case_Functions caseFunc = new CSC_Case_Functions(theCase);
        theCase.Department__c = caseFunc.getDepartment();
        theCase.Team_Manager__c = caseFunc.getTeamManager();
        theCase.Team__c = caseFunc.getTeam();
        theCase.Business_Hours__c = caseFunc.getBusinessHours();
        theCase.Full_Department__c = caseFunc.getFullDepartment();
        return null;
    }
    public static SelectOption[] accountOptions {
        public get;
        public set;
    }
    
    public static List<Dictionary> accountOptions_c {
        public get;
        public set;
    }
    
    public class Dictionary {
        public string Id {get;private set;}
        public string name {get;private set;}
        public string cif {get;private set;}
        public Dictionary(string name, string cif, string Id){
            
            
            
            if(cif == null || cif == ''){
                this.cif = 'No CIF';
            }else
                this.cif = cif;
            
            if(name == 'None')
                this.name = '----- No Relationship Linked------';
            else
                this.name = name+' : '+ this.cif;
            
            this.Id = Id;
        }
    }
    
    public static SelectOption[] cifdataOptions {
        public get;
        public set;
    }
    
    public static List<Dictionary> cifdataOptions_c {
        public get;
        public set;
    }
    
    //RN - CloudSmiths
    public static void searchSalesforceAccounts(){
        
        list<String> cifNumbers = new list<String>();
        accountOptions_c = new List<Dictionary>();
        cifdataOptions_c = new List<Dictionary>();
        //accountOptions_c.clear();
        //cifdataOptions_c.clear();
        if(cifNameMap != null)
            cifNameMap.clear();
        
        if(qType.equals('cif') || qType.equals('ucode')){
            //Get CIF for the SF account record
            System.debug('RN : Search SF on =' + qValue);
            
            if(qType.equals('cif')){
                rel = [Select Id, Name, CIF__c From Account Where Name like :qValue+'%' AND RecordType.Name != 'Relationship Group' Order by Name ASC limit 15];
            }
            else{
                String usercodes = '%' + qValue + '%';
                rel = [Select Id, Name, CIF__c From Account Where User_Code__c like :usercodes AND RecordType.Name != 'Relationship Group' Order by Name ASC limit 15];
            }
            
            if(rel.size() >= 1){
                relID = rel[0].Id;
                relName = rel[0].Name;
                system.debug('22222222222222222222222222222222222222222222s'+relName);
                //get the first relationship until a user change the selection option, there could be multaple CIF numbers
                if(String.isNotBlank(rel[0].CIF__c)){
                    cifNumbers.addAll(rel[0].CIF__c.split(','));
                }
                
                if(!cifNumbers.isEmpty()){
                    
                    qValue = cifNumbers[0];
                    
                    System.debug('RN : Search CIF on =' + qValue);
                    //get CIF data - will only get one record if weusethe CIF number - registrtaion number and ID could return more than one
                    ClientDetails = RetrieveClientDetails('cif', qValue, CIB_VIEW,true);
                    SetAuthorityInfo();
                    SetAdditionalAccounts();
                    
                    for(Account a :rel){
                        accountOptions_c.add(new Dictionary(a.Name , a.CIF__c , a.Id));
                    }
                    
                    System.debug('RN : CIF Array value' + cifNumbers[0]);
                    relCIF = cifNumbers[0];
                    System.debug('RN : CIF Field Value' + relCIF);
                    
                    //First relationship found has a CIF Number, we've searched on that CIF number
                    UpdateAccountInfo(relID, relCIF);
                    
                    if(PrimaryClient == null ){
                        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There is no CIF data for this CIF number : ' + cifNumbers[0] ));
                        ResponseMessage = 'There is no CIF data for this CIF number : ' + cifNumbers[0];
                    }else{
                        //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Found CIF Data For : ' + relName ));
                        //ResponseMessage = 'Found CIF Data For : ' + relName;
                    }
                }else{
                    //add the rest of the accounts to a dropdown list
                    for(Account a :rel){
                        accountOptions_c.add(new Dictionary(a.Name , a.CIF__c, a.Id));
                    }
                    //ResponseMessage ='Could not find a CIF Number in Salesforce for this Relationship'; //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a CIF Number in Salesforce for this Relationship'));
                }
                
            }else if(rel.size() == 0){
                ResponseMessage ='Could not find a Relationship in Salesforce with this Name : ' + qvalue;//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a Relationship in Salesforce with this Name : ' + qvalue));
            }
        }else
        {
            
            String cifsearch = '';
            if(qType.equals('cif2cif')){
                cifsearch=qType;
                qType='cif';
            }
            
            System.debug('RN123 : Search CIF on qType =' + qType + ' AND Value = ' + qValue);
            
            ClientDetails = RetrieveClientDetails(qType, qValue, CIB_VIEW,true);
            
            SetAuthorityInfo();
            SetAdditionalAccounts();
            qType = 'cif';
            
            //more than one CIF record
            if(PrimaryClients.size() >= 1){
                
                for(ClientDetail p :PrimaryClients){
                    
                    String cname = '';
                    String ccif = '';
                    
                    if(p.individual != null){
                        if(p.individual.surname != null){
                            if(String.isNotBlank(p.individual.surname.value)){
                                if(p.identifications != null){
                                    for (IdentificationsInfo ii : p.identifications) {
                                        System.debug(ii.type.code);
                                        if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                                            cifNumbers.add(ii.numbers);
                                            ccif = ii.numbers;
                                        }  
                                    } 
                                }
                                
                                if(String.isNotBlank(p.individual.nameInitials.value)){
                                    cifdataOptions_c.add(new Dictionary(p.individual.nameInitials.value + ' ' + p.individual.surname.value + ' : ' + ccif , p.individual.nameInitials.value + ' ' + p.individual.surname.value + ' : ' + ccif, p.id));
                                    cname = p.individual.nameInitials.value + ' ' + p.individual.surname.value + ' : ' + ccif;
                                }else{
                                    cifdataOptions_c.add(new Dictionary(p.individual.surname.value + ' : ' + ccif , p.individual.surname.value + ' : ' + ccif, p.id));
                                    cname = p.individual.surname.value + ' : ' + ccif;
                                }
                                
                                System.debug('PUT MAP->' + cname + '-' + ccif);
                                cifNameMap.put(cname,ccif);
                            }
                        }
                    }
                }//end loop
                
                String q='';
                if(cifNumbers.size() > 0){
                    q = '%' + cifNumbers[0] + '%';
                }else{
                    cifNumbers.add(qValue);
                    q = '%' + cifNumbers[0] + '%';
                }
                
                rel = [Select Id, Name, CIF__c From Account Where CIF__c like :q limit 1];
                
                if(rel.size() == 1){
                    
                    if(cifNumbers.size() > 0){
                        qValue = cifNumbers[0];
                    }else{
                        cifNumbers.add(qValue);
                    }
                    
                    if(!cifNumbers.isEmpty()){
                        
                        //add the rest of the accounts to a dropdown list
                        for(Account a :rel){
                            accountOptions_c.add(new Dictionary(a.Name , a.CIF__c, a.Id));
                        }
                        
                        relCIF = cifNumbers[0];
                        relID = rel[0].Id;
                        relName = rel[0].Name;
                        
                        //Have searched and found a number of clients from CIF and need to update the first one
                        UpdateAccountInfo(relID, relCIF);
                    }else{
                       // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a CIF Number in Salesforce for this Relationship'));
                        //ResponseMessage = 'Could not find a CIF Number in Salesforce for this Relationship';
                    }
                }else if(rel.size() == 0){
                    
                    String rectypeid = [Select Id From RecordType Where Name = 'Prospect'].id;
                    
                    Account newAcc = new Account();
                    newAcc.CIF__c = cifNumbers[0];
                    newAcc.RecordTypeId = rectypeid;
                    newAcc.OwnerId = UserInfo.getUserId();
                    
                    if(PrimaryClient != null){
                        if(PrimaryClient.individual != null){
                            if(PrimaryClient.individual.surname != null){
                                if(String.isNotBlank(PrimaryClient.individual.surname.value)){
                                    if(String.isNotBlank(PrimaryClient.individual.nameInitials.value)){
                                        newAcc.Name = PrimaryClient.individual.nameInitials.value + ' ' + PrimaryClient.individual.surname.value;
                                    }else{
                                        newAcc.Name = PrimaryClient.individual.surname.value;
                                    }
                                }else{
                                    newAcc.Name = 'Missing Name - See CIF Number';
                                }
                                
                                if(PrimaryClient.customerDetails != NULL && PrimaryClient.customerDetails.groupScheme != NULL && PrimaryClient.customerDetails.groupScheme.description != NULL) {
                                    newAcc.groupScheme__c = PrimaryClient.customerDetails.groupScheme.description.value;
                                }
                                
                                try{
                                    //RN - Relationship Duplication rule bypass
                                    Database.DMLOptions dml = new Database.DMLOptions();
                                    
                                    dml.DuplicateRuleHeader.AllowSave = true;
                                    
                                    Database.SaveResult sr = Database.insert(newAcc, dml);
                                    
                                    if (sr.isSuccess()) {
                                        
                                        relName = newAcc.Name;
                                        relCIF = newAcc.CIF__c;
                                        relID = newAcc.Id;
                                        
                                    }else{               
                                        for(Database.Error err : sr.getErrors()) {
                                            ResponseMessage = 'The following error has occurred. \n';
                                            ResponseMessage += err.getStatusCode() + ': ' + err.getMessage() + '\n';
                                            ResponseMessage +='Relationship fields that affected this error: ' + err.getFields() + '\n';
                                            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The following error has occurred.'));
                                            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,err.getStatusCode() + ': ' + err.getMessage()));
                                            //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Relationship fields that affected this error: ' + err.getFields()));
                                        }
                                        
                                    }
                                }catch(DMLException ex){
                                    System.debug(ex.getMessage());
                                    ResponseMessage = 'Error: ';
                                    ResponseMessage = ex.getMessage();
                                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                                }catch(Exception ex){
                                    System.debug(ex.getMessage());
                                     ResponseMessage = 'Error: ';
                                    ResponseMessage = ex.getMessage();
                                    //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                                }                           
                            }
                        }
                    }
                }
                
                
            }
        }
    }
    
    public static void cifSelection(){
        
        list<String> cifNumbers = new list<String>();
        
        qValue = cifNameMap.get(cifName);
        qType = 'cif';
        
        ClientDetails = RetrieveClientDetails(qType, qValue , CIB_VIEW,true);
        SetAuthorityInfo();
        SetAdditionalAccounts();
        
        String q = '%' + qValue + '%';
        rel = [Select Id, Name, CIF__c From Account Where CIF__c like :q limit 1];
        
        if(rel.size() == 1){
            
            
            if(String.isNotBlank(qValue)){
                
                //add the rest of the accounts to a dropdown list
                for(Account a :rel){
                    accountOptions_c.add(new Dictionary(a.Name , a.CIF__c, a.Id));
                }
                
                relCIF = qValue;
                relID = rel[0].Id;
                relName = rel[0].Name;
                
                // We've selected another CIF and found an account with that CIF, update that account
                UpdateAccountInfo(relID, relCIF);
            }else{
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a CIF Number for this Relationship'));
                ResponseMessage = 'Could not find a CIF Number for this Relationship';
            }
            
        }else if(rel.size() == 0){
            
            String rectypeid = [Select Id From RecordType Where Name = 'Prospect'].id;
            
            Account newAcc = new Account();
            newAcc.CIF__c = qValue;
            newAcc.RecordTypeId = rectypeid;
            newAcc.OwnerId = UserInfo.getUserId();
            
            String[] theName = cifName.split(':');
            newAcc.Name = theName[0].trim();
            
            ClientDetail cd = ClientDetailFromCIF(newAcc.CIF__c);
            if(cd != NULL && cd.customerDetails != NULL && cd.customerDetails.groupScheme != NULL && cd.customerDetails.groupScheme.description != NULL) 
                newAcc.groupScheme__c = cd.customerDetails.groupScheme.description.value;
            
            try{
                insert newAcc;
                relName = newAcc.Name;
                relCIF = newAcc.CIF__c;
                relID = newAcc.Id;
            }catch(DMLException ex){
                System.debug(ex.getMessage());
                //ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                ResponseMessage = ex.getMessage();
            }
        }
    }
    
    public static void accountSelection(){
        
        list<String> cifNumbers = new list<String>();
        
        rel = [Select Id, Name, CIF__c From Account Where Id = :relID limit 1];
        relID = rel[0].Id;
        relName = rel[0].Name;
        
        //get the first relationship until a user change the selection option, there could be multaple CIF numbers
        if(String.isNotBlank(rel[0].CIF__c)){
            cifNumbers.addAll(rel[0].CIF__c.split(','));
        }
        
        if(cifNumbers.size() >0){
            qValue = cifNumbers[0];
            relCIF = cifNumbers[0];
        }else{
            qValue=null; 
        }
        if(!cifNumbers.isEmpty()){
            
            //get CIF data - will only get one record if weusethe CIF number - registrtaion number and ID could return more than one
            ClientDetails = RetrieveClientDetails('cif', qValue, CIB_VIEW,true);
            SetAuthorityInfo();
            SetAdditionalAccounts();
            
            // We've selected another CIF and found an account with that CIF, update that account
            UpdateAccountInfo(relID, relCIF);
            /*
if(PrimaryClient==null || PrimaryClient.individual==null){
ResponseMessage = 'There is no CIF data for this CIF number : ' + relCIF;//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There is no CIF data for this CIF number : ' + relCIF ));
}else if(PrimaryClient != null || PrimaryClient.individual != null){
ResponseMessage ='Found CIF Data For : ' + relName ;// ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Found CIF Data For : ' + relName ));
}*/
        }else{
            //ResponseMessage = 'Could not find a CIF Number in Salesforce for this Relationship';//ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a CIF Number in Salesforce for this Relationship'));
        }
        
    }
    
    
    // Constructor gets all settings, query strings, runs REST call and sets data
    public static void lscNewCaseExt() {
        setSessionVariables(); 
    }
    
    public void runQueryFromURL(){
        
        if (ApexPages.currentPage().getParameters().get(REGID_FIELD)!=null && ApexPages.currentPage().getParameters().get(REGID_FIELD)!=''
            && ApexPages.currentPage().getParameters().get(QUERYTYPE_FIELD)!=null && ApexPages.currentPage().getParameters().get(QUERYTYPE_FIELD)!='') {
                
                ClientDetails = RetrieveClientDetails(ApexPages.currentPage().getParameters().get(QUERYTYPE_FIELD), 
                                                      ApexPages.currentPage().getParameters().get(REGID_FIELD), 
                                                      CIB_VIEW, 
                                                      true);
                
                SetAuthorityInfo(); //sets the authority info for the non primary clients (ie. account authentication details)
                SetAdditionalAccounts(); //adds additional accounts to primary client 
            }
    }
    
    public static void setSessionVariables(){
        for(ADAPT360_Integration_Setting__mdt settings : [SELECT DeveloperName, Setting__c FROM ADAPT360_Integration_Setting__mdt WHERE DeveloperName IN('BASE_ENDPOINT','OPERATION_GETALLVIEWS','OPERATION_GETCLIENTS','TIMEOUT','X_IBM_Client_Id','X_IBM_Client_Secret','QUERYTYPE_FIELD','QUERYTYPES','REGID_FIELD','CIB_VIEW')]){
            if (settings.DeveloperName == 'BASE_ENDPOINT') BASE_ENDPOINT = settings.Setting__c;
            if (settings.DeveloperName == 'OPERATION_GETALLVIEWS') OPERATION_GETALLVIEWS = settings.Setting__c;
            if (settings.DeveloperName == 'OPERATION_GETCLIENTS') OPERATION_GETCLIENTS = settings.Setting__c;
            if (settings.DeveloperName == 'TIMEOUT') TIMEOUT = integer.valueof(settings.Setting__c);
            if (settings.DeveloperName == 'X_IBM_Client_Id') X_IBM_Client_Id = settings.Setting__c;
            if (settings.DeveloperName == 'X_IBM_Client_Secret') X_IBM_Client_Secret = settings.Setting__c;
            if (settings.DeveloperName == 'QUERYTYPE_FIELD') QUERYTYPE_FIELD = settings.Setting__c;
            if (settings.DeveloperName == 'REGID_FIELD') REGID_FIELD = settings.Setting__c;
            if (settings.DeveloperName == 'CIB_VIEW') CIB_VIEW = settings.Setting__c;
            //RN - CloudSmiths
            //if (settings.DeveloperName == 'QUERYTYPES') queryTypeList.addAll(settings.Setting__c.split(','));
        }
    }
    
    public static void getUDFServiceTypes(){
        UDFServiceTypes = '';
        for(DynamicSectionRendering__mdt settings : [Select Label From DynamicSectionRendering__mdt Where Object__c = 'Case' AND Section__c = 'UDF' AND Field__c = 'Service_Type__c']) {
            UDFServiceTypes = UDFServiceTypes + ';' + settings.Label;
        }
    }
    
    public static void getChargesServiceTypes(){
        ChargesServiceTypes = '';
        for(DynamicSectionRendering__mdt settings : [Select Label From DynamicSectionRendering__mdt Where Object__c = 'Case' AND Section__c = 'Charges' AND Field__c = 'Service_Type__c']) {
            ChargesServiceTypes = ChargesServiceTypes + ';' + settings.Label;
        }
    }
    
    // Action method which synchronously calls the Get Client Details operation with specified parameters
    // queryType: Type of query, valids ones are: cif, passport, identityDocument and suid
    // regId: Registration number, ID number, passport number etc depending on the query type
    // view: Predefined views of the client information. If it is null or empty "BASIC_VIEW" will be used
    // hideMeta: Boolean flag, if set to true then no extra meta data will be shown. Default is false
    public static List<ClientDetail> RetrieveClientDetails(String queryType, String regId, String view, Boolean hideMeta) {
        // Builds the query strings based on the parameters passed to the method
        String QueryString='';
        if (queryType != '') QueryString = QueryString + '?queryType=' + queryType;
        if (regId != '') QueryString = QueryString + (QueryString=='' ? '?' : '&') + 'regId=' + regId;
        if (view != '') QueryString = QueryString + (QueryString=='' ? '?' : '&') + 'view=' + view;
        QueryString = QueryString + (QueryString=='' ? '?' : '&') + 'hideMeta=' + (hideMeta ? 'true' : 'false');
        
        System.debug('** Query = ' + QueryString);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(BASE_ENDPOINT + OPERATION_GETCLIENTS + QueryString.replace(' ','%20'));
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        request.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
        request.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
        request.setTimeout(TIMEOUT);
        
        HttpResponse response;
        ClientDetails = new List<ClientDetail>();
        try {
            response = http.send(request);
            
            System.debug('** response = ' + response.getBody());
             System.debug('** getStatusCode = ' +response.getStatusCode());
            
            if (response.getStatusCode() == 200)
            {
                try {
                    // Deserialize the list of Client Details from the JSON string
                    ClientDetails = (List<ClientDetail>)JSON.deserialize(response.getBody().replace('"limit":','"limits":').replace('"$ref":','"ref":').replace('"number":','"numbers":').replace('"_links":','"links":').replace('"$id":','"id":'), List<ClientDetail>.class);  
                }catch(Exception e){ 
                    System.debug(e.getMessage());
                   ResponseMessage = 'Error:  '+response.getStatus();
                    ResponseMessage += response.getBody(); 
                }
            }else{
                ResponseMessage = 'Error:  '+response.getStatus();
                ResponseMessage += response.getBody();
           
            }
            
        } catch(Exception e){ 
            System.debug(e.getMessage());
            ResponseMessage = 'Error:  '+response.getStatus();
            ResponseMessage += e.getMessage(); 
        }
        
        
        String caseId = '';
        String caseCIF = '';
        
        if(theCase != null){
            caseId = theCase.Id;
            caseCIF = theCase.Account.CIF__c;
        }else{
            if(ApexPages.currentPage().getParameters().get('audit') != null){
                caseId = ApexPages.currentPage().getParameters().get('audit');
                caseCIF = regId; 
            }
        }
        
        
        auditCIFSearch(queryType, regId, UserInfo.getUserId(), caseId, caseCIF);
        
        return ClientDetails;
    }
    
    // Property method for Client Details found
    public static list<ClientDetail> ClientDetails {
        get { return Client_Details; }
        set { Client_Details = value; }
    }
    
    // Property method to get the Primary Client and set the CIFNumber for the client we are currently seeing
    public static  ClientDetail PrimaryClient {
        get {
            for (ClientDetail pc : PrimaryClients) {
                if (pc.identifications != null) {
                    for (IdentificationsInfo ii : pc.identifications) {
                        if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                            // drop down hasn't been changed yet, set to the first one we find
                            if (CIFNumber == null) {
                                CIFNumber = ii.numbers;
                                return pc;
                            }
                            // dropdown has been changed, set to this one if the CIF corresponds
                            if (ii.numbers == CIFNumber) return pc;
                        }
                    }  
                }
            }
            return null;
        }
    }
    
    // Property method to put PrimaryClient Accounts in a Map. Avoids limitation when displaying on VF page
    public Map<AccountInfo, String> PrimaryClientAccounts {
        get {
            if (PrimaryClient != null && PrimaryClient.account != null && PrimaryClient.account.size() > 0) {
                Map<AccountInfo, String> accounts = new Map<AccountInfo, String>();
                for(AccountInfo acc : PrimaryClient.account) {
                    accounts.put(acc, '');
                }
                return accounts;
            }
            return null;
        } 
    }
    
    // Property method to get all the Primary Clients for the search done
    public static List<ClientDetail> PrimaryClients {
        get
        {
            List<ClientDetail> PrimaryClients = new List<ClientDetail>();
            if (ClientDetails != null && ClientDetails.size() > 0) {
                for (ClientDetail cd : ClientDetails) {
                    if (cd.meta != null
                        && cd.meta.queryResult != null
                        && cd.meta.queryResult.sourceSystem != null
                        && cd.meta.queryResult.sourceSystem == 'cif'
                        && cd.meta.queryResult.type != null
                        && cd.meta.queryResult.type == 'related')
                        PrimaryClients.add(cd);
                    //PrimaryClients.add(cd);
                    //PrimaryClients.add(cd);
                    //PrimaryClients.add(cd);
                    //PrimaryClients.add(cd);
                    
                }
            }
            return PrimaryClients;
        }
    }
    
    // Property method to build the dropdown that shows the CIF of all the Primary Clients one can show on the CIF screen
    public List<SelectOption> CIFOptions {
        get {
            List<SelectOption> cif_options = new List<SelectOption>();
            for (ClientDetail pc : PrimaryClients) {
                if (pc.identifications != null) {
                    for (IdentificationsInfo ii : pc.identifications) {
                        if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                            String Label = ii.numbers;
                            if (pc.customerDetails != null 
                                && pc.customerDetails.groupScheme != null 
                                && pc.customerDetails.groupScheme.description != null 
                                && pc.customerDetails.groupScheme.description.value != null 
                                && pc.customerDetails.groupScheme.description.value.trim() != '') 
                                Label = Label + ' - ' + pc.customerDetails.groupScheme.description.value;
                            SelectOption option = new SelectOption(ii.numbers,Label);
                            cif_options.add(option);
                        }  
                    }  
                }  
            }
            return cif_options;
        }
    }
    
    // Property method to return a list of strings containing the CIF Numbers of the Primary Clients
    public List<String> CIFNumbers {
        get {
            List<String> cifs = new List<String>();
            for (ClientDetail pc : PrimaryClients) {
                if (pc.identifications != null) {
                    for (IdentificationsInfo ii : pc.identifications) {
                        if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                            cifs.add(ii.numbers);
                        }  
                    }  
                }  
            }
            return cifs;
        }
    }
    
    // Property method for the selected item of the CIF dropdown
    public static String CIFNumber { get;set; }
    public List<ClientDetail> Mandates {
        get
        {
            List<ClientDetail> Mandates = new List<ClientDetail>();
            for (ClientDetail cd : ClientDetails) {
                if (cd.meta != null
                    && cd.meta.queryResult != null
                    && cd.meta.queryResult.sourceSystem != null
                    && cd.meta.queryResult.sourceSystem == 'auth')
                    if (IsMandateOfPrimaryClient(cd)) Mandates.add(cd);
            }
            Mandates.sort();
            return Mandates;
        }
    }
    
    // Method that checks if a client is a mandate of the Primary Client
    public Boolean IsMandateOfPrimaryClient(ClientDetail cd) {
        if (PrimaryClient != null && PrimaryClient.authority != null && cd.id != null) {
            for (AuthorityInfo authinfo : PrimaryClient.authority) {
                if (authinfo.signatoryDetails != null && authinfo.signatoryDetails.size() > 0) {
                    for (SignatoryDetailsInfo siginfo : authinfo.signatoryDetails) {
                        if (siginfo.entity != null && siginfo.entity.ref != null) {
                            if (siginfo.entity.ref == cd.id) return true;
                        }
                    }
                }
            }
        }
        return false;
    }
    
    // Property method to return any errors that come out of the REST API call
    public String Error { 
        get { return ResponseMessage; }
    }
    // sets the Authority 
    private static void SetAuthorityInfo() {
        if (ClientDetails!=null && ClientDetails.size() > 0) {
            for (ClientDetail cifcd : ClientDetails) {
                if (cifcd.authority != null
                    && cifcd.meta != null
                    && cifcd.meta.queryResult != null
                    && cifcd.meta.queryResult.sourceSystem != null
                    && cifcd.meta.queryResult.sourceSystem == 'cif') {
                        for (AuthorityInfo authinfo : cifcd.authority) {
                            for (ClientDetail cd : ClientDetails) {
                                if (cd.id != null && cd.id.trim() != '' && authinfo.signatoryDetails.size() > 0 && cd.id == authinfo.signatoryDetails[0].entity.ref) {
                                    cd.authority = new List<AuthorityInfo>();
                                    cd.authority.add(authinfo);
                                }
                            }
                        }   
                    }  
            }
        }
    }
    
    // Gets all the additional accounts on client details with ClientDetail.MetaInfo.QueryResultInfo.sourceSystem = cif and ClientDetail.MetaInfo.QueryResultInfo.sourceSystem.type = additionalcif
    // and add these accounts to the accounts with ClientDetail.MetaInfo.QueryResultInfo.sourceSystem = cif and ClientDetail.MetaInfo.QueryResultInfo.sourceSystem.type = related
    private static void SetAdditionalAccounts() {
        if (ClientDetails!=null && ClientDetails.size() > 0) {
            for (ClientDetail cifcd : ClientDetails) {
                if (cifcd.meta != null
                    && cifcd.meta.queryResult != null
                    && cifcd.meta.queryResult.sourceSystem != null
                    && cifcd.meta.queryResult.sourceSystem == 'cif'
                    && cifcd.meta.queryResult.type != null
                    && cifcd.meta.queryResult.type == 'related') {
                        for (ClientDetail addtnlcd : ClientDetails) {
                            if (addtnlcd.meta != null
                                && addtnlcd.meta.queryResult != null
                                && addtnlcd.meta.queryResult.sourceSystem != null
                                && addtnlcd.meta.queryResult.sourceSystem == 'cif'
                                && addtnlcd.meta.queryResult.type != null
                                && addtnlcd.meta.queryResult.type == 'additionalCIF'
                                && addtnlcd.account != null
                                && addtnlcd.account.size() > 0) {
                                    if (cifcd.account == null || cifcd.account.size() == 0)
                                        cifcd.account = addtnlcd.account;
                                    else
                                        cifcd.account.addAll(addtnlcd.account);      
                                }                    
                        }
                        if (cifcd.account != null && cifcd.account.size() > 0) cifcd.account.sort(); //sort the accounts for display purposes
                    }      
            }  
        }  
    }
    
    
    // This method updates any account info we would like to update from the ADAPT360 service. Primary Client holds the current client selected
    private static void UpdateAccountInfo(Id accountId, String CIF) {
        ClientDetail cd = ClientDetailFromCIF(CIF);
        if(cd != NULL && cd.customerDetails != NULL && cd.customerDetails.groupScheme != NULL && cd.customerDetails.groupScheme.description != NULL) {
            Account accToUpdate = new Account(Id = accountId, groupScheme__c = cd.customerDetails.groupScheme.description.value);
            try {
                update accToUpdate;
            } catch (Exception ex) {
                System.debug('Error updating account info:' + ex.getMessage());
            }
        }
    }
    
    private static ClientDetail ClientDetailFromCIF(String CIF) {
        if (CIF != NULL && CIF != '') {
            for (ClientDetail pc : PrimaryClients) {
                if (pc.identifications != null) {
                    for (IdentificationsInfo ii : pc.identifications) {
                        if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                            // found CIF number to update
                            if (ii.numbers == CIF) {
                                return pc;
                            }
                        }
                    }
                }
            }    
        }
        return null;
    }
    
    public class CaseRecordTypeInformation{
        public String recordId = '';
        public String label = '';
        public String value = '';
    }
    public class DigitalOpsCase{
        public String accountId = '';
        public boolean colleague = false;
        public String emailSenderName = '';
        public String emailFromAddress = '';
        public String status = '';
        public String userType = '';
        public String iDVComplete = '';
        public String iDV = '';
        
        public String novoFXReference = '';
        public String bAPSReference = '';
        public String queue = '';
        public String subject = '';
        public String description = '';
        public String priority = '';
        public String department = '';
        public String fullDepartment = '';
        public String teamManager = '';
        
        public String businessHours = '';
        public String team = '';
        public String origin = '';
        public String serviceCategory = '';
        public String serviceSubCategory = '';
        public String serviceType = '';
        
        public String channel = '';
        public String recordTypeId = '';
        public String OwnerId = '';
        public String relationshipID = '';
        public String ResponseMessage_r = '';
    }
    
    public class ManualCase{
        public String id = '';
        public String accountNumber = '';
        public String contactConfirmedWith = '';
        public String clientContactTelNo = '';
        public DateTime dateConfirmed = null;
        public String clientAbsaAccountNumber = '';
        public String clientIDNumberMandateAUTH = '';
        public String clientSignatureMandateSIGV = '';
        public String beneficiaryName = '';
        public Decimal amountVerifiedandApproved = 0;
        public String beneficiaryAccNoandBank = '';
        
        public String beneficiaryACBorBranchCode = '';
        public String indemnityVerified = '';
        public String disclaimerReadtoClient = '';
        public String rSCConfirmsFunds = '';
        public String duplicationsChecked = '';
        public String typeofTransferAuthorised = '';
        public String verifyClientAccountNumberDebit = '';
        public String paymentAuthPaperMandate = '';
        public String thirdPartyPaymentProcessed = '';
        public Decimal wip = 0;
        
        public boolean pop = false;
        public String chargeAccountNo = '';
        public String transactionCode = '';
        public String costCentre = '';
        public String corpCode = '';
        public String dRRef = '';
        public String cRRef = '';
        public DateTime effectiveDate = null;
        public String cRAccountNo = '';
        public String emailSenderName = '';
        
        public String emailFromAddress = '';
        public String queue = '';
        public String subject = '';
        public String description = '';
        public String priority = '';
        public boolean urgent = false;
        public String accountId = '';
        public String department = '';
        public String fullDepartment = '';
        public String teamManager = '';
        
        public String businessHours = '';
        public String team = '';
        public String origin = '';
        public String serviceCategory = '';
        public String serviceSubCategory = '';
        public String serviceType = '';
        public Decimal requests = 0;
        public String channel = '';
        public boolean hWasEmailToCaseAction = false;
        public String reasonforCancellation = '';
        
        public String recordTypeId = '';
        public String OwnerId = '';
        public String relationshipID = '';
        public String ResponseMessage_r = '';
        
        
    }
    public class ComplainCase{
        public ID id = null;
        public String accountId = '';
        public String ownerID = '';
        public String emailSenderName = '';
        public String emailFromAddress = '';
        public Boolean suppressAcknowledgeAlert = false;
        public String priority = '';
        public String status = '';
        public Date incidentDate = null;
        public String origin = '';
        public String ResponseMessage_r = '';
        public String ownerName = '';
        public String RecordTypeId = '';
        
        public String subject = '';
        public String description = '';
        
        public String complaintServiceSubCategory = '';
        public String complaintChannel = '';
        public Boolean staffError = false;
        public Boolean mnip = false;
        public String staffErrorDescription = '';
        
        public String opportunityName = '';
        public String staffMemberName = '';
        
        public String desiredAction = '';
        public String actionTaken = '';
        public String rootCauseCategory = '';
        public String rootCause = '';
        public String businessOwnerAction = '';
        public String resolutionDetail = '';
        public String resolvedInFavourOf = '';
        
        public String complaintServiceCategory = '';
        public String resolvingArea = '';
        public String complaintServiceType = '';
        public String resolvingTeam = '';
        public String callReportId = '';
        
        
    } 
    // Class which defines the Client details returned in Adapt360 Service
    public class ClientDetail implements Comparable {
        public AccountInfo[] account{get;set;}
        public IndividualInfo individual{get;set;}
        public CustomerDetailsInfo customerDetails{get;set;}
        public LocationInfo location{get;set;}
        public ContactInfo contact{get;set;}
        public CorporateEntityInfo corporateEntity{get;set;}
        public CustomerInfo customer{get;set;}
        public MetaInfo meta{get;set;}
        public IdentificationsInfo[] identifications{get;set;}
        public String links{get;set;}
        public FlagInfo flags{get;set;}
        public AuthorityInfo[] authority{get;set;}
        public String id{get;set;}
        
        // we order clients alphabetically by AuthorityType, then Name
        public Integer compareTo(Object compareTo) {
            String thisCombined;
            if (individual.salutationType.description.value != null) thisCombined = thisCombined + individual.salutationType.description.value.trim();
            if (individual.nameInitials.value != null) thisCombined = thisCombined + individual.nameInitials.value.trim();
            if (individual.surname.value != null) thisCombined = thisCombined + individual.surname.value.trim();
            if (authority.size() > 0 && authority[0].authorityType.value != null) thisCombined = authority[0].authorityType.value + thisCombined;
            ClientDetail compareToclient = (ClientDetail)compareTo;
            String compareTocombined;
            if (compareToclient.individual.salutationType.description.value != null) compareTocombined = compareTocombined + compareToclient.individual.salutationType.description.value.trim();
            if (compareToclient.individual.nameInitials.value != null) compareTocombined = compareTocombined + compareToclient.individual.nameInitials.value.trim();
            if (compareToclient.individual.surname.value != null) compareTocombined = compareTocombined + compareToclient.individual.surname.value.trim();
            if (compareToclient.authority.size() > 0 && compareToclient.authority[0].authorityType.value != null) compareTocombined = compareToclient.authority[0].authorityType.value.trim() + compareTocombined;
            return thisCombined.compareTo(compareTocombined);
        }
    }
    
    public class AccountInfo implements Comparable {
        public attribute accountNumber{get;set;}
        public attribute product{get;set;}
        public attribute productType{get;set;}
        public attribute availableBalance{get;set;}
        public Decimal availableBalanceFormatted {
            get {
                if (availableBalance!=null && availableBalance.value!=null) return Decimal.valueOf(availableBalance.value); else return null;
            }
        }
        public attribute availableBalanceSpecified{get;set;}
        public attribute balance{get;set;}
        public Decimal balanceFormatted {
            get {
                if (balance!=null && balance.value!=null) return Decimal.valueOf(balance.value); else return null;
            }
        }
        public attribute balanceSpecified{get;set;}
        public attribute balanceTxt{get;set;}
        public attribute branch{get;set;}
        public attribute corporationCode{get;set;}
        public attribute dateClosed{get;set;}
        public attribute detail{get;set;}
        public attribute limits{get;set;}
        public attribute limitSpecified{get;set;}
        public attribute accountStatus{get;set;}
        public entityreference entity{get;set;}
        
        // we order accounts alphabetically by Status then Account Number
        public Integer compareTo(Object compareTo) {
            String thisCombined;
            if (accountStatus.value != null) thisCombined = thisCombined + accountStatus.value.trim();
            if (accountNumber.value != null) thisCombined = thisCombined + accountNumber.value.trim();
            String compareTocombined;
            if (((AccountInfo)compareTo).accountStatus.value != null) compareTocombined = compareTocombined + ((AccountInfo)compareTo).accountStatus.value;
            if (((AccountInfo)compareTo).accountNumber.value != null) compareTocombined = compareTocombined + ((AccountInfo)compareTo).accountNumber.value;
            return thisCombined.compareTo(compareTocombined);
        }
    }
    
    public class IndividualInfo {
        public attribute givenName{get;set;}
        public attribute nameInitials{get;set;}
        public attribute surname{get;set;}
        public keyvaluepair salutationType{get;set;}
        public keyvaluepair countryPassport{get;set;}
        public keyvaluepair countryOfBirth{get;set;}
        public keyvaluepair gender{get;set;}
        public keyvaluepair nationality{get;set;}
        public keyvaluepair employmentStatusType{get;set;}
        public DocumentDetailsInfo documentDetails{get;set;}
        public attribute birthDate{get;set;}
        public keyvaluepair countryOfOrigin{get;set;}
        public keyvaluepair countryOfResidence{get;set;}
    }
    
    public class CustomerDetailsInfo {
        public keyvaluepair identificationTypeId{get;set;}
        public attribute individualId{get;set;}
        public attribute universalResourceLocator{get;set;}
        public keyvaluepair customerType{get;set;}
        public keyvaluepair groupScheme{get;set;}
        public keyvaluepair sourceOfFundsCode{get;set;}
        public keyvaluepair sourceOfIncomeCode{get;set;}
        public keyvaluepair corporateDivision{get;set;}
        public attribute NCAThreshold{get;set;}
        public attribute CPAThreshold{get;set;}
        public keyvaluepair sbuSegment{get;set;}
        public attribute forensicHold{get;set;}
        public attribute inLiquidation{get;set;}
        public attribute underJudicialManagement{get;set;}
        public attribute financialCrime{get;set;}
        public attribute inBusinessRescue{get;set;}
        public attribute inBusinessRescueAffectedParty{get;set;}
        public attribute placedInBusinessRescueBy{get;set;}
        public attribute casaReference{get;set;}
    }
    
    public class LocationInfo {
        public Address physicalAddress{get;set;}
        public Address postalAddress{get;set;}
        public Address businessAddress{get;set;}
        public Address headOfficeAddress{get;set;}
    }
    
    public class Address {
        public attribute addressName1{get;set;}
        public attribute addressName2{get;set;}
        public attribute suburbName{get;set;}
        public attribute cityName{get;set;}
        public attribute postCodeArea{get;set;}
        public attribute addressTypeCode{get;set;}
        public attribute addressType{get;set;}
    }
    
    public class ContactInfo {
        public attribute cellPhoneNumber{get;set;}
        public keyvaluepair communicationChannelType{get;set;}
        public attribute workPhone{get;set;}
        public attribute homePhone{get;set;}
        public attribute telephoneNumber{get;set;}
        public attribute eMailUserId{get;set;}
        public attribute contactPerson{get;set;}
        public attribute designation{get;set;}
    }
    
    public class CorporateEntityInfo {
        public keyvaluepair incorporatedCountry{get;set;}
        public keyvaluepair standardIndustryCode{get;set;}
    }
    
    public class CustomerInfo {
        public CustomerDetails Details;
    }
    
    public class CustomerDetails {
        public attribute CPAThreshold{get;set;}
    }
    
    public class MetaInfo {
        public QueryResultInfo queryResult;
    }
    
    public class QueryResultInfo {
        public String sourceSystem{get;set;}
        public String type{get;set;}
    }
    
    public class IdentificationsInfo {
        public IdentificationType type{get;set;}
        public String numbers{get;set;}
        public Boolean personalIdentificationFlag{get;set;}
        public Boolean systemIdentificationFlag{get;set;}
        public String issueDate{get;set;}
        public String expiryDate{get;set;}
        public String country{get;set;}
    }
    
    public class IdentificationType {
        public String code;
        public String description;
    }
    
    public class FlagInfo {
        public attribute compliant{get;set;}
        public keyvaluepair reason{get;set;}
    }
    
    public class AuthorityInfo {
        public SignatoryDetailsInfo[] signatoryDetails{get;set;}
        public attribute authorityTypeCode{get;set;}
        public attribute customerCode{get;set;}
        public attribute accountNumber{get;set;}
        public attribute changeTrackingNumber{get;set;}
        public attribute courtAuthorityCode{get;set;}
        public attribute numberOfSignatures{get;set;}
        public attribute employeeNumber{get;set;}
        public attribute originalCourtAuthorityCode{get;set;}
        public attribute originalNumberOfSignatures{get;set;}
        public attribute originalSpecialConditions{get;set;}
        public attribute overrideEmployeeNumber{get;set;}
        public attribute specialConditions{get;set;}
        public attribute status{get;set;}
        public attribute changedSignatory{get;set;}
        public attribute authorityType{get;set;}
    }
    
    public class SignatoryDetailsInfo {
        public ProductInfo product;
        public attribute dateIssued{get;set;}
        public attribute expiryDate{get;set;}
        public attribute maximumAmount{get;set;}
        public Decimal maximumAmountFormatted {
            get {
                if (maximumAmount!=null && maximumAmount.value!=null) return Decimal.valueOf(maximumAmount.value); else return null;
            }
        }
        public entityreference entity{get;set;}
    }
    
    public class ProductInfo {
        public attribute accountNumber{get;set;}
    }
    
    public class DocumentDetailsInfo {
        public DocumentInfo idDoc{get;set;}
        public DocumentInfo addDoc{get;set;}
    }
    
    public class DocumentInfo {
        public attribute casaTier{get;set;}
        public keyvaluepair documentType{get;set;}
        public keyvaluepair documentStatusReason{get;set;}
        public attribute casaSequence{get;set;}
        public attribute imageId{get;set;}
        public attribute casaReference{get;set;}
        public attribute documentRecieved{get;set;}
        public attribute documentInOrder{get;set;}
        public attribute qualityAssurance{get;set;}
        public attribute allCorrectRecieved{get;set;}
        public attribute allCorrectInOrder{get;set;}
    }
    
    public class attribute { public String value{get;set;} }
    public class entityreference { public String ref{get;set;} }
    public class keyvaluepair {
        public attribute code{get;set;}
        public attribute description{get;set;}    
    }
    
    //RN - CloudSmiths 
    @future
    private static void auditCIFSearch(String queryType, String queryValue, String userId, String caseId, String caseCIF){
        
        CIF_Search_Audit__c audit = new CIF_Search_Audit__c();
        audit.CaseId__c = caseId;
        audit.CaseCIFNumber__c = caseCIF;
        audit.UserId__c = userId;
        audit.SearchAction__c = queryType;
        audit.SearchValue__c = queryValue;
        
        try{
            
            insert audit;
            
        }catch(DMLException ex){
            System.debug('There was an Error when logging the audit record for CIF searches');
            System.debug(ex.getMessage());
        }
    }
}