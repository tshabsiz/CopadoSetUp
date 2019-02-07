public with sharing class ClientPlanSummaryPrintViewController   extends ClientPlanUtils{
    public Client_Plan__c clientPlan { get; set; }

    //controllers of other client plan tabs
    public ClientPlanDetailsController clientPlanDetailsController {get;set;}
    public ClientPlanStrategyController clientPlanStrategyController {get;set;}
    public ClientOverviewController clientPlanOverviewController {get;set;}
    public ClientPlanController clientPlanController {get;set;}
    public ClientFinancialsController clientPlanFinancialsController {get;set;}
    public ClientPlanOrgStructureController clientPlanOrgStructureController {get;set;}

    //data sets
    public List<Client_Plan_Relationship__c> clientPlanStakeholders {get;set;}
    public List<Financial_Information__c> clientPlanFinancials {get;set;}
    public List<Budget_Revenue__c> clientPlanExistingProducts {get;set;}
    public Client_Plan_Revenue_By_Product__c clientPlanRevByProduct {get;set;}

    //What pages to render
    public Boolean pageOverview {get;set;}
    public Boolean pageClientSector {get;set;}
    public Boolean pageOwnership {get;set;}
    public Boolean pageSwot {get;set;}
    public Boolean pageStakeHolders {get;set;}
    public Boolean pagePresence {get;set;}
    public Boolean pageFinancials {get;set;}
    public Boolean pageFacilitiesBreakdown {get;set;}
    public Boolean pageRevenuesByProduct {get;set;}
    public Boolean pageStrategies {get;set;}
    public Boolean pageOpportunities {get;set;}
    public Boolean pageContactBio {get;set;}
    
    //Tonga MM : Map collections
    public Map<String,SubTotal> currencyTotalsMap {get;set;}

    public ClientPlanSummaryPrintViewController(ApexPages.StandardController stdController) {
        super(ApexPages.currentPage().getParameters().get('planId'),'planId');
        if(!test.isRunningTest()) {
            stdController.addFields(new List<String>{
                'Id',
                'Org_Structure_Image_ID__c',
                'Country_Presence_Image_ID__c',
                'Group_Structure_Image_ID__c',
                'Name',
                'Relationship__c',
                'Relationship__r.Name',
                'SDS__c',
                'Override_Pull_DG_From_SPEAR__c'
            });
        }

        clientPlan = (Client_Plan__c) stdController.getRecord();
        clientPlanDetailsController = new ClientPlanDetailsController(stdController);
        clientPlanStrategyController = new ClientPlanStrategyController();
        clientPlanOverviewController = new ClientOverviewController();
        clientPlanController = new ClientPlanController();
        clientPlanFinancialsController = new ClientFinancialsController();
        clientPlanOrgStructureController = new ClientPlanOrgStructureController();

        //Determine what pages to render
        this.processParameters();

        //Fetch data
        if(clientPlan.Id != null) {
            this.queryStakeHolders();
            this.queryClientFinancials();
            this.queryClientExistingProducts();
            this.queryClientRevenueByProduct();
            queryACMFacilities();
        }
    }	

    private void processParameters() {
        Map<String, String> allParameters = ApexPages.currentPage().getParameters();

        this.pageOverview = isSet(allParameters, 'pageOverview');
        this.pageClientSector = isSet(allParameters, 'pageClientSector');
        this.pageOwnership = isSet(allParameters, 'pageOwnership');
        this.pageSwot = isSet(allParameters, 'pageSwot');
        this.pageStakeHolders = isSet(allParameters, 'pageStakeHolders');
        this.pagePresence = isSet(allParameters, 'pagePresence');
        this.pageFinancials = isSet(allParameters, 'pageFinancials');
        this.pageFacilitiesBreakdown = isSet(allParameters, 'pageFacilitiesBreakdown');
        this.pageRevenuesByProduct = isSet(allParameters, 'pageRevenuesByProduct');
        this.pageStrategies = isSet(allParameters, 'pageStrategies');
        this.pageOpportunities = isSet(allParameters, 'pageOpportunities');
        this.pageContactBio = isSet(allParameters, 'pageContactBio');
        
        System.debug('pageContactBio '+pageContactBio);
    }

    private static Boolean isSet(Map<String, String> allParameters, String paramName) {
        if(!String.isEmpty(paramName)) {
            if(allParameters.keyset().contains(paramName)) {
                if(allParameters.get(paramName) == 'true') {
                    return true;
                }
            }
        }

        return false;
    }

    private void queryStakeHolders() {
        clientPlanStakeholders = [
            SELECT      Id, Contact__c, Reports_to__c, Contact__r.Name,Contact__r.Biography__c,Contact__r.Image__c, Contact__r.Job_Role__c, Contact__r.Job_Title__c, Comment__c, Client_Strength__c, (
                            SELECT      Id, Barclays_Contact_User__r.Name, Strength_of_Relationship__c, Primary_Contact__c 
                            FROM        Client_Plan_Relationship_Items__r
                            WHERE       Primary_Contact__c = TRUE
                            ORDER BY    Primary_Contact__c DESC
                        )
            FROM        Client_Plan_Relationship__c
            WHERE       Client_Plan__c = :clientPlan.Id
            ORDER BY    Contact__r.Name
        ];
    }

    private void queryClientFinancials() {
        clientPlanFinancials = ClientFinancialsController.queryFinancialInformation(clientPlan, 0, 5);
    }

    private void queryClientExistingProducts() {
        clientPlanExistingProducts = [
            SELECT      Id, Product_Level_3__c, Product_Level_3__r.Name, Product__c, Country__c, Maturity_Date__c, LGD__c, DG__C, Limit__c, Utilisation__c, Margin__c, FTP__c, Arranging_Fee__c, Commitment_Fee__c, RoRWA__c
            FROM        Budget_Revenue__c
            WHERE       Client_Plan__c = :clientPlan.Id
            ORDER BY    Product__c
        ];
    }

    private void queryClientRevenueByProduct() {
        List<Client_Plan_Revenue_By_Product__c> clientPlanRevByProductList = [
            SELECT      Client_Plan__c, CreatedById, CreatedDate, CurrencyIsoCode, F12_AssetSalesFinance__c, F12_AverageDepositBalance__c, F12_Debt__c, F12_Deposits__c, F12_Derivatives__c, F12_FX__c, F12_OtherMADCMECM__c, F12_OtherRBBWealth__c, F12_OtherTrade__c, F12_Trade__c, F12_TransactionProducts__c, F12_CommercialPropertyFinance__c, F12_Equities__c, F12_FixedIncome__c, F12_Passive__c, F12_PrimeServices__c, F12_PrivateEquity__c, F12_Treasury__c, F12_WorkingCapital__c, F12P_AssetSalesFinance__c, F12P_AverageDepositBalance__c, F12P_Debt__c, F12P_Deposits__c, F12P_Derivatives__c, F12P_FX__c, F12P_OtherMADCMECM__c, F12P_OtherRBBWealth__c, F12P_OtherTrade__c, F12P_Trade__c, F12P_TransactionProducts__c, F12P_CommercialPropertyFinance__c, F12P_Equities__c, F12P_FixedIncome__c, F12P_Passive__c, F12P_PrimeServices__c, F12P_PrivateEquity__c, F12P_Treasury__c, F12P_WorkingCapital__c, F24_AssetSalesFinance__c, F24_AverageDepositBalance__c, F24_Debt__c, F24_Deposits__c, F24_Derivatives__c, F24_FX__c, F24_OtherMADCMECM__c, F24_OtherRBBWealth__c, F24_OtherTrade__c, F24_Trade__c, F24_TransactionProducts__c, F24_CommercialPropertyFinance__c, F24_Equities__c, F24_FixedIncome__c, F24_Passive__c, F24_PrimeServices__c, F24_PrivateEquity__c, F24_Treasury__c, F24_WorkingCapital__c, F24P_AssetSalesFinance__c, F24P_AverageDepositBalance__c, F24P_Debt__c, F24P_Deposits__c, F24P_Derivatives__c, F24P_FX__c, F24P_OtherMADCMECM__c, F24P_OtherRBBWealth__c, F24P_OtherTrade__c, F24P_Trade__c, F24P_TransactionProducts__c, F24P_CommercialPropertyFinance__c, F24P_Equities__c, F24P_FixedIncome__c, F24P_Passive__c, F24P_PrimeServices__c, F24P_PrivateEquity__c, F24P_Treasury__c, F24P_WorkingCapital__c, H12_AssetSalesFinance__c, H12_AverageDepositBalance__c, H12_Debt__c, H12_Deposits__c, H12_Derivatives__c, H12_FX__c, H12_OtherMADCMECM__c, H12_OtherRBBWealth__c, H12_OtherTrade__c, H12_Trade__c, H12_TransactionProducts__c, H12_CommercialPropertyFinance__c, H12_Equities__c, H12_FixedIncome__c, H12_Passive__c, H12_PrimeServices__c, H12_PrivateEquity__c, H12_Treasury__c, H12_WorkingCapital__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name, SystemModstamp, Tot_F12_Contrib_Weighted__c, Tot_F12_Contribution__c, Tot_F12_Non_Lending_Contrib__c, Tot_F12_Non_Lendng_Contrib_Weighted__c, Tot_F24_Contrib_Weighted__c, Tot_F24_Contribution__c, Tot_F24_Non_Lending_Contrib__c, Tot_F24_Non_Lendng_Contrib_Weighted__c, Tot_H12_Contribution__c, Tot_H12_Non_Lending_Contrib__c, rorwa_Deposits__c, rorwa_AverageDepositBalance__c, rorwa_TransactionProducts__c, rorwa_Derivatives__c, rorwa_Debt__c, rorwa_Trade__c, rorwa_FX__c, rorwa_AssetSalesFinance__c, rorwa_OtherTrade__c, rorwa_OtherMADCMECM__c, rorwa_OtherRBBWealth__c, rorwa_CommercialPropertyFinance__c, rorwa_Equities__c, rorwa_FixedIncome__c, rorwa_Passive__c, rorwa_PrimeServices__c, rorwa_PrivateEquity__c, rorwa_Treasury__c, rorwa_WorkingCapital__c, RWA_Deposits__c,RWA_AverageDepositBalance__c,RWA_TransactionProducts__c,RWA_Debt__c,RWA_Trade__c,RWA_FX__c,RWA_AssetSalesFinance__c,RWA_OtherTrade__c,RWA_OtherMADCMECM__c,RWA_OtherRBBWealth__c, RWA_CommercialPropertyFinance__c, RWA_Equities__c, RWA_FixedIncome__c, RWA_Passive__c, RWA_PrimeServices__c, RWA_PrivateEquity__c, RWA_Treasury__c, RWA_WorkingCapital__c
            FROM        Client_Plan_Revenue_By_Product__c
            WHERE       Client_Plan__c = :clientPlan.Id
            ORDER BY    CreatedDate DESC 
            LIMIT       1
        ];

        clientPlanRevByProduct = null;
        if(!clientPlanRevByProductList.isEmpty()) {
            clientPlanRevByProduct = clientPlanRevByProductList.get(0);
        }
    }
}