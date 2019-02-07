/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Opportunity_Split__c
*/
@isTest
public class ZZTEST_F_OpportunitySplit {

    public enum OpportunitySplitRecordType {DEFAULT_OPPORTUNITY_SPLIT}

    private static ZZTEST_F_OpportunitySplit instance;

    private Integer productCounter;

    private ZZTEST_F_OpportunitySplit() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_OpportunitySplit getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_OpportunitySplit();
        }
        return instance;
    }
    
    public Opportunity_Split__c getProduct(OpportunitySplitRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT) {
                return getDefaultProduct(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Opportunity_Split__c getInsertedProduct(OpportunitySplitRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT) {
                return getInsertedDefaultProduct(dataContainer);
            }
        } catch (Exception e) {
            System.debug('############## ' + e);
            return null;
        }
        return null;
    }
    
    private Opportunity_Split__c getDefaultProduct(ZZTEST_DataContainer dataContainer) {
        Opportunity_Split__c split= new Opportunity_Split__c ();
        split.Business_Unit__c = 'Barclays Africa';
        split.Division__c = 'Barclays Card';
        split.Percentage__c = 30;
        
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        split.Opportunity__c = opty.Id;
        split.Opportunity__r = opty;
        
        return split;
    }

    private Opportunity_Split__c getInsertedDefaultProduct(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Opportunity_Split__c.getSObjectType()).isEmpty()) {
            Opportunity_Split__c split = this.getDefaultProduct(dataContainer);
            System.debug('split.Percentage__c: ' + split.Percentage__c);
            insert split;
            dataContainer.put(split);
            return split;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Opportunity_Split__c.getSobjectType(), null).values()) {
                return (Opportunity_Split__c) s;
            }
        }
        System.debug('#### a sakra');
        return null;
    }

}