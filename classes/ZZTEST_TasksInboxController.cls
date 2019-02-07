/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for TasksGanttChartController
*/
@isTest
private class ZZTEST_TasksInboxController {
	public static testMethod void testTasksInboxAssignments(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Initiative initiativeFactory = ZZTEST_DataFactoryFacade.initiative;
		ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_Action actionFactory = ZZTEST_DataFactoryFacade.action;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		User barclaysStdUser = userFactory.getBarclaysStandardUser();
        PermissionSet collaboration = [SELECT Id FROM PermissionSet WHERE Name = 'Collaboration'];
        insert new PermissionSetAssignment(PermissionSetId = collaboration.Id, AssigneeId = barclaysStdUser.Id);

        System.runAs(barclaysStdUser) {

			Initiative__c initiative = initiativeFactory.getInsertedProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer);
			Meeting__c meeting = meetingFactory.getInsertedProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);

			Integer batchSize = 200;
			List<Action__c> actions = new List<Action__c>();
			for(Integer i=0; i<=batchSize; i++){
				Action__c action = actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.DEFAULT_ACTION, dataContainer);
				action.Status__c = TasksInboxController.STATUS_OPEN;
				if(i < 100){
					action.Initiative__c = initiative.Id;
				} else{
					action.Meeting__c = meeting.Id;
				}
				actions.add(action);
			}

			Database.DMLOptions dml = new Database.DMLOptions(); 
        	dml.DuplicateRuleHeader.AllowSave = true;
        	List<Database.SaveResult> srList = Database.insert(actions,dml);

        	//Create Tasks
			List<Task> tasks = new List<Task>();
			for(Action__c action : actions){
				Task task = new Task();
				task.WhatId = action.Id;
				task.ActivityDate = Date.today();
				tasks.add(task);
			}
			insert tasks;

        	Test.startTest();

        	TasksInboxController controller = new TasksInboxController();
        	controller.getFilterOptions();
        	controller.getDateFilterOptions();
        	List<TasksInboxController.TaskItem> taskItems = controller.getTaskItems();
        	System.assertEquals(taskItems.size(), 2*(batchSize+1));
        	
			Test.stopTest();

		}
	}

	public static testMethod void testTasksInboxDelegated(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Initiative initiativeFactory = ZZTEST_DataFactoryFacade.initiative;
		ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_Action actionFactory = ZZTEST_DataFactoryFacade.action;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Initiative__c initiative = initiativeFactory.getInsertedProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer);
		Meeting__c meeting = meetingFactory.getInsertedProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);

		Integer batchSize = 200;
		List<Action__c> actions = new List<Action__c>();
		for(Integer i=0; i<=batchSize; i++){
			Action__c action = actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.DEFAULT_ACTION, dataContainer);
			action.Status__c = TasksInboxController.STATUS_OPEN;
			if(i < 100){
				action.Initiative__c = initiative.Id;
			} else{
				action.Meeting__c = meeting.Id;
			}
			actions.add(action);
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.SaveResult> srList = Database.insert(actions,dml);

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		User barclaysStdUser;
    	System.runAs (thisUser) {
        	barclaysStdUser = userFactory.getBarclaysStandardUser();
    	}

        //Create Action Assignments
        List<Action_Assignment__c> actionAssignments = new List<Action_Assignment__c>();
        for(Action__c action : actions){
        	actionAssignments.add(new Action_Assignment__c(Action__c=action.Id, Assigned_to__c=barclaysStdUser.Id));
        }
        insert actionAssignments;

        //Create Tasks
		List<Task> tasks = new List<Task>();
		for(Action__c action : actions){
			Task task = new Task();
			task.OwnerId = barclaysStdUser.Id;
			task.WhatId = action.Id;
			task.ActivityDate = Date.today();
			tasks.add(task);
		}
		insert tasks;

        Test.startTest();

        TasksInboxController controller = new TasksInboxController();
        controller.getFilterOptions();
        controller.getDateFilterOptions();
        controller.filterOption = TasksInboxController.MY_DELEGATED;
        List<TasksInboxController.TaskItem> taskItems = controller.getTaskItems();
        System.assertEquals(taskItems.size(), 2*(batchSize+1));
        	
		Test.stopTest();

	}

	public static testMethod void testTasksInboxFollowers(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Initiative initiativeFactory = ZZTEST_DataFactoryFacade.initiative;
		ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_Action actionFactory = ZZTEST_DataFactoryFacade.action;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Initiative__c initiative = initiativeFactory.getInsertedProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer);
		Meeting__c meeting = meetingFactory.getInsertedProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);

		Integer batchSize = 200;
		List<Action__c> actions = new List<Action__c>();
		for(Integer i=0; i<=batchSize; i++){
			Action__c action = actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.DEFAULT_ACTION, dataContainer);
			action.Status__c = TasksInboxController.STATUS_OPEN;
			if(i < 100){
				action.Initiative__c = initiative.Id;
			} else{
				action.Meeting__c = meeting.Id;
			}
			actions.add(action);
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;
        List<Database.SaveResult> srList = Database.insert(actions,dml);

        //Create Tasks
		List<Task> tasks = new List<Task>();
		for(Action__c action : actions){
			Task task = new Task();
			task.WhatId = action.Id;
			task.ActivityDate = Date.today();
			tasks.add(task);
		}
		insert tasks;

        Test.startTest();

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		User barclaysStdUser;
    	System.runAs (thisUser) {
        	barclaysStdUser = userFactory.getBarclaysStandardUser();
    	}
    	
        //Create Action Followers
        List<Action_Follower__c> actionFollowers = new List<Action_Follower__c>();
        for(Action__c action : actions){
        	actionFollowers.add(new Action_Follower__c(Action__c=action.Id, Follower__c=barclaysStdUser.Id));
        }
        insert actionFollowers;

        System.runAs(barclaysStdUser) {
        	TasksInboxController controller = new TasksInboxController();
        	controller.getFilterOptions();
        	controller.getDateFilterOptions();
        	controller.filterOption = TasksInboxController.WHAT_I_FOLLOW;
        	List<TasksInboxController.TaskItem> taskItems = controller.getTaskItems();
        	System.assertEquals(taskItems.size(), batchSize+1);
        }

		Test.stopTest();
	}
}