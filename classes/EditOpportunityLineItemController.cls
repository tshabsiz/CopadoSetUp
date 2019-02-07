/**
* @author Deloitte 
* @date 2015
*
* @group Add product to opportunity
*
* @description controller for redirect page for edit on opportunity line item
*/

public class EditOpportunityLineItemController {

    public String oppId { get; private set; }
    public String lineId { get; private set; }
    
    public EditOpportunityLineItemController (ApexPages.StandardController stdController) {
        lineId = ApexPages.currentPage().getParameters().get('id');
        
        OpportunityLineItem o = [SELECT OpportunityId FROM OpportunityLineItem WHERE Id =: lineId];
        
        oppId = o.OpportunityId;
    }
}