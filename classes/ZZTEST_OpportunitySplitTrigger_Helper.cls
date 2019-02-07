/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Opportunity_Split__c Trigger
*/
@isTest
public class ZZTEST_OpportunitySplitTrigger_Helper {
    
    /**
    * @description Test of "sumPercentage" method
    */
    public static testMethod void testSumPercentage() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
    
        ZZTEST_F_OpportunitySplit opportunitySplitFactory = ZZTEST_DataFactoryFacade.opportunitySplit;
        Opportunity_Split__c split1 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        Opportunity_Split__c split2 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
            
        split1.Percentage__c = 34;
        split2.Percentage__c = 52;
        
        List<Opportunity_Split__c> splits = new List<Opportunity_Split__c>{split1, split2};
        
        //executing tested method
        Decimal result = OpportunitySplitTrigger_Helper.sumPercentage(splits);
        
        Decimal expected = split1.Percentage__c + split2.Percentage__c;
        System.assertEquals(expected, result);
    }
    
    /**
    * @description Test of "addOver100Error" method
    */
    public static testMethod void testAddOver100Error() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
    
        ZZTEST_F_OpportunitySplit opportunitySplitFactory = ZZTEST_DataFactoryFacade.opportunitySplit;
        Opportunity_Split__c split1 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        Opportunity_Split__c split2 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
            
        split1.Percentage__c = 80;
        split2.Percentage__c = 30;
        
        List<Opportunity_Split__c> splits = new List<Opportunity_Split__c>{split1, split2};
        
        //executing tested method
        OpportunitySplitTrigger_Helper.addOver100Error(splits, split1.Percentage__c + split2.Percentage__c);
        
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(Label.Splits_Sum_Over_100_Percent));
        
        Decimal percentageSum = split1.Percentage__c + split2.Percentage__c;
        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains('' + percentageSum));
    }
    
    /**
    * @description Test of "replaceStoredSplitsByTriggered" method
    */
    public static testMethod void testReplaceStoredSplitsByTriggered() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_OpportunitySplit opportunitySplitFactory = ZZTEST_DataFactoryFacade.opportunitySplit;
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        
        Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        List<Opportunity_Split__c> splitsToDelete = [SELECT Id FROM Opportunity_Split__c WHERE Opportunity__c = :opty.Id];
        delete splitsToDelete;
        
        //stored splits preparation
        Opportunity_Split__c storedSplit1 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        storedSplit1.Percentage__c = 40;
        
        Opportunity_Split__c storedSplit2 = opportunitySplitFactory.getInsertedProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        storedSplit2.Percentage__c = 30;
        
        List<Opportunity_Split__c> storedSplits = new List<Opportunity_Split__c>{storedSplit1, storedSplit2};
        upsert storedSplits;
        
        
        //triggered splits preparation
        //triggeredSplit1 should replace storedSplit2
        Opportunity_Split__c triggeredSplit1 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        triggeredSplit1.Id = storedSplit2.Id;
        triggeredSplit1.Percentage__c = 33;
        
        //triggeredSplit2 should not replace anything - not stored in DB
        Opportunity_Split__c triggeredSplit2 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        triggeredSplit2.Percentage__c = 50;
        
        List<Opportunity_Split__c> triggeredSplits = new List<Opportunity_Split__c>{triggeredSplit1, triggeredSplit2};
        
        //executing tested method
        List<Opportunity_Split__c> result = OpportunitySplitTrigger_Helper.replaceStoredSplitsByTriggered(storedSplits, triggeredSplits);
        
        System.assertEquals(3, result.size());
        System.assertEquals(storedSplit1.Id, result[0].Id);
        System.assertEquals(triggeredSplit1.Id, result[1].Id);
        
        System.assertEquals(null, result[2].Id);
        System.assertEquals(triggeredSplit2.Percentage__c, result[2].Percentage__c);
    }
    
    /**
    * @description Test of "groupSplitsByOpp" method
    */
    public static testMethod void testGroupSplitsByOpp() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunitySplit opportunitySplitFactory = ZZTEST_DataFactoryFacade.opportunitySplit;
        
        //opportunities preparation
        Opportunity opty1 = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        Opportunity opty2 = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        insert opty2;
        List<Opportunity_Split__c> splitsToDelete = [SELECT Id FROM Opportunity_Split__c WHERE Opportunity__c = :opty1.Id OR Opportunity__c = :opty2.Id];
        delete splitsToDelete;
        
        //splits preparation
        Opportunity_Split__c split1 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        Opportunity_Split__c split2 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        Opportunity_Split__c split3 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        Opportunity_Split__c split4 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        split1.Opportunity__c = opty1.Id;
        split2.Opportunity__c = opty2.Id;
        split3.Opportunity__c = opty1.Id;
        split4.Opportunity__c = opty2.Id;
        
        List<Opportunity_Split__c> splits = new List<Opportunity_Split__c>{split1, split2, split3, split4};
        insert splits;
        
        //executing tested method
        Map<Id, List<Opportunity_Split__c>> result = OpportunitySplitTrigger_Helper.groupSplitsByOpp(splits);
        
        System.assertEquals(2, result.keySet().size());
        System.assertEquals(true, result.keySet().contains(opty1.Id));
        System.assertEquals(true, result.keySet().contains(opty2.Id));
        
        System.assertEquals(2, result.get(opty1.Id).size());
        System.assertEquals(2, result.get(opty2.Id).size());
        
        List<Opportunity_Split__c> resultList1 = result.get(opty1.Id);
        List<Opportunity_Split__c> resultList2 = result.get(opty2.Id);
        
        System.assertEquals(split1.Id, resultList1[0].Id); 
        System.assertEquals(split3.Id, resultList1[1].Id);
        System.assertEquals(split2.Id, resultList2[0].Id); 
        System.assertEquals(split4.Id, resultList2[1].Id); 
    }
    
    /**
    * @description Test of "checkSplitsSumUnder100Percent" method
    */
    public static testMethod void testCheckSplitsSumUnder100Percent() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_OpportunitySplit opportunitySplitFactory = ZZTEST_DataFactoryFacade.opportunitySplit;
        
        Opportunity opty1 = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        
        //1 opportunity with 1 not inserted split
        Opportunity opty = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        insert opty;
        List<Opportunity_Split__c> splitsToDelete = [SELECT Id FROM Opportunity_Split__c WHERE Opportunity__c = :opty1.Id OR Opportunity__c = :opty.Id];
        delete splitsToDelete;
        
        Opportunity_Split__c split0 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        split0.Percentage__c = 100;
        split0.Opportunity__c = opty.Id;
        
        //3 splits, split 1 should not be counted - stored in DB and updated by split2
        Opportunity_Split__c split1 = opportunitySplitFactory.getInsertedProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        split1.Percentage__c = 20;
        update split1;
        
        Opportunity_Split__c split2 = opportunitySplitFactory.getInsertedProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        split1.Percentage__c = 30;
          
        Opportunity_Split__c split3 = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        split3.Percentage__c = 80;
        
        List<Opportunity_Split__c> splits = new List<Opportunity_Split__c>{split0, split2, split3};
        
        OpportunitySplitTrigger_Helper.checkSplitsSumUnder100Percent(splits);
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(Label.Splits_Sum_Over_100_Percent));
        
        Decimal percentageSum = split2.Percentage__c + split3.Percentage__c;
        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains('' + percentageSum));
    }
    
    /**
    * @description Test of bulkification
    */
    public static testMethod void testBulk() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_OpportunitySplit opportunitySplitFactory = ZZTEST_DataFactoryFacade.opportunitySplit;
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        
        Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        List<Opportunity_Split__c> splitsToDelete = [SELECT Id FROM Opportunity_Split__c WHERE Opportunity__c = :opty.Id];
        delete splitsToDelete;
        
        //200 opportunity splits creation
        List<Opportunity_Split__c> splits = new List<Opportunity_Split__c>();
        for (Integer i = 0; i < 200; i++) {
            Opportunity_Split__c split = opportunitySplitFactory.getProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
                dataContainer);
            splits.add(split);
        }
        
        Test.startTest();
        OpportunitySplitTrigger_Helper.checkSplitsSumUnder100Percent(splits);
        Test.stopTest();
        
        System.assertEquals(1, ApexPages.getMessages().size());
        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(Label.Splits_Sum_Over_100_Percent));
    }
    
}