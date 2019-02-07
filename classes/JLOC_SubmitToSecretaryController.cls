/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a controller for JLOC_SubmitToSecretary page.
* @Date:        10/2015
* @ConstructorParam:    stdController - Standard Controller for "JLOC" object
* @TestClass:   ZZTEST_JLOC_SubmitToSecretaryController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class JLOC_SubmitToSecretaryController {
	public static String STATUS_SUBMITTED_TO_SECRETARY = 'Submitted to Secretary';
	private JLOC__c jloc;
	public Boolean requiredFieldsMissing { get; set; }
	public Boolean requiredActionsNotPerformed { get; set; }

	public JLOC_SubmitToSecretaryController(ApexPages.StandardController stdController) {
		
        
        //Tonga MM : Modified constructer to dynamically include fields onto controller everytime new fields are added
        List<String> fieldNames  = new List<String>();
        
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.JLOC__c.fields.getMap();
        for (String fieldName: schemaFieldMap.keySet()) {
            fieldNames.add(fieldName);
        }
        if(!test.isRunningTest()) {
            stdController.addFields(fieldNames);
        }
		jloc = (JLOC__c)stdController.getRecord();
        requiredFieldsMissing = areRequiredFieldsMissing();
		requiredActionsNotPerformed = areRequiredActionsNotPerformed();
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to Submit JLOC to Secretary.
    * @param        None
    * @Returns:     the view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public PageReference submitToSecretary(){
		requiredFieldsMissing = areRequiredFieldsMissing();
		requiredActionsNotPerformed = areRequiredActionsNotPerformed();
        jloc.JLOC_Status__c = STATUS_SUBMITTED_TO_SECRETARY;
        //update jloc;
        
        Savepoint sp =  Database.setSavepoint();
        
        PageReference printView = Page.JLOC_PrintView;
        printView.getParameters().put('id', jloc.Id);
        printView.getParameters().put('status', jloc.JLOC_Status__c);
        printView.setRedirect(true);
        
        //Check if there are opportunities associated to JLOC 
        if (JLOC_PrintViewController.getJLOCOpportunity(jloc.Id) == NULL && !Test.isRunningTest()) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_AtLeastOneOpportunityForJLOC));
            return null;
        }
        
        Attachment att = new Attachment();
        Blob body = Test.isRunningTest() ? Blob.ValueOf('dummy text') : printView.getContent();
        att.Body = body;
        att.Name = jloc.Name + '_'+jloc.JLOC_Status__c+'_' + System.now().format('yyyyMMdd') + '.pdf';
        att.parentId = jloc.id;
        try {
            INSERT att;
        } catch(DmlException ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
        }

        if(jloc.JLOC_Document_ID__c != null) {
            try {
                DELETE [SELECT Id, Name, Body FROM Attachment WHERE Id = :jloc.JLOC_Document_ID__c];
            } catch(DmlException ex) 
            {
                JLOC_Utility.logException(ex, 'JLOC_viewController', 'generatePdf', 'There was an error in Deleting JLOC Attachment ID '+jloc.JLOC_Document_ID__c);
            }
        }
        
        jloc.JLOC_Document_ID__c = att.Id;
        try{
            UPDATE jloc;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, jloc.JLOC_Status__c + ' document has been (re-)generated.'));
        } catch(DmlException ex) {
                JLOC_Utility.logException(ex, 'JLOC_viewController', 'generatePdf', 'There was an error in updating JLOC ID '+jloc.ID);
             Database.rollback(sp);
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(0)));
			return null;
        }
        
		if(requiredActionsNotPerformed){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You may NOT present your paper to the JLOC Committee.'));
            Database.rollback(sp);
			return null;
		} 

		List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();
		Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
		req.setObjectId(jloc.Id);
		requests.add(req);
		try{
			List<Approval.ProcessResult> results = Approval.process(requests);
		} catch(Exception ex){
            Database.rollback(sp);
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(0)));
			return null;
		}

		PageReference pageRef = new ApexPages.StandardController(jloc).view();
		pageRef.setRedirect(true);
		return pageRef;
	}
/*
	public PageReference submitToSecretary(){
		requiredFieldsMissing = areRequiredFieldsMissing();
		requiredActionsNotPerformed = areRequiredActionsNotPerformed();

		PageReference pageRef = new ApexPages.StandardController(jloc).view();
		pageRef.setRedirect(true);

		if(requiredActionsNotPerformed){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'You may NOT present your paper to the JLOC Committee.'));
			pageRef = null;
		} else{
			jloc.JLOC_Status__c = STATUS_SUBMITTED_TO_SECRETARY;
		}
		try{
			update jloc;
		} catch(DmlException ex){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(0)));
			return null;
		}
		return pageRef;
	}
*/
	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to cancel submitting to Secretart.
    * @param        None
    * @Returns:     the view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public PageReference cancel(){
		return new ApexPages.StandardController(jloc).view();
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to check if there is any required field missing
    * @param        None
    * @Returns:     true if any required field is missing value
    *				false if all required fields are provided
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public Boolean areRequiredFieldsMissing(){
		if(String.isBlank(jloc.Status__c) || String.isBlank(jloc.CLGD_Consumption__c)){
			return true;
		} else{
			return false;
		}
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to check if any required confirmation is missing
    * @param        None
    * @Returns:     true if any required confirmation is missing value
    *				false if all required confirmations are provided
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public Boolean areRequiredActionsNotPerformed(){
		if(jloc.Deal_Presented_To_Deal_Forum__c == false || jloc.Go_Approval_From_Deal_Forum_Quorum__c == false || jloc.Approved_By_Financial_Crime_Compliance__c == false 
				|| jloc.Conflict_Clearance_Obtained__c == false || jloc.Deal_Team_Polices_Confirmation__c == false){
			return true;
		} else{
			return false;
		}
	}
}