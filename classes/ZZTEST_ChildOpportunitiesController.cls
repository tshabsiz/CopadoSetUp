/**
* @Author:        Dino Scarcella
* @Company:       ABSA Capital
* @Description:   Unit Tests for ChildOpportunitiesController
*                   Tests executed:
*                   1 - testChildOpportunitiesController()
*						Tests main functionality related to Child Opportunities VF Page                       
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ChildOpportunitiesController {
	public static testMethod void testChildOpportunitiesController() {
        // First create a User
        ZZTEST_F_User userFactory = ZZTEST_F_User.getInstance();
        User u = userFactory.getBarclaysStandardUser();

        System.runAs(u) {
            ZZTEST_F_Opportunity oppFactory = ZZTEST_DataFactoryFacade.opportunity;
            // Create Opportunities
            ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
            Opportunity parentOpp = oppFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
            Opportunity childOpp = oppFactory.getProduct(ZZTEST_F_Opportunity.OpportunityRecordType.DEFAULT_OPPORTUNITY, dataContainer);
			
            // Create link between child and parent opportunity
            parentOpp.Is_Parent_Opportunity__c = 'Yes';
            insert parentOpp;
        	childOpp.Parent_Opportunity__c = parentOpp.Id;
        	insert childOpp;
            
            // Initialize controller
            PageReference pipelineReportPage = Page.ChildOpportunities;
            Test.setCurrentPage(pipelineReportPage);
            Apexpages.Standardcontroller stc = new ApexPages.StandardController(parentOpp);
            ChildOpportunitiesController ctrl = new ChildOpportunitiesController(stc);
            
            Test.startTest();
            // Simulate a user selecting to edit an opportunity before selecting anything
            ctrl.StartEditing();
            // Simulate a user selecting an opportunity
            ctrl.opportunityItems[0].isSelected = true;
            // Simulate a user selecting to edit the opportunity selected
            ctrl.StartEditing();
            System.assertEquals(true, ctrl.Editing);
            System.assertEquals(false, ctrl.ErrorsExist);
            // Update the parentOpportunity
            parentOpp.StageName = 'Closed Won';
            parentOpp.Probability = 100;
            parentOpp.Reason_Won_Lost__c = 'Other';
            parentOpp.Closed_via_Visual_Workflow__c = true;
            parentOpp.ProductLevel3Count__c = 1;
            parentOpp.Notify_ABSA_Insurance_Of_This_Deal__c = 'No';
            update parentOpp;
            // Simulate a user saving
            ctrl.save();
            // Simulate a user cancelling edit on opportunity selected
            ctrl.CancelEditing();
            System.assertEquals(false, ctrl.Editing);
            Test.stopTest();
        }
    }
}