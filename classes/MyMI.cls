/**
  * @Author:          Dino Scarcella
  * @Company:         Absa Capital
  * @Description:     Class responsible for all MyMI integration
  * History
  * <Date>      <Authors Name>     <Brief Description of Change>
  *------------------------------------------------------------*/
public class MyMI {
	private String MYMI_BASE_ENDPOINT = '';
    private String MYMI_USERNAME = '';
    private String MYMI_PASSWORD = '';
    private String MYMI_APIID = '';
	private String MYMI_OPERATION_GETTOKEN = '';
    private String MYMI_OPERATION_CLIENTGROUPS = '';
	private Integer MYMI_SYNC_TIMEOUT = 0;
	private String X_IBM_Client_Id = '';
	private String X_IBM_Client_Secret = '';
    private ClientGroup ClientGroup_Feed;
    private List<Product_Setting__mdt> productSettings;
    public String errorMessage {get;set;}
    
    //constructor
    public MyMI() {
        for(Integration_Setting__mdt settings : [SELECT DeveloperName, Setting__c FROM Integration_Setting__mdt WHERE DeveloperName IN('MYMI_BASE_ENDPOINT','MYMI_USERNAME','MYMI_PASSWORD','MYMI_APIID','MYMI_OPERATION_GETTOKEN','MYMI_OPERATION_CLIENTGROUPS','MYMI_SYNC_TIMEOUT','X_IBM_Client_Id','X_IBM_Client_Secret')]){
            if (settings.DeveloperName == 'MYMI_BASE_ENDPOINT') MYMI_BASE_ENDPOINT = settings.Setting__c;
            if (settings.DeveloperName == 'MYMI_USERNAME') MYMI_USERNAME = settings.Setting__c;
            if (settings.DeveloperName == 'MYMI_PASSWORD') MYMI_PASSWORD = settings.Setting__c;
            if (settings.DeveloperName == 'MYMI_APIID') MYMI_APIID = settings.Setting__c;
            if (settings.DeveloperName == 'MYMI_OPERATION_GETTOKEN') MYMI_OPERATION_GETTOKEN = settings.Setting__c;
            if (settings.DeveloperName == 'MYMI_OPERATION_CLIENTGROUPS') MYMI_OPERATION_CLIENTGROUPS = settings.Setting__c;
            if (settings.DeveloperName == 'MYMI_SYNC_TIMEOUT') MYMI_SYNC_TIMEOUT = integer.valueof(settings.Setting__c);
            if (settings.DeveloperName == 'X_IBM_Client_Id') X_IBM_Client_Id = settings.Setting__c;
            if (settings.DeveloperName == 'X_IBM_Client_Secret') X_IBM_Client_Secret = settings.Setting__c;
        }
        productSettings = [SELECT ProductName__c, ProductHouse__c FROM Product_Setting__mdt WHERE ProductSet__c = 'MyMIGrouping'];
    }
    
    // Property method for the Subsidiaries which the REST call returns
    public ClientGroup ClientGroupFeed {
        get { return ClientGroup_Feed; }
    }
    
    // Synchronous method which calls the MyMI ClientGroup feed with cibkey
	public ClientGroup RetrieveClientGroupFeedSync(String cibkey) {
        errorMessage = '';
        
        //LoadMockData
        
        //StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name = 'MyMIClientGroupResponse' LIMIT 1];
		//String prefix = sr.NamespacePrefix;
		//if( String.isEmpty(prefix) ) {
    	//	prefix = '';
		//} else {
    	//	prefix += '__';
		//}
		//String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + prefix + 'MyMIClientGroupResponse'; 
		//PageReference pg = new PageReference(srPath);
		//String body = pg.getContent().toString();
        //ClientGroup_Feed = (ClientGroup)JSON.deserialize(body, ClientGroup.class);
        //calculateTotals();
        //return ClientGroup_Feed;
		
        //End LoadMockData
        
        TokenResponse token;
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(MYMI_BASE_ENDPOINT + MYMI_OPERATION_GETTOKEN);
		request.setMethod('POST');
		request.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
		request.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('User', UserInfo.getUserId() + ':' + UserInfo.getName());
        request.setBody('{\"userName\":\"' + MYMI_USERNAME + '\", \"password\":\"' + MYMI_PASSWORD + '\", \"apiid\":\"' + MYMI_APIID + '\"}');
		request.setTimeout(MYMI_SYNC_TIMEOUT);
		HttpResponse response = http.send(request);
		
		if (response != null && response.getStatusCode() == 200) {
			try {
				// Deserialize the TokenResponse from the JSON string.
            	token = (TokenResponse)JSON.deserialize(response.getBody(), TokenResponse.class);
			} catch (Exception e) {
            	errorMessage = e.getMessage();
                ClientGroup_Feed = null;return null;
            }
            if (token.message != null && token.message != 'Authorized') {
 				errorMessage = 'Couldn\'t authorize use of MYMI service';
                ClientGroup_Feed = null;return null;
            }
        } else {
        	errorMessage = 'Couldn\'t retrieve session token from MyMI';
            ClientGroup_Feed = null;return null;
        }
        
        // Builds the query strings based on the parameters passed to the method
		String QueryString='';
        if (cibkey != '') {
            QueryString = QueryString + '?cibkey=' + cibkey;
        } else {
         	errorMessage = 'No CIB Key available to query MyMI';
            ClientGroup_Feed = null;return null;   
        }
        http = new Http();
        request = new HttpRequest();
        request.setEndpoint(MYMI_BASE_ENDPOINT + MYMI_OPERATION_CLIENTGROUPS + QueryString);
        request.setMethod('GET');
        request.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
		request.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
        request.setHeader('Authorization', token.tokenType + ' ' + token.token);
        request.setHeader('User', UserInfo.getUserId() + ':' + UserInfo.getName());
        request.setTimeout(MYMI_SYNC_TIMEOUT);
        response = http.send(request);
        
        if (response != null && response.getStatusCode() == 200) {
			try {
				// Deserialize the ClientGroup from the JSON string.
            	ClientGroup_Feed = (ClientGroup)JSON.deserialize(response.getBody(), ClientGroup.class);
                calculateTotals();
			} catch (Exception e) {
                try {
                    Error err = (Error)JSON.deserialize(response.getBody(), Error.class);
                    if (err.status == 404) errorMessage = 'CIB Key not found in MyMI.'; else errorMessage = e.getMessage();
                } catch (Exception nfe) {
                	errorMessage = e.getMessage();
                }
                ClientGroup_Feed = null;return null;
            }
        } else {
        	if (response != null && response.getStatusCode()==404) errorMessage = 'CIB Key not found in MyMI.'; 
            else if (response != null) errorMessage = response.getStatus();
            else errorMessage = 'Could not retrieve data from MyMI.';
            ClientGroup_Feed = null;return null;
        }
        return ClientGroup_Feed;
	}
    
    public void calculateTotals() {
        // calculated Revenue fields after retrieval
        Double Revenue_Deposits=0;Double Revenue_TransactionProducts=0;Double Revenue_Equities=0;Double Revenue_FixedIncome=0; 
        Double Revenue_Debt=0;Double Revenue_Trade=0;Double Revenue_FX=0;Double Revenue_AssetSalesFinance=0;Double Revenue_OtherMADCMECM=0;
        Double Revenue_OtherRBBWealth=0;Double Revenue_OtherTrading=0;Double Revenue_CommercialPropertyFinance=0;Double Revenue_Passive=0;
        Double Revenue_PrimeServices=0;Double Revenue_PrivateEquity=0;Double Revenue_Treasury=0;Double Revenue_WorkingCapital=0;
        // calculated RWA fields after retrieval
        Double RWA_Deposits=0;Double RWA_TransactionProducts=0;Double RWA_Equities=0;Double RWA_FixedIncome=0;Double RWA_Debt=0;Double RWA_Trade=0;
        Double RWA_FX=0;Double RWA_AssetSalesFinance=0;Double RWA_OtherMADCMECM=0;Double RWA_OtherRBBWealth=0;Double RWA_OtherTrading=0;
        Double RWA_CommercialPropertyFinance=0;Double RWA_Passive=0;Double RWA_PrimeServices=0;Double RWA_PrivateEquity=0;Double RWA_Treasury=0;
        Double RWA_WorkingCapital=0;
        
        if (ClientGroup_Feed != null) {
            for(Subsidiary sub: ClientGroup_Feed.Subsidiaries) {
                for(Product prod: sub.Products) {
                    if (ProductMapped('Deposits', prod.ProductHouse)) {
                    	Revenue_Deposits += prod.Revenue;
                        RWA_Deposits += prod.RWA;
                    } else if (ProductMapped('TransactionProducts', prod.ProductHouse)) {
                    	Revenue_TransactionProducts += prod.Revenue;
                        RWA_TransactionProducts += prod.RWA;
                    } else if (ProductMapped('Equities', prod.ProductHouse)) {
                    	Revenue_Equities += prod.Revenue;
                        RWA_Equities += prod.RWA;
                    } else if (ProductMapped('FixedIncome', prod.ProductHouse)) {
                    	Revenue_FixedIncome += prod.Revenue;
                        RWA_FixedIncome += prod.RWA;
                    } else if (ProductMapped('Debt', prod.ProductHouse)) {
                    	Revenue_Debt += prod.Revenue;
                        RWA_Debt += prod.RWA;
                    } else if (ProductMapped('Trade', prod.ProductHouse)) {
                    	Revenue_Trade += prod.Revenue;
                        RWA_Trade += prod.RWA;
                    } else if (ProductMapped('FX', prod.ProductHouse)) {
                    	Revenue_FX += prod.Revenue;
                        RWA_FX += prod.RWA;
                    } else if (ProductMapped('AssetSalesFinance', prod.ProductHouse)) {
                    	Revenue_AssetSalesFinance += prod.Revenue;
                        RWA_AssetSalesFinance += prod.RWA;
                    } else if (ProductMapped('OtherMADCMECM', prod.ProductHouse)) {
                    	Revenue_OtherMADCMECM += prod.Revenue;
                        RWA_OtherMADCMECM += prod.RWA;
                    } else if (ProductMapped('OtherRBBWealth', prod.ProductHouse)) {
                    	Revenue_OtherRBBWealth += prod.Revenue;
                        RWA_OtherRBBWealth += prod.RWA;
                    } else if (ProductMapped('OtherTrading', prod.ProductHouse)) {
                    	Revenue_OtherTrading += prod.Revenue;
                        RWA_OtherTrading += prod.RWA;
                    } else if (ProductMapped('CommercialPropertyFinance', prod.ProductHouse)) {
                    	Revenue_CommercialPropertyFinance += prod.Revenue;
                        RWA_CommercialPropertyFinance += prod.RWA;
                    } else if (ProductMapped('Passive', prod.ProductHouse)) {
                    	Revenue_Passive += prod.Revenue;
                        RWA_Passive += prod.RWA;
                    } else if (ProductMapped('PrimeServices', prod.ProductHouse)) {
                    	Revenue_PrimeServices += prod.Revenue;
                        RWA_PrimeServices += prod.RWA;
                    } else if (ProductMapped('PrivateEquity', prod.ProductHouse)) {
                    	Revenue_PrivateEquity += prod.Revenue;
                        RWA_PrivateEquity += prod.RWA;
                    } else if (ProductMapped('Treasury', prod.ProductHouse)) {
                    	Revenue_Treasury += prod.Revenue;
                        RWA_Treasury += prod.RWA;
                    } else if (ProductMapped('WorkingCapital', prod.ProductHouse)) {
                    	Revenue_WorkingCapital += prod.Revenue;
                        RWA_WorkingCapital += prod.RWA;
                    }
                }
            }
            ClientGroup_Feed.RevenueDeposits = Revenue_Deposits.intValue();
            ClientGroup_Feed.RevenueTransactionProducts = Revenue_TransactionProducts.intValue();
            ClientGroup_Feed.RevenueEquities = Revenue_Equities.intValue();
            ClientGroup_Feed.RevenueFixedIncome = Revenue_FixedIncome.intValue();
            ClientGroup_Feed.RevenueDebt = Revenue_Debt.intValue();
            ClientGroup_Feed.RevenueTrade = Revenue_Trade.intValue();
            ClientGroup_Feed.RevenueFX = Revenue_FX.intValue();
            ClientGroup_Feed.RevenueAssetSalesFinance = Revenue_AssetSalesFinance.intValue();
            ClientGroup_Feed.RevenueOtherMADCMECM = Revenue_OtherMADCMECM.intValue();
            ClientGroup_Feed.RevenueOtherRBBWealth = Revenue_OtherRBBWealth.intValue();
            ClientGroup_Feed.RevenueOtherTrading = Revenue_OtherTrading.intValue();
            ClientGroup_Feed.RevenueCommercialPropertyFinance = Revenue_CommercialPropertyFinance.intValue();
            ClientGroup_Feed.RevenuePassive = Revenue_Passive.intValue();
            ClientGroup_Feed.RevenuePrimeServices = Revenue_PrimeServices.intValue();
            ClientGroup_Feed.RevenuePrivateEquity = Revenue_PriVateEquity.intValue();
            ClientGroup_Feed.RevenueTreasury = Revenue_Treasury.intValue();
            ClientGroup_Feed.RevenueWorkingCapital = Revenue_WorkingCapital.intValue();
            ClientGroup_Feed.RWADeposits = RWA_Deposits.intValue();
            ClientGroup_Feed.RWATransactionProducts = RWA_TransactionProducts.intValue();
            ClientGroup_Feed.RWAEquities = RWA_Equities.intValue();
            ClientGroup_Feed.RWAFixedIncome = RWA_FixedIncome.intValue();
            ClientGroup_Feed.RWADebt = RWA_Debt.intValue();
            ClientGroup_Feed.RWATrade = RWA_Trade.intValue();
            ClientGroup_Feed.RWAFX = RWA_FX.intValue();
            ClientGroup_Feed.RWAAssetSalesFinance = RWA_AssetSalesFinance.intValue();
            ClientGroup_Feed.RWAOtherMADCMECM = RWA_OtherMADCMECM.intValue();
            ClientGroup_Feed.RWAOtherRBBWealth = RWA_OtherRBBWealth.intValue();
            ClientGroup_Feed.RWAOtherTrading = RWA_OtherTrading.intValue();
            ClientGroup_Feed.RWACommercialPropertyFinance = RWA_CommercialPropertyFinance.intValue();
            ClientGroup_Feed.RWAPassive = RWA_Passive.intValue();
            ClientGroup_Feed.RWAPrimeServices = RWA_PrimeServices.intValue();
            ClientGroup_Feed.RWAPrivateEquity = RWA_PrivateEquity.intValue();
            ClientGroup_Feed.RWATreasury = RWA_Treasury.intValue();
            ClientGroup_Feed.RWAWorkingCapital = RWA_WorkingCapital.intValue();
        }
    }
    
    private Boolean ProductMapped(String product, String ProductHouse) {
        if (productSettings != NULL && productSettings.size() > 0) {
            for(Product_Setting__mdt ps: productSettings) {
                if (product != NULL && product != '' 
                    && ProductHouse != NULL && ProductHouse != '' 
                    && ps.ProductName__c != NULL && ps.ProductName__c != '' 
                    && ps.ProductHouse__c != NULL && ps.ProductHouse__c != '') 
                {
                    if (String.valueOf(ps.ProductHouse__c).equalsIgnoreCase(ProductHouse) && String.valueOf(ps.ProductName__c).equalsIgnoreCase(product)) {
                        return true;
                    }
                }
            }
        }
        return false;
    }
    
    public class TokenResponse {
        public String message {get;set;}
		public String token {get;set;}
        public String tokenType {get;set;}
    }
    
    public class ClientGroup {
		public String Key {get;set;}
		public String Name {get;set;}
		public Double Revenue {get;set;}
		public Double RWA {get;set;}
        public Subsidiary[] Subsidiaries;
        // calculated Revenue fields after retrieval
        public Double RevenueDeposits{get;set;}
        public Double RevenueTransactionProducts{get;set;}
        public Double RevenueEquities{get;set;}
        public Double RevenueFixedIncome{get;set;}
        public Double RevenueDebt{get;set;}
        public Double RevenueTrade{get;set;}
        public Double RevenueFX{get;set;}
        public Double RevenueAssetSalesFinance{get;set;}
        public Double RevenueOtherMADCMECM{get;set;}
        public Double RevenueOtherRBBWealth{get;set;}
        public Double RevenueOtherTrading{get;set;}
        public Double RevenueCommercialPropertyFinance{get;set;}
        public Double RevenuePassive{get;set;}
        public Double RevenuePrimeServices{get;set;}
        public Double RevenuePrivateEquity{get;set;}
        public Double RevenueTreasury{get;set;}
        public Double RevenueWorkingCapital{get;set;}
        // calculated RWA fields after retrieval
        public Double RWADeposits{get;set;}
        public Double RWATransactionProducts{get;set;}
        public Double RWAEquities{get;set;}
        public Double RWAFixedIncome{get;set;}
        public Double RWADebt{get;set;}
        public Double RWATrade{get;set;}
        public Double RWAFX{get;set;}
        public Double RWAAssetSalesFinance{get;set;}
        public Double RWAOtherMADCMECM{get;set;}
        public Double RWAOtherRBBWealth{get;set;}
        public Double RWAOtherTrading{get;set;}
        public Double RWACommercialPropertyFinance{get;set;}
        public Double RWAPassive{get;set;}
        public Double RWAPrimeServices{get;set;}
        public Double RWAPrivateEquity{get;set;}
        public Double RWATreasury{get;set;}
        public Double RWAWorkingCapital{get;set;}
        // get the data date after retrieval
        public DateTime DataDate {
            get {
                 for(Subsidiary sub: Subsidiaries) {
                     for(Product prod: sub.Products) {
                         if (prod.GetDataDate != NULL) return prod.GetDataDate;
                     }
                 }
                 return null;
            }
        }
    }
    
    public class Subsidiary {
    	public String Name {get;set;}
		public String ParentName {get;set;}
        public String ParentKey {get;set;}
        public String SDS {get;set;}
        public Double Revenue {get;set;}
		public Double RWA {get;set;}
        public Product[] Products;
    }
    
    public class Product {
        public String Name {get;set;}
        public Double Revenue {get;set;}
        public Double RWA {get;set;}
        public Double CostOfCapital {get;set;}
        public Double RoRWA {get;set;}
        public Double RevenueNetCostOfCapital {get;set;}
        public String MajorDesk {get;set;}
        public String ProductHouse {get;set;}
        public String BusinessArea {get;set;}
        public String DataDate {get;set;}
        public String MaturityDate {get;set;}
        public String ProductType {get;set;}
        public DateTime GetDataDate {
            get {
            	if (DataDate != NULL && DataDate.length() > 18) {
                    try {
                        Integer year = Integer.valueof(DataDate.substring(0,4));
                        Integer month = Integer.valueof(DataDate.substring(5,7));
                        Integer day = Integer.valueof(DataDate.substring(8,10));
                        Integer hour = Integer.valueof(DataDate.substring(11,13));
                        Integer minute = Integer.valueof(DataDate.substring(14,16));
                        Integer second = Integer.valueof(DataDate.substring(17,19));
                        return DateTime.newInstance(year, month, day, hour, minute, second);    
                    } catch (Exception e) {
                        return null;
                    }
            	} else {
            		return null;
        		}    
            }
        }
        public DateTime GetMaturityDate {
            get {
            	if (MaturityDate != NULL && MaturityDate.length() > 18) {
                    try {
                        Integer year = Integer.valueof(MaturityDate.substring(0,4));
                        Integer month = Integer.valueof(MaturityDate.substring(5,7));
                        Integer day = Integer.valueof(MaturityDate.substring(8,10));
                        Integer hour = Integer.valueof(MaturityDate.substring(11,13));
                        Integer minute = Integer.valueof(MaturityDate.substring(14,16));
                        Integer second = Integer.valueof(MaturityDate.substring(17,19));
                        return DateTime.newInstance(year, month, day, hour, minute, second);    
                    } catch (Exception e) {
                        return null;
                    }
            	} else {
            		return null;
        		}    
            }
        }
    }
    
    public class Error {
        public string type {get;set;}
        public string title {get;set;}
        public string detail {get;set;}
        public integer status {get;set;}
        public string statusText {get;set;}
    }
}