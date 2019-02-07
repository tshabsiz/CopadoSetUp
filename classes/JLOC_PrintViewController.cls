public with sharing class JLOC_PrintViewController {
    public JLOC__c jloc { get; set; }
    public Opportunity jlocOpportunity { get; set; }    
    public Account jlocRelationship { get; set; }
    public Client_Plan__c jlocClientPlan { get;set; }

    public List<Financial_Information__c> jlocFinanceList { get; set; }
    public Financial_Information__c jlocFinancials { get; set; }

	public String jlocNewFinancingLimits { get; set; }
    public String jlocFinancialsCalcDebDivtEbitda { get; set; }
    public List<OpportunityLineItem> jlocProposedProducts { get; set; }
    public List<Budget_Revenue__c> jlocExistingProducts { get; set; }
    public Budget_Revenue__c jlocExistingProductsTotals { get; set; }
    public List<Country_Presence__c> jlocPresences { get; set; }
    public List<OpportunityTeamMember> jlocDealTeam { get; set; }
    public List<Client_Plan_Security__c> jlocSecurities { get;set; }
    public List<Opportunity> jlocOpenOpportunitiesExcluded { get;set; }
    public List<Opportunity> jlocOpenOpportunitiesIncluded { get;set; }
    public List<Potential_Opportunity__c> jlocPotentialOpportunities { get;set; }
    public Client_Plan_Revenue_By_Product__c jlocRevByProduct { get; set; }
    public List<String> jlocBorrowers { get; set; }
    public List<String> jlocGuarantors { get; set; }
    public Boolean NonSADeals { get; set; }
    
    public  ClientFinancialsController clientPlanFinancialsController{get;set;}

    private static final String ABSA = 'ABSA';
    private static final String OTHER = 'OTHER';
    private final static String PDF_CONTENT_TYPE = 'application/pdf';

    public JLOC_PrintViewController(ApexPages.StandardController stdController) {
        if(!test.isRunningTest()) {
            stdController.addFields(new List<String>{
                'Name',
                'Organisation__c',
                'Pricing_and_Returns_Document_ID__c',
                 'Organisation__r.RecordTypeID',
                    'Stress_Case_ID__c',
                    'Management_Case_ID__c',
                    'Banker_Case_ID__c',
                    'Forecast_Description__c',
                    'Forecast_Not_Available__c',
                    'JLOC_Status__c'
            });
        }
        String status = '';
        jloc = (JLOC__c) stdController.getRecord();
		
        if(!String.isblank(Apexpages.currentPage().getParameters().get('status')))
           {
               status = Apexpages.currentPage().getParameters().get('status');
               jloc.JLOC_Status__c = status;
           }

        
        //Init Lists
        jlocFinanceList = new List<Financial_Information__c>();
        jlocProposedProducts = new List<OpportunityLineItem>();
        jlocExistingProducts = new List<Budget_Revenue__c>();
        jlocPresences = new List<Country_Presence__c>();
        jlocDealTeam = new List<OpportunityTeamMember>();
        jlocSecurities = new List<Client_Plan_Security__c>();
        jlocOpenOpportunitiesExcluded = new List<Opportunity>();
        jlocOpenOpportunitiesIncluded = new List<Opportunity>();
        jlocBorrowers = new List<String>();
        jlocGuarantors = new List<String>();

        if(jloc.Id != null) {
            /* Get Opportunity & Relationship/Account */
            jlocOpportunity = getJLOCOpportunity(jloc.Id);

            jlocRelationship = [
                SELECT  Id, Name, Client_Country__c, CurrencyIsoCode, External_Credit_Rating__c
                FROM    Account 
                WHERE   Id = :jloc.Organisation__c
            ];

            /* Get the open Opportunities for this Relationship (not on this JLOC) */
           
                jlocOpenOpportunitiesExcluded = [
                SELECT      Id, Name, CloseDate, Probability, StageName, Annualised_Income__c, Total_Balance_Facility_Size__c, (SELECT Product_Name__c FROM OpportunityLineItems)
                FROM        Opportunity
                WHERE       (AccountId = :jlocRelationship.Id OR Related_Group_Client__c = :jlocRelationship.Id OR Account_Name__c = :jlocRelationship.Id)
                AND 		JLOC__c != :jloc.Id
                AND 		isClosed = FALSE
                ORDER BY    CloseDate ASC
            ];
          
            
            
            
            /* Get the open Opportunities for this Relationship (for this JLOC) */
            jlocOpenOpportunitiesIncluded = [
                SELECT      Id, Name,Related_Group_Client__r.Name, StageName, CloseDate, Opportunity_Country__c
                FROM        Opportunity
                WHERE       (AccountId = :jlocRelationship.Id OR Account_Name__c = :jlocRelationship.Id
                            OR Related_Group_Client__c = :jlocRelationship.Id)
                AND 		JLOC__c = :jloc.Id
                AND 		isClosed = FALSE
                ORDER BY    CloseDate ASC
            ];
            
            NonSADeals = JLOC_Utility.NonSADeals(jlocOpenOpportunitiesIncluded);
            
            /* Get the Borrowers and Guarantors for this Relationship */
            List<Client_Plan_Borrowers_Guarantors__c> borrowersAndGuarantors = [
                SELECT      CreatedById, CreatedDate, CurrencyIsoCode, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name, Relationship__c, SystemModstamp, Type__c, Value__c 
                FROM        Client_Plan_Borrowers_Guarantors__c
                WHERE       Relationship__c = :jlocRelationship.Id
                ORDER BY    Type__c, Value__c
            ];
            jlocBorrowers = new List<String>();
            jlocGuarantors = new List<String>();
            for(Client_Plan_Borrowers_Guarantors__c bgItem : borrowersAndGuarantors) {
                if(bgItem.Type__c == 'Borrower') {
                    jlocBorrowers.add(bgItem.Value__c);
                }
                else if(bgItem.Type__c == 'Guarantor') {
                    jlocGuarantors.add(bgItem.Value__c);
                }
            }

            /* Get the Client Plan for this Relationship if it exists */
            List<Client_Plan__c> tmpClientPlans = [
                SELECT      Id, Name, Client_Overview__c,Relationship__c, Financial_Information_Image_ID__c, Org_Structure_Image_ID__c, Sector_Overview__c, TFL__c, RoRWA_Existing__c, DG__c, LGD__c, convertCurrency(TFL__c) ConvertedTFL__c, Financial_Year_End__c, FinancialCommentary__c
                FROM        Client_Plan__c
                WHERE       Relationship__c = :jloc.Organisation__c
                ORDER BY    CreatedDate DESC
                LIMIT       5
            ];
            if(!tmpClientPlans.isEmpty()) {
                jlocClientPlan = tmpClientPlans[0];
                ApexPages.currentPage().getParameters().put('planId',jlocClientPlan.ID);
                clientPlanFinancialsController = new ClientFinancialsController();
                clientPlanFinancialsController.queryACMFacilities();
            } else {
                jlocClientPlan = null;
            }

            /* Get the Potential Opportunities for the latest Client Plan */
            if (jlocClientPlan != null)
            jlocPotentialOpportunities = [
            	SELECT    Id, Name, Close_Date__c, Product__c, Stage__c, Probability__c, Type__c, Product_Level_1__c, Product_Level_1__r.Name, Product_Level_2__c, Product_Level_2__r.Name, Product_Level_3__c, Product_Level_3__r.Name
                    FROM      Potential_Opportunity__c
                    WHERE     Client_Plan__c = :jlocClientPlan.Id AND Opportunity__c = null AND IsConverted__c = false
                    ORDER BY  Close_Date__c
                ];

            /* Get the latest FinancialInformation record for this Account - ordered by Year & CreatedDate */
            if(jlocClientPlan!=null)
            jlocFinanceList = ClientFinancialsController.queryFinancialInformation(jlocClientPlan, 0, 5);

            /* Make calculations based on the latest (newest) finance record */
            jlocFinancials = null;
            jlocFinancialsCalcDebDivtEbitda = null;
            if(!jlocFinanceList.isEmpty()) {
                   
                jlocFinancials = jlocFinanceList.get(0);
                                                                        
                    
               if(jlocFinancials.Net_Debt__c != null && jlocFinancials.EBITDA__c != null && jlocFinancials.EBITDA__c != 0 && jlocFinancials.Financial_Results__c != '') {

                   if(jlocFinancials.Financial_Results__c.equals('Audited Full Year')){
                       //Divide Net_Debt__c by EBITDA__c - precision of 2 decimals behind the comma
                       try {
                           Decimal debDivtEbitda = jlocFinancials.Net_Debt__c;
                           debDivtEbitda = debDivtEbitda.divide(jlocFinancials.EBITDA__c, 2);
                           
                           jlocFinancialsCalcDebDivtEbitda = debDivtEbitda.toPlainString();
                       } catch(Exception e) {
                           System.debug(e);
                       }
                   }
                   else if(jlocFinancials.Financial_Results__c.equals('Interim Results')){
                       
                       try {
                           Decimal debDivtEbitda = jlocFinancials.Net_Debt__c;
                           Decimal annualisedEbitda = (jlocFinancials.EBITDA__c/6)* 12; 
                           
                           debDivtEbitda = debDivtEbitda.divide(annualisedEbitda, 2);
                           jlocFinancialsCalcDebDivtEbitda = debDivtEbitda.toPlainString(); 
                       } catch(Exception e) {
                           System.debug(e);
                       }
                   }else{
                       
                       try {
                           Integer period = Integer.valueOf(jlocFinancials.Period_Of_Months__c);
                           Decimal debDivtEbitda = jlocFinancials.Net_Debt__c;
                           Decimal annualisedEbitda = (jlocFinancials.EBITDA__c/period)* 12; 
                           
                           debDivtEbitda = debDivtEbitda.divide(annualisedEbitda, 2);
                           jlocFinancialsCalcDebDivtEbitda = debDivtEbitda.toPlainString();      
                       } catch(Exception e) {
                           System.debug(e);
                       }
                   }   
                }
            } else {
                //Create empty Financial_Information__c record to show the Relationship Financials Table but without values
                jlocFinancials = new Financial_Information__c();
            }
            
            /* Calculate the New Financing Limit based on the users currency */ 
            jlocNewFinancingLimits = CalculateNewFinancingLimit();

            /* Get the proposed products from the Related Opportunity */
            jlocProposedProducts = JLOC_Utility.getProposedProducts(jloc.Id);

            /* Get the DealTeam from the Related Opportunity */
            jlocDealTeam = [
                SELECT      Id, Opportunity.Name, User.Name, TeamMemberRole 
                FROM        OpportunityTeamMember 
                WHERE       Opportunity.Id = :jlocOpportunity.Id
                ORDER BY    Opportunity.Name, User.LastName
            ];

            //Enforce the dealteam to have an even number of members (layout) by adding an empty last member if odd
            if(math.mod(jlocDealTeam.size(),2) == 1) {
                jlocDealTeam.add(new OpportunityTeamMember());
            }

            /* Do we have a valid pricing and returns document? */
            if(String.isNotBlank(jloc.Pricing_and_Returns_Document_ID__c)) {
                Attachment pricingAndReturnsAttach = new Attachment();
                try {
                    pricingAndReturnsAttach = [SELECT Id, Name, ContentType FROM Attachment WHERE Id = :jloc.Pricing_and_Returns_Document_ID__c];
                } catch(QueryException ex) {}
                if(pricingAndReturnsAttach.ContentType != 'image/jpeg' && pricingAndReturnsAttach.ContentType != 'image/png') {
                    jloc.Pricing_and_Returns_Document_ID__c = null;
                }
            }

            /* Do we have a valid ancillary calculation document? */
            if(String.isNotBlank(jloc.Ancillary_Calculation_Document_ID__c)) {
                Attachment ancillaryCalculationAttach = new Attachment();
                try {
                    ancillaryCalculationAttach = [SELECT Id, Name, ContentType FROM Attachment WHERE Id = :jloc.Ancillary_Calculation_Document_ID__c];
                } catch(QueryException ex) {}
                if(ancillaryCalculationAttach.ContentType != 'image/jpeg' && ancillaryCalculationAttach.ContentType != 'image/png') {
                    jloc.Ancillary_Calculation_Document_ID__c = null;
                }
            }

            /* Get the existing data from the Client Plan if we have one */
            if(jlocClientPlan != null) {
                jlocExistingProducts = JLOC_Utility.getExistingProduct(jlocClientPlan.Id);
                
                jlocExistingProductsTotals = BudgetRevenueTotals(jlocClientPlan.ID);

                jlocPresences = [
                    SELECT      Banking_Country__c, Client_Plan__c, CreatedById, CreatedDate, CurrencyIsoCode, Engaged__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name, Primary_Bank__c, SystemModstamp 
                    FROM        Country_Presence__c
                    WHERE       Client_Plan__c = :jlocClientPlan.Id
                    ORDER BY    Banking_Country__c ASC
                ];

                jlocSecurities = [
                    SELECT      Id, Security_Description__c, Value__c
                    FROM        Client_Plan_Security__c
                    WHERE       Relationship__c = :jlocRelationship.Id
                    ORDER BY    CreatedDate ASC
                ];

                //Add padding to security description to ensure wrapping
                for(Client_Plan_Security__c jlocSecurity : jlocSecurities) {
                    jlocSecurity.Security_Description__c = jlocSecurity.Security_Description__c != NULL ? jlocSecurity.Security_Description__c.replaceAll('.{80}', '$0 ') : '';
                }
				
                List<Client_Plan_Revenue_By_Product__c> revByProdList =JLOC_Utility.getRevenueByProduct(jlocClientPlan.Id);

                jlocRevByProduct = null;
                if(!revByProdList.isEmpty()) {
                    jlocRevByProduct = revByProdList.get(0);
                }
            }
        }
    }
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     prepares totals of products table
		* @Returns:         Budget_Revenue__c
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public static Budget_Revenue__c BudgetRevenueTotals(ID cpID) {
		AggregateResult ar = [
			SELECT 	SUM(Limit__c) totalLimit, SUM(Utilisation__c) totalUtilisation 
			FROM 	Budget_Revenue__c
			WHERE 	Client_Plan__c = :cpID
		];

		Budget_Revenue__c totals = new Budget_Revenue__c();
		totals.Limit__c = (Decimal) ar.get('totalLimit');
		totals.Utilisation__c = (Decimal) ar.get('totalUtilisation');

		//Force the currencyCode on the Total record to be the Org Default. Limitation from using SUM in SOQL
		CurrencyType defaultOrgCurrency = [SELECT Id, IsoCode, IsCorporate FROM CurrencyType WHERE IsCorporate = true].get(0);
		totals.CurrencyIsoCode = defaultOrgCurrency.IsoCode;
		return totals;
	}
	
	/**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Calculates the New Financing Limit (calculates in users default currency in case client plan and jloc are different currencies)
		* @Returns:         String
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private String CalculateNewFinancingLimit() {
		Decimal NewFinancingLimits = 0;
		JLOC__c jloc_convert = [SELECT convertCurrency(Total_Fin_Limits_Proposed__c) ConvertedTotal_Fin_Limits_Proposed__c FROM JLOC__c WHERE Id = :jloc.id];
		if (jlocClientPlan != null && jlocClientPlan.get('ConvertedTFL__c')!=null) NewFinancingLimits = (Decimal)jlocClientPlan.get('ConvertedTFL__c');
		if (jloc_convert != null && jloc_convert.get('ConvertedTotal_Fin_Limits_Proposed__c') != null) NewFinancingLimits = NewFinancingLimits + (Decimal)jloc_convert.get('ConvertedTotal_Fin_Limits_Proposed__c'); 
		List<String> formatargs = new String[]{'0','number','###,###,##0.00'}; 
		return UserInfo.getDefaultCurrency() + ' ' + String.format(NewFinancingLimits.format(), formatargs);
	}
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     returns the first opportunity associated to the JLOC
		* @param        	Jloc Id
		* @Returns:         Opportunity
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
    public static Opportunity getJLOCOpportunity(Id JlocId) {
        List<Opportunity> jlocOpportunities = [
                SELECT  Id, Name, Opportunity_Country__c 
                FROM    Opportunity 
                WHERE   JLOC__c = :JlocId
                LIMIT   1
        ];
        if (!jlocOpportunities.isEmpty()) return jlocOpportunities[0]; else return null;
    }
}