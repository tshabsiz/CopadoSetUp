/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for TasksGanttChartController
*/
@isTest
private class ZZTEST_TasksGanttChartController
{
	public static testMethod void testGanttChart(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Program programFactory = ZZTEST_DataFactoryFacade.program;
		ZZTEST_F_Initiative initiativeFactory = ZZTEST_DataFactoryFacade.initiative;
		ZZTEST_F_Action actionFactory = ZZTEST_DataFactoryFacade.action;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		//Create Programs
		List<Program__c> programs = new List<Program__c>();
		Program__c program1 = programFactory.getProduct(ZZTEST_F_Program.ProgramRecordType.DEFAULT_PROGRAM, dataContainer);
		Program__c program2 = programFactory.getProduct(ZZTEST_F_Program.ProgramRecordType.DEFAULT_PROGRAM, dataContainer);
		programs.add(program1);
		programs.add(program2);
		insert programs;

		//Create Initiatives
		List<Initiative__c> initiativesForProgram1 = new List<Initiative__c>();
		List<Initiative__c> initiativesForProgram2 = new List<Initiative__c>();
		for(Integer i=0; i<=10; i++){
			initiativesForProgram1.add(initiativeFactory.getProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer));
		}
		insert initiativesForProgram1;
		for(Integer i=0; i<=10; i++){
			initiativesForProgram2.add(initiativeFactory.getProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer));
		}
		insert initiativesForProgram2;

		//Create Sections
		List<Section__c> sections = new List<Section__c>();
		for(Initiative__c init : initiativesForProgram1){
			sections.add(new Section__c(Name='Section1', Initiative__c=init.Id));
			sections.add(new Section__c(Name='Section2', Initiative__c=init.Id));
		}
		for(Initiative__c init : initiativesForProgram2){
			sections.add(new Section__c(Name='Section1', Initiative__c=init.Id));
			sections.add(new Section__c(Name='Section2', Initiative__c=init.Id));
		}
		insert sections;

		//Create Actions
		List<Action__c> actions = new List<Action__c>();
		for(Initiative__c init : initiativesForProgram1){
			Action__c action = actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.DEFAULT_ACTION, dataContainer);
			action.Initiative__c = init.Id;
			actions.add(action);
		}
		for(Section__c section : sections){
			Action__c action = actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.DEFAULT_ACTION, dataContainer);
			action.Section__c = section.Id;
			actions.add(action);
		}
		insert actions;

		//Create Tasks
		List<Task> tasks = new List<Task>();
		for(Action__c action : actions){
			Task task = new Task();
			task.WhatId = action.Id;
			task.ActivityDate = Date.today();
			tasks.add(task);
		}
		insert tasks;

		//Create connections between Programs and Initiatives
		List<Program_Connector__c> programConnectors = new List<Program_Connector__c>();
		for(Initiative__c init : initiativesForProgram1){
			programConnectors.add(new Program_Connector__c(Initiative__c=init.Id, Program__c=program1.Id));
		}
		for(Initiative__c init : initiativesForProgram2){
			programConnectors.add(new Program_Connector__c(Initiative__c=init.Id, Program__c=program2.Id));
		}
		insert programConnectors;

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        TasksGanttChartController controller = new TasksGanttChartController();
        String programsList = TasksGanttChartController.getAllPrograms();
        String initiativeList = TasksGanttChartController.getAllInitiatives();

        //System.assertEquals(programsList.size(), 2);
        
        String programId =  program1.Id;
        String initiativeId =  initiativesForProgram1[0].Id;

        TasksGanttChartController.getGanttChartDataForProgram(programId, true, true, true, true);
        TasksGanttChartController.getGanttChartDataForInitiative(initiativeId);

		Test.stopTest();
	}
}