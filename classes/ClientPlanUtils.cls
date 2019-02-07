/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Utils class for Client Plan
* @Date:        3/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanUtils  
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------
* @Modified By : Mabhedle
* @Modification Description : Added generic methods that can be used by other classes in the client plan
* @Modification Date : 2017-06-28
*--------------------------------------------------------------------------------------------------------
*/
public virtual class ClientPlanUtils {
    
    //Tonga MM : Map declarations that will be used to get related records that belong to underlying client plans
    public Map<ID,List<Client_Plan__c>> accountToClientPlansMap{get;set;}
    public Map<ID,List<Potential_Opportunity__c>> clientPlanToPotentialOpportunities{set;get;}
    public Map<ID,List<Opportunity>> clientPlanToOpportunities{get;set;}
    public Map<ID,List<Budget_Revenue__c>> clientPlanToBudgetRevenues{get;set;}
    

    public string selectedClient{get;set;}
    public string selectedClientPlans{get;set;}
    
    public static MAP<ID,Account> accountList {get;set;}
    public MAP<ID,Account> accountListToPotentialOpps {get;set;}
    public MAP<ID,Account> accountListToOpps {get;set;}
    public MAP<ID,Account> accountListToBudgetRevenues {get;set;}
    
    public List<String> acmfsKeys {get;set;}
    public List<String> acmfsLabels {get;set;}
    public List<ACMFacility__c> acmfs {get;set;}
    public Map<String, List<ACMFacility__c>> acmfsMap {get;set;}
    Public Map<String,SubTotal> facilitySubTotalMap{get;set;}
    public decimal ACMFacilityUtilizationTotal{get;set;}
    public decimal ACMFacilityFacilityTotal{get;set;}
    public String userCurrency{get;set;}
   
    //Tonga MM : other facilities limits total using useer defualt currency
    public decimal totalOtherFacilities{get;set;}
    
	private static final String EDIT = 'edit';
    public boolean isGlobalParent{get;set;}

	/**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     creates sharing record for client plan
      * @Param:			  String planId, String userId
      * @Returns:         Client_Plan__Share
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
	public static Client_Plan__Share createSharingInstance(String planId, String userId) {

        Client_Plan__Share shRec = new Client_Plan__Share();
        shRec.AccessLevel = EDIT;
        shRec.RowCause = Schema.Client_Plan__Share.RowCause.Client_Plan_Manager__c;

        try {
        	shRec.ParentId = planId;
        	shRec.UserOrGroupId = userId;
       	} catch (StringException e) {
       		system.debug(e);
       		return null;
       	}
        
        return shRec;
    }
    private Client_Plan__c plan{get;set;}
    private String keyParameter{get;set;}
    public ClientPlanUtils(String planID,String keyParameter)
    {
        try
        {
            if (String.isEmpty(planId)) {
                planId = ApexPages.currentPage().getParameters().get('id');
                keyParameter = 'id';
            }
            plan = queryPlan(planID);
            
            this.keyParameter =keyParameter;
            if(plan!=null)
            {
                if(plan.relationship__r.Type.equalsIgnoreCase('Global Parent'))
                {
                    isGlobalParent = true;
                }
                getChildClients();
            }
        }
        catch(Exception exc)
        {
            System.debug('Error '+exc.getStackTraceString());
        }
       
       
    }
    

    
    
    //Tonga MM : Get child underlying client plans that belong to relationship groups that are linked to global parents
    public  List<SelectOption> getChildClientPlans()
    {
        String pageName = ApexPages.currentPage().getUrl().substringBetween('apex/', '?');
        List<SelectOption> sp = new List<SelectOption>();
        sp.add(new SelectOption('','~Select~'));
        for(String key : accountToClientPlansMap.keySet()){
            for(Client_Plan__c clP:  accountToClientPlansMap.get(key))
            {
                sp.add(new SelectOption('/apex/'+pageName+'?'+keyParameter+'='+clP.ID,clP.Name+' '+clP.relationship__r.Name));
            }
        }    
        return sp;
    }
    
    
    private void populatePipelineOpportnityMapList(Map<ID,Account> accountList)
    {
        accountListToOpps = new  MAP<ID,Account>();
        for(Account acc :accountList.values())
        {
            for(Opportunity opp :acc.Opportunities)
            {
                if(clientPlanToOpportunities.containsKey(acc.ID))
                {
                    clientPlanToOpportunities.get(acc.ID).add(opp);
                } 
                else
                {
                    accountListToOpps.put(acc.ID,accountList.get(acc.ID));
                    List<Opportunity> newList = new List<Opportunity>();
                    newList.add(opp);
                    clientPlanToOpportunities.put(acc.ID,newList);
                }
            }
            
        }
            
    }
   
    public static boolean loaded=false;
    //Tonga MM : get Underlying clients of for global parents/gets underlying clients opportunities and potential opportunities
    public void getChildClients()
    {
        List<SelectOption> RGClient = new List<SelectOption> ();	
        accountToClientPlansMap = new Map<ID,List<Client_Plan__c>>();
        clientPlanToOpportunities = new Map<ID,List<Opportunity>>();
        clientPlanToPotentialOpportunities =new Map<ID,List<Potential_Opportunity__c>>();
        accountListToPotentialOpps = new Map<id,Account>();
        
        
        if(!loaded){
            accountList = new Map<ID,Account>([Select ID,Name,(Select ID,Name,Account.Name,Total_Balance_Facility_Size__c,Owner.Name,CloseDate,Probability,Annualised_Income__c,StageName 
                                                           from Opportunities
                                                          	where StageName != 'CLosed Won' AND StageName != 'Closed Lost' 
															ORDER BY  Annualised_Income__c DESC) 
                                           from account 
                                           where ParentID =: plan.Relationship__c]);
            loaded = true;
        }
            
        
        
        
        if(accountList.size()>0){
            populatePipelineOpportnityMapList(accountList);
        }
               
        Map<ID,Client_Plan__c> clientPlans = new Map<ID,Client_Plan__c>([SELECT Id, Relationship__c, Relationship__r.Name,Name, Relationship__r.OwnerId, Relationship__r.Owner.Name,
                                              LastModifiedDate, Status__c, Client_Overview__c, DG__c, FAIS_Status__c, Financial_Year_End__c, 
                                              Latest_Audited_Financial_Statement__c, Sector_Overview__c, TFL__c, Expansion_Policy__c,
                                              Org_Structure_Items_Count__c, Country_Presence_Count__c, Budget_Revenues_Count__c, 
                                              Potential_Opportunities_Count__c, Relationships_Count__c, Strategies_Count__c, LGD__c, 
                                              Override_Pull_DG_From_SPEAR__c, DG_Last_Pulled_From_SPEAR__c, SDS__c, Relationship__r.Type,
                                                                         (SELECT    Id,Opportunity__r.Account.Name, Name, Close_Date__c, Product__c, Stage__c, Probability__c, Type__c, IsConverted__c, Product_Level_1__c, Product_Level_1__r.Name, Product_Level_2__c, Product_Level_2__r.Name, Product_Level_3__c, Product_Level_3__r.Name
                                                                          FROM      Unqualified_Opportunities__r
                                                                          WHERE     isConverted__c = false
                                                                          ORDER BY  Opportunity__c)
                                              FROM Client_Plan__c where Relationship__c IN:accountList.keySet()]);
        
        if(clientPlans.size()>0)        
        {
            prepareTotalsOfBudgetRevenues(clientPlans);
        }
        
        for(Client_Plan__c clientPlan : clientPlans.values())
        {
            if(clientPlanToPotentialOpportunities.containsKey(clientPlan.relationship__c))
            {
                accountListToPotentialOpps.put(clientPlan.Relationship__c,accountList.get(clientPlan.Relationship__c));
                clientPlanToPotentialOpportunities.get(clientPlan.Relationship__c).addAll(clientPlan.Unqualified_Opportunities__r);
            }
            else
            {
                List<Potential_Opportunity__c> popentialOpps = new List<Potential_Opportunity__c>();
                popentialOpps.addAll(clientPlan.Unqualified_Opportunities__r);
                if(popentialOpps.size()>0)
                {
                    accountListToPotentialOpps.put(clientPlan.Relationship__c,accountList.get(clientPlan.Relationship__c));
                    clientPlanToPotentialOpportunities.put(clientPlan.Relationship__c,popentialOpps);
                }
                clientPlanToPotentialOpportunities.put(clientPlan.Relationship__c,popentialOpps);
            }
            if(accountToClientPlansMap.containskey(clientPlan.Relationship__c))
            {
                accountToClientPlansMap.get(clientPlan.Relationship__c).add(clientPlan);
            }
            else
            {
                List<Client_Plan__c> clList = new List<Client_plan__c>();
                clList.add(clientPlan);
              	accountToClientPlansMap.put(clientPlan.Relationship__c,clList);
            }
        }	
       
    }
    public Client_Plan__c queryPlan(ID PlanID)
    {
        List<Client_Plan__c> plans;
        try {
            plans = [
                SELECT Id, Relationship__c, Relationship__r.Name,Relationship__r.recordTypeID, Relationship__r.OwnerId, Relationship__r.Owner.Name,
                    LastModifiedDate, Status__c, Client_Overview__c, DG__c, FAIS_Status__c, Financial_Year_End__c, 
                    Latest_Audited_Financial_Statement__c, Sector_Overview__c, TFL__c, Expansion_Policy__c,
                    Org_Structure_Items_Count__c, Country_Presence_Count__c, Budget_Revenues_Count__c, 
                    Potential_Opportunities_Count__c, Relationships_Count__c, Strategies_Count__c, LGD__c, 
                    Override_Pull_DG_From_SPEAR__c, DG_Last_Pulled_From_SPEAR__c, SDS__c, Relationship__r.Type
                FROM Client_Plan__c 
                WHERE Id = :planId];
        } catch (Exception e) {
            return null;
        }
        
        if (plans.isEmpty()) {
            return null;
        } else {
            return plans[0];
        }
    }
    private void prepareTotalsOfBudgetRevenues(Map<ID,Client_Plan__c> clientPlans) {
		AggregateResult [] ar = [
			SELECT 	Client_Plan__r.Relationship__c relationship,SUM(Limit__c) totalLimit, SUM(Utilisation__c) totalUtilisation 
			FROM 	Budget_Revenue__c
			WHERE 	Client_Plan__c IN: clientPlans.keySet()
            GROUP BY Client_Plan__r.Relationship__c
		];

       
        accountListToBudgetRevenues = new Map<ID,Account>();
        clientPlanToBudgetRevenues = new Map<ID,List<Budget_Revenue__c>>();
        queryBudgetRevenues(clientPlans);
        //Force the currencyCode on the Total record to be the Org Default. Limitation from using SUM in SOQL
		CurrencyType defaultOrgCurrency = [SELECT Id, IsoCode, IsCorporate FROM CurrencyType WHERE IsCorporate = true].get(0);
        for(AggregateResult currentResult: ar)
        {
            ID accountID = (ID)currentResult.get('relationship');
            
            Budget_Revenue__c totals = new Budget_Revenue__c();
            totals.Product__c = Label.lbl_Totals;
            totals.Country__c = ' ';
            totals.Maturity_Date__c = null;
            totals.LGD__c = null;
            totals.DG__c = null;
            totals.Limit__c = (Decimal) currentResult.get('totalLimit');
            totals.Utilisation__c = (Decimal) currentResult.get('totalUtilisation');
            totals.Margin__c = null;
            totals.FTP__c = null;
            totals.Arranging_Fee__c = null;
            totals.Commitment_Fee__c = null;
            totals.RoRWA__c = null;
            totals.CurrencyIsoCode = defaultOrgCurrency.IsoCode;
            
            if(clientPlanToBudgetRevenues.containsKey(accountID))
                {
                    clientPlanToBudgetRevenues.get(accountID).add(totals);
                } 
                else
                {
                    accountListToBudgetRevenues.put(accountID,accountList.get(accountID));
                    List<Budget_Revenue__c> newList = new List<Budget_Revenue__c>();
                    newList.add(totals);
                    clientPlanToBudgetRevenues.put(accountID,newList);
                }
        }
        //queryBudgetRevenues(clientPlans);
	}
    private void queryBudgetRevenues(Map<ID,Client_Plan__c> clientPlans) {
        for(Budget_Revenue__c br : [
                                    SELECT    Id, Product_Level_3__c,Client_Plan__r.Relationship__c, Product_Level_3__r.Name, Product__c, Country__c, Maturity_Date__c, LGD__c, DG__C, Limit__c, Utilisation__c, CurrencyIsoCode, Margin__c, FTP__c, Arranging_Fee__c, Commitment_Fee__c, RoRWA__c 
                                    FROM      Budget_Revenue__c
                                    WHERE     Client_Plan__c =: clientPlans.keySet()
                                    ORDER BY  Product__c
        ])
        {
            if(clientPlanToBudgetRevenues.containsKey(br.Client_Plan__r.Relationship__c))
                {
                    clientPlanToBudgetRevenues.get(br.Client_Plan__r.Relationship__c).add(br);
                } 
                else
                {
                    accountListToBudgetRevenues.put(br.Client_Plan__r.Relationship__c,accountList.get(br.Client_Plan__r.Relationship__c));
                    List<Budget_Revenue__c> newList = new List<Budget_Revenue__c>();
                    newList.add(br);
                    clientPlanToBudgetRevenues.put(br.Client_Plan__r.Relationship__c,newList);
                }
        }
	}
    public virtual void queryACMFacilities() {
		acmfs = [
			SELECT    Id, Name, CPTYID__c,Country__c,CurrencyIsoCode, CPTYLABEL__c,RoRWA__c,COM_FEES__c,Arrang_Fee__c,NET_MARGIN__c,FTP_bps__c,GROSS_MARGIN__c, FACILITYPRODUCTDESCRIPTION__c, EXPIRYDATE__c, FACILITYCURRENCY__c, FACILITYAMOUNT__c, LOSSGIVENDEFAULT__c, ACMUTILIZATIONCURRENCY__c, ACMUTILIZATIONAMOUNT__c, RETRIEVEDVIAACM__c
            FROM      ACMFacility__c
            WHERE     ClientPlan__c = :plan.ID
            AND FACILITYAMOUNT__c > 0
			ORDER BY  CPTYLABEL__c, FACILITYPRODUCTDESCRIPTION__c
		];
        
       // build map
        this.conversions = new Map<String,CurrencyType>();
        final List<CurrencyType> currencies = [select Id, IsCorporate, IsoCode, ConversionRate, DecimalPlaces from CurrencyType where IsActive=true];
        for (CurrencyType cur : currencies) {
            this.conversions.put(cur.IsoCode, cur);
            if (cur.IsCorporate) this.corporateIso = cur.IsoCode;
        }
        acmfsMap = new Map<String, List<ACMFacility__c>>();
        
        acmfsKeys = new List<String>();
        acmfsLabels = new List<String>();
        
        ACMFacilityUtilizationTotal=0;
        ACMFacilityFacilityTotal=0;
        userCurrency=UserInfo.getDefaultCurrency();
        
        //Tonga MM : Subtotal calculations and grouping VIA SDS Client
        facilitySubTotalMap = new Map<String,SubTotal>();
        
    	for (ACMFacility__c acmf : acmfs)
    	{
	        String key = (String)acmf.get('CPTYID__c');
            String label = (String)acmf.get('CPTYLABEL__c');
            
            String IsoCurrency = acmf.CurrencyIsoCode;
            if(!String.isBlank(acmf.FACILITYCURRENCY__c))
            {
                IsoCurrency = acmf.FACILITYCURRENCY__c;
            }
            
            SubTotal subT = new SubTotal();
            decimal convertedFacilityAmount = convert(acmf.FACILITYAMOUNT__c, IsoCurrency,userCurrency);
            decimal convertedUtilizationAmount = convert(acmf.ACMUTILIZATIONAMOUNT__c,IsoCurrency, userCurrency);
            if(convertedUtilizationAmount!=null)
            {
                ACMFacilityUtilizationTotal+=convertedUtilizationAmount;
                subT.convertedUtilizationAmountSubTotal += convertedUtilizationAmount;
            }
            	
            
            if(convertedFacilityAmount!=null)
            	ACMFacilityFacilityTotal+=convertedFacilityAmount;
            
            if(facilitySubTotalMap.containsKey(IsoCurrency))
            {
                subT = facilitySubTotalMap.get(IsoCurrency);
                
                if(acmf.ACMUTILIZATIONAMOUNT__c!=null)
                    subT.utilizationAmountSubTotal += acmf.ACMUTILIZATIONAMOUNT__c;
                
                if(acmf.FACILITYAMOUNT__c!=null)
                	subT.facilityAmountSubTotal+=acmf.FACILITYAMOUNT__c;
                
                subT.convertedFacilityAmountSubTotal += convertedFacilityAmount;
                subT.convertedUtilizationAmountSubTotal += convertedUtilizationAmount;
                facilitySubTotalMap.put(IsoCurrency, subT);
            }
            else
            {
                if(acmf.ACMUTILIZATIONAMOUNT__c!=null)
                	subT.utilizationAmountSubTotal = acmf.ACMUTILIZATIONAMOUNT__c;
                
                if(acmf.FACILITYAMOUNT__c!=null)
                subT.facilityAmountSubTotal = acmf.FACILITYAMOUNT__c;
                
                subT.convertedFacilityAmountSubTotal = convertedFacilityAmount;
                subT.convertedUtilizationAmountSubTotal = convertedUtilizationAmount;
                facilitySubTotalMap.put(IsoCurrency, subT);
            }
            
            if (!acmfsMap.containsKey(key)) {
            	acmfsMap.put(key, new List<ACMFacility__c> {acmf});
                acmfsKeys.add(key);
                acmfsLabels.add(label);
            } else 
             	acmfsMap.get(key).add(acmf);   
            
           
    	}
         System.debug(facilitySubTotalMap);
    }
    public class SubTotal
    {
        public decimal subTotal{get;set;}
        public decimal convertedSubTotal{get;set;}
        
        //Tonga MM : Wrapper fields for ACM Facility object
        public decimal facilityAmountSubTotal{get;set;}
        public decimal utilizationAmountSubTotal{get;set;}
        
        public decimal convertedFacilityAmountSubTotal {get;set;}
        public decimal convertedUtilizationAmountSubTotal{get;set;}
        public SubTotal()
        {
            convertedSubTotal=0;
            subTotal=0;
            facilityAmountSubTotal=0;
            utilizationAmountSubTotal=0;
            
            convertedFacilityAmountSubTotal=0;
            convertedUtilizationAmountSubTotal=0;
        }
    }
    
    public  Map<String,SubTotal> updateFacilitiesTotal(List<Client_Plan_Facility__c> otherFacility)
    {
        totalOtherFacilities=0;
        Map<String,SubTotal> currencyTotalsMap = new Map<String,SubTotal>();
        
        
        for(Client_Plan_Facility__c facility : otherFacility)
        {
            totalOtherFacilities+=(Decimal)facility.get('convertedCurrency');
            if(currencyTotalsMap.containsKey(facility.CurrencyIsoCode))
            {
                SubTotal sub = currencyTotalsMap.get(facility.CurrencyIsoCode);
                sub.subTotal+=facility.Limit__c;
                if(facility.get('convertedCurrency')!=null)
                    sub.convertedSubTotal+=(Decimal)facility.get('convertedCurrency');
                
                currencyTotalsMap.put(facility.CurrencyIsoCode,sub);
                
            }
            else
            {
                SubTotal sub = new SubTotal();
                sub.subTotal = facility.Limit__c;
                if(facility.get('convertedCurrency')!=null)
                	sub.convertedSubTotal+=(Decimal)facility.get('convertedCurrency');
                
                currencyTotalsMap.put(facility.CurrencyIsoCode, sub);
            }
        }
        return currencyTotalsMap;
    }
    
    private Map<String,CurrencyType> conversions{get;set;}
    private String corporateIso=null;
    
    //Tonga MM : Convert between two known currencies.
    public Decimal convert(Decimal value, String fromIso, String toIso) {
        if (String.isBlank(fromIso) || String.isBlank(toIso) ) {
            return value;
        }
      
        if(value==null)
        {
            value=0;
        }
        // if same currencies we simply round
        if (fromIso.equalsIgnoreCase(toIso)) {
            return value.setScale(this.conversions.get(fromIso.toUpperCase()).DecimalPlaces, System.RoundingMode.HALF_UP);
        }
        //Tonga MM : calculations
        final Decimal rate = ((CurrencyType)this.conversions.get(toIso.toUpperCase())).ConversionRate/((CurrencyType)this.conversions.get(fromIso.toUpperCase())).ConversionRate;
        final Decimal resultRounded = (value * rate).setScale(this.conversions.get(toIso.toUpperCase()).DecimalPlaces, System.RoundingMode.HALF_UP);
        
        // return
        return resultRounded;
    }
   
}