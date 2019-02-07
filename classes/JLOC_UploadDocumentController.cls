/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a controller for JLOC_UploadDocument page.
* @Date:        10/2015
* @ConstructorParam:    stdController - Standard Controller for "JLOC" object
* @TestClass:   ZZTEST_JLOC_UploadDocumentController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 3/2016	  Marek Cech 		 changed save method to support 3 document types, added deletePreviousVersion
*------------------------------------------------------------*/
public with sharing class JLOC_UploadDocumentController {
	
	public Attachment attachment { get; set; }
	private JLOC__c jloc;
    public String fileType{get;set;}
     public String anchor{get;set;}

	private static final String PRICING_AND_RETURNS = 'PricingAndReturns';
	private static final String ANCILLARY_CALCULATION = 'AncillaryCalculation';
    private static final String STRESS_CASE = 'StressCase';
    private static final String BANK_CASE= 'BankCase';
    private static final String MANAGEMENT_CASE = 'ManagementCase';
    private static final String EMBEDDEDPREFIX = '(Embedded) ';
    private List<String> embedded = new List<String>{PRICING_AND_RETURNS,MANAGEMENT_CASE,BANK_CASE,STRESS_CASE};

	public JLOC_UploadDocumentController(ApexPages.StandardController stdController) {
		if(!test.isRunningTest()) {
			stdController.addFields(new List<String>{
	            'Name', 'Pricing_and_Returns_Document_ID__c', 'Ancillary_Calculation_Document_ID__c','Management_Case_ID__c','Banker_Case_ID__c','Stress_Case_ID__c'
	        });
	    }

		jloc = (JLOC__c) stdController.getRecord();
		attachment = new Attachment();
		fileType = ApexPages.CurrentPage().getParameters().get('fileType');
        anchor = ApexPages.CurrentPage().getParameters().get('anchor');
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to insert new one as attachment
    * @param        None
    * @Returns:     the edit page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 3/2016	  Marek Cech 		 added support for 3 document types
    *------------------------------------------------------------*/
	public PageReference save() {
		//Save new Attachment
		attachment.ParentId = jloc.Id;
        
		try {
            if(attachment.Body!=null)
            {
                if(embedded.contains(fileType)){
                    attachment.Name = EMBEDDEDPREFIX +attachment.Name;
                }
                
                INSERT attachment;
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'No file was uploaded'));
                return null;
            }
            
			
		} catch(DmlException ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}

		String anchor;

		if(fileType == PRICING_AND_RETURNS) {
			deletePreviousVersion(jloc.Pricing_and_Returns_Document_ID__c);
			jloc.Pricing_and_Returns_Document_ID__c = attachment.Id;
		} else if(fileType == ANCILLARY_CALCULATION) {
			deletePreviousVersion(jloc.Ancillary_Calculation_Document_ID__c);
			jloc.Ancillary_Calculation_Document_ID__c = attachment.Id;
		} else if(fileType ==STRESS_CASE)
        {
            deletePreviousVersion(jloc.Stress_Case_ID__c);
			jloc.Stress_Case_ID__c = attachment.Id;
        }else if(fileType ==BANK_CASE)
        {
            deletePreviousVersion(jloc.Banker_Case_ID__c);
			jloc.Banker_Case_ID__c = attachment.Id;
        }else if(fileType ==MANAGEMENT_CASE)
        {
            deletePreviousVersion(jloc.Management_Case_ID__c);
			jloc.Management_Case_ID__c = attachment.Id;
        }
        
        anchor = this.anchor;
        try {
			UPDATE jloc;
		} catch(DmlException ex) {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}

        PageReference pageRef = new PageReference('/apex/JLOC_Edit?id='+jloc.Id+'&sfdc.override=1#'+anchor);
		pageRef.setRedirect(true);
		return pageRef;
	}
    
    public PageReference Cancel()
    {
        PageReference pageRef = new PageReference('/apex/JLOC_Edit?id='+jloc.Id+'&sfdc.override=1#'+anchor);
		pageRef.setRedirect(true);
		return pageRef;
    }
	/**
    * @Author:      Marek Cech
    * @Company:     Deloitte
    * @Description: This method is used to delete old Pricing and Returns document (if exists)
    * @param        String fileId
    * @Returns:     void
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public static void deletePreviousVersion(String fileId) {
		if(String.isNotBlank(fileId)) {
			List<Attachment> attachments = [
				SELECT 	Id 
				FROM 	Attachment 
				WHERE 	Id = :fileId
			];
			if(!attachments.isEmpty()){
				DELETE attachments;
			}
		}
	}
}