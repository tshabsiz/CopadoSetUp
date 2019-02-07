public without sharing class ClientPlanRevenueByProductController {
	public String refreshElement { get; set; }

	public String clientPlanId { get; set; }
	public Client_Plan_Revenue_By_Product__c revByProd { get; set; }
	public String accountCurrency { get; set; }

    public Boolean PulledFromMyMI { get {return revByProd!=NULL && revByProd.LastPulledfromMyMI__c!=NULL;}}
    public String CIBKey { get; set; }
    private Map<String,Double> conversion_rates = new Map<String,Double>();
    
	public ClientPlanRevenueByProductController() {
        clientPlanId = ApexPages.currentPage().getParameters().get('planId');
        
        if(String.isEmpty(clientPlanId)) {
            clientPlanId = ApexPages.currentPage().getParameters().get('id');
        }

        if(!String.isEmpty(clientPlanId)) {
        	this.queryRevenueByProduct();

        	if(revByProd == null) {
				revByProd = new Client_Plan_Revenue_By_Product__c();
				revByProd.Client_Plan__c = clientPlanId;

				//Default RoRWA checkboxes
				/*
				revByProd.rorwa_Deposits__c = true;
				revByProd.rorwa_TransactionProducts__c = true;
				revByProd.rorwa_Derivatives__c = true;
				revByProd.rorwa_Debt__c = true;
				revByProd.rorwa_Trade__c = true;
				*/
			}

			Client_Plan__c cp = [SELECT Id, Relationship__r.Id, Relationship__r.CurrencyIsoCode, Relationship__r.MyMI_CIB_Parent_ID__c FROM Client_Plan__c WHERE Id = :clientPlanId];
			if(cp != null && cp.Relationship__r.CurrencyIsoCode != '') {
				accountCurrency = cp.Relationship__r.CurrencyIsoCode;
			} else {
				accountCurrency = null;
			}
            if(cp != null && cp.Relationship__r.MyMI_CIB_Parent_ID__c != NULL && cp.Relationship__r.MyMI_CIB_Parent_ID__c != '') CIBKey = cp.Relationship__r.MyMI_CIB_Parent_ID__c;
            else CIBKey = NULL;
        } else {
        	ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'No ClientPlan'));
        }
        
        for(CurrencyType curr: [SELECT IsoCode,ConversionRate 
                                             FROM CurrencyType WHERE IsActive=TRUE]){
            conversion_rates.put(curr.IsoCode,curr.ConversionRate);        
        }
    }

    public void save() {  
		try {
			if(String.isEmpty(revByProd.Id)) {
				// Match Revenue By Products Currency with the Relationship Currency before inserting
				if (accountCurrency != null) revByProd.CurrencyIsoCode = accountCurrency;
				INSERT revByProd;
			} else {
				if (accountCurrency != null) revByProd.CurrencyIsoCode = accountCurrency;
				UPDATE revByProd;
			}

			//Fetch new data to get updated formula fields for the totals
			this.queryRevenueByProduct();

			//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Saved successfully'));
		} catch(exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error whilst saving: ' + e));
		}
	}

	private void queryRevenueByProduct() {
		List<Client_Plan_Revenue_By_Product__c> revByProdList = [
    		SELECT Client_Plan__c, CreatedById, CreatedDate, CurrencyIsoCode, F12_AssetSalesFinance__c, F12_AverageDepositBalance__c, F12_Debt__c, F12_Deposits__c, F12_Derivatives__c, F12_FX__c, F12_OtherMADCMECM__c, F12_OtherRBBWealth__c, F12_OtherTrade__c, F12_Trade__c, F12_TransactionProducts__c, F12_CommercialPropertyFinance__c, F12_Equities__c, F12_FixedIncome__c, F12_Passive__c, F12_PrimeServices__c, F12_PrivateEquity__c, F12_Treasury__c, F12_WorkingCapital__c, F12P_AssetSalesFinance__c, F12P_AverageDepositBalance__c, F12P_Debt__c, F12P_Deposits__c, F12P_Derivatives__c, F12P_FX__c, F12P_OtherMADCMECM__c, F12P_OtherRBBWealth__c, F12P_OtherTrade__c, F12P_Trade__c, F12P_TransactionProducts__c, F12P_CommercialPropertyFinance__c, F12P_Equities__c, F12P_FixedIncome__c, F12P_Passive__c, F12P_PrimeServices__c, F12P_PrivateEquity__c, F12P_Treasury__c, F12P_WorkingCapital__c, F24_AssetSalesFinance__c, F24_AverageDepositBalance__c, F24_Debt__c, F24_Deposits__c, F24_Derivatives__c, F24_FX__c, F24_OtherMADCMECM__c, F24_OtherRBBWealth__c, F24_OtherTrade__c, F24_Trade__c, F24_TransactionProducts__c, F24_CommercialPropertyFinance__c, F24_Equities__c, F24_FixedIncome__c, F24_Passive__c, F24_PrimeServices__c, F24_PrivateEquity__c, F24_Treasury__c, F24_WorkingCapital__c, F24P_AssetSalesFinance__c, F24P_AverageDepositBalance__c, F24P_Debt__c, F24P_Deposits__c, F24P_Derivatives__c, F24P_FX__c, F24P_OtherMADCMECM__c, F24P_OtherRBBWealth__c, F24P_OtherTrade__c, F24P_Trade__c, F24P_TransactionProducts__c, F24P_CommercialPropertyFinance__c, F24P_Equities__c, F24P_FixedIncome__c, F24P_Passive__c, F24P_PrimeServices__c, F24P_PrivateEquity__c, F24P_Treasury__c, F24P_WorkingCapital__c, H12_AssetSalesFinance__c, H12_AverageDepositBalance__c, H12_Debt__c, H12_Deposits__c, H12_Derivatives__c, H12_FX__c, H12_OtherMADCMECM__c, H12_OtherRBBWealth__c, H12_OtherTrade__c, H12_Trade__c, H12_TransactionProducts__c, H12_CommercialPropertyFinance__c, H12_Equities__c, H12_FixedIncome__c, H12_Passive__c, H12_PrimeServices__c, H12_PrivateEquity__c, H12_Treasury__c, H12_WorkingCapital__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name, SystemModstamp, Tot_F12_Contrib_Weighted__c, Tot_F12_Contribution__c, Tot_F12_Non_Lending_Contrib__c, Tot_F12_Non_Lendng_Contrib_Weighted__c, Tot_F24_Contrib_Weighted__c, Tot_F24_Contribution__c, Tot_F24_Non_Lending_Contrib__c, Tot_F24_Non_Lendng_Contrib_Weighted__c, Tot_H12_Contribution__c, Tot_H12_Non_Lending_Contrib__c, rorwa_Deposits__c, rorwa_AverageDepositBalance__c, rorwa_TransactionProducts__c, rorwa_Derivatives__c, rorwa_Debt__c, rorwa_Trade__c, rorwa_FX__c, rorwa_AssetSalesFinance__c, rorwa_OtherTrade__c, rorwa_OtherMADCMECM__c, rorwa_OtherRBBWealth__c, rorwa_CommercialPropertyFinance__c, rorwa_Equities__c, rorwa_FixedIncome__c, rorwa_Passive__c, rorwa_PrimeServices__c, rorwa_PrivateEquity__c, rorwa_Treasury__c, rorwa_WorkingCapital__c, RWA_Deposits__c,RWA_AverageDepositBalance__c,RWA_TransactionProducts__c,RWA_Debt__c,RWA_Trade__c,RWA_FX__c,RWA_AssetSalesFinance__c,RWA_OtherTrade__c,RWA_OtherMADCMECM__c,RWA_OtherRBBWealth__c, RWA_CommercialPropertyFinance__c, RWA_Equities__c, RWA_FixedIncome__c, RWA_Passive__c, RWA_PrimeServices__c, RWA_PrivateEquity__c, RWA_Treasury__c, RWA_WorkingCapital__c, LastPulledFromMyMI__c
    		FROM 		Client_Plan_Revenue_By_Product__c
    		WHERE		Client_Plan__c = :clientPlanId
    		ORDER BY 	CreatedDate DESC 
    		LIMIT 		1
    	];

    	if(!revByProdList.isEmpty()) {
    		revByProd = revByProdList.get(0);
    	}
	}
    
    public void clearLastPulledFromMyMIDate() {
        try {
            revByProd.LastPulledfromMyMI__c = NULL;
            UPDATE revByProd;
        } catch(exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error during manual MyMI data entry: ' + e));
        }
    }
    
    public void pullFromMyMI() {
        try {
            // Match Revenue By Products Currency with the Relationship Currency before insert/update
        	MyMI MyMIFeed = new MyMI();
        	MyMI.ClientGroup cg = MyMIFeed.RetrieveClientGroupFeedSync(CIBKey);
            if (MyMIFeed.errorMessage == '') {
                revByProd.H12_Deposits__c = convertCurrency('ZAR', accountCurrency, cg.RevenueDeposits);
                revByProd.RWA_Deposits__c = convertCurrency('ZAR', accountCurrency, cg.RWADeposits);
                revByProd.H12_TransactionProducts__c = convertCurrency('ZAR', accountCurrency, cg.RevenueTransactionProducts);
                revByProd.RWA_TransactionProducts__c = convertCurrency('ZAR', accountCurrency, cg.RWATransactionProducts);
                revByProd.H12_Debt__c = convertCurrency('ZAR', accountCurrency, cg.RevenueDebt);
                revByProd.RWA_Debt__c = convertCurrency('ZAR', accountCurrency, cg.RWADebt);
                revByProd.H12_Trade__c = convertCurrency('ZAR', accountCurrency, cg.RevenueTrade);
                revByProd.RWA_Trade__c = convertCurrency('ZAR', accountCurrency, cg.RWATrade);
                revByProd.H12_FX__c = convertCurrency('ZAR', accountCurrency, cg.RevenueFX);
                revByProd.RWA_FX__c = convertCurrency('ZAR', accountCurrency, cg.RWAFX);
                revByProd.H12_AssetSalesFinance__c = convertCurrency('ZAR', accountCurrency, cg.RevenueAssetSalesFinance);
                revByProd.RWA_AssetSalesFinance__c = convertCurrency('ZAR', accountCurrency, cg.RWAAssetSalesFinance);
                revByProd.H12_OtherMADCMECM__c = convertCurrency('ZAR', accountCurrency, cg.RevenueOtherMADCMECM);
                revByProd.RWA_OtherMADCMECM__c = convertCurrency('ZAR', accountCurrency, cg.RWAOtherMADCMECM);
                revByProd.H12_OtherRBBWealth__c = convertCurrency('ZAR', accountCurrency, cg.RevenueOtherRBBWealth);
                revByProd.RWA_OtherRBBWealth__c = convertCurrency('ZAR', accountCurrency, cg.RWAOtherRBBWealth);
                revByProd.H12_OtherTrade__c = convertCurrency('ZAR', accountCurrency, cg.RevenueOtherTrading);
                revByProd.RWA_OtherTrade__c = convertCurrency('ZAR', accountCurrency, cg.RWAOtherTrading);
                revByProd.H12_CommercialPropertyFinance__c = convertCurrency('ZAR', accountCurrency, cg.RevenueCommercialPropertyFinance);
                revByProd.RWA_CommercialPropertyFinance__c = convertCurrency('ZAR', accountCurrency, cg.RWACommercialPropertyFinance);
                revByProd.H12_Equities__c = convertCurrency('ZAR', accountCurrency, cg.RevenueEquities);
                revByProd.RWA_Equities__c = convertCurrency('ZAR', accountCurrency, cg.RWAEquities);
                revByProd.H12_FixedIncome__c = convertCurrency('ZAR', accountCurrency, cg.RevenueFixedIncome);
                revByProd.RWA_FixedIncome__c = convertCurrency('ZAR', accountCurrency, cg.RWAFixedIncome);
                revByProd.H12_Passive__c = convertCurrency('ZAR', accountCurrency, cg.RevenuePassive);
                revByProd.RWA_Passive__c = convertCurrency('ZAR', accountCurrency, cg.RWAPassive);
                revByProd.H12_PrimeServices__c = convertCurrency('ZAR', accountCurrency, cg.RevenuePrimeServices);
                revByProd.RWA_PrimeServices__c = convertCurrency('ZAR', accountCurrency, cg.RWAPrimeServices);
                revByProd.H12_PrivateEquity__c = convertCurrency('ZAR', accountCurrency, cg.RevenuePrivateEquity);
                revByProd.RWA_PrivateEquity__c = convertCurrency('ZAR', accountCurrency, cg.RWAPrivateEquity);
                revByProd.H12_Treasury__c = convertCurrency('ZAR', accountCurrency, cg.RevenueTreasury);
                revByProd.RWA_Treasury__c = convertCurrency('ZAR', accountCurrency, cg.RWATreasury);
                revByProd.H12_WorkingCapital__c = convertCurrency('ZAR', accountCurrency, cg.RevenueWorkingCapital);
                revByProd.RWA_WorkingCapital__c = convertCurrency('ZAR', accountCurrency, cg.RWAWorkingCapital);
                revByProd.LastPulledfromMyMI__c = cg.DataDate;
                if(String.isEmpty(revByProd.Id)) {
                    if (accountCurrency != null) revByProd.CurrencyIsoCode = accountCurrency;
                    INSERT revByProd;
				} else {
                    UPDATE revByProd;
				}
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, MyMIFeed.errorMessage));
            }
        } catch(exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL, 'Error during MyMI data retrieval: ' + e));
        }
    }
    
    public Double convertCurrency(String oCurrency, String nCurrency, Double amount){
        //Convert incoming amount
        Double conversionRate = conversion_rates.get(oCurrency);
        amount = amount / conversionRate;
        //Now multiply it by the currency rate you want to convert to
        conversionRate = conversion_rates.get(nCurrency);
        amount = amount * conversionRate;
        
        return amount.intValue();
    }
}