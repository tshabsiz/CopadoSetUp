/**
* @Author       Dino Scarcella
* @Company:     Absa Capital
* @Description: Helper for Drawdowns Trigger
* @Date:        2018-08-28
* @ConstructorParam:      None
* @TestClass:   ZZTEST_DrawdownsTrigger_Helper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------*/

public without sharing class DrawdownsTrigger_Helper {
	/**
	* @Author:          Dino Scarcella
	* @Company:         Absa Capital
	* @Description:     CIBDIGSALP-2279+2294 - Method to update fields for first drawdown date and amount should the opportunity come from Oberon
	* @Returns:         void
	* History
	* <Date>      <Authors Name>    <Brief Description of Change> 
	*------------------------------------------------------------*/
    public static void UpdateFirstDrawdown(List<Drawdowns__c> triggerNew, List<Drawdowns__c> triggerOld, Map<Id, Drawdowns__c> triggeroldMap) {
        Boolean RunTrigger = false;
        Set<Id> oppIds = new Set<Id>();
        // deletes (only run if it's from External System or a Resource and Project Finance Opportunity)
        if (triggerNew == NULL) {
        	for(Drawdowns__c dd : triggerOld)
            {
                if (dd.isExternal__c != NULL && dd.isExternal__c == true || (dd.ProductLevel2List__c != NULL && dd.ProductLevel2List__c.Contains('Resource and Project Finance'))) {
                	if (!oppIds.Contains(dd.Opportunity__c)) oppIds.add(dd.Opportunity__c);
                	RunTrigger = true;
                }
            }
        // updates (only run if drawdown date or amount were changed and opportunity was pushed from external system or a Resource and Project Finance Opportunity)
        } else if (triggerNew != NULL && triggerOld != NULL) {
            for(Drawdowns__c dd : triggerNew)
            {
                if (
                    (dd.isExternal__c != NULL && dd.isExternal__c == true || (dd.ProductLevel2List__c != NULL && dd.ProductLevel2List__c.Contains('Resource and Project Finance')))
                    && 
                   	(
                        triggerOldMap.get(dd.Id).Drawdown_date__c != dd.Drawdown_date__c || triggerOldMap.get(dd.Id).Drawdown_Amount__c != dd.Drawdown_Amount__c 
                   	)
                   ) 
                {
                    if (!oppIds.Contains(dd.Opportunity__c)) oppIds.add(dd.Opportunity__c);
                	RunTrigger = true;
                }
            }
        // inserts (only run if it's from External System or a Resource and Project Finance Opportunity)
        } else if (triggerNew != NULL){
        	for(Drawdowns__c dd : triggerNew)
            {
                if (dd.isExternal__c != NULL && dd.isExternal__c == true || (dd.ProductLevel2List__c != NULL && dd.ProductLevel2List__c.Contains('Resource and Project Finance'))) {
            		if (!oppIds.Contains(dd.Opportunity__c)) oppIds.add(dd.Opportunity__c);
                	RunTrigger = true;
                }
            }    
        }
        if (!RunTrigger) return;
        
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        List<Drawdowns__c> dds = [SELECT Id, Drawdown_date__c, Drawdown_Amount__c, Opportunity__c
                                  FROM Drawdowns__c
                                  WHERE Opportunity__c IN: oppIds];
        
        for (Id oppId : oppIds) {
            Date MinDate = NULL;
            Decimal MinAmount = NULL;
        	for (Drawdowns__c dd : dds) {
                if (dd.Drawdown_date__c != NULL && (MinDate == NULL || dd.Drawdown_date__c < MinDate) && dd.Opportunity__c == oppId) {
                    MinDate = dd.Drawdown_date__c;
                    MinAmount = dd.Drawdown_Amount__c;
                }
            }
            oppsToUpdate.add(new Opportunity(Id = oppId, First_Drawdown_Manual__c = MinDate, First_Drawdown_Amount__c = MinAmount));
        }
        
        Database.SaveResult[] results = Database.update(oppsToUpdate,false);
        for(Database.SaveResult r : results)
        {
         	if(!r.isSuccess())
            {
                for(Database.Error err : r.getErrors()) System.debug('Failed to update First Drawdown:' + err.getMessage());
            }
        }
    }
}