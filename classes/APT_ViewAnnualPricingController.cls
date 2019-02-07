/**
* @Author		Marta Malinowska
* Company:		Deloitte
* @Description:	This class is used as a controller for APT_ViewAnnualPricing page.
* @Date:		09/2015
* @ConstructorParam:	stdController - Standard Controller for "Annual Pricing" object
* @TestClass:	ZZTEST_APT_ViewAnnualPricingController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class APT_ViewAnnualPricingController {
	private Annual_Pricing__c annualPricing;
	public Boolean editMode { get; set; }
	public Boolean isSubmitted { get; set; }
	public Boolean isPending { get; set; }
	public Boolean isApproved { get; set; }
	public Boolean isRejected { get; set; }
	private Boolean isApprovalRequired;
	public Boolean isReadOnly { get; set; }
	public Boolean isReadyToRequestForApproval { get; set; }
	public Boolean isReadyToGeneratePricingLetter { get; set; }
	public List<APT_AnnualPricingUtils.PricingGroupWrapper> pricingGroups { get; set; }

	public APT_ViewAnnualPricingController(ApexPages.StandardController stdController) {
		annualPricing = (Annual_Pricing__c)stdController.getRecord();
		editMode = ApexPages.currentPage().getParameters().get('mode') == 'edit' ? true : false;

		pricingGroups = APT_AnnualPricingUtils.getAnnualPricingItemsGroupedByPricingGroups(annualPricing);
		isApprovalRequired = APT_AnnualPricingUtils.getIsApprovalRequired(pricingGroups);

        isSubmitted = annualPricing.Approval_Status__c == APT_AnnualPricingUtils.STATUS_STANDARD_PRICING ? false : true;
		//isSubmitted = annualPricing.Approval_Status__c == APT_AnnualPricingUtils.STATUS_NOT_SUBMITTED ? false : true;
		isPending = annualPricing.Approval_Status__c == APT_AnnualPricingUtils.STATUS_PENDING ? true : false;
		isApproved = annualPricing.Approval_Status__c == APT_AnnualPricingUtils.STATUS_APPROVED ? true : false;
		isRejected = annualPricing.Approval_Status__c == APT_AnnualPricingUtils.STATUS_REJECTED ? true : false;

		isReadOnly = isPending || isApproved;
		isReadyToRequestForApproval = !isSubmitted && isApprovalRequired || isRejected;
		isReadyToGeneratePricingLetter = !isSubmitted && !isApprovalRequired || isApproved;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to redirect to edit page.
	* @param 		None
	* @Returns:		Edit page for current Annual Pricing
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference edit(){
		PageReference pageRef = new ApexPages.StandardController(annualPricing).view();
		pageRef.getParameters().put('mode','edit');
		return pageRef;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to redirect to Approval Request page.
	* @param 		None
	* @Returns:		Approval Request page for current Annual Pricing
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference submit(){
		PageReference pageRef = Page.APT_ApprovalRequest;
		pageRef.getParameters().put('id', annualPricing.Id);
		return pageRef;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to update Annual Pricing Items.
	* @param 		None
	* @Returns:		View page for Annual Pricing object
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference save(){
		List<Annual_Pricing_Item__c> annualPricingItemsToUpd = new List<Annual_Pricing_Item__c>();
		for(APT_AnnualPricingUtils.PricingGroupWrapper pg : pricingGroups){
			for(APT_AnnualPricingUtils.AnnualPricingItemWrapper api : pg.annualPricingItems){
				if(api.annualPricingItem.Final_Price__c != api.annualPricingItem.Standard_Price__c){
					api.annualPricingItem.Approval_Required__c = true;
				} else{
					api.annualPricingItem.Approval_Required__c = false;
				}
				annualPricingItemsToUpd.add(api.annualPricingItem);
			}
		}

		try{
			update annualPricingItemsToUpd;
		} catch(DmlException ex){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
			return null;
		}

		return new ApexPages.StandardController(annualPricing).view();
	}

	public PageReference cancel(){
		return new ApexPages.StandardController(annualPricing).view();
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to redirect to Generate Pricing Letter page.
	* @param 		None
	* @Returns:		Generate Pricing Letter page for current Annual Pricing
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference generate(){
		PageReference pageRef = Page.APT_GeneratePricingLetter;
		pageRef.getParameters().put('id', annualPricing.Id);
		pageRef.setRedirect(true);

		return pageRef;
	}

}