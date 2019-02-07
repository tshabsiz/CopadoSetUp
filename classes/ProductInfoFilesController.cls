/**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-570 - VF page for SF1 to list Product collateral files. This allows
*					users to view all documents from the Salesforce1 App
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/

public with sharing class ProductInfoFilesController {
	// Property method to build the dropdown that shows the Top Level Product Categories
    public List<SelectOption> TopLevelCategories {
        get
        {
            List<SelectOption> top_level_categories = new List<SelectOption>();
            for (Barclays_SA__Category__c cat : [SELECT Id, Name FROM Barclays_SA__Category__c WHERE Barclays_SA__Is_Top_Level__c = 1 ORDER BY Name]) {
            	SelectOption option = new SelectOption(cat.Id,cat.Name);
                top_level_categories.add(option);
            }
            return top_level_categories;
        }
    }
    
    // Property method to build the dropdown that shows the Product Sub Categories
    public List<SelectOption> SubCategories {
        get
        {
        	List<SelectOption> sub_categories = new List<SelectOption>();
            for (Barclays_SA__Category__c cat : [SELECT Id, Name FROM Barclays_SA__Category__c 
            										WHERE Barclays_SA__Is_Top_Level__c = 0 
            										AND Barclays_SA__Parent_Category__c =: SelectedTopLevelCategory ORDER BY Name]) {
            	SelectOption option = new SelectOption(cat.Id,cat.Name);
                sub_categories.add(option);
            }
            SelectedSubCategory = '--SELECT--';
            return sub_categories;
        }
    }
    
    // Property methods to keep track of what we have selected
    public String SelectedTopLevelCategory { get;set; }
    public String SelectedSubCategory {	get;set; }
    public List<ContentWorkspaceDoc> Files { get;set; }
    public Set<String> DocumentIDs { get;set; }
    
    public PageReference getFiles() {
    		Set<Id> categoryids = new Set<Id>();
    		if ((SelectedTopLevelCategory!=null && SelectedTopLevelCategory!='--SELECT--') && (SelectedSubCategory==null || SelectedSubCategory=='--SELECT--')) 
    			categoryids.add(SelectedTopLevelCategory);
    		if (SelectedSubCategory!=null && SelectedSubCategory!='--SELECT--') categoryids.add(SelectedSubCategory);
    		if (SelectedTopLevelCategory==null || SelectedTopLevelCategory=='--SELECT--') {
    			SelectedSubCategory = '--SELECT--';
    			Files = null;
    			return null;
    		}
    	
    		Set<String> ContentIds = new Set<String>();
    		for (Barclays_SA__Cat_Content_Junction__c junction : [
    			SELECT Barclays_SA__ContentId__c FROM Barclays_SA__Cat_Content_Junction__c 
    			WHERE Barclays_SA__Category__c IN : categoryids
    			AND IsDeleted = false
    		]) ContentIds.add(junction.Barclays_SA__ContentId__c);
    	
    		Files = [SELECT ContentDocumentID, ContentDocument.ContentModifiedDate
						FROM ContentWorkspaceDoc WHERE ContentDocumentId 
						IN : ContentIds 
						ORDER BY ContentDocument.Title];
        
        	DocumentIDs = new Set<String>();
    		for(ContentWorkspaceDoc cwd : Files) {
    			DocumentIDs.add(cwd.ContentDocumentID);
    		}
        
			return null;
    }
}