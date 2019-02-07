/*=============================================
*@CreatedDate :2018-07-25
*@CreatedBy : Mabhedle Tonga 
*@Description : Rest function that gets matter and related entities with the agreement status of Confirmed/Completed or Amended
===============================================*/
@RestResource(urlMapping='/master/*')
global class Libra_Restful_Master {
    
    @HttpPost
    global static void getMaster()
    {
        String requestBody = RestContext.request.requestBody.toString();
        try
        {
            If(String.isNotBlank(requestBody))
            {
                LibraRestfulModel.RootObject newMaster = new LibraRestfulModel.RootObject();
                Libra_Restul_Functions.MatterWrapper matter =(Libra_Restul_Functions.MatterWrapper)JSON.deserialize(requestBody,Libra_Restul_Functions.MatterWrapper.class);
                
                if(String.isNotBlank(matter.matterId))
                {
                    List<advpm__Matter__c> matterDealList = Libra_Restul_Functions.getSObjectById(matter.matterId,Libra_Restful_Constants.MatterColumns,Libra_Restful_Constants.MatterObject);
                    
                    if(matterDealList!=null && matterDealList.size()>0)
                    {
                    String additionalClause = '  Agreement_Status__c IN (\'Confirmed/Completed\',\'Amended\')';
                        List<Agreement__c> agreementList = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.AgreementColumns,Libra_Restful_Constants.AgreementObject,' Where Matter_Deal__c = \''+matter.matterId+'\' AND '+ additionalClause);
                    	boolean checkSupportingAgreementforMarketCollateral = false,checkAgreementforMarketCollateral = false;
                        for(Agreement__c agreement: agreementList){
                            if(agreement.recordType.Name.equalsIgnoreCase('ISDA Agreement'))
                                checkSupportingAgreementforMarketCollateral = true;
                            
                            if(agreement.recordType.Name.equalsIgnoreCase('GMRA Agreement') || agreement.recordType.Name.equalsIgnoreCase('GMSLA Agreement'))
                                checkAgreementforMarketCollateral = true;
                            
                            newMaster.Agreements.add(new LibraRestfulModel.Agreement(agreement));
                        }
                           
                        List<Supporting_Agreement__c>  supportingAgreement = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.SupportingAgreementColumns,Libra_Restful_Constants.SupportingAgreementObject,' Where Agreement__c IN ' +Libra_Restul_Functions.listToString(agreementList));
                    	
                        for(Supporting_Agreement__c SA: supportingAgreement)
                        	newMaster.SupportingAgreements.add(new LibraRestfulModel.SupportingAgreement(SA));
                        
                        List<Jurisdiction__c> Jurisdictions = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.JurisdictionColumns,Libra_Restful_Constants.JurisdictionObject,' Where Matter__c = \''+matter.matterId+'\'');
                        for(Jurisdiction__c j:Jurisdictions)
                        	newMaster.Jurisdictions.add(new LibraRestfulModel.Jurisdiction(j));
                        
                        List<advpm__Participant__c> Participants = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.ParticipantColumns,Libra_Restful_Constants.ParticipantObject,' Where advpm__Matter__c = \''+matter.matterId+'\'');
                    	for(advpm__Participant__c p:Participants)
                        	newMaster.Participants.add(new LibraRestfulModel.Participant(p));
                        
                        List<Deal_Party__c> DealParties = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.DealPartyColumns,Libra_Restful_Constants.DealPartyObject,' Where Deal__c = \''+matter.matterId+'\'');
                    	for(Deal_Party__c dp: DealParties)
                        	newMaster.DealParties.add(new LibraRestfulModel.DealParty(dp));
                        
                        List<Netting_Group__c> NettingGroups = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.NettingGroupColumns,Libra_Restful_Constants.NettingGroupObject,' Where Matter_Deal__c = \''+matter.matterId+'\'');
                        Set<ID> NettingGroupIDSet = new Set<ID>();
                        for(Netting_Group__c ng:NettingGroups){
                        	newMaster.NettingGroups.add(new LibraRestfulModel.NettingGroup(ng));
                            NettingGroupIDSet.add(NG.ID);
                        }
                        
                        Map<ID,List<NettingGroupBranch__c >> BranchPerNettingGroupMap =Libra_Restul_Functions.getBranchPerNettingGroup(Libra_Restul_Functions.getNettingGroupBranchByIdSet(NettingGroupIDSet));
                        
                        for(ID varID :NettingGroupIDSet)
                        {
                            Map<String,List<NettingGroupBranch__c >> BranchPerNettingGroupMap2= Libra_Restul_Functions.getNettingGroupbranch(BranchPerNettingGroupMap.get(varID));
                            if(BranchPerNettingGroupMap2.containsKey('Bank')){
                                for(NettingGroupBranch__c bankBranch :BranchPerNettingGroupMap2.get('Bank')){
                                    if(BranchPerNettingGroupMap2.containsKey('Counterparty'))
                                    {
                                        for(NettingGroupBranch__c counterPartyBranch :BranchPerNettingGroupMap2.get('Counterparty')){
                                            if(BranchPerNettingGroupMap2.containsKey('Trade Instrument')){
                                                for(NettingGroupBranch__c tradeInstruBranch :BranchPerNettingGroupMap2.get('Trade Instrument')){
                                                    newMaster.NettingGroupBranches.add(new LibraRestfulModel.NettingGroupBranch(tradeInstruBranch,counterPartyBranch,bankBranch));
                                                }
                                            } 
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        List<Agreement_Clause__c>AgreementClause = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.AgreementClauseColumns,Libra_Restful_Constants.AgreementClauseObject,' Where Agreement__c IN '+Libra_Restul_Functions.listToString(agreementList));
                        Set<ID> ClauseIdSet = new Set<Id>();
                        
                        for(Agreement_Clause__c ag: AgreementClause)
                        {
                            newMaster.agreementClauses.add(new LibraRestfulModel.AgreementClause(ag));
                            ClauseIdSet.add(ag.Clause__c);
                        }
                       /* for(Clause__c c:Libra_Restul_Functions.getClauseByIdSet(ClauseIdSet)){
                            newMaster.Clause.add(new LibraRestfulModel.Clause(c));
                        }*/
                        
                        List<Agreement_Trade_Instrument__c> AgreementTradeInstruments = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.AgreementTradeInstrumentColumns,Libra_Restful_Constants.AgreementTradeInstrumentObject,' Where Agreement__c IN '+Libra_Restul_Functions.listToString(agreementList));
                        
                        Set<ID> agreementTradeInstrumentSet = new Set<Id>();
                        for(Agreement_Trade_Instrument__c art: AgreementTradeInstruments)
                        {
                            newMaster.AgreementTradeInstruments.add(new LibraRestfulModel.AgreementTradeInstrument(art));
                            agreementTradeInstrumentSet.add(art.Trade_Instrument__c);
                        }
                        
                       /* for(Trade_Instrument__c TI:Libra_Restul_Functions.getTradeInstrumentByIdSet(agreementTradeInstrumentSet))
                        {
                            newMaster.TradeInstruments.add(new LibraRestfulModel.TradeInstrument(TI));
                        }*/
                        
                       List<Market_Collateral__c>  MarketCollateral = new List<Market_Collateral__c>();
                        
                        if(checkSupportingAgreementforMarketCollateral)
                            MarketCollateral = Libra_Restul_Functions.getmarketCollateralOnSupportingAgreement(matter.matterId);    
                        
                        if(checkAgreementforMarketCollateral)
                            MarketCollateral.addAll(Libra_Restul_Functions.getmarketCollateralOnAgreement(matter.matterId));
                        
                        for(Market_Collateral__c m: MarketCollateral)
                    		newMaster.MarketCollateral.add(new LibraRestfulModel.MarketCollateral(m));


                        List<Amendment__c> matterAmendment = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.AmendmentColumns,Libra_Restful_Constants.AmendmentObject,' Where Matter__c = \''+matter.matterId+'\'');
						
                        for(Amendment__c a : matterAmendment)
                            newMaster.matterAmendments.add(new LibraRestfulModel.Ammendment(a));
                        
                        List<Amendment__c> agreementAmendment = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.AmendmentColumns,Libra_Restful_Constants.AmendmentObject,' Where Agreement__c IN '+Libra_Restul_Functions.listToString(agreementList));
						
                        for(Amendment__c a : agreementAmendment)
                            newMaster.agreementAmendments.add(new LibraRestfulModel.Ammendment(a));
                        
                        List<Amendment__c> supportingAgreementAmendment = Libra_Restul_Functions.getSObjectByMatterId(matter.matterId,Libra_Restful_Constants.AmendmentColumns,Libra_Restful_Constants.AmendmentObject,' Where Supporting_Agreement__c IN '+Libra_Restul_Functions.listToString(supportingAgreement));
						
                        for(Amendment__c a : supportingAgreementAmendment)
                            newMaster.supportingAgreementAmendment.add(new LibraRestfulModel.Ammendment(a));
                        
                    }
                 
                    newMaster.Matter = new LibraRestfulModel.Matter(matterDealList[0]);
                    RestContext.response.responseBody = Blob.valueOf(JSON.serialize(newMaster));
                }
            }
        }
        catch(StringException eex)
        {
            RestContext.response.responseBody = Blob.valueOf(Libra_Restful_Constants.NotFound);
            RestContext.response.statusCode =Libra_Restful_Constants.statusCodeNotFound;
        }catch(QueryException qe)
        {
            RestContext.response.responseBody = Blob.valueOf(qe.getMessage());
            RestContext.response.statusCode =400;
        }
    }
    
   
}