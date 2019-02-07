/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for TasksGanttChartController
*/
@isTest
private class ZZTEST_ActionTrigger {
	public static testMethod void testInitiativeActions(){
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Initiative initiativeFactory = ZZTEST_DataFactoryFacade.initiative;
		ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_Action actionFactory = ZZTEST_DataFactoryFacade.action;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		User barclaysStdUser = userFactory.getBarclaysStandardUser();

		Initiative__c initiative1 = initiativeFactory.getInsertedProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer);
		Initiative__c initiative2 = initiativeFactory.getInsertedProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer);

		List<Section__c> sections = new List<Section__c>();
		Section__c section1 = new Section__c(Name='Section1', Initiative__c=initiative1.Id);
		sections.add(section1);
		Section__c section2 = new Section__c(Name='Section2', Initiative__c=initiative2.Id);
		sections.add(section2);
		insert sections;

		Integer batchSize = 200;
		List<Action__c> actions = new List<Action__c>();
		for(Integer i=0; i<=batchSize; i++){
			Action__c action = actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.DEFAULT_ACTION, dataContainer);
			action.Section__c = section1.Id;
			action.Action_Owner__c = barclaysStdUser.Id;
			actions.add(action);
		}

		Test.startTest();

			Database.DMLOptions dml = new Database.DMLOptions(); 
        	dml.DuplicateRuleHeader.AllowSave = true;
        	List<Database.SaveResult> srList = Database.insert(actions,dml);
        	Set<Id> actionIds = new Set<Id>();
        	for(Database.SaveResult sr : srList){
        		if(sr.isSuccess()){
        			actionIds.add(sr.getId());
        		}
        	}

        	for(Action__c action : [SELECT Initiative__c FROM Action__c WHERE Id IN :actionIds]){
        		System.assertEquals(action.Initiative__c, initiative1.Id);
        	}

        	for(Action__c action : actions){
        		action.Section__c = section2.Id;
        	}
        	srList = Database.update(actions,dml);

        	for(Action__c action : [SELECT Initiative__c FROM Action__c WHERE Id IN :actionIds]){
        		System.assertEquals(action.Initiative__c, initiative2.Id);
        	}

		Test.stopTest();
        }
		
	}

	public static testMethod void testCommitteeActions(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Committee committeeFactory = ZZTEST_DataFactoryFacade.committee;
		ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_Action actionFactory = ZZTEST_DataFactoryFacade.action;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Committee__c committee1 = committeeFactory.getInsertedProduct(ZZTEST_F_Committee.CommitteeRecordType.DEFAULT_COMMITTEE, dataContainer);
		Committee__c committee2 = committeeFactory.getInsertedProduct(ZZTEST_F_Committee.CommitteeRecordType.DEFAULT_COMMITTEE, dataContainer);
		
		List<Meeting__c> meetings = new List<Meeting__c>();
		Meeting__c meeting1 = meetingFactory.getProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);
		meeting1.Committee__c = committee1.Id;
		meetings.add(meeting1);
		Meeting__c meeting2 = meetingFactory.getProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);
		meeting2.Committee__c = committee2.Id;
		meetings.add(meeting2);
		insert meetings;

		Integer batchSize = 200;
		List<Action__c> actions = new List<Action__c>();
		for(Integer i=0; i<=batchSize; i++){
			Action__c action = actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.DEFAULT_ACTION, dataContainer);
			action.Meeting__c = meeting1.Id;
			actions.add(action);
		}

		Test.startTest();

			Database.DMLOptions dml = new Database.DMLOptions(); 
        	dml.DuplicateRuleHeader.AllowSave = true;
        	List<Database.SaveResult> srList = Database.insert(actions,dml);
        	Set<Id> actionIds = new Set<Id>();
        	for(Database.SaveResult sr : srList){
        		if(sr.isSuccess()){
        			actionIds.add(sr.getId());
        		}
        	}

        	for(Action__c action : [SELECT Committee__c FROM Action__c WHERE Id IN :actionIds]){
        		System.assertEquals(action.Committee__c, committee1.Id);
        	}

        	for(Action__c action : actions){
        		action.Meeting__c = meeting2.Id;
        	}
        	srList = Database.update(actions,dml);

        	for(Action__c action : [SELECT Committee__c FROM Action__c WHERE Id IN :actionIds]){
        		System.assertEquals(action.Committee__c, committee2.Id);
        	}

		Test.stopTest();
	}
}