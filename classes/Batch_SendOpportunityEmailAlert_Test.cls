/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate : 2017-05-31
@Description : Test class
------------------------------------------------------*/
@isTest
public class Batch_SendOpportunityEmailAlert_Test {

    static testMethod void sendOpportunityEmail()
    {
        
        
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUserWithCIBRole();

        User cU = [Select UserRole.Name from User where ID  =: u.ID];
        System.debug(cU);
        System.runAs(u) {
			ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
			ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
			ZZTEST_F_OpportunityLineItem oliFactory = ZZTEST_DataFactoryFacade.opportunityLineItem;
			ZZTEST_F_Product productFactory = ZZTEST_DataFactoryFacade.product;
			ZZTEST_F_PricebookEntry pricebookEntryFactory = ZZTEST_DataFactoryFacade.pricebookEntry;

			dataContainer.put(u);

			setupData();

			Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            opp.StageName = 'Client Engaged';
            opp.closeDate = Date.today();
            opp.Reason_for_probability_change__c='Just came from a meeting';
            update opp;
            
            Test.startTest();
            Database.executeBatch(new Batch_SendOpportunityEmailAlert());
            Test.stopTest();
        }
    }
    
    private static void setupData()
    {
        Opportunity_Email_Alert_Config__c opportunityConfig = new Opportunity_Email_Alert_Config__c
            (Name = 'ClosedOpportunityAlert',
             Future_Warning_Days__c=5,
             Starting_Year__c = 2017,
             StageName__c = 'Closed Won;Closed Lost');
        insert opportunityConfig;
    }
}