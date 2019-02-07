/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

**/
trigger Agreement_Trigger on Agreement__c (before update, before insert, after update, after insert, before delete) 
{
    System.debug('### Agreement_Trigger START');

    List<Agreement__c> libraAgreementList = new  List<Agreement__c>();
    Map<String, Schema.RecordTypeInfo> agreementRecordTypeMap = Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 

    if(checkRecursion.canIRun() == True)
    {
        //After Insert context
        if(Trigger.isAfter && Trigger.isInsert)
        {
            Agreement_Helper.afterInsert(Trigger.new);
        }
        //After Insert context End.
        
        //AFTER context.
        if(Trigger.isAfter)
        {
            //AFTER UPDATE context.
            if(Trigger.isUpdate)
            {   
                //Blank Set.
                Set<Id> agreementIds = new Set<Id>();
                Set<Id> extendedAgreements = new Set<Id>();
                List<Condition__c> conditions = new List<Condition__c>();
                
                //Loop through updated agreements.
                for(Agreement__c agreement : Trigger.new)
                {
                    //Get the accounts previous state.
                    Agreement__c oldAgreement = Trigger.oldMap.get(agreement.Id); 
                    
                    //Signature Date OR Effective Date Changed?
                    if(agreement.Signature_Date__c != null && (oldAgreement.Signature_Date__c != agreement.Signature_Date__c) || agreement.Effective_Date__c != null && (oldAgreement.Effective_Date__c != agreement.Effective_Date__c))
                    {
                        //Add id to set.
                        agreementIds.add(agreement.Id);
                    }
                    
                    if(agreement.Agreement_Status__c == 'Extension' && oldAgreement.Agreement_Status__c != 'Extension')
                    {
                        extendedAgreements.add(agreement.Id);
                    }
                }
                
                //Flags conditions that a reliant on this field as needing rescheduling.
                conditions = ConditionOccurrence_Helper.relativeDateChanged(agreementIds, 'Agreement');  
                
                //We have any records to update.
                if(!conditions.isEmpty())
                {
                    for(Condition__c condition : conditions)
                    {
                        //Set update flag to true so they get reschduled.
                        condition.Forced_Update__c = DateTime.now();
                    }
                    
                    //Update conditions
                    update conditions;
                }
                
                if(!extendedAgreements.isEmpty())
                {
                    Agreement_Helper.deactivateConditions(extendedAgreements);
                }
                
                Agreement_Helper.updateWatcherOccurence(Trigger.OldMap, Trigger.NewMap);
                
            }
            //AFTER UPDATE context.
            if(Trigger.isInsert){
                Agreement_Helper.defaultClauses(Trigger.new);
            }
        }
        //AFTER context. 
        
        if(Trigger.isBefore ) 
        {
            if(Trigger.isInsert || Trigger.isUpdate)
            {            
                for(Agreement__c eachAgreement : Trigger.new)
                {
                    //Only add Agreement to list if Record Type is GMRA/GMSLA/ISDA or Prime Services
                    if(eachAgreement.Relationship_Type__c != 'Asset Manager' && eachAgreement.RecordTypeId == agreementRecordTypeMap.get('GMRA Agreement').getRecordTypeId())
                    {
                        libraAgreementList.add(eachAgreement);
                    } 
                    else if(eachAgreement.RecordTypeId == agreementRecordTypeMap.get('Prime Services Agreement').getRecordTypeId() ) {

                        //Only add agreement temaplates for these relationship type scenarios.
                        if(eachAgreement.Relationship_Type__c == 'Collective Investment Scheme Manager') {
                            libraAgreementList.add(eachAgreement);
                        }
                        else if(eachAgreement.Relationship_Type__c == 'Counterparty' && eachAgreement.Prime_Services_Client__c == 'No') {
                             libraAgreementList.add(eachAgreement);
                        }
                    }
                    else if(eachAgreement.RecordTypeId == agreementRecordTypeMap.get('GMSLA Agreement').getRecordTypeId() || eachAgreement.RecordTypeId == agreementRecordTypeMap.get('ISDA Agreement').getRecordTypeId())
                    {
                        libraAgreementList.add(eachAgreement);
                    }
                }
                
                //Call agreementTemplateAssignment() method to assign the correct Agreement Template based on Agreement Type and Version
                if(!libraAgreementList.isEmpty()) 
                {
                    Agreement_Helper.agreementTemplateAssignment(libraAgreementList);
                }
                
                //INSERT OR AFTER CONTEXT
                Boolean isMarketTransaction = false;

                if(Trigger.isInsert) {

                    for(Agreement__c a : Trigger.new)
                    {
                        advpm__Matter__c matter = new advpm__Matter__c();
                        matter.RecordTypeId = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Market Transaction').getRecordTypeId();
                        
                        advpm__Matter__c matterPrimeServices = new advpm__Matter__c();
                        matterPrimeServices.RecordTypeId = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Market Transaction - Prime Services').getRecordTypeId();
                        
                        try {
                            advpm__Matter__c agreementMatter = [SELECT Id, RecordTypeId FROM advpm__Matter__c WHERE id = :a.Matter_Deal__c LIMIT 1];
                        
                            if(matter.RecordTypeId == agreementMatter.RecordTypeId || matterPrimeServices.RecordTypeId == agreementMatter.RecordTypeId) {
                                isMarketTransaction = true;
                            }
                        }
                        catch(Exception e) {
                            System.debug('No matter exists with type of Agreement: ' + e.getMessage());
                        }
                    }
                    
                    if(isMarketTransaction)
                    {                    
                        Set<id> MatterIdSet = new  set<id>();
                        
                        List<agreement__c> MatterAgreements = new List<agreement__c>();

                        for(Agreement__c agg : Trigger.new) {
                            MatterIdSet.add(agg.Matter_Deal__c);
                        }

                        MatterAgreements =  [select Id, RecordTypeId,Matter_Deal__c from agreement__c where Matter_Deal__c in :MatterIdSet];
                        Set<Agreement__c> appeared = new Set<Agreement__c>();

                        for(Agreement__c primaryAgreementRec : Trigger.new)
                        {
                            for (Agreement__c agreementRecToCheck : MatterAgreements)
                            {
                                if (primaryAgreementRec.RecordTypeId == agreementRecToCheck.RecordTypeId && primaryAgreementRec.Matter_Deal__c == agreementRecToCheck.Matter_Deal__c)
                                {
                                    primaryAgreementRec.addError('An Agreement of this type has already been added to this Market Transaction and cannot be added again! Please select another Master Agreement Type');
                                }
                            }
                        }
                    }
                }
            }
            //Through error when User attempts to delete Agreement that where auto created from a Deal
            else if (Trigger.isDelete)
            {
                for(Agreement__c eachAgreement : Trigger.old)
                {
                    if(eachAgreement.hAuto_Created__c == True)
                    {
                        eachAgreement.AddError('You are not allowed to delete the Agreement, please contact your Salesforce Administrator');
                    }
                }
            }
        }
    }
    System.debug('### Agreement_Trigger END');
}