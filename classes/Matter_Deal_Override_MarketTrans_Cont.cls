/**
* Created by KyleAlexander on 2018/03/14.
* 
* 16/04/2018 - TdB  - Add duplicateCheck() based on Bank, Relationship, Relationship Type and Master Agreement Type
*/

public with sharing class Matter_Deal_Override_MarketTrans_Cont {
    
    public advpm__Matter__c matter {get;set;}
    public Id MatterId {get;set;}
    public Boolean isNewMatter {get;set;}
    public Boolean isEditable {get;set;}
    
    public Matter_Deal_Override_MarketTrans_Cont (ApexPages.StandardController stdController) {
        MatterId = ApexPages.currentPage().getParameters().get('matterId');
        
        if(MatterId != null){
            matter = [select id, name, Bank__c, Relationship__c, Relationship_Type_picklist__c, Counterparty_Type__c,
                      Party_B__c, Master_Agreement_Type__c, Netting_Complete__c, Active__c, Netting_Applicable__c, Prime_Services_Client__c,
                      Collateral_Agreement_Flag__c, Collective_Investment_Scheme_Name__c, Collective_Investment_Scheme_Type__c
                      from advpm__Matter__c where id = :MatterId limit 1];
            isNewMatter = false;
            
            isEditable = true;
            List<Agreement__c> agreementList = [select Id, Agreement_Status__c FROM Agreement__c WHERE Matter_Deal__c = :MatterId];
            for(Agreement__c agreement : agreementList){
                if(agreement.Agreement_Status__c == 'Confirmed/Completed' || agreement.Agreement_Status__c == 'Amended' || agreement.Agreement_Status__c == 'Cancelled/Terminated'){
                    isEditable = false;
                    break;
                }
            }
        }
        else{
            matter = new advpm__Matter__c();
            
            matter.Party_B__c = true;
            
            List<Account> account = [select id, name, SDS__c from Account where SDS__c = '10250696' limit 1];
            
            if(!account.isEmpty())
            {
                matter.Bank__c = account[0].id;
            }
            
            id recId = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Market Transaction').getRecordTypeId();
            matter.RecordTypeId = recId;
            
            isNewMatter = true;
        }
    }
    
    public PageReference CancelPage() {
        PageReference pf = new PageReference('/' + matter.id);
        return pf;
    }
    
    public PageReference SaveMatter() {
        if(isNewMatter == false){
            if(matter.Netting_Complete__c == true){
                //Get all the Netting Groups
                List<Netting_Group__c> nettingGroups = [select id, name, Netting_Type__c from Netting_Group__c where Matter_Deal__c = :MatterId];
                //Get all netting types and check if all of those netting types have been added to the matter
                Schema.DescribeFieldResult fieldResult = Netting_Group__c.Netting_Type__c.getDescribe();
                List<Schema.PicklistEntry> nettingType = fieldResult.getPicklistValues();
                for(Schema.PicklistEntry nt : nettingType){
                    Boolean notAllAdded = false;
                    for(Netting_Group__c ng : nettingGroups){
                        if(ng.Netting_Type__c == nt.getValue()){
                            notAllAdded = true;
                            break;
                        }
                    }
                    if(notAllAdded == false){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Not all Netting Groups have been added. Please add: ' + nt.getValue()));
                        return null;
                    }
                }
                
                //Get all of the existing netting group branches
                List<NettingGroupBranch__c> nettingGroupBranches = [Select id, Relationship__c, Relationship__r.Name, Trade_Instrument__c, Trade_Instrument__r.Name, NettingGroup__c, BranchType__c from NettingGroupBranch__c];
                
                //Get all the Bank branches
                List<Deal_Party__c> bankBranchList = [SELECT Id, Relationship__r.Name FROM Deal_Party__c WHERE Deal__c =: MatterId AND Relationship_Type__c = :'Bank Branch'];
                advpm__Matter__c matterBank = [SELECT Id, Bank__c, Bank__r.Name FROM advpm__Matter__c WHERE Id =: MatterId LIMIT 1];
                
                //Add all banks and bank branches to list
                List<Id> bankBranches = new List<Id>();
                for(Deal_Party__c dp : bankBranchList)
                {
                    bankBranches.add(dp.Relationship__r.Id);
                }
                bankBranches.add(matterBank.Bank__c);
                
                //Get all the Couterparties, dealParties etc.
                List<Deal_Party__c> counterpartyList = [SELECT Id, Relationship__r.Name FROM Deal_Party__c WHERE Deal__c =: MatterId AND (Relationship_Type__c =: 'Counterparty Branch' OR Relationship_Type__c = 'Qualified Investor Hedge Fund' OR Relationship_Type__c = 'Retail Hedge Fund')];
                List<advpm__Matter__c> matterCP = [SELECT Id, Relationship__c, Relationship_Type_picklist__c, Relationship__r.Name FROM advpm__Matter__c WHERE Id =: MatterId AND Relationship_Type_picklist__c =: 'Counterparty' LIMIT 1];
                List<Deal_Party__c> disclosedPrinciplesList = new List<Deal_Party__c>();
                if(matter.Relationship_Type_picklist__c == 'Asset Manager'){
                    disclosedPrinciplesList = [SELECT Id, Relationship__r.Name FROM Deal_Party__c WHERE Deal__c =: MatterId AND Relationship_Type__c =: 'Disclosed Principal'];
                }
                
                //Add all counterparties etc. to list
                List<Id> counterparties = new List<Id>();
                if(!disclosedPrinciplesList.isEmpty() || disclosedPrinciplesList != null){
                    for(Deal_Party__c disPrinc : disclosedPrinciplesList)
                    {
                        counterparties.add(disPrinc.Relationship__r.Id);
                    }
                }
                for(Deal_Party__c dp : counterpartyList)
                {
                    counterparties.add(dp.Relationship__r.Id);
                }
                if(matterCP.size() > 0)
                {
                    counterparties.add(matterCP[0].Relationship__c);
                }
                
                Set<Id> tradeInstrumentIds = new Set<Id>();
                
                //Get all Trade Instruments
                Map<Id, Agreement__c> agreementList = new Map<Id, Agreement__c>([
                    select
                    Id,
                    Agreement_Status__c
                    FROM Agreement__c
                    WHERE
                    Matter_Deal__c = :MatterId]);
                
                Set<Id> agreementIds = agreementList.keySet();
                
                
                List<Agreement_Trade_Instrument__c> agreementTradeInstruments = [select Agreement__c, Trade_Instrument__c FROM Agreement_Trade_Instrument__c WHERE Agreement__c IN :agreementIds];
                
                for(Agreement_Trade_Instrument__c ati : agreementTradeInstruments)
                {
                    tradeInstrumentIds.add(ati.Trade_Instrument__c);
                }
                
                List<Trade_Instrument__c> ti = [select id, name from Trade_Instrument__c WHERE Id IN :tradeInstrumentIds];
                
                //Add all trade instruments to list
                List<Id> tradeInstrument = new List<Id>();
                for(Trade_Instrument__c trIn : ti)
                {
                    tradeInstrument.add(trIn.Id);
                }
                
                List<NettingGroupBranch__c> tempTICloseOutList = new List<NettingGroupBranch__c>();
                List<NettingGroupBranch__c> tempTINovationList = new List<NettingGroupBranch__c>();
                List<NettingGroupBranch__c> tempTISettlementList = new List<NettingGroupBranch__c>();
                
                //Check that all bank and bank branches, counterparty and counterparty branches and disclosed principals associated with the market transaction have been associated with each netting group
                for(Netting_Group__c ng : nettingGroups){
                    List<NettingGroupBranch__c> tempBankList = new List<NettingGroupBranch__c>();
                    List<NettingGroupBranch__c> tempCoutperartyList = new List<NettingGroupBranch__c>();
                    for(NettingGroupBranch__c ngb : nettingGroupBranches){
                        if(ng.id == ngb.NettingGroup__c){
                            if(ngb.BranchType__c == 'Bank'){
                                tempBankList.add(ngb);
                            }
                            else if(ngb.BranchType__c == 'Counterparty'){
                                tempCoutperartyList.add(ngb);
                            }
                            else if (ngb.BranchType__c == 'Trade Instrument') {
                                if(ng.Netting_Type__c == 'Close Out'){
                                    tempTICloseOutList.add(ngb);
                                }
                                else if(ng.Netting_Type__c == 'Novation'){
                                    tempTINovationList.add(ngb);
                                }
                                else if(ng.Netting_Type__c == 'Settlement') {
                                    tempTISettlementList.add(ngb);
                                }
                            }
                        }
                    }
                    if(tempBankList.size() != bankBranches.size()){
                        String missingNames = getMissingBanksOrCounterparties(bankBranches, tempBankList, false);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Not all Banks / Bank Branches have been associated with each Netting Group. Please add the following Bank Branch: ' + missingNames.substring(0, missingNames.length() - 2) + ' for Netting Group: ' + ng.Name));
                        return null;
                    }                 
                    
                    if(tempCoutperartyList.size() != counterparties.size()){
                        String missingNames = getMissingBanksOrCounterparties(counterparties, tempCoutperartyList, false);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Not all Counterparty / Counterparty Branches / Disclosed Principals / Hedge Funds have been associated with each Netting Group. Please add the following Counterparty Branch / Disclosed Principal / Hedge Fund : ' + missingNames.substring(0, missingNames.length() - 2) + ' for Netting Group: ' + ng.Name));
                        return null;
                    }
                    
                }
                //Checks if all trade instruments are added
                if(!tempTICloseOutList.isEmpty()){
                    if(tempTICloseOutList.size() != tradeInstrument.size()) {
                        String missingNames = getMissingBanksOrCounterparties(tradeInstrument, tempTICloseOutList, true);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Not all Trade Instruments have been associated with the Netting Group of Type: Close Out. Please add the following Trade Instruments: ' + missingNames.substring(0, missingNames.length() - 2)));
                        return null;
                    }
                }
                if(!tempTINovationList.isEmpty()){
                    if(tempTINovationList.size() != tradeInstrument.size()) {
                        String missingNames = getMissingBanksOrCounterparties(tradeInstrument, tempTINovationList, true);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Not all Trade Instruments have been associated with the Netting Group of Type: Novation. Please add the following Trade Instruments: ' + missingNames.substring(0, missingNames.length() - 2)));
                        return null;
                    }
                }
                if(!tempTISettlementList.isEmpty()){
                    if(tempTISettlementList.size() != tradeInstrument.size()) {
                        String missingNames = getMissingBanksOrCounterparties(tradeInstrument, tempTISettlementList, true);
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Not all Trade Instruments have been associated with the Netting Group of Type: Settlement. Please add the following Trade Instruments: ' + missingNames.substring(0, missingNames.length() - 2)));
                        return null;
                    }
                }
            }
            
            //Check if must set the matter to inactive
            if(matter.Active__c == false){
                id recId = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Market Transaction (Locked)').getRecordTypeId();
                matter.RecordTypeId = recId;
            }
            
            update matter;
            PageReference pf = new PageReference('/' + matter.id);
            return pf;
        }
        //Netting Complete has not been selected
        else{
            matter.Party_B__c = true;
            matter.Active__c = true;
            try{
                if(matter.Relationship_Type_picklist__c == 'Collective Investment Scheme Manager' && matter.Collective_Investment_Scheme_Name__c == null){
                    if(matter.Collective_Investment_Scheme_Type__c != 'Both' && matter.Collective_Investment_Scheme_Type__c != 'N/A'){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, 'Collective Investment Scheme Name cannot be empty if Collective Investment Scheme Manager is selected as a Relationship Type'));
                        return null;
                    }
                }
                insert matter;
                PageReference pf = new PageReference('/' + matter.id);
                return pf;
            }
            catch (DmlException e){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getDmlMessage(0)));
                return null;
            }
        }
    }
    
    public String getMissingBanksOrCounterparties(List<Id> branchList, List<NettingGroupBranch__c> tempList, Boolean isTradeInstrument){
        Set<Id> missingValues = new Set<Id>(branchList);
        Set<Id> tempSet = new Set<Id>();
        for(NettingGroupBranch__c ngb : tempList)
        {
            if(isTradeInstrument){
                tempSet.add(ngb.Trade_Instrument__c);
            }
            else{
                tempSet.add(ngb.Relationship__r.Id);
            }
        }
        
        missingValues.removeAll(tempSet);
        
        String missingNames = '';
        for(Id mv : missingValues){
            if(isTradeInstrument){
                Trade_Instrument__c tempTI = [select id, name from Trade_Instrument__c where id = :mv];
                missingNames += tempTI.Name + ', ';
            }
            else{
                Deal_Party__c tempBranch = [SELECT Id, Relationship__r.Name FROM Deal_Party__c WHERE Relationship__r.Id = :mv limit 1];
                missingNames += tempBranch.Relationship__r.Name + ', ';
            }
        }
        
        if(missingNames.equals('')){
            missingNames = 'Error';
        }
        
        return missingNames;
    }
    
    public pageReference duplicateCheck()
    {
        List<advpm__Matter__c> marketTransactionDuplicateList = new List<advpm__Matter__c>();
        String matterUrlString = '';
        
        if(!String.isBlank(matter.Relationship__c) && !String.isBlank(matter.Relationship_Type_picklist__c) && !String.isBlank(matter.Master_Agreement_Type__c) && !String.isBlank(matter.Bank__c)) 
        {
            //Get all existing Market Transaction where the Bank, Relationship, Relationship Type and Master Agreement Type is the same
            marketTransactionDuplicateList = [SELECT Id, Name, Bank__c, Relationship__c, Relationship_Type_picklist__c, Master_Agreement_Type__c 
                                              FROM advpm__Matter__c 
                                              WHERE Bank__c = :matter.Bank__c 
                                              AND Relationship__c = :matter.Relationship__c 
                                              AND Relationship_Type_picklist__c = :matter.Relationship_Type_picklist__c
                                              AND Master_Agreement_Type__c = :matter.Master_Agreement_Type__c
                                             ];
        }
        if(!marketTransactionDuplicateList.isEmpty()) 
        {
            for(advpm__Matter__c eachMatter : marketTransactionDuplicateList )
            {
                matterUrlString += '<li  style="margin-left:0px"><a href=' + site.getBaseSecureUrl() + '/' + eachMatter.Id + '>'  + eachMatter.Name + '</a></li>';
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.Warning,'Please note that an ' + matter.Master_Agreement_Type__c + ' already exist between the Bank and Counterparty , Duplicate Market Transaction: <ul style="margin-top:5px">' + matterUrlString + '</ul>'));
        }
        
        return null;
    }
    
}