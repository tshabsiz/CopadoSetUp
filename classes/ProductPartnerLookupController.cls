/**
* @Author       Dino Scarcella
* Company:      Absa Capital
* @Description: Controller for VF page for Product Partner Lookup
* @Date:        07/2017
* @ConstructorParam: N/A
* @TestClass:   ZZTEST_ProductPartnerLookupController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 28.02.2018  Dino Scarcella	 Added filters for Product Partners to choose should 
*------------------------------------------------------------*/
public with sharing class ProductPartnerLookupController {

  public List<User> results{get;set;} // search results
  public string searchString{get;set;} // search keyword
  public boolean excludeProductPartner{get;set;} // search criteria
  public string opportunityId{get;set;} // opportunity id to filter based on anything opportunity related
  public string productLevel1{get;set;} // the product level 1 selected on the AddProductToOpportunity Page
  public string productLevel2{get;set;} // the product level 2 selected on the AddProductToOpportunity Page
  public string productLevel3{get;set;} // the product level 3 selected on the AddProductToOpportunity Page
  private Map<Id, Product2> mapProducts; // map of all product level 1
  private Map<Id, Product_Level_2__c> mapProductLevel2; // map of all product level 2
  private Map<Id, Product_Level_3__c> mapProductLevel3; // map of all product level 3

  public ProductPartnerLookupController() {
    // get the current search string
    searchString = System.currentPageReference().getParameters().get('lksrch');
    excludeProductPartner = System.currentPageReference().getParameters().get('ExcludeProductPartner').equals('true');
    opportunityId = System.currentPageReference().getParameters().get('OpportunityId');
    productLevel1 = System.currentPageReference().getParameters().get('ProductLevel1');
    productLevel2 = System.currentPageReference().getParameters().get('ProductLevel2');
    productLevel3 = System.currentPageReference().getParameters().get('ProductLevel3');
    mapProducts = new Map<Id, Product2>([SELECT Id, Name FROM Product2 WHERE IsActive=:true]);
    mapProductLevel2 = new Map<Id, Product_Level_2__c>([SELECT Id, Name FROM Product_Level_2__c WHERE Active__c=:true]);
    mapProductLevel3 = new Map<Id, Product_Level_3__c>([SELECT Id, Name FROM Product_Level_3__c WHERE Active__c=:true]);
    runSearch();  
  }

  // performs the keyword search
  public PageReference search() {
    runSearch();
    return null;
  }

  // prepare the query and issue the search command
  private void runSearch() {
    // TODO prepare query string for complex serarches & prevent injections
    results = performSearch(searchString);               
  } 

  // run the search and return the records found. 
  private List<User> performSearch(string searchString) {
	List<Opportunity> opp = new List<Opportunity>();
    
    if(opportunityId != null && opportunityId != '') opp = [SELECT OwnerId, Opportunity_Country__c FROM Opportunity WHERE Id =:opportunityId LIMIT 1];
      
    String soql = 'select Id, Name, Hub__c, Team__c, Country from User';
    soql = soql +  ' where isActive = true';
    if(searchString != '' && searchString != null)
      	soql = soql + ' and name LIKE \'%' + searchString +'%\'';
    if(excludeProductPartner && !Test.isRunningTest()) {
     	soql = soql + ' and (Team_Role__c = \'Product Partner\'';
      	soql = soql + ((opp.size() > 0 && opp[0].OwnerId != null) ? ' or Id = \'' + opp[0].OwnerId + '\')' : ')');
    }
	if (excludeProductPartner) soql = soql + FilterProductPartners(opp);
    soql = soql + ' and Profile.Name != \'Chatter Free User\'';
   	soql = soql + ' order by name';
    soql = soql + ' limit 25';
    System.debug(soql);
    return database.query(soql); 

  }

  // used by the visualforce page to send the link to the right dom element
  public string getFormTag() {
    return System.currentPageReference().getParameters().get('frm');
  }

  // used by the visualforce page to send the link to the right dom element for the text box
  public string getTextBox() {
    return System.currentPageReference().getParameters().get('txt');
  }

  private String FilterProductPartners(List<Opportunity> opp) {
    List<Product_Setting__mdt> ProductSettings = [SELECT ProductName__c, Product_Partner_Team__c, ProductLevel__c, OpportunityCountry__c
        					 					  FROM Product_Setting__mdt
                             					  WHERE ProductSet__c = 'ProductPartnerFilter'
                                                  ORDER BY ProductLevel__c DESC];
    String whereclause = ' and Team__c IN (';
      
    for(Product_Setting__mdt ps : ProductSettings) {
        if (
           		(
                    (productLevel1 != NULL && productLevel1 != '' && ps.ProductLevel__c == 1 && mapProducts.containsKey(productLevel1) && mapProducts.get(productLevel1).Name == ps.ProductName__c) ||
                    (productLevel2 != NULL && productLevel2 != '' && ps.ProductLevel__c == 2 && mapProductLevel2.containsKey(productLevel2) && mapProductLevel2.get(productLevel2).Name == ps.ProductName__c) ||
                    (productLevel3 != NULL && productLevel3 != '' && ps.ProductLevel__c == 3 && mapProductLevel3.containsKey(productLevel3) && mapProductLevel3.get(productLevel3).Name == ps.ProductName__c)
                ) &&
            	(opp.size() == 0 || ps.OpportunityCountry__c == NULL || String.IsBlank(ps.OpportunityCountry__c) || (opp.size() > 0 && (opp[0].Opportunity_Country__c == NULL || String.IsBlank(opp[0].Opportunity_Country__c) || (opp[0].Opportunity_Country__c != NULL && SettingExists(ps.OpportunityCountry__c, opp[0].Opportunity_Country__c)))))
           )
        {
            if (ps.Product_Partner_Team__c != NULL && ps.Product_Partner_Team__c != '') {
            	for(String team : ps.Product_Partner_Team__c.Split('\\|')) {
                      whereclause += '\'' + team + '\',';
            	}
                break;
            }
        }
    }
   
    if  (whereclause == ' and Team__c IN (') return '';
    else return whereclause.removeEnd(',') + ')';
      
    return whereclause;
  }
    
  private Boolean SettingExists(String setting, String searchSetting) {
  	for(String s : setting.Split('\\|')) {
        if (s.trim() == searchSetting.trim()) return true;
    }
    return false;
  }
}