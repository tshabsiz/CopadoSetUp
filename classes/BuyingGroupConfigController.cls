public with sharing class BuyingGroupConfigController {

	public Id buyingCentreId;
	public List<Account> portfolioItems { 
		get{
			return [SELECT Id, Name FROM Account WHERE ParentId = :buyingCentreId ORDER BY Name];
		}
	 	set; 
	}
	public String accountName { get; set; }
	public List<Account> accounts { get; set; }
	public Boolean showAddBtn { get; set; }
	public Boolean showSearchResults { get; set; }

	public BuyingGroupConfigController(ApexPages.StandardController stdController) {
		buyingCentreId = ApexPages.currentPage().getParameters().get('id');
		showAddBtn = false;
		showSearchResults = false;
	}
/*
	public List<Account> getPortfolioItems() {    
        return [SELECT Id, Name FROM Account WHERE ParentId = :buyingCentreId ORDER BY Name];
    }
*/
    public void runSearch() {
		if (String.isNotBlank(accountName) && accountName.length()>1){
			String soql = 'SELECT Id, Name, Owner.Name, Parent.Name FROM Account WHERE Account.RecordType.DeveloperName != \'Buying_Group\'';
			soql += ' AND Name LIKE \''+String.escapeSingleQuotes(accountName)+'%\' ORDER BY Name LIMIT 20';
			accounts = Database.query(soql);
			showSearchResults = true;
		} else{
			accounts = new List<Account>();
			showSearchResults = false;
		}
		showAddBtn = false;
	}

	public void setShowSearchResults(){
		accountName = '';
		showAddBtn = true;
		showSearchResults = false;
	}

    @RemoteAction
    public static void addClientsToPortfolio(List<String> clients, String accountId) {
    	List<Account> accountsToUpd = new List<Account>();
    	
		for(String clientId : clients){
			Account a = new Account(Id=clientId);
			a.ParentId = accountId;
			accountsToUpd.add(a);
		}
		updateRecords(accountsToUpd);
    }

    public void removePortfolioItem() {
    	Id clientId = Apexpages.currentpage().getParameters().get('clientId');
    	Account account = new Account(Id=clientId);
		account.ParentId = null;
		try{
			update account;
		} catch(System.DmlException ex){
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_RemoveOrganisationFromBuyingGroup));
		}
    }

  	public static void updateRecords(List<SObject> records){
		Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        Database.SaveResult[] srList = Database.update(records, dml);
	}
}