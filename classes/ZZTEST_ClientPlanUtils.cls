/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanUtils
*                 Tests executed:
*                 1 - testCreateSharingInstance()
*                   Tests method creating sharing record
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 23-May-2016	Mohsin Wadee	Added CreateTestClientPlan() method to create a test Client Plan.
* -----------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanUtils {

	private static final String EDIT = 'edit';

	@testSetup static void setup() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
        
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
	}
    
    public static testMethod Client_Plan__c CreateTestClientPlan()
    {   
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc1 = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.DEFAULT_ACCOUNT, dataContainer);
       
        Client_Plan__c ap = new Client_Plan__c();
        ap.Relationship__c = acc1.Id;
        insert ap;
        
        return ap;
    }

	static testMethod void testCreateSharingInstance() {
		Client_Plan__c plan = [SELECT Id FROM Client_Plan__c LIMIT 1];
		String userId = UserInfo.getUserId();

		//null params
		Client_Plan__Share result = ClientPlanUtils.createSharingInstance(null, null);
		System.assertEquals(null, result.ParentId);
		System.assertEquals(null, result.UserOrGroupId);
		System.assertEquals(EDIT, result.AccessLevel);
		System.assertEquals(Schema.Client_Plan__Share.RowCause.Client_Plan_Manager__c, result.RowCause);

		//not existing planId
		result = ClientPlanUtils.createSharingInstance('a', userId);
		System.assertEquals(null, result);

		//not existing user id
		result = ClientPlanUtils.createSharingInstance(plan.Id, 'b');
		System.assertEquals(null, result);

		//working code
		result = ClientPlanUtils.createSharingInstance(plan.Id, userId);
		System.assertEquals(plan.Id, result.ParentId);
		System.assertEquals(userId, result.UserOrGroupId);
		System.assertEquals(EDIT, result.AccessLevel);
		System.assertEquals(Schema.Client_Plan__Share.RowCause.Client_Plan_Manager__c, result.RowCause);
	}

}