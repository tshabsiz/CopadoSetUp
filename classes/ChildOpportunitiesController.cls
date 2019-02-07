/**
* @Author       Dino Scarcella
* Company:      ABSA Capital
* @Description: This class is used as a controller for ChildOpportunities page.
* @Date:        10/2017
* @ConstructorParam: stdController - Standard Controller for "Opportunity" object
* @TestClass:   ZZTEST_ChildOpportunitiesController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class ChildOpportunitiesController {
    private Opportunity opp;
    public List<ChildOpportunityWrapper> opportunityItems { get; set; }
    public Boolean Editing { get; set; }
    
	public ChildOpportunitiesController(ApexPages.StandardController stdController) {
        List<String> fieldNames  = new List<String>();
        
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.Opportunity.fields.getMap();
        for (String fieldName: schemaFieldMap.keySet()) {
            fieldNames.add(fieldName);
        }
        if(!test.isRunningTest()) stdController.addFields(fieldNames);

        opp = (Opportunity)stdController.getRecord();
        getOpportunities();
    }
    
    /**
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: This method is used to query all child Opportunities of a Parent Opportunity
    * @param        None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public void getOpportunities() {
    	opportunityItems = new List<ChildOpportunityWrapper>();
        List<Opportunity> allChildOpportunities;
        allChildOpportunities = [
            SELECT  Id, Name, Account.Name, Related_Group_Client__c, Annualised_Income__c, StageName, CloseDate,
            		(SELECT Product_Level_3__r.Name FROM OpportunityLineItems ORDER BY CreatedDate DESC LIMIT 1)
            FROM    Opportunity
            WHERE   Parent_Opportunity__c =: opp.Id
            ORDER BY CloseDate DESC
        ];
        
        for(Opportunity opp : allChildOpportunities) {
            Boolean opportunityIsSelectable = !(opp.StageName == 'Closed Lost' || opp.StageName == 'Closed Won');
            Boolean opportunitySelected = false;
        	opportunityItems.add(new ChildOpportunityWrapper(opportunityIsSelectable, opportunitySelected, opp));
        }
	}
    
    public PageReference StartEditing() {
        if (itemsSelected)
            Editing = true;
        else {
         	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Opportunities Selected'));
        }
        clearErrors();
        return null;
    }
    
    public PageReference CancelEditing() {
        Editing = false;
        return null;
    }
    
    public PageReference save() {  
    	List<Opportunity> oppsToUpdate = createOppsToUpdate();
        if (oppsToUpdate.size() > 0) {
            Savepoint sp = Database.setSavepoint();
            Database.SaveResult[] result = new Database.SaveResult[]{};
            result = Database.Update(oppsToUpdate, false);
            
            for (Integer i = 0; i < oppsToUpdate.size(); i++) {
            	Database.SaveResult sr = result[i];
                if (!sr.isSuccess()) {
                	String errors = '';
                    for(Database.Error err : sr.getErrors()) errors = errors + err.getMessage();
                    SetError(oppsToUpdate[i].Id,errors);
                    if (i == 0) ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Update Error on Parent Opportunity: ' + errors));
                }
            }
            if (ErrorsExist) 
                Database.rollback(sp); //rollback, there were errors
            else {
            	PageReference parentOpportunityPage = new PageReference('/apex/ChildOpportunitiesRefreshParentPage?oppId=' + opp.Id);
                return parentOpportunityPage;
            }
        }
        Editing = false;
        return null;
    }
    
    private List<Opportunity> createOppsToUpdate() {
    	List<Opportunity> oppsToUpdate = new List<Opportunity>();
        // Add parent to update
        if (opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost')
        	oppsToUpdate.add(new Opportunity(Id = opp.Id, StageName = opp.StageName, CloseDate = opp.CloseDate, Reason_Won_Lost__c = opp.Reason_Won_Lost__c, Product_Code_Won_Opportunity__c = opp.Product_Code_Won_Opportunity__c, Loss_Win_Description__c = opp.Loss_Win_Description__c, Closed_via_Visual_Workflow__c = true));
        if (opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost')
            oppsToUpdate.add(new Opportunity(Id = opp.Id, StageName = opp.StageName, CloseDate = opp.CloseDate));
        // Add children to update
        for (ChildOpportunityWrapper oppitem : opportunityItems) {
            if (oppitem.isSelected && (opp.StageName == 'Closed Won' || opp.StageName == 'Closed Lost'))
                oppsToUpdate.add(new Opportunity(Id = oppitem.opportunity.Id, StageName = opp.StageName, CloseDate = opp.CloseDate, Reason_Won_Lost__c = opp.Reason_Won_Lost__c, Product_Code_Won_Opportunity__c = opp.Product_Code_Won_Opportunity__c, Loss_Win_Description__c = opp.Loss_Win_Description__c, Closed_via_Visual_Workflow__c = true));
            if (oppitem.isSelected && opp.StageName != 'Closed Won' && opp.StageName != 'Closed Lost')
                oppsToUpdate.add(new Opportunity(Id = oppitem.opportunity.Id, StageName = opp.StageName, CloseDate = opp.CloseDate));
        }
        return oppsToUpdate;
    }
    
    public Boolean itemsSelected { 
        get{
            for (ChildOpportunityWrapper oppitem : opportunityItems)
                if (oppitem.isSelected) return true;
            return false;
    	} 
    }
    
    public Boolean ErrorsExist { 
        get{
            for (ChildOpportunityWrapper oppitem : opportunityItems)
                if (oppitem.error!='') return true;
            return false;
    	} 
    }
    
    private void SetError(Id oppId, String error) {
        for(ChildOpportunityWrapper oppitem : opportunityItems) {
        	if (oppId == oppitem.opportunity.Id)
                oppitem.error = error;
        }
    }
    
    private void ClearErrors() {
        for(ChildOpportunityWrapper oppitem : opportunityItems) oppitem.error = '';
    }
    
    public class ChildOpportunityWrapper {
        public Boolean isSelectable { get; set; }
		public Boolean isSelected { get; set; }
		public Opportunity opportunity { get; set; }
        public String error { get; set; }

		public ChildOpportunityWrapper(Boolean isSelectable, Boolean isSelected, Opportunity opportunity) {
            this.isSelectable = isSelectable;
			this.isSelected = isSelected;
			this.opportunity = opportunity;
            this.error = '';
		}
	}
}