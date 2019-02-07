/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanTrigger_Helper
*                 Tests executed:
*                 1 - testCheckRightsToCreateNewViaTeamMember()
*                   Tests checking rights to create a client plan for team member
*                 2 - testCheckRightsToCreateNewViaOwner()
*                   Tests checking rights to create a client plan for account owner
*                 3 - testCheckRightsToCreateNewErrors()
*                   Tests errors handling during checking rights to create a client plan for account owner
*                 4 - testSharing()
*                   Tests sharing method
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 24-May-2016	Mohsin Wadee	In testSharing() method used getInsertedProduct() method to create test account instead.
* ---------------------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanTrigger_Helper {

        private static final String EDIT = 'Edit';

        private class ZZTEST_ClientPlanTrigger_HelperException extends Exception {
        }

        static testMethod void testCheckRightsToCreateNewViaTeamMember() {
                ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();

                ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
                Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

                ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
                User u1 = userFactory.getExistingUserByProfile('System Administrator');

                Account_Team_Member__c mem1 = new Account_Team_Member__c();
                mem1.Organisation__c = acc1.Id;
                mem1.Organisation_Access__c = 'Read/Write';
                mem1.Team_Member__c = u1.Id;
                mem1.Team_Role__c = 'Markets';
                insert mem1;

                System.runAs(u1) {
                        Client_Plan__c plan1 = new Client_Plan__c();
                        plan1.Relationship__c = acc1.Id;

                        Database.SaveResult[] saveResult = Database.INSERT(new List<Client_Plan__c>{plan1}, false);  
                        
                        System.assertEquals(1, saveResult.size());

                        Database.SaveResult r = saveResult[0];
                        System.assertEquals(true, r.isSuccess());
                }
        }

        static testMethod void testCheckRightsToCreateNewViaOwner() {
                ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();

                ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
                Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

                Client_Plan__c plan1 = new Client_Plan__c();
                plan1.Relationship__c = acc1.Id;

                Database.SaveResult[] saveResult = Database.INSERT(new List<Client_Plan__c>{plan1}, false); 

                System.assertEquals(1, saveResult.size());

                Database.SaveResult r = saveResult[0];
                System.assertEquals(true, r.isSuccess());
        }

        static testMethod void testCheckRightsToCreateNewErrors() {
                ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();

                ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
                Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);

                ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
                User u1 = userFactory.getExistingUserByProfile('System Administrator');

                System.runAs(u1) {
                        Client_Plan__c plan1 = new Client_Plan__c();
                        plan1.Relationship__c = acc1.Id;

                        Database.SaveResult[] saveResult = Database.INSERT(new List<Client_Plan__c>{plan1}, false);  
                        
                        System.assertEquals(1, saveResult.size());

                        Database.SaveResult r = saveResult[0];
                        System.assertEquals(false, r.isSuccess());
                        System.assertEquals(1, r.getErrors().size());
                        System.assertEquals(Label.errMsg_CantCreateClientPlan, r.getErrors()[0].getMessage());
                }
        }

        static testMethod void testSharing() {
                ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();

                //2 accounts
                ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
                Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
                Account acc2 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
            
                //1 user, second one is running user
                ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
                User u1 = userFactory.getExistingUserByProfile('System Administrator');

                //assigning user to account team
                Account_Team_Member__c mem1 = new Account_Team_Member__c();
                mem1.Organisation__c = acc1.Id;
                mem1.Organisation_Access__c = 'Read/Write';
                mem1.Team_Member__c = u1.Id;
                mem1.Team_Role__c = 'Markets';
                INSERT mem1;

                //2 client plans
                Client_Plan__c plan1 = new Client_Plan__c();
                plan1.Relationship__c = acc1.Id;
                Client_Plan__c plan2 = new Client_Plan__c();
                plan2.Relationship__c = acc2.Id;
				
                try {
                        INSERT new List<Client_Plan__c>{plan1, plan2};
                        throw new ZZTEST_ClientPlanTrigger_HelperException();
                } catch(Exception e) {
                        System.assertEquals(true, e instanceof ZZTEST_ClientPlanTrigger_HelperException);
                }

                List<Client_Plan__Share> shareRecs = [
                        SELECT  RowCause, AccessLevel
                        FROM    Client_Plan__Share
                        WHERE   ParentId = :plan1.Id AND UserOrGroupId = :u1.Id
                ];
                System.assertEquals(1, shareRecs.size());

                String userId = UserInfo.getUserId();

                shareRecs = [
                        SELECT  RowCause, AccessLevel
                        FROM    Client_Plan__Share
                        WHERE   ParentId = :plan1.Id AND UserOrGroupId = :userId
                ];
                //1 record for full access (ownership) and 1 for read/write
                System.assertEquals(2, shareRecs.size());

                shareRecs = [
                        SELECT  RowCause, AccessLevel
                        FROM    Client_Plan__Share
                        WHERE   ParentId = :plan2.Id AND UserOrGroupId = :userId
                ];
                //1 record for full access (ownership) and 1 for read/write
                System.assertEquals(2, shareRecs.size());
            
            	shareRecs = [
                        SELECT  RowCause, AccessLevel
                        FROM    Client_Plan__Share
                        WHERE   ParentId = :plan1.Id AND UserOrGroupId = :userId
                        AND RowCause =: Schema.Client_Plan__Share.RowCause.Client_Plan_Manager__c
                ];
                //1 record for current relationship owner
                System.assertEquals(1, shareRecs.size());
            	acc2.OwnerId = u1.Id;
            	UPDATE acc2;
            	shareRecs = [
                        SELECT  RowCause, AccessLevel
                        FROM    Client_Plan__Share
                        WHERE   ParentId = :plan1.Id AND UserOrGroupId = :userId
                        AND RowCause =: Schema.Client_Plan__Share.RowCause.Client_Plan_Manager__c
                ];
                //0 record for previous relationship owner after account owner update
                System.assertEquals(0, shareRecs.size());
        }
}