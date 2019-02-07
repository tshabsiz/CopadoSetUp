/**
* @Author       Marek Cech
* Company:      Deloitte
* @Description: Pipeline Report controller class.
* @Date:        10/2015
* @TestClass:   ZZTEST_PipelineReportController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 12/01/2016	C Reinecke		Added Client Country column and filter
* 17/02/2016	C Reinecke		Ordered Owner and Banker Lists Alphabetically
*------------------------------------------------------------*/
/**
* @Author       Marek Cech
* Company:      Deloitte
* @Description: Pipeline Report controller class.
* @Date:        10/2015
* @TestClass:   ZZTEST_PipelineReportController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 12/01/216		C Reinecke		Added Client Country column and filter
* 22/02/216   Marta Malinowska  Changed Relationship Type filter to Prospect/Existing Relationships and added Pipeline Segmentation filter
*------------------------------------------------------------
*@ LastmodifiedBy : Mabhedle Tonga 
*@ LastModifiedDate : 2017-05-22
*@ Modification Description : Added additional filter criterias(Team Member Name,Opportunity Country,Team Name) 
*--------------------------------------------------------------
*@ LastmodifiedBy : Mabhedle Tonga 
*@ LastModifiedDate : 2017-05-31
*@ Modification Description : Added additional filter criterias(TB Region,Sub Stage,Product Partner Approval,Product Partner) 
*--------------------------------------------------------------
*/
public with sharing class PipelineReportController {

    public List<Opportunity> optys {get;set;}
    
    public String orgTypeJson {get;set;}
        
    public String productLevel1OptionsJson {get;set;}
    
    public String productLevel2OptionsJson {get;set;}
    
    public String productLevel3OptionsJson {get;set;}
    
    public String optyStageOptionsJson {get;set;}
 
    //Tonga MM : Added addition collection for new filters included in the report
    public String opportunityCountryJson{get;set;}
    
    public String teamNameOptionsJson {get;set;}
    
    public String teamMemberIdsJson {get;set;}
    
    public String optySubStageOptionsJson {get;set;}
    
    public String optyApprovalStatusOptionJson{get;set;}
    
    public String TBRegionOptionJson{get;set;}
    
    //Tonga : MM SFAFRICA 1043
    public String chosenView{get;set;}
 
    public String teamRoleOptionsJson {get;set;}
    
    public String accountClientCountryOptionsJson {get;set;}
    
    public String accountClientRegionOptionsJson {get;set;}
    
    public String accountSegmentOptionsJson {get;set;}
    
    public String userTeamOptionsJson {get;set;}
    
    public String bankersJson {get;set;}
    
    public String coverageTeamJson {get;set;}
    
    public String currencyIsoCode {get;set;}
    
    public String closeDateString {get;set;}

    public String pipelineOptionsJson {get;set;}
    
    public String bankerIdsJson {get;set;}
    
    public String oppOwnerIdsJson {get;set;}
    
    public String productPartnerIdsJson{get;set;}
    
    public String orgIdJson {get;set;}
    
    //table sorting parameters - column and (asc or desc)
    public String sortColumn {get;set;}
    
    public String sortOrder {get;set;}
    
    //pagination information
    public Integer queryOffset {get;set;}
    
    public Integer optyCount {get;set;}
    
    //table totals
    public Decimal facilitySize {get;set;}
    
    public Decimal incomeThisYear {get;set;}
    
    public Decimal annualisedIncome {get;set;}
    
    public Decimal weightedIncomeThisYear {get;set;}
    
    public Decimal weightedAnnualisedIncome {get;set;}
   
    //private fields for query creation
    private List<Id> optyIds;
    
    @testVisible
    private List<Account> accounts;
    
    @testVisible
    private Date startDate;
    
    @testVisible
    private Date endDate;
    
    @testVisible
    private Boolean keepOffset {get;set;}

    @testVisible
    private Map<String, List<Id>> relationshipTypesMap;
    
    @testVisible
    private static final Integer QUERY_LIMIT = 15;
    
    private static final Integer EXCEL_QUERY_LIMIT = 10000;
    
    private static final String COUNT_QUERY = 'SELECT Count(Id) oppCount, SUM(Total_Balance_Facility_Size__c) ' +
        'totalFacilitySize, SUM(Income_this_Year__c) totalIncomeThisYear, SUM(Annualised_Income__c) ' +
        'totalAnnualisedIncome, SUM(Weighted_Income_this_Year__c) totalWeightedIncomeThisY, ' +
        'SUM(Weighted_Annualised_Income__c) totalWeightedAnnIncome FROM Opportunity';
    
    //private fields for json creation
    private static final String JSON_NAME = 'name';
    
    private static final String JSON_ID = 'id';
    
    private static final String EMPTY_JSON_ARRAY = '[]';

    private static final String PROSPECT = 'Prospect';

    @testVisible
    private static final String TYPE_PROSPECT = 'Prospect Relationships';

    @testVisible
    private static final String TYPE_EXISTING = 'Existing Relationships';

    @testVisible
    private static final String ALL_OPEN_OPPS = 'All Open Opportunities';

    @testVisible
    private static final String ALL_OPPS_MORE_THAN_50 ='All Opportunities > 50%';

    @testVisible
    private static final String ALL_CLOSED_OPPS = 'All Closed Opportunities';

    public List<Integer> NUM_OF_OPPTEAMMEMBERS{get{return new List<Integer>{1,2,3,4,5,6,7,8,9,10};}}
    
    /**
    * @description Contructor, prepares jsons for typeaheads.
    */
    public PipelineReportController() {
        queryOffset = 0;
        keepOffset = false;

        prepareCurrencyIsoCode();
        prepareRelationshipTypesMap();
        prepareData();
        prepareBankersJson();
        prepareCoverageTeamJson();
        
        if (!Test.isRunningTest()) {
            prepareOptyCount();
        }
    }
    
    /**
    * @description Prepares query and list of opportunities.
    */
    public PageReference prepareData() {
        if (!keepOffset) {
            queryOffset = 0;
        }
        keepOffset = false;
        
        String query = prepareQuery(true, true, false);
        optys = Database.query(query);
        
        if (!Test.isRunningTest()) {
            prepareOptyCount();
        }
        return null;
    }
    
    /**
    * @description Moves offset to next page.
    */
    public PageReference moveNext() {
        if ((queryOffset + QUERY_LIMIT) < optyCount) {
            queryOffset += QUERY_LIMIT;
        }
        keepOffset = true;
        prepareData();
        return null;
    }
    
    /**
    * @description Moves offset to previous page.
    */
    public PageReference movePrevious() {
        if ((queryOffset - QUERY_LIMIT) >= 0) {
            queryOffset -= QUERY_LIMIT;
        } else {
            queryOffset = 0;
        }
        keepOffset = true;
        prepareData();
        return null;
    }
    
    /**
    * @description Moves offset to the first page.
    */
    public PageReference moveFirst() {
        queryOffset = 0;
        keepOffset = true;
        prepareData();
        return null;
    }
    
    /**
    * @description Moves offset to the last page.
    */
    public PageReference moveLast() {
        if ((optyCount - QUERY_LIMIT) >= 0) {
            queryOffset = optyCount - QUERY_LIMIT;
        } else {
            queryOffset = 0;
        }
        keepOffset = true;
        prepareData();
        return null;
    }
    
    /**
    * @description Prepares query and list of opportunities for excel.
    * @return List<Opportunity> - queried opportunities
    */
    public List<Opportunity> getExcelData() {
        String query = prepareQuery(false, true, true);
        return Database.query(query);
    }
    
    /**
    * @description Shows excel export page.
    * @return PageReference
    */
    public PageReference showExcelPage() {
        PageReference pr = Page.PipelineReportExcel;
        pr.setRedirect(false);
        return pr;
    }
    
    /**
    * @Author:          Marta Malinowska
    * @Company:         Deloitte
    * @Description:     Prepare select options for Relationship Type filter.
    * @Params           None
    * @Returns:         List<SelectOption> - list of relationship type options
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public List<SelectOption> getOrgTypes() {  
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption(TYPE_PROSPECT, TYPE_PROSPECT));
        options.add(new SelectOption(TYPE_EXISTING, TYPE_EXISTING)); 
        return options;
    }
    
    /**
    * @description Prepares json of buying groups for typeahead.
    */
    public String getBuyingGroupJson() {
        if (orgTypeJson == null) {
            return EMPTY_JSON_ARRAY;
        }
        List<String> recTypes = (List<String>) JSON.deserialize(orgTypeJson, List<String>.class);
        List<Id> recTypeIds = new List<Id>();
        for(String recType : recTypes){
            recTypeIds.addAll(relationshipTypesMap.get(recType));
        }
    
        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartArray();
        
        for (Account acc: [SELECT Id, Name FROM Account WHERE Id IN 
            (SELECT AccountId FROM Opportunity WHERE Account.RecordTypeId IN :recTypeIds)]) {
        
            generator.writeStartObject();
            generator.writeStringField(JSON_NAME, acc.Name);
            generator.writeStringField(JSON_ID, acc.Id);
            generator.writeEndObject();
        }
        generator.writeEndArray();
        return generator.getAsString();
    }
    
    /**
    * @description Prepares select options of level 1 products for frontend.
    * @return List<SelectOption> 
    */
    public List<SelectOption> getProductsLevel1() {
        List<SelectOption> options = new List<SelectOption>();
        for (Product2 prod2 : [SELECT Id, Name FROM Product2 WHERE IsActive=:true ORDER BY Name asc]){
            options.add(new SelectOption(prod2.id, prod2.Name));
        }       
        return options;
    }
    
    /**
    * @description Prepares select options of level 2 products for frontend.
    * @return List<SelectOption> 
    */
    public List<SelectOption> getProductsLevel2() {
        List<SelectOption> options = new List<SelectOption>();
        if (productLevel1OptionsJson == null) {
            return options;
        }
        
        List<String> productsLvl1 = (List<String>) JSON.deserialize(productLevel1OptionsJson, List<String>.class);
        if (productsLvl1.isEmpty()) {
            return options;
        }
        
        String query = 'SELECT Id, Name FROM Product_Level_2__c WHERE Active__c = true AND (';
        
        for (Integer i = 0; i < productsLvl1.size(); i++) {
            query += ' Product__c = \'' + productsLvl1[i] + '\'';
            if (i != productsLvl1.size() -1) {
                query += ' OR';
            }
        }
        
        if (productsLvl1.size() > 0) {
            query += ')';
        }
        
        query += ' ORDER BY Name asc LIMIT 1000';
        
        List<Product_Level_2__c> products = Database.query(query);
        for (Product_Level_2__c product: products) {
            options.add(new SelectOption(product.id, product.Name));
        }
        return options;
    }

    /**
    * @description Prepares select options of level 3 products for frontend based on product level 1 and 2
    * @return List<SelectOption> 
    */
    public List<SelectOption> getProductsLevel3() {
        List<SelectOption> options = new List<SelectOption>();
        
        if (productLevel1OptionsJson == null || productLevel2OptionsJson == null) {
            return options;
        }
        
        List<String> productsLvl1 = new List<String>();
        List<String> productsLvl2 = new List<String>();
        if (productLevel1OptionsJson != null) productsLvl1 = (List<String>) JSON.deserialize(productLevel1OptionsJson, List<String>.class);
        if (productLevel2OptionsJson != null) productsLvl2 = (List<String>) JSON.deserialize(productLevel2OptionsJson, List<String>.class);
            
        if (productsLvl1.isEmpty() || productsLvl2.isEmpty()) {
            return options;
        }
        
        String query = 'SELECT Id, Name FROM Product_Level_3__c WHERE Active__c = true';
        if (productsLvl1.size() > 0) query += ' AND (';
        for (Integer i = 0; i < productsLvl1.size(); i++) {
            query += ' Product_Level_2__r.Product__c = \'' + productsLvl1[i] + '\'';
            if (i != productsLvl1.size() -1) {
                query += ' OR';
            }
        }
        if (productsLvl1.size() > 0) query += ')';
        
        if (productsLvl2.size() > 0) query += ' AND (';
        for (Integer i = 0; i < productsLvl2.size(); i++) {
            query += ' Product_Level_2__c = \'' + productsLvl2[i] + '\'';
            if (i != productsLvl2.size() -1) {
                query += ' OR';
            }
        }
        if (productsLvl2.size() > 0) query += ')';
        
        query += ' ORDER BY Name asc LIMIT 1000';
        
        List<Product_Level_3__c> products = Database.query(query);
        for (Product_Level_3__c product: products) {
            options.add(new SelectOption(product.id, product.Name));
        }
        return options;
    }
    
    /**
    * @Author:          Marta Malinowska
    * @Company:         Deloitte
    * @Description:     Prepares select options of Pipeline Segmentation filter.
    * @Params           None
    * @Returns:         List<SelectOption> - list of pipeline segmentation options
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public List<SelectOption> getPipelineValues() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption(ALL_OPEN_OPPS, ALL_OPEN_OPPS));
        options.add(new SelectOption(ALL_OPPS_MORE_THAN_50, ALL_OPPS_MORE_THAN_50));
        options.add(new SelectOption(ALL_CLOSED_OPPS, ALL_CLOSED_OPPS));
        return options;
    }

    /**
    * @description Prepares select options of opportunity stages for frontend.
    * @return List<SelectOption> 
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 24/02/2016  Marta Malinowska   Add dependency from selected Pipeline Segmentation options.
    *------------------------------------------------------------*/
    public List<SelectOption> getOpportunityStageValues() {
        Schema.DescribeFieldResult f = Opportunity.StageName.getDescribe();
        List<SelectOption> options = new List<SelectOption>();

        if (pipelineOptionsJson == null) {
            options = prepareSelectOptionsFromDescribeFieldResult(f);
            return options;
        }
        
        List<String> pipelineOptions = (List<String>) JSON.deserialize(pipelineOptionsJson, List<String>.class);
        if (pipelineOptions.isEmpty()) {
            options = prepareSelectOptionsFromDescribeFieldResult(f);
            return options;
        }

        for(OpportunityStage stage : [SELECT Id, MasterLabel, IsClosed, DefaultProbability 
                                        FROM OpportunityStage WHERE IsActive = true ORDER BY SortOrder]) {
            for(String option : pipelineOptions){
                if(option == ALL_OPEN_OPPS && stage.IsClosed == false 
                || option == ALL_OPPS_MORE_THAN_50 && stage.DefaultProbability > 50
                || option == ALL_CLOSED_OPPS && stage.IsClosed == true){
                    options.add(new SelectOption(stage.MasterLabel, stage.MasterLabel));
                }
            }
        }
        return options;
    }
    
    /**
    * @description Prepares select options of deal team member roles
    * @return List<SelectOption> 
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 15/09/2016  Dino Scarcella	 New method
    *------------------------------------------------------------*/
    public List<SelectOption> getteamRoleValues() {
        Schema.DescribeFieldResult f = OpportunityTeamMember.TeamMemberRole.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
    * @description Prepares select options of account regions for frontend.
    * @return List<SelectOption> 
    */
    public List<SelectOption> getAccountClientCountryValues() {
        Schema.DescribeFieldResult f = Account.Client_Country__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
    * @description Prepares select options of account regions for frontend.
    * @return List<SelectOption> 
    */
    public List<SelectOption> getAccountClientRegionValues() {
        Schema.DescribeFieldResult f = Account.Client_Region__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
    * @description Prepares select options of account segments for frontend.
    * @return List<SelectOption> 
    */
    public List<SelectOption> getAccountSegmentValues() {
        Schema.DescribeFieldResult f = Account.Segment__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    // Tonga MM : Prepare select option for opportunity country values
     public List<SelectOption> getOpportunityCountryValues() {
        Schema.DescribeFieldResult f = Opportunity.Opportunity_Country__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    // Tonga MM : Prepare select option for team names
     public List<SelectOption> getUserTeamNameValues() {
        Schema.DescribeFieldResult f = User.Team__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    //Tonga MM : Prepare select option for opp substage
    public List<SelectOption> getOpportunitySubStageValues() {
        Schema.DescribeFieldResult f = Opportunity.SubStage__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    //Tonga MM : Prepare select option for approval status
	public List<SelectOption> getOpportunityApprovalStatusValues() {
        Schema.DescribeFieldResult f = Opportunity.ProductPartnerApprovalStatus__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
	
    public List<SelectOption> getTBRegionValues() {
        Schema.DescribeFieldResult f = Account.Transactional_Banking_Region__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    // Tonga MM : Prepare select option for listview
    public List<SelectOption> getListView()
    {
        List<SelectOption> options = new List<SelectOption>();       
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('MyView','MyView'));
        
        return options;
    }
    
    /**
    * @description Prepares opportunity count, uses WHERE part if used for data 
    * preparation (if any data filter is used).
    */
    @testVisible
    private void prepareOptyCount() {
        String query = prepareQuery(false, false, false);
        String[] split = query.split('FROM Opportunity ');
        String actualQuery = COUNT_QUERY;
        
        //query contains WHERE part
        if (split.size() > 1) {
            actualQuery = COUNT_QUERY + ' ' + split[1];
        }
        
        AggregateResult[] aggResult = Database.query(actualQuery);
        
        optyCount = (Integer) aggResult[0].get('oppCount');
        
        Double conversionRate = [SELECT conversionrate FROM currencytype WHERE isocode = 
                :currencyIsoCode LIMIT 1].conversionRate;
        
        if (optyCount == 0 || conversionRate == null) {
            facilitySize = 0;
            incomeThisYear = 0;
            annualisedIncome = 0;
            weightedIncomeThisYear = 0;
            weightedAnnualisedIncome = 0;
            
        } else {
            facilitySize = (Decimal) aggResult[0].get('totalFacilitySize');
            incomeThisYear = (Decimal) aggResult[0].get('totalIncomeThisYear');
            annualisedIncome = (Decimal) aggResult[0].get('totalAnnualisedIncome');
            weightedIncomeThisYear = (Decimal) aggResult[0].get('totalWeightedIncomeThisY');
            weightedAnnualisedIncome = (Decimal) aggResult[0].get('totalWeightedAnnIncome');
            
            facilitySize *= conversionRate;
            incomeThisYear *= conversionRate;
            annualisedIncome *= conversionRate;
            weightedIncomeThisYear *= conversionRate;
            weightedAnnualisedIncome *= conversionRate;
        }
    }
    
    /**
    * @description Prepares json of coverage teams for typeahead.
    */
    @testVisible
    private void prepareCoverageTeamJson() {
        Schema.DescribeFieldResult f = User.Team__c.getDescribe();
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<String> options = new List<String>();
        for (Schema.PicklistEntry e: p) {
            options.add(e.getLabel());
        }
        coverageTeamJson = JSON.serializePretty(options);
    }
    
    /**
    * @description Prepares json of bankers for typeahead.
    */
    @testVisible
    private void prepareBankersJson() {
        JSONGenerator generator = JSON.createGenerator(false);
        generator.writeStartArray();
        for (User user: [SELECT Id, Name FROM User WHERE Profile.UserLicense.Name = 'Salesforce' ORDER BY Name]) {
            generator.writeStartObject();
            generator.writeStringField(JSON_NAME, user.Name);
            generator.writeStringField(JSON_ID, user.Id);
            generator.writeEndObject();
        }
        generator.writeEndArray();
        bankersJson = generator.getAsString();
    }
    
    /**
    * @description Controller's main method for query preparation
    * @return String - prepared query
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 24/02/2016  Marta Malinowska   Add conditions for Pipeline Segmentation filter.
    *------------------------------------------------------------*/
    @testVisible
    private String prepareQuery(Boolean isPageRequest, Boolean useOrdering, Boolean isExcel) {
    
        //SELECT part of query
        String query = 'SELECT Id, Account.Id, Account.Transactional_Banking_Region__c,Name, Account.Name, Account_Name__c, Account_Name__r.Name, RecordType.Name, Account.Client_Country__c, ' + 
            'Account.Client_Region__c,SubStage__c,ProductPartnerApprovalStatus__c,ProductPartner__r.Name, Account.Segment__c, Account.Industry, Account.Team_F__c, Account.Owner.Name, ' +
            'Owner.Name, StageName, convertCurrency(Total_Balance_Facility_Size__c), convertCurrency(Income_this_Year__c), ' +
            'convertCurrency(Annualised_Income__c), Probability, convertCurrency(Weighted_Income_this_Year__c), ' +
            'convertCurrency(Weighted_Annualised_Income__c), CloseDate, CreatedDate, Push_Counter__c, ' +
            'Days_Since_Last_Stage_Change__c,Opportunity_Country__c, First_Drawdown__c, (SELECT PricebookEntry.Product2.Name, Product_Level_2__r.Name, ' +
            'Product_Level_3__r.Name, LoanType__c, RefinanceIncreaseDecrease__c, convertCurrency(Hold_Size__c), Gross_Margin__c, Ftp__c, Margin__c, Arranging_Fee__c, Other_Fees__c, ' + 
            'Committment_Fee__c, Annual_Facility_Fee__c, DG_TTC__c, LGD__c, convertCurrency(RWA__c), Underwrite__c FROM OpportunityLineItems), ' +
            '(SELECT Name, TeamMemberRole,User.Team__c FROM OpportunityTeamMembers ORDER BY TeamMemberRole) ' +
            'FROM Opportunity WHERE';
        
        if(!String.isBlank(chosenView))
        {
            if(chosenView.equalsIgnoreCase('MyView'))
            {
                List<STring> ids = new List<String>();
                ids.add(UserInfo.getUserId());                
                query += ' Id IN ' + getSubqueryByOpportunityShareID(ids)[0];
                query = query.Replace('(SELECT UserORGroupID FROM OpportunityShare)', getSubqueryByOpportunityShareID(ids)[1]);                
            }            
        }
        
        //conditions of query - filters
        Boolean orgIdAdded = false;
        if (orgIdJson != null && orgTypeJson != null) {
            List<String> ids = (List<String>) JSON.deserialize(orgIdJson, List<String>.class);
            List<Id> orgTypeIds = new List<Id>();
            List<String> orgTypes = (List<String>) JSON.deserialize(orgTypeJson, List<String>.class);
            for(String orgType : orgTypes){
                if(relationshipTypesMap.containsKey(orgType)){
                    orgTypeIds.addAll(relationshipTypesMap.get(orgType));
                }
            }
            
            if (ids.size() > 0 && orgTypeIds.size() > 0) {
                orgIdAdded = true;
                query = prepareSubquery(query, ' Account.Id = \'', ids);
            }
        }
        if (!orgIdAdded && orgTypeJson != null) {
            List<Id> orgTypeIds = new List<Id>();
            List<String> orgTypes = (List<String>) JSON.deserialize(orgTypeJson, List<String>.class);
            for(String orgType : orgTypes){
                if(relationshipTypesMap.containsKey(orgType)){
                    orgTypeIds.addAll(relationshipTypesMap.get(orgType));
                }
            }

            if (orgTypeIds.size() > 0) {
                query = prepareSubquery(query, ' Account.RecordTypeId = \'', orgTypeIds);
            }
        }
        
        Boolean productLevel3Added = false;
        if (productLevel3OptionsJson != null && productLevel2OptionsJson != null && productLevel1OptionsJson != null) {
            List<String> productsLvl3 = (List<String>) JSON.deserialize(productLevel3OptionsJson, List<String>.class);
            List<String> productsLvl2 = (List<String>) JSON.deserialize(productLevel2OptionsJson, List<String>.class);
            List<String> productsLvl1 = (List<String>) JSON.deserialize(productLevel1OptionsJson, List<String>.class);
            
            if (productsLvl3.size() > 0 && productsLvl2.size() > 0 && productsLvl1.size() > 0) {
                productLevel3Added = true;
                query = addAnd(query);
                query += ' Id IN ' + getSubqueryByProductLevel3(productsLvl3);
            }
        }
        
        Boolean productLevel2Added = false;
        if (!productLevel3Added && productLevel2OptionsJson != null && productLevel1OptionsJson != null) {
            List<String> productsLvl2 = (List<String>) JSON.deserialize(productLevel2OptionsJson, List<String>.class);
            List<String> productsLvl1 = (List<String>) JSON.deserialize(productLevel1OptionsJson, List<String>.class);
            
            if (productsLvl2.size() > 0 && productsLvl1.size() > 0) {
                productLevel2Added = true;
                query = addAnd(query);
                query += ' Id IN ' + getSubqueryByProductLevel2(productsLvl2);
            }
        } 
        if (!productLevel3Added && !productLevel2Added && productLevel1OptionsJson != null) {
            List<String> productsLvl1 = (List<String>) JSON.deserialize(productLevel1OptionsJson, List<String>.class);
            
            if (productsLvl1.size() > 0) {
                query = addAnd(query);
                query += ' Id IN ' + getSubqueryByProductLevel1(productsLvl1);
            }
        }
        
        if (userTeamOptionsJson != null) {
            List<String> teams = (List<String>) JSON.deserialize(userTeamOptionsJson, List<String>.class);
            
            if (teams.size() > 0) {
                query = addAnd(query);
                getSubqueryByCoverageTeam(teams);
                query += ' AccountId IN :accounts';
            }
        }
        
        if (bankerIdsJson != null) {
            List<String> ids = (List<String>) JSON.deserialize(bankerIdsJson, List<String>.class);
            
            if (ids.size() > 0) {
                query = prepareSubquery(query, ' Account.OwnerId = \'', ids);
            }
        }
        
        if (teamRoleOptionsJson != null) {
            List<String> roles = (List<String>) JSON.deserialize(teamRoleOptionsJson, List<String>.class);
            
            if (roles.size() > 0) {
                query = addAnd(query);
                query += ' Id IN ' + getSubqueryByRole(roles)[0];
                query = query.Replace('(SELECT Name, TeamMemberRole FROM OpportunityTeamMembers)', getSubqueryByRole(roles)[1]);
            }
        }
        
        if (oppOwnerIdsJson != null) {
            List<String> ids = (List<String>) JSON.deserialize(oppOwnerIdsJson, List<String>.class);
            
            if (ids.size() > 0) {
                query = prepareSubquery(query, ' OwnerId = \'', ids);
            }
        }
        
        if (optyStageOptionsJson != null) {
            List<String> stages = (List<String>) JSON.deserialize(optyStageOptionsJson, List<String>.class);
            
            if (stages.size() > 0) {
                query = prepareSubquery(query, ' StageName = \'', stages);
            }
        }
        
        if (opportunityCountryJson != null) {
            List<String> countries = (List<String>) JSON.deserialize(opportunityCountryJson, List<String>.class);
            if (countries.size() > 0) {
                query = prepareSubquery(query, ' Opportunity_Country__c = \'', countries);
            }
            
        }
        if (optySubStageOptionsJson != null) {
            List<String> subStages = (List<String>) JSON.deserialize(optySubStageOptionsJson, List<String>.class);
            if (subStages.size() > 0) {
                query = prepareSubquery(query, ' SubStage__c = \'', subStages);
            }
            
        }
        
        if (optyApprovalStatusOptionJson != null) {
            List<String> approvalStatus = (List<String>) JSON.deserialize(optyApprovalStatusOptionJson, List<String>.class);
            if (approvalStatus.size() > 0) {
                query = prepareSubquery(query, ' ProductPartnerApprovalStatus__c = \'', approvalStatus);
            }
            
        }
            
        if (TBRegionOptionJson != null) {
            List<String> TBRegion = (List<String>) JSON.deserialize(TBRegionOptionJson, List<String>.class);
            if (TBRegion.size() > 0) {
                query = prepareSubquery(query, ' Account.Transactional_Banking_Region__c = \'', TBRegion);
            }            
        }
        
         if (teamNameOptionsJson != null) {
            List<String> teamName = (List<String>) JSON.deserialize(teamNameOptionsJson, List<String>.class);
            
            if (teamName.size() > 0) {
                query = addAnd(query);
                query += ' Id IN ' + getSubqueryByTeamName(teamName)[0];
                query = query.Replace('(SELECT Name, TeamMemberRole FROM OpportunityTeamMembers)', getSubqueryByTeamName(teamName)[1]);
            }
        }
        
        if (teamMemberIdsJson != null) {
            List<String> teamMemberIDs = (List<String>) JSON.deserialize(teamMemberIdsJson, List<String>.class);
            
            if (teamMemberIDs.size() > 0) {
                query = addAnd(query);
                query += ' Id IN ' + getSubqueryByTeamMemberID(teamMemberIDs)[0];
                query = query.Replace('(SELECT Name, TeamMemberRole FROM OpportunityTeamMembers)', getSubqueryByTeamMemberID(teamMemberIDs)[1]);
            }
        }
        if (productPartnerIdsJson != null) {
            List<String> ids = (List<String>) JSON.deserialize(productPartnerIdsJson, List<String>.class);
            
            if (ids.size() > 0) {
                query = prepareSubquery(query, ' ProductPartner__c = \'', ids);
            }
        }
        
        if (accountClientCountryOptionsJson != null) {
            List<String> countries = (List<String>) JSON.deserialize(accountClientCountryOptionsJson, List<String>.class);
            
            if (countries.size() > 0) {
                query = prepareSubquery(query, ' Account.Client_Country__c = \'', countries);
            }
        }
        
        if (accountClientRegionOptionsJson != null) {
            List<String> regions = (List<String>) JSON.deserialize(accountClientRegionOptionsJson, List<String>.class);
            
            if (regions.size() > 0) {
                query = prepareSubquery(query, ' Account.Client_Region__c = \'', regions);
            }
        }
        
        if (accountSegmentOptionsJson != null) {
            List<String> segments = (List<String>) JSON.deserialize(accountSegmentOptionsJson, List<String>.class);
         
            if (segments.size() > 0) {
                query = prepareSubquery(query, ' Account.Segment__c = \'', segments);
            }
        }
        
        if (closeDateString != null && closeDateString != '') {
            Date closeDate = prepareDateFromString(closeDateString);
            query = addAnd(query);
            startDate = closeDate.toStartOfMonth();
            endDate = closeDate.toStartOfMonth().addMonths(1).addDays(-1);
            query += ' CloseDate <= :endDate';
        }

        if (pipelineOptionsJson != null) {
            List<String> pipelineSegments = (List<String>) JSON.deserialize(pipelineOptionsJson, List<String>.class);
            
            if (pipelineSegments.size() > 0) {
                String subquery = '';
                for(String pipeline : pipelineSegments){
                    if(pipeline == ALL_OPEN_OPPS){
                        subquery += String.isBlank(subquery) ? ' (' : ' OR';
                        subquery += ' IsClosed = false';
                    } else if(pipeline == ALL_OPPS_MORE_THAN_50){
                        subquery += String.isBlank(subquery) ? ' (' : ' OR';
                        subquery += ' Probability > 50';
                    } else if(pipeline == ALL_CLOSED_OPPS){
                        subquery += String.isBlank(subquery) ? ' (' : ' OR';
                        subquery += ' IsClosed = true';
                    }
                }
                if(String.isNotBlank(subquery)){
                    query = addAnd(query);
                    query += subquery + ')';
                }
                System.debug('QUERY: '+query);
            }
        }
        
        //if no condition added WHERE should be removed
        if (query.endsWith('WHERE')) {
            Integer lengthWithoutWhere = query.length() - 6;
            query = query.left(lengthWithoutWhere);
        }
        
        //sorting
        if (useOrdering && sortColumn != null && sortColumn != '' && sortOrder != null && sortOrder != '') {
            query += ' ORDER BY ' + sortColumn + ' ' + sortOrder + ' NULLS LAST';
        }
        
        //limit of number of opportunities returned
        //adds offset because of pagination
        if (isPageRequest) {
            query += ' LIMIT ' + QUERY_LIMIT;
            query += ' OFFSET ' + queryOffset;
        } else if (isExcel) {
            query += ' LIMIT ' + EXCEL_QUERY_LIMIT;
        }
        
         System.debug('QUERY: '+query);
        return query;
    }
    
    /**
    * @description Adds subquery to query in param.
    * @param String query - query to add subquery to
    * @param String field - field to subquery on
    * @param List<String> values - values of field
    * @return String - modified query
    */
    private String prepareSubquery(String query, String field, List<String> values) {
        query = addAnd(query);
        query += ' (';
        for (Integer i = 0; i < values.size(); i++) {
            query += field + values[i] + '\'';
            if (i != values.size() - 1) {
                query += ' OR';
            }
        }
        query += ')';
        return query;
    }
    
    /**
    * @description Query default currency iso code of running user and sets it to an instance variable.
    */
    @testVisible
    private void prepareCurrencyIsoCode() {
        List<User> users = [SELECT DefaultCurrencyIsoCode FROM User WHERE Id = :UserInfo.getUserId()];
        currencyIsoCode = users[0].DefaultCurrencyIsoCode;
    }

    /**
    * @Author:          Marta Malinowska
    * @Company:         Deloitte
    * @Description:     Prepare map to store Relationship Record Type Ids grouped by relationship type (Prospect/Existing).
    * @Params           None
    * @Returns:         None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    @testVisible
    private void prepareRelationshipTypesMap(){
        relationshipTypesMap = new Map<String, List<String>>{
            TYPE_PROSPECT => new List<Id>(),
            TYPE_EXISTING => new List<Id>()
        };
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE IsActive=:true AND 
                SobjectType = 'Account' ORDER BY Name asc]){
            if(rt.Name.startsWithIgnoreCase(PROSPECT)){
                relationshipTypesMap.get(TYPE_PROSPECT).add(rt.Id);
            } else{
                relationshipTypesMap.get(TYPE_EXISTING).add(rt.Id);
            }
        }
    }
    
    /**
    * @description Creates Date from string like '2015-10'. Day is always set to 1.
    * @param String closeDateString - source string 
    * @return Date
    */
    @testVisible
    private Date prepareDateFromString(String closeDateString) {
        String[] split = closeDateString.split('-', 0);
        return Date.newInstance(Integer.valueOf(split[0]), Integer.valueOf(split[1]), 1);
    }
    
    /**
    * @description Adds AND to query if needed.
    * @return String - modified query
    */
    @testVisible
    private String addAnd(String query) {
        if (!query.endsWith('WHERE')) {
            query += ' AND';
        }
        return query;
    }
    
    /**
    * @description Creates List of opportunity ids by product level 1. 
    * @return List<String> productsLvl1
    */
    @testVisible
    private String getSubqueryByProductLevel1(List<String> productsLvl1) {
        String query = '(SELECT OpportunityId From OpportunityLineItem WHERE';
        for (Integer i = 0; i < productsLvl1.size(); i++) {
            query += ' Product2Id = \'' + productsLvl1[i] + '\'';
            if (i != productsLvl1.size() - 1) {
                query += ' OR';
            }
        }
        query += ')';
        return query;
    }
    
    /**
    * @description Creates List of opportunity ids by product level 2. 
    * @return List<String> productsLvl2
    */
    @testVisible 
    private String getSubqueryByProductLevel2(List<String> productsLvl2) {
        String query = '(SELECT OpportunityId From OpportunityLineItem WHERE';
        for (Integer i = 0; i < productsLvl2.size(); i++) {
            query += ' Product_Level_2__c = \'' + productsLvl2[i] + '\'';
            if (i != productsLvl2.size() - 1) {
                query += ' OR';
            }
        }
        query += ')';
        return query;
    }
    
    /**
    * @description Creates List of opportunity ids by product level 3. 
    * @return List<String> productsLvl3
    */
    @testVisible 
    private String getSubqueryByProductLevel3(List<String> productsLvl3) {
        String query = '(SELECT OpportunityId From OpportunityLineItem WHERE';
        for (Integer i = 0; i < productsLvl3.size(); i++) {
            query += ' Product_Level_3__c = \'' + productsLvl3[i] + '\'';
            if (i != productsLvl3.size() - 1) {
                query += ' OR';
            }
        }
        query += ')';
        return query;
    }
    
    /**
    * @description Creates List of opportunity ids by opportunity deal team member and creates query to return relevant deal team members based on role 
    * @return List<String> roles
    */
    @testVisible 
    private List<String> getSubqueryByRole(List<String> roles) {
    	String query = '(SELECT OpportunityId From OpportunityTeamMember WHERE TeamMemberRole IN (';
        String dealteammembers = '(SELECT Name, TeamMemberRole FROM OpportunityTeamMembers WHERE TeamMemberRole IN (';
        for (Integer i = 0; i < roles.size(); i++) {
            query += '\'' + roles[i] + '\'';
            dealteammembers += '\'' + roles[i] + '\''; 
            if (i != roles.size() - 1) {
            	query += ',';
            	dealteammembers += ',';
            }
        }
        query += '))';
        dealteammembers += '))';
        return new List<String> { query, dealteammembers };
    }
    
    /**
    * @description Creates List of account ids by selected coverage team. 
    * @param List<String> userTeamOptions
    */
    @testVisible 
    private void getSubqueryByCoverageTeam(List<String> userTeamOptions) {
        String query = 'SELECT Id FROM Account WHERE OwnerId IN (SELECT Id FROM User WHERE';
        for (Integer i = 0; i < userTeamOptions.size(); i++) {
            query += ' Team__c = \'' + userTeamOptions[i] +'\'';
            if (i != userTeamOptions.size() - 1) {
                query += ' OR';
            }
        }
        query += ')';
        accounts = Database.query(query);
    }
    
    /**
    * @description Creates select options from picklist values.
    * @return List<SelectOption>
    */
    private List<SelectOption> prepareSelectOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            options.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        return options;
    }
    
    @testVisible 
    private List<String> getSubqueryByTeamMemberID(List<String> UserIDs) {
    	String query = '(SELECT OpportunityId From OpportunityTeamMember WHERE UserID IN (';
        String dealteammembers = '(SELECT Name, TeamMemberRole FROM OpportunityTeamMembers WHERE UserID IN (';
        for (Integer i = 0; i < UserIDs.size(); i++) {
            query += '\'' + UserIDs[i] + '\'';
            dealteammembers += '\'' + UserIDs[i] + '\''; 
            if (i != UserIDs.size() - 1) {
            	query += ',';
            	dealteammembers += ',';
            }
        }
        query += '))';
        dealteammembers += '))';
        return new List<String> { query, dealteammembers };
    }
    
    @testVisible 
    private List<String> getSubqueryByTeamName(List<String> teamNames) {
    	String query = '(SELECT OpportunityId From OpportunityTeamMember WHERE User.Team__c IN (';
        String dealteamNames = '(SELECT Name, TeamMemberRole FROM OpportunityTeamMembers WHERE User.Team__c IN (';
        for (Integer i = 0; i < teamNames.size(); i++) {
            query += '\'' + teamNames[i] + '\'';
            dealteamNames += '\'' + teamNames[i] + '\''; 
            if (i != teamNames.size() - 1) {
            	query += ',';
            	dealteamNames += ',';
            }
        }
        query += '))';
        dealteamNames += '))';
        return new List<String> { query, dealteamNames };
    }
	
@testVisible 
    private List<String> getSubqueryByOpportunityShareID(List<String> UserIDs) {
    	String query = '(SELECT OpportunityId From OpportunityShare WHERE (UserOrGroupID  IN (';
        String dealteammembers = '(SELECT UserOrGroupID FROM OpportunityShare WHERE (UserOrGroupID IN (';
        for (Integer i = 0; i < UserIDs.size(); i++) {
            query += '\'' + UserIDs[i] + '\'';
            dealteammembers += '\'' + UserIDs[i] + '\''; 
            if (i != UserIDs.size() - 1) {
            	query += ',';
            	dealteammembers += ',';
            }
        }
        query += ') OR Opportunity.OwnerID = \''+UserIDs[0] + '\') AND RowCause IN(\'Team\',\'Owner\'))';
        dealteammembers += ') OR Opportunity.OwnerID = \''+UserIDs[0] + '\') AND RowCause IN(\'Team\',\'Owner\'))';
        return new List<String> { query, dealteammembers };
    }    
}