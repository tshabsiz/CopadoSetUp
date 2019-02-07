public class Libra_Restful_Constants {

    public static final String NotFound = 'Not found';
    
    public static final Integer statusCodeNotFound = 404;
    public static final integer statusCodeFetalError=500;
    
    public static final String matterObject = 'advpm__Matter__c';
    public static final String agreementObject = 'Agreement__c';
    public static final String SupportingAgreementObject = 'Supporting_Agreement__c';
    public static final String MarketCollateralObject = 'Market_Collateral__c';
    public static final String tradeInstrumentObject = 'Trade_Instrument__c';
    public static final String AgreementTradeInstrumentObject = 'Agreement_Trade_Instrument__c';
	public static final String JurisdictionObject='jurisdiction__c';
    public static final String DealPartyObject = 'Deal_Party__c';
    public static final String ClauseObject = 'clause__c';
    public static final String AgreementClauseObject = 'Agreement_Clause__c';
    public static final String NettingGroupObject = 'Netting_Group__c';
    public static final String nettingGroupBranchObject = 'NettingGroupBranch__c';
    public static final String AmendmentObject = 'Amendment__c';
    public static final String ParticipantObject = 'advpm__Participant__c';

	public static final String AmendmentColumns = 'Agreement__c, Amendment_Document_Uploaded__c, Amendment_Reason_Type__c, Amendment_Reason__c,'+
        										' Effective_date__c, Matter__c, Name, Name_of_Regulation__c, RecordTypeId,Supporting_Agreement__c, Id ';
	    
    public static final String nettingGroupColumns = 'Id, Name, Cross_Counterparty__c, Cross_Product__c, Matter_Deal__c, Net_Across_Bank__c, Net_Across_Counterparty__c, Netting_Strength__c, Netting_Type__c ';
    
    public static final String nettingGroupBranchColumns = 'Name, BranchType__c, NettingGroup__c,Relationship__r.Sds__c ,Relationship__c,Trade_Instrument__r.Name,Trade_Instrument__c, Id, Relationship__r.Name ';
    
    public static final String AgreementClauseColumns = 'Name, Agreement__c, Clause__c, Id, Clause__r.Clause_Name__c, Clause__r.Clause_Type__c, Clause__r.Sort_Order__c, Clause__r.Name,'+
        												' Clause__r.Afffects_Bank_s_Liquidity__c, Clause__r.Clause_Unique__c,' +
                										' Clause__r.GMRA_Clause__c, Clause__r.GMRA_Default__c, Clause__r.GMSLA_Clause__c, Clause__r.GMSLA_Default__c, Clause__r.ISDA_Clause__c ';
    
    public static final String ClauseColumns = 'Clause_Name__c, Clause_Type__c, Sort_Order__c, Name, Afffects_Bank_s_Liquidity__c, Id, Clause_Unique__c, GMRA_Clause__c, GMRA_Default__c, GMSLA_Clause__c, GMSLA_Default__c, ISDA_Clause__c ';
    
    public static final String DealPartyColumns = 'Asset_Manager__c, Counterparty__c, Deal__c, Party_B__c, Relationship__c, Relationship_SDS_ID__c, Relationship_Type__c, Supporting_Agreement__c, Id, Relationship__r.Name ';
    
    public static final String JurisdictionColumns ='Name, Jurisdictions_Netting_Does_Not_Apply__c ,Matter__c, Id ';
    
    public static final String AgreementTradeInstrumentColumns='Id, Agreement__c, Name, Supporting_Agreement__c, Trade_Instrument__c,'+
        		'Trade_Instrument__r.Trade_Instrument_ID__c, Trade_Instrument__r.Asset_Class__c, Trade_Instrument__r.Agreement_Type__c, Trade_Instrument__r.Name ';
    
    public static final String ParticipantColumns  = 'advpm__Comment__c,advpm__Contact__c,Contact_Number__c,advpm__Matter__c,advpm__Role__c,Name,RecordTypeId,RecordType.Name,Primary_Contact_for_Role__c,Receive_Notifications__c,Id ';
    
    public static final String MarketCollateralColumns = 'Name,Agreement__c,Applicable_Party__c,Collateral_Comments__c,Collateral_Type__c,Country_of_Issue__c,'+
        												'Currency__c,Margin__c,Market_Collateral_Type__c,Sub_Type__c,Supporting_Agreement__c,Value__c,Id ';
    
    public static final String MatterColumns = 'ID,Name,Active__c,Bank__c,Bank__r.Name,Bank__r.Sds__c,Relationship__r.Sds__c,Relationship__c,Relationship__r.Name,Relationship_Type_picklist__c,Counterparty_Type__c,Collective_Investment_Scheme_Name__c,'+
                                             		'Collective_Investment_Scheme_Type__c,Collective_Investment_Scheme_Name__r.Name,Collective_Investment_Scheme_Name__r.Sds__c,Count_Asset_Manager__c,Count_Counterparty__c,Count_Jurisdiction__c,'+
                                             		'Party_B__c,Master_Agreement_Type__c,Netting_Applicable__c,Netting_Complete__c,Prime_Services_Client__c,'+
                                             		'Collateral_Agreement_Flag__c ';
    
    public static final String AgreementColumns = 'Id,Calculation_Agent__c ,Absa_as_Agent_Principal__c, Absa_as_Borrower_Lender__c, Agreement_Status__c,'+
                                            'Agreement_Template__c, Agreement_Comments__c, Agreement_ID__c, Bank__c, Bank_Minimum_Transfer_Amount__c, '+
                                            'Base_Currency__c, Bilateral_Unilateral__c, Break_Clause_Date__c, Break_Clause_days__c, Business_Unit__c, '+
                                            'Buy_Sell_Back_Applies__c, Cash_Amount_counterparty__c, Cash_Amount__c, Change_Reason__c, Closure_Reason__c,'+ 
                                            'Counterparty_as_Agent_Principal__c, Counterparty_as_Borrower_Lender__c,'+
                                            'Counterparty_Minimum_Transfer_Amount__c, Country_of_Issue__c, Cross_Default_Threshold_Re_Absa__c,'+
                                            'Cross_Default_Threshold_Re_Counterparty__c, CurrencyIsoCode, Currency_Re_Absa__c, Currency_Re_Counterparty__c,'+
                                            'Equity_Percentage__c, Equity_Percentage_Counterparty__c, Facility_Loan_Date__c, Facility_Loan_Name__c,'+ 
                                            'GMRA_Transaction_Type__c, Governing_Law__c, Loan_Name__c, Loan_Linked__c, Margin_Maintenance_Amount_Absa__c,'+ 
                                            'Margin_Maintenance_Amount_Counterparty__c, Margin_Maintenance_Own_Amount_Absa__c,'+ 
                                            'Margin_Maintenance_Own_Amount_Counter__c, Master_Agreement_Name__c,'+ 
                                            'Master_Agreement_Required_Prior_to_First__c, Master_Agreement_Start_Date__c, Master_Agreement_Type__c,'+ 
                                            'Master_Agreement_Version__c, Matter_Deal__c, Prime_Services_Client__c, Principal_Type__c, Relationship__c,'+ 
                                            'Relationship_Type__c, Termination_Currency__c, Transaction_Exposure_Calculation_Method__c, Triparty_Agent__c,'+ 
                                            'RecordTypeId,RecordType.Name ';
    
    public static final String SupportingAgreementColumns = ' Active__c,Bank_Independent_Amount_Type__c,Agreement__c,Agreement_Template__c,Bank_Collateral_Threshold_Amount_Eligibl__c,'+
        'Bank_Collateral_Threshold_Amount_Type__c,Bank_Collateral_Threshold_Fixed_Amount__c,Bank_Minimum_Transfer_Amount_Type__c,'+
        'Bank_Ind_Currency_Initial_Mg_Currency__c,Bank_Independent_Amount_Initial_Margin__c,Bank_Min_Transfer_Fixed_Amount__c,Base_Currency__c,'+
        'BCTRB_F_A_M_A2_S_P_A__c,BCTRB_F_A_M_A3_S_P_A__c,BCTRB_F_A_M_A1_S_P_A__c,BCTRB_F_AA_M_Aa2_S_P_AA__c,BCTRB_F_AA_M_Aa3_S_P_AA__c,'+
        'BCTRB_F_AA_M_Aa1_S_P_AA__c,BCTRB_F_AAA_M_Aaa_S_P_AAA__c,BCTRB_F_BBB_M_Baa2_S_P_BBB__c,BCTRB_F_BBB_M_Baa3_S_P_BBB__c,'+
        'BCTRB_F_BBB_M_Baa1_S_P_BBB__c,BCTRB_F_Below_B_M_Below_Ba1_S_P_A__c,Call_Frequency__c,CCTRB_F_A_M_A2_S_P_A__c,CCTRB_F_A_M_A3_S_P_A__c,'+
        'CCTRB_F_A_M_A1_S_P_A__c,CCTRB_F_AA_M_Aa2_S_P_AA__c,CCTRB_F_AA_M_Aa3_S_P_AA__c,CCTRB_F_AA_M_Aa1_S_P_AA__c,CCTRB_F_AAA_M_Aaa_S_P_AAA__c,'+
        'CCTRB_F_BBB_M_Baa2_S_P_BBB__c,CCTRB_F_BBB_M_Baa3_S_P_BBB__c,CCTRB_F_BBB_M_Baa1_S_P_BBB__c,'+
        'CCTRB_F_BelowB_M_BelowBa1_S_P_BelowB__c,Collateral_type__c,Counterparty_Collateral_T_Amount_Type__c,'+
        'Counterparty_Collateral_Threshold_Amount__c,Counterparty_Collateral_Threshold_Fixed__c,Counterparty_Ind_Amount_Initial_Margin__c,'+
        'Counterparty_Ind_Curr_Initial_Mg_Curr__c,Counterparty_Independent_Amount__c,Counterparty_Independent_Amount_Type__c,'+
        'Counterparty_Min_Transfer_Amount_Type__c,Counterparty_Min_Transfer_Fixed_Amount__c,CSA_Type__c,CurrencyIsoCode,Date__c,'+
        'Dist_Int_Amount_Eligible_Currency__c,Id,Initial_Margin_Calculation_Method__c,Master_Agreement_Type__c,Name,Other_Agreement__c,'+
        'Other_Valuation_Agent__c,RecordTypeId,Rehypothecation__c,Security_Chargor__c,Security_Obligation_to_Absa__c,'+
        'Security_Obligation_to_Counterparty__c,Security_Provider__c,SO_Absa_Own_Amount__c,SO_Counterparty_Own_Amount__c,Substitution__c,'+
        'Supporting_Agreement_Type__c,Termination_Currency__c,Transaction_Exposure_Calculation_Method__c,'+
        'Triparty_Agent__c,Uncleared_Swaps_Margin_Indicator_UCSM__c,Valuation__c,Valuation_Agent__c,Valuation_Date__c,Valuation_Time__c,'+
        'Weekday_that_Constitutes_Valuation_Date__c,Dist_Int_Amount_Int_Ref_Rate__c,Eligible_Currency__c ';
    
    public static final String tradeInstrumentColumns = 'Trade_Instrument_ID__c, Asset_Class__c, Agreement_Type__c, Id, Name ';
}