public class LibraRestfulModel {
    
    
    public class TradeInstrument
    {
        private string assetClass { get; set; }
        private string agreementType { get; set; }
        private string Id { get; set; }
        private string Name { get; set; }
        public TradeInstrument(Trade_Instrument__c standardTradeInstrument)
        {
            this.assetClass = standardTradeInstrument.Asset_Class__c;
            this.agreementType = standardTradeInstrument.Agreement_Type__c;
            this.Id = standardTradeInstrument.Id;
            this.Name = standardTradeInstrument.Name;
        }
    }
    
    
    public class SupportingAgreement
    {
        private boolean active{get;set;}
        private string agreement{get;set;}
        private string bankCollateralThresholdAmountEligibl{get;set;}
        private string bankCollateralThresholdAmountType{get;set;}
        private decimal bankCollateralThresholdFixedAmount{get;set;}
        private string bankIndCurrencyInitialMgCurrency{get;set;}
        private decimal bankIndependentAmountInitialMargin{get;set;}
        private string bankIndependentAmountType{get;set;}
        private decimal bankMinTransferFixedAmount{get;set;}
        private string bankMinimumTransferAmountType{get;set;}
        private string BaseCurrency{get;set;}
        private decimal BCTRB_F_A_M_A1_S_P_A{get;set;}
        private decimal BCTRB_F_A_M_A2_S_P_A{get;set;}
        private decimal BCTRB_F_A_M_A3_S_P_A{get;set;}
        private decimal BCTRB_F_AA_M_Aa1_S_P_AA{get;set;}
        private decimal BCTRB_F_AA_M_Aa2_S_P_AA{get;set;}
        private decimal BCTRB_F_AA_M_Aa3_S_P_AA{get;set;}
        private decimal BCTRB_F_AAA_M_Aaa_S_P_AAA{get;set;}
        private decimal BCTRB_F_BBB_M_Baa1_S_P_BBB{get;set;}
        private decimal BCTRB_F_BBB_M_Baa2_S_P_BBB{get;set;}
        private decimal BCTRB_F_BBB_M_Baa3_S_P_BBB{get;set;}
        private decimal BCTRB_F_Below_B_M_Below_Ba1_S_P_A{get;set;}
        private string callFrequency{get;set;}
        private decimal CCTRB_F_A_M_A1_S_P_A{get;set;}
        private decimal CCTRB_F_A_M_A2_S_P_A{get;set;}
        private decimal CCTRB_F_A_M_A3_S_P_A{get;set;}
        private decimal CCTRB_F_AA_M_Aa1_S_P_AA{get;set;}
        private decimal CCTRB_F_AA_M_Aa2_S_P_AA{get;set;}
        private decimal CCTRB_F_AA_M_Aa3_S_P_AA{get;set;}
        private decimal CCTRB_F_AAA_M_Aaa_S_P_AAA{get;set;}
        private decimal CCTRB_F_BBB_M_Baa1_S_P_BBB{get;set;}
        private decimal CCTRB_F_BBB_M_Baa2_S_P_BBB{get;set;}
        private decimal CCTRB_F_BBB_M_Baa3_S_P_BBB{get;set;}
        private decimal CCTRB_F_BelowB_M_BelowBa1_S_P_BelowB{get;set;}
        private string collateralType{get;set;}
        private string counterpartyCollateralTAmountType{get;set;}
        private decimal CounterpartyCollateralThresholdAmount{get;set;}
        private string counterpartyCollateralThresholdFixed{get;set;}
        private decimal counterpartyIndAmountInitialMargin{get;set;}
        private string counterpartyIndCurrInitialMgCurr{get;set;}
        private decimal counterpartyIndependentAmount{get;set;}
        private string counterpartyIndependentAmountType{get;set;}
        private string counterpartyMinTransferAmountType{get;set;}
        private decimal counterpartyMinTransferFixed_Amount{get;set;}
        private string CSAType{get;set;}
        private string currencyIsoCode{get;set;}
        private Date supportingAgreementDate{get;set;}
        private string distIntAmountEligibleCurrency{get;set;}
        private string distIntAmountIntRefRateType{get;set;}
        private string eligibleCurrency{get;set;}
        private string Id{get;set;}
        private string initialMarginCalculationMethod{get;set;}
        private string masterAgreementType{get;set;}
        private string name{get;set;}
        private string otherAgreement{get;set;}
        private string otherValuationAgent{get;set;}
        private string recordTypeId{get;set;}
        private string rehypothecation{get;set;}
        private string securityChargor{get;set;}
        private string securityObligationToAbsa{get;set;}
        private string securityObligationToCounterparty{get;set;}
        private string Security_Provider{get;set;}
        private decimal sOAbsaOwnAmount{get;set;}
        private decimal sOCounterpartyOwnAmount{get;set;}
        private string substitution{get;set;}
        private string supportingAgreementType{get;set;}
        private decimal terminationCurrency{get;set;}
        private string transactionExposureCalculationMethod{get;set;}
        private boolean tripartyAgent{get;set;}
        private string unclearedSwapsMarginIndicatorUCSM{get;set;}
        private decimal valuation{get;set;}
        private string valuationAgent{get;set;}
        private string valuationDate{get;set;}
        private string valuationTime{get;set;}
        private string weekdaythatConstitutesValuationDate{get;set;}
        public  SupportingAgreement(Supporting_Agreement__c standardSupportingAgreement)
        {
            this.active= standardSupportingAgreement.Active__c;
            this.agreement= standardSupportingAgreement.Agreement__c;
            this.bankCollateralThresholdAmountEligibl= standardSupportingAgreement.Bank_Collateral_Threshold_Amount_Eligibl__c;
            this.bankCollateralThresholdAmountType= standardSupportingAgreement.Bank_Collateral_Threshold_Amount_Type__c;
            this.bankCollateralThresholdFixedAmount= standardSupportingAgreement.Bank_Collateral_Threshold_Fixed_Amount__c;
            this.bankIndCurrencyInitialMgCurrency= standardSupportingAgreement.Bank_Ind_Currency_Initial_Mg_Currency__c;
            this.bankIndependentAmountInitialMargin= standardSupportingAgreement.Bank_Independent_Amount_Initial_Margin__c;
            this.bankIndependentAmountType= standardSupportingAgreement.Bank_Independent_Amount_Type__c;
            this.bankMinTransferFixedAmount= standardSupportingAgreement.Bank_Min_Transfer_Fixed_Amount__c;
            this.bankMinimumTransferAmountType= standardSupportingAgreement.Bank_Minimum_Transfer_Amount_Type__c;
                this.BaseCurrency= standardSupportingAgreement.Base_Currency__c;
            this.BCTRB_F_A_M_A1_S_P_A= standardSupportingAgreement.BCTRB_F_A_M_A1_S_P_A__c;
            this.BCTRB_F_A_M_A2_S_P_A= standardSupportingAgreement.BCTRB_F_A_M_A2_S_P_A__c;
            this.BCTRB_F_A_M_A3_S_P_A= standardSupportingAgreement.BCTRB_F_A_M_A3_S_P_A__c;
            this.BCTRB_F_AA_M_Aa1_S_P_AA= standardSupportingAgreement.BCTRB_F_AA_M_Aa1_S_P_AA__c;
            this.BCTRB_F_AA_M_Aa2_S_P_AA= standardSupportingAgreement.BCTRB_F_AA_M_Aa2_S_P_AA__c;
            this.BCTRB_F_AA_M_Aa3_S_P_AA= standardSupportingAgreement.BCTRB_F_AA_M_Aa3_S_P_AA__c;
            this.BCTRB_F_AAA_M_Aaa_S_P_AAA= standardSupportingAgreement.BCTRB_F_AAA_M_Aaa_S_P_AAA__c;
            this.BCTRB_F_BBB_M_Baa1_S_P_BBB= standardSupportingAgreement.BCTRB_F_BBB_M_Baa1_S_P_BBB__c;
            this.BCTRB_F_BBB_M_Baa2_S_P_BBB= standardSupportingAgreement.BCTRB_F_BBB_M_Baa2_S_P_BBB__c;
            this.BCTRB_F_BBB_M_Baa3_S_P_BBB= standardSupportingAgreement.BCTRB_F_BBB_M_Baa3_S_P_BBB__c;
            this.BCTRB_F_Below_B_M_Below_Ba1_S_P_A= standardSupportingAgreement.BCTRB_F_Below_B_M_Below_Ba1_S_P_A__c;
            this.callFrequency= standardSupportingAgreement.Call_Frequency__c;
            this.CCTRB_F_A_M_A1_S_P_A= standardSupportingAgreement.CCTRB_F_A_M_A1_S_P_A__c;
            this.CCTRB_F_A_M_A2_S_P_A= standardSupportingAgreement.CCTRB_F_A_M_A2_S_P_A__c;
            this.CCTRB_F_A_M_A3_S_P_A= standardSupportingAgreement.CCTRB_F_A_M_A3_S_P_A__c;
            this.CCTRB_F_AA_M_Aa1_S_P_AA= standardSupportingAgreement.CCTRB_F_AA_M_Aa1_S_P_AA__c;
            this.CCTRB_F_AA_M_Aa2_S_P_AA= standardSupportingAgreement.CCTRB_F_AA_M_Aa2_S_P_AA__c;
            this.CCTRB_F_AA_M_Aa3_S_P_AA= standardSupportingAgreement.CCTRB_F_AA_M_Aa3_S_P_AA__c;
            this.CCTRB_F_AAA_M_Aaa_S_P_AAA= standardSupportingAgreement.CCTRB_F_AAA_M_Aaa_S_P_AAA__c;
            this.CCTRB_F_BBB_M_Baa1_S_P_BBB= standardSupportingAgreement.CCTRB_F_BBB_M_Baa1_S_P_BBB__c;
            this.CCTRB_F_BBB_M_Baa2_S_P_BBB= standardSupportingAgreement.CCTRB_F_BBB_M_Baa2_S_P_BBB__c;
            this.CCTRB_F_BBB_M_Baa3_S_P_BBB= standardSupportingAgreement.CCTRB_F_BBB_M_Baa3_S_P_BBB__c;
            this.CCTRB_F_BelowB_M_BelowBa1_S_P_BelowB= standardSupportingAgreement.CCTRB_F_BelowB_M_BelowBa1_S_P_BelowB__c;
            this.collateralType= standardSupportingAgreement.Collateral_type__c;
            this.counterpartyCollateralTAmountType= standardSupportingAgreement.Counterparty_Collateral_T_Amount_Type__c;
            this.CounterpartyCollateralThresholdAmount= standardSupportingAgreement.Counterparty_Collateral_Threshold_Amount__c;
            this.counterpartyCollateralThresholdFixed= standardSupportingAgreement.Counterparty_Collateral_Threshold_Fixed__c;
            this.counterpartyIndAmountInitialMargin= standardSupportingAgreement.Counterparty_Ind_Amount_Initial_Margin__c;
            this.counterpartyIndCurrInitialMgCurr= standardSupportingAgreement.Counterparty_Ind_Curr_Initial_Mg_Curr__c;
            this.counterpartyIndependentAmount= standardSupportingAgreement.Counterparty_Independent_Amount__c;
            this.counterpartyIndependentAmountType= standardSupportingAgreement.Counterparty_Independent_Amount_Type__c;
            this.counterpartyMinTransferAmountType= standardSupportingAgreement.Counterparty_Min_Transfer_Amount_Type__c;
            this.counterpartyMinTransferFixed_Amount= standardSupportingAgreement.Counterparty_Min_Transfer_Fixed_Amount__c;
            this.CSAType= standardSupportingAgreement.CSA_Type__c;
            this.currencyIsoCode= standardSupportingAgreement.CurrencyIsoCode;
            this.supportingAgreementDate= standardSupportingAgreement.Date__c;
            this.distIntAmountEligibleCurrency= standardSupportingAgreement.Dist_Int_Amount_Eligible_Currency__c;
            this.distIntAmountIntRefRateType= standardSupportingAgreement.Dist_Int_Amount_Int_Ref_Rate__c;
            this.eligibleCurrency= standardSupportingAgreement.Eligible_Currency__c;
            this.Id= standardSupportingAgreement.id;
            this.initialMarginCalculationMethod= standardSupportingAgreement.Initial_Margin_Calculation_Method__c;
            this.masterAgreementType= standardSupportingAgreement.Master_Agreement_Type__c;
            this.name= standardSupportingAgreement.Name;
            this.otherAgreement= standardSupportingAgreement.Other_Agreement__c;
            this.otherValuationAgent= standardSupportingAgreement.other_Valuation_Agent__c;
            this.rehypothecation= standardSupportingAgreement.Rehypothecation__c;
            this.securityChargor= standardSupportingAgreement.Security_Chargor__c;
            this.securityObligationToAbsa= standardSupportingAgreement.Security_Obligation_to_Absa__c;
            this.securityObligationToCounterparty= standardSupportingAgreement.Security_Obligation_to_Counterparty__c;
            this.Security_Provider= standardSupportingAgreement.Security_Provider__c;
            this.sOAbsaOwnAmount= standardSupportingAgreement.SO_Absa_Own_Amount__c;
            this.sOCounterpartyOwnAmount= standardSupportingAgreement.SO_Counterparty_Own_Amount__c;
            this.substitution= standardSupportingAgreement.Substitution__c;
            this.supportingAgreementType= standardSupportingAgreement.Supporting_Agreement_Type__c;
            this.terminationCurrency= standardSupportingAgreement.Termination_Currency__c;
            this.transactionExposureCalculationMethod= standardSupportingAgreement.Transaction_Exposure_Calculation_Method__c;
            this.tripartyAgent= standardSupportingAgreement.Triparty_Agent__c;
            this.unclearedSwapsMarginIndicatorUCSM= standardSupportingAgreement.Uncleared_Swaps_Margin_Indicator_UCSM__c;
            this.valuation= standardSupportingAgreement.Valuation__c;
            this.valuationAgent= standardSupportingAgreement.Valuation_Agent__c;
            this.valuationDate= standardSupportingAgreement.Valuation_Date__c;
            this.valuationTime= standardSupportingAgreement.Valuation_Time__c;
            this.weekdaythatConstitutesValuationDate= standardSupportingAgreement.Weekday_that_Constitutes_Valuation_Date__c;
            
        }
    }
    
    
    public class Participant
    {
        private string advpmMatter { get; set; }
        private string advpmRole { get; set; }
        private string advpmContact{get;set;}
        private string advpmComment{get;set;}
        private string name { get; set; }
        private string recordTypeName { get; set; }
        private boolean primaryContactforRole { get; set; }
        private string Id { get; set; }
        private string contactNumber{get;set;}
        public Participant(advpm__Participant__c standardParticipant)
        {
            
            this.advpmMatter = standardParticipant.advpm__Matter__c;
            this.advpmRole = standardParticipant.advpm__Role__c;
            this.advpmContact = standardParticipant.advpm__Contact__c;
            this.advpmComment = standardParticipant.advpm__Comment__c;
            this.name = standardParticipant.Name;
            this.recordTypeName = standardParticipant.RecordType.Name;
            this.primaryContactforRole = standardParticipant.Primary_Contact_for_Role__c ;
            this.Id = standardParticipant.Id ;
            this.contactNumber = standardParticipant.Contact_Number__c;

        }
    }
    
    
    
    public class NettingGroup
    {
        private string Id { get; set; }
        private string name { get; set; }
        private string crossProduct { get; set; }
        private string matterDeal { get; set; }
        private string netAcrossBank { get; set; }
        private string netAcrossCounterparty { get; set; }
        private string nettingStrength { get; set; }
        private string nettingType { get; set; }
        private string crossCounterparty{get;set;}
        public NettingGroup(Netting_Group__c standardNettingGroup)
        {
            this.Id =  standardNettingGroup.Id;
            this.name = standardNettingGroup.Name;
            this.crossProduct = standardNettingGroup.Cross_Product__c;
            this.matterDeal = standardNettingGroup.Matter_Deal__c;
            this.netAcrossBank = standardNettingGroup.Net_Across_Bank__c;
            this.netAcrossCounterparty = standardNettingGroup.Net_Across_Counterparty__c;
            this.nettingStrength = standardNettingGroup.Netting_Strength__c;
            this.nettingType = standardNettingGroup.Netting_Type__c;
            this.crossCounterparty= standardNettingGroup.Cross_Counterparty__c;
            
    }
    }
    
   
    
    public class NettingGroupBranch
    {
        private string nettingGroup { get; set; }
        private String bankName { get; set; }
        private String bankSds { get; set; }
        private string counterPartyName { get; set; }
        private string counterPartySds { get; set; }
        private string tradeInstrument { get; set; }
        private string tradeInstrumentName { get; set; }
        
        public  NettingGroupBranch (NettingGroupBranch__c tradeInstrument,NettingGroupBranch__c counterParty,NettingGroupBranch__c bank)
        {
            this.nettingGroup = tradeInstrument.NettingGroup__c;
            this.bankName = bank.Relationship__r.Name;
            this.counterPartyName = counterParty.Relationship__r.Name;
            this.tradeInstrument = tradeInstrument.Trade_Instrument__c;
            if(tradeInstrument.Trade_Instrument__c!=null)
                this.tradeInstrumentName = tradeInstrument.Trade_Instrument__r.Name;
            
            if(counterParty.Relationship__c!=null)
                this.counterPartySds = counterParty.Relationship__r.Sds__c;
            
            if(bank.Relationship__c!=null)
                this.bankSds = bank.Relationship__r.Sds__c;
            
            
        }
    }
    
    public class Matter
    {
        private boolean active{get;set;}
        private string Id { get; set; }
        private string name { get; set; }
        private string relationshipName { get; set; }
        private string relationshipTypepicklist { get; set; }
        private string counterpartyType { get; set; }
        private string masterAgreementType { get; set; }
        private boolean nettingApplicable { get; set; }
        private boolean nettingComplete { get; set; }
        private boolean collateralAgreementFlag { get; set; }
        private string collectiveInvestmentSchemeName{get;set;}
        private string collectiveInvestmentSchemeType{get;set;}
        private string collectiveInvestmentSchemeNameSDS{get;set;}
        private string primeServicesClient{get;set;}
        private string bankName{get;set;}
        private string bankSDS{get;set;}
        private string relationshipSds{get;set;}
        
        
        private  Matter(){}
        public Matter(advpm__Matter__c standardMatter)
        {
            this.active = standardMatter.Active__c;
            this.collateralAgreementFlag = standardMatter.collateral_Agreement_Flag__c;
            this.nettingComplete = standardMatter.netting_Complete__c;
            this.nettingApplicable = standardMatter.Netting_Applicable__c;
            this.masterAgreementType = standardMatter.Master_Agreement_Type__c;
            this.counterpartyType = standardMatter.Counterparty_Type__c;
            this.relationshipTypepicklist = standardMatter.Relationship_Type_picklist__c;
            this.relationshipName = standardMatter.Relationship__r.Name;
            this.Name = standardMatter.Name;
            this.Id = standardMatter.Id;
            this.CollectiveInvestmentSchemeName = standardMatter.Collective_Investment_Scheme_Name__r.Name;
            this.collectiveInvestmentSchemeType = standardMatter.Collective_Investment_Scheme_Type__c;
            this.primeServicesClient = standardMatter.Prime_Services_Client__c;
            this.collectiveInvestmentSchemeNameSDS= standardMatter.Collective_Investment_Scheme_Name__r.Sds__c;
            this.bankName= standardMatter.Bank__r.Name;
            this.bankSDS=standardMatter.Bank__r.Sds__c;
            this.relationshipSds = standardMatter.Relationship__r.Sds__c;
            
        }
    } 
    
  
    
    public class MarketCollateral
    {
        private string applicableParty { get; set; }
        private string collateralType { get; set; }
        private string marketCollateralCurrency { get; set; }
        private string marketCollateralType { get; set; }
        private string supportingAgreement { get; set; }
        private decimal value { get; set; }
        private string Id { get; set; }
        private string countryofIssue { get; set; }
        private string subType { get; set; }
        private decimal margin{get;set;}
        
        private string agreement{get;set;}
        private string collateralComment{get;set;}
        
        public MarketCollateral(Market_Collateral__c standardMarketCol)
        {
            this.applicableParty =standardMarketCol.Applicable_Party__c;
            this.collateralType =standardMarketCol.Collateral_Type__c;
            this.marketCollateralCurrency = standardMarketCol.Currency__c;
            this.marketCollateralType = standardMarketCol.Market_Collateral_Type__c;
            this.supportingAgreement = standardMarketCol.Supporting_Agreement__c;
            this.value = standardMarketCol.Value__c;
            this.Id =standardMarketCol.Id;
            this.countryofIssue  = standardMarketCol.Country_of_Issue__c;
            this.subType = standardMarketCol.Sub_Type__c;
            this.margin = standardMarketCol.Margin__c;
            this.agreement = standardMarketCol.Agreement__c;
            this.collateralComment = standardMarketCol.Collateral_Comments__c;
        }
        
    }
   
    
    public class Jurisdiction
    {
        private string name { get; set; }
        private string jurisdictionsNettingDoesNotApply { get; set; }
        private string matter { get; set; }
        private string Id {get;set;}
        
        public Jurisdiction(Jurisdiction__c standardJurisdiction)
        {
            this.name = standardJurisdiction.Name;
            this.jurisdictionsNettingDoesNotApply = standardJurisdiction.Jurisdictions_Netting_Does_Not_Apply__c;
            this.matter = standardJurisdiction.Matter__c;
            this.Id = standardJurisdiction.ID;
        }
    }
    
    public class DealParty
    {
        private boolean assetManager { get; set; }
        private boolean counterparty { get; set; }
        private string deal { get; set; }
        private string relationship { get; set; }
        private string relationshipSDSID { get; set; }
        private string relationshipType { get; set; }
        private string Id { get; set; }
        private string relationshipName { get; set; }
        private string supportingAgreement{get;set;}
        
        public DealParty(Deal_Party__c standardDealParty)
        {
            this.assetManager = standardDealParty.Asset_Manager__c;
            this.counterparty  = standardDealParty.Counterparty__c;
            this.deal  = standardDealParty.Deal__c;
            this.relationshipSDSID  = standardDealParty.Relationship_SDS_ID__c;
            this.relationshipType = standardDealParty.Relationship_Type__c;
            this.Id  = standardDealParty.Id;
            this.relationshipName  = standardDealParty.Relationship__r.Name;
            this.supportingAgreement = standardDealParty.Supporting_Agreement__c;
        }
    }
   
    
    public class Clause
    {
        private string clauseName { get; set; }
        private string clauseType{get;set;}
        private boolean afffectsBanksLiquidity { get; set; }
        private string Id { get; set; }
        public  Clause(Clause__c standardClause)
        {
            this.clauseName = standardClause.Clause_Name__c;
            this.afffectsBanksLiquidity = standardClause.Afffects_Bank_s_Liquidity__c;
            this.Id = standardClause.Id;
            this.clauseType = standardClause.Clause_Type__c;
        }
    }
  
    
    public class Agreement
    {
        private string Id { get; set; }
        private string absaAsAgentPrincipal{get;set;}
        private string absaAsBorrowerLender{get;set;}
        private string agreementComments{get;set;}
        private string agreementStatus { get; set; }
        private string agreementID { get; set; }
        private string bank { get; set; }
        private decimal bankMinimumTransferAmount{get;set;}
        private string BaseCurrency{get;set;}
        private string bilateralUnilateral { get; set; }
        private Date breakClauseDate{get;set;}
        private decimal breakClausedays{get;set;}
        private string businessUnit { get; set; }
        private string buySellBackApplies { get; set; }
        private string calculationAgent{get;set;}
        private decimal cashAmount { get; set; }
        private decimal cashAmountCounterparty{get;set;}
        private string changeReason{get;set;}
        private string closureReason{get;set;}
        private string  counterpartyAsAgentPrincipal{ get; set; }
        private string counterpartyAsBorrowerLender{ get; set; }
        private decimal counterpartyMinimumTransferAmount{ get; set; }
        private string countryofIssue { get; set; }
        private decimal crossDefaultThresholdReAbsa{ get; set; }
        private decimal crossDefaultThresholdReCounterparty{ get; set; }
        private string currencyIsoCode { get; set; }
        private string currencyReAbsa { get; set; }
        private string currencyReCounterparty { get; set; }
        private decimal equityPercentage{get;set;}
        private decimal equityPercentageCounterparty { get; set; }
        private string facilityLoanDate{get;set;}
        private string facilityLoanName{get;set;}
        private String GMRATransactionType{get;set;}
        private string governingLaw { get; set; }
        private string loanLinked{get;set;}
        private string loanName{get;set;}
        private string marginMaintenanceAmountAbsa {get;set;}
        private string marginMaintenanceAmountCounterparty {get;set;}
        private decimal marginMaintenanceOwnAmountAbsa {get;set;}
        private decimal MarginMaintenanceOwnAmountCounter {get;set;}
        private string masterAgreementName { get; set; }
        private boolean masterAgreementRequiredPriortoFirst { get; set; }
        private Date masterAgreementStartDate { get; set; }
        private string masterAgreementType { get; set; }
        private string masterAgreementVersion { get; set; }
        private string matterDeal { get; set; }
        private string primeServicesClient{get;set;}
        private string PrincipalType{get;set;}
        private string relationshipType { get; set; }
        private string relationshipName{get;set;}
        private string terminationCurrency { get; set; }
        private string transactionExposureCalculationMethod{get;set;}
        private string tripartyAgent { get; set; }
        
        public  Agreement(Agreement__c standardAgreement)
        {
            this.Id =standardAgreement.id;
            this.agreementComments = standardAgreement.Agreement_Comments__c;
            this.agreementStatus = standardAgreement.Agreement_Status__c; 
            this.agreementID = standardAgreement.Agreement_ID__c;
            this.bank = standardAgreement.Bank__c;
            this.bankMinimumTransferAmount = standardAgreement.Bank_Minimum_Transfer_Amount__c;
            this.BaseCurrency = standardAgreement.Base_Currency__c;
            this.bilateralUnilateral = standardAgreement.Bilateral_Unilateral__c;
            this.breakClauseDate = standardAgreement.Break_Clause_Date__c;
            this.breakClausedays = standardAgreement.Break_Clause_days__c;
            this.businessUnit =  standardAgreement.Business_Unit__c;
            this.buySellBackApplies = standardAgreement.Buy_Sell_Back_Applies__c;
            this.calculationAgent = standardAgreement.Calculation_Agent__c;
            this.cashAmount = standardAgreement.Cash_Amount__c;
            this.cashAmountCounterparty= standardAgreement.Cash_Amount_counterparty__c;
            this.changeReason = standardAgreement.Change_Reason__c;
            this.closureReason = standardAgreement.Closure_Reason__c;
            this.counterpartyAsAgentPrincipal = standardAgreement.Counterparty_as_Agent_Principal__c;
            this.counterpartyAsBorrowerLender = standardAgreement.Counterparty_as_Borrower_Lender__c;
            this.CounterpartyMinimumTransferAmount = standardAgreement.Counterparty_Minimum_Transfer_Amount__c;
            this.countryofIssue = standardAgreement.Country_of_Issue__c;
            this.crossDefaultThresholdReAbsa = standardAgreement.Cross_Default_Threshold_Re_Absa__c;
            this.crossDefaultThresholdReCounterparty = standardAgreement.Cross_Default_Threshold_Re_Counterparty__c;
            this.currencyIsoCode = standardAgreement.CurrencyIsoCode;
            this.currencyReAbsa = standardAgreement.Currency_Re_Absa__c;
            this.currencyReCounterparty = standardAgreement.Currency_Re_Counterparty__c;
            this.equityPercentage = standardAgreement.Equity_Percentage__c;
            this.equityPercentageCounterparty = standardAgreement.Equity_Percentage_Counterparty__c;
            this.facilityLoanDate = standardAgreement.Facility_Loan_Date__c;
            this.facilityLoanName = standardAgreement.Facility_Loan_Name__c;
            this.GMRATransactionType = standardAgreement.GMRA_Transaction_Type__c;
            this.governingLaw = standardAgreement.Governing_Law__c;
            this.loanLinked = standardAgreement.Loan_Linked__c;
            this.loanName= standardAgreement.Loan_Name__c;
            this.marginMaintenanceAmountAbsa = standardAgreement.Margin_Maintenance_Amount_Absa__c;
            this.marginMaintenanceAmountCounterparty = standardAgreement.Margin_Maintenance_Amount_Counterparty__c;
            this.marginMaintenanceOwnAmountAbsa = standardAgreement.Margin_Maintenance_Own_Amount_Absa__c;
            this.MarginMaintenanceOwnAmountCounter = standardAgreement.Margin_Maintenance_Own_Amount_Counter__c;
            this.masterAgreementName = standardAgreement.Master_Agreement_Name__c;
            this.masterAgreementRequiredPriortoFirst = standardAgreement.Master_Agreement_Required_Prior_to_First__c;
            this.masterAgreementStartDate = standardAgreement.Master_Agreement_Start_Date__c;
            this.masterAgreementType = standardAgreement.Master_Agreement_Type__c;
            this.masterAgreementVersion = standardAgreement.Master_Agreement_Version__c;
            this.matterDeal = standardAgreement.Matter_Deal__c;
            this.primeServicesClient = standardAgreement.Prime_Services_Client__c;
            this.PrincipalType = standardAgreement.Principal_Type__c;
            this.relationshipType = standardAgreement.Relationship_Type__c;
            this.relationshipName = standardAgreement.Relationship__c;
            this.terminationCurrency = standardAgreement.Termination_Currency__c;
            this.transactionExposureCalculationMethod = standardAgreement.Transaction_Exposure_Calculation_Method__c;
            this.tripartyAgent = standardAgreement.Triparty_Agent__c;
            this.absaAsAgentPrincipal  = standardAgreement.Absa_as_Agent_Principal__c;
            this.absaAsBorrowerLender =  standardAgreement.Absa_as_Borrower_Lender__c;
            
        }
    }
    
    public class Ammendment
    {
        private string agreement{get;set;}
        private boolean amendmentDocumentUploaded {get;set;}
        private string amendmentReasonType {get;set;}
        private string amendmentReason {set;get;}
        private DateTime effectiveDate {get;set;}
        private string matter {get;set;}
        private string name {get;set;}
        private string nameOfRegulation{get;set;}
        private string supportingAgreement{get;set;}
        private string Id {get;set;}
        public Ammendment(Amendment__c standardAmmendment)
        {
            this.agreement = standardAmmendment.Agreement__c;
            this.amendmentDocumentUploaded = standardAmmendment.Amendment_Document_Uploaded__c;
            this.amendmentReasonType = standardAmmendment.Amendment_Reason_Type__c;
            this.amendmentReason = standardAmmendment.Amendment_Reason__c;
            this.effectiveDate = standardAmmendment.Effective_date__c;
            this.matter = standardAmmendment.Matter__c;
            this.name = standardAmmendment.Name;
            this.nameOfRegulation = standardAmmendment.Name_of_Regulation__c;
            this.supportingAgreement = standardAmmendment.Supporting_Agreement__c;
            this.Id = standardAmmendment.id;
            
        }
    }
    public class AgreementTradeInstrument
    {
        private string agreementId{get;set;}
        private string supportingAgreement{get;set;}
        private string tradeInstrument{get;set;}
        
        private string assetClass { get; set; }
        private string agreementType { get; set; }
        private string Id { get; set; }
        private string Name { get; set; }
        public AgreementTradeInstrument(Agreement_Trade_Instrument__c agreementTradeInstrument)
        {
            this.agreementId = agreementTradeInstrument.Agreement__c;
            this.supportingAgreement = agreementTradeInstrument.Supporting_Agreement__c;
            this.tradeInstrument = agreementTradeInstrument.Trade_Instrument__c;
            this.Id = agreementTradeInstrument.id;
            
            if(agreementTradeInstrument.Trade_Instrument__c!=null)
            {
               this.assetClass =agreementTradeInstrument.Trade_Instrument__r.Asset_Class__c;
                this.agreementType =agreementTradeInstrument.Trade_Instrument__r.Agreement_Type__c;
                this.Name =agreementTradeInstrument.Trade_Instrument__r.Name;
            }
        }
    }
    public class AgreementClause
    {
        private string agreementId{get;set;}
        private string clauseId{get;set;}
        private string agreementClauseId{get;set;}
        private string clauseName { get; set; }
        private string clauseType{get;set;}
        private boolean afffectsBanksLiquidity { get; set; }
        public AgreementClause(Agreement_Clause__c agreementClause)
        {
            this.agreementClauseId = agreementClause.Id;
            this.agreementId = agreementClause.Agreement__c;
            this.clauseId = agreementClause.Clause__c;
            
            if(agreementClause.Clause__c!=null)
            {
                this.clauseName=agreementClause.Clause__r.Clause_Name__c;
                this.clauseType=agreementClause.Clause__r.Clause_Type__c;
                this.afffectsBanksLiquidity =agreementClause.Clause__r.Afffects_Bank_s_Liquidity__c;
            }
        }
    }
    
    public class RootObject
    {
        public List<AgreementClause> agreementClauses{get;set;}
        public List<AgreementTradeInstrument> agreementTradeInstruments{get;set;}
        //public List<TradeInstrument> TradeInstruments { get; set; }
        public List<SupportingAgreement> SupportingAgreements { get; set; }
        public List<Participant> Participants { get; set; }
        public List<NettingGroup> NettingGroups { get; set; }
        public List<NettingGroupBranch> NettingGroupBranches { get; set; }
        public Matter Matter { get; set; }
        public List<MarketCollateral> MarketCollateral { get; set; }
        public List<Jurisdiction> Jurisdictions { get; set; }
        public List<DealParty> DealParties { get; set; }
        //public List<Clause> Clause { get; set; }
        public List<Agreement> Agreements { get; set; }
        public List<Ammendment> matterAmendments{get;set;}
        public List<Ammendment> agreementAmendments{get;set;}
        public List<Ammendment> supportingAgreementAmendment{get;set;}
        
        public RootObject()
        {
            agreementTradeInstruments = new List<AgreementTradeInstrument>();
            agreementClauses = new List<AgreementClause>();
            //TradeInstruments = new List<TradeInstrument>();
            SupportingAgreements = new List<SupportingAgreement> ();
            Participants = new List<Participant> ();
            NettingGroups=  new List<NettingGroup> ();
            NettingGroupBranches = new List<NettingGroupBranch> ();
            matter = new Matter();
            MarketCollateral = new List<MarketCollateral>();
            Jurisdictions = new List<Jurisdiction>();
            DealParties = new List<DealParty>();
            //Clause = new List<Clause>();
            Agreements = new List<Agreement> ();
            matterAmendments = new List<Ammendment>();
            agreementAmendments = new List<Ammendment>();
            supportingAgreementAmendment = new List<Ammendment>();        }
    }
    
    
    
}