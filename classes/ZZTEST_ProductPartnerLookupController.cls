/**
* @Author:        Dino Scarcella
* @Company:       Absa Capital
* @Description:   Unit Tests for ProductPartnerLookup on AddProductToOpportunity Page
*                 Tests executed:
*                 1 - testProductPartnerLookup()
*                   Tests the product partner lookup on AddProductToOpportunity Page
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 2018-07-04  Dino Scarcella	 Added Country Support to testProductPartnerLookup test
* ------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ProductPartnerLookupController {
	public static testMethod void testProductPartnerLookup() {
        //Create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
            Product2 sampleProduct = productFactory.getProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, dataContainer);
			INSERT sampleProduct;
            Product_Level_2__c prdLevel2 = new Product_Level_2__c(Name='Debt Finance', Product__c=sampleProduct.Id);
            INSERT prdLevel2;
            
            Test.startTest();

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			OpportunityLineItem oli1 = oliFactory.getProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, dataContainer);
			opp.Opportunity_Country__c = 'South Africa';
            update opp;
            
            PageReference ProductPartnerLookup = Page.ProductPartnerLookup;
            Test.setCurrentPage(ProductPartnerLookup);
    
            ApexPages.currentPage().getParameters().put('lksrch', '');
            ApexPages.currentPage().getParameters().put('ExcludeProductPartner', 'true');
            ApexPages.currentPage().getParameters().put('txt', 'j_id0%3AtheForm%3AaddProductToOpportunity%3AProductPartnerInputF&');
            ApexPages.currentPage().getParameters().put('frm', 'j_id0%3AtheForm');
            ApexPages.currentPage().getParameters().put('OpportunityId', opp.Id);
            ApexPages.currentPage().getParameters().put('ProductLevel2', prdLevel2.Id);
            ProductPartnerLookupController pplc = new ProductPartnerLookupController();
            pplc.search();
            
            System.assertEquals(true, pplc.results.size() > 0);
            System.assertEquals('j_id0%3AtheForm%3AaddProductToOpportunity%3AProductPartnerInputF&', pplc.getTextBox());
            System.assertEquals('j_id0%3AtheForm', pplc.getFormTag());
            
            Test.stopTest();
        }
    }
}