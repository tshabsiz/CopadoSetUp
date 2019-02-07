/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 *** CHANGE LOG ***
 
 02/05/2017 - PG    - Cated initial class.
 21/06/2017 - PG    - Added "Other_Relative_Date__c" to getFullConditionRecords method.
                    - Removed "Realtive Start Date" from getFullConditionRecords.  
 26/06/2017 - PG    - Added "Signature" and "Effective" Date to getFullConditionRecords method.
 28/06/2017 - PG    - Add method "validateConditionParties_FYE" used in Condition trigger to check borrowers FYE date.
 30/06/2017 - PG    - Add method "validateDealParticipants" used in Condition trigger to check participants exist with TA role on deals.
 03/07/2017 - PG    - Remove field "Occurences__c" from getFullConditionRecords.
 21/08/2017 - PG    - Added 2 methods "beforeUpdate" && "checkAgreementStatus".
                    - Attempt to move to a logic-less trigger.  No further logic in Triggers! N.B!
 22/08/2017 - PG    - Added "conditionTypes" static variable for easy reference.  
                    - Added "validateParticipantRoles" method.
                    - Removed "validateDealParticipants" as it was replaced by more generic methods.  Now handles logic instead of trigger.
 28/08/2017 - PG    - Added methods "activateInsertedConditions" & "setupInsertActivation" to handle activating new conditions withput specifiyng the condition parties.               
 15/09/2017 - PG    - Replace "Superceded" with "Extension" in Code. 
 20/09/2017 - PG    - Added method "createConditionDocuments". 
                    - Updated "afterInsert" to use new "createConditionDocuments" method.
 02/10/2017 - PG    - Deleted "createConditionDocuments" method and removed from "afterInsert" trigger handler.  
 11/10/2017 - PG    - Added some additional SQL fields to getFullConditionRecords() method.
 16/11/2017 - PG    - Added "createConditionDocuments" method, needed for HotDocs integration.
 07/12/2017 - PG    - Optimised "validateParticipantRoles" method a bit.  There was an unnessasary IF.  Conslidated into main loop.
                    - Removed unused method "recordTypeNameById". 
                    - Removed unused method "recordTypeIdByName" and updated dependant classes. 
 08/12/2017 - PG    - Removed method "recordTypes". Updated reference to in other classes.
 23/01/2018 - TdB   - Add validateConditionsMonitoredBy();
 05/02/2018 - PG    - Fixed issue where "Transaction Manager" was used in validateConditionsMonitoredBy.  Needed to be api value "Transaction Management"
 14/02/2018 - TdB   - Add updateConditionPartiesAfterInsert() for when a condition changed to active upon edit
 
**/ 
public class Condition_Helper 
{    
    /**
    * Variables
    **/
    public static final Map<String, RecordTypeInfo> conditionTypes = new Map<String, RecordTypeInfo>(Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName()); 

    /**
    * Before Insert Trigger Handler
    **/
    public static void beforeInsert(List<Condition__c> inputNewList) 
    {
        setupInsertActivation(inputNewList);
    }

    /**
    * After Insert Trigger Handler
    **/
    public static void afterInsert(List<Condition__c> inputNewList) 
    {
        processInsertActivateLater(inputNewList);
        activateInsertedConditions(inputNewList);
        createConditionDocuments(inputNewList);
    }    

    /**
    * Before Update Trigger Handler
    **/
    public static void beforeUpdate(List<Condition__c> inputNewList, Map<Id, Condition__c> inputOldMap) 
    {
        checkAgreementStatus(inputNewList, inputOldMap);
        validateParticipantRoles(inputNewList, inputOldMap);
        validateConditionsMonitoredBy(inputNewList, inputOldMap);
    }

    /**
    * activateInsertedConditions - Activates conditions inserted as "Active" if needed.
    **/
    public static void activateInsertedConditions(List<Condition__c> inputNewList)
    {
        //Blank Variables
        List<Condition__c> conditions = new List<Condition__c>();
        Set<Id> conditionIds = new Set<Id>();
        List<Condition_Occurrence__c> conditionOccurrences = new List<Condition_Occurrence__c>();

        //Loop through inserted conditions.
        for(Condition__c condition : inputNewList)
        {
            if(condition.Active__c == true || condition.activate_later__c == true)
            {
                conditionIds.add(condition.Id);
            }
        }

        //Query full condition records.
        conditions = Condition_Helper.getFullConditionRecords(conditionIds); 

        //Make sure we have records.
        if(!conditions.isEmpty())        {

            //Retrieve all the occurrences needed for the conditions.
            conditionOccurrences = ConditionOccurrence_Helper.createOccurrences(conditions);
           
            //Did we need to insert any condition occurrences.
            if(!conditionOccurrences.isEmpty())
            {
                //Insert condition occurrence records.
                insert conditionOccurrences;
            }
        }
    }

    /**
    * processActivateLater - Adds condition parties to an "activate later" and activates it.
    **/
    public static void processInsertActivateLater(List<Condition__c> inputNewList)
    {
        //Blank vars.
        Set<Id> agreementIds = new Set<Id>();
        Map<Id, Agreement__c> agreements = new Map<Id, Agreement__c>();
        List<Condition__c> conditions = new List<Condition__c>();
        List<Condition_Party__c> conditionParties = new List<Condition_Party__c>();

        //Loop through inserted conditions. 
        for(Condition__c condition : inputNewList)
        {
            //Inserted as "Activate Later".
            if(condition.Active__c == false && condition.Activate_Later__c == true)
            {
                agreementIds.add(condition.Agreement__c);
            }
        }

        //Get a list of agreements and parties for the conditions.
        agreements = new Map<Id, Agreement__c>([
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Agreement__c,
                        Deal_Party__c
                    FROM Agreement_Parties__r
                )
            FROM Agreement__c
            WHERE
                Id IN :agreementIds 
        ]);

        //Loop through inserted conditions. 
        for(Condition__c condition : inputNewList)
        {
            //Inserted as "Activate Later".
            if(condition.Active__c == false && condition.Activate_Later__c == true)
            {
                //Agreement parties for the conditions agreement.
                List<Agreement_Party__c> agreementParties = agreements.get(condition.Agreement__c).Agreement_Parties__r;

                //Loop through agreement parties.
                for(Agreement_Party__c agreementParty : agreementParties)
                {
                    //New condition party.
                    Condition_Party__c conditionParty = new Condition_Party__c();
                    conditionParty.Condition__c = condition.Id;
                    conditionParty.Agreement_Party__c = agreementParty.Id;

                    //Add to insert list.
                    conditionParties.add(conditionParty);
                }      
            }
        }

        //Any condition parties to insert.
        if(!conditionParties.isEmpty())
        {
            insert conditionParties;
        }
    }

    /**
    * setupInsertActivation - Used when activating a newly inserted condition, handles the condition parties pre-check and value setup.
    **/
    public static void setupInsertActivation(List<Condition__c> inputNewList)
    {
        //Blank vars.
        Set<Id> agreementIds = new Set<Id>();
        Map<Id, Agreement__c> agreements = new Map<Id, Agreement__c>();

        //Loop through inserted conditions. 
        for(Condition__c condition : inputNewList)
        {
            //Inserted as "Active" with an Agreement.
            if(condition.Active__c == true && condition.Agreement__c != null)
            {
                agreementIds.add(condition.Agreement__c);
            }
        }

        //Get a list of agreements and parties for the conditions.
        agreements = new Map<Id, Agreement__c>([
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Agreement__c,
                        Deal_Party__c
                    FROM Agreement_Parties__r
                )
            FROM Agreement__c
            WHERE
                Id IN :agreementIds
        ]);

        //Loop through inserted conditions and make sure they have agreement parties before going further... 
        for(Condition__c condition : inputNewList)
        {
            //Inserted as "Active" with an Agreement.
            if(condition.Active__c == true && condition.Agreement__c != null)
            {
                //This would result in no parties for auto activation.
                if(agreements.get(condition.Agreement__c).Agreement_Parties__r.size() == 0)
                {
                    condition.addError('You may not insert this condition as "Active" because the associated agreement does not have any agreement parties defined.');
                }
                else
                {
                    //Clear the "Active" for now, and mark as later for party handling.
                    condition.Active__c = false;
                    condition.Activate_Later__c = true;
                }
            }
        }
    }
    
    /**
     * Returns full condition record fields for input ids.
    **/
    public static List<Condition__c> getFullConditionRecords(Set<Id> inputConditionIds)
    {
        //Blank list.
        List<Condition__c> conditions = new List<Condition__c>(); 

        //Query full condition records.
        conditions = [
            SELECT
                Id,
                Name,
                Active__c,
                Ready__c,
                Clause__c,
                Matter__c,
                Agreement__c,
                Agreement__r.Termination_Date__c, 
                Recurrence__c,
                Date__c,
                Number_Of_Days__c,
                Days__c,
                RecordTypeId,
                Due_Date__c,
                Other__c,
                Matter__r.Conditions_Occurrence_Monitoring__c,
                Status__c,
                Activation_Start__c,
                Activation_End__c,
                RecordType.Name,
                Other_Relative_Date__c,
                Signature_Date__c,
                Effective_Date__c,
                Forced_Update__c,
                (
                    SELECT
                        Id,
                        Name,
                        Relationship__c,
                        Financial_Year_End__c,
                        Agreement_Party__r.Id,
                        Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__r.advpm__Staff__r.Id,
                        Agreement_Party__r.Deal_Party__r.Relationship__c,
                        Agreement_Party__r.Deal_Party__r.Relationship__r.Name
                    FROM Condition_Parties__r
                ),
                (
                    SELECT
                        Id
                    FROM Conditions_Due__r
                )
            FROM Condition__c
            WHERE Id IN :inputConditionIds
        ];
        
        return conditions;
    }
    
    /**
     * Returns full condition record fields for input ids.
    **/
    public static Map<Id, String> validateConditionParties_FYE(Set<Id> inputConditionIds)
    {
        //Blank list.
        List<Condition__c> conditions = new List<Condition__c>(); 
        Map<Id, String> conditionsWithErrors = new Map<Id, String>();
        
        //Get the conditions and their condition parties.
        conditions = [
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        Financial_Year_End__c,
                        Relationship__c
                    FROM Condition_Parties__r
                )
            FROM Condition__c
            WHERE 
                Id IN :inputConditionIds
        ];
        
        //Loop through queried records.
        for(Condition__c condition : conditions)
        {
            //Loop through parties.
            for(Condition_Party__c conditionParty : condition.Condition_Parties__r)
            {
                //Blank FYE
                if(!conditionsWithErrors.containsKey(conditionParty.Id) && conditionParty.Financial_Year_End__c == null)
                {
                        //Add to map.
                        conditionsWithErrors.put(condition.Id, 'Please ensure all Condition Parties have a "Financial Year End" specified on the Relationship ('+conditionParty.Relationship__c+')');
                }
            }
        }
        
        //Return map.
        return conditionsWithErrors;
    }

    /**
    * checkAgreementStatus - Checks if the Condition is being activate on an agreement in an "Extension" status.
    **/
    public static void checkAgreementStatus(List<Condition__c> inputNewList, Map<Id, Condition__c> inputOldMap)
    {
        //Blank vars.
        Set<Id> agreementIds = new Set<Id>();
        Map<Id, Agreement__c> agreements = new Map<Id, Agreement__c>();

        //Loop through conditions.
        for(Condition__c condition : inputNewList)
        {
            //Condition was activated.
            if(condition.Active__c == true && inputOldMap.get(condition.Id).Active__c == false)
            {
                //Add to agreement id set.
                agreementIds.add(condition.Agreement__c);
            }
        }

        //We have agreement ids.
        if(!agreementIds.isEmpty())
        {
            agreements = new Map<Id, Agreement__c>([ 
                SELECT
                    Id,
                    Agreement_Status__c 
                FROM Agreement__c
                WHERE
                    Id IN :agreementIds
            ]);

            //Have agreement records.
            if(!agreements.isEmpty())
            {
                //Loop through conditions once again.
                for(Condition__c condition : inputNewList)
                {
                    if(agreements.containsKey(condition.Agreement__c))
                    { 
                        //Check if this conditions agreement is "Extension".
                        if(agreements.get(condition.Agreement__c).Agreement_Status__c == 'Extension')
                        {
                            //Add error on the record being activated.
                            condition.addError('You may not activate a condition on a "Extension" agreement.'); 
                        } 
                    }
                }
            }
            //If end.
        }
        //If end.
    }

    /**
    * validateParticipantRoles - Validates required participant roles for an activated condition based on condition type.
    **/
    
    public static void validateConditionsMonitoredBy(List<Condition__c> inputNewList, Map<Id, Condition__c> inputOldMap)
    {
        //Blank vars.
        Set<Id> matterIds = new Set<Id>();
        Map<Id, advpm__Matter__c> matters = new Map<Id, advpm__Matter__c>();
        
        //Loop through inbound conditions.
        for(Condition__c condition : inputNewList)
        {
            //Add to set.
            matterIds.add(condition.Matter__c); 
        }
        
        //Get the matters and participants for all conditions.
        matters = new Map<Id, advpm__Matter__c>([
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        Conditions_Monitored_By__c,
                      Conditions_Monitored_By__r.advpm__Role__c,
                        Deal__c
                    FROM Deal_Parties__r
                )
            FROM advpm__Matter__c
            WHERE
                Id IN :matterIds
        ]);

        //Loop through inbound conditions again.
        for(Condition__c condition : inputNewList)
        { 
            if(condition.Active__c == true && inputOldMap.get(condition.Id).Active__c == false)
            {
                Boolean requiredRoles = false;

                //Get all the participants for this conditions matter specifically.
                List<Deal_Party__c> dealParties = matters.get(condition.Matter__c).Deal_Parties__r;

                //Condition Precendent
                for(Deal_Party__c eachDealParty : dealParties)
                {
                    if(eachDealParty.Conditions_Monitored_By__c != null)
                    {
                        Set<String> participantRoles = new Set<String>(eachDealParty.Conditions_Monitored_By__r.advpm__Role__c.split(';'));

                        if(participantRoles.size() > 0)
                        {
                            if(condition.RecordTypeId == conditionTypes.get('Financial Covenant').getRecordTypeId() || condition.RecordTypeId == conditionTypes.get('General Undertaking').getRecordTypeId() || condition.RecordTypeId == conditionTypes.get('Information Undertaking').getRecordTypeId())
                            {
                                //Make sure we have a "TM" role.
                                if(participantRoles.contains('Transaction Administration') || participantRoles.contains('Transaction Management')  || participantRoles.contains('SPV') || participantRoles.contains('Agency'))
                                {
                                    requiredRoles = true;
                                }
                            }
                        }

                    }
                }

                //Make sure we found the required roles.
                if(requiredRoles == false)
                {
                    if(condition.RecordTypeId == conditionTypes.get('Financial Covenant').getRecordTypeId() || condition.RecordTypeId == conditionTypes.get('General Undertaking').getRecordTypeId() || condition.RecordTypeId == conditionTypes.get('Information Undertaking').getRecordTypeId())
                    {

                        condition.addError('Please ensure a Participant with a valid TMG Role is specified as the Conditions Monitored By on the Deal Party before activating the Condition.');
                    }
                }
            }            
        }
    }
    
    public static void validateParticipantRoles(List<Condition__c> inputNewList, Map<Id, Condition__c> inputOldMap)
    {
        //Blank vars.
        Set<Id> matterIds = new Set<Id>();
        Map<Id, advpm__Matter__c> matters = new Map<Id, advpm__Matter__c>();

        //Loop through inbound conditions.
        for(Condition__c condition : inputNewList)
        {
            //Add to set.
            matterIds.add(condition.Matter__c); 
        }

        //Get the matters and participants for all conditions.
        matters = new Map<Id, advpm__Matter__c>([
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        advpm__Role__c,
                        advpm__Matter__c
                    FROM advpm__Participants__r
                )
            FROM advpm__Matter__c
            WHERE
                Id IN :matterIds
        ]);

        //Loop through inbound conditions again.
        for(Condition__c condition : inputNewList)
        {   
            //Only execute if the condition was Activated.
            if(condition.Active__c == true && inputOldMap.get(condition.Id).Active__c == false)
            {
                Boolean requiredRoles = false;

                //Get all the participants for this conditions matter specifically.
                List<advpm__Participant__c> participants = matters.get(condition.Matter__c).advpm__Participants__r;

                //Condition Precendent
                for(advpm__Participant__c participant : participants)
                {
                    if(participant.advpm__Role__c != null)
                    {
                        Set<String> participantRoles = new Set<String>(participant.advpm__Role__c.split(';'));

                        if(participantRoles.size() > 0)
                        {
                            if(condition.RecordTypeId == conditionTypes.get('Condition Precedent').getRecordTypeId() || condition.RecordTypeId == conditionTypes.get('Governance Check').getRecordTypeId())
                            {
                                //Make sure we have a "TA" role.
                                if(participantRoles.contains('Transaction Administration') || participantRoles.contains('Agency'))
                                {
                                    requiredRoles = true;
                                }
                            }
                        }
                    }
                }

                //Make sure we found the required roles.
                if(requiredRoles == false)
                {
                    if(condition.RecordTypeId == conditionTypes.get('Condition Precedent').getRecordTypeId() || condition.RecordTypeId == conditionTypes.get('Governance Check').getRecordTypeId())
                    {
                        condition.addError('Please ensure a participant with the role "Transaction Administrator" or "Agency" is specified on the Deal before activating this Condition.');
                    }
                }
            }
            //If end.
        }
    }

    /**
    * createConditionDocuments - Insert document for the condition that originate from the condition template.
    **/
    public static void createConditionDocuments(List<Condition__c> inputNewList)
    {
        Set<Id> conditionTemplateIds = new Set<Id>();
        Map<Id, Condition_Template__c> conditionTemplates = new Map<Id, Condition_Template__c>();
        List<Condition_Document__c> conditionDocuments = new List<Condition_Document__c>();

        //Unique list of condition templates.
        for(Condition__C condition : inputNewList)
        {
            if(condition.Condition_Template__c != null)
            {
               conditionTemplateIds.add(condition.Condition_Template__c);
            }
        }

        //Fetch templates and documents.
        conditionTemplates = new Map<Id, Condition_Template__c>([
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        Name,
                        Document_Type__c
                    FROM Document_Templates__r
                )
            FROM Condition_Template__c
            WHERE
                Id IN :conditionTemplateIds
        ]);

        //Loop over condition against to build insert list.
        for(Condition__C condition : inputNewList)
        {
            if(conditionTemplates.containsKey(condition.Condition_Template__c))
            {
                for(Document_Template__c template : conditionTemplates.get(condition.Condition_Template__c).Document_Templates__r)
                {   
                    //Add to insert list.
                    conditionDocuments.add(new Condition_Document__c(Condition__c = condition.Id, Name = template.Name, Document_Type__c = template.Document_Type__c));
                }
            }
        }

        //Anything to insert.
        if(!conditionDocuments.isEmpty())
        {
            insert conditionDocuments;
        }        
    }
    
    public static void updateConditionPartiesAfterInsert(List<Condition__c> inputNewList)
    {
        //Blank vars.
        Set<Id> agreementIds = new Set<Id>();
        Set<Id> conditionIds = new Set<Id>();
        Map<Id, Agreement__c> agreements = new Map<Id, Agreement__c>();
        List<Condition__c> conditions = new List<Condition__c>();
        List<Condition_Party__c> conditionParties = new List<Condition_Party__c>();
        List<Condition_Party__c> existingConditionParties = new List<Condition_Party__c>();

        //Loop through inserted conditions. 
        for(Condition__c condition : inputNewList)
        {
        	agreementIds.add(condition.Agreement__c);
            conditionIds.add(condition.Id);
        }

        //Get a list of agreements and parties for the conditions.
        agreements = new Map<Id, Agreement__c>([
            SELECT
                Id,
                Name,
                (
                    SELECT
                        Id,
                        Agreement__c,
                        Deal_Party__c
                    FROM Agreement_Parties__r
                )
            FROM Agreement__c
            WHERE
                Id IN :agreementIds 
        ]);

        //Loop through inserted conditions. 
        for(Condition__c condition : inputNewList)
        {
            //Agreement parties for the conditions agreement.
            List<Agreement_Party__c> agreementParties = agreements.get(condition.Agreement__c).Agreement_Parties__r;
            
            //Loop through agreement parties.
            for(Agreement_Party__c agreementParty : agreementParties)
            {
                //New condition party.
                Condition_Party__c conditionParty = new Condition_Party__c();
                conditionParty.Condition__c = condition.Id;
                conditionParty.Agreement_Party__c = agreementParty.Id;
                
                //Add to insert list.
                conditionParties.add(conditionParty);
            }      
        }
        
        //Get existing Condition Parties
        existingConditionParties = [SELECT Id, Condition__c FROM Condition_Party__c WHERE Condition__c IN :conditionIds];

        //Any condition parties to insert.
        if(!conditionParties.isEmpty())
        {
            insert conditionParties;
        }
        
        //Any condition parties to delete
        if(!existingConditionParties.isEmpty())
        {
            delete existingConditionParties;
        }
    }
}