/**
* @Author		Marta Malinowska
* Company:		Deloitte
* @Description:	This class is used as a controller for APT_PricingLetter and APT_PricingLetterPdf pages.
* @Date:		09/2015
* @ConstructorParam:	stdController - Standard Controller for "Annual Pricing" object
* @TestClass:	ZZTEST_APT_PricingLetterController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class APT_PricingLetterController {
	private static String DOC_HEADER_LEFT  = 'Pricing_Letter_Header_Left';
	private static String DOC_HEADER_RIGHT  = 'Pricing_Letter_Header_Right';
	private static String DOC_FOOTER  = 'Pricing_Letter_Footer';
	private Map<String, Id> mapDocuments;
	public String headerLeftUrl { get; set; }
	public String headerRightUrl { get; set; }
	public String footerUrl { get; set; }
	private Id annualPricingId;
	private Annual_Pricing__c annualPricing;
	private Set<Id> childIds;
	public Pricing_Template__c pricingTemplate { get; set; }
	public List<Account> groupEntities { get; set; }
	public List<PricingGroupWrapper> pricingGroups { get; set; }
	public String currentDate { get; set; }

	public APT_PricingLetterController(ApexPages.StandardController stdController) {
		currentDate = DateTime.now().format('dd MMMM yyyy');

		mapDocuments = new Map<String, Id>();
		for(Document doc : [SELECT Id, DeveloperName FROM Document WHERE DeveloperName = :DOC_HEADER_LEFT OR DeveloperName = :DOC_HEADER_RIGHT OR DeveloperName = :DOC_FOOTER]){
			mapDocuments.put(doc.DeveloperName, doc.Id);
		}
		String baseURL = URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.ImageServer';
		String organizationId = UserInfo.getOrganizationId();
		headerLeftUrl = mapDocuments.containsKey(DOC_HEADER_LEFT) ? baseURL+'?id='+mapDocuments.get(DOC_HEADER_LEFT)+'&oid='+organizationId : '';
		headerRightUrl = mapDocuments.containsKey(DOC_HEADER_RIGHT) ? baseURL+'?id='+mapDocuments.get(DOC_HEADER_RIGHT)+'&oid='+organizationId : '';
		footerUrl = mapDocuments.containsKey(DOC_FOOTER) ? baseURL+'?id='+mapDocuments.get(DOC_FOOTER)+'&oid='+organizationId : '';

		annualPricingId = ApexPages.currentPage().getParameters().get('id');
		annualPricing = [SELECT Id, Name, Pricing_Template__c, Pricing_Template__r.Type__c, Organisation__c, Year__c, Previous_Year__c, 
						Name_of_group_of_companies__c, Name_of_holding_company__c
						FROM Annual_Pricing__c WHERE Id = :annualPricingId];
		
		List<Pricing_Template__c> pricingTemplates = [SELECT Id, Name, Address__c, Phone_Fax__c, Website__c, Title__c, Section_1__c, Section_2__c, On_Behalf__c,
																	Title_for_Group_Entities__c, Title_for_Pricing_Groups__c, Section_3__c, Legal_Info__c 
																	FROM Pricing_Template__c WHERE Id = :annualPricing.Pricing_Template__c];
		if(pricingTemplates.isEmpty()){
			System.debug('There is no Pricing Template for year ');
		} else{
			pricingTemplate = pricingTemplates[0];
		}
		//Replace placeholders in Section 3
		if(String.isNotBlank(pricingTemplate.Section_3__c)){
			String nameOfGroupOfCompaniesRegex = '(?i)\\[\\s*'+Annual_Pricing__c.Name_of_group_of_companies__c.getDescribe().getLabel()+'\\s*\\]';
			String nameOfHoldingCompanyRegex = '(?i)\\[\\s*'+Annual_Pricing__c.Name_of_holding_company__c.getDescribe().getLabel()+'\\s*\\]';
			Pattern nameOfGroupOfCompaniesPattern = Pattern.compile(nameOfGroupOfCompaniesRegex);
			Pattern nameOfHoldingCompanyPattern = Pattern.compile(nameOfHoldingCompanyRegex);
			Matcher nameOfGroupOfCompaniesMatcher = nameOfGroupOfCompaniesPattern.matcher(pricingTemplate.Section_3__c);
			Matcher nameOfHoldingCompanyMatcher = nameOfHoldingCompanyPattern.matcher(pricingTemplate.Section_3__c);
			if(nameOfGroupOfCompaniesMatcher.find()) {
				pricingTemplate.Section_3__c = pricingTemplate.Section_3__c.replaceAll(nameOfGroupOfCompaniesRegex, annualPricing.Name_of_group_of_companies__c);
			}
			if(nameOfHoldingCompanyMatcher.find()) {
				pricingTemplate.Section_3__c = pricingTemplate.Section_3__c.replaceAll(nameOfHoldingCompanyRegex, annualPricing.Name_of_holding_company__c);
			}
		}

		Map<Id, Account> currentOrganisation = new Map<Id, Account>([SELECT Id, Name FROM Account WHERE Id = :annualPricing.Organisation__c]);
		childIds = new Set<Id>();
		childIds.addAll(currentOrganisation.keySet());
		getChildrens(currentOrganisation.keySet());
		groupEntities = [SELECT Id, Name FROM Account WHERE Id IN :childIds ORDER BY Name];

		//pricingGroups = APT_AnnualPricingUtils.getAnnualPricingItemsGroupedByPricingGroups(annualPricing);
		pricingGroups = getAnnualPricingItems();
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to query all Annual Pricing Items related to current Annual Pricing, grouped by Pricing Group, Product Category and Product Type
	* @param 		None
	* @Returns:		List of Pricing Group Wrapper
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public List<PricingGroupWrapper> getAnnualPricingItems(){
		Map<Id, Annual_Pricing_Item__c> mapPreviousAnnualPricingItems = getPreviousAnnualPricingItems();
		Map<Id, PricingGroupWrapper> mapPricingGroups = new Map<Id, PricingGroupWrapper>();
		PricingGroupWrapper pricingGroup;
		ProductCategoryWrapper productCategory;
		ProductTypeWrapper productType;
		AnnualPricingItemWrapper annualPricingItem;
		for(Annual_Pricing_Item__c api : [SELECT Id, Name, Pricing_Deal_Product__r.Pricing_Group__c, Product_Category__c, 
											Product_Type__c, Pricing_Deal_Product__c, Pricing_Deal_Product_Name__c, Final_Price__c,
											VAT_Amount__c, Final_Price_VAT_Incl__c
											FROM Annual_Pricing_Item__c WHERE Annual_Pricing__c = :annualPricing.Id
											ORDER BY Pricing_Deal_Product__r.Pricing_Group__r.Report_Sequence__c, Pricing_Deal_Product__r.Report_Sequence__c]){
			Annual_Pricing_Item__c previousAnnualPricingItem = mapPreviousAnnualPricingItems.get(api.Pricing_Deal_Product__c);
			if(mapPricingGroups.containsKey(api.Pricing_Deal_Product__r.Pricing_Group__c)){
				pricingGroup = mapPricingGroups.get(api.Pricing_Deal_Product__r.Pricing_Group__c);
				
			} else{
				pricingGroup =  new PricingGroupWrapper(api.Pricing_Deal_Product__r.Pricing_Group__c);
				mapPricingGroups.put(pricingGroup.Id, pricingGroup);
			}
			productCategory = pricingGroup.getProductCategory(api.Product_Category__c);
			productType = productCategory.getProductType(api.Product_Type__c);
			annualPricingItem = new AnnualPricingItemWrapper(api, previousAnnualPricingItem, productType.annualPricingItems.isEmpty());
			productType.annualPricingItems.add(annualPricingItem);

			productType.rowspan++;
			productCategory.rowspan++;
			pricingGroup.rowspan++;
		}

		for(Pricing_Group__c pg : [SELECT Id, Name, VAT_Inclusive__c, Compare_To_Previous_Year_Prices__c, Compare_Excl_Incl_VAT_Prices__c
											FROM Pricing_Group__c WHERE Id IN :mapPricingGroups.keySet()]){
			mapPricingGroups.get(pg.Id).record = pg;
		}
		return mapPricingGroups.values();
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to query all Annual Pricing Items related to previous Annual Pricing
	* @param 		None
	* @Returns:		Map of Annual Pricing Items related to previous Annual Pricing
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public Map<Id, Annual_Pricing_Item__c> getPreviousAnnualPricingItems(){
		Map<Id, Annual_Pricing_Item__c> mapPreviousAnnualPricingItems = new Map<Id, Annual_Pricing_Item__c>();
		Annual_Pricing__c previousAnnualPricing;
		try{
			previousAnnualPricing = [SELECT Id, Name FROM Annual_Pricing__c 
										WHERE Organisation__c = :annualPricing.Organisation__c 
										AND Pricing_Template__r.Type__c = :annualPricing.Pricing_Template__r.Type__c
										AND Year__c = :annualPricing.Previous_Year__c
										//AND (Approval_Status__c = :APT_AnnualPricingUtils.STATUS_NOT_SUBMITTED OR Approval_Status__c = :APT_AnnualPricingUtils.STATUS_APPROVED)
                                        AND (Approval_Status__c = :APT_AnnualPricingUtils.STATUS_STANDARD_PRICING  OR Approval_Status__c = :APT_AnnualPricingUtils.STATUS_APPROVED)
										ORDER BY CreatedDate DESC LIMIT 1];
		} catch(QueryException ex){
			return mapPreviousAnnualPricingItems;
		}
		
		for(Annual_Pricing_Item__c annualPricingItem : [SELECT Id, Name, Pricing_Deal_Product__c, Final_Price__c FROM Annual_Pricing_Item__c
														WHERE Annual_Pricing__c = :previousAnnualPricing.Id]){
			mapPreviousAnnualPricingItems.put(annualPricingItem.Pricing_Deal_Product__c, annualPricingItem);
		}

		return mapPreviousAnnualPricingItems;
	}

	/**
	* @Author:		Marta Malinowska
	* @Company:		Deloitte
	* @Description:	This method is used to query all SDS related Organisations
	* @param 		Set of Account Ids
	* @Returns:		None
	* History
	* <Date>      <Authors Name>     <Brief Description of Change>
	*------------------------------------------------------------*/
	public void getChildrens(Set<Id> accountIds){
    	Set<Id> childrens = new Set<Id>();
		for(Hierarchy__c h : [SELECT Child__c FROM Hierarchy__c WHERE Hierarchy_Type__c = 'SDS' AND Parent__c IN :accountIds]){
			childrens.add(h.Child__c);
		}
		if(!childrens.isEmpty()){
			childIds.addAll(childrens);
			getChildrens(childrens);
		}
	}

	public class PricingGroupWrapper {  
		public Id id { get; set; }
		public Pricing_Group__c record { get; set; }
		public List<ProductCategoryWrapper> productCategories { get; set; }
		public Integer rowspan { get; set; }

		public PricingGroupWrapper(Id id){
			this.id = id;
			this.productCategories = new List<ProductCategoryWrapper>();
			this.rowspan = 0;
		}

		public ProductCategoryWrapper getProductCategory(String productCategoryName){
			for(ProductCategoryWrapper productCategory : this.productCategories){
				if(productCategory.Name == productCategoryName){
					return productCategory;
				}
			}
			ProductCategoryWrapper productCategory = new ProductCategoryWrapper(productCategoryName, this.productCategories.isEmpty());
			this.productCategories.add(productCategory);
			return productCategory;
		}
	}

	public class ProductCategoryWrapper {
		public String Name { get; set; }
		public Boolean isFirst { get; set; }
		public List<ProductTypeWrapper> productTypes { get; set; }
		public Integer rowspan { get; set; }

		public ProductCategoryWrapper(String Name, Boolean isFirst){
			this.Name = Name;
			this.isFirst = isFirst;
			this.productTypes = new List<ProductTypeWrapper>();
			this.rowspan = 0;
		}

		public ProductTypeWrapper getProductType(String productTypeName){
			for(ProductTypeWrapper productType : this.productTypes){
				if(productType.Name == productTypeName){
					return productType;
				}
			}
			ProductTypeWrapper productType = new ProductTypeWrapper(productTypeName, this.productTypes.isEmpty());
			this.productTypes.add(productType);
			return productType;
		}
	}

	public class ProductTypeWrapper {
		public String Name { get; set; }
		public Boolean isFirst { get; set; }
		public List<AnnualPricingItemWrapper> annualPricingItems { get; set; }
		public Integer rowspan { get; set; }

		public ProductTypeWrapper(String Name, Boolean isFirst){
			this.Name = Name;
			this.isFirst = isFirst;
			this.annualPricingItems = new List<AnnualPricingItemWrapper>();
			this.rowspan = 0;
		}
	}

	public class AnnualPricingItemWrapper {
		public Annual_Pricing_Item__c record { get; set; }
		public Annual_Pricing_Item__c previousRecord { get; set; }
		public Boolean isFirst { get; set; }

		public AnnualPricingItemWrapper(Annual_Pricing_Item__c record, Annual_Pricing_Item__c previousRecord, Boolean isFirst){
			this.record = record;
			this.previousRecord = previousRecord;
			this.isFirst = isFirst;
		}
	}
}