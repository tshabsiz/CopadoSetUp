/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 25/04/2017 - PG    - Created initial class.
 20/06/2017 - PG    - Added logic to Once off and Relative date for mulitple borrowers / condition parties.
                    - Changed the way start and end date function work.  Takes additional condition party as param.
 21/06/2017 - PG    - Updated "relativeDateChanged" method to handle multiple borrowers.   FYE field no longer used in query.
                    - Removed all reference to old "FYE" field on Condition so I can delete the field. Now on borrower
                    - Added "Other Relative Date" to occurrrence generator logic.
                    - Removed all reference to "Relative Start Date" field on condition.
 29/06/2017 - PG    - Added method "buildConditionPartiesText".  Used to consolidate all the relationships into a text string for CP's and GC's.
                    - Added method "determineResponsiblePerson". Used to detemine the responsible person for monitoring from the deal participants.
                    - Added method "deletedConditionPartyIds" to facilitate delete occurrences for a removed condition party.
 03/07/2017 - PG    - inputCondition.Conditions_Due__r.size() add to buildConditionOccurences.
 04/07/2017 - IV    - Added "shouldUpdateOccurances" and  "updateOccuranceTreshold" to handle required FC fields to propagate to occurrences.
 05/07/2017 - PG    - Added comments to Ivan 2 methods.
                    - Removed obselete method "insertOccurrences" method.   Was an @future method used in troubleshooting on the 3rd July.
                    - Added logic for Activation Period in FC's.
 13/09/2017 - PG    - Removed "Update Schedule" field from some methods.
                    - Added specific status of Condition Occurrences not to be delete when deactivating a condition. See "deactivateConditions".
 14/09/2017 - PG    - Remove method "conditionPartiesOccurrences".  Moved it to condition party helper class.
 20/09/2017 - PG    - Added "beforeInsert" and "afterInsert" trigger handle methods.
 20/09/2017 - PG    - Added "createOccurrenceDocuments" method.
 02/10/2017 - PG    - Modified "createOccurrenceDocuments" to work directly off condition template instead of condition & occurrence documents object.  
 09/10/2017 - PG    - Added "beforeUpdate" trigger handler.
                    - Added method "checkFieldChanges" to track is a occurrence data was updated.
                    - Modifed "deactivateConditions" to take box document, activity and modified flags into consideration when deleting future occurrences.
                    - Added new method "getFutureOccurrences".  
                    - Refactored "deactivateCondition" to use the above method.
 02/11/2017 - PG    - Added "Other__c" to Ivans threshold methods.
 08/11/2017 - TdB   - Add validateSupportDocumentsUploaded method
 16/11/2017 - PG    - Updated method "createOccurrenceDocument" to use "Condition Document" instead of via the conditions assoc template.  Needed for HotDocs.
 07/12/2017 - PG    - Removed some debug output in weird places.
 18/01/2018 - TdB   - Change Person Responsible from User to Participant. Add Participant User for the User linked to Participant
					- Add functionality to not flag occurrence as modified if the Deal1__c value change 
 20/02/2018 - TdB   - Update conditions required to cater for decimal places as well

**/ 
public class ConditionOccurrence_Helper 
{
    /**
     * Variables
    **/
   
    //Custom Settings
    public static ConditionSchedulingSettings__c settings = ConditionSchedulingSettings__c.getInstance('Default');
    
    //Scheduling Period
    public static Date periodEndDate    = Date.today().addMonths(settings.Months_In_Advance__c.intValue());
    public static Id businessHoursId    = [SELECT Id FROM BusinessHours WHERE Name = :settings.Business_Hours__c].Id;
   
    //Record Type Info
    public static Schema.DescribeSObjectResult occurrenceDescribe = Schema.SObjectType.Condition_Occurrence__c;
    public static Map<String,Schema.RecordTypeInfo> OCCURRENCE_TYPES = occurrenceDescribe.getRecordTypeInfosByName();
    public static Map<String, Schema.SObjectField> occurrenceFields = Schema.SObjectType.Condition_Occurrence__c.fields.getMap();
   
    //Only used in generatoring CP and GC occurrences.
    public static Map<Id, Map<String,Id>> responsiblePeople = new Map<Id, Map<String,Id>>();

    //Hold future existing occurrences.
    public static Map<Id, Condition_Occurrence__c> existingFutureOccurrences = new Map<Id, Condition_Occurrence__c>();
    
    /**
    * After Insert Trigger Handler
    **/
    public static void afterInsert(List<Condition_Occurrence__c> inputNewList) 
    {
        createOccurrenceDocuments(inputNewList);
    }

    /**
    * Before Update Trigger Handler
    **/
    public static void beforeUpdate(List<Condition_Occurrence__c> inputNewList, Map<Id, Condition_Occurrence__c> inputOldMap) 
    {
        checkFieldChanges(inputNewList, inputOldMap);
    }

    /**
     * createOccurrences - Main method call by trigger to generate condition occurrences.
    **/
    public static List<Condition_Occurrence__c> createOccurrences(List<Condition__c> inputConditions)
    {
        System.debug('### ConditionOccurrence_Helper : createOccurrences');
       
        //Blank list.
        List<Condition_Occurrence__c> conditionOccurrencesToInsert = new List<Condition_Occurrence__c>();
       
        //Populate responsible for CP's and GC's.
        responsiblePeople = determineResponsiblePerson(inputConditions);

        //Get existing future condition occurrences.
        existingFutureOccurrences = getFutureOccurrences(inputConditions);
       
        //Loop through conditions passed.
        for(Condition__c inputCondition : inputConditions)
        {
            //Blank list.
            List<Condition_Occurrence__c> inputConditionOccurrences = new List<Condition_Occurrence__c>();
       
            //Get occurrences needed for the condition.
            inputConditionOccurrences = createConditionOccurrences(inputCondition); 
           
            //Add condition occurrence for the current condition to the main returned list.
            conditionOccurrencesToInsert.addAll(inputConditionOccurrences);
        }
 
        //Default return.
        return conditionOccurrencesToInsert;
    }
   
    /**
     * createConditionOccurrences - Gets the the condition occurrences for a specific condition only.
    **/
    public static List<Condition_Occurrence__c> createConditionOccurrences(Condition__c inputCondition)
    {
        //Blank List.
        List<Condition_Occurrence__c> conditionOccurrences = new List<Condition_Occurrence__c>();

        //NON-SCHEDULED
        if(inputCondition.Recurrence__c == null && inputCondition.Due_Date__c == null)
        {
            System.debug('### ConditionOccurrence_Helper : createConditionOccurrences : NON-SCHEDULED');

            //Build occurrences.
            conditionOccurrences    = buildConditionOccurences(inputCondition, 'NON-SCHEDULED');
        }
       
        //ONCE-OFF-DUE-DATE
        if(inputCondition.Recurrence__c == 'Once Off' && String.isBlank(inputCondition.Date__c) && inputCondition.Due_Date__c != null)
        {
            System.debug('### ConditionOccurrence_Helper : createConditionOccurrences : ONCE-OFF-DUE-DATE');
           
            //Build occurrences.
            conditionOccurrences    = buildConditionOccurences(inputCondition, 'ONCE-OFF-DUE-DATE');
        }
       
        //ONCE-OFF-RELATIVE-DATE
        if(inputCondition.Recurrence__c == 'Once Off' && !String.isBlank(inputCondition.Date__c) && inputCondition.Due_Date__c == null)
        {
            System.debug('### ConditionOccurrence_Helper : createConditionOccurrences : ONCE-OFF-RELATIVE-DATE');
            
            //Build occurrences.
            conditionOccurrences    = buildConditionOccurences(inputCondition, 'ONCE-OFF-RELATIVE-DATE');
        }
       
        //RECURRING-RELATIVE-DATE
        if(inputCondition.Recurrence__c != 'Once Off' && !String.isBlank(inputCondition.Date__c) && inputCondition.Due_Date__c == null)
        {
            System.debug('### ConditionOccurrence_Helper : createConditionOccurrences : RECURRING-RELATIVE-DATE');
            
            //Build occurrences.
            conditionOccurrences    = buildConditionOccurences(inputCondition, 'RECURRING-RELATIVE-DATE');
        }
       
        //Default return.
        return conditionOccurrences;
    }
   
    /**
     * calculateStartDate - Detemines the START date for a relative date condition.
    **/
    public static Date calculateStartDate(Condition__c inputCondition, String inputRecurrenceType, Condition_Party__c inputConditionParty)
    {
        Date startDate = null;
       
        //ONCE-OFF-DUE-DATE
        if(inputRecurrenceType == 'ONCE-OFF-DUE-DATE')
        {
            //Specified Due Date.
            startDate = inputCondition.Due_Date__c;
        }
       
        //ONCE-OFF-RELATIVE-DATE
        if(inputRecurrenceType == 'ONCE-OFF-RELATIVE-DATE')
        {
            if(inputCondition.Date__c == 'Signature Date')
            {
                startDate = inputCondition.Days__c == 'Days Before' ? inputCondition.Signature_Date__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputCondition.Signature_Date__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
           
            if(inputCondition.Date__c == 'Effective Date')
            {
                startDate = inputCondition.Days__c == 'Days Before' ? inputCondition.Effective_Date__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputCondition.Effective_Date__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
           
            if(inputCondition.Date__c == 'Financial Year End')
            {
                startDate = inputCondition.Days__c == 'Days Before' ? inputConditionParty.Financial_Year_End__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputConditionParty.Financial_Year_End__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
           
            if(inputCondition.Date__c == 'Other')
            {
                startDate = inputCondition.Days__c == 'Days Before' ? inputCondition.Other_Relative_Date__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputCondition.Other_Relative_Date__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
        }
       
        //RECURRING-RELATIVE-DATE
        if(inputRecurrenceType == 'RECURRING-RELATIVE-DATE')
        {
           
            if(inputCondition.Date__c == 'Signature Date')
            {
                startDate = inputCondition.Days__c == 'Days Before' ? inputCondition.Signature_Date__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputCondition.Signature_Date__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
           
            if(inputCondition.Date__c == 'Effective Date')
            {
                startDate = inputCondition.Days__c == 'Days Before' ? inputCondition.Effective_Date__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputCondition.Effective_Date__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
           
            if(inputCondition.Date__c == 'Financial Year End')
            {
                 startDate = inputCondition.Days__c == 'Days Before' ? inputConditionParty.Financial_Year_End__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputConditionParty.Financial_Year_End__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
           
            if(inputCondition.Date__c == 'Other')
            {
                startDate = inputCondition.Days__c == 'Days Before' ? inputCondition.Other_Relative_Date__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputCondition.Other_Relative_Date__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
        }
       
        //System.debug('### ConditionOccurrence_Helper : calculateStartDate : startDate : '+startDate);
       
        //Return
        return startDate;
    }
   
    /**
     * calculateEndDate - Detemines the END date for a relative date condition.
    **/
    public static Date calculateEndDate(Condition__c inputCondition, String inputRecurrenceType, Condition_Party__c inputConditionParty)
    {
        Date endDate = null;
       
        //ONCE-OFF-DUE-DATE
        if(inputRecurrenceType == 'ONCE-OFF-DUE-DATE')
        {
            endDate = inputCondition.Due_Date__c;
        }
       
        //ONCE-OFF-RELATIVE-DATE
        if(inputRecurrenceType == 'ONCE-OFF-RELATIVE-DATE')
        {
            if(inputCondition.Date__c == 'Signature Date')
            {
                endDate = inputCondition.Days__c == 'Days Before' ? inputCondition.Signature_Date__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputCondition.Signature_Date__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
           
            if(inputCondition.Date__c == 'Effective Date')
            {
                endDate = inputCondition.Days__c == 'Days Before' ? inputCondition.Effective_Date__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputCondition.Effective_Date__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
           
            if(inputCondition.Date__c == 'Financial Year End')
            {
                 endDate = inputCondition.Days__c == 'Days Before' ? inputConditionParty.Financial_Year_End__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputConditionParty.Financial_Year_End__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
           
            if(inputCondition.Date__c == 'Other')
            {
                endDate = inputCondition.Days__c == 'Days Before' ? inputCondition.Other_Relative_Date__c.addDays(-(Integer.valueOf(inputCondition.Number_Of_Days__c))) : inputCondition.Other_Relative_Date__c.addDays(Integer.valueOf(inputCondition.Number_Of_Days__c));
            }
        }
       
        //RECURRING-RELATIVE-DATE
        if(inputRecurrenceType == 'RECURRING-RELATIVE-DATE')
        {  
            //Check if the agreement termination is before rolling period end, then use the agreement termination date.
            if(inputCondition.Agreement__r.Termination_Date__c != null && (inputCondition.Agreement__r.Termination_Date__c <= periodEndDate))
            {
                endDate = inputCondition.Agreement__r.Termination_Date__c;
            }
            //Check if the agreement end date is after the rolling period, then use the rolling period as end date.
            else if(inputCondition.Agreement__r.Termination_Date__c != null && (inputCondition.Agreement__r.Termination_Date__c >= periodEndDate))
            {
                endDate = periodEndDate;
            }
            //The agreement does not have a termination date, then use the rolling period end date.
            else if(inputCondition.Agreement__r.Termination_Date__c == null)
            {
                endDate = periodEndDate;
            }
            //Finally use the rolling period end date.
            else
            {
               endDate = periodEndDate;
            }
        }
       
        //System.debug('### ConditionOccurrence_Helper : calculateEndDate : endDate : '+endDate);
       
        //Return
        return endDate;
    }
   
    /**
    * nextBusinessDate - Detemines the next Business Day for a date.
    **/
    public static Date nextBusinessDate(Date inputDate)
    {
        //Convert to date to datetime.
        Datetime convertedDateTime = DateTime.newInstance(inputDate.year(), inputDate.month(),inputDate.day());
        Datetime nextBusinessDateTime = BusinessHours.nextStartDate(businessHoursId, convertedDateTime);
        Date newDate = Date.newInstance(nextBusinessDateTime.year(), nextBusinessDateTime.month(), nextBusinessDateTime.day());
 
        //Return
        return newDate;
    }
   
    /**
     * buildConditionOccurences - Generic method that builds the condition occurrences.
    **/
    public static List<Condition_Occurrence__c> buildConditionOccurences(Condition__c inputCondition, String inputRecurrenceType)
    {
        System.debug('### ConditionOccurrence_Helper : buildConditionOccurences');
        
        Boolean isActivationBased = false;
        
        //Detemine if this is an Activation Period based condition
        if(inputCondition.Activation_Start__c != null && inputCondition.Activation_End__c != null)
        {
           isActivationBased = true; 
        }
       
        //Blank List.
        List<Condition_Occurrence__c> conditionOccurrences = new List<Condition_Occurrence__c>();
        Date startDate = null;
        Date endDate = null;
       
        //One generate a single (1) occurrence for condition of type "Condition Precedent" & "Govenance Checks".  Not one per condition party.
        if(inputCondition.RecordType.Name == 'Condition Precedent' || inputCondition.RecordType.Name == 'Governance Check')
        {
            //ONCE-OFF-DUE-DATE OR ONCE-OFF-RELATIVE-DATE
            if(inputRecurrenceType == 'ONCE-OFF-DUE-DATE' || inputRecurrenceType == 'NON-SCHEDULED')
            {
                //Blank condition party, so I dont need to overload the methods.
                Condition_Party__c conditionParty = new Condition_Party__c();
               
                //Specified Due Date.
                startDate = calculateStartDate(inputCondition, inputRecurrenceType, conditionParty);
                endDate   = calculateEndDate(inputCondition, inputRecurrenceType, conditionParty);
               
                //New single condition occurrence object.
                Condition_Occurrence__c conditionOccurrence = new Condition_Occurrence__c();
                conditionOccurrence.Name = inputCondition.Name;
                conditionOccurrence.Condition__c = inputCondition.Id;
                conditionOccurrence.Status__c = 'New';
                conditionOccurrence.Deal1__c = inputCondition.Matter__c;
                conditionOccurrence.Clause__c = inputCondition.Clause__c;
                if(responsiblePeople.containsKey(inputCondition.Matter__c) == True)
                {
                     conditionOccurrence.Person_Responsible__c = responsiblePeople.get(inputCondition.Matter__c).get('Participant');
                	conditionOccurrence.Participant_User__c = responsiblePeople.get(inputCondition.Matter__c).get('User');
                }
               
                
                //Populated the consolidated relationship field.
                conditionOccurrence.Relationship_Consolidated__c = buildConditionPartiesText(inputCondition.Condition_Parties__r);
               
                //Adjust for business hours.
                conditionOccurrence.Due_Date__c = (inputRecurrenceType == 'ONCE-OFF-DUE-DATE') ? nextBusinessDate(endDate) : null;
               
                //Record Type
                conditionOccurrence.RecordTypeId = OCCURRENCE_TYPES.get(inputCondition.RecordType.Name).getRecordTypeId();
                
                //Check if there is an existing occurrence.
                Id existingOccurrenceId = existingConditionOccurrence(conditionOccurrence, null);

                if(existingOccurrenceId == null)
                {
                    //Add to list.
                    conditionOccurrences.add(conditionOccurrence);
                }
                else
                {
                    //Create am update item.
                    Condition_Occurrence__c updateConditionOccurrence = new Condition_Occurrence__c();
                    updateConditionOccurrence.Id = existingOccurrenceId;
                   // updateConditionOccurrence.Person_Responsible__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__c;
                    //updateConditionOccurrence.Participant_User__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__r.advpm__Staff__r.Id;
                    updateConditionOccurrence.Relationship_Consolidated__c = buildConditionPartiesText(inputCondition.Condition_Parties__r);

                    //Add to list.
                    conditionOccurrences.add(updateConditionOccurrence);
                }
            }
        }
        else
        {
            //Loop through all parties on the condition.
            for(Condition_Party__c conditionParty : inputCondition.Condition_Parties__r)
            {
                //ONCE-OFF-DUE-DATE
                if(inputRecurrenceType == 'ONCE-OFF-DUE-DATE')
                {
                    //Specified Due Date.
                    startDate = calculateStartDate(inputCondition, inputRecurrenceType, conditionParty);
                    endDate   = calculateEndDate(inputCondition, inputRecurrenceType, conditionParty);
                    
                    //New single condition occurrence object.
                    Condition_Occurrence__c conditionOccurrence = new Condition_Occurrence__c();
                    conditionOccurrence.Name = inputCondition.Name;
                    conditionOccurrence.Condition__c = inputCondition.Id;
                    conditionOccurrence.Status__c = 'New';
                    conditionOccurrence.Deal1__c = inputCondition.Matter__c;
                    conditionOccurrence.Clause__c = inputCondition.Clause__c;
                    conditionOccurrence.Person_Responsible__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__c;
                    conditionOccurrence.Participant_User__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__r.advpm__Staff__r.Id;
                    conditionOccurrence.Condition_Party__c = conditionParty.Id;

                    //Populated the consolidated relationship field.
                    conditionOccurrence.Relationship_Consolidated__c = conditionParty.Agreement_Party__r.Deal_Party__r.Relationship__r.Name;
                   
                    //Adjust for business hours.
                    conditionOccurrence.Due_Date__c = nextBusinessDate(endDate);
                    
                    //Record Type
                    conditionOccurrence.RecordTypeId = OCCURRENCE_TYPES.get(inputCondition.RecordType.Name).getRecordTypeId();
                    
                    //Check if there is an existing occurrence.
                    Id existingOccurrenceId = existingConditionOccurrence(conditionOccurrence, conditionParty);

                    if(existingOccurrenceId == null)
                    {
                        //Add to list.
                        if(isActivationBased == true)
                        {
                            if(conditionOccurrence.Due_Date__c >= inputCondition.Activation_Start__c && conditionOccurrence.Due_Date__c <= inputCondition.Activation_End__c)
                            {
                                //Add to list.
                                conditionOccurrences.add(conditionOccurrence); 
                            }
                        }
                        else
                        {
                            //Add to list.
                            conditionOccurrences.add(conditionOccurrence);
                        }
                    }
                    else
                    {
                        //Create am update item.
                        Condition_Occurrence__c updateConditionOccurrence = new Condition_Occurrence__c();
                        updateConditionOccurrence.Id = existingOccurrenceId;
                        // updateConditionOccurrence.Person_Responsible__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__c;
                        //updateConditionOccurrence.Participant_User__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__r.advpm__Staff__r.Id;	
                        //Add to list.
                        conditionOccurrences.add(updateConditionOccurrence);
                    }
                }
               
                //ONCE-OFF-RELATIVE-DATE
                if(inputRecurrenceType == 'ONCE-OFF-RELATIVE-DATE')
                {
                    //Specified Due Date.
                    startDate = calculateStartDate(inputCondition, inputRecurrenceType, conditionParty);
                    endDate   = calculateEndDate(inputCondition, inputRecurrenceType, conditionParty);
                   
                    //New single condition occurrence object.
                    Condition_Occurrence__c conditionOccurrence = new Condition_Occurrence__c();
                    conditionOccurrence.Name = inputCondition.Name;
                    conditionOccurrence.Condition__c = inputCondition.Id;
                    conditionOccurrence.Status__c = 'New';
                    conditionOccurrence.Deal1__c = inputCondition.Matter__c;
                    conditionOccurrence.Clause__c = inputCondition.Clause__c;
                    conditionOccurrence.Person_Responsible__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__c;
                    conditionOccurrence.Participant_User__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__r.advpm__Staff__r.Id;
                    conditionOccurrence.Condition_Party__c = conditionParty.Id;

                    //Populated the consolidated relationship field.
                    conditionOccurrence.Relationship_Consolidated__c = conditionParty.Agreement_Party__r.Deal_Party__r.Relationship__r.Name;
                   
                    //Adjust for business hours.
                    conditionOccurrence.Due_Date__c = nextBusinessDate(endDate);
                   
                    //Record Type
                    conditionOccurrence.RecordTypeId = OCCURRENCE_TYPES.get(inputCondition.RecordType.Name).getRecordTypeId();
                   
                    //Check if there is an existing occurrence.
                    Id existingOccurrenceId = existingConditionOccurrence(conditionOccurrence, conditionParty);

                    if(existingOccurrenceId == null)
                    { 
                        //Add to list.
                        if(isActivationBased == true)
                        {
                            if(conditionOccurrence.Due_Date__c >= inputCondition.Activation_Start__c && conditionOccurrence.Due_Date__c <= inputCondition.Activation_End__c)
                            {
                                //Add to list.
                                conditionOccurrences.add(conditionOccurrence);
                            }
                        }
                        else
                        {
                            //Add to list.
                            conditionOccurrences.add(conditionOccurrence);
                        }
                    }
                    else
                    {
                        //Create am update item.
                        Condition_Occurrence__c updateConditionOccurrence = new Condition_Occurrence__c();
                        updateConditionOccurrence.Id = existingOccurrenceId;
                       // updateConditionOccurrence.Person_Responsible__c = conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__c;
                        // updateConditionOccurrence.Participant_User__c = conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__r.advpm__Staff__r.Id;
                        //Add to list.
                        conditionOccurrences.add(updateConditionOccurrence);
                    }
                }
           
                //RECURRING-RELATIVE-DATE
                if(inputRecurrenceType == 'RECURRING-RELATIVE-DATE')
                {
                    System.debug('### ConditionOccurrence_Helper : buildConditionOccurences : RECURRING-RELATIVE-DATE : Party : '+conditionParty.Relationship__c); 
                    
                    //Specified Due Date.
                    startDate = calculateStartDate(inputCondition, inputRecurrenceType, conditionParty);
                    endDate   = calculateEndDate(inputCondition, inputRecurrenceType, conditionParty);
               
                    //Blank values
                    Integer occurrencesRequired = null;
                    Decimal occurrencesRequired_Decimal = null;
                    Integer monthIterator = null;
                   
                    //Set the occurrence date to the start date.
                    Date occurrenceDate = startDate; 
                   
                    //Monthly.
                    if(inputCondition.Recurrence__c == 'Monthly')
                    {
                        monthIterator       = 1;
                        occurrencesRequired_Decimal = startDate.monthsBetween(endDate) / 1.0000;
                       
                        if(occurrencesRequired_Decimal >= 2.0000 && occurrencesRequired_Decimal < 3.0000)
                        {
                            occurrencesRequired_Decimal = occurrencesRequired_Decimal + 1.0000;
                        }
                    }
                   
                    //Quarterly.
                    if(inputCondition.Recurrence__c == 'Quarterly')
                    {  
                        monthIterator       = 3;
                        occurrencesRequired_Decimal = startDate.monthsBetween(endDate) / 3.0000;
                    }
                   
                    //Bi-Annually.
                    if(inputCondition.Recurrence__c == 'Bi-Annually')
                    {
                        monthIterator       = 6;
                        occurrencesRequired_Decimal = startDate.monthsBetween(endDate) / 6.0000;
                    }
                   
                    //Annually.
                    if(inputCondition.Recurrence__c == 'Annually')
                    {
                        monthIterator       = 12;
                        occurrencesRequired_Decimal =  startDate.monthsBetween(endDate) / 12.0000;
                    }
                    
                    if(occurrencesRequired_Decimal.setScale(4) > 0.0000 && occurrencesRequired_Decimal.setScale(4) < 1.0000)
                    {
                        occurrencesRequired = 1;
                    }
                    else
                    {
                        occurrencesRequired = occurrencesRequired_Decimal.intValue();
                    }
                   
                    Date periodStartDate = null;
                   
                    if(inputCondition.Conditions_Due__r.size() == 0)
                    {
                        periodStartDate  = occurrenceDate;
                    }
                    else
                    {
                        periodStartDate  = Date.today();
                    }
                     System.debug('startDate : ' + startDate);
                     System.debug('endDate : ' + endDate);
                   System.debug('startDate.monthsBetween(endDate) : ' + startDate.monthsBetween(endDate)); 
                    System.debug('occurrencesRequired : ' + occurrencesRequired);
                    //For loop to get build number of occurrences required.
                    for(Integer counter = 0; counter < occurrencesRequired; counter++)
                    {
                        //Make sure we only add "future" occurrences and no more than the period end.
                        if(occurrenceDate >= periodStartDate && occurrenceDate <= endDate)
                        {
                            System.debug('occurrenceDate : ' + occurrenceDate);
                            System.debug('periodStartDate : ' + periodStartDate);
                            System.debug('endDate : ' + endDate); 
                            //New single condition occurrence object.
                            Condition_Occurrence__c conditionOccurrence = new Condition_Occurrence__c();
                            conditionOccurrence.Name = inputCondition.Name;
                            conditionOccurrence.Condition__c = inputCondition.Id;
                            conditionOccurrence.Status__c = 'New';
                            conditionOccurrence.Deal1__c = inputCondition.Matter__c;
                            conditionOccurrence.Clause__c = inputCondition.Clause__c;
                            conditionOccurrence.Person_Responsible__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__c;
                            conditionOccurrence.Participant_User__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__r.advpm__Staff__r.Id;
                            conditionOccurrence.Condition_Party__c = conditionParty.Id;

                            //Populated the consolidated relationship field.
                            conditionOccurrence.Relationship_Consolidated__c = conditionParty.Agreement_Party__r.Deal_Party__r.Relationship__r.Name;
                           
                            //Adjust for business hours.
                            conditionOccurrence.Due_Date__c = nextBusinessDate(occurrenceDate);
                           
                            //Record Type
                            conditionOccurrence.RecordTypeId = OCCURRENCE_TYPES.get(inputCondition.RecordType.Name).getRecordTypeId();
                            
                            //Check if there is an existing occurrence.
                            Id existingOccurrenceId = existingConditionOccurrence(conditionOccurrence, conditionParty);

                            if(existingOccurrenceId == null)
                            {
                                //Add to list.
                                if(isActivationBased == true) 
                                {                                  
                                    if(conditionOccurrence.Due_Date__c >= inputCondition.Activation_Start__c && conditionOccurrence.Due_Date__c <= inputCondition.Activation_End__c)
                                    {
                                        //Add to list.
                                        conditionOccurrences.add(conditionOccurrence);
                                    }
                                }
                                else
                                {
                                    //Add to list.
                                    conditionOccurrences.add(conditionOccurrence);
                                }
                            }
                            else
                            {
                                //Create am update item.
                                Condition_Occurrence__c updateConditionOccurrence = new Condition_Occurrence__c();
                                updateConditionOccurrence.Id = existingOccurrenceId;
                                //updateConditionOccurrence.Person_Responsible__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__c;
                                //updateConditionOccurrence.Participant_User__c= conditionParty.Agreement_Party__r.Deal_Party__r.Conditions_Monitored_By__r.advpm__Staff__r.Id;
                                //Add to list.
                                conditionOccurrences.add(updateConditionOccurrence);
                            }
                        }
                       
                        //Increment the date to next occurrence date.
                        Date newDate = occurrenceDate.addMonths(monthIterator); 
                        occurrenceDate = newDate;
                    }
                }
            }
            //Condition party loop end.
        }
       
        //Return
        return conditionOccurrences;
    }
   
    /**
     * deactivateConditions - Removes all the future dated condition occurences for deactivated conditions.
    **/
    public static List<Condition_Occurrence__c> deactivateConditions(List<Condition__c> inputConditions)
    {
        System.debug('### ConditionOccurrence_Helper : deactivateConditions');
       
        //Blank List.
        Map<Id, Condition_Occurrence__c> conditionOccurrences = new Map<Id, Condition_Occurrence__c>();
        List<Condition_Occurrence__c> occurrencesToDelete = new List<Condition_Occurrence__c>();        

        //Get all future occurrences, including activity tracking
        conditionOccurrences = getFutureOccurrences(inputConditions);

        //Loop over occurrences.
        for(String key : conditionOccurrences.keySet())
        {   
            //Make sure we exclude any occurrences that may have been worked on by a user.
            if(conditionOccurrences.get(key).Tasks.size() == 0 && conditionOccurrences.get(key).BoxDocuments__r.size() == 0 && conditionOccurrences.get(key).Modified__c == false)
            {
                //Add to delete list.
                occurrencesToDelete.add(conditionOccurrences.get(key)); 
            }
        }
       
        return occurrencesToDelete;
    }
   
    /**
     * activateConditions - Kicks off the creation of acivated conditions.
    **/
    public static List<Condition_Occurrence__c> activateConditions(List<Condition__c> inputConditions)
    {
        System.debug('### ConditionOccurrence_Helper : activateConditions');
       
        //Blank List.
        List<Condition_Occurrence__c> occurrencesToInsert = new List<Condition_Occurrence__c>();
       
        //Call our method that generates the condition occurrences.
        occurrencesToInsert = createOccurrences(inputConditions);
        
        return occurrencesToInsert;
    }
   
    /**
     * relativeDateChanged - Identifies which conditions are affected by the "relative date" change.
    **/
    public static List<Condition__c> relativeDateChanged(Set<Id> inputObjectIds, String inputFieldType)
    {
        System.debug('### ConditionOccurrence_Helper : relativeDateChanged');
       
        //Blank List.
        List<Condition__c> conditions = new List<Condition__c>();
        Set<Id> partyConditions = new Set<Id>();
        List<Condition_Party__c> conditionParties = new List<Condition_Party__c>(); 
       
        //Financial Year End
        if(inputFieldType == 'Account')
        {
            //Get all condition parties
            conditionParties = [
                SELECT
                    Id,
                    Agreement_Party__r.Deal_Party__r.Relationship__c,
                    Condition__c,
                    Condition__r.Date__c,
                    Condition__r.Active__c
                FROM Condition_Party__c
                WHERE
                    Agreement_Party__r.Deal_Party__r.Relationship__c IN :inputObjectIds
                    AND Condition__r.Date__c = 'Financial Year End'
                    AND Condition__r.Active__c = true
            ];
           
            //Loop through condition parties and build up unique list on conditions.
            for(Condition_Party__c conditionParty : conditionParties)
            {
                if(!partyConditions.contains(conditionParty.Condition__c))
                {
                   partyConditions.add(conditionParty.Condition__c);
                }
            }
           
            //Anything to process
            if(!partyConditions.isEmpty())
            {
                //Get all agreements & conditions associated with this "relationship".
                conditions = [
                    SELECT
                        Id
                    FROM Condition__c
                    WHERE
                        Id IN :partyConditions
                ];
            }
        }
       
        //Signature Date OR Effective Date
        if(inputFieldType == 'Agreement')
        {
            //Get all agreements associated with this "relationship".
            conditions = [
                SELECT
                    Id,
                    Agreement__r.Matter_Deal__r.advpm__Primary_Account__c
                FROM Condition__c
                WHERE
                    Agreement__c IN :inputObjectIds
                    AND Active__c = true
                    AND Date__c != null
                    AND Date__c != 'Financial Year End'
                    AND Date__c != 'Other'
            ];
        }
       
        //Return
        return conditions;
    }
   
    /**
     * buildConditionPartiesText - Build a comma seperated text "string "of all condition parties passed in.
    **/
    public static String buildConditionPartiesText(List<Condition_Party__c> inputConditionParties)
    {
        System.debug('### ConditionOccurrence_Helper : buildConditionPartiesText');

        //Blank var.
        List<String> partyNames = new List<String>();
        String consolidatedName = '';
       
        for(Condition_Party__c inputConditionParty : inputConditionParties)
        {
            //Not blank string or value.
            if(!String.isBlank(inputConditionParty.Relationship__c))
            {
                //Add to list of strings.
                partyNames.add(inputConditionParty.Relationship__c);
            }
        }
       
        //Any names?
        if(!partyNames.isEmpty())
        {
            //Join names from list.
            consolidatedName = String.join(partyNames, '; ');
        }

        System.debug('### ConditionOccurrence_Helper : buildConditionPartiesText : '+consolidatedName);
       
        //Default return
        return consolidatedName;
    }
   
    /**
     * determineResponsiblePerson - Build a comma seperated text "string "of all condition parties passed in.
    **/
    public static Map<Id, Map<String,Id>> determineResponsiblePerson(List<Condition__c> inputConditions)
    {
        System.debug('### ConditionOccurrence_Helper : determineResponsiblePerson');
       
        //Blank vars
        Set<Id> matterIds = new Set<Id>();
        List<advpm__Matter__c> matters = new List<advpm__Matter__c>();
        Map<Id, Map<String,Id>> dealResponsiblePerson = new Map<Id, Map<String,Id>>();
       
        //Loop through conditions and get unqiue matters.
        for(Condition__c inputCondition : inputConditions)
        {
            //Matter not in set.
            if(!matterIds.contains(inputCondition.Matter__c))
            {
                //Add to set.
                matterIds.add(inputCondition.Matter__c);
            }
        }
       
        //Get a list of matters and their participants.
        matters = [
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        advpm__Staff__c,
                        advpm__Role__c,
                        Primary_Contact_for_Role__c
                    FROM
                        advpm__Participants__r
                    WHERE
                        advpm__Staff__c != null
                        AND advpm__Role__c != null
                       
                )
            FROM advpm__Matter__c
            WHERE
                Id IN :matterIds
        ];
       
        //Loop through Matter.
        for(advpm__Matter__c matter : matters)
        {
            //Loop participants.
            for(advpm__Participant__c participant : matter.advpm__Participants__r)
            {
                //Blank roles.
                List<String> roles = participant.advpm__Role__c.split(';');
               
                //Loop through roles.
                for(String role : roles)
                {
                    if(role == 'Transaction Administration')
                    {
                        if(!dealResponsiblePerson.containsKey(matter.Id))
                        {
                            //Add to map.
                            dealResponsiblePerson.put(matter.Id, new Map<String,Id>() );
                            dealResponsiblePerson.get(matter.Id).put('User',participant.advpm__Staff__c);
                            dealResponsiblePerson.get(matter.Id).put('Participant',participant.id);

                        }
                        else
                        {
                            //Replace if map if primary only.
                            if(dealResponsiblePerson.containsKey(matter.Id) && participant.Primary_Contact_for_Role__c == true)
                            {
                                //Add to map.
                                dealResponsiblePerson.put(matter.Id, new Map<String,Id>() );
                                dealResponsiblePerson.get(matter.Id).put('User',participant.advpm__Staff__c);
                                dealResponsiblePerson.get(matter.Id).put('Participant',participant.id);
                            }
                        }
                    }
                }
               
            }
        }
       
        //Default return
        return dealResponsiblePerson;
    }
    
    /**
     * shouldUpdateOccurances - Determines which fields changed on a financial covenant.
    **/
    public static Boolean shouldUpdateOccurances(Condition__c newCondition, Condition__c oldCondition)
    {
        Boolean condition1 = newCondition.Required_Base__c != oldCondition.Required_Base__c;
        Boolean condition2 = newCondition.Required_Base_Multiple__c != oldCondition.Required_Base_Multiple__c;
        Boolean condition3 = newCondition.Required_Base_Percentage__c != oldCondition.Required_Base_Percentage__c;
        Boolean condition4 = newCondition.Required_Base_Range_Multiple_Range_From__c != oldCondition.Required_Base_Range_Multiple_Range_From__c;
        Boolean condition5 = newCondition.Required_Base_Range_Multiple_To__c != oldCondition.Required_Base_Range_Multiple_To__c;
        Boolean condition6 = newCondition.Required_Base_Range_Percentage_From__c != oldCondition.Required_Base_Range_Percentage_From__c;
        Boolean condition7 = newCondition.Required_Base_Range_Percentage_To__c != oldCondition.Required_Base_Range_Percentage_To__c;
        Boolean condition8 = newCondition.Required_Base_Range_Ratio_From__c != oldCondition.Required_Base_Range_Ratio_From__c;
        Boolean condition9 = newCondition.Required_Base_Range_Ratio_From_Two__c != oldCondition.Required_Base_Range_Ratio_From_Two__c;
        Boolean condition10 = newCondition.Required_Base_Range_Ratio_To__c != oldCondition.Required_Base_Range_Ratio_To__c;
        Boolean condition11 = newCondition.Required_Base_Range_Ratio_To_Two__c != oldCondition.Required_Base_Range_Ratio_To_Two__c;
        Boolean condition12 = newCondition.Required_Base_Ratio__c != oldCondition.Required_Base_Ratio__c;
        Boolean condition13 = newCondition.Required_Base_Ratio_From__c != oldCondition.Required_Base_Ratio_From__c;
        Boolean condition14 = newCondition.Required_Base_Ratio_To__c != oldCondition.Required_Base_Ratio_To__c;
        Boolean condition15 = newCondition.Source__c != oldCondition.Source__c;
        Boolean condition16 = newCondition.Threshold_Category__c != oldCondition.Threshold_Category__c;
        Boolean condition17 = newCondition.Threshold_Comparator__c != oldCondition.Threshold_Comparator__c;
        Boolean condition18 = newCondition.Threshold_Type__c != oldCondition.Threshold_Type__c;
        Boolean condition19 = newCondition.Margin_Ratchet__c != oldCondition.Margin_Ratchet__c;
        Boolean condition20 = newCondition.Other__c != oldCondition.Other__c;
        Boolean condition21 = newCondition.Required_Base_Number__c != oldCondition.Required_Base_Number__c;
        Boolean condition22 = newCondition.Required_Base_Range_Number_From__c != oldCondition.Required_Base_Range_Number_From__c;
        Boolean condition23 = newCondition.Required_Base_Range_Number_To__c != oldCondition.Required_Base_Range_Number_To__c;

        return condition1 || condition2 || condition3 || condition4 || condition5 || condition6 || condition7 || condition8 || condition9 
            || condition10 || condition11 || condition12 || condition13 || condition14 || condition15 || condition16 || condition17 
            || condition18 || condition19 || condition20 || condition21 || condition22 || condition23;
    }
    
    /**
     * updateOccuranceTreshold - Updates the condition occurrences with the new Treshold values.
    **/
    public static void updateOccuranceTreshold(Map<Id, Condition__c> conditionMap)
    {
        List<Condition_Occurrence__c> toUpdate = [SELECT Id, Condition__c, Required_Base__c, Required_Other__c, Required_Base_Multiple_Num__c,
            Required_Base_Percentage_Num__c, Required_Base_Range_Multiple_From_Num__c, Required_Base_Range_Multiple_To_Num__c,
            Required_Base_Range_Percentage_From_Num__c, Required_Base_Range_Percentage_To_Num__c, Required_Base_Range_Ratio_From_Num__c,
            Required_Base_Range_Ratio_From_Two_Num__c, Required_Base_Range_Ratio_To_Num__c, Required_Base_Range_Ratio_To_Two_Num__c,
            Required_Base_Ratio__c, Required_Base_Ratio_From_Num__c, Required_Base_Ratio_To_Num__c, Source_Text__c, Threshold_Category_Text__c,
            Threshold_Comparator_Text__c, Threshold_Type_Text__c, Margin_Ratchet__c, Required_Base_Number__c, Required_Base_Range_Number_From__c, Required_Base_Range_Number_To__c
            FROM Condition_Occurrence__c WHERE Condition__c IN :conditionMap.keySet() AND Due_Date__c >= TODAY];

        for(Condition_Occurrence__c occurence: toUpdate)
        {
            Condition__c parent = conditionMap.get(occurence.Condition__c);
            setTresholdVals(occurence, parent);
        }

        update toUpdate;
    }

    public static void setTresholdVals(Condition_Occurrence__c occurence, Condition__c parent)
    {
        occurence.Required_Base__c = parent.Required_Base__c;
        occurence.Required_Other__c = parent.Other__c;
        occurence.Required_Base_Multiple_Num__c = parent.Required_Base_Multiple__c;
        occurence.Required_Base_Number__c = parent.Required_Base_Number__c;
        occurence.Required_Base_Range_Number_From__c = parent.Required_Base_Range_Number_From__c;
        occurence.Required_Base_Range_Number_To__c = parent.Required_Base_Range_Number_To__c;
        occurence.Required_Base_Percentage_Num__c = parent.Required_Base_Percentage__c;
        occurence.Required_Base_Range_Multiple_From_Num__c = parent.Required_Base_Range_Multiple_Range_From__c;
        occurence.Required_Base_Range_Multiple_To_Num__c = parent.Required_Base_Range_Multiple_To__c;
        occurence.Required_Base_Range_Percentage_From_Num__c = parent.Required_Base_Range_Percentage_From__c;
        occurence.Required_Base_Range_Percentage_To_Num__c = parent.Required_Base_Range_Percentage_To__c;
        occurence.Required_Base_Range_Ratio_From_Num__c = parent.Required_Base_Range_Ratio_From__c;
        occurence.Required_Base_Range_Ratio_From_Two_Num__c = parent.Required_Base_Range_Ratio_From_Two__c;
        occurence.Required_Base_Range_Ratio_To_Num__c = parent.Required_Base_Range_Ratio_To__c;
        occurence.Required_Base_Range_Ratio_To_Two_Num__c = parent.Required_Base_Range_Ratio_To_Two__c;
        occurence.Required_Base_Ratio__c = parent.Required_Base_Ratio__c;
        occurence.Required_Base_Ratio_From_Num__c = parent.Required_Base_Ratio_From__c;
        occurence.Required_Base_Ratio_To_Num__c = parent.Required_Base_Ratio_To__c;
        occurence.Source_Text__c = parent.Source__c;
        occurence.Threshold_Category_Text__c = parent.Threshold_Category__c;
        occurence.Threshold_Comparator_Text__c = parent.Threshold_Comparator__c;
        occurence.Threshold_Type_Text__c = parent.Threshold_Type__c;
        occurence.Margin_Ratchet__c = parent.Margin_Ratchet__c;
    }

    /**
    * createOccurrenceDocuments - Create ocurrence documents when inserted based on the associated conditions template.
    **/    
    public static void createOccurrenceDocuments(List<Condition_Occurrence__c> inputNewList)
    {
        System.debug('### ConditionOccurrence_Helper : createOccurrenceDocuments');

        //Blank vars.
        Set<Id> conditionIds = new Set<Id>();
        Map<Id, Condition__c> conditions = new Map<Id, Condition__c>();
        List<BoxDocument__c> boxDocuments  = new List<BoxDocument__c>();

        //Build condition ids.
        for(Condition_Occurrence__c conditionOccurrence : inputNewList)
        {
            conditionIds.add(conditionOccurrence.Condition__c);
        }

        //Fetch conditions and documents.
        conditions = new Map<Id, Condition__c>([
            SELECT
                Id,
                (
                    SELECT
                        Id,
                        Name,
                        Document_Type__c
                    FROM Condition_Documents__r
                )
            FROM Condition__c
            WHERE
                Id IN :conditionIds
        ]);

        //Build condition ids.
        for(Condition_Occurrence__c conditionOccurrence : inputNewList)
        {
            if(conditions.containsKey(conditionOccurrence.Condition__c))
            {
                for(Condition_Document__C documentTemplate : conditions.get(conditionOccurrence.Condition__c).Condition_Documents__r)
                {
                    //New box document.
                    BoxDocument__c boxDocument = new BoxDocument__c();
                    boxDocument.Type__c = documentTemplate.Document_Type__c;
                    boxDocument.Name = documentTemplate.Name;
                    boxDocument.PII__c = 'Yes';
                    boxDocument.Prerequisite_Document__c = true;
                    boxDocument.Condition_Occurrence__c = conditionOccurrence.Id;
                    boxDocument.Owner_Type__c = 'Condition_Occurrence__c';

                    //Add to insert list.
                    boxDocuments.add(boxDocument);  
                }
            }
        }

        //Any documents to insert 
        if(!boxDocuments.isEmpty())
        {
            insert boxDocuments; 
        }
    }

    /**
    * checkFieldChanges - Checks if any updatable fields have changed and marks an occurrence as "Data Modified".
    **/
    public static void checkFieldChanges(List<Condition_Occurrence__c> inputNewList, Map<Id, Condition_Occurrence__c> inputOldMap)
    {
        //Loop through
        for(Condition_Occurrence__c conditionOccurrence : inputNewList)
        {
            //Loop over fields.
            for(String field : occurrenceFields.keySet())
            {   
                //Updateable Field
                if(occurrenceFields.get(field).getDescribe().isUpdateable() && field != 'Deal1__c' && field != 'Participant_User__c' && field!= 'Person_Responsible__c')
                {
                    //Field changed.
                    if(conditionOccurrence.get(field) != inputOldMap.get(conditionOccurrence.Id).get(field))
                    {
                        conditionOccurrence.Modified__c = true;
                    }
                }
            }
        }
    }

    /**
    * getFutureOccurrences - Retrieves future conditions for a list of conditions.
    **/
    public static Map<Id, Condition_Occurrence__c> getFutureOccurrences(List<Condition__c> inputConditions)
    {
        //Blank list.
        Map<Id, Condition_Occurrence__c> conditionOccurrences = new Map<Id, Condition_Occurrence__c>();

        //Get condition ids.
        Set<Id> conditionIds = (new Map<Id,Condition__c>(inputConditions)).keySet();

        //Get all future occurrences, including activity tracking, and assoc boxx documents.
        conditionOccurrences = new Map<Id, Condition_Occurrence__c>([
            SELECT
                Id,
                Name,
                CreatedDate,
                LastModifiedDate,
                Modified__c,
                Condition__c,
                Due_Date__c,
                Condition_Party__c,
                RecordTypeId,
                Condition_Party__r.Agreement_Party__r.Deal_Party__r.Relationship__c,
                (
                    SELECT
                        Id
                    FROM Tasks
                    WHERE
                        IsDeleted = false
                    LIMIT 1
                ),
                (
                    SELECT
                        Id
                    FROM BoxDocuments__r 
                    LIMIT 1
                )
            FROM Condition_Occurrence__c
            WHERE
                Condition__c IN :conditionIds 
                AND (Due_Date__c >= :Date.today() OR Due_Date__c = NULL)
            
        ]);

        //Default return.
        return conditionOccurrences;
    }

    /**
    * existingConditionOccurrence
    **/
    public static Id existingConditionOccurrence(Condition_Occurrence__c inputOccurrence, Condition_Party__c inputConditionParty) 
    {
        for(String key : existingFutureOccurrences.keySet())
        {        
            if(inputOccurrence.Condition__c == existingFutureOccurrences.get(key).Condition__c)
            {
                if(inputOccurrence.Due_Date__c == existingFutureOccurrences.get(key).Due_Date__c)
                {
                    if( inputOccurrence.RecordTypeId == OCCURRENCE_TYPES.get('Condition Precedent').getRecordTypeId() || inputOccurrence.RecordTypeId == OCCURRENCE_TYPES.get('Governance Check').getRecordTypeId() )
                    {
                        return existingFutureOccurrences.get(key).Id;
                    }
                    else
                    {
                        if(existingFutureOccurrences.get(key).Condition_Party__r.Agreement_Party__r.Id == inputConditionParty.Agreement_Party__r.Id)
                        {
                            return existingFutureOccurrences.get(key).Id;
                        }
                    }
                }
            }
        }

        //Default return
        return null;
    } 
    
    /**
     * validateSupportDocumentsUploaded - Validate that supporting documents have been uploaded based on the box location and/or upload date on BoxDocument__c 
     * */
     public static void validateSupportDocumentsUploaded(List<Condition_Occurrence__c> conditionOccurencesList)
    {
        Set<Id> conditionOccurenceIds = new Set<Id>();
        Map<Id, List<BoxDocument__c>> occurrencePrerequisiteDocsNotUploaded_Map = new Map<Id, List<BoxDocument__c>>();
        Map<Id, List<BoxDocument__c>> occurrenceOtherDocs_Map = new Map<Id, List<BoxDocument__c>>();
        Map<Id, Boolean> occurrenceDocumentsLoaded_Map = new Map<Id, Boolean>();
        
        //Add all conditions to a set
        for(Condition_Occurrence__c eachConditionOccurrence : conditionOccurencesList)
        {
            conditionOccurenceIds.add(eachConditionOccurrence.Id);
        }
        
        //Populate Map - Get all box documents uploaded, check: - ALL prerequisite(if any) have been uploaded, if Yes flag as TRUE else flag as FALSE
        //                                                        if no prerequisite documents required, check if other documents were uploaded                                                      
        for(BoxDocument__c eachDocument : [SELECT Id, Name, Box_Location__c, Condition_Occurrence__c, Upload_Date__c, Prerequisite_Document__c 
                                           FROM BoxDocument__c 
                                           WHERE Condition_Occurrence__c =: conditionOccurenceIds])
        {
            if(!occurrenceDocumentsLoaded_Map.containsKey(eachDocument.Condition_Occurrence__c))
            {
                occurrenceDocumentsLoaded_Map.put(eachDocument.Condition_Occurrence__c, TRUE);          
            }
            
            if(occurrenceDocumentsLoaded_Map.containsKey(eachDocument.Condition_Occurrence__c))
            {
                System.debug('### in contains map before if : ' + occurrenceDocumentsLoaded_Map.get(eachDocument.Condition_Occurrence__c));
                //If Prerequisite Document = TRUE and upload date NULL flag as FALSE
                if(eachDocument.Prerequisite_Document__c == TRUE && eachDocument.Upload_Date__c == NULL)
                {
                    occurrenceDocumentsLoaded_Map.put(eachDocument.Condition_Occurrence__c, FALSE);
                    System.debug('### in contains map in if : ' + occurrenceDocumentsLoaded_Map.get(eachDocument.Condition_Occurrence__c));
                }
            }
        }
        
        //Loop through occurrences and check if upload date specified
        for(Condition_Occurrence__c eachConditionOccurrence : conditionOccurencesList)
        {
            if(occurrenceDocumentsLoaded_Map.containsKey(eachConditionOccurrence.id))
            {
                eachConditionOccurrence.Box_Documents_Uploaded__c  = occurrenceDocumentsLoaded_Map.get(eachConditionOccurrence.id);
            }
        }
    }
}