/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Pricing Group
*/
@isTest
public class ZZTEST_F_PricingGroup {
	public enum PricingGroupRecordType {DEFAULT_PRICING_GROUP}

    private static ZZTEST_F_PricingGroup instance;

    private Integer productCounter;
   	
    private ZZTEST_F_PricingGroup() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_PricingGroup getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_PricingGroup();
        }
        return instance;
    }

    public Pricing_Group__c getProduct(PricingGroupRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getDefaultPricingGroup(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Pricing_Group__c getInsertedProduct(PricingGroupRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getInsertedDefaultPricingGroup(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Pricing_Group__c getDefaultPricingGroup(ZZTEST_DataContainer dataContainer) {
        Pricing_Group__c pricingGroup = new Pricing_Group__c();
        pricingGroup.Name = 'Test Pricing Group';
        pricingGroup.VAT_Inclusive__c = true;
        pricingGroup.Letter_Format__c = 'Comparative Incl VAT';
        pricingGroup.Report_Sequence__c = 0;

        return pricingGroup;
    }

    private Pricing_Group__c getInsertedDefaultPricingGroup(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Pricing_Group__c.getSObjectType()).isEmpty()) {
            Pricing_Group__c pricingGroup = this.getDefaultPricingGroup(dataContainer);
            insert pricingGroup;
            dataContainer.put(pricingGroup);
            return pricingGroup;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Pricing_Group__c.getSobjectType(), null).values()) {
                return (Pricing_Group__c) s;
            }
        }
        return null;
    }
}