public class Libra_Restul_Functions {
    
    public static List<advpm__Matter__c> getAll()
    {
        return [Select ID,Name,Relationship__r.Name, Master_agreement_type__c,Relationship__r.SDS__c
                from advpm__Matter__c 
                where ID IN (Select matter_deal__c from Agreement__c where Agreement_Status__c IN ('Confirmed/Completed','Amended'))];
    }
    public static List<Trade_Instrument__c> getTradeInstrumentByIdSet(Set<Id> sObjectIdSet)
    {
        return [Select Trade_Instrument_ID__c, Asset_Class__c, Agreement_Type__c, Id, Name
               From Trade_Instrument__c where ID IN:sObjectIdSet];
    }
    public static List<Market_Collateral__c> getmarketCollateralOnSupportingAgreement(ID matterId)
    {
        return [SELECT Name,Agreement__c,Applicable_Party__c,Collateral_Comments__c,Collateral_Type__c,Country_of_Issue__c,
                Currency__c,Margin__c,Market_Collateral_Type__c,Sub_Type__c,Supporting_Agreement__c,Value__c,Id
                FROM Market_Collateral__c
                where Supporting_Agreement__r.Agreement__r.Matter_Deal__c = :matterId];
    }
    public static List<Market_Collateral__c> getmarketCollateralOnAgreement(ID matterId)
    {
        return [SELECT Name,Agreement__c,Applicable_Party__c,Collateral_Comments__c,Collateral_Type__c,Country_of_Issue__c,
                Currency__c,Margin__c,Market_Collateral_Type__c,Sub_Type__c,Supporting_Agreement__c,Value__c,Id
                FROM Market_Collateral__c
                where Agreement__r.Matter_Deal__c = :matterId];
    }
    public static String listToString(List<SOBJECT> objectList)
    {
        List<String> sObjectId = new List<String>();
        for(SOBJECT obj : objectList)
        {
            sObjectId.add(obj.ID);
        }
        string allstring = '\''+string.join(sObjectId,'\',\'')+'\'';
        return '('+allstring+')';
    }
    public static List<Clause__c> getClauseByIdSet(Set<Id> sObjectIdSet)
    {
        return [Select Clause_Name__c, Clause_Type__c, Sort_Order__c, Name, Afffects_Bank_s_Liquidity__c, Id, Clause_Unique__c, 
                		GMRA_Clause__c, GMRA_Default__c, GMSLA_Clause__c, GMSLA_Default__c, ISDA_Clause__c
               From Clause__c where ID IN:sObjectIdSet];
    }
    public static List<NettingGroupBranch__c> getNettingGroupBranchByIdSet(Set<ID> NettingGroupIDSet)
    {
        return [Select Name, BranchType__c, NettingGroup__c,Relationship__r.Sds__c, Relationship__c, Trade_Instrument__c, Trade_Instrument__r.Name,Id, Relationship__r.Name 
                
                From NettingGroupBranch__c
                Where NettingGroup__c IN:NettingGroupIDSet];
    }
    
    public static List<SObject> getSObjectById(List<String> sObjectId,String sObjectColumns,String sObjectName)
    {        
            
            string allstring = '\''+string.join(sObjectId,'\',\'')+'\'';
        System.debug(allstring);
        String query = 'SELECT ' + sObjectColumns + ' FROM '+sObjectName+' WHERE Id = ('+allstring+')';
        
        return Database.query(query);
    }
    public static List<SObject> getSObjectById(String sObjectId,String sObjectColumns,String sObjectName)
    {        
        String query = 'SELECT ' + sObjectColumns + ' FROM '+sObjectName+' WHERE Id = \''+sObjectId+'\'';
        
        return Database.query(query);
    }
    public static List<SObject> getSObject(String sObjectColumns,String sObjectName)
    {        
        String query = 'SELECT ' + sObjectColumns + ' FROM '+sObjectName;
        
        return Database.query(query);
    }
    public static List<SObject> getSObjectById(String sObjectId,String sObjectColumns,String sObjectName,String additionalClause)
    {        
        String query = 'SELECT ' + sObjectColumns + ' FROM '+sObjectName+' WHERE Id = \''+sObjectId+'\' AND '+additionalClause;
        
        return Database.query(query);
    }
    public static List<SObject> getSObjectByMatterId(String sObjectId,String sObjectColumns,String sObjectName, String whereClause)
    {        
        String query = 'SELECT ' + sObjectColumns + ' FROM '+sObjectName;
        
        if(String.isNotBlank(whereClause))
        {
            query = query +' '+whereClause;
        }
        
        return Database.query(query);
    }
    public static Map<ID,List<NettingGroupBranch__c >> getBranchPerNettingGroup(List<NettingGroupBranch__c> NettingGroupBranchList)
    {
		Map<ID,List<NettingGroupBranch__c >> branchPerNettingGroup = new Map<Id,List<NettingGroupBranch__c >>();
        
        for(NettingGroupBranch__c NGB : NettingGroupBranchList)
        {
            if(branchPerNettingGroup.containsKey(NGB.NettingGroup__c))
            {
                List<NettingGroupBranch__c > tempList= branchPerNettingGroup.get(NGB.NettingGroup__c);
                tempList.add(NGB);
                branchPerNettingGroup.put(NGB.NettingGroup__c,tempList);
            }
            else
            {
                branchPerNettingGroup.put(NGB.NettingGroup__c,new List<NettingGroupBranch__c>{NGB});
            }
        }
        return branchPerNettingGroup;
    }
    
    public static Map<String,List<NettingGroupBranch__c >> getNettingGroupbranch(List<NettingGroupBranch__c> NettingGroupBranchList)
    {
        Map<String,List<NettingGroupBranch__c >> nettingMap = new Map<String,List<NettingGroupBranch__c >>();
        
        for(NettingGroupBranch__c NGB : NettingGroupBranchList)
        {
            if(nettingMap.containsKey(NGB.BranchType__c))
            {
                System.debug(NGB.BranchType__c);
                List<NettingGroupBranch__c > tempList= nettingMap.get(NGB.BranchType__c);
                tempList.add(NGB);
                nettingMap.put(NGB.BranchType__c,tempList);
            }
            else
            {
                nettingMap.put(NGB.BranchType__c,new List<NettingGroupBranch__c>{NGB});
            }
        }
        return nettingMap;
    }
    
    public class AgreementClauseWrapper
    {
        public String agreementClauseId{get;set;}
    }
    public class AmendmentWrapper
    {
        public String amendmentId{get;set;}
        public String amendmentType{get;set;}
    }
    public class NettingGroupBranchWrapper
    {
        public String nettingGroupBranchId{get;set;}
    }
    public class NettingGroupWrapper
    {
        public String nettingGroupId {get;set;}
    }
    public class ClauseWrapper
    {
        public String clauseId {get;set;}
    }
    public class DealPartyWrapper
    {
        public String dealPartyId{get;set;}
    }
    public class MatterWrapper
    {
        public string matterId{get;set;}
    }
    public class AgreementTradeInstrumentWrapper
    {
        public String agreementTradeInstrumentId  {get;set;}
    }
    public class ParticipantWrapper
    {
        public String participantId{get;set;}
    }
    public class jurisdictionWrapper
    {
        public String jurisdictionId{get;set;}
    }
    
    public class TradeInstrumentWrapper
    {
        public String tradeInstrumentId {get;set;}
    }
    public class AgreementWrapper
    {
        public String agreementId{get;set;}
    }
    public class MarketCollateralWrapper
    {
        public String marketCollateralId{get;set;}
    }
    public Static Blob getExceptionResponse(Exception exc)
    {
        ESPUtility.Response exceptionResponse = new ESPUtility.Response();
        exceptionResponse.message  =exc.getMessage();
        exceptionResponse.stackTrace  =exc.getStackTraceString();
        return  Blob.valueOf(System.JSON.serialize(exceptionResponse));
    }
}