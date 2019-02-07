/**
* @Author		Marta Malinowska
* Company:		Deloitte
* @Description:	This class is used as a help class for classes APT_ViewAnnualPricingController, APT_ApprovalRequestController 
*				and triggers APT_AnnualPricingItemTrigger, APT_StandardPricingTrigger.
* @Date:		09/2015
* @ConstructorParam:	None
* @TestClass:	ZZTEST_APT_PricingLetterController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class APT_AnnualPricingUtils {
	public static String STATUS_NOT_SUBMITTED = 'Not Submitted';
    public static String STATUS_STANDARD_PRICING = 'Standard Pricing';
	public static String STATUS_PENDING = 'Pending';
	public static String STATUS_APPROVED = 'Approved';
	public static String STATUS_REJECTED = 'Rejected';
	public static String STATUS_PENDING_FIRST_APPROVAL = 'Pending 1st line Approval';
	public static String STATUS_PENDING_SECOND_APPROVAL = 'Pending 2nd line Approval';
    private static final String EDIT = 'edit';

	public APT_AnnualPricingUtils() {}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to set Final Price by default to equal to Standard Price.
	* @param 		The list of Annual Pricing Items to process
	* @Returns:		None
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static void copyStandardPrice(List<Annual_Pricing_Item__c> annualPricingItems){
		Set<Id> standardPricingIds = new Set<Id>();
		for(Annual_Pricing_Item__c api : annualPricingItems){
			if(api.Standard_Pricing__c != null){
				standardPricingIds.add(api.Standard_Pricing__c);
			}
		}

		Map<Id, Standard_Pricing__c> mapStandardPricings = new Map<Id, Standard_Pricing__c>([SELECT Id, Price__c FROM Standard_Pricing__c WHERE Id IN :standardPricingIds]);
		for(Annual_Pricing_Item__c api : annualPricingItems){
			if(api.Standard_Pricing__c != null && mapStandardPricings.containsKey(api.Standard_Pricing__c)){
				api.Final_Price__c =  mapStandardPricings.get(api.Standard_Pricing__c).Price__c;
			}
		}
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to update the status of Annual Pricing.
	* @param 		The list of Annual Pricing Items before update and after update.
	* @Returns:		None
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static void updateApprovalStatus(Map<Id, Annual_Pricing_Item__c> newAnnualPricingItems, Map<Id, Annual_Pricing_Item__c> oldAnnualPricingItems){
		Set<Id> annualPricingIds = new Set<Id>();
		for(Id apiId : newAnnualPricingItems.keySet()){
			if(oldAnnualPricingItems.get(apiId).Approval_Status__c != newAnnualPricingItems.get(apiId).Approval_Status__c){
				annualPricingIds.add(newAnnualPricingItems.get(apiId).Annual_Pricing__c);
			}
		}

		List<Annual_Pricing__c> annualPricingToUpd = new List<Annual_Pricing__c>();
		for(Annual_Pricing__c ap : [SELECT Id, Approval_Status__c, (SELECT Id, Approval_Status__c FROM Annual_Pricing_Items__r)
									FROM Annual_Pricing__c WHERE Id IN :annualPricingIds]){
			Boolean isPending = false;
			Boolean isApproved = true;
			Boolean isRejected = false;
			for(Annual_Pricing_Item__c api : ap.Annual_Pricing_Items__r){
				if(api.Approval_Status__c != STATUS_APPROVED){
					isApproved = false;
					if(api.Approval_Status__c == STATUS_PENDING_FIRST_APPROVAL || api.Approval_Status__c == STATUS_PENDING_SECOND_APPROVAL){
						isPending = true;
					} else if(api.Approval_Status__c == STATUS_REJECTED){
						isPending = false;
						isRejected = true;
						break;
					} 
				}
			}
			if(isPending){
				ap.Approval_Status__c = STATUS_PENDING;
				annualPricingToUpd.add(ap);
			}
			if(isApproved){
				ap.Approval_Status__c = STATUS_APPROVED;
				annualPricingToUpd.add(ap);
			}
			if(isRejected){
				ap.Approval_Status__c = STATUS_REJECTED;
				annualPricingToUpd.add(ap);
			} 
		}

		update annualPricingToUpd;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to check if Pricing Template is locked and add error message for Standard Pricings.
	* @param 		The list of Standard Pricings.
	* @Returns:		None
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static void validateStandardPricingBeforeInsert(List<Standard_Pricing__c> standardPricings){
		Map<Id, Pricing_Template__c> mapPricingTemplates = getPricingTemplatesMap(standardPricings);
		for(Standard_Pricing__c stdPricing : standardPricings){
			if(mapPricingTemplates.containsKey(stdPricing.Pricing_Template__c) && mapPricingTemplates.get(stdPricing.Pricing_Template__c).Locked__c == true){
				stdPricing.addError(Label.errMsg_NotAllowedToAddStandardPricing);
			}
		}
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to check if Pricing Template is locked and add error message for Standard Pricings to prevent update.
	* @param 		The list of Standard Pricings.
	* @Returns:		None
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static void validateStandardPricingBeforeUpdate(List<Standard_Pricing__c> standardPricings){
		Map<Id, Pricing_Template__c> mapPricingTemplates = getPricingTemplatesMap(standardPricings);
		for(Standard_Pricing__c stdPricing : standardPricings){
			if(mapPricingTemplates.containsKey(stdPricing.Pricing_Template__c) && mapPricingTemplates.get(stdPricing.Pricing_Template__c).Locked__c == true){
				stdPricing.addError(Label.errMsg_NotAllowedToChangeStandardPricing);
			}
		}
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to check if Pricing Template is locked and add error message for Standard Pricings to prevent delete.
	* @param 		The list of Standard Pricings.
	* @Returns:		None
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static void validateStandardPricingBeforeDelete(List<Standard_Pricing__c> standardPricings){
		Map<Id, Pricing_Template__c> mapPricingTemplates = getPricingTemplatesMap(standardPricings);
		for(Standard_Pricing__c stdPricing : standardPricings){
			if(mapPricingTemplates.containsKey(stdPricing.Pricing_Template__c) && mapPricingTemplates.get(stdPricing.Pricing_Template__c).Locked__c == true){
				stdPricing.addError(Label.errMsg_NotAllowedToDeleteStandardPricing);
			}
		}
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to query Pricing Templates.
	* @param 		The list of Standard Pricings.
	* @Returns:		Map of Pricing Templates
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static Map<Id, Pricing_Template__c> getPricingTemplatesMap(List<Standard_Pricing__c> standardPricings){
		Set<Id> pricingTemplateIds = new Set<Id>();
		for(Standard_Pricing__c stdPricing : standardPricings){
			pricingTemplateIds.add(stdPricing.Pricing_Template__c);
		}
		return new Map<Id, Pricing_Template__c>([SELECT Id, Locked__c FROM Pricing_Template__c WHERE Id IN :pricingTemplateIds]);
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to create a list of Annual Pricing Items that will be displayed on View Annual Pricing page.
	* @param 		The list of Annual Pricing.
	* @Returns:		List of Pricing Group Wrapper that includes all Related Annual Pricing Items.
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static List<PricingGroupWrapper> getAnnualPricingItemsGroupedByPricingGroups(Annual_Pricing__c annualPricing){
		Map<Id, Annual_Pricing_Item__c> mapAnnualPricingItems = new Map<Id, Annual_Pricing_Item__c>();
		Map<Id, Standard_Pricing__c> mapStandardPricings = new Map<Id, Standard_Pricing__c>();
		Map<Id, Pricing_Deal_Product__c> mapPricingDealProducts = new Map<Id, Pricing_Deal_Product__c>();

		Set<Id> pricingGroupIds = new Set<Id>();
		Set<Id> pricingDealProductIds = new Set<Id>();
		for(Annual_Pricing_Item__c annualPricingItem : [SELECT Id, Name, Pricing_Deal_Product__r.Pricing_Group__c, Pricing_Deal_Product__c, 
														Standard_Price__c, Standard_VAT_Inclusive__c, Final_Price__c, 
														Approval_Required__c, Status_Icon__c, isLocked__c
														FROM Annual_Pricing_Item__c  
														WHERE Annual_Pricing__c = :annualPricing.Id]){
			mapAnnualPricingItems.put(annualPricingItem.Pricing_Deal_Product__c, annualPricingItem);
			pricingGroupIds.add(annualPricingItem.Pricing_Deal_Product__r.Pricing_Group__c);
			pricingDealProductIds.add(annualPricingItem.Pricing_Deal_Product__c);
		}

		List<PricingGroupWrapper> pricingGroups = new List<PricingGroupWrapper>();
		for(Pricing_Group__c pricingGroup : [SELECT Id, Name, OwnerId,
																(SELECT Id, Pricing_Deal_Product_Name__c, Product_Category__c, Product_Type__c
																	FROM Pricing_Deal_Products__r WHERE Id IN :pricingDealProductIds
																	ORDER BY Report_Sequence__c) 
															FROM Pricing_Group__c WHERE Id IN :pricingGroupIds 
															ORDER BY Report_Sequence__c]){
			List<AnnualPricingItemWrapper> annualPricingItems = new List<AnnualPricingItemWrapper>();
			for(Pricing_Deal_Product__c pricingDealProduct : pricingGroup.Pricing_Deal_Products__r){
				Annual_Pricing_Item__c annualPricingItem = mapAnnualPricingItems.get(pricingDealProduct.Id);
				annualPricingItems.add(new AnnualPricingItemWrapper(pricingDealProduct, annualPricingItem));
			}
			pricingGroups.add(new PricingGroupWrapper(pricingGroup, annualPricingItems));
		}

		return pricingGroups;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to create a list of Annual Pricing Items that will be displayed on Approval Request page.
	* @param 		The list of Annual Pricing.
	* @Returns:		List of Pricing Group Wrapper that includes list of Annual Pricing Items required approval.
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static List<PricingGroupWrapper> getAnnualPricingItemsForApproval(Annual_Pricing__c annualPricing){
		Map<Id, Annual_Pricing_Item__c> mapAnnualPricingItems = new Map<Id, Annual_Pricing_Item__c>();
		Map<Id, Standard_Pricing__c> mapStandardPricings = new Map<Id, Standard_Pricing__c>();
		Map<Id, Pricing_Deal_Product__c> mapPricingDealProducts = new Map<Id, Pricing_Deal_Product__c>();

		Set<Id> pricingGroupIds = new Set<Id>();
		Set<Id> pricingDealProductIds = new Set<Id>();
		for(Annual_Pricing_Item__c annualPricingItem : [SELECT Id, Pricing_Deal_Product__r.Pricing_Group__c, Pricing_Deal_Product__c, 
														Standard_Price__c, Standard_VAT_Inclusive__c, Final_Price__c, Request_Comments__c,
														Approval_Required__c, Status_Icon__c, isLocked__c
														FROM Annual_Pricing_Item__c  
														WHERE Annual_Pricing__c = :annualPricing.Id 
														AND Approval_Required__c = true AND isLocked__c = false]){
			mapAnnualPricingItems.put(annualPricingItem.Pricing_Deal_Product__c, annualPricingItem);
			pricingGroupIds.add(annualPricingItem.Pricing_Deal_Product__r.Pricing_Group__c);
			pricingDealProductIds.add(annualPricingItem.Pricing_Deal_Product__c);
		}

		List<PricingGroupWrapper> pricingGroups = new List<PricingGroupWrapper>();
		for(Pricing_Group__c pricingGroup : [SELECT Id, Name, OwnerId,
																(SELECT Id, Pricing_Deal_Product_Name__c, Product_Category__c, Product_Type__c
																	FROM Pricing_Deal_Products__r WHERE Id IN :pricingDealProductIds
																	ORDER BY Report_Sequence__c) 
															FROM Pricing_Group__c WHERE Id IN :pricingGroupIds 
															ORDER BY Report_Sequence__c]){
			List<AnnualPricingItemWrapper> annualPricingItems = new List<AnnualPricingItemWrapper>();
			for(Pricing_Deal_Product__c pricingDealProduct : pricingGroup.Pricing_Deal_Products__r){
				Annual_Pricing_Item__c annualPricingItem = mapAnnualPricingItems.get(pricingDealProduct.Id);
				annualPricingItems.add(new AnnualPricingItemWrapper(pricingDealProduct, annualPricingItem));
			}
			pricingGroups.add(new PricingGroupWrapper(pricingGroup, annualPricingItems));
		}

		return pricingGroups;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to check if approval is required 
	*				and determines if the button "Submit for Approval" will be displayed on View Annual Pricing page.
	* @param 		The list of Pricing Group Wrapper that include Annual Pricing Items.
	* @Returns:		true if at least one of Annual Pricing Items require approval
	*				false if there is no Annual Pricing Item that requires approval
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public static Boolean getIsApprovalRequired(List<PricingGroupWrapper> pricingGroups){
		Boolean isApprovalRequired = false;
		for(PricingGroupWrapper pg : pricingGroups){
			for(AnnualPricingItemWrapper api : pg.annualPricingItems){
				if(api.annualPricingItem.Approval_Required__c == true){
					isApprovalRequired = true;
					break;
				}
			}
		}

		return isApprovalRequired;
	}

	public class PricingGroupWrapper {
		public Pricing_Group__c pricingGroup { get; set; }
		public List<AnnualPricingItemWrapper> annualPricingItems { get; set; }

		public PricingGroupWrapper(Pricing_Group__c pricingGroup, List<AnnualPricingItemWrapper> annualPricingItems){
			this.pricingGroup = pricingGroup;
			this.annualPricingItems = annualPricingItems;
		}
	}

	public class AnnualPricingItemWrapper {
		public Pricing_Deal_Product__c pricingDealProduct { get; set; }
		public Annual_Pricing_Item__c annualPricingItem { get; set; }

		public AnnualPricingItemWrapper(Pricing_Deal_Product__c pricingDealProduct, Annual_Pricing_Item__c annualPricingItem){
			this.pricingDealProduct = pricingDealProduct;
			this.annualPricingItem = annualPricingItem;
		}
	}
    
    
    public static Annual_Pricing__Share createSharingInstance(String planId, String userId) {
        
        Annual_Pricing__Share shRec = new Annual_Pricing__Share();
        shRec.AccessLevel = EDIT;
        shRec.RowCause = Schema.Annual_Pricing__Share.RowCause.Manual;
        
        try {
            shRec.ParentId = planId;
            shRec.UserOrGroupId = userId;
        } catch (StringException e) {
            system.debug(e);
            return null;
        }
        
        return shRec;
    }
}