/**
* @Author:        Dino Scarcella
* @Company:       ABSA Capital
* @Description:   Unit Tests for UserTrigger_Helper
*                   Tests executed:
*                   1 - testUpdateOpportunityAndCallReportRelationshipOwnerRole()
*                       Checks that RelationshipOwnerRoleName__c is updated on call reports and opps when user role is modified
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
public class ZZTEST_UserTrigger_Helper {
	public static testMethod void testUpdateOpportunityAndCallReportRelationshipOwnerRole() {
    	ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        ZZTEST_F_Call_Report callReportFactory = ZZTEST_DataFactoryFacade.callReport;
		
		User thisUser = [SELECT Id, UserRole.Name, UserRoleId FROM User WHERE Id = :UserInfo.getUserId()];
        UserRole anotherRole = [SELECT Id, Name FROM UserRole WHERE Id != :UserInfo.getUserRoleId() LIMIT 1];
        System.runAs (thisUser) {
            Test.startTest();
	        Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
	        insert opp;
            Call_Report__c callRep = callReportFactory.getInsertedProduct(ZZTEST_F_Call_Report.CallReportRecordType.DEFAULT_CALL_REPORT, dataContainer);
            
	        Account oppacc = new Account(Id = opp.AccountId);
            oppacc.OwnerId = thisUser.Id;
	        update oppacc;
            
            Account cracc = new Account(Id = opp.AccountId);
            cracc.OwnerId = thisUser.Id;
	        update cracc;
            
	        Opportunity insertedOpp = [SELECT Id, RelationshipOwnerRoleName__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            System.assertEquals(thisUser.UserRole.Name, insertedOpp.RelationshipOwnerRoleName__c);
            
            thisUser.UserRoleId = anotherRole.Id;
            update thisUser;
            Test.stopTest();
            
            insertedOpp = [SELECT Id, Segment__c, RelationshipOwnerRoleName__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
            Call_Report__c insertedCR = [SELECT Id, RelationshipOwnerRoleName__c FROM Call_Report__c WHERE Id = :callRep.Id LIMIT 1];
            System.assertEquals(anotherRole.Name, insertedOpp.RelationshipOwnerRoleName__c);
            System.assertEquals(anotherRole.Name, insertedCR.RelationshipOwnerRoleName__c);
        }
    }
}