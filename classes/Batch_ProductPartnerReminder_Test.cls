@isTest
public class Batch_ProductPartnerReminder_Test {

    static testmethod void  myUnitTest()
    {
         ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUserWithCIBRole();

        User cU = [Select ID from User where ID  !=: u.ID AND ManagerID != null AND isActive = true limit 1];
        
        System.debug(cU);
        System.runAs(u) {
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			
			dataContainer.put(u);

			setupData();

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            
            opp.ProductPartner__c = cU.ID;
            update opp;
            
            System.debug(opp);
            Test.startTest();
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setComments('Submitting Product Partner Request for Approval');
            req.setObjectId(opp.ID);
            Approval.process(req, true);
            
            Database.executeBatch(new Batch_ProductPartnerReminder());
            Test.stopTest();
        }
    }
    private static void setupData()
    {
        Opportunity_Email_Alert_Config__c opportunityConfig = new Opportunity_Email_Alert_Config__c
            (Name = 'ProductPartnerReminder');
        insert opportunityConfig;
    }
}