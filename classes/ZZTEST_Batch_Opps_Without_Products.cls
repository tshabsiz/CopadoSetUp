@isTest 
public class ZZTEST_Batch_Opps_Without_Products {
	static testMethod void testBatch() 
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
		
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        System.runAs (thisUser) {
	        Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
	        User barclaysStdUser = userFactory.getBarclaysStandardUser();
	        insert opp;
        }
        
   		Test.startTest();
        Batch_Opportunities_Without_Products obj = new Batch_Opportunities_Without_Products();
        DataBase.executeBatch(obj, 200);
        Test.stopTest();
    }
}