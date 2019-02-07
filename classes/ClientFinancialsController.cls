/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientEnvironment VF page.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientFinancialsController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*15.2.2016      Svata Sejkora   adding modifications to allow editing and deleting of Financial Information
*------------------------------------------------------------*/
public class ClientFinancialsController extends ClientPlanUtils{
    
    public Client_Plan__c plan {get;set;}    
    public Boolean planLoaded {get;set;}
    public Long dateOfLatestAFS {get;set;}
    public Long lastReviewDate {get;set;}
    public static String lastFinInforYear{get;set;}
    
    public String userCurrencyCode {get;set;} 
    public Map<String,SubTotal> currencyTotalsMap{get;set;}
    
    public List<Financial_Information__c> financeList {get;set;}
    public List<Client_Plan_Facility__c> absaFacility {get;set;}
    public List<Client_Plan_Facility__c> otherFacility {get;set;}
    public List<Client_Plan_Security__c> absaSecurity {get;set;}
    
    public String clientSecurity {get;set;}
    public String clientSecurityCurrency {get;set;}
    public String absaSecId {get;set;}
    public String recordId {get;set;}
    public String finFieldName {get;set;}
    public String finValue {get;set;}
    public String yearValue {get;set;}
    public String monthValue {get;set;}
    public String facilityId {get;set;}
    public String productLvl3 {get;set;}
    public String bank {get;set;}
    public String country {get;set;}
    public String facType {get;set;}
    public String currencyVal {get; set;}
    public String currentRatio {get;set;}
    public String interestCoverRatio {get;set;}
    public String financialResults {get;set;}
    public String periodValue {get;set;}
    
    public Long value {get;set;}
    public Long utilisation {get;set;}
    public Long facLimit {get;set;}
    public decimal netAssetValue {get;set;}
    public decimal turnover {get;set;}
    public decimal marketCap {get;set;}
    public decimal totalAssets {get;set;}
    public decimal cashGenByOperations {get;set;}
    public decimal ebitda {get;set;}
    public decimal ebit {get;set;}
    public decimal netDebt {get;set;}
    public decimal eps {get;set;}
    
    public decimal netInterestExpenseIncome{get;set;}
    public decimal netInterestExpenseBAGLfacilities{get;set;}
    public decimal PAT{get;set;}
    public decimal netWorth{get;set;}
    public decimal tangibleNetWorth{get;set;}
    public decimal totalLiabilities{get;set;}
    public decimal cashFlowFromOperatingActivities{get;set;}
    public decimal cashFlowFromOperatingActivitiesAdj{get;set;}
    public decimal Capex{get;set;}
    public decimal netCashGenerationUtilization{get;set;}
    public decimal freeCashFlow{get;set;}
    public decimal totalTangibleAssets{get;set;}
    public Decimal grossDebt{get;set;}
    public decimal subordinatedShareholderLoans{get;set;}
    public decimal cashAndCashEquivalents {get;set;} 
    
    
    public Decimal roe {get;set;}
    public Decimal roa {get;set;}
    public Decimal debtEquity {get;set;}
    
    private static final String countriesPicklistJson = JsonUtils.returnJSONString('Picklists', 'CountryPresenceJSON', 'txt', 'Picklists');
    private static Map<String, String> countriesPicklistMap = JsonUtils.returnPicklistMap(countriesPicklistJson);
    private static String countriesJson = Json.serializePretty(countriesPicklistMap.keySet());
    
    @testVisible
    private String errorMessage;
    private static final String ABSA = 'ABSA';
    private static final String OTHER = 'OTHER';
    
    public Transient Blob imageBody {get; set;}
    public String imageName {get;set;}
    public String imageContentType {get;set;}
    
    public ClientFinancialsController() {
        super(ApexPages.currentPage().getParameters().get('planId'),'planId');
        String planId = ApexPages.currentPage().getParameters().get('planId');
        if(String.isEmpty(planId)) {
            planId = ApexPages.currentPage().getParameters().get('id');
        }
        if(!String.isEmpty(planId)) {
            queryPlan(planId);
            if(planLoaded) {
                userCurrencyCode = UserInfo.getDefaultCurrency();
                financeList = queryFinancialInformation(plan, System.Today().year()-5, 6);
                
                
                queryAbsaFacility();
                otherFacility = queryOtherFacility(plan);
                absaSecurity = queryAbsaSecurity(plan.Relationship__c);
                currencyTotalsMap =updateFacilitiesTotal(otherFacility);
            }
        } else {
            planLoaded = false;
        }
    }
    
    public static String getCountriesJson() {
        return countriesJson;
    }
    
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     save method
* @Returns:         PageReference with null value
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public PageReference save() {
        if(dateOfLatestAFS != null && dateOfLatestAFS != 0) {
            plan.Latest_Audited_Financial_Statement__c = DateTime.newInstance(dateOfLatestAFS).date();
        }
        
        if(lastReviewDate != null && lastReviewDate != 0) {
            plan.Last_Review_Date__c = DateTime.newInstance(lastReviewDate).date();
        }        
        
        try {
            
            for(Financial_Information__c f :financeList)
            {
                f.CurrencyIsoCode = plan.CurrencyIsoCode;
            }
            
            UPDATE plan;
            update financeList;
        } catch(Exception e) {
            System.debug(e);
            setErrorMessage(Label.errMsg_ErrorDuringSaving);
        }
        
        return null;
    }
    
    public PageReference uploadImage() {
        //Remove existing one if it exists
        this.deleteImage();
        
        //Add new one
        Attachment image = new Attachment();
        image.ParentId = this.plan.Id;
        image.IsPrivate = false;
        image.Name = imageName;
        image.ContentType = imageContentType;
        image.Body = imageBody;
        
        Id imageId = null;
        try {
            INSERT image;
            imageId = image.Id;
        } catch (DMLException e) {
            System.debug(e);
        }
        
        if(imageId != null) {
            try {
                plan.Financial_Information_Image_ID__c = imageId;
                UPDATE plan;
            } catch (DMLException e) {
                System.debug(e);
            }
        }
        
        PageReference pageRef = Page.ClientFinancials;
        pageRef.getParameters().put('planId', plan.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference deleteImage() {
        //Remove actual attachment if it exists
        List<Attachment> attachments = [
            SELECT  Id
            FROM    Attachment
            WHERE   ParentId = :plan.Id AND Id = :plan.Financial_Information_Image_ID__c
        ];
        
        try {      
            DELETE attachments;
        } catch(DMLException e) {
            System.debug(e);
        }        
        
        //Remove reference to the Attachment ID
        try {
            plan.Financial_Information_Image_ID__c = null;
            UPDATE plan;
        } catch (DMLException e) {
            System.debug(e);
        }
        
        PageReference pageRef = Page.ClientFinancials;
        pageRef.getParameters().put('planId', plan.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     delete financial info record
* @Returns:         null
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public PageReference deleteFinInfo() {
        
        Financial_Information__c finInfo = [
            SELECT  Id 
            FROM    Financial_Information__c 
            WHERE   Id = :recordId
        ][0];
        
        try {
            DELETE finInfo;
        } catch(Exception e) {
            System.debug(e);
            setErrorMessage(Label.errMsg_ErrorDuringDeleting);
        }
        
        financeList = queryFinancialInformation(plan, System.Today().year()-5, 6);
       
        
        return null;
    }
    
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     saves changes to fin info record
* @Returns:         PageReference with null value
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public PageReference saveFinValue() {
        for(Financial_Information__c fi: financeList) {
            if(fi.Id == recordId) {
                try {
                    fi.put(finFieldName, Decimal.valueOf(finValue));
                    UPDATE fi;
                } catch (Exception e) {
                    System.debug(e);
                    setErrorMessage(Label.errMsg_ErrorDuringSaving);
                }
            }
        }
        
        return null;
    }
    
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     prepares select options of FAIS_Status__c field
* @Returns:         List<SelectOption> - options prepared
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    
    public List<SelectOption> getFAISOptions() {
        Schema.DescribeFieldResult f = Client_Plan__c.FAIS_Status__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    public List<SelectOption> getCurrencyCodeOptions() {
        Schema.DescribeFieldResult f = Client_Plan__c.CurrencyIsoCode.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     prepares select options of Financial_Year_End__c field
* @Returns:         List<SelectOption> - options prepared
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    
    public List<SelectOption> getFiscalMonthOptions() {
        Schema.DescribeFieldResult f = Client_Plan__c.Financial_Year_End__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     prepares select options of year field
* @Returns:         List<SelectOption> - options prepared
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public List<SelectOption> getYearOptions() {
        Schema.DescribeFieldResult f = Financial_Information__c.Year__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     prepares select options of month field
* @Returns:         List<SelectOption> - options prepared
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public List<SelectOption> getMonthOptions() {
        Schema.DescribeFieldResult f = Financial_Information__c.Month__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    public List<SelectOption> getFinancialResultOptions() {
        Schema.DescribeFieldResult f = Financial_Information__c.Financial_Results__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
* @Author:          Mtha Gumede
* @Company:         Absa Capital
* @Description:     prepares select options of month field
* @Returns:         List<SelectOption> - options prepared
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public List<SelectOption> getPeriodOptions() {
        Schema.DescribeFieldResult f = Financial_Information__c.Period_Of_Months__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }

    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     prepares select options of currency field
* @Returns:         List<SelectOption> - options prepared
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    
    public List<SelectOption> getCurrencyOptions() {
        Schema.DescribeFieldResult f = Client_Plan_Facility__c.CurrencyIsoCode.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     prepares select options of year field to allow only creation of non existing years
* @Returns:         List<SelectOption> - options prepared
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public String getExistingYearOptions() {
        List<String> currentYears = new List<String>();
        
        for(Financial_Information__c finInfo: [
            SELECT  Year__c 
            FROM    Financial_Information__c 
            WHERE   Relationship__c = :plan.Relationship__c
        ]) {
            currentYears.add(finInfo.Year__c);
        }
        
        return JSON.serialize(currentYears);
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     modifies Financial information
* @Returns:         PageReference - null
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public PageReference modifyYear() {
        if(recordId == '') {
            addFinancialInformation();
        } else {
            editFinancialInformation();
        }
        return null;
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     modifies facility
* @Returns:         PageReference - null
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public PageReference modifyFacility() {
        if(String.isEmpty(facilityId)) {
            addFacility();
        } else {
            editFacility();
        }
        return null;
    }
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     delete Facility record
* @Returns:         null
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public PageReference deleteFacility() { 
        Client_Plan_Facility__c facilityInfo = [
            SELECT  Id 
            FROM    Client_Plan_Facility__c
            WHERE   Id = :facilityId
        ][0];
        
        try {
            DELETE facilityInfo;
        } catch(Exception e) {
            System.debug(e);
            setErrorMessage(Label.errMsg_ErrorDuringDeleting);
        }
        
        OtherFacility = queryOtherFacility(plan);
        currencyTotalsMap = updateFacilitiesTotal(otherFacility);
        return null;
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     modifies security
* @Returns:         PageReference - null
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public PageReference modifySecurity() {
        if(String.isEmpty(absaSecId)) {
            addSecurity();
        } else {
            editSecurity();
        }
        return null;
    }
    
    /**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     delete Security record
* @Returns:         null
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public PageReference deleteSecurity() { 
        Client_Plan_Security__c securityInfo = [
            SELECT  Id 
            FROM    Client_Plan_Security__c
            WHERE   Id = :absaSecId
        ][0];
        
        try {
            DELETE securityInfo;
        } catch(Exception e) {
            System.debug(e);
            setErrorMessage(Label.errMsg_ErrorDuringDeleting);
        }
        
        absaSecurity  = queryAbsaSecurity(plan.Relationship__c);
        return null;
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     search for products to add to facility
* @Params:          search text
* @Returns:         List<SearchResult>
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    @RemoteAction
    public static List<SearchResult> search(String name) {
        name += '%';
        String soql = 'SELECT Id, Name FROM Product2 WHERE Name LIKE :name ORDER BY Name LIMIT 15';
        
        List<SearchResult> results = new List<SearchResult>();
        for(Product2 product : Database.query(soql)) {
            results.add(new SearchResult(product.Id, product.Name));
        }
        
        if(results.size() == 0) {
            results.add(new SearchResult());
        }
        return results;
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     queries Absa Facility
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    private void queryAbsaFacility() {
        absaFacility = [
            SELECT    Id, Limit__c, Product__c, Country__c, Utilisation__c, Product_Level_3__c, Product_Level_3__r.Name
            FROM      Client_Plan_Facility__c
            WHERE     Relationship__c = :plan.Relationship__c AND Type_Of_Facility__c = :ABSA
            ORDER BY  CreatedDate ASC
        ];
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     queries Absa Facility
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public static List<Client_Plan_Facility__c>  queryOtherFacility(Client_Plan__c plan) {
        return [
            SELECT    Id, Limit__c,ConvertCurrency(Limit__c) convertedCurrency, Product__c, Bank__c, Country__c, Product_Level_3__c, Product_Level_3__r.Name,CurrencyIsoCode
            FROM      Client_Plan_Facility__c
            WHERE     Relationship__c = :plan.Relationship__c AND Type_Of_Facility__c = :OTHER
            ORDER BY  CreatedDate ASC
        ];
    }      
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     queries Absa security
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public static List<Client_Plan_Security__c> queryAbsaSecurity(ID RelationshipID) {
        return [
            SELECT    Id, Security_Description__c, Value__c
            FROM      Client_Plan_Security__c
            WHERE     Relationship__c = :RelationshipID
            ORDER BY  CreatedDate ASC
        ];
    }
    
    /**
* @Author:          Svatopluk Sejkora
* @Company:         Deloitte
* @Description:     adds product
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    private void addFinancialInformation() {
        Financial_Information__c finInf = new Financial_Information__c();
        
        finInf.Relationship__c = plan.Relationship__c;
        finInf.Net_Asset_Value__c =netAssetValue;
        finInf.Year__c = yearValue;
        finInf.Month__c = monthValue;
        finInf.Period_Of_Months__c = periodValue;
        finInf.Turnover__c =turnover;
        finInf.Market_Cap__c = marketCap;
        finInf.Total_Assets__c = totalAssets;
        finInf.Cash_Generated_by_Operations__c = cashGenByOperations;
        finInf.EBITDA__c = ebitda;
        finInf.EBIT__c = ebit;
        finInf.Net_Debt__c = netDebt;
        finInf.ROE__c = roe;
        finInf.ROA__c = roa;
        finInf.Debt_Equity__c = debtEquity;
        finInf.Current_Ratio__c = currentRatio;
        finInf.EPS__c = eps;
        finInf.Financial_Results__c = financialResults;
        finInf.Interest_Cover_Ratio__c = interestCoverRatio;
        finInf.net_Interest_Expense_Income__c=netInterestExpenseIncome;
        finInf.net_Interest_Expense_BAGL_facilities__c=netInterestExpenseBAGLfacilities;
        finInf.PAT__c =PAT;
        finInf.net_Worth__c =netWorth;
        finInf.tangible_Net_Worth__c =tangibleNetWorth;
        finInf.total_Liabilities__c=totalLiabilities;
        finInf.cash_Flow_From_Operating_Activities_Adj__c=cashFlowFromOperatingActivitiesAdj;
        finInf.Capex__c=Capex;
        finInf.net_Cash_Generation_Utilization__c=netCashGenerationUtilization;
        finInf.free_Cash_Flow__c=freeCashFlow;
        finInf.total_Tangible_Assets__c=totalTangibleAssets;
        finInf.gross_Debt__c=grossDebt;
        finInf.subordinated_Shareholder_Loans__c=subordinatedShareholderLoans;
        finInf.cash_And_Cash_Equivalents__c=cashAndCashEquivalents;
        finInf.Financial_Results__c = financialResults;
        
        try {
            INSERT finInf;
        } catch (Exception e) {
            System.debug(e);
            setErrorMessage(Label.errMsg_ErrorDuringAddingPotOpty);
        }
        financeList = queryFinancialInformation(plan, System.Today().year()-5, 6);
        
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     product editation
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    private void editFinancialInformation() {
        for(Financial_Information__c finInf: financeList) {
            if(finInf.Id == recordId) {
                finInf.Net_Asset_Value__c = netAssetValue;
                finInf.Year__c = yearValue;
                finInf.Month__c = monthValue;
                finInf.Period_Of_Months__c = periodValue;
                finInf.Turnover__c = turnover;
                finInf.Market_Cap__c =marketCap;
                finInf.Total_Assets__c = totalAssets;
                finInf.Cash_Generated_by_Operations__c = cashGenByOperations;
                finInf.EBITDA__c = ebitda;
                finInf.EBIT__c = ebit;
                finInf.Net_Debt__c = netDebt;
                finInf.ROE__c = roe;
                finInf.ROA__c = roa;
                finInf.Debt_Equity__c = debtEquity;
                finInf.Current_Ratio__c = currentRatio;
                finInf.EPS__c = eps;
                finInf.Interest_Cover_Ratio__c = interestCoverRatio;
                finInf.Financial_Results__c = financialResults;
                
                finInf.net_Interest_Expense_Income__c=netInterestExpenseIncome;
                finInf.net_Interest_Expense_BAGL_facilities__c=netInterestExpenseBAGLfacilities;
                finInf.PAT__c =PAT;
                finInf.net_Worth__c =netWorth;
                finInf.tangible_Net_Worth__c =tangibleNetWorth;
                finInf.total_Liabilities__c=totalLiabilities;
                finInf.cash_Flow_From_Operating_Activities_Adj__c=cashFlowFromOperatingActivitiesAdj;
                finInf.Capex__c=Capex;
                finInf.net_Cash_Generation_Utilization__c=netCashGenerationUtilization;
                finInf.free_Cash_Flow__c=freeCashFlow;
                finInf.total_Tangible_Assets__c=totalTangibleAssets;
                finInf.gross_Debt__c=grossDebt;
                finInf.subordinated_Shareholder_Loans__c=subordinatedShareholderLoans;
                finInf.cash_And_Cash_Equivalents__c=cashAndCashEquivalents;
               
                try {
                    UPDATE finInf;
                } catch (Exception e) {
                    System.debug(e);
                    setErrorMessage(Label.errMsg_ErrorDuringEditingPotOpty);
                }
                financeList = queryFinancialInformation(plan, System.Today().year()-5, 6);
                
                
                break;
            }
        }
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     facility add
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    private void addFacility() {
        Client_Plan_Facility__c faci = new Client_Plan_Facility__c();
        faci.Relationship__c = plan.Relationship__c;
        faci.Type_Of_Facility__c = facType;
        faci.Bank__c = bank;
        faci.Country__c = country;
        faci.Utilisation__c = utilisation;
        faci.Product_Level_3__c = productLvl3;
        faci.Limit__c = facLimit;
        faci.CurrencyIsoCode = currencyVal;
        
        try {
            INSERT faci;
        } catch (Exception e) {
            System.debug(e);
            setErrorMessage(Label.errMsg_ErrorDuringAddingPotOpty);
        }
        queryAbsaFacility();
        otherFacility = queryOtherFacility(plan);
        currencyTotalsMap = updateFacilitiesTotal(otherFacility);
        
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     facility editation
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    private void editFacility() {
        
        List<Client_Plan_Facility__c> allFaci = new List<Client_Plan_Facility__c>();
        
        allFaci.addAll(absaFacility);
        allFaci.addAll(otherFacility);
        
        for(Client_Plan_Facility__c faci: allFaci) {
            if(faci.Id == facilityId) {
                faci.Bank__c = bank;
                faci.Country__c = country;
                faci.Utilisation__c = utilisation;
                faci.Product_Level_3__c = productLvl3;
                faci.Limit__c = facLimit;
                faci.CurrencyIsoCode = currencyVal;
                
                try {
                    UPDATE faci;
                } catch (Exception e) {
                    System.debug(e);
                    setErrorMessage(Label.errMsg_ErrorDuringEditingPotOpty);
                }
                
                queryAbsaFacility();
                otherFacility = queryOtherFacility(plan);
                currencyTotalsMap = updateFacilitiesTotal(otherFacility);
                
                break;
            }
        }        
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     security add
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    private void addSecurity() {
        Client_Plan_Security__c secu = new Client_Plan_Security__c();
        
        secu.Relationship__c = plan.Relationship__c;
        secu.Value__c = value;
        secu.Security_Description__c = clientSecurity;
        secu.CurrencyIsoCode = clientSecurityCurrency;
        
        try {
            INSERT secu;
        } catch(Exception e) {
            System.debug(e);
            setErrorMessage(Label.errMsg_ErrorDuringAddingPotOpty);
        }
        
        absaSecurity = queryAbsaSecurity(plan.Relationship__c);
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     facility editation
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    private void editSecurity() {
        for(Client_Plan_Security__c secu: absaSecurity) {
            if(secu.Id == absaSecId) {
                secu.Value__c = value;
                secu.Security_Description__c = clientSecurity;
                secu.CurrencyIsoCode = clientSecurityCurrency;
                
                try {
                    UPDATE secu;
                } catch (Exception e) {
                    System.debug(e);
                    setErrorMessage(Label.errMsg_ErrorDuringEditingPotOpty);
                }
                
                absaSecurity = queryAbsaSecurity(plan.Relationship__c);
                break;
            }
        }        
    }
    
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     queries client plan
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    private void queryPlan(String planId) {
        List<Client_Plan__c> plans;
        try {
            plans = [
                SELECT  Id, Name, FAIS_Status__c, FAIS_Status_Comment__c,Financial_Information_Image_ID__c, Financial_Year_End__c, Latest_Audited_Financial_Statement__c, Last_Review_Date__c, Relationship__c, RoRWA_Existing__c, TFL__c, FinancialCommentary__c
                FROM    Client_Plan__c 
                WHERE   Id = :planId
            ];
        } catch (Exception e) {
            planLoaded = false;
            return;
        }
        
        if(plans.isEmpty()) {
            planLoaded = false; 
        } else {
            planLoaded = true;
            plan = plans[0];
            
            dateOfLatestAFS = prepareTimestampFromDate(plan.Latest_Audited_Financial_Statement__c);
            lastReviewDate = prepareTimestampFromDate(plan.Last_Review_Date__c);
        }
    }
    
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     queries financial information records
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public static List<Financial_Information__c> queryFinancialInformation(Client_Plan__c plan, Integer greaterthan, Integer RecordLimit) {
        List<Financial_Information__c>financialList = [
            SELECT    Id, Year__c, Month__c, Period_Of_Months__c,Tangible_Gearing_Net_Debt_TNW__c,Net_Debt_Cash_Ebitda__c,Gross_Debt_Cash_Ebitda__c,LastModifiedDate ,EBITDA_Net_Interest_cover__c ,Cash_flow_from_operating_activities_Adj__c ,PAT__c,Financial_Results__c,Net_cash_generation_utilization__c,Capex__c,Free_Cash_Flow__c,Cash_flow_from_operating_activities__c,Total_Liabilities__c,Tangible_Net_Worth__c,Cash_and_cash_equivalents__c,Net_Worth__c,Subordinated_Shareholder_Loans__c,Gross_Debt__c,Total_Tangible_Assets__c,Net_Interest_Expense_BAGL_facilities__c,Net_Interest_Expense_Income__c,Turnover__c, Market_Cap__c, Total_Assets__c, Net_Asset_Value__c, Total_Interest_Bearing_Debt__c, Cash_Generated_by_Operations__c, EBITDA__c, EBIT__c, EBITDA_Margin__c, ROE__c, ROA__c, Debt_Equity__c, Current_Ratio__c, EPS__c, Interest_Cover_Ratio__c, Net_Debt__c
            FROM      Financial_Information__c
            WHERE     Relationship__c = :plan.Relationship__c
            AND Year__c > :String.valueOf(greaterthan)
            ORDER BY  YearString__c DESC
            LIMIT :RecordLimit
        ];
        
        if(financialList.size()>0)
            lastFinInforYear = financialList[0].Year__c;
        
       return financialList;
    }
    
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     converts date to timestamp
* @Params           Date - date to be converted
* @Returns:         Long - timestamp
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    @testVisible
    private Long prepareTimestampFromDate(Date d) {
        if (d == null) {
            return 0;
        } else {
            DateTime dt = DateTime.newInstance(d.year(), d.month(), d.day());
            return dt.getTime();
        }
    }
    
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     prepares select options from describe field result
* @Params           Schema.DescribeFieldResult f - field info to process
* @Returns:         List<SelectOption> - prepared select options
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    private List<SelectOption> prepareSelectOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        for(Schema.PicklistEntry e: p) {
            options.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        return options;
    }
    
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     getter of error message
* @Returns:         String - error message
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public String getErrorMessage() {
        String message = errorMessage;
        errorMessage = null;
        return message;
    }
    
    /**
* @Author:          Marek Cech
* @Company:         Deloitte
* @Description:     setter of error message
* @Params           String errorMessage to set
* @Returns:         void
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
    
    /**
* @Author:          Svata Sejkora
* @Company:         Deloitte
* @Description:     private object to pass search results to and from page
* @Returns:         none
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
    @testVisible
    private class SearchResult {
        
        public String value;
        public String label;
        
        public SearchResult(Id id, String name) {
            this.value = id;
            this.label = name;
        }
        
        public SearchResult() {
            this.value = 'value';
            this.label = 'label';
        }
        
    }
    
}