/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Pricing Deal Product
*/
@isTest
public class ZZTEST_F_PricingDealProduct {
	public enum PricingDealProductRecordType {DEFAULT_PRICING_DEAL_PRODUCT}

    private static ZZTEST_F_PricingDealProduct instance;

    private Integer productCounter;
   	
    private ZZTEST_F_PricingDealProduct() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_PricingDealProduct getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_PricingDealProduct();
        }
        return instance;
    }

    public Pricing_Deal_Product__c getProduct(PricingDealProductRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getDefaultPricingDealProduct(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Pricing_Deal_Product__c getInsertedProduct(PricingDealProductRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getInsertedDefaultPricingDealProduct(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Pricing_Deal_Product__c getDefaultPricingDealProduct(ZZTEST_DataContainer dataContainer) {
        Pricing_Deal_Product__c pricingDealProduct = new Pricing_Deal_Product__c();
        pricingDealProduct.Pricing_Deal_Product_Name__c = 'Test Pricing Deal Product';
        ZZTEST_F_PricingGroup pricingGroupFactory = ZZTEST_DataFactoryFacade.pricingGroup;
        Pricing_Group__c pricingGroup = pricingGroupFactory.getInsertedProduct(ZZTEST_F_PricingGroup.PricingGroupRecordType.DEFAULT_PRICING_GROUP, dataContainer);
        pricingDealProduct.Pricing_Group__c = pricingGroup.Id;
        pricingDealProduct.Product_Category__c = 'Test Product Category';
        pricingDealProduct.Product_Type__c = 'Test Product Type';
        pricingDealProduct.Report_Sequence__c = 0;

        return pricingDealProduct;
    }

    private Pricing_Deal_Product__c getInsertedDefaultPricingDealProduct(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Pricing_Deal_Product__c.getSObjectType()).isEmpty()) {
            Pricing_Deal_Product__c pricingDealProduct = this.getDefaultPricingDealProduct(dataContainer);
            insert pricingDealProduct;
            dataContainer.put(pricingDealProduct);
            return pricingDealProduct;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Pricing_Deal_Product__c.getSobjectType(), null).values()) {
                return (Pricing_Deal_Product__c) s;
            }
        }
        return null;
    }
}