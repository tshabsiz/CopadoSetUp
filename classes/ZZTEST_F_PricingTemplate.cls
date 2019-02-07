/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Pricing Template
*/
@isTest
public class ZZTEST_F_PricingTemplate {
	public enum PricingTemplateRecordType {DEFAULT_PRICING_TEMPLATE}

    private static ZZTEST_F_PricingTemplate instance;

    private Integer productCounter;
   	
    private ZZTEST_F_PricingTemplate() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_PricingTemplate getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_PricingTemplate();
        }
        return instance;
    }

    public Pricing_Template__c getProduct(PricingTemplateRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getDefaultPricingTemplate(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Pricing_Template__c getInsertedProduct(PricingTemplateRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getInsertedDefaultPricingTemplate(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Pricing_Template__c getDefaultPricingTemplate(ZZTEST_DataContainer dataContainer) {
        Pricing_Template__c pricingTemplate = new Pricing_Template__c();
        pricingTemplate.Year__c = '2015';
        pricingTemplate.Type__c = 'Standard';
        pricingTemplate.Locked__c = false;
        pricingTemplate.Address__c = 'Test Address';
        pricingTemplate.Phone_Fax__c = 'Test Phone';
        pricingTemplate.Website__c = 'Test Website';
        pricingTemplate.Title__c = 'Test Title';
        pricingTemplate.Section_1__c = 'Test Section 1';
        pricingTemplate.Section_2__c = 'Test Section 2';
        pricingTemplate.On_Behalf__c = 'On Behalf';
        pricingTemplate.Title_for_Group_Entities__c = '';
        pricingTemplate.Title_for_Pricing_Groups__c = '';
        pricingTemplate.Section_3__c = 'Test Section 3';
        pricingTemplate.Legal_Info__c = 'Legal Info';
        return pricingTemplate;
    }

    private Pricing_Template__c getInsertedDefaultPricingTemplate(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Pricing_Template__c.getSObjectType()).isEmpty()) {
            Pricing_Template__c pricingTemplate = this.getDefaultPricingTemplate(dataContainer);
            insert pricingTemplate;
            dataContainer.put(pricingTemplate);
            return pricingTemplate;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Pricing_Template__c.getSobjectType(), null).values()) {
                return (Pricing_Template__c) s;
            }
        }
        return null;
    }
}