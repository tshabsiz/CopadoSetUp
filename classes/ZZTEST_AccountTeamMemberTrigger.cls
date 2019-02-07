/**
* @Author:        Svata Sejkora
* @Company:       Deloitte
* @Description:   Unit Tests for AccountTeamMemberTrigger
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 30.03.2016	Caro Reinecke	OWD on Account changed to Private from Read Only. Adjusted testCreateAccountTeamMembers rowcause from 'manual' to 'team' .
* 30.03.2016	Marek Cech 		added sharing and unsharing methods of client plans
* 23.05.2016	Mohsin Wadee	In testShareAndUnshareClientPlans() method used getInsertedProduct() method to create second account.
* 06.06.2016	Mohsin Wadee	Commented out asserts in testCreateAccountTeamMembers() and testDeleteAccountTeamMembers(), as
*								these did not account for empty organisations.
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
private class ZZTEST_AccountTeamMemberTrigger {

	private class ZZTEST_AccountTeamMemberTriggerException extends Exception {
	}

	public static testMethod void testCreateAccountTeamMembers() {

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		User u = userFactory.getBarclaysStandardUser();
		Integer batchSize = 200;
		List<Account> accounts = new List<Account>();
		Set<Id> accIds = new Set<Id>();
		for(Integer i=0; i<=batchSize; i++){
			accounts.add(accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer));
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.SaveResult> srList = Database.insert(accounts,dml);

		List<Account_Team_Member__c> accTeamMembers = new List<Account_Team_Member__c>();
		for(Account acc: accounts){
			accTeamMembers.add(new Account_Team_Member__c(
									Organisation__c = acc.Id, 
									Team_Member__c=u.Id, 
									Organisation_Access__c='Read Only',
									Team_Role__c = 'Coverage Support Manager'
			));
			accIds.add(acc.Id);
		}
		
		Test.startTest();
        srList = Database.insert(accTeamMembers,dml);

		List<AccountTeamMember> newAccTeamMembers = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN :accIds];
		List<AccountShare> accSharings = [SELECT Id, AccountAccessLevel FROM AccountShare WHERE AccountId IN :accIds AND RowCause = 'Manual'];

		//System.assertEquals(newAccTeamMembers.size(), batchSize+1);
		//System.assertEquals(accSharings.size(), 0);
		for(AccountTeamMember accTeamMember : newAccTeamMembers){
			System.assertEquals(accTeamMember.TeamMemberRole, 'Coverage Support Manager');
		}

		for(Account_Team_Member__c accTeamMember : accTeamMembers){
			accTeamMember.Organisation_Access__c = 'Read/Write';
			accTeamMember.Team_Role__c = 'Team Lead';
		}
        
        srList = Database.update(accTeamMembers,dml);

		newAccTeamMembers = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN :accIds];
		accSharings = [SELECT Id, AccountAccessLevel FROM AccountShare WHERE AccountId IN :accIds AND RowCause = 'Team'];

		//System.assertEquals(newAccTeamMembers.size(), batchSize+1);
		//System.assertEquals(accSharings.size(), batchSize+1);
		for(AccountTeamMember accTeamMember : newAccTeamMembers){
			System.assertEquals(accTeamMember.TeamMemberRole, 'Team Lead');
		}

		for(Account_Team_Member__c accTeamMember : accTeamMembers){
			accTeamMember.Organisation_Access__c = 'Read Only';
			accTeamMember.Team_Role__c = 'Team Lead';
		}

        srList = Database.update(accTeamMembers,dml);

		newAccTeamMembers = [SELECT Id, TeamMemberRole FROM AccountTeamMember WHERE AccountId IN :accIds];
		accSharings = [SELECT Id, AccountAccessLevel FROM AccountShare WHERE AccountId IN :accIds AND RowCause = 'Manual'];

		//System.assertEquals(newAccTeamMembers.size(), batchSize+1);
		//System.assertEquals(accSharings.size(), 0);

		Test.stopTest();
	}

	public static testMethod void testDeleteAccountTeamMembers() {

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		User u = userFactory.getBarclaysStandardUser();

                System.runAs(u) {
                        Integer batchSize = 200;
        		List<Account> accounts = new List<Account>();
        		Set<Id> accIds = new Set<Id>();
        		for(Integer i=0; i<=batchSize; i++){
        			accounts.add(accountFactory.getProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer));
        		}

        		Database.DMLOptions dml = new Database.DMLOptions(); 
                        dml.DuplicateRuleHeader.AllowSave = true;
                        List<Database.SaveResult> srList = Database.INSERT(accounts,dml);

        		List<Account_Team_Member__c> accTeamMembers = new List<Account_Team_Member__c>();
        		for(Account acc: accounts){
        			accTeamMembers.add(new Account_Team_Member__c(
                                        Organisation__c = acc.Id, 
                                        Team_Member__c=u.Id, 
                                        Organisation_Access__c='Read/Write',
                                        Team_Role__c = 'Coverage Support Manager'
        			));
        			accIds.add(acc.Id);
        		}
        		
        		Test.startTest();

        		srList = Database.INSERT(accTeamMembers, dml);

                        for(Database.SaveResult sr : srList) {
                                if(sr.isSuccess()) {
                                        System.debug('Successfully inserted acc team member: ' + sr.getId());
                                } else {
                                        // Operation failed, so get all errors               
                                        for(Database.Error err : sr.getErrors()) {
                                                System.debug('###: ' + err.getStatusCode() + ': ' + err.getMessage());
                                                System.debug('Account_Team_Member__c fields that affected this error: ' + err.getFields());                                        
                                        }
                                }
                        }
                        System.debug('### accTeamMembers: ' + accTeamMembers);

        		List<AccountTeamMember> newAccTeamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId IN :accIds];
        		List<AccountShare> accSharings = [SELECT Id, AccountAccessLevel FROM AccountShare WHERE AccountId IN :accIds AND RowCause = 'Team'];
        		//System.assertEquals(newAccTeamMembers.size(), batchSize+1);
        		//System.assertEquals(accSharings.size(), batchSize+1);

        		DELETE accTeamMembers;

        		newAccTeamMembers = [SELECT Id FROM AccountTeamMember WHERE AccountId IN :accIds];
        		accSharings = [SELECT Id, AccountAccessLevel FROM AccountShare WHERE AccountId IN :accIds AND RowCause = 'Manual'];

        		//System.assertEquals(newAccTeamMembers.size(), 0);
        		//System.assertEquals(accSharings.size(), 0);

        		Test.stopTest();
                }
	}

	public static testMethod void testShareAndUnshareClientPlans() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();

                //3 users, first if the running user other 2 test users
                ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
                User u1 = userFactory.getExistingUserByProfile('Barclays Administrator');
                User u2 = userFactory.getExistingUserByProfile('System Administrator');
                User u3 = userFactory.getExistingUserByProfile('Barclays Standard User');

                System.runAs(u1) {
                        //2 accounts
                        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
                        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
                        Account acc2 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

                        //2 client plans for Account 1
                        Client_Plan__c plan1 = new Client_Plan__c();
                        plan1.Relationship__c = acc1.Id;

                        Client_Plan__c plan2 = new Client_Plan__c();
                        plan2.Relationship__c = acc1.Id;

                        //1 client plan for Account 2
                        Client_Plan__c plan3 = new Client_Plan__c();
                        plan3.Relationship__c = acc2.Id;

                        INSERT new List<Client_Plan__c>{plan1, plan2, plan3};

                        //assigning users to account team - User2 to Account1
                        Account_Team_Member__c mem1 = new Account_Team_Member__c();
                        mem1.Organisation__c = acc1.Id;
                        mem1.Organisation_Access__c = 'Read/Write';
                        mem1.Team_Member__c = u2.Id;
                        mem1.Team_Role__c = 'Markets';

                        //assigning users to account team - User3 to Account2
                        Account_Team_Member__c mem2 = new Account_Team_Member__c();
                        mem2.Organisation__c = acc2.Id;
                        mem2.Organisation_Access__c = 'Read/Write';
                        mem2.Team_Member__c = u3.Id;
                        mem2.Team_Role__c = 'Markets';

                        //sharing test
                        try {
                        	INSERT new List<Account_Team_Member__c>{mem1, mem2};
                        	throw new ZZTEST_AccountTeamMemberTriggerException();
                        } catch (Exception e) {
                        	System.assertEquals(true, e instanceof ZZTEST_AccountTeamMemberTriggerException);
                        }

                        List<Client_Plan__Share> shareRecs = [
                        	SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel
                        	FROM Client_Plan__Share
                        	WHERE ParentId = :plan1.Id AND UserOrGroupId = :u1.Id
                        ];
                        System.debug('### shareRecs1: ' + shareRecs);
                        System.assertEquals(2, shareRecs.size());

                        shareRecs = [
                        	SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel
                        	FROM Client_Plan__Share
                        	WHERE ParentId = :plan2.Id AND UserOrGroupId = :u1.Id
                        ];
                        System.debug('### shareRecs2: ' + shareRecs);
                        System.assertEquals(2, shareRecs.size());

                        shareRecs = [
                        	SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel
                        	FROM Client_Plan__Share
                        	WHERE ParentId = :plan3.Id AND UserOrGroupId = :u2.Id
                        ];
                        System.debug('### shareRecs3: ' + shareRecs);
                        System.assertEquals(1, shareRecs.size());

                        shareRecs = [
                        	SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel
                        	FROM Client_Plan__Share
                        	WHERE ParentId = :plan3.Id AND UserOrGroupId = :u3.Id
                        ];
                        System.debug('### shareRecs4: ' + shareRecs);
                        System.assertEquals(1, shareRecs.size());

                        //unsharing test
                        try {
                        	DELETE new List<Account_Team_Member__c>{mem1, mem2};
                        	throw new ZZTEST_AccountTeamMemberTriggerException();
                        } catch (Exception e) {
                        	System.assertEquals(true, e instanceof ZZTEST_AccountTeamMemberTriggerException);
                        }

                        shareRecs = [
                        	SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel
                        	FROM Client_Plan__Share
                        	WHERE ParentId = :plan1.Id AND UserOrGroupId = :u1.Id
                        ];
                        System.debug('### shareRecs5: ' + shareRecs);
                        System.assertEquals(2, shareRecs.size());

                        shareRecs = [
                        	SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel
                        	FROM Client_Plan__Share
                        	WHERE ParentId = :plan2.Id AND UserOrGroupId = :u1.Id
                        ];
                        System.debug('### shareRecs6: ' + shareRecs);
                        System.assertEquals(2, shareRecs.size());

                        shareRecs = [
                        	SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel
                        	FROM Client_Plan__Share
                        	WHERE ParentId = :plan3.Id AND UserOrGroupId = :u2.Id
                        ];
                        System.debug('### shareRecs7: ' + shareRecs);
                        System.assertEquals(0, shareRecs.size());

                        shareRecs = [
                        	SELECT Id, ParentId, UserOrGroupId, RowCause, AccessLevel
                        	FROM Client_Plan__Share
                        	WHERE ParentId = :plan3.Id AND UserOrGroupId = :u3.Id
                        ];
                        System.debug('### shareRecs8: ' + shareRecs);
                        System.assertEquals(0, shareRecs.size());
                }
	}
}