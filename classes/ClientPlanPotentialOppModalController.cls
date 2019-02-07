/**
* @Author        Marek Cech
* @Company:      Deloitte
* @Description:  Controller class for UnqualifiedOpportunityModal VF component.
* @Date:         09/2015
* @Constructor param:       None
* @TestClass:    ZZTEST_UnqOpportunityModalController 
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 13.06.2017  Dino Scarcella	 Added method to get Country Options for Add Opportunity modal
*------------------------------------------------------------*/
public class ClientPlanPotentialOppModalController {

    /**
    * @Author:        Marek Cech
    * @Company:       Deloitte
    * @Description:   Prepares unqualified opportunity Stage__c picklist values to List<String>
    * @Param:         None
    * @Returns:       List<String>
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public List<String> getUnqOptyStageOptions() {
        List<String> options = new List<String>();
        
        Schema.DescribeFieldResult f = Potential_Opportunity__c.Stage__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        for(Schema.PicklistEntry e : p) {
            options.add(e.getLabel());
        }

        return options;
    }
    
    /**
    * @Author:        Marek Cech
    * @Company:       Deloitte
    * @Description:   Prepares opportunity Stage__c picklist values to List<String>
    * @Param:         None
    * @Returns:       List<String>
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 30.05.2017  Dino Scarcella	 Changed getOptyStageOptions to get the CIB opp stages
    *------------------------------------------------------------*/
    public List<String> getOptyStageOptions() {
        List<String> options = new List<String>();
        
        Schema.DescribeFieldResult f = Opportunity.StageName.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        for(Schema.PicklistEntry e : p) {
        	if (e.getLabel() == 'Opportunity Identified' || e.getLabel() == 'Client Engaged' || e.getLabel() == 'Needs Established' || e.getLabel() == 'Initial Solution Proposed' || e.getLabel() == 'Credit Case Submitted')
                options.add(e.getLabel());
        }

        return options;
    }
    
    /**
    * @Author:        Marek Cech
    * @Company:       Deloitte
    * @Description:   Prepares Type__c picklist values to List<String>
    * @Param:         None
    * @Returns:       List<String>
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public List<String> getTypeOptions() {
        List<String> options = new List<String>();
        
        Schema.DescribeFieldResult f = Potential_Opportunity__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        for(Schema.PicklistEntry e: p) {
            options.add(e.getLabel());
        }

        return options;
    }
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     prepares select options of opportunity country field
		* @Returns:         List<SelectOption> - prepared list of select options
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public List<SelectOption> getOptyCountryOptions() {
		List<SelectOption> options = new List<SelectOption>();
        
        Schema.DescribeFieldResult f = Opportunity.Opportunity_Country__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        options.add(new SelectOption('',''));
        for(Schema.PicklistEntry e: p) {
            options.add(new SelectOption(e.value,e.getLabel()));
        }

        return options;
	}
}