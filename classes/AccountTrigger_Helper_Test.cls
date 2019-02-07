/**=============================================
@ CreatedBy : Tonga MM
@ CreatedDate : 2017-06-12
@ Description : Test class for newly added methods on AccountTrigger_Helper
=================================================**/
@isTest
public class AccountTrigger_Helper_Test 
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
        Database.update(accounts[0],dml);
        relationshipGroup.OwnerID = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND ManagerId != NULL LIMIT 1].ID;
        Database.update(relationshipGroup,dml);
        
        Test.stopTest();
        
    }
    
    static testMethod void checkOpportunityCallReportShareOwnerChange()
    {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        
		Account relationshipGroup = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);
        
        relationshipGroup.type='Global Parent';
        update relationshipGroup;
        
        Account relationshipGroupTwo = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);
        relationshipGroupTwo.type='Global Parent';
        update relationshipGroupTwo;
        
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
        Database.update(accounts[0],dml);
        //relationshipGroup.OwnerID = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND ManagerId != NULL LIMIT 1].ID;
        
        List<Account> accountToUpdate = new List<Account>();
        for(Account a :[Select ID,ParentId from Account where ParentID=:relationshipGroup.ID])
        {
            a.ParentId = relationshipGroupTwo.ID;
            accountToUpdate.add(a);
        }
        Database.update(accountToUpdate,dml);
        Database.update(relationshipGroup,dml);
        
        Test.stopTest();
        
    }
}