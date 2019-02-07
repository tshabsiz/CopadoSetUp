/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests - Opportunity Team Member Trigger
* 
* 07.07.2016	Mohsin Wadee	SFA-327	Unmarked testCheckCompliance() and testCheckComplianceBatch() as test methods
*										as deal members no longer have to be marked as cleared.
*/
@isTest
public class ZZTEST_OpportunityTeamMemberTrigger {

	public static void testCheckCompliance() {

		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);

		OpportunityTeamMember oppTeamMember = new OpportunityTeamMember(OpportunityId = opp.Id, UserId=UserInfo.getUserId());
		Test.startTest();
		try{
			insert oppTeamMember;
		} catch(DmlException ex){
			System.assertEquals(ex.getDmlMessage(0), System.Label.errMsg_OpportunityTeamMemberCheckCompliance);
		}
		oppTeamMember.I_confirm_team_member_has_been_cleared__c = true;
		insert oppTeamMember;
		oppTeamMember.I_confirm_team_member_has_been_cleared__c = false;
		try{
			update oppTeamMember;
		} catch(DmlException ex){
			System.assertEquals(ex.getDmlMessage(0), System.Label.errMsg_OpportunityTeamMemberCheckCompliance);
		}
		Test.stopTest();
	}

	public static void testCheckComplianceBatch() {
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
        Opportunity opp = opportunityFactory.getInsertedProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, 
            dataContainer);

        // set opportunity as private
        opp.Private_Side__c = true;
        update opp;

		List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
		oppTeamMembers.add(new OpportunityTeamMember(OpportunityId = opp.Id, I_confirm_team_member_has_been_cleared__c = true));
		oppTeamMembers.add(new OpportunityTeamMember(OpportunityId = opp.Id, I_confirm_team_member_has_been_cleared__c = true));
		oppTeamMembers.add(new OpportunityTeamMember(OpportunityId = opp.Id, I_confirm_team_member_has_been_cleared__c = false));
		Test.startTest();
		try{
			insert oppTeamMembers;
		} catch(DmlException ex){
			System.assertEquals(ex.getDmlMessage(0), System.Label.errMsg_OpportunityTeamMemberCheckCompliance);
		}
		Test.stopTest();
	}

	public static testMethod void testChatterDailyDigestForOpportunityTeamMember() {
        ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select ID from user where ID=:UserInfo.getuserId()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
            
            User u = userFactory.getBarclaysStandardUser();
            Integer batchSize = 200;
            
            List<Opportunity> opps = new List<Opportunity>();
            for(Integer i=0; i<=batchSize; i++){
                opps.add(opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer));
            }
            insert opps;
            
            List<Id> oppIds = new List<Id>();
            List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
            for(Opportunity opp : opps){
                oppTeamMembers.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId=u.Id, TeamMemberRole='Member Role', I_confirm_team_member_has_been_cleared__c = true));
                oppIds.add(opp.Id);
            }
            
            Test.startTest();
            
            insert oppTeamMembers;
            
            List<EntitySubscription> subscriptions = [SELECT Id, parentId, subscriberId FROM EntitySubscription WHERE parentId IN :oppIds];
            List<FeedItem> posts = [SELECT Id FROM FeedItem WHERE ParentId IN :oppIds AND Type = :ChatterUtils.TEXT_POST];
            
            System.assertEquals(subscriptions.size(), batchSize+1);
            System.assertEquals(posts.size(), batchSize+1);
            
            delete oppTeamMembers;
            
            subscriptions = [SELECT Id, parentId, subscriberId FROM EntitySubscription WHERE parentId IN :oppIds];
            System.assertEquals(subscriptions.size(), 0);
            
            Test.stopTest();
        }
        
    }

	public static testMethod void shareJlocWithOpportunityTeamMembers(){
        
        User user1 =[Select ID from User where id=:UserInfo.getUserId()];
        
        System.runAs(user1)
        {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            ZZTEST_F_Opportunity opportunityFactory = ZZTEST_DataFactoryFacade.opportunity;
            ZZTEST_F_JLOC jlocFactory = ZZTEST_DataFactoryFacade.jloc;
            ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;
            
            JLOC__c jloc = jlocFactory.getInsertedProduct(ZZTEST_F_JLOC.JlocRecordType.DEFAULT_JLOC, dataContainer);
            
            Integer batchSize = 200;
            List<Opportunity> opportunities = new List<Opportunity>();
            for(Integer i=0; i<=batchSize; i++){
                Opportunity opp = opportunityFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
                opp.JLOC__c = jloc.Id;
                opportunities.add(opp);
            }
            insert opportunities;
            
            Database.DMLOptions dml = new Database.DMLOptions(); 
            dml.DuplicateRuleHeader.AllowSave = true;
            
            Test.startTest();
            
            User barclaysStdUser = userFactory.getBarclaysStandardUser();
            List<OpportunityTeamMember> oppTeamMembers = new List<OpportunityTeamMember>();
            for(Opportunity opp : opportunities){
                oppTeamMembers.add(new OpportunityTeamMember(OpportunityId = opp.Id, UserId=barclaysStdUser.Id, I_confirm_team_member_has_been_cleared__c=true));
            }
            List<Database.SaveResult> srList = Database.insert(oppTeamMembers,dml);
            
            List<JLOC__Share> dealTeamSharings = [SELECT Id FROM JLOC__Share WHERE RowCause = 'Opportunity_Team_Member__c' AND UserOrGroupId = :barclaysStdUser.Id AND ParentId = :jloc.Id];
            System.assertEquals(dealTeamSharings.size(), 1);
            
            delete oppTeamMembers;
            dealTeamSharings = [SELECT Id FROM JLOC__Share WHERE RowCause = 'Opportunity_Team_Member__c' AND UserOrGroupId = :barclaysStdUser.Id AND ParentId = :jloc.Id];
            System.assertEquals(dealTeamSharings.size(), 0);
            
            Test.stopTest();
        }
        
    }
}