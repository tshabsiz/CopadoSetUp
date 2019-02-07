/**
* @Author		Marta Malinowska
* Company:		Deloitte
* @Description:	This class is used as a controller for APT_PendingApprovalInbox page.
* @Date:		09/2015
* @ConstructorParam:	None
* @TestClass:	ZZTEST_APT_PendingApprovalInboxCtr
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class APT_PendingApprovalInboxController {
	private Map<Id, AnnualPricingWrapper> annualPricingsMap;
	public List<AnnualPricingWrapper> annualPricings { get; set; }
	public static String APPROVE = 'Approve';
	public static String REJECT = 'Reject';
	//public List<SelectOption> actions { get; set; }
	public Boolean isSelected { get; set; }
	public Boolean isPendingApproval { get; set; }

	public APT_PendingApprovalInboxController() {
		isSelected = false;
		Id currentUserId = UserInfo.getUserId();
		Set<Id> annualPricingIds = new Set<Id>();
		Set<Id> annualPricingItemIds = new Set<Id>();

		Map<Id, Id> mapWorkItemIds = new Map<Id, Id>();
		for(ProcessInstance processInstance : [SELECT TargetObjectId, 
									(SELECT Id, Actor.Id, Actor.Name FROM WorkItems WHERE Actor.Id = :currentUserId)
                                    FROM ProcessInstance
                                    WHERE TargetObject.Type = 'Annual_Pricing_Item__c' AND Status = 'Pending']){
			for(ProcessInstanceWorkItem workItem : processInstance.WorkItems){
				mapWorkItemIds.put(workItem.Id, processInstance.TargetObjectId);
				annualPricingItemIds.add(processInstance.TargetObjectId);
			}
		}
		if(mapWorkItemIds.isEmpty()){
			isPendingApproval = false;
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, Label.infMsg_EmptyPendingApprovalInbox));
		} else{
			isPendingApproval = true;
		}
		
		Map<Id, Annual_Pricing_Item__c> mapAnnualPricingItems = new Map<Id, Annual_Pricing_Item__c>();
		for(Annual_Pricing_Item__c annualPricingItem : [SELECT Id, Name, Annual_Pricing__c, Pricing_Group__c, Pricing_Deal_Product_Name__c, 
															Standard_Price__c, Standard_VAT_Inclusive__c, Final_Price__c,
															Request_Comments__c, Approval_Status__c 
                                                        
															FROM Annual_Pricing_Item__c WHERE Id IN :annualPricingItemIds
															ORDER BY Pricing_Deal_Product__r.Pricing_Group__r.Report_Sequence__c, Pricing_Deal_Product__r.Report_Sequence__c]){
			mapAnnualPricingItems.put(annualPricingItem.Id, annualPricingItem);
			annualPricingIds.add(annualPricingItem.Annual_Pricing__c);
		}
		Map<Id, Annual_Pricing__c> mapAnnualPricings = new Map<Id, Annual_Pricing__c>([SELECT Id, Name, Organisation__r.Name, Pricing_Template__r.Year__c
																						FROM Annual_Pricing__c WHERE Id IN :annualPricingIds]);

		
		Map<Id, List<ProcessInstanceWorkItemWrapper>> mapWorkItems = new Map<Id, List<ProcessInstanceWorkItemWrapper>>();
		for(Id workItemId : mapWorkItemIds.keySet()){
			ProcessInstanceWorkItemWrapper workItem = new ProcessInstanceWorkItemWrapper(workItemId, mapAnnualPricingItems.get(mapWorkItemIds.get(workItemId)));
			if(mapWorkItems.containsKey(workItem.annualPricingItem.Annual_Pricing__c)){
				mapWorkItems.get(workItem.annualPricingItem.Annual_Pricing__c).add(workItem);
			} else{
				mapWorkItems.put(workItem.annualPricingItem.Annual_Pricing__c, new List<ProcessInstanceWorkItemWrapper>{workItem});
			}
		}

		annualPricingsMap = new Map<Id, AnnualPricingWrapper>();
		for(Id annualPricingId : mapWorkItems.keySet()){
			annualPricingsMap.put(annualPricingId, new AnnualPricingWrapper(mapAnnualPricings.get(annualPricingId), mapWorkItems.get(annualPricingId)));
		}
		annualPricings = annualPricingsMap.values();
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to Approve/Reject all selected Annual Pricing Items.
	* @param 		None
	* @Returns:		Pending Approval Inbox page
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public PageReference submit(){
		//Id userId = UserInfo.getUserId();
		List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest>();

		for(AnnualPricingWrapper apw : annualPricings){
			for(ProcessInstanceWorkItemWrapper wi : apw.workItems){
				if(wi.isSelected){
					if(String.isBlank(wi.action)){
						Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.errMsg_ApproveRejectRequired+wi.annualPricingItem.Name));
						return null;
					} else{
						// Create an approval request for the Annual Pricing Items
						Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
						req.setComments(wi.comments);
						req.setAction(wi.action);
						req.setWorkitemId(wi.workItemId);
						requests.add(req);
					}
				}
			}
		}

		if(requests.isEmpty()){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, Label.errMsg_AtLeastOneAnnualPricingItemRequired));
        	return null;
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

		PageReference pageRef = Page.APT_PendingApprovalInbox;
		pageRef.setRedirect(true);
		return pageRef;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to get a list of possible approval actions.
	* @param 		None
	* @Returns:		List of Select Options: Approve, Refect
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public List<SelectOption> getActions() {
		List<SelectOption> options = new List<SelectOption>();
		//options.add(new SelectOption('','--None--'));
		options.add(new SelectOption(APPROVE, APPROVE));
		options.add(new SelectOption(REJECT, REJECT));
		return options;
	}
	
	public class AnnualPricingWrapper{
		public Boolean isSelected { get; set; }
		public Annual_Pricing__c annualPricing { get; set; }
		public List<ProcessInstanceWorkItemWrapper> workItems { get; set; }

		AnnualPricingWrapper(Annual_Pricing__c annualPricing, List<ProcessInstanceWorkItemWrapper> workItems){
			this.isSelected = false;
			this.annualPricing = annualPricing;
			this.workItems = workItems;
		}
	}

	public class ProcessInstanceWorkItemWrapper{
		public Boolean isSelected { get; set; }
		public Id workItemId { get; set; }
		public Annual_Pricing_Item__c annualPricingItem { get; set; }
		public String action { get; set; }
		public String comments { get; set; }

		public ProcessInstanceWorkItemWrapper(Id workItemId, Annual_Pricing_Item__c annualPricingItem){
			this.isSelected = false;
			this.workItemId = workItemId;
			this.annualPricingItem = annualPricingItem;
			this.action = APPROVE;
		}
	}

}