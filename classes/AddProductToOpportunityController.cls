/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: Controller for VF page Add Product to Opportunity
* @Date:        02/2015
* @ConstructorParam:    stdController - Standard Controller for "Opportunity Line Item" object
* @TestClass:   ZZTEST_AddProductToOpportunity
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 11/2015     Marek Cech         added getDebt method, added product family handling to onProductLevel1Changed method
* 04/2016     Marek Cech         removed functionality for product picklists, added functionality for product search component
* 2017.06.14  Dino Scarcella   	 Added Properties to identify a Trade or Working Capital Product
* 2017.07.12  Dino Scarcella     Added functionality to autopopulate Product Partner and customize Product Partner lookup based on conditions
* 2017.08.07  Dino Scarcella     Added ability to specify whether this is a refinance with increased, decreased or unchanged amount
* 2017.02.28  Dino Scarcella     Added Product Partner Validation and Oberon enhancements
*------------------------------------------------------------*/
public with sharing class AddProductToOpportunityController {
    
    public Opportunity opp;
    public PricebookEntry priceBookEntry;
    public PricebookEntry newPriceBookEntry;
    public String product {get;set;} 

    public String existingProduct {get;set;}
    public String selectedProductLevel {get;set;}
    public String selectedProductId {get;set;}
    public String selectedProductName {get;set;}

    public Boolean isExisting {get;set;}
    public Boolean isEdit {get;set;}
    public Boolean ExcludeProductPartner { get;set; }
    public Integer daysFromCloseDateToEndOfYear {get;set;}
    public Integer monthsFromCloseDateToEndOfYear {get;set;}
    public String opportunityCountry {get;set;}
    public Boolean renderErrorMessage {get;set;}
    public String productFamily {get;set;}

    public Boolean isAssetFinance {
        get { return product != null && product != '' && mapProducts.get(product) != NULL && mapProducts.get(product).Name == 'Asset Finance' ? true : false; }
    }
    
    public Boolean isTrade {
        get { return product != null && product != '' && mapProducts.get(product) != NULL && mapProducts.get(product).Name == 'Trade' ? true : false; }
    }
    
    public Boolean isWorkingCapital {
        get { return product != null && product != '' && mapProducts.get(product) != NULL && mapProducts.get(product).Name == 'Working Capital' ? true : false; }
    }
    
    public Boolean isTradeFinance {
        get { return product != null && product != '' && mapProducts.get(product) != NULL && mapProducts.get(product).Name == 'Trade Finance' ? true : false; }
    }
    
    public Boolean isCPF {
        get { return product != null && product != '' && mapProducts.get(product) != NULL && mapProducts.get(product).Name == 'Commercial Property Finance' ? true : false; }
    }
    
    public Boolean isGlobalFinance {
        get { return product != null && product != '' && mapProducts.get(product) != NULL && mapProducts.get(product).Name == 'Global Finance' ? true : false; }
    }
    public Boolean isPhysicalCash {
        get { return product != null && product != '' && mapProducts.get(product) != NULL && mapProducts.get(product).Name == 'Physical Cash' ? true : false; }
    }
    
    public Boolean isRPF {
        get {
            return oppLineItem.Product_Level_2__c != NULL && mapProductLevel2.containsKey(oppLineItem.Product_Level_2__c) && mapProductLevel2.get(oppLineItem.Product_Level_2__c) != NULL && mapProductLevel2.get(oppLineItem.Product_Level_2__c).Name == 'Resource and Project Finance' ? true : false; 
        }
    }
    
    public Boolean isForeignExchange {
        get {
            return oppLineItem.Product_Level_2__c != NULL && mapProductLevel2.containsKey(oppLineItem.Product_Level_2__c) && mapProductLevel2.get(oppLineItem.Product_Level_2__c) != NULL && mapProductLevel2.get(oppLineItem.Product_Level_2__c).Name == 'Foreign Exchange' ? true : false; 
        }
    }
    
    public Boolean isBond {
        get {
            return oppLineItem.Product_Level_3__c != NULL && mapProductLevel3.containsKey(oppLineItem.Product_Level_3__c) && (mapProductLevel3.get(oppLineItem.Product_Level_3__c).Name == 'Bonds - Local Currency' || mapProductLevel3.get(oppLineItem.Product_Level_3__c).Name == 'Bonds - Hard Currency') ? true : false;
        }
    }
    
    public Boolean isExternal {
        get {
            return opp.isExternal__c != NULL && opp.isExternal__c == true ? true : false;
        }
    }
    
    public String ProductLevel3Name {
    	get { return oppLineItem.Product_Level_3__c != NULL && mapProductLevel3.containsKey(oppLineItem.Product_Level_3__c) ? mapProductLevel3.get(oppLineItem.Product_Level_3__c).Name : ''; }
    }
    
    private ApexPages.StandardController stdCtrl;
    private String oppId;
    private String oliId;
    
    @testVisible
    private OpportunityLineItem oppLineItem;
    private Map<Id, Product2> mapProducts;
    private Map<Id, Product_Level_2__c> mapProductLevel2;
    private Map<Id, Product_Level_3__c> mapProductLevel3;
    private List<Product_Setting__mdt> ProductSettings;
    public Map<ID, User> Users;

    private static final String DEBT = 'Debt';
    private static final String UNMAPPED = 'Unmapped from PCB';
    public static final String ElectronicBanking = 'Electronic Banking';
    
    @testVisible
    private ProbabilityThreshhold__c PROBABILITYTHRESHHOLD = ProbabilityThreshhold__c.getValues('DebtFamilyProbability');
    public ProbabilityThreshhold__c PROBABILITY_THRESHHOLD {
        get { return PROBABILITYTHRESHHOLD; }
        set { PROBABILITYTHRESHHOLD = value; }
    }
    
    public AddProductToOpportunityController(ApexPages.StandardController stdController) {
        stdCtrl = stdController;
        
        List<String> fieldNames  = new List<String>();
        
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.OpportunityLineItem.fields.getMap();
        for (String fieldName: schemaFieldMap.keySet()) {
            fieldNames.add(fieldName);
        }
        
        if(!Test.isRunningTest())
        {
            stdCtrl.addFields(fieldNames);
            stdController.addFields(fieldNames);
        }
        
        
        oppLineItem = (OpportunityLineItem) stdCtrl.getRecord();
        
        //Create New OpportunityLineItem or Search for existing one
        oliId = ApexPages.currentPage().getParameters().get('id');
        oppId = ApexPages.currentPage().getParameters().get('oppId');
        
        existingProduct = '';

        if(String.isBlank(oliId) && String.isBlank(oppId)) {
            renderErrorMessage = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, Label.errMsg_UrlParamMissing));
            return;
        }
        
        if(String.isBlank(oliId)) {
            opp = [
                SELECT  id, OwnerId, Name, Type, CurrencyIsoCode,IsClosed, Pricebook2Id, Pricebook2.Name, CloseDate, Opportunity_Country__c, StageName, Probability, isExternal__c
                FROM    Opportunity 
                WHERE   id = :oppId
            ];
            //oli = new OpportunityLineItem(OpportunityId=opp.Id);
            oppLineItem.OpportunityId = opp.Id;
            isEdit = false;
        } else {
            //Select existing Opportunity Line Item fields
            OpportunityLineItem oli = [
                SELECT  OpportunityId, PricebookEntryId, PricebookEntry.Product2Id, PricebookEntry.Product2.Name, Product_Level_2__c, Product_Level_2__r.Name, Product_Level_3__c, Product_Level_3__r.Name
                FROM    OpportunityLineItem 
                WHERE   Id = :oliId
            ];

            //Determine what the high level product is
            if(oli.Product_Level_3__c != null) {
                existingProduct = oli.Product_Level_3__r.Name;
            } else if(oli.Product_Level_2__c != null) {
                existingProduct = oli.Product_Level_2__r.Name;
            } else {
                existingProduct = oli.PricebookEntry.Product2.Name;
            }
            
            //Select Opportunity
            opp = [
                SELECT  id, OwnerId, Name, Type, CurrencyIsoCode, Pricebook2Id, Pricebook2.Name, CloseDate, Opportunity_Country__c, StageName, Probability, isExternal__c
                FROM    Opportunity 
                WHERE   id = :oli.OpportunityId
            ];

            //Select PriceBook Entry
            priceBookEntry = [
                SELECT  Id, Product2Id, Product2.Name, Product2.IsActive, Product2.Family 
                FROM    PricebookEntry 
                WHERE   Id = :oli.PricebookEntryId
            ];
            productFamily = priceBookEntry.Product2.Family == null ? '' : priceBookEntry.Product2.Family;
            
            isEdit = true;
            //Set Product
            product = oli.PricebookEntry.Product2Id;
        }
        
        renderErrorMessage = false;

        //Set Existing flag
        isExisting = opp.Type == 'New to Bank' || opp.Type == 'Cross Sell' ? false : true;

        mapProducts = new Map<Id, Product2>([SELECT Id, Name, Family FROM Product2 WHERE IsActive=:true]);
        mapProductLevel2 = new Map<Id, Product_Level_2__c>([SELECT Id, Name FROM Product_Level_2__c WHERE Active__c=:true]);
        mapProductLevel3 = new Map<Id, Product_Level_3__c>([SELECT Id, Name FROM Product_Level_3__c WHERE Active__c=:true]);
        ProductSettings = [SELECT ProductName__c, ProductLevel__c, OpportunityCountry__c, Product_Partner_Team__c FROM Product_Setting__mdt WHERE ProductSet__c = 'ProductPartnerFilter' ORDER BY ProductLevel__c DESC];
        Users = new Map<Id, User>([Select Id, Team__c, Team_Role__c from User WHERE IsActive = true AND Profile.Name != 'Chatter Free User']);
        Date endOfYear = Date.newInstance(opp.CloseDate.year(), 12, 31);
        daysFromCloseDateToEndOfYear = opp.CloseDate.daysBetween(endOfYear);
        monthsFromCloseDateToEndOfYear = opp.CloseDate.monthsBetween(endOfYear);
        opportunityCountry = opp.Opportunity_Country__c;
        //Make sure ExcludeProductPartner is set correctly if a product is already set
        ProductPartnerExclusion();
    }
    
    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: Gets product list (level 1)
    * @param        None
    * @Returns:     List<SelectOption>
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 10/2015  Marta Malinowska   Add current inactive product to the list of products level 1
    *------------------------------------------------------------*/
    public List<SelectOption> getProducts() {
        List<SelectOption> options = new List<SelectOption>();
        if(isEdit == false){
            options.add(new SelectOption('','--Select--')); 
        }

        if(priceBookEntry != null && priceBookEntry.Product2.IsActive == false){
            options.add(new SelectOption(priceBookEntry.Product2Id, priceBookEntry.Product2.Name));
        }

        for(Product2 prod2 : [SELECT Id, Name FROM Product2 WHERE IsActive=true AND Name != :UNMAPPED ORDER BY Name asc]){
            options.add(new SelectOption(prod2.id, prod2.Name));
        }       

        return options;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: Gets product list (level 2)
    * @param        None
    * @Returns:     List<SelectOption>
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public List<SelectOption> getProductsLevel2() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--Select--')); 
        
        for(Product_Level_2__c prodl2 : [SELECT Id, Name FROM Product_Level_2__c WHERE Active__c = true AND Product__c = :product ORDER BY Name asc]){
            options.add(new SelectOption(prodl2.id, prodl2.Name));
        }

        return options;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: Gets product list (level 3)
    * @param        None
    * @Returns:     List<SelectOption>
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public List<SelectOption> getProductsLevel3() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('','--Select--')); 
        for(Product_Level_3__c prodl3 : [SELECT Id, Name FROM Product_Level_3__c WHERE Active__c = true AND Product_Level_2__c = :oppLineItem.Product_Level_2__c ORDER BY Name asc]){
            options.add(new SelectOption(prodl3.id, prodl3.Name));
        }

        return options;
    }
    
    /**
    * @Author:      Marek Cech
    * @Company:     Deloitte
    * @Description: This method handles changes of product
    * @param        None
    * @Returns:     PageReference - null
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference onProductChanged() {
        System.debug('### onProductChanged [selectedProductLevel: ' + selectedProductLevel + ', selectedProductId: ' + selectedProductId + ', selectedProductName: ' + selectedProductName + ']');
        
        if(String.isNotEmpty(selectedProductLevel) || String.isNotEmpty(selectedProductId)) {
            Integer selectedProductLevelInt = Integer.valueOf(selectedProductLevel);

            String newProductLevel1 = null;
            String newProductLevel2 = null;
            String newProductLevel3 = null;

            ProductSelection_Helper psHelper = new ProductSelection_Helper();

            if(selectedProductLevelInt == 1) {
                newProductLevel1 = selectedProductId;
            } else if(selectedProductLevelInt == 2) {
                newProductLevel2 = selectedProductId;
                newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
            } else if(selectedProductLevelInt == 3) {
                newProductLevel3 = selectedProductId;
                newProductLevel2 = psHelper.getProductParent(3, newProductLevel3);
                newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
            }

            //Save the new Product Values
            System.debug('### Saving Product values to [Product: ' + newProductLevel1 + ', Product_Level_2__c: ' + newProductLevel2 + ', Product_Level_3__c: ' + newProductLevel3);

            product = newProductLevel1;
            oppLineItem.Product_Level_2__c = newProductLevel2;
            oppLineItem.Product_Level_3__c = newProductLevel3;
        
            //Product family handling
            Product2 p = mapProducts.get(product);
            if(p != null) {
                if(p.Family != productFamily) {
                   productFamily = p.Family == null ? '' : p.Family;
                }
            } else {
                productFamily = '';
            }
        } else {
            product = null;
            oppLineItem.Product_Level_2__c = null;
            oppLineItem.Product_Level_3__c = null;

            productFamily = '';
        }
        
        // If a new oppLineItem then apply Product Partner Default rules
        updateProductPartner();
        
        return null;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: Save Opportunity Line Item
    * @param        None
    * @Returns:     view page for Opportunity
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 10/2015     Marta Malinowska   Check if Product Level 1 has been changed
    *------------------------------------------------------------*/
    public PageReference save() {
        validate();
        if(ApexPages.getMessages().isEmpty() == false) {
            return null;
        }

        System.debug('### Passed validate. Into Save for oppLineItem [' + oppLineItem + ']');

        if(String.isBlank(oppLineItem.Id)){
            oppLineItem.PricebookEntryId = newPriceBookEntry.Id;
        }

        if(String.isNotBlank(oppLineItem.Id) && newPriceBookEntry.Id != priceBookEntry.Id){
            try {
                changePriceBookEntryOnOppLineItem(oppLineItem, newPriceBookEntry);
            } catch(DmlException ex){
                for(Integer i=0; i < ex.getNumDml(); i++){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(i)));
                }
                return null;
            }
        } else {
            System.debug('### Calling standard controller.save()');
            
            PageReference pageRef = stdCtrl.save();
            if(pageRef == null) {
                return pageRef;
            }
        }

        PageReference oppPage = new ApexPages.StandardController(opp).view();
        oppPage.setRedirect(false);
        return oppPage;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: Save Opportunity Line Item
    * @param        None
    * @Returns:     add new product to opportunity page
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference saveAndNew() {
        validate();
        if(ApexPages.getMessages().isEmpty() == false) {
            return null;
        }
        
        PageReference pr = stdCtrl.save();
        if(pr == null) {
            return pr;
        }

        PageReference newOli = new PageReference('/apex/AddProductToOpportunity?oppId=' + opp.Id);
        newOli.setRedirect(true);
        return newOli;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: Cancel changes
    * @param        None
    * @Returns:     view page for Opportunity
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference cancel() {
        PageReference oppPage = new ApexPages.StandardController(opp).view();
        oppPage.setRedirect(true);
        return oppPage;
    }

    /**
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: RPF Calculator redirect
    * @param        None
    * @Returns:     view page RPF Calculator
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference Calculate() {
        if (Save()!=NULL)
          return new PageReference('/apex/RPFCalculator?oliId=' + oliId);    
        else
            return NULL;
    }
    
    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: Validate if Product Level 1 is selected and can be assigned to Opportunity 
    * @param        None
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public void validate() {
        System.debug('### Entering Validate');
		for(Product_Setting__mdt ps : [SELECT Id,ProductName__c, ProductLevel__c, OpportunityCountry__c, Product_Partner_Team__c,CheckBalanceFacilitySize__c,
                           			CurrencyIsoCode__c,BalanceFacilitySize__c
                           FROM Product_Setting__mdt 
                                       WHERE ProductSet__c = 'validation'
                                       ORDER BY ProductLevel__c DESC]) {
             System.debug('Entered Product Setting' +ProductSettings.size());
            if((
                (ps.ProductLevel__c == 1 && product != NULL && mapProducts.get(product) != null && mapProducts.get(product).Name == ps.ProductName__c) ||
                (ps.ProductLevel__c == 2 && oppLineItem.Product_Level_2__c != NULL && mapProductLevel2.get(oppLineItem.Product_Level_2__c) != null && mapProductLevel2.get(oppLineItem.Product_Level_2__c).Name == ps.ProductName__c) ||
                (ps.ProductLevel__c == 3 && oppLineItem.Product_Level_3__c != NULL && mapProductLevel3.get(oppLineItem.Product_Level_3__c) != null && mapProductLevel3.get(oppLineItem.Product_Level_3__c).Name == ps.ProductName__c)
            ))
            {
                System.debug('Found'+ps.CurrencyIsoCode__c);
                if(ps.CheckBalanceFacilitySize__c && ps.BalanceFacilitySize__c !=null && ps.CurrencyIsoCode__c!=null)
                {
                    Decimal convertedAmount = convert(oppLineItem.Balance__c,opp.CurrencyIsoCode,ps.CurrencyIsoCode__c);

                    System.debug(convertedAmount);
                    if(convertedAmount>=ps.BalanceFacilitySize__c)
                    {
                        if(Users.containsKey(oppLineItem.ProductPartner__c))
                            if(!Users.get(oppLineItem.ProductPartner__c).Team__c.equalsIgnoreCase(ps.Product_Partner_Team__c))
                            	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Facility size is greater than or equal '+ps.CurrencyIsoCode__c+' '+String.valueOf(convertedAmount.format())+'. Only these Product Partner Teams allowed for this Product:'+ps.Product_Partner_Team__c));
                    }
                    
                   
                }
                 break;
            }
        }
        if(oppLineItem.Primary_Banking_Target__c == NULL && oppLineItem.Product_Level_2__c != NULL && mapProductLevel2.containsKey(oppLineItem.Product_Level_2__c) && mapProductLevel2.get(oppLineItem.Product_Level_2__c).Name == ElectronicBanking && opportunityCountry != NULL && opportunityCountry == 'South Africa')
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_PrimaryBankingTarget_Validation));
        }
        
        if(oppLineItem.MonthlyValue__c == NULL && oppLineItem.Product_Level_3__c != NULL && mapProductLevel3.containsKey(oppLineItem.Product_Level_3__c) && mapProductLevel3.get(oppLineItem.Product_Level_3__c).Name.Contains('Domestic Payments') && opportunityCountry != NULL && opportunityCountry == 'South Africa')
        {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_MonthlyValue_Validation));
        }
        
        if(String.isBlank(product)) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_AddProductToOpportunitySelectProduct));
        } 

        if(String.isBlank(opp.Pricebook2Id)) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Price Book is not selected. Please contact System Administrator.'));
        }

        if(opp.Probability > PROBABILITY_THRESHHOLD.Probability__c && (productFamily == DEBT && !isCPF) && (oppLineItem.RoRWA__c == NULL || oppLineItem.RWA__c == NULL)) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_MandatoryFieldsForDebtFamily));
        }
        
        if(oppLineItem.Gross_Margin__c == NULL && (productFamily == DEBT && !isCPF) && opportunityCountry != NULL && opportunityCountry == 'South Africa' && (opp.StageName == 'Initial Solution Proposed' || opp.StageName == 'Credit Case Submitted' || opp.StageName == 'Credit Sanctions Obtained' || opp.StageName == 'Pricing Finalised' || opp.StageName == 'Mandate Won' || opp.StageName == 'Contracts Finalised' || opp.StageName == 'In Implementation / Conditions Precedent' || opp.StageName == 'Closed Won')) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_MarginMandatory));
        }
        
        if(oppLineItem.Terms_Years__c == NULL && (productFamily == DEBT && !isCPF) && opportunityCountry != NULL && opportunityCountry == 'South Africa' && (opp.StageName == 'Initial Solution Proposed' || opp.StageName == 'Credit Case Submitted' || opp.StageName == 'Credit Sanctions Obtained' || opp.StageName == 'Pricing Finalised' || opp.StageName == 'Mandate Won' || opp.StageName == 'Contracts Finalised' || opp.StageName == 'In Implementation / Conditions Precedent' || opp.StageName == 'Closed Won')) {
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_TermMandatory));
        }
        
        if(oppLineItem.LoanType__c == NULL && (productFamily == DEBT && !isCPF)) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_MandatoryRefinance));
        }
        
        if(oppLineItem.LoanType__c != NULL && oppLineItem.LoanType__c == 'Refinance' && oppLineItem.RefinanceIncreaseDecrease__c == NULL && productFamily == DEBT) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_MandatoryRefinanceIncreaseDecrease));
        }
        
        if(oppLineItem.ProductPartner__c == NULL && oppLineItem.Product_Level_2__c != NULL && !String.isBlank(String.valueOf(oppLineItem.Product_Level_2__c))) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_AddProductToOpportunitySelectProductPartner));
        }
        
        if (oppLineItem.ProductPartner__c != NULL)
        {
            if(isProductPartner(UserInfo.getUserId()) )
            {
                if(oppLineItem.Annualised_Income__c == 0){
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_AddProductToOpportunityAddIncome));
                }
            }
        }
        
        String checkProductPartnerTeam = checkProductPartnerTeam();
        if (checkProductPartnerTeam != NULL && ExcludeProductPartner) {
            for(String message : checkProductPartnerTeam.Split('<br/>'))
            	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, message));
        }
        
        if((opp.StageName == 'Initial Solution Proposed' || opp.StageName == 'Credit Case Submitted' || opp.StageName == 'Credit Sanctions Obtained' || opp.StageName == 'Pricing Finalised' || opp.StageName == 'Mandate Won' || opp.StageName == 'Contracts Finalised') && oppLineItem.Product_Level_2__c == NULL){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_AddProductLevel2ToOpportunity));
        }
        
        if(opp.StageName == 'In Implementation / Conditions Precedent' && oppLineItem.Product_Level_3__c == NULL){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_AddProductLevel3ToOpportunityInImplementation));
        }

        try {
            newPriceBookEntry = [
                SELECT  Id, Product2Id 
                FROM    PricebookEntry 
                WHERE   Product2Id = :product AND Pricebook2Id = :opp.Pricebook2Id AND CurrencyIsoCode = :opp.CurrencyIsoCode 
                LIMIT   1];
        } catch(QueryException ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Standard Price for selected product and currency ' + opp.CurrencyIsoCode + ' is not configured. Please contact System Administrator.'));
        }
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: Delete old Opportunity Line Item and create new one if Product Level 1 is changed.
    * @param        Opportunity Line Item
    * @param        Price Book Entry
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 11.11.2015    Marek Cech    Removed Booking Centre
    *------------------------------------------------------------*/
    public static void changePriceBookEntryOnOppLineItem(OpportunityLineItem oppLineItem, PricebookEntry newPriceBookEntry) {
        //Clone Opportunity Line Item
        OpportunityLineItem newOppLineItem = new OpportunityLineItem();
        newOppLineItem.OpportunityId = oppLineItem.OpportunityId;
        newOppLineItem.PricebookEntryId = newPriceBookEntry.Id;
        newOppLineItem.Product_Level_2__c = oppLineItem.Product_Level_2__c;
        newOppLineItem.Product_Level_3__c = oppLineItem.Product_Level_3__c;
        newOppLineItem.Annualised_Income__c = oppLineItem.Annualised_Income__c;
        newOppLineItem.Balance__c = oppLineItem.Balance__c;
        newOppLineItem.Margin__c = oppLineItem.Margin__c;
        newOppLineItem.Estimated_Utilisation__c = oppLineItem.Estimated_Utilisation__c;
        newOppLineItem.Fees__c = oppLineItem.Fees__c;
        newOppLineItem.Recurring_Fees_Period__c = oppLineItem.Recurring_Fees_Period__c;
        newOppLineItem.Recurring_Fees__c = oppLineItem.Recurring_Fees__c;
        newOppLineItem.Income_this_Year__c = oppLineItem.Income_this_Year__c;
        newOppLineItem.Terms_Years__c = oppLineItem.Terms_Years__c;
        newOppLineItem.ROEC__c = oppLineItem.ROEC__c;
        newOppLineItem.RoRWA__c = oppLineItem.RoRWA__c;
        newOppLineItem.RoRWA1styear__c = oppLineItem.RoRWA1styear__c;
        newOppLineItem.RWA__c = oppLineItem.RWA__c;
        newOppLineItem.RWA1styear__c = oppLineItem.RWA1styear__c;
        newOppLineItem.Gross_Margin__c = oppLineItem.Gross_Margin__c;
        newOppLineItem.Ftp__c = oppLineItem.Ftp__c;
        newOppLineItem.New_Facility_Balance__c = oppLineItem.New_Facility_Balance__c;
        newOppLineItem.Existing_Facility_Balance__c = oppLineItem.Existing_Facility_Balance__c;
        newOppLineItem.Net_Facility_Balance__c = oppLineItem.Net_Facility_Balance__c;
        newOppLineItem.New_Facility__c = oppLineItem.New_Facility__c;
        newOppLineItem.Hold_Size__c = oppLineItem.Hold_Size__c;
        newOppLineItem.Base_Rate__c = oppLineItem.Base_Rate__c;
        newOppLineItem.Rate_Type__c = oppLineItem.Rate_Type__c;
        newOppLineItem.Loan_Profile__c = oppLineItem.Loan_Profile__c;
        newOppLineItem.LoanType__c = oppLineItem.LoanType__c;
        newOppLineItem.RefinanceIncreaseDecrease__c = oppLineItem.RefinanceIncreaseDecrease__c;
        newOppLineItem.Arranging_Fee__c = oppLineItem.Arranging_Fee__c;
        newOppLineItem.Syndicated__c = oppLineItem.Syndicated__c;
        newOppLineItem.Underwrite__c = oppLineItem.Underwrite__c;
        newOppLineItem.Participation_Fee__c = oppLineItem.Participation_Fee__c;
        newOppLineItem.Agency_Fee__c = oppLineItem.Agency_Fee__c;
        newOppLineItem.Annual_Facility_Fee__c = oppLineItem.Annual_Facility_Fee__c;
        newOppLineItem.Unutilised_Facility_Fee__c = oppLineItem.Unutilised_Facility_Fee__c;
        newOppLineItem.Committment_Fee__c = oppLineItem.Committment_Fee__c;
        newOppLineItem.Co_ordination_Fee__c = oppLineItem.Co_ordination_Fee__c;
        newOppLineItem.Arranging_Fee_Deferred__c = oppLineItem.Arranging_Fee_Deferred__c;
        newOppLineItem.Participation_Fee_Deferred__c = oppLineItem.Participation_Fee_Deferred__c;
        newOppLineItem.Agency_Fee_Deferred__c = oppLineItem.Agency_Fee_Deferred__c;
        newOppLineItem.Other_Fees_Deferred__c = oppLineItem.Other_Fees_Deferred__c;
        newOppLineItem.Coordination_Fee_Deferred__c = oppLineItem.Coordination_Fee_Deferred__c; 
        newOppLineItem.RORC__c = oppLineItem.RORC__c;
        newOppLineItem.RORC1stYear__c = oppLineItem.RORC1stYear__c;
        newOppLineItem.Threshold__c = oppLineItem.Threshold__c;
        newOppLineItem.ProductPartner__c = oppLineItem.ProductPartner__c;
    	newOppLineItem.Term_Interval__c = oppLineItem.Term_Interval__c;
        newOppLineItem.Transaction_Value__c = oppLineItem.Transaction_Value__c;
        newOppLineItem.Volume__c = oppLineItem.Volume__c;
        newOppLineItem.StartDate__c = oppLineItem.StartDate__c;
        newOppLineItem.DrawPercentageCurrentYear__c = oppLineItem.DrawPercentageCurrentYear__c;
        newOppLineItem.DrawPercentageNextYear__c = oppLineItem.DrawPercentageNextYear__c;
        newOppLineItem.Primary_Banking_Target__c = oppLineItem.Primary_Banking_Target__c;
        newOppLineItem.BulletAmount__c = oppLineItem.BulletAmount__c;
		newOppLineItem.BulletPaymentDue__c = oppLineItem.BulletPaymentDue__c;
		newOppLineItem.Flexi__c = oppLineItem.Flexi__c;
		newOppLineItem.LTV__c = oppLineItem.LTV__c;
		newOppLineItem.NewCapital__c = oppLineItem.NewCapital__c;
		newOppLineItem.RefinanceAmount__c = oppLineItem.RefinanceAmount__c;
		newOppLineItem.SecondaryLoan__c = oppLineItem.SecondaryLoan__c;
        newOppLineItem.FlexiFee__c = oppLineItem.FlexiFee__c;
        newOppLineItem.MonthlyValue__c = oppLineItem.MonthlyValue__c;
        newOppLineItem.FX_Sales_Comment__c = oppLineItem.FX_Sales_Comment__c;
        
        DELETE new OpportunityLineItem(Id=oppLineItem.Id);
        INSERT newOppLineItem;
    }
    
    /**
    * @Author:      Marek Cech
    * @Company:     Deloitte
    * @Description: getter of debt string
    * @Returns:     void
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public String getDebt() {
        return DEBT;
    }
    
    /***************************************************************************************
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: Returns a Boolean signifying whether to load default Product partner or not
    * @Returns:     Boolean
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *--------------------------------------------------------------------------------------*/
    public Boolean ProductPartnerExclusion() {
        if (opp != NULL && opp.Type != NULL && opp.Type == 'Income Recovery') {
        	ExcludeProductPartner = false;
            return false;
        }
        
        if (product == null || mapProducts.get(product) == null || mapProducts.get(product).Name == null) return false;
        
        Integer ProductCount =  [SELECT COUNT() FROM Product_Setting__mdt
                                 WHERE ProductSet__c = 'ProductPartnerExclusion'
                                 AND ProductLevel__c = 1
                                 AND ProductName__c = :mapProducts.get(product).Name
                                 LIMIT 1];
        
        if (ProductCount > 0) {
            ExcludeProductPartner = true;
            return true;
        } else {
            ExcludeProductPartner = false;
            return false;
        }
    }
    
    /***************************************************************************************
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: Sets the Product Partner to the opportunity owner if required
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *--------------------------------------------------------------------------------------*/
    public void updateProductPartner() {
        Boolean ExcludePP = ProductPartnerExclusion();

        if (oppLineItem.Id == NULL) {
          if (product == null)
              oppLineItem.ProductPartner__c = NULL;
          else if (opp != null && opp.OwnerId != NULL && !ExcludePP)
              oppLineItem.ProductPartner__c = opp.OwnerId;
          else if (opp != null && opp.OwnerId != NULL && ExcludePP)
        	  oppLineItem.ProductPartner__c = NULL;
          else
              oppLineItem.ProductPartner__c = NULL;
        }
    }
    
    public boolean isProductPartner(ID userID)
    {
        boolean isBanker=false;
        try
        {
            String TeamRole = Users.get(userId).Team_Role__c;       
            
            if(!String.isBlank(TeamRole))
            {
                if(teamRole.equalsIgnoreCase('Product Partner'))
                {
                    isBanker = true;
                }
                
            }
            
        }
        catch(Exception exc)
        {
        }
        return isBanker;
    }
    
    /***************************************************************************************
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: Checks if the Product Partner in question qualifies for this Product
    * 				and returns a relevant message if it doesn't
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *--------------------------------------------------------------------------------------*/
    public String checkProductPartnerTeam() {
        String ProductsMessage = '';
        String TeamMessage = '';
        Boolean TeamOrProductMatch = false;
        Decimal CurrentProductLevel;
        
        if (oppLineItem.ProductPartner__c != NULL) {
            String PPTeam;
            if (Users.containsKey(oppLineItem.ProductPartner__c))
        		PPTeam = Users.get(oppLineItem.ProductPartner__c).Team__c;
            else 
				PPTeam = NULL;
                
            if (PPTeam != NULL && PPTeam != '') {
            	for(Product_Setting__mdt ps : ProductSettings) {
               		if (ps.ProductLevel__c != NULL &&
                        ps.ProductName__c != NULL &&
                        ps.Product_Partner_Team__c != NULL) {
						if (TeamOrProductMatch && CurrentProductLevel != NULL && CurrentProductLevel != ps.ProductLevel__c) break;
                            
                        for(String team : ps.Product_Partner_Team__c.Split('\\|')) {
                            Boolean ProductMatch = (
                                (
                                    (ps.ProductLevel__c == 1 && product != NULL && mapProducts.get(product) != null && mapProducts.get(product).Name == ps.ProductName__c) ||
                                    (ps.ProductLevel__c == 2 && oppLineItem.Product_Level_2__c != NULL && mapProductLevel2.get(oppLineItem.Product_Level_2__c) != null && mapProductLevel2.get(oppLineItem.Product_Level_2__c).Name == ps.ProductName__c) ||
                                    (ps.ProductLevel__c == 3 && oppLineItem.Product_Level_3__c != NULL && mapProductLevel3.get(oppLineItem.Product_Level_3__c) != null && mapProductLevel3.get(oppLineItem.Product_Level_3__c).Name == ps.ProductName__c)
                                ) && 
                                	(opp == NULL || ps.OpportunityCountry__c == NULL || String.IsBlank(ps.OpportunityCountry__c) || (opp != NULL && (opp.Opportunity_Country__c == NULL || String.IsBlank(opp.Opportunity_Country__c) || (opp.Opportunity_Country__c != NULL && SettingExists(ps.OpportunityCountry__c, opp.Opportunity_Country__c)))))
                        	);
                            if (team == PPTeam || ProductMatch)
                            {
                                TeamOrProductMatch = true;
                                // The team and Product matched so the validation passes
                            	if (team == PPTeam && ProductMatch)
                                	return NULL;
                                else {
                                    // The team matched but the product didn't
                                    if (team == PPTeam) {
                                        ProductsMessage += 'Level ' + Integer.valueOf(ps.ProductLevel__c) + ':  ' + ps.ProductName__c + ',';
                                    // The Product matched but the team didn't
                                    } else {
                                        TeamMessage += team + ',';
                                    }
                                }
                            }
                        }
                        CurrentProductLevel = ps.ProductLevel__c;
                    }
            	}
            }
        }

        String returnString = '';
        if (ProductsMessage != '') ProductsMessage = 'Only these Products permissable for this Product Partner: ' + ProductsMessage.removeEnd(',');
        if (TeamMessage != '') TeamMessage = 'Only these Product Partner Teams allowed for this Product: ' + TeamMessage.removeEnd(',');
        if (ProductsMessage != '' && TeamMessage != '') returnString += ProductsMessage + '<br/>' + TeamMessage;
        if (ProductsMessage != '' && TeamMessage == '') returnString += ProductsMessage;
        if (ProductsMessage == '' && TeamMessage != '') returnString += TeamMessage;
        if (returnString != '') return returnString;
        else return NULL;
    }
    
    private Boolean SettingExists(String setting, String searchSetting) {
        for(String s : setting.Split('\\|')) {
            if (s.trim() == searchSetting.trim()) return true;
        }
        return false;
  	}
    
    public static Map<String,CurrencyType> conversions{get;set;}
    public static List<CurrencyType> currencies{get;set;}
    //Tonga MM : Convert between two known currencies.
    public  Decimal convert(Decimal value, String fromIso, String toIso) {
        
        // build map
        
        if(conversions == null)
        {
            conversions = new Map<String,CurrencyType>();
            
            Map<String,CurrencyType> conversions = new Map<String,CurrencyType>();
            currencies = [select Id, IsCorporate, IsoCode, ConversionRate, DecimalPlaces from CurrencyType where IsActive=true];
        }
        
        for (CurrencyType cur : currencies) {
            conversions.put(cur.IsoCode, cur);
            
        }
        if (String.isBlank(fromIso) || String.isBlank(toIso) ) {
            return value;
        }
      
        if(value==null)
        {
            value=0;
        }
        // if same currencies we simply round
        if (fromIso.equalsIgnoreCase(toIso)) {
            return value.setScale(conversions.get(fromIso.toUpperCase()).DecimalPlaces, System.RoundingMode.HALF_UP);
        }
        //Tonga MM : calculations
        final Decimal rate = ((CurrencyType)conversions.get(toIso.toUpperCase())).ConversionRate/((CurrencyType)conversions.get(fromIso.toUpperCase())).ConversionRate;
        final Decimal resultRounded = (value * rate).setScale(conversions.get(toIso.toUpperCase()).DecimalPlaces, System.RoundingMode.HALF_UP);
        
        // return
        return resultRounded;
    }
}