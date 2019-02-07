/**
* @Author       Dino Scarcella
* Company:      Absa Capital
* @Description: Controller for RPF Calculator on Add Product to Opportunity Page
* @Date:        11/2017
* @TestClass:   ZZTEST_RPFCalculator
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class RPFCalculator {
    private String oliId;
    public OpportunityLineItem oli {get;set;} // Hold the Product for this calculation
    public Boolean renderErrorMessage {get;set;} // Whether to show error messages or not
    public Integer NumMonthsThisYear {get;set;} // Holds number of months from Start Date to end of this year
    public Decimal ArrangingFeeUpfrontAmount {get;set;} // Holds the portion of the Arranging Fee thats Upfront
    public Decimal ArrangingFeeDeferredAmount {get;set;} // Holds the portion of the Arranging Fee thats Deferred
    public List<RPF> RPFFinancials {get;set;} // Holds the financials for all the months
    public Map<String, RPFCalculation__c> RPFCalculations {get;set;} // Holds all the stored values in this calculation
    public String MonthChange {get;set;} // Holds the Month of the calculated Balance Sheet Utilisation Assumption we want to change
    public Decimal AmountChange {get;set;} // Holds the Amount of the calculated Balance Sheet Utilisation Assumption we want to change
    
    //Totals for reporting purposes
    public Decimal CalculatedNetMarginCurrentYear {get;set;}
    public Decimal CalculatedNetMarginNextYear {get;set;}
    public Decimal CalculatedCommittmentCurrentYear {get;set;}
    public Decimal CalculatedCommittmentNextYear {get;set;}
    public Decimal CalculatedDeferredCurrentYear {get;set;}
    public Decimal CalculatedDeferredNextYear {get;set;}
    public Decimal CalculatedUpfrontCurrentYear {get;set;}
    public Decimal CalculatedUpfrontNextYear {get;set;}
    public Decimal CalculatedTotalPipelineCurrentYear {get;set;}
    public Decimal CalculatedTotalPipelineNextYear {get;set;}
    
    public RPFCalculator() {
        oliId = ApexPages.currentPage().getParameters().get('oliId');
        
        if(String.isBlank(oliId)) {
            renderErrorMessage = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'No Product Associated to Calculation.'));
            return;
        }
        
        //Select existing Opportunity Line Item fields
        oli = [
        	SELECT  DrawPercentageCurrentYear__c, DrawPercentageNextYear__c, StartDate__c, Hold_Size__c, Margin__c, Committment_Fee__c, Arranging_Fee__c, Arranging_Fee_Deferred__c, Opportunity.Probability, Terms_Years__c, OpportunityId
            FROM    OpportunityLineItem
            WHERE   Id = :oliId
        ];

        if (oli == null || 
            oli.DrawPercentageCurrentYear__c == null || 
            oli.DrawPercentageNextYear__c == null || 
            oli.StartDate__c == null || 
            oli.Hold_Size__c == null || 
            oli.Margin__c == null || 
            oli.Committment_Fee__c == null || 
            oli.Arranging_Fee__c == null ||
            oli.Arranging_Fee_Deferred__c == null || 
            oli.Opportunity.Probability == null || 
            oli.Terms_Years__c == null) {
                renderErrorMessage = true;
                if (oli == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Relevant information required for calculation not available.'));
                if (oli.DrawPercentageCurrentYear__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Draw percentage for Current Year required for calculation.'));
                if (oli.DrawPercentageNextYear__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Draw percentage for Next Year required for calculation.'));
                if (oli.StartDate__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Start Date required for calculation.'));
                if (oli.Hold_Size__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Hold Size required for calculation.'));
                if (oli.Margin__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Net Margin required for calculation.'));
                if (oli.Committment_Fee__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Commitment Fee Percentage required for calculation.'));
                if (oli.Arranging_Fee__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Arranging Fee Percentage required for calculation.'));
                if (oli.Arranging_Fee_Deferred__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Arranging Fee Deferred required for calculation.'));
                if (oli.Opportunity.Probability == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Opportunity Probability required for calculation.'));
                if (oli.Terms_Years__c == null) ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Term Years required for calculation.'));
                return;
        }
        
        NumMonthsThisYear = 12 - oli.StartDate__c.month() + 1; // eg. if its in March it's 10 months including March
        
        // Performs all the calculations required for the RPF Pipeline Calculator
        CalculateFigures();
    }
    
    private void CalculateFigures() {
    	List<RPF> RPFs = new List<RPF>();
        for(Integer i = 0; i < NumMonthsThisYear; i++) {
 			RPF thismonth = new RPF();
            thismonth.Month = DateTime.newInstance(2017, oli.StartDate__c.month(), 15).addmonths(i).format('MMM') + ' ' + oli.StartDate__c.year();
            RPFs.add(thismonth);
        }
        
        for(Integer i = 0; i < 12; i++) {
 			RPF thismonth = new RPF();
            thismonth.Month = DateTime.newInstance(2018, i + 1, 15).format('MMM') + ' ' + (oli.StartDate__c.year() + 1);
            RPFs.add(thismonth);
        }
        
        for(RPF thismonth : RPFs) {
        	thismonth.GrossBalanceSheetCommitment = oli.Hold_Size__c;
            if (thismonth.Month.contains(String.valueOf(oli.StartDate__c.year())))
            	thisMonth.BalanceSheetUtilisationAssumption = oli.DrawPercentageCurrentYear__c / 100 * thismonth.GrossBalanceSheetCommitment / NumMonthsThisYear;
        }
        
        // Load Saved Balance Sheet Arranging Fees and Balance Sheet Utilisation Assumptions for 1st Year
		RPFs = LoadStoredCalculations(RPFs, oli.StartDate__c.year());
        
        for(RPF thismonth : RPFs) {
            if (thismonth.Month.contains(String.valueOf(oli.StartDate__c.year()+1)))
                thisMonth.BalanceSheetUtilisationAssumption = oli.Hold_Size__c * oli.DrawPercentageNextYear__c / 100 / 12;
        } 
        
        // Load Saved Balance Sheet Arranging Fees and Balance Sheet Utilisation Assumptions for 2nd Year
		RPFs = LoadStoredCalculations(RPFs, oli.StartDate__c.year()+1);
        
        for(Integer i = 0; i < RPFs.size(); i++) {
 			if (i == 0) RPFs[i].BalanceSheetUtilisationAssumptionCD = RPFs[i].BalanceSheetUtilisationAssumption;
            else RPFs[i].BalanceSheetUtilisationAssumptionCD = RPFs[i-1].BalanceSheetUtilisationAssumptionCD + RPFs[i].BalanceSheetUtilisationAssumption;
            RPFs[i].UndrawnBalanceSheet = RPFs[i].GrossBalanceSheetCommitment - RPFs[i].BalanceSheetUtilisationAssumptionCD;
            RPFs[i].Margin = RPFs[i].BalanceSheetUtilisationAssumptionCD * oli.Margin__c / 100 / 12;
            RPFs[i].CommitmentFee = RPFs[i].UndrawnBalanceSheet * oli.Committment_Fee__c / 100 / 12;
            RPFs[i].ArrangingDeferredFee = ArrangingFeeDeferredAmount / (oli.Terms_Years__c * 12);
            if (i == 0) RPFs[i].ArrangingUpfrontFee = ArrangingFeeUpfrontAmount;
            else RPFs[i].ArrangingUpfrontFee = 0;
            
            RPFs[i].TotalPipelineValue = RPFs[i].Margin + RPFs[i].CommitmentFee + RPFs[i].ArrangingDeferredFee + RPFs[i].ArrangingUpfrontFee;
            RPFs[i].WeightedTotalPipelineValue = (RPFs[i].Margin + RPFs[i].CommitmentFee + RPFs[i].ArrangingDeferredFee + RPFs[i].ArrangingUpfrontFee) * oli.Opportunity.Probability / 100;
        }
        
        RPFFinancials = RPFs;
    }
    
    public List<String> RPFRows {
        get{
            return new List<String>{'Net Margin', 'Committment Fees', 'Deferred Fees', 'Upfront Fees', 'Total Pipeline Value', 'Weighted Pipeline Value'};
        }
    }
    
    //Utilisation Assumption Rows
    public List<String> UARows {
        get{
            return new List<String>{'Utilisation Assumptions'};
        }
    }
    
    public PageReference reCalculate() {
        CalculateFigures();
        UpdateProductTotals();
        UpdateDrawdowns();
        return null;
    }
    
    public PageReference changeUA() {
        List<RPFCalculation__c> RPFCs = [SELECT Id FROM RPFCalculation__c 
                                         WHERE Opportunity__c =: oli.OpportunityId 
                                         AND OpportunityLineItemId__c =: String.ValueOf(oli.Id)
                                         AND Month__c =: MonthChange
                                        ];
        if (RPFCs.size() > 0) DELETE RPFCs;
        
        RPFCalculation__c RPFC = new RPFCalculation__c(Name = MonthChange + String.ValueOf(oli.Id), 
                                                       Month__c = MonthChange,
                                                       Amount__c = AmountChange, 
                                                       Opportunity__c = oli.OpportunityId, 
                                                       OpportunityLineItemId__c = String.ValueOf(oli.Id));
        INSERT RPFC;
        
        CalculateFigures();
        UpdateProductTotals();
        UpdateDrawdowns();
        return null;
    }
    
    public PageReference changeArrangingFee() {
    	List<RPFCalculation__c> RPFCs = [SELECT Id FROM RPFCalculation__c 
                                         WHERE Opportunity__c =: oli.OpportunityId 
                                         AND OpportunityLineItemId__c =: String.ValueOf(oli.Id)
                                         AND Month__c IN ('ArrangingFeeUpfrontAmount','ArrangingFeeDeferredAmount')
                                        ];
        if (RPFCs.size() > 0) DELETE RPFCs;
            
        List<RPFCalculation__c> RPFCsToInsert = new List<RPFCalculation__c>();
        RPFCsToInsert.add(new RPFCalculation__c(
            										Name = 'ArrangingFeeUpfrontAmount' + String.ValueOf(oli.Id), 
                                                    Month__c = 'ArrangingFeeUpfrontAmount',
                                                    Amount__c = ArrangingFeeUpfrontAmount, 
                                                    Opportunity__c = oli.OpportunityId, 
                                                    OpportunityLineItemId__c = String.ValueOf(oli.Id))
                         						);
        RPFCsToInsert.add(new RPFCalculation__c(
            										Name = 'ArrangingFeeDeferredAmount' + String.ValueOf(oli.Id), 
                                                    Month__c = 'ArrangingFeeDeferredAmount',
                                                    Amount__c = ArrangingFeeDeferredAmount, 
                                                    Opportunity__c = oli.OpportunityId, 
                                                    OpportunityLineItemId__c = String.ValueOf(oli.Id))
                          						);
        INSERT RPFCsToInsert;
        
        CalculateFigures();
        UpdateProductTotals();
        UpdateDrawdowns();
        return null;
    }
    
    // Loads all the stored Arranging Fees and Balance Sheet Utilisation Assumptions into the array
    private List<RPF> LoadStoredCalculations(List<RPF> RPFs, Integer UAYear) {
        RPFCalculations = new Map<String, RPFCalculation__c>();
        
        List<RPFCalculation__c> RPFCs = [SELECT Amount__c, Month__c FROM RPFCalculation__c 
                                         WHERE Opportunity__c =: oli.OpportunityId 
                                         AND OpportunityLineItemId__c =: String.ValueOf(oli.Id)];
        
        for(RPFCalculation__c RPFC : RPFCs) {
        	RPFCalculations.put(RPFC.Month__c, RPFC);
        }
        
        for(RPF thismonth : RPFs) {
      		if (RPFCalculations.containsKey(thismonth.Month) && thismonth.Month.contains(String.valueOf(UAYear))) thismonth.BalanceSheetUtilisationAssumption = RPFCalculations.get(thismonth.Month).Amount__c;
        }
        
        // if we haven't changed deferred and upfront fee
        if (!RPFCalculations.containsKey('ArrangingFeeUpfrontAmount') && !RPFCalculations.containsKey('ArrangingFeeDeferredAmount')) {
            // Gets what portion is deferred and what portion is upfront based on flag on Product Page
        	if (oli.Arranging_Fee_Deferred__c == true) {
            	ArrangingFeeDeferredAmount = Math.Round(oli.Hold_Size__c * oli.Arranging_Fee__c / 100); 
                ArrangingFeeUpfrontAmount = 0;
        	} else {
	            ArrangingFeeUpfrontAmount = Math.Round(oli.Hold_Size__c * oli.Arranging_Fee__c / 100);
                ArrangingFeeDeferredAmount = 0;
	        }
        }
        // if we have changed deferred and upfront fee
        if (RPFCalculations.containsKey('ArrangingFeeUpfrontAmount')) ArrangingFeeUpfrontAmount = RPFCalculations.get('ArrangingFeeUpfrontAmount').Amount__c;
        if (RPFCalculations.containsKey('ArrangingFeeDeferredAmount')) ArrangingFeeDeferredAmount = RPFCalculations.get('ArrangingFeeDeferredAmount').Amount__c;
        
        return RPFs;
    }
    
    public void UpdateProductTotals() {
        CalculatedNetMarginCurrentYear = 0;
        CalculatedNetMarginNextYear = 0;
        CalculatedCommittmentCurrentYear = 0;
        CalculatedCommittmentNextYear = 0;
        CalculatedDeferredCurrentYear = 0;
        CalculatedDeferredNextYear = 0;
        CalculatedUpfrontCurrentYear = 0;
        CalculatedUpfrontNextYear = 0;
        CalculatedTotalPipelineCurrentYear = 0;
        CalculatedTotalPipelineNextYear = 0;
        
        if (RPFFinancials != NULL) {
        	for(RPF thismonth : RPFFinancials) {
                if (thismonth.Month.contains(String.valueOf(oli.StartDate__c.year()))) {
                    CalculatedNetMarginCurrentYear += thismonth.Margin;
                    CalculatedCommittmentCurrentYear += thismonth.CommitmentFee;
                    CalculatedDeferredCurrentYear += thismonth.ArrangingDeferredFee;
                    CalculatedUpfrontCurrentYear += thismonth.ArrangingUpfrontFee;
                    CalculatedTotalPipelineCurrentYear += thismonth.TotalPipelineValue;
                } else if (thismonth.Month.contains(String.valueOf(oli.StartDate__c.year()+1))) {
                    CalculatedNetMarginNextYear += thismonth.Margin;
                    CalculatedCommittmentNextYear += thismonth.CommitmentFee;
                    CalculatedDeferredNextYear += thismonth.ArrangingDeferredFee;
                    CalculatedUpfrontNextYear += thismonth.ArrangingUpfrontFee;
                    CalculatedTotalPipelineNextYear += thismonth.TotalPipelineValue;
                }
        	}
        
            OpportunityLineItem oliToUpdate = new OpportunityLineItem(
                Id = oliId,
                CalculatedNetMarginCurrentYear__c = CalculatedNetMarginCurrentYear,
                CalculatedCommittmentCurrentYear__c = CalculatedCommittmentCurrentYear,
                CalculatedDeferredCurrentYear__c = CalculatedDeferredCurrentYear,
                CalculatedUpfrontCurrentYear__c = CalculatedUpfrontCurrentYear,
                CalculatedTotalPipelineCurrentYear__c = CalculatedTotalPipelineCurrentYear,
                CalculatedNetMarginNextYear__c = CalculatedNetMarginNextYear,
                CalculatedCommittmentNextYear__c = CalculatedCommittmentNextYear,
                CalculatedDeferredNextYear__c = CalculatedDeferredNextYear,
                CalculatedUpfrontNextYear__c = CalculatedUpfrontNextYear,
                CalculatedTotalPipelineNextYear__c = CalculatedTotalPipelineNextYear
            );
    
            try {
                update oliToUpdate;
            } catch (Exception e) {
                System.debug('Exception storing calculation values on product:' + e.getMessage());
            }
        }
    }
    
    private void UpdateDrawdowns() {
        List<Drawdowns__c> drawDownsInsert = new List<Drawdowns__c>();
        Map<String,Integer> MapMonthList = new Map<String,Integer>{'Jan' => 1,'Feb' => 2,'Mar' => 3,'Apr' => 4,'May' => 5,'Jun' => 6,'Jul' => 7,'Aug' => 8,'Sep' => 9,'Oct' => 10,'Nov' => 11,'Dec' => 12};
        
        if (RPFFinancials != NULL) {
            for(RPF thismonth : RPFFinancials) {
                Date drawdownDate = Date.newInstance(Integer.valueOf(thismonth.Month.split(' ')[1]), MapMonthList.get(thismonth.Month.split(' ')[0]), 1).addMonths(1).toStartofMonth().addDays(-1);
                drawDownsInsert.add(new Drawdowns__c(
                    					Opportunity__c = oli.OpportunityId, 
                    					Drawdown_date__c = drawdownDate, 
                    					Drawdown_Amount__c = thismonth.BalanceSheetUtilisationAssumption,
                    					NetMargin__c = thismonth.Margin,
                    					CommitmentFees__c = thismonth.CommitmentFee,
                    					DeferredFees__c = thismonth.ArrangingDeferredFee,
                    					UpfrontFees__c = thismonth.ArrangingUpfrontFee
                					));
            }
            
            Savepoint sp = Database.setSavepoint();
            List<Drawdowns__c> drawDownsDelete = [SELECT Id FROM Drawdowns__c WHERE Opportunity__c =: oli.OpportunityId];
            try {
                DELETE drawDownsDelete;
                INSERT drawDownsInsert;
            } catch (Exception e) {
                Database.rollback(sp);
                System.debug('Exception updating drawdowns:' + e.getMessage());
            }
        }
    }
    
    public PageReference UpdateProductTotalsAndDrawdowns(){
    	UpdateProductTotals();
        UpdateDrawdowns();
        return null;
    }
    
    public class RPF {
        public String Month{get;set;} // Month and year for this data eg. December 2017 (unique identifier for the figures below)
        public Decimal GrossBalanceSheetCommitment{get;set;} // Gross Balance Sheet Commitment figure for this month
        public Decimal BalanceSheetUtilisationAssumption{get;set;} // Balance Sheet Utilisation Assumption figure for this month
        public Decimal BalanceSheetUtilisationAssumptionCD{get;set;} // Balance Sheet Utilisation Assumption(Cumulative Draw) figure for this month
        public Decimal UndrawnBalanceSheet{get;set;} // Undrawn Balance Sheet figure for this month GrossBalanceSheetCommitment - BalanceSheetUtilisationAssumptionCD (first month being current only)
        public Decimal Margin{get;set;} // Cumulative Draw * Net Margin / 12
        public Decimal CommitmentFee{get;set;} // UndrawnBalanceSheet * Commitment Fee percentage / 12
        public Decimal ArrangingDeferredFee{get;set;} // Deferred Arranging Fee percentage / Term Years from Product
        public Decimal ArrangingUpfrontFee{get;set;} // Upfront Arranging Fee percentage (Only stored in this object for the first year as its upfront)
        public Decimal TotalPipelineValue{get;set;} // Gets the total Net margin, Commitment Fees, Deferred Fees, Upfront Fees
        public Decimal WeightedTotalPipelineValue{get;set;} // Gets the total Net margin, Commitment Fees, Deferred Fees, Upfront Fees weighted by Opportunity Probability
    }
}