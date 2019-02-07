/**
* @Author       
* Company:      Deloitte
* @Description: TUnit Tests for TreeViewController
* @Date:        
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 23/02/2016    C Reinecke      Added New Test Methods to exercise the Global Parent Hierarchy
*------------------------------------------------------------*/
@isTest
private class ZZTEST_TreeViewController
{
	public static testMethod void testSdsHierarchy() {

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;

		Account globalParent = accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.SDS_ACCOUNT, dataContainer);
		globalParent.Type = 'SDS Ultimate Parent';
		insert globalParent;

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.SaveResult> srList;

		List<Account> sdsUltimateParents = new List<Account>();
		for(Integer i=0; i<10; i++){
			Account ultimateParent = accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.SDS_ACCOUNT, dataContainer);
			ultimateParent.Type = 'SDS Ultimate Parent';
			sdsUltimateParents.add(ultimateParent);
		}
		srList = Database.insert(sdsUltimateParents,dml);

		List<Account> accounts = new List<Account>();
		for(Integer i=0; i<1000; i++){
			accounts.add(accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.SDS_ACCOUNT, dataContainer));
		}
		srList = Database.insert(accounts,dml);

		List<Hierarchy__c> hierarchies = new List<Hierarchy__c>();
		for(Account acc: sdsUltimateParents){
			hierarchies.add(new Hierarchy__c(
									Parent__c = globalParent.Id, 
									Child__c=acc.Id, 
									Hierarchy_Type__c='SDS'
			));
		}

		Integer i = 0;
		for(Account acc: accounts){
			hierarchies.add(new Hierarchy__c(
									Parent__c = sdsUltimateParents[i].Id, 
									Child__c=acc.Id, 
									Hierarchy_Type__c='SDS'
			));
			if(i == 9){
				i = 0;
			} else{
				i++;
			}
		}
		
		Test.startTest();
        srList = Database.insert(hierarchies,dml);
        System.assertEquals(TreeViewController.getUltimateParent(accounts[0].Id).Id, globalParent.Id);
        
        String json = TreeViewController.getSdsHierarchy(accounts[0].Id, true);
		
		Test.stopTest();
	}

	public static testMethod void testBuyingGroupHierarchy() {

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;

		Account buyingGroup = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);

		Integer batchSize = 4000;
		List<Account> accounts = new List<Account>();
		for(Integer i=0; i<=batchSize; i++){
			Account a = accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
			a.ParentId = buyingGroup.Id;
			accounts.add(a);
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.SaveResult> srList = Database.insert(accounts,dml);
		
		Test.startTest();
        
        System.assertEquals(TreeViewController.getBuyingGroup(accounts[0].Id).Id, buyingGroup.Id);
        String json = TreeViewController.getBuyingGroupHierarchy(accounts[0].Id);
		
		Test.stopTest();
	}

		public static testMethod void testRelationshipHierarchy() {

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;

		Account relationshipGroup = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);

		Integer batchSize = 4000;
		List<Account> accounts = new List<Account>();
		for(Integer i=0; i<=batchSize; i++){
			Account a = accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
			a.ParentId = relationshipGroup.Id;
			accounts.add(a);
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.SaveResult> srList = Database.insert(accounts,dml);
		
		Test.startTest();
        
        System.assertEquals(TreeViewController.getUltimateRelationshipParent(accounts[0].Id).Id, relationshipGroup.Id);
        String json = TreeViewController.getRelationshipHierarchy(accounts[0].Id,False);
		
		Test.stopTest();
	}
}