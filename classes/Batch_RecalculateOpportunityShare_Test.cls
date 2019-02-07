/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate :2017-06-23
@Description : Test class
------------------------------------------------------*/
@isTest
public class Batch_RecalculateOpportunityShare_Test 
{
    static testMethod void myUnitTest()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        //ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;       
        
		Account relationshipGroup = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);
        
        relationshipGroup.type='Global Parent';
        update relationshipGroup;
		Integer batchSize = 2;
		List<Account> accounts = new List<Account>();
        List<Opportunity> opps = new List<Opportunity>();
        
		for(Integer i=0; i<=batchSize; i++){
			Account a = accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);
			a.ParentId = relationshipGroup.Id;
			accounts.add(a);
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.SaveResult> srList = Database.insert(accounts,dml);
        accounts[0].recordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        dml.DuplicateRuleHeader.AllowSave = true;
		
        Test.startTest();
        Database.executeBatch(new Batch_RecalculateOpportunityShare());
        Test.stopTest();
        
    }

}