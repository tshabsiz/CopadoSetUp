/**
* @Author:        Marta Malinowska
* @Company:       Deloitte
* @Description:   Factory class for test data purposes
*
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 3.12.2015   Marek Cech         added Recurring_Fees_Period__c value to newly created OpportunityLineItem
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_F_OpportunityLineItem {

    public enum OpportunityLineItemRecordType {DEFAULT_OPPORTUNITY_LINE_ITEM, DOMESTIC_PAYMENTS_OPPORTUNITY_LINE_ITEM}

    private static ZZTEST_F_OpportunityLineItem instance;
    
    private static final String MONTHLY = OpportunityLineItemTrigger_Helper.MONTHLY;

    private Integer productCounter;

    private ZZTEST_F_OpportunityLineItem() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_OpportunityLineItem getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_OpportunityLineItem();
        }
        return instance;
    }

    public OpportunityLineItem getProduct(OpportunityLineItemRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM) {
                return getDefaultProduct(dataContainer);
            }
            if (type == OpportunityLineItemRecordType.DOMESTIC_PAYMENTS_OPPORTUNITY_LINE_ITEM) {
            	return getDomesticPaymentsProduct(dataContainer);   
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public OpportunityLineItem getInsertedProduct(OpportunityLineItemRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM) {
                return getInsertedDefaultProduct(dataContainer);
            }
            if (type == OpportunityLineItemRecordType.DOMESTIC_PAYMENTS_OPPORTUNITY_LINE_ITEM) {
            	return getInsertedDomesticPaymentsProduct(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private OpportunityLineItem getDefaultProduct(ZZTEST_DataContainer dataContainer) {
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Description = 'Karel Kakadu OpportunityLineItem';
        oli.Quantity = 1;
        oli.UnitPrice = 10000;

        ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;
        PricebookEntry pe = pricebookEntryFactory.getInsertedProduct(ZZTEST_F_PricebookEntry.PricebookEntryRecordType.DEFAULT_PRICEBOOK_ENTRY, 
            dataContainer);
        oli.PricebookEntryId = pe.Id;
        oli.PricebookEntry = pe;

        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        oli.OpportunityId = opty.Id;
        oli.Fees__c = 0;
        oli.Opportunity = opty;
        oli.Annualised_Income__c = 1234565;
        oli.Recurring_Fees_Period__c = MONTHLY;
        
        ZZTEST_F_Product_Level_2 productLvl2Factory = ZZTEST_DataFactoryFacade.productLvl2;
        Product_Level_2__c productLvl2 = productLvl2Factory.getInsertedProduct(ZZTEST_F_Product_Level_2.ProductLevel2RecordType.DEFAULT_PRODUCT, 
            dataContainer);
        oli.Product_Level_2__c = productLvl2.Id;
        oli.Product_Level_2__r = productLvl2;
        
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl3 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);
        oli.Product_Level_3__c = productLvl3.Id;
        oli.Product_Level_3__r = productLvl3;
        
        // Add a product partner
        if (!dataContainer.getSObjectMap(User.getSObjectType()).isEmpty()) {
        	for(SObject s :dataContainer.getRecordTypeMap(User.getSobjectType(), null).values()) {
                oli.ProductPartner__c = s.Id;
                break;
            }
        }
        
        return oli;
    }
    
    private OpportunityLineItem getDomesticPaymentsProduct(ZZTEST_DataContainer dataContainer) {
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Description = 'Domestic Payments OpportunityLineItem';
        oli.Quantity = 1;
        oli.UnitPrice = 10000;

        ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;
        PricebookEntry pe = pricebookEntryFactory.getInsertedProduct(ZZTEST_F_PricebookEntry.PricebookEntryRecordType.TRANSACTIONS_PRICEBOOK_ENTRY, 
            dataContainer);
        oli.PricebookEntryId = pe.Id;
        oli.PricebookEntry = pe;
        
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.PUBLIC_OPPORTUNITY,
            dataContainer);
        oli.OpportunityId = opty.Id;
        oli.Fees__c = 0;
        oli.Opportunity = opty;
        oli.Annualised_Income__c = 1234565;
        oli.Recurring_Fees_Period__c = MONTHLY;
        
        ZZTEST_F_Product_Level_2 productLvl2Factory = ZZTEST_DataFactoryFacade.productLvl2;
        Product_Level_2__c productLvl2 = productLvl2Factory.getInsertedProduct(ZZTEST_F_Product_Level_2.ProductLevel2RecordType.ELECTRONIC_BANKING_PRODUCT, 
            dataContainer);
        oli.Product_Level_2__c = productLvl2.Id;
        oli.Product_Level_2__r = productLvl2;
        
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl3 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DOMESTIC_PAYMENTS_PRODUCT, 
            dataContainer);
        oli.Product_Level_3__c = productLvl3.Id;
        oli.Product_Level_3__r = productLvl3;
        
        // Add a product partner
        if (!dataContainer.getSObjectMap(User.getSObjectType()).isEmpty()) {
        	for(SObject s :dataContainer.getRecordTypeMap(User.getSobjectType(), null).values()) {
                oli.ProductPartner__c = s.Id;
                break;
            }
        }
        
        return oli;
    }

    private OpportunityLineItem getInsertedDefaultProduct(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(OpportunityLineItem.getSObjectType()).isEmpty()) {
            OpportunityLineItem oli = this.getDefaultProduct(dataContainer);
            insert oli;
            dataContainer.put(oli);
            return oli;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(OpportunityLineItem.getSobjectType(), null).values()) {
                return (OpportunityLineItem) s;
            }
        }
        return null;
    }

    private OpportunityLineItem getInsertedDomesticPaymentsProduct(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(OpportunityLineItem.getSObjectType()).isEmpty()) {
            OpportunityLineItem oli = this.getDomesticPaymentsProduct(dataContainer);
            insert oli;
            dataContainer.put(oli);            
            return oli;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(OpportunityLineItem.getSobjectType(), null).values()) {
                return (OpportunityLineItem) s;
            }
        }
        return null;
    }
}