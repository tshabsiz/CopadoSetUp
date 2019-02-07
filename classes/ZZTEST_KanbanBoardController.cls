/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for TasksGanttChartController
*/
@isTest
private class ZZTEST_KanbanBoardController {
	public static testMethod void testKanbanBoard(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
		ZZTEST_F_Initiative initiativeFactory = ZZTEST_DataFactoryFacade.initiative;
		ZZTEST_F_Action actionFactory = ZZTEST_DataFactoryFacade.action;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		//Create Initiative
		Initiative__c initiative = initiativeFactory.getInsertedProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer);

		//Create Sections
		List<Section__c> sections = new List<Section__c>();
		sections.add(new Section__c(Name='Section1', Initiative__c=initiative.Id));
		sections.add(new Section__c(Name='Section2', Initiative__c=initiative.Id));
		insert sections;

		//Create Actions
		List<Action__c> actions = new List<Action__c>();
		for(Section__c section : sections){
			Action__c action = actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.DEFAULT_ACTION, dataContainer);
			action.Section__c = section.Id;
			actions.add(action);
		}
		insert actions;

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        PageReference KanbanBoard = Page.KanbanBoard;
        Test.setCurrentPage(KanbanBoard);
    	ApexPages.currentPage().getParameters().put('Id', initiative.Id);
        Apexpages.Standardcontroller stdCtr = new ApexPages.StandardController(initiative);
        KanbanBoardController controller = new KanbanBoardController(stdCtr);

		Test.stopTest();
	}
}