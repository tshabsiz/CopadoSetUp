/*====================================================
@CreatedDate : 2017-11-15
@CreatedBy : Mabhedle Tonga 
@Description : Purpose of this Class is to house all generic functions that are being used across JLOC application
=====================================================*/
public class JLOC_Utility {

    public static List<OpportunityLineItem> getProposedProducts(ID JLOCID)
    {
        return [SELECT  Id, Product_Name__c, Product_Level_2__r.Name, Product_Level_3__r.Name, Terms_Years__c, Term_Interval__c, Hold_Size__c, Estimated_Utilisation__c, Gross_Margin__c, Margin__c, FTP__c, Arranging_Fee__c, Committment_Fee__c, Annual_Facility_Fee__c, Threshold__c, RoRWA__c, Base_Rate__c, Product2.Family, Balance__c
                    FROM    OpportunityLineItem 
                    WHERE   Opportunity.JLOC__c = :JLOCID
                	AND Opportunity.isClosed=false
                ];
    }
    
    public static List<Client_Plan_Revenue_By_Product__c> getRevenueByProduct(ID ClientPlanID)
    {
        return [
                        SELECT      Client_Plan__c, CreatedById, CreatedDate, CurrencyIsoCode, F12_AssetSalesFinance__c, F12_AverageDepositBalance__c, F12_Debt__c, F12_Deposits__c, F12_Derivatives__c, F12_FX__c, F12_OtherMADCMECM__c, F12_OtherRBBWealth__c, F12_OtherTrade__c, F12_Trade__c, F12_TransactionProducts__c, F12_CommercialPropertyFinance__c, F12_Equities__c, F12_FixedIncome__c, F12_Passive__c, F12_PrimeServices__c, F12_PrivateEquity__c, F12_Treasury__c, F12_WorkingCapital__c, F12P_AssetSalesFinance__c, F12P_AverageDepositBalance__c, F12P_Debt__c, F12P_Deposits__c, F12P_Derivatives__c, F12P_FX__c, F12P_OtherMADCMECM__c, F12P_OtherRBBWealth__c, F12P_OtherTrade__c, F12P_Trade__c, F12P_TransactionProducts__c, F12P_CommercialPropertyFinance__c, F12P_Equities__c, F12P_FixedIncome__c, F12P_Passive__c, F12P_PrimeServices__c, F12P_PrivateEquity__c, F12P_Treasury__c, F12P_WorkingCapital__c, F24_AssetSalesFinance__c, F24_AverageDepositBalance__c, F24_Debt__c, F24_Deposits__c, F24_Derivatives__c, F24_FX__c, F24_OtherMADCMECM__c, F24_OtherRBBWealth__c, F24_OtherTrade__c, F24_Trade__c, F24_TransactionProducts__c, F24_CommercialPropertyFinance__c, F24_Equities__c, F24_FixedIncome__c, F24_Passive__c, F24_PrimeServices__c, F24_PrivateEquity__c, F24_Treasury__c, F24_WorkingCapital__c, F24P_AssetSalesFinance__c, F24P_AverageDepositBalance__c, F24P_Debt__c, F24P_Deposits__c, F24P_Derivatives__c, F24P_FX__c, F24P_OtherMADCMECM__c, F24P_OtherRBBWealth__c, F24P_OtherTrade__c, F24P_Trade__c, F24P_TransactionProducts__c, F24P_CommercialPropertyFinance__c, F24P_Equities__c, F24P_FixedIncome__c, F24P_Passive__c, F24P_PrimeServices__c, F24P_PrivateEquity__c, F24P_Treasury__c, F24P_WorkingCapital__c, H12_AssetSalesFinance__c, H12_AverageDepositBalance__c, H12_Debt__c, H12_Deposits__c, H12_Derivatives__c, H12_FX__c, H12_OtherMADCMECM__c, H12_OtherRBBWealth__c, H12_OtherTrade__c, H12_Trade__c, H12_TransactionProducts__c, H12_CommercialPropertyFinance__c, H12_Equities__c, H12_FixedIncome__c, H12_Passive__c, H12_PrimeServices__c, H12_PrivateEquity__c, H12_Treasury__c, H12_WorkingCapital__c, Id, IsDeleted, LastModifiedById, LastModifiedDate, Name, SystemModstamp, Tot_F12_Contrib_Weighted__c, Tot_F12_Contribution__c, Tot_F12_Non_Lending_Contrib__c, Tot_F12_Non_Lendng_Contrib_Weighted__c, Tot_F24_Contrib_Weighted__c, Tot_F24_Contribution__c, Tot_F24_Non_Lending_Contrib__c, Tot_F24_Non_Lendng_Contrib_Weighted__c, Tot_H12_Contribution__c, Tot_H12_Non_Lending_Contrib__c, rorwa_Deposits__c, rorwa_AverageDepositBalance__c, rorwa_TransactionProducts__c, rorwa_Derivatives__c, rorwa_Debt__c, rorwa_Trade__c, rorwa_FX__c, rorwa_AssetSalesFinance__c, rorwa_OtherTrade__c, rorwa_OtherMADCMECM__c, rorwa_CommercialPropertyFinance__c, rorwa_Equities__c, rorwa_FixedIncome__c, rorwa_Passive__c, rorwa_PrimeServices__c, rorwa_PrivateEquity__c, rorwa_Treasury__c, rorwa_WorkingCapital__c, rorwa_OtherRBBWealth__c, RWA_Deposits__c,RWA_AverageDepositBalance__c,RWA_TransactionProducts__c,RWA_Debt__c,RWA_Trade__c,RWA_FX__c,RWA_AssetSalesFinance__c,RWA_OtherTrade__c,RWA_OtherMADCMECM__c,RWA_OtherRBBWealth__c, RWA_CommercialPropertyFinance__c, RWA_Equities__c, RWA_FixedIncome__c, RWA_Passive__c, RWA_PrimeServices__c, RWA_PrivateEquity__c, RWA_Treasury__c, RWA_WorkingCapital__c
                        FROM        Client_Plan_Revenue_By_Product__c
                        WHERE       Client_Plan__c = :ClientPlanID
                        ORDER BY    CreatedDate DESC 
                        LIMIT       1
                    ];
    }
    
    public static List<Budget_Revenue__c> getExistingProduct(ID ClientPlanID)
    {
        return  [
                    SELECT      Id, Product_Level_3__c, Product_Level_3__r.Name, Product__c, Country__c, Maturity_Date__c, LGD__c, DG__C, Limit__c, Utilisation__c, Margin__c, FTP__c, Arranging_Fee__c, Commitment_Fee__c, RoRWA__c
                    FROM        Budget_Revenue__c
                    WHERE       Client_Plan__c = :ClientPlanID
                    ORDER BY    Product__c
                ];
    }
    
    public static void logException(Exception e, String classname, String method, String devnote){
        
        Jloc_Clientplan_Exception_Audit_Trail__c auditTrail = new Jloc_Clientplan_Exception_Audit_Trail__c();	
       
        auditTrail.Class_Name__c = classname;
        auditTrail.Exception_DateTime__c = System.now();
        auditTrail.Exception_Message__c = e.GetMessage();
        auditTrail.Method_Name__c = method;
        auditTrail.Line_Number__c = e.getLineNumber();
        auditTrail.Stack_Trace__c = e.getStackTraceString();
        auditTrail.Developer_Notes__c = devnote;
        auditTrail.User_ID__c = UserInfo.getUserId();

            try{
            	insert auditTrail;
                System.debug('Error was logged in the Jloc_Clientplan_Exception_Audit_Trail Object');
        		System.debug(e.getMessage());
            }catch(DMLException ex){
                System.debug('Error could not be logged in the audit trail object');
        		System.debug(ex.getMessage());
                System.debug('Original Error below:');
                System.debug(e.getMessage());
            }
    }
    
    public static Boolean NonSADeals(List<Opportunity> jlocOpenOpportunitiesIncluded) {
        for(Opportunity opp : jlocOpenOpportunitiesIncluded) {
        	if (opp.Opportunity_Country__c != NULL && opp.Opportunity_Country__c != 'South Africa') return true;
        }
        return false;
    }
}