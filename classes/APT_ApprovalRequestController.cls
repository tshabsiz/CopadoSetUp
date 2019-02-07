/**
* @Author		Marta Malinowska
* Company:		Deloitte
* @Description:	This class is used as a controller for APT_ApprovalRequest page.
* @Date:		09/2015
* @ConstructorParam:	stdController - Standard Controller for "Annual Pricing" object
* @TestClass:	ZZTEST_APT_ApprovalRequestController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*2018/09/14    Tonga Mabhedle     Updated approval functionality to use related user field
*------------------------------------------------------------*/
public with sharing class APT_ApprovalRequestController {
	private static String FIRST_LINE_APPROVERS_GROUP = 'Annual_Pricing_First_Line_Approvers';
	private Annual_Pricing__c annualPricing;
	public Boolean isSubmitted { get; set; }
	public List<APT_AnnualPricingUtils.PricingGroupWrapper> pricingGroups { get; set; }
	public Id selectedApprover { get; set; }
	public List<SelectOption> approvers { get; set; }
    public List<SelectOption> secondApprovers{get;set;}

	public APT_ApprovalRequestController(ApexPages.StandardController stdController) {
		annualPricing = (Annual_Pricing__c)stdController.getRecord();
		//isSubmitted = annualPricing.Approval_Status__c == APT_AnnualPricingUtils.STATUS_NOT_SUBMITTED ? false : true;
        isSubmitted = annualPricing.Approval_Status__c == APT_AnnualPricingUtils.STATUS_STANDARD_PRICING ? false : true;
		pricingGroups = APT_AnnualPricingUtils.getAnnualPricingItemsForApproval(annualPricing);

        
        //Tonga MM : Updated this table look up to no longer look at the group member but a seting tabling for approves
        Set<Id> approverIds = new Set<Id>();
        firstToSecondApprovers = new map<Id,Annual_Pricing_Approver__c>();
        List<Annual_Pricing_Approver__c> annualPricingApproverList = [SELECT Id, First_Line_Approver__c,Second_Line_Approver__r.Name,
                                                                      First_Line_Approver__r.Name,Second_Line_Approver__c 
                                                                  FROM Annual_Pricing_Approver__c 
                                                                  WHERE First_Line_Approver__r.IsActive = true];
		for(Annual_Pricing_Approver__c APP: annualPricingApproverList)
        {
            approverIds.add(APP.First_Line_Approver__r.Id);
            firstToSecondApprovers.put(APP.First_Line_Approver__c,APP);
        }
        
		approvers = new List<SelectOption>();
		approvers.add(new SelectOption('', '--None--'));
        if(!approverIds.isEmpty()){
            for(User u : getUserByIDs(approverIds)){
                approvers.add(new SelectOption(u.Id, u.Name));
            }
		}
        else
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.lblSecondApproverRequired));
        }
	}
    
    private Map<Id,Annual_Pricing_Approver__c> firstToSecondApprovers {get;set;}
    public string secondApprover{get;set;}
    public void setSecondApprover()
    {
        if(firstToSecondApprovers.containsKey(selectedApprover))
        {
            secondApprover = firstToSecondApprovers.get(selectedApprover).Second_Line_Approver__r.Name;
        }
        else
            {
                secondApprover = '';
            }
        
    }
    public static List<User> getUserByIDs(Set<id> ids)
    {
        return [SELECT Id, Name FROM User WHERE Id IN :ids ORDER BY Name];
    }

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to submit Annual Pricing Items for approval.
	* @param 		None
	* @Returns:		View page for Annual Pricing object
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference submit(){
		if(String.isBlank(selectedApprover)){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.errMsg_ApproverRequired));
			return null;
		} 
        
        if(String.isBlank(secondApprover))
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.lblSecondApproverRequired));
            return null;
        }
		//Id userId = UserInfo.getUserId();
		List<Annual_Pricing_Item__c> annualPricingItemsToUpd = new List<Annual_Pricing_Item__c>();
		for(APT_AnnualPricingUtils.PricingGroupWrapper pricingGroupWrapper : pricingGroups){
        	for(APT_AnnualPricingUtils.AnnualPricingItemWrapper annualPricingItemWrapper : pricingGroupWrapper.annualPricingItems){
        		annualPricingItemWrapper.annualPricingItem.First_Line_Approver__c = selectedApprover;
                annualPricingItemWrapper.annualPricingItem.Second_Line_Approver__c = firstToSecondApprovers.get(selectedApprover).Second_Line_Approver__c;
        		annualPricingItemsToUpd.add(annualPricingItemWrapper.annualPricingItem);
        	}
        }
        try{
        	update annualPricingItemsToUpd;
        } catch(DmlException ex){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        	return null;
		}

		List<Approval.ProcessSubmitRequest> requests = new List<Approval.ProcessSubmitRequest>();

		for(Annual_Pricing_Item__c api : [SELECT Id, Name, Approval_Status__c, Approval_Required__c, Request_Comments__c, 
											Pricing_Deal_Product__r.Pricing_Group__r.OwnerId
											FROM Annual_Pricing_Item__c 
											WHERE Annual_Pricing__c = :annualPricing.Id AND isLocked__c = false]){
			// Create an approval request for the Annual Pricing Items
			Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
			req.setComments(api.Request_Comments__c);
			req.setObjectId(api.Id);
			//req.setNextApproverIds(new Id[] {selectedApprover});
			requests.add(req);
		}
		
		// Submit the approval request for the Annual Pricing Items
		try{
			List<Approval.ProcessResult> results = Approval.process(requests);
			for(Approval.ProcessResult result : results){
				System.debug(result);
			}
		} catch(Exception ex){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
        	return null;
		}

		return new ApexPages.StandardController(annualPricing).view();
	}
}