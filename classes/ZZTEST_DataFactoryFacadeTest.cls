/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests - DataFactoryFacade
*
* 07-Dec-2015 Mohsin Wadee US-0775 - Call ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem 
									in testDataFactoryFacade method.	
* 10-Dec-2015 Mohsin Wadee US-0775 - Replace method call ZZTEST_F_CustomChatterSettings.InstantiateChatterSettingsForOpportunityLineItem
*		with ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem
*/
@isTest
public class ZZTEST_DataFactoryFacadeTest {

    static testMethod void testDataFactoryFacade() {
        
        ZZTEST_F_DeactivateChatterPostSettings.InstantiateChatterSettingsForOpportunityLineItem(False, False, False, False);
        
        Test.startTest();
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        Account acc2 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        System.debug('################ ' + acc1.Name + ' ' + acc2.Name);
        
        ZZTEST_F_Contact contactFactory = ZZTEST_DataFactoryFacade.contact;
        Contact cont = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        Contact cont2 = contactFactory.getInsertedProduct(ZZTEST_F_Contact.ContactRecordType.DEFAULT_CONTACT, dataContainer);
        System.debug('################ ' + cont.Account.BillingStreet + ' ' + cont2.Account.BillingStreet);

        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        Opportunity opty = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        Opportunity opty2 = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);
        System.debug('################ ' + opty.Account.Name + ' ' + opty2.Account.Name);

        ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
        Product2 product = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, 
            dataContainer);
        Product2 product1 = productFactory.getInsertedProduct(ZZTEST_F_Product.ProductRecordType.DEFAULT_PRODUCT, 
            dataContainer);
        System.debug('################ ' + product.Id + ' ' + product1.Id);
        
        ZZTEST_F_Product_Level_2 productLvl2Factory = ZZTEST_DataFactoryFacade.productLvl2;
        Product_Level_2__c productLvl21 = productLvl2Factory.getInsertedProduct(ZZTEST_F_Product_Level_2.ProductLevel2RecordType.DEFAULT_PRODUCT, 
            dataContainer);
        Product_Level_2__c productLvl22 = productLvl2Factory.getInsertedProduct(ZZTEST_F_Product_Level_2.ProductLevel2RecordType.DEFAULT_PRODUCT, 
            dataContainer);
        System.debug('################ ' + productLvl21.Id + ' ' + productLvl22.Id);
        
        ZZTEST_F_Product_Level_3 productLvl3Factory = ZZTEST_DataFactoryFacade.productLvl3;
        Product_Level_3__c productLvl31 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);
        Product_Level_3__c productLvl32 = productLvl3Factory.getInsertedProduct(ZZTEST_F_Product_Level_3.ProductLevel3RecordType.DEFAULT_PRODUCT, 
            dataContainer);
        System.debug('################ ' + productLvl31.Id + ' ' + productLvl32.Id);
    
        ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;
        PricebookEntry pe1 = pricebookEntryFactory.getInsertedProduct(ZZTEST_F_PricebookEntry.PricebookEntryRecordType.DEFAULT_PRICEBOOK_ENTRY, 
            dataContainer);
        PricebookEntry pe2 = pricebookEntryFactory.getInsertedProduct(ZZTEST_F_PricebookEntry.PricebookEntryRecordType.DEFAULT_PRICEBOOK_ENTRY, 
            dataContainer);
        System.debug('################ ' + pe1.Id + ' ' + pe1.Product2.Name);
        System.debug('################ ' + pe2.Id + ' ' + pe2.Product2.Name);

        ZZTEST_F_OpportunityLineItem opportunityLineItemFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
        OpportunityLineItem oli1 = opportunityLineItemFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, 
            dataContainer);
        OpportunityLineItem oli2 = opportunityLineItemFactory.getInsertedProduct(ZZTEST_F_OpportunityLineItem.OpportunityLineItemRecordType.DEFAULT_OPPORTUNITY_LINE_ITEM, 
            dataContainer);
        System.debug('################ ' + oli1.Id + ' ' + oli1.Opportunity.Name + ' ' + oli1.PricebookEntry.Name);
        System.debug('################ ' + oli2.Id + ' ' + oli2.Opportunity.Name + ' ' + oli2.PricebookEntry.Name);

        ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
        User u1 = userFactory.getBarclaysStandardUser();
        User u2 = userFactory.getExistingUserByProfile('System Administrator');

        System.assertEquals(u1.ProfileId,userFactory.getProfileIdByName('Barclays Standard User'));
        System.assertEquals(u2.ProfileId,userFactory.getProfileIdByName('System Administrator'));
        System.debug('################ ' + u1.Id + ' ' + u1.UserName + ' ' + u1.ProfileId);
        System.debug('################ ' + u2.Id + ' ' + u2.UserName + ' ' + u2.ProfileId);
        
        List<Opportunity_Split__c> splitsToDelete = [SELECT Id FROM Opportunity_Split__c WHERE Opportunity__c = :opty.Id];
        delete splitsToDelete;
        
        ZZTEST_F_OpportunitySplit opportunitySplitFactory = ZZTEST_DataFactoryFacade.opportunitySplit;
        Opportunity_Split__c split = opportunitySplitFactory.getInsertedProduct(ZZTEST_F_OpportunitySplit.OpportunitySplitRecordType.DEFAULT_OPPORTUNITY_SPLIT,
            dataContainer);
        System.debug('################ ' + split.Id + ' ' + split.Name);
/*
        F_Delivery deliveryFactory = TestDataFactoryFacade.delivery;
        Delivery__c del1 = deliveryFactory.getInsertedProduct(F_Delivery.DeliveryRecordType.DEFAULT_DELIVERY, 
            dataContainer);
        Delivery__c del2 = deliveryFactory.getInsertedProduct(F_Delivery.DeliveryRecordType.DEFAULT_DELIVERY, 
            dataContainer);
        System.debug('################ ' + del1.Id + ' ' + del1.Opportunity__r.Name + ' ' + del1.Account__r.Name + 
            ' ' + del1.Project_Leader__r.Email + ' ' + del1.Last_Invoiced_Month__c);
        System.debug('################ ' + del2.Id + ' ' + del2.Opportunity__r.Name + ' ' + del2.Account__r.Name + 
            ' ' + del2.Project_Leader__r.Email  + ' ' + del2.Last_Invoiced_Month__c);

        F_Allocation allocationFactory = TestDataFactoryFacade.allocation;
        Allocation__c alloc1 = allocationFactory.getInsertedProduct(F_Allocation.AllocationRecordType.DEFAULT_ALLOCATION, 
            dataContainer);
        Allocation__c alloc2 = allocationFactory.getInsertedProduct(F_Allocation.AllocationRecordType.DEFAULT_ALLOCATION, 
            dataContainer);
        System.debug('################ ' + alloc1.Id + ' ' + alloc1.Delivery__r.Project_Number__c + ' ' + alloc1.Product__r.Name + 
            ' ' + alloc1.Order__r.Description);
        System.debug('################ ' + alloc2.Id + ' ' + alloc2.Delivery__r.Project_Number__c + ' ' + alloc2.Product__r.Name + 
            ' ' + alloc2.Order__r.Description);

        F_Order orderFactory = TestDataFactoryFacade.order;
        Order order1 = orderFactory.getInsertedProduct(F_Order.OrderRecordType.EXTERNAL_ORDER, dataContainer);
        Order order2 = orderFactory.getInsertedProduct(F_Order.OrderRecordType.INTERNAL_ORDER, dataContainer);
        Order order3 = orderFactory.getInsertedProduct(F_Order.OrderRecordType.EXTERNAL_ORDER, dataContainer);
        Order order4 = orderFactory.getInsertedProduct(F_Order.OrderRecordType.INTERNAL_ORDER, dataContainer);
        System.debug('################ ' + order1.Id);
        System.debug('################ ' + order2.Id);
        System.debug('################ ' + order3.Id);
        System.debug('################ ' + order4.Id);

        F_Invoice invoiceFactory = TestDataFactoryFacade.invoice;
        Invoice__c invoice = invoiceFactory.getInsertedProduct(F_Invoice.InvoiceRecordType.DEFAULT_INVOICE, dataContainer);
        System.debug('################ ' + invoice.Id + ' ' + invoice.Delivery__r.Account__r.Name +
            ' ' + invoice.Order__r.Order_Subject__c + ' ' + invoice.Delivery__r.Project_Number__c);
    
        F_Timesheet timesheetFactory = TestDataFactoryFacade.timesheet;
        Timesheet__C timesheet = timesheetFactory.getInsertedProduct(F_Timesheet.TimesheetRecordType.DEFAULT_TIMESHEET, dataContainer);
        System.debug('################ ' + timesheet.Allocation__r.Ordered_Man_days__c + ' ' + timesheet.Approver__r.Email + ' ' +
            timesheet.Employee__r.ProductCode);

        F_EarningPerEmployee earningFactory = TestDataFactoryFacade.earning;
        Employee_Earning__c earning = earningFactory.getInsertedProduct(F_EarningPerEmployee.EarningRecordType.DEFAULT_EARNING, dataContainer);
        System.debug('################ ' + earning.Employee__r.ProductCode + ' ' + earning.Invoice__r.Account__r.Name);

        F_Vacation vacationFactory = TestDataFactoryFacade.vacation;
        Vacation__c vacation = vacationFactory.getInsertedProduct(F_Vacation.VacationRecordType.DEFAULT_VACATION, dataContainer);
        System.debug('################ ' + vacation.Employee__r.ProductCode);      


        F_License licenseFactory = TestDataFactoryFacade.license;
        License_AW__c license = licenseFactory.getInsertedProduct(F_License.LicenseRecordType.DEFAULT_LICENSE, dataContainer);
        System.debug('################ ' + license.Account__r.Name + ' ' + license.Opportunity__r.Name);  

        F_Skill skillFactory = TestDataFactoryFacade.skill;
        Skill__c skill = skillFactory.getInsertedProduct(F_Skill.SkillRecordType.DEFAULT_SKILL, dataContainer);
        System.debug('################ ' ); 
        */
        Test.stopTest();
    }
}