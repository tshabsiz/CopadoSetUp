public class nettingGroupExtension {
    
    public Netting_Group__c nettingGroup;
    private ApexPages.StandardController stdController;
    
    public Boolean isNewRecord {get;set;}
    public String[] selectedBankBranches {get;set;}
    public String[] selectedCounterparties {get;set;}
    public String[] selectedTradeInstruments {get;set;}
    
    public Id dealId;

    public Set<String> bankBranchIdSet {get;set;}
    public Set<String> CounterpartyBranchIdSet {get;set;}
    public Set<String> TradeInstrumentBranchIdSet {get;set;}
    public Set<String> bankBranchNameSet {get;set;}
    public Set<String> CounterpartyBranchNameSet {get;set;}
    public Set<String> TradeInstrumentBranchNameSet {get;set;}

    public List<NettingGroupBranch__c> nettingGroupBranchesBank = new List<NettingGroupBranch__c>();
    public List<NettingGroupBranch__c> nettingGroupBranchesCP = new List<NettingGroupBranch__c>();
    public List<NettingGroupBranch__c> nettingGroupBranchesTI = new List<NettingGroupBranch__c>();

    public Boolean nettingGroupPanel {get;set;}

    public Boolean isSaveAndNew {get;set;}
    public String duplicateNettingName;
    public String duplicateRelName;
    public String duplicateTIName;

    public advpm__Matter__c matter;

    public Boolean defaultCounterpartyToNo {get;set;}

    public nettingGroupExtension(ApexPages.StandardController stdController) 
    {
        //add fields not used on VF page
        if(test.isRunningTest() == false)
        {
        stdController.addFields(new List<String>{'Matter_Deal__c'});
        }
        
        this.nettingGroup = (Netting_Group__c)stdController.getRecord();
        this.stdController = stdController;
        
        system.debug('nettingGroup.Id: ' + nettingGroup.Id);
        
        //Used to check if this is new/existing record - Value set on button
        String isNewRecordString = ApexPages.currentPage().getParameters().get('new');
        
        if(isNewRecordString != 'true') 
        {
            isNewRecordString = 'false';
        }
        isNewRecord = Boolean.valueOf(isNewRecordString);
        
        if(isNewRecord)
        {
            dealId = ApexPages.currentPage().getParameters().get('dealId');
            nettingGroup.Matter_Deal__c = dealId;
        }
        else
        {
            dealId = nettingGroup.Matter_Deal__c;
        }

        try
        {
            matter = [select id, name, Netting_Complete__c, Relationship_Type_picklist__c from advpm__Matter__c where id = :dealId limit 1];
            if(matter.Relationship_Type_picklist__c == 'Asset Manager' || matter.Relationship_Type_picklist__c == 'Collective Investment Scheme Manager'){
                defaultCounterpartyToNo = true;
            }
            else{
                defaultCounterpartyToNo = false;
            }

            if(matter.Netting_Complete__c == true){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.WARNING,'By Saving, Editing or Deleting this Netting Group, it will make Netting Incomplete.'));
            }
        }
        catch(Exception e){}
        
		//Query existingdBankBranches to set picklist values  
        List<NettingGroupBranch__c> existingdBankBranches = 
            [
                SELECT
                Id,
                Relationship__r.Name
                FROM
                NettingGroupBranch__c
                WHERE
                NettingGroup__c =: nettingGroup.Id
                AND
                BranchType__c =: 'Bank'
            ];
        
        //add to set
        bankBranchIdSet = new Set<String>();
        bankBranchNameSet = new Set<String>();
        for(NettingGroupBranch__c lbl : existingdBankBranches)
        {
            bankBranchIdSet.add('"' + lbl.Relationship__r.Id + '"');
            bankBranchNameSet.add('"' + lbl.Relationship__r.Name + '"');
        }
        
        //Query existingdCounterpartyBranches to set picklist values  
        List<NettingGroupBranch__c> existingdCounterpartyBranches = 
            [
                SELECT
                Id,
                Relationship__r.Name
                FROM
                NettingGroupBranch__c
                WHERE
                NettingGroup__c =: nettingGroup.Id
                AND
                BranchType__c =: 'Counterparty'
            ];
        
        //add to set
        CounterpartyBranchIdSet = new Set<String>();
        CounterpartyBranchNameSet = new Set<String>();
        for(NettingGroupBranch__c lbl : existingdCounterpartyBranches)
        {
            CounterpartyBranchIdSet.add('"' + lbl.Relationship__r.Id + '"');
            CounterpartyBranchNameSet.add('"' + lbl.Relationship__r.Name + '"');
        }

        //Query existingTradeInstruments to set picklist values
        List<NettingGroupBranch__c> existingTradeInstruments =
        [
                SELECT
                        Id,
                        Trade_Instrument__r.Name
                FROM
                        NettingGroupBranch__c
                WHERE
                NettingGroup__c =: nettingGroup.Id
                AND
                BranchType__c =: 'Trade Instrument'
        ];

        //add to set
        TradeInstrumentBranchIdSet = new Set<String>();
        TradeInstrumentBranchNameSet = new Set<String>();
        for(NettingGroupBranch__c lbl : existingTradeInstruments)
        {
            TradeInstrumentBranchIdSet.add('"' + lbl.Trade_Instrument__r.Id + '"');
            TradeInstrumentBranchNameSet.add('"' + lbl.Trade_Instrument__r.Name + '"');
        }

        //amendmentPanel = false;
        nettingGroupPanel = true;
    }

    public PageReference setupSave(){
        return nettingSaveHelper();
    }
    
    public PageReference save()
    {
        isSaveAndNew = false;
        return setupSave();
    }

    public PageReference saveNew()
    {
        isSaveAndNew = true;
        return setupSave();
    }

    public PageReference deleteNettingGroup()
    {
        try {
            matter.Netting_Complete__c = false;
            update matter;

            delete nettingGroup;
            PageReference pr = new PageReference('/' + dealId);
            pr.setRedirect(true);
            return pr;
        }
        catch (Exception e){
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    //Method to insert netting insert/delete netting group branches and save record
    public PageReference nettingSaveHelper() {
        if(isNewRecord)
        {
            nettingGroup.id = null;
            insert nettingGroup;
        }

        //delete existing branches
        List<NettingGroupBranch__c> branchestoDelete = 
            [
                SELECT
                Id,
                Relationship__r.Name
                FROM
                NettingGroupBranch__c
                WHERE
                NettingGroup__c =: nettingGroup.Id
            ];
        
        //add all selected existing branches to lists to be inserted as Netting Group Branches
        for(String bank : selectedBankBranches)
        {
            NettingGroupBranch__c ngb1 = new NettingGroupBranch__c(NettingGroup__c = nettingGroup.Id, BranchType__c	= 'Bank', Relationship__c = bank);
            nettingGroupBranchesBank.add(ngb1);
        }
        
        for(String cp : selectedCounterparties)
        {
            NettingGroupBranch__c ngb2 = new NettingGroupBranch__c(NettingGroup__c = nettingGroup.Id, BranchType__c	= 'Counterparty', Relationship__c = cp);
            nettingGroupBranchesCP.add(ngb2);
        }

        for(String ti : selectedTradeInstruments)
        {
            NettingGroupBranch__c ngb3 = new NettingGroupBranch__c(NettingGroup__c = nettingGroup.Id, BranchType__c	= 'Trade Instrument', Trade_Instrument__c = ti);
            nettingGroupBranchesTI.add(ngb3);
        }

        try {
            //Check if combinations of netting type, bank / bank branches, counterparty / counterparty branches / disclosed principal and trade instrument have been added previously
            if(isDuplicates(nettingGroup, nettingGroupBranchesTI, true)){
                apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'A Trade Instrument: ' + duplicateTIName + ' of Netting Type: ' + nettingGroup.Netting_Type__c + ' has already been added in a previously added netting group: ' + duplicateNettingName));
                resetAfterError();
                return null;
            }

            if(!isNewRecord)
            {
                delete branchestoDelete;
            }

            matter.Netting_Complete__c = false;
            update matter;

            insert nettingGroupBranchesBank;
            insert nettingGroupBranchesCP;
            insert nettingGroupBranchesTI;

            stdController.save();

            if(!isSaveAndNew){
                PageReference pr = new PageReference('/' + dealId);
                pr.setRedirect(true);
                return pr;
            }
            else{
                PageReference pr = new PageReference('/apex/nettingGroup?new=true&dealid=' + dealId);
                pr.setRedirect(true);
                return pr;
            }
        }
        catch(exception e) {
            apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'There was an issue creating the netting group, please try again or contact a system administrator :' + e.getMessage() + e.getLineNumber()));
            return null;
        }
        
    }

    public void resetAfterError()
    {
        if(isNewRecord)
        {
            delete nettingGroup;
        }
        nettingGroupBranchesBank.clear();
        nettingGroupBranchesCP.clear();
        nettingGroupBranchesTI.clear();
    }

    public Boolean isDuplicates(Netting_Group__c currNetGroup, List<NettingGroupBranch__c> currBranches, Boolean isTradeInstrument){

        //Get all of the existing netting groups that exist for this matter
        List<Netting_Group__c> nettingGroups = [Select id, name, Netting_Type__c from Netting_Group__c where Matter_Deal__c = :dealId];

        //Get all of the existing netting group branches
        List<NettingGroupBranch__c> nettingGroupBranches = [Select id, Relationship__c, Relationship__r.Name, Trade_Instrument__c, Trade_Instrument__r.Name, NettingGroup__c, BranchType__c from NettingGroupBranch__c WHERE NettingGroup__c IN :nettingGroups];

        if(!nettingGroups.isEmpty() || nettingGroups != null){
            for(Netting_Group__c ng : nettingGroups){

                //Check that it doesn't validate against itself - for when editing netting group
                if(currNetGroup.id != ng.id){

                    if(currNetGroup.Netting_Type__c == ng.Netting_Type__c){

                        //Compare the netting group branch baing added to the existing ones
                        for(NettingGroupBranch__c ngb : nettingGroupBranches){

                            //If the netting group branch is a part of the netting group
                            if(ng.id == ngb.NettingGroup__c){
                                for(NettingGroupBranch__c cngb : currBranches){
                                    if(isTradeInstrument){
                                        //If the branch types are the same and the trade instruments are the same - then there is a duplicate
                                        if(cngb.BranchType__c == ngb.BranchType__c && cngb.Trade_Instrument__c == ngb.Trade_Instrument__c){
                                            duplicateNettingName = ng.Name;
                                            duplicateTIName = ngb.Trade_Instrument__r.Name;
                                            return true;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return false;
    }
	
    //Get Bank branches from Deal parties to build up multiselect picklist for Cross Bank field
    public List<Selectoption> getBankBranches(){

        List<Deal_Party__c> bankBranchList = 
            [
                SELECT
                Id,
                Relationship__r.Name
                FROM
                Deal_Party__c
                WHERE
                Deal__c =: dealId
                AND
                Relationship_Type__c =: 'Bank Branch'
            ];
        
        advpm__Matter__c matterBank = 
            [
                SELECT
                Id,
                Bank__c,
                Bank__r.Name
                FROM
                advpm__Matter__c
                WHERE
                Id =: dealId
                LIMIT 1
            ];

        List<Selectoption> bankBranchesSel = new List<selectoption>();
        for(Deal_Party__c dp : bankBranchList)
        {
			bankBranchesSel.add(new selectOption(dp.Relationship__r.Id, dp.Relationship__r.Name));
        }
		//Add Bank from Matter as default Cross Bank
		bankBranchesSel.add(new selectOption(matterBank.Bank__c, matterBank.Bank__r.Name));
        
        system.debug('bankBranchesSel: ' + bankBranchesSel);
        
        return bankBranchesSel; 
    }
    
    //Get Counterparties from Deal parties to build up multiselect picklist for Cross Counterparty field
    public List<Selectoption> getCounterparties(){

        List<Deal_Party__c> counterpartyList = 
            [
                SELECT
                Id,
                Relationship__r.Name
                FROM
                Deal_Party__c
                WHERE
                Deal__c =: dealId
                AND
                (Relationship_Type__c =: 'Counterparty Branch'
                OR
                Relationship_Type__c = 'Qualified Investor Hedge Fund'
                OR
                Relationship_Type__c = 'Retail Hedge Fund')
            ];
        
        List<advpm__Matter__c> matterCP = 
            [
                SELECT
                Id,
                Relationship__c,
                Relationship_Type_picklist__c,
                Relationship__r.Name
                FROM
                advpm__Matter__c
                WHERE
                Id =: dealId
                AND 
                Relationship_Type_picklist__c =: 'Counterparty'
                LIMIT 1
            ];

        advpm__Matter__c thisMatter =
        [
                SELECT
                        Id,
                        Relationship_Type_picklist__c
                FROM
                        advpm__Matter__c
                WHERE
                Id =: dealId
                limit 1
        ];

        List<Deal_Party__c> disclosedPrinciplesList = new List<Deal_Party__c>();

        if(thisMatter.Relationship_Type_picklist__c == 'Asset Manager'){
            disclosedPrinciplesList =
            [
                    SELECT
                            Id,
                            Relationship__r.Name
                    FROM
                            Deal_Party__c
                    WHERE
                    Deal__c =: dealId
                    AND
                    Relationship_Type__c =: 'Disclosed Principal'
            ];
        }
        
        List<Selectoption> counterpartiesSel = new List<selectoption>();

        if(!disclosedPrinciplesList.isEmpty() || disclosedPrinciplesList != null){
            for(Deal_Party__c disPrinc : disclosedPrinciplesList)
            {
                counterpartiesSel.add(new selectOption(disPrinc.Relationship__r.Id, disPrinc.Relationship__r.Name));
            }
        }

        for(Deal_Party__c dp : counterpartyList)
        {
			counterpartiesSel.add(new selectOption(dp.Relationship__r.Id, dp.Relationship__r.Name));
        }
        
        if(matterCP.size() > 0)
        {
        	counterpartiesSel.add(new selectOption(matterCP[0].Relationship__c, matterCP[0].Relationship__r.Name));   
        }
        
        return counterpartiesSel; 
    }

    //Get Trade Instruments from each Agreement to build up multiselect picklist for Trade Instrument field
    public List<Selectoption> getTradeInstruments(){

        Set<Id> tradeInstrumentIds = new Set<Id>();

        //Get all Trade Instruments
        Map<Id, Agreement__c> agreementList = new Map<Id, Agreement__c>([
                select
                        Id,
                        Agreement_Status__c
                FROM Agreement__c
                WHERE
                        Matter_Deal__c = :dealId]);

        Set<Id> agreementIds = agreementList.keySet();

        List<Agreement_Trade_Instrument__c> agreementTradeInstruments = [select Agreement__c, Trade_Instrument__c FROM Agreement_Trade_Instrument__c WHERE Agreement__c IN :agreementIds];

        for(Agreement_Trade_Instrument__c ati : agreementTradeInstruments)
        {
            tradeInstrumentIds.add(ati.Trade_Instrument__c);
        }

        List<Trade_Instrument__c> ti = [select id, name from Trade_Instrument__c WHERE Id IN :tradeInstrumentIds];

        List<Selectoption> tradeInstrumentSel = new List<selectoption>();
        for(Trade_Instrument__c tradeInstrument : ti)
        {
            tradeInstrumentSel.add(new selectOption(tradeInstrument.Id, tradeInstrument.Name));
        }

        return tradeInstrumentSel;
    }
}