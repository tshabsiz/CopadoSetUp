/**
* @Author:        Marek Cech
* @Company:       Deloitte
* @Description:   Unit Tests for ClientPlanPotentialOppModalController
*                 Tests executed:
*                 1 - testGetStageOptions()
*                     Tests that method returns correct picklist values.
*                 2 - testGetTypeOptions()
*                     Tests that method returns correct picklist values.
*				  3 - testGetCountryOptions()
*					  Tests that method returns correct picklist values.
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 30.5.2017   Dino Scarcella     Changed stages to CIB stages to test against for testOptyStageOptions
* 12.6.2017	  Dino Scarcella	 Added method for getting country options on the Strategy Tab on Client Plan
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_ClientPlanPotentialOppModalCtr {

    static testMethod void testGetUnqOptyStageOptions() {
        Set<String> expected = new Set<String>();
        
        Schema.DescribeFieldResult f = Potential_Opportunity__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        for(Schema.PicklistEntry e: p) {
            expected.add(e.getLabel());
        }
        
        ClientPlanPotentialOppModalController ctrl = new ClientPlanPotentialOppModalController();
        List<String> result = ctrl.getUnqOptyStageOptions();
        for(String s: result) {
            System.assertEquals(true, expected.contains(s));
        }
    }
    
    static testMethod void testOptyStageOptions() {
        Set<String> expected = new Set<String>();
        
        Schema.DescribeFieldResult f = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        for(Schema.PicklistEntry e : p) {
        	if (e.getLabel() == 'Opportunity Identified' || e.getLabel() == 'Client Engaged' || e.getLabel() == 'Needs Established' || e.getLabel() == 'Initial Solution Proposed' || e.getLabel() == 'Credit Case Submitted')
                expected.add(e.getLabel()); 
        }
        
        ClientPlanPotentialOppModalController ctrl = new ClientPlanPotentialOppModalController();
        List<String> result = ctrl.getOptyStageOptions();
        for(String s: result) {
            System.assertEquals(true, expected.contains(s));
        }
    }
    
    static testMethod void testGetTypeOptions() {
        Set<String> expected = new Set<String>();
        
        Schema.DescribeFieldResult f = Potential_Opportunity__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        for(Schema.PicklistEntry e: p) {
            expected.add(e.getLabel());
        }
        
        ClientPlanPotentialOppModalController ctrl = new ClientPlanPotentialOppModalController();
        List<String> result = ctrl.getTypeOptions();
        for(String s: result) {
            System.assertEquals(true, expected.contains(s));
        }
    }
    
    static testMethod void testGetCountryOptions() {
        Set<String> expected = new Set<String>();
        
        Schema.DescribeFieldResult f = Opportunity.Opportunity_Country__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        expected.add('');
        for(Schema.PicklistEntry e: p) {
            expected.add(e.value);
        }
        
        ClientPlanPotentialOppModalController ctrl = new ClientPlanPotentialOppModalController();
        List<SelectOption> result = ctrl.getOptyCountryOptions();
        for(SelectOption s: result) {
            System.assertEquals(true, expected.contains(s.getValue()));
        }
    }
}