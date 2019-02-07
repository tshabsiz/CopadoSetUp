/**
*** CHANGE LOG ***

16/11/2017 - TdB    - Created Class.
					- Link Financial Covenenats (Conditions)  to Margin Ratchet
06/12/2017 - TdB 	- Add Warning Message for no active conditions

**/ 

public class Margin_Ratchet_Conditions_Bulk{
    
    public List<sObject_Scheduling_Occurences.FinancialCovenantsWrapper> FinancialCovenantConditionWrapper { get; set; }
    public List<Margin_Ratchet_Conditions__c> existingMarginRatchetConditions { get; set; }
    public List<Condition__c> existingConditions { get; set; }
    public List<sObject> objectParentRecord { get; set; }
    public Set<Id> existingConditionSet { get; set; }
    public Map<Id, Id> conditionMarginRatchetCondition { get; set; }
    public Boolean showError { get; set; }
    public Id currentObjectId;
    public String currentObjectName; 
    public Id parentObjectId;
    public Boolean activeConditions { get; set; }
    
    public Margin_Ratchet_Conditions_Bulk()
    {
        //Empty wrappers
        FinancialCovenantConditionWrapper = new  List<sObject_Scheduling_Occurences.FinancialCovenantsWrapper>();
        existingMarginRatchetConditions = new List<Margin_Ratchet_Conditions__c>();
        existingConditions = new  List<Condition__c>();
        objectParentRecord = new List<sObject>();
        existingConditionSet = new Set<Id>();
        conditionMarginRatchetCondition = new Map<Id, Id>();
        
        //Get Record Id from URL
        if(ApexPages.currentPage().getParameters().get('sObjectId') != null)
        {
            currentObjectId = Id.valueOf(ApexPages.currentPage().getParameters().get('sObjectId'));
        }
        
        //Get Object API Name based on Id
        currentObjectName = currentObjectId.getSObjectType().getDescribe().getName();
        
        //Margin Ratchet
        if(currentObjectName  == 'Margin_Ratchet__c')
        {
            //Get Margin Ratchet Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Agreement__r.Matter_Deal__c  FROM Margin_Ratchet__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification financialCovenants
            existingMarginRatchetConditions = [SELECT Id, Margin_Ratchet__c, Condition__c  FROM Margin_Ratchet_Conditions__c WHERE Margin_Ratchet__c = : currentObjectId]; 
            
            if(objectParentRecord.size() > 0)
            {
                //Call class with method to get list of financialCovenants
                sObject_Scheduling_Occurences.getFinancialCovenants((Id)objectParentRecord[0].get('Agreement__c'));
                //Get financialCovenants linked to Agreement
                existingConditions = sObject_Scheduling_Occurences.financialCovenantList;
                
                if(existingConditions.size() == 0)
                {
                    activeConditions = false;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.INFO,'No active Financial Covenants on the Agreement'));
                }
                else
                {
                    activeConditions = true;
                }
            }
        }

        if(!existingMarginRatchetConditions.isEmpty())
        {
            //Build a set of existing Notification financialCovenants
            for(Margin_Ratchet_Conditions__c eachMarginRatchetCondition : existingMarginRatchetConditions)
            {
                if(!existingConditionSet.contains(eachMarginRatchetCondition.Condition__c))
                {
                    existingConditionSet.add(eachMarginRatchetCondition.Condition__c);  
                } 
                
                //Add to map for use later to track deselected.
                conditionMarginRatchetCondition.put(eachMarginRatchetCondition.Condition__c, eachMarginRatchetCondition.Id);
            } 
        }
        
        initialiseWrapperList();
    }
    
    public void initialiseWrapperList()
    {
        //Loop through financialCovenants Wrapper, check if financialCovenant already created as a Notification financialCovenant and flag as True
        for(Condition__c eachCondition : existingConditions)
        {
            sObject_Scheduling_Occurences.FinancialCovenantsWrapper wrapperItem = new sObject_Scheduling_Occurences.FinancialCovenantsWrapper();
            wrapperItem.financialCovenant = eachCondition;
            
            if(existingConditionSet.contains(eachCondition.Id))
            {
                wrapperItem.selected = true;   
            }
            
            //Add to main wrapper list.
            FinancialCovenantConditionWrapper.add(wrapperItem);
        }
    }
    
    public PageReference saveRecord() 
    {
        List<Margin_Ratchet_Conditions__c> marginRatchetConditionsInsert = new List<Margin_Ratchet_Conditions__c>();
        List<Margin_Ratchet_Conditions__c> marginRatchetConditionsDelete = new List<Margin_Ratchet_Conditions__c>();
        
        //Reset error message.
        showError = true;
        
        //Loop through wrapper list.
        for(sObject_Scheduling_Occurences.FinancialCovenantsWrapper eachWrapper : FinancialCovenantConditionWrapper)
        {
            //If selected
            if(eachWrapper.selected)
            {
                //One is selected at least.
                showError = false;
                
                if(!existingConditionSet.contains(eachWrapper.financialCovenant.Id))
                {
                    //New Notification financialCovenant
                    Margin_Ratchet_Conditions__c marginRatchetConditionsItem = new Margin_Ratchet_Conditions__c();
                    marginRatchetConditionsItem.Margin_Ratchet__c = currentObjectId;
                    marginRatchetConditionsItem.Condition__c = eachWrapper.financialCovenant.Id;
                    
                    //Add to list.
                    marginRatchetConditionsInsert.add(marginRatchetConditionsItem);
                }
            }
            //If deselected
            else
            {
                if(existingConditionSet.contains(eachWrapper.financialCovenant.Id))
                {
                    //Id of financialCovenant to delete.
                    Id financialCovenantNotificationId = (Id)conditionMarginRatchetCondition.get(eachWrapper.financialCovenant.Id);
                    
                    //Notification financialCovenant to delete.
                    Margin_Ratchet_Conditions__c marginRatchetConditionsItemToDelete = new Margin_Ratchet_Conditions__c(Id = financialCovenantNotificationId); 
                    
                    //Add to delete list.
                    marginRatchetConditionsDelete.add(marginRatchetConditionsItemToDelete);
                }
            }
        }
        
        //Execute changes.
        try 
        {
            //Insert new records.
            if(!marginRatchetConditionsInsert.isEmpty())
            {
                insert marginRatchetConditionsInsert;
            }
            
            //Delete deselected records.
            if(!marginRatchetConditionsDelete.isEmpty())
            {
                delete marginRatchetConditionsDelete;
            }
            
            //New Page Setup
            PageReference standardPage = new PageReference('/'+ currentObjectId); 
            standardPage.setRedirect(true);
            
            //Redirect.
            return standardPage;
        }
        catch(Exception e)
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }
        return null;
    }
    
    public PageReference cancel() 
    {
		PageReference standardPage = new PageReference('/'+ currentObjectId); 
        standardPage.setRedirect(true);
        return standardPage;
    }
}