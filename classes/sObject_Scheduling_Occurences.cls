/**
*** CHANGE LOG ***

08/11/2017 - TdB   - Created Class.
				   - getParticipantsList() - Get all Participants linked to sObject  
				   - getDistributionGroupList() - Get all Distribution Groups linked to sObject 
				   - getFinancialCovenants() - Get all Financial Covenants (Conditions) linked to sObject 
				   - getRelationshipPartiesList() - Get all Relationship Parties linked to sObject 
				   - insertSObject() - Insert initial record (Parent) and first Watcher Occurence
				   - buildSObjectWatcher() - Build the Watcher record based on frequency, date and schedule start/date date
				   - calculateStartDate() - Get start date from lowest level (Agreement/Facility/Tranche) for Watcher
				   - calculateEndDate() - Get end date from lowest level (Agreement/Facility/Tranche) for Watcher
				   - calculateScheduleEndDate() - Calculate schedule start date on sObject based on lowest level (Agreement/Facility/Tranche)
				   - calculateScheduleStartDate() - Calculate schedule end date on sObject based on lowest level (Agreement/Facility/Tranche)
				   - nextBusinessDate() - Validate that Due Date fall on a week day (Use Business Hours)
				   - insertNotificationParticipants() - Insert Notification Particpants based on selection on VF Page
				   - insertNotificationGroups() -  Insert Notification Groups based on selection on VF Page
				   - insertMarginRatchetConditions() -  Insert Margin Ratchet Conditions based on selection on VF Page
				   - insertRelationshipParties() -  Insert Relationship Parties based on selection on VF Page
				   - ParticipantWrapper() - Wrapper for Partcipant and sObject
				   - DistroGroupWrapper() - Wrapper for Distobution Group and sObject
				   - FinancialCovenantsWrapper() - Wrapper for Financial Covenants (Conditions) and sObject
				   - RelationshipPartiesWrapper() - Wrapper for Relationship Parties (Agreement/Facility/Tranche) and sObject
12/02/2018 - TdB   - Remove Status__c refrences on Watcher
26/02/2018 - TdB	- Change Financial_Year_End__c from Date to a picklist


**/ 
public class sObject_Scheduling_Occurences {
    
    public static Map <String, Schema.RecordTypeInfo> NOTI_PARTICIPANT_TYPES = Notification_Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public static Map <String, Schema.RecordTypeInfo> NOTI_GROUP_TYPES = Notification_Group__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> MarginRatchet_RecordTypes = Margin_Ratchet__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> Condition_RecordTypes = Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static Map <String, Schema.RecordTypeInfo> Watcher_RecordTypes = Watcher__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public static  List<advpm__Participant__c> participants { get; set;}
    public static List<Distribution_Group__c> distroGroups { get; set;}
    public static List<Condition__c> financialCovenantList { get; set;}
    public static List<Agreement_Party__c> agreementPartiesList { get; set;}
    public static List<Facility_Party__c> facilityPartiesList { get; set;}
    public static List<Tranche_Party__c> tranchePartiesList { get; set;}
    public static String parentObjectName = '';
    public static Id parentObjectId ;
    public static Schema.sObjectType marginRatchetObjectType = Schema.Margin_Ratchet__c.getSObjectType();
    public static Schema.sObjectType collateralValuationObjectType = Schema.Collateral_Valuation__c.getSObjectType();
    public static Schema.sObjectType collateralMonitoringObjectType = Schema.Collateral_Monitoring__c.getSObjectType();
    public static Schema.sObjectType triggerObjectType = Schema.Trigger__c.getSObjectType();
    public static DateTime todaysDate_nextMonth = System.now().addMonths(1);
    
    //Custom Settings
    public static ConditionSchedulingSettings__c settings = ConditionSchedulingSettings__c.getInstance('Default');
    
    //Scheduling Period
    public static Date periodEndDate    = Date.today().addMonths(settings.Months_In_Advance__c.intValue());
    public static Id businessHoursId    = [SELECT Id FROM BusinessHours WHERE Name = :settings.Business_Hours__c].Id;
    
    public static List<ParticipantWrapper> getParticipantsList(Id parentId)
    {
        //Blank variables.
        participants = new List<advpm__Participant__c>();
        
        //Empty wrappers
        List<ParticipantWrapper> participantsWrapper = new List<ParticipantWrapper>();
        
        //Populate participants on Deal.
        participants = [
            SELECT 
            Id, 
            Name,
            advpm__Matter__c, //Deal
            advpm__Staff__c,
            advpm__Staff__r.Email,
            advpm__Role__c
            FROM advpm__Participant__c
            WHERE
            advpm__Matter__c = :parentId
            AND advpm__Staff__c != null
        ];
        
        //Build participants wrapper
        for(advpm__Participant__c participant : participants)
        {
            //New Wrapper
            ParticipantWrapper pWrapper = new ParticipantWrapper();
            pWrapper.selected = false;
            pWrapper.participant = participant;
            
            //Add to wrapper list.
            participantsWrapper.add(pWrapper);
        }

        return participantsWrapper;
    }
    
    public static List<DistroGroupWrapper> getDistributionGroupList() 
    {
        //Blank variables.
        distroGroups = new List<Distribution_Group__c>();
        Id MatterDealId;
        
        //Empty wrappers
        List<DistroGroupWrapper> distroGroupsWrapper = new List<DistroGroupWrapper>();
        
        //Get distrubution groups.
        distroGroups = [
            SELECT 
            Id, 
            Name,
            Description__c,
            Email_Address__c,
            Group_Type__c
            FROM Distribution_Group__c
        ];
        
        //Build distrubution wrapper
        for(Distribution_Group__c distroGroup : distroGroups)
        {
            DistroGroupWrapper dWrapper = new DistroGroupWrapper();
            dWrapper.selected = false;
            dWrapper.distroGroup = distroGroup;
            
            //Add to wrapper list.
            distroGroupsWrapper.add(dWrapper);
        }
        
        return distroGroupsWrapper;
    }
    
    public static List<FinancialCovenantsWrapper> getFinancialCovenants(Id parentId) 
    {
        //Blank variables.
        financialCovenantList = new List<Condition__c>();
        Id MatterDealId;
        String FinancialCovenantsRecordTypeId;
        
        //Empty wrappers
        List<FinancialCovenantsWrapper> financialCovenantsWrappers = new List<FinancialCovenantsWrapper>();
        financialCovenantsRecordTypeId = Condition_RecordTypes.get('Financial Covenant').getRecordTypeId();
        
        //Get distrubution groups.
        financialCovenantList = [
            SELECT 
            Id, 
            Name,
            Clause__c,
            Recurrence__c,
            Due_Date__c,
            Active__c,
            Margin_Ratchet_Name__c,
            Agreement__c
            FROM Condition__c
            WHERE Agreement__c = :parentId
            AND RecordTypeId = : financialCovenantsRecordTypeId
            AND Active__c = TRUE
        ];
        
        //Build distrubution wrapper
        for(Condition__c FinancialCovenant : financialCovenantList)
        {
            FinancialCovenantsWrapper fcWrapper = new FinancialCovenantsWrapper();
            fcWrapper.selected = false;
            fcWrapper.financialCovenant = FinancialCovenant;
            
            //Add to wrapper list.
            financialCovenantsWrappers.add(fcWrapper);
        }
        
        return financialCovenantsWrappers;
    }
    
    public static List<RelationshipPartiesWrapper> getRelationshipPartiesList(Id parentId, String partiesLevel)
    {
        //Empty Wrappers
        List<RelationshipPartiesWrapper> relationshipParties_Wrapper = new List<RelationshipPartiesWrapper>();
        
        //Parties on Tranche
        if(partiesLevel == 'Tranche')
        {
            tranchePartiesList = new List<Tranche_Party__c>();
            tranchePartiesList = [SELECT Id, Party_Type__c, Facility_Party__c, Facility_Tranche__c, Name 
                                  FROM Tranche_Party__c
                                  WHERE Facility_Tranche__c = : parentId];
            
            //Build wrapper
            for(Tranche_Party__c eachParty : tranchePartiesList)
            {
                //New Wrapper
                RelationshipPartiesWrapper rpWrapper = new RelationshipPartiesWrapper();
                rpWrapper.selected = false;
                rpWrapper.partyId = eachParty.id;
                rpWrapper.partyName = eachParty.Name;
                rpWrapper.partyType = eachParty.Party_Type__c;
                
                //Add to wrapper list.
                relationshipParties_Wrapper.add(rpWrapper);
            }
        }
        //Parties on Fcaility
        else if(partiesLevel == 'Facility')
        {
            facilityPartiesList = new List<Facility_Party__c>();
            facilityPartiesList = [SELECT Party_Type__c, Facility__c, Agreement_Party__c, Name, Id 
                                   FROM Facility_Party__c
                                   WHERE Facility__c = : parentId];
            
            //Build wrapper
            for(Facility_Party__c eachParty : facilityPartiesList)
            {
                //New Wrapper
                RelationshipPartiesWrapper rpWrapper = new RelationshipPartiesWrapper();
                rpWrapper.selected = false;
                rpWrapper.partyId = eachParty.id;
                rpWrapper.partyName = eachParty.Name;
                rpWrapper.partyType = eachParty.Party_Type__c;
                
                //Add to wrapper list.
                relationshipParties_Wrapper.add(rpWrapper);
            }
        }
        //Parties on Agreement
        else if(partiesLevel == 'Agreement')
        {
            agreementPartiesList = new List<Agreement_Party__c> ();
            agreementPartiesList = [SELECT Id, Deal_Party__c, Agreement__c, Party_Type__c, Name 
                                    FROM Agreement_Party__c
                                    WHERE Agreement__c = : parentId];
            
            //Build wrapper
            for(Agreement_Party__c eachParty : agreementPartiesList)
            {
                //New Wrapper
                RelationshipPartiesWrapper rpWrapper = new RelationshipPartiesWrapper();
                rpWrapper.selected = false;
                rpWrapper.partyId = eachParty.id;
                rpWrapper.partyName = eachParty.Name;
                rpWrapper.partyType = eachParty.Party_Type__c;
                
                //Add to wrapper list.
                relationshipParties_Wrapper.add(rpWrapper);
            }
        }
        
        return relationshipParties_Wrapper;
    }
    
    public static sObject insertSObject(sObject parentRecord)
    {
        Watcher__c watcherItem = new Watcher__c();
        List<sObject> parentRecordDetail;
        Date scheduleEndDate;
        Date scheduleStartDate;

        //Insert Parent record
        if(parentRecord.getSObjectType() == marginRatchetObjectType)
        {
            //Set Margin Ratchet Record Type based on Type
            if(parentRecord.get('Type__c') == 'Event')
            {
                parentRecord.put('RecordTypeId',MarginRatchet_RecordTypes.get('Event').getRecordTypeId());
            }
            else
            {
                parentRecord.put('RecordTypeId',MarginRatchet_RecordTypes.get('Covenant').getRecordTypeId());
            }
        }
        
        //Insert Parent Record + first Watcher Occurance + related lists/records
        if(parentRecord.id == null)
        {
            insert parentRecord;
            
            //Get inserted parent
            parentObjectId = (Id)parentRecord.get('Id');
            parentObjectName = parentObjectId.getSObjectType().getDescribe().getName();
            
            //Get newly inserted record, calculate schedule dates, insert first watcher and related data
            //Margin Ratchet
            if(parentObjectName == 'Margin_Ratchet__c')
            {
                parentRecordDetail = [SELECT Type__c, Schedule_Start_Date__c, Schedule_End_Date__c,Signature_Date__c, Relative_Date__c, Other_Relative_Date__c, Number_of_Days__c, Matter_Deal__c, Id, Frequency__c, Financial_Year_End__c, Facility__c, Facility__r.Availability_Start_Date__c , Facility__r.Signature_Date__c, Facility__r.Availability_End_Date__c, Facility_Tranche__r.Availability_End_Date__c, Facility_Tranche__r.Availability_Start_Date__c, Facility_Tranche__r.Signature_Date__c,Facility_Tranche__c, Event_Type__c, Effective_Date__c, Due_Date__c, Days__c, Comments__c, Agreement__c, Agreement__r.Effective_Date__c  , Agreement__r.Signature_Date__c, Agreement__r.Client_Name__r.Financial_Year_End_Month__c, Agreement__r.Termination_Date__c, Actual__c 
                                      FROM Margin_Ratchet__c 
                                      WHERE Id = :parentObjectId limit 1];
                
                Margin_Ratchet_Helper.insertWatcherOccurence(parentRecordDetail);
                Margin_Ratchet_Helper.updateStartEndDates(parentRecordDetail);
            } 
            //Collateral Valuation
            else if(parentObjectName == 'Collateral_Valuation__c')
            {
                //Get newly inserted record, calculate schedule dates, insert first watcher and related data
                parentRecordDetail = [SELECT Schedule_Start_Date__c, Schedule_End_Date__c,Signature_Date__c, Relative_Date__c, Other_Relative_Date__c, Number_of_Days__c, Deal__c, Id, Frequency__c, Financial_Year_End__c, Effective_Date__c, Due_Date__c, Days__c, Agreement__c, Agreement__r.Effective_Date__c  , Agreement__r.Signature_Date__c, Agreement__r.Client_Name__r.Financial_Year_End_Month__c, Agreement__r.Termination_Date__c, Collateral__c, Collateral__r.Signature_Date__c, Collateral__r.Expiry_Date__c
                                      FROM Collateral_Valuation__c 
                                      WHERE Id = :parentObjectId limit 1];
                Collateral_Valuation_Helper.insertWatcherOccurence(parentRecordDetail);
                Collateral_Valuation_Helper.updateStartEndDates(parentRecordDetail);
                
            }
            //Collateral Monitoring
            else if(parentObjectName == 'Collateral_Monitoring__c')
            {
                //Get newly inserted record, calculate schedule dates, insert first watcher and related data
                parentRecordDetail = [SELECT Schedule_Start_Date__c, Schedule_End_Date__c,Signature_Date__c, Relative_Date__c, Other_Relative_Date__c, Number_of_Days__c, Deal__c, Id, Frequency__c, Financial_Year_End__c, Effective_Date__c, Due_Date__c, Days__c, Agreement__c, Agreement__r.Effective_Date__c  , Agreement__r.Signature_Date__c, Agreement__r.Client_Name__r.Financial_Year_End_Month__c, Agreement__r.Termination_Date__c, Collateral__c, Collateral__r.Signature_Date__c, Collateral__r.Expiry_Date__c
                                      FROM Collateral_Monitoring__c 
                                      WHERE Id = :parentObjectId limit 1];
                Collateral_Monitoring_Helper.insertWatcherOccurence(parentRecordDetail);
                Collateral_Monitoring_Helper.updateStartEndDates(parentRecordDetail);
            }
            //Trigger
            else if(parentObjectName == 'Trigger__c')
            {
                //Get newly inserted record, calculate schedule dates, insert first watcher and related data
                parentRecordDetail = [SELECT Schedule_Start_Date__c, Schedule_End_Date__c,Signature_Date__c, Relative_Date__c, Other_Relative_Date__c, Number_of_Days__c, Deal__c, Id, Frequency__c, Financial_Year_End__c, Effective_Date__c, Due_Date__c, Days__c, Agreement__c, Agreement__r.Effective_Date__c  , Agreement__r.Signature_Date__c, Agreement__r.Client_Name__r.Financial_Year_End_Month__c, Agreement__r.Termination_Date__c
                                      FROM Trigger__c 
                                      WHERE Id = :parentObjectId limit 1];
                Trigger_Helper.insertWatcherOccurence(parentRecordDetail);
                Trigger_Helper.updateStartEndDates(parentRecordDetail);
            }
            update parentRecordDetail;
        }
        //If record already exist, update record based on new values in fields
        else
        {
            update parentRecord;
        }
        
        return parentRecord;
    }
    
    public static Watcher__c buildSObjectWatcher(sObject parentRecord)
    {
        parentObjectId = (Id)parentRecord.get('Id');
        parentObjectName = parentObjectId.getSObjectType().getDescribe().getName();
        Watcher__c watcherItem = new Watcher__c();
        
        Date startDate = null;
         Date endDate = null;
        
         //Call method to get start date for Watcher
         //Once-Off 
        if((Date)parentRecord.get('Due_Date__c') != null)
        {
           
            startDate = calculateStartDate(parentRecord,'DUE-DATE');
            //endDate = calculateEndDate(parentRecord,'DUE-DATE');
        }
        //Other Frequency
        else
        {
            startDate = calculateStartDate(parentRecord,'RELATIVE-DATE');
           // endDate = calculateEndDate(parentRecord,'RELATIVE-DATE');
        }
        
        //Set sObject link and Record Type
        //Margin Ratchet
        if(parentObjectName == 'Margin_Ratchet__c')
        {
            watcherItem.Margin_Ratchet__c = (Id)parentRecord.get('Id');
            watcherItem.RecordTypeId = Watcher_RecordTypes.get('Margin Ratchet').getRecordTypeId();
        }
        //Collateral Valuation
        else if(parentObjectName == 'Collateral_Valuation__c')
        {
            watcherItem.Collateral_Valuation__c = (Id)parentRecord.get('Id');
            watcherItem.RecordTypeId = Watcher_RecordTypes.get('Collateral Valuation').getRecordTypeId();
        }
        //Collateral Monitoring
        else if(parentObjectName == 'Collateral_Monitoring__c')
        {
            watcherItem.Collateral_Monitoring__c = (Id)parentRecord.get('Id');
            watcherItem.RecordTypeId = Watcher_RecordTypes.get('Collateral Monitoring').getRecordTypeId();
        }
        //Trigger
        else if(parentObjectName == 'Trigger__c')
        {
            watcherItem.Trigger__c = (Id)parentRecord.get('Id');
            watcherItem.Deal__c = (Id)parentRecord.get('Deal__c');
            watcherItem.RecordTypeId = Watcher_RecordTypes.get('Trigger').getRecordTypeId();
        }
        
        if(startDate != null)
        {
            watcherItem.Due_Date__c = nextBusinessDate(startDate);
        }

        return watcherItem;
    }
    
    public static Date calculateStartDate(sObject parentRecord, String watcherType)
    {
        Date startDate = null;
        Integer noDays = 0;
        Date tempDate;
        
        //ONCE-OFF-DUE-DATE
        if(watcherType == 'DUE-DATE')
        {
            //Specified Due Date.
            startDate = (Date)parentRecord.get('Due_Date__c');
        }
        
        //ONCE-OFF-RELATIVE-DATE
        if(watcherType == 'RELATIVE-DATE')
        {    
            noDays = Integer.valueOf((Decimal)parentRecord.get('Number_Of_Days__c'));
            
            if(parentRecord.get('Relative_Date__c') == 'Signature Date')
            {
                tempDate = (Date)parentRecord.get('Signature_Date__c');
            }
            
            else if(parentRecord.get('Relative_Date__c') == 'Effective Date')
            {
                tempDate = (Date)parentRecord.get('Effective_Date__c');
            }
            
            else if(parentRecord.get('Relative_Date__c') == 'Financial Year End')
            {
                tempDate = (Date)parentRecord.get('Financial_Year_End__c');
            }
            
            else if(parentRecord.get('Relative_Date__c') == 'Other')
            {
                tempDate = (Date)parentRecord.get('Other_Relative_Date__c');
            }
            
            //Calculate start date based on the relative date selected, Days and No of Days on sObject 
            if(tempDate != null && noDays != null && ((String)parentRecord.get('Days__c') == 'Days Before' || (String)parentRecord.get('Days__c') == 'Days After'))
            {
                System.debug('In schedule');
                startDate = (String)parentRecord.get('Days__c') == 'Days Before' ? tempDate.addDays(-noDays) : tempDate.addDays(noDays);
            }
            else
            {
                startDate = tempDate;
            }
            
        }
        System.debug('startDate : ' + startDate);        
        return startDate;
    }
    
    public static Date calculateEndDate(sObject parentRecord, String watcherType)
    {
        Date endDate = null;
        Integer noDays = 0;
        Date tempDate;
        
        //ONCE-OFF-DUE-DATE
        if(watcherType == 'DUE-DATE')
        {
            //Specified Due Date.
            endDate = (Date)parentRecord.get('Due_Date__c');
        }
        
        //ONCE-OFF-RELATIVE-DATE
        if(watcherType == 'RELATIVE-DATE')
        {
            noDays = Integer.valueOf((Decimal)parentRecord.get('Number_Of_Days__c'));
            if(parentRecord.getSObjectType() == marginRatchetObjectType)
            {
                //if((Date)parentRecord.get('Other_Relative_Date__c') != null)
                //{
                //    tempDate = (Date)parentRecord.get('Other_Relative_Date__c');
                //}
                //else
                //{   //Facility Tranche - use Available End Date
                    if(parentRecord.get('Facility_Tranche__c') != null)
                    {
                        tempDate = (Date)parentRecord.getsObject('Facility_Tranche__r').get('Availability_End_Date__c');
                    }
                    //Facility - use Available End Date
                    else if(parentRecord.get('Facility__c') != null)
                    {
                        tempDate = (Date)parentRecord.getsObject('Facility__r').get('Availability_End_Date__c');
                    }
                    //Agreement - use Termination Date
                    else 
                    {
                        tempDate = (Date)parentRecord.getsObject('Agreement__r').get('Termination_Date__c');
                    }
            	//}
            }
            //Collateral Valuation, Collateral Monitoring and Trigger
            else if(parentRecord.getSObjectType() == collateralValuationObjectType || parentRecord.getSObjectType() == collateralMonitoringObjectType || parentRecord.getSObjectType() == TriggerObjectType)
            {
               // if((Date)parentRecord.get('Other_Relative_Date__c') != null)
               // {
               //     tempDate = (Date)parentRecord.get('Other_Relative_Date__c');
               // }
               // else
               // {    
                    //Agreement - use Termination Date
                    if(parentRecord.get('Agreement__C') != null)
                    {
                        tempDate = (Date)parentRecord.getsObject('Agreement__r').get('Termination_Date__c');
                    }
                    //Collateral - use Expiry Date
                    else 
                    {
                        tempDate = (Date)parentRecord.getsObject('Collateral__r').get('Expiry_Date__c');
                    }
               // }
            }
            
            //Calculate new due date based relative date, frequncy, No days and days
            if(tempDate != null && noDays != null && ((String)parentRecord.get('Days__c') == 'Days Before' || (String)parentRecord.get('Days__c') == 'Days After'))
            {
                System.debug('In schedule');
                endDate = (String)parentRecord.get('Days__c') == 'Days Before' ? tempDate.addDays(-noDays) : tempDate.addDays(noDays);
            }
            else
            {
                endDate = tempDate;
            }
            
        }
        return endDate;
    }
    
    public static Date calculateScheduleEndDate(sObject parentRecord, sObject lowestlevelParent)
    {
        Date endDate = null;
        Integer noDays = 0;
        Date tempDate;
        
        //ONCE-OFF-DUE-DATE
        if((String)parentRecord.get('Frequency__c') == 'Once Off')
        {
            //Specified Due Date.
            endDate = (Date)parentRecord.get('Due_Date__c');
        }
        
        //ONCE-OFF-RELATIVE-DATE
        else
        {
            noDays = Integer.valueOf((Decimal)parentRecord.get('Number_Of_Days__c'));
            //Margin Ratchet
            if(parentRecord.getSObjectType() == marginRatchetObjectType)
            {
               // if((Date)parentRecord.get('Other_Relative_Date__c') != null)
               // {
               //     tempDate = (Date)parentRecord.get('Other_Relative_Date__c');
               // }
               // else
               // {    
                    //Facility Tranche - use Availablity End Date
                    if(parentRecord.get('Facility_Tranche__c') != null)
                    {
                        tempDate = (Date)lowestlevelParent.get('Availability_End_Date__c');
                    }
                    //Facility - use Availablity End Date
                    else if(parentRecord.get('Facility__c') != null)
                    {
                        if((Date)lowestlevelParent.get('Availability_End_Date__c') != null)
                        {
                            tempDate = (Date)lowestlevelParent.get('Availability_End_Date__c');
                        }
                        
                    }
                    //Agreement - use Termination End Date
                    else 
                    {
                        tempDate = (Date)lowestlevelParent.get('Termination_Date__c');
                    }
                //}
            }
            //Collateral Valuation, Collateral Monitoring and Trigger
            else if(parentRecord.getSObjectType() == collateralValuationObjectType || parentRecord.getSObjectType() == collateralMonitoringObjectType || parentRecord.getSObjectType() == triggerObjectType)
            {
               // if((Date)parentRecord.get('Other_Relative_Date__c') != null)
               // {
               //     tempDate = (Date)parentRecord.get('Other_Relative_Date__c');
               // }
               // else
               // {    
                //Agreement - use Termination Date
                if(parentRecord.get('Agreement__C') != null)
                {
                    tempDate = (Date)lowestlevelParent.get('Termination_Date__c');
                }
                //Collateral - use Expiry Date
                else 
                {
                    tempDate = (Date)lowestlevelParent.get('Expiry_Date__c');
                }
               // }
            }
            
             //Calculate new end date based relative date, frequncy, No days and days
            if(tempDate != null && noDays != null && ((String)parentRecord.get('Days__c') == 'Days Before' || (String)parentRecord.get('Days__c') == 'Days After'))
            {
                System.debug('In schedule');
                endDate = (String)parentRecord.get('Days__c') == 'Days Before' ? tempDate.addDays(-noDays) : tempDate.addDays(noDays);
            }
            else
            {
                endDate = tempDate;
            }
            
        }

        return endDate;
    }
    
    public static Date calculateScheduleStartDate(sObject parentRecord, sObject lowestlevelParent)
    {
        Date startDate = null;
        Integer noDays = 0;
        Date tempDate;
        String lowestlevelObjectName = lowestlevelParent.getSObjectType().getDescribe().getName();
        
        
        //ONCE-OFF-DUE-DATE
        if((String)parentRecord.get('Frequency__c') == 'Once Off')
        {
            //Specified Due Date.
            startDate = (Date)parentRecord.get('Due_Date__c');
        }
        
        //ONCE-OFF-RELATIVE-DATE
        else
        {
            noDays = Integer.valueOf((Decimal)parentRecord.get('Number_Of_Days__c'));
            //Signature Date
            if(parentRecord.get('Relative_Date__c') == 'Signature Date')
            {
                tempDate = (Date)lowestlevelParent.get('Signature_Date__c');
            }
            //Effective Date
            else if(parentRecord.get('Relative_Date__c') == 'Effective Date')
            {
                //Facility/Tranche - use Availability Start Date
                if(lowestlevelObjectName == 'Facility_Tranche__c' || lowestlevelObjectName == 'Facility__c') 
                {
                    tempDate = (Date)lowestlevelParent.get('Availability_Start_Date__c');
                }
                //Agreement - use Effective Date
                else
                {
                    tempDate = (Date)lowestlevelParent.get('Effective_Date__c');
                } 
            }
            //Financial Year End
            else if(parentRecord.get('Relative_Date__c') == 'Financial Year End')
            {
                tempDate = (Date)lowestlevelParent.get('Financial_Year_End_Date__c');
            }
            //Other
            else if(parentRecord.get('Relative_Date__c') == 'Other')
            {
                tempDate = (Date)parentRecord.get('Other_Relative_Date__c');
            }
 			
            //Calculate new start date based relative date, frequncy, No days and days
            if(tempDate != null && noDays != null && ((String)parentRecord.get('Days__c') == 'Days Before' || (String)parentRecord.get('Days__c') == 'Days After'))
            {
                System.debug('In schedule');
                startDate = (String)parentRecord.get('Days__c') == 'Days Before' ? tempDate.addDays(-noDays) : tempDate.addDays(noDays);
            }
            else
            {
                startDate = tempDate;
            }
            
        }
        
        System.debug('startDate : ' + startDate);
        return startDate;
    }
    
    public static Date nextBusinessDate(Date inputDate)
    {
        //Convert to date to datetime.
        Datetime convertedDateTime = DateTime.newInstance(inputDate.year(), inputDate.month(),inputDate.day());
        Datetime nextBusinessDateTime = BusinessHours.nextStartDate(businessHoursId, convertedDateTime);
        Date newDate = Date.newInstance(nextBusinessDateTime.year(), nextBusinessDateTime.month(), nextBusinessDateTime.day());
        
        //Return
        return newDate;
    }
    
    public static void insertNotificationParticipants(List<ParticipantWrapper> participantsWrapperList, Id parentId, String parentRecordName)
    {
        List<Notification_Participant__c> notificationParticipants = new List<Notification_Participant__c>();
        parentId.getSObjectType().getDescribe().getName();
        
        try
        {
            //Get all selected participants.
            for(ParticipantWrapper participantWrapper : participantsWrapperList)
            {
                //Selected?
                if(participantWrapper.selected)
                {
                    //New Notification_Participant__c 
                    Notification_Participant__c pNotification = new Notification_Participant__c();
                    pNotification.Participant__c = participantWrapper.participant.Id;
                    
                    //Margin Ratchet
                    if(parentObjectName == 'Margin_Ratchet__c')
                    {
                        pNotification.Margin_Ratchet__c = parentId;
                    }
                    //Collateral Valuation
                    else if(parentObjectName == 'Collateral_Valuation__c')
                    {
                        pNotification.Collateral_Valuation__c = parentId;
                    }
                    //Valuation Monitoring
                    else if(parentObjectName == 'Collateral_Monitoring__c')
                    {
                        pNotification.Collateral_Monitoring__c = parentId;
                    }
                    //Trigger
                    else if(parentObjectName == 'Trigger__c')
                    {
                        pNotification.Trigger__c = parentId;
                    }
                    
                    pNotification.RecordTypeId = NOTI_PARTICIPANT_TYPES.get(parentRecordName).getRecordTypeId();
                    
                    //Add to insert list.
                    notificationParticipants.add(pNotification);
                }
            }
            
            //Insert notification records for both objects.
            if(!notificationParticipants.isEmpty())
            {
                insert notificationParticipants;
            }
        } catch(Exception e)
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }
        
    }
    
    public static void insertNotificationGroups(List<DistroGroupWrapper> DistroGroupWrapperList, Id parentId, String parentRecordName)
    {
        List<Notification_Group__c> notificationGroups = new List<Notification_Group__c>();
        parentObjectName = parentId.getSObjectType().getDescribe().getName();
        
        try
        {
            //Get all selected dsitro group.
            for(DistroGroupWrapper distroGroupWrapper : DistroGroupWrapperList)
            {
                //Selected?
                if(distroGroupWrapper.selected)
                {
                    //New Notification_Participant__c 
                    Notification_Group__c gNotification = new Notification_Group__c();
                    gNotification.Distribution_Group__c = distroGroupWrapper.distroGroup.Id;
                    
                    //Margin Ratchet
                    if(parentObjectName == 'Margin_Ratchet__c')
                    {
                        gNotification.Margin_Ratchet__c = parentId;
                    }
                    //Collateral Valuation
                    else if(parentObjectName == 'Collateral_Valuation__c')
                    {
                        gNotification.Collateral_Valuation__c = parentId;
                    }
                    //Collateral Monitoring
                    else if(parentObjectName == 'Collateral_Monitoring__c')
                    {
                        gNotification.Collateral_Monitoring__c = parentId;
                    }
                    //Trigger
                    else if(parentObjectName == 'Trigger__c')
                    {
                        gNotification.Trigger__c = parentId;
                    }
                    
                    gNotification.RecordTypeId = NOTI_GROUP_TYPES.get(parentRecordName).getRecordTypeId();
                    
                    //Add to insert list.
                    notificationGroups.add(gNotification);
                }
            }
            
            if(!notificationGroups.isEmpty())
            {
                insert notificationGroups;
            }
        }catch(Exception e)
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }
        
    }
    
    public static void insertMarginRatchetConditions(List<FinancialCovenantsWrapper> financialCovenantsWrapperList, Id parentId)
    {
        List<Margin_Ratchet_Conditions__c> marginRatchetConditions = new List<Margin_Ratchet_Conditions__c>();
        parentObjectName = parentId.getSObjectType().getDescribe().getName();
        
        try
        {
            //Get all selected participants.
            for(FinancialCovenantsWrapper eachFinancialCovenantsWrapper : financialCovenantsWrapperList)
            {
                //Selected?
                if(eachFinancialCovenantsWrapper.selected)
                {
                    //New Margin_Ratchet_Conditions__c 
                    Margin_Ratchet_Conditions__c marginRatchetConditionItem = new Margin_Ratchet_Conditions__c();
                    marginRatchetConditionItem.Condition__c = eachFinancialCovenantsWrapper.financialCovenant.Id;
                    
                    //Margin Ratchet
                    if(parentObjectName == 'Margin_Ratchet__c')
                    {
                        marginRatchetConditionItem.Margin_Ratchet__c = parentId;
                    }
                    //Add to insert list.
                    marginRatchetConditions.add(marginRatchetConditionItem);
                }
            }
            
            //Insert notification records for both objects.
            if(!marginRatchetConditions.isEmpty())
            {
                insert marginRatchetConditions;
            }
        } catch(Exception e)
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }
        
    }
    
    public static void insertRelationshipParties(List<RelationshipPartiesWrapper> relationshipPartiesWrapperList, Id parentId)
    {
        List<Relationship_Parties__c> relationshipPartiesList= new List<Relationship_Parties__c>();
        parentObjectName = parentId.getSObjectType().getDescribe().getName();
        Id lowestLevelParentId ;
        String lowestLevelParentName ;
        
        try{
            //Get all selected participants.
            for(RelationshipPartiesWrapper eachRelationshipPartyWrapper : relationshipPartiesWrapperList)
            {
                lowestLevelParentId = eachRelationshipPartyWrapper.partyId;
                lowestLevelParentName = lowestLevelParentId.getSObjectType().getDescribe().getName();
                //Selected?
                if(eachRelationshipPartyWrapper.selected)
                {
                    //New Relationship_Parties__c 
                    Relationship_Parties__c relationshipPartiesItem = new Relationship_Parties__c();
                    
                    //Margin Ratchet
                    if(parentObjectName == 'Margin_Ratchet__c')
                    {
                        relationshipPartiesItem.Margin_Ratchet__c = parentId;
                    }
                    
                    //Agreement Parties
                    if(lowestLevelParentName == 'Agreement_Party__c')
                    {
                        relationshipPartiesItem.Agreement_Party__c = eachRelationshipPartyWrapper.partyId;
                    }
                    //Facility Parties
                    else if(lowestLevelParentName == 'Facility_Party__c')
                    {
                        relationshipPartiesItem.Facility_Party__c = eachRelationshipPartyWrapper.partyId;
                    }                
                    //Tranche Parties
                    else if(lowestLevelParentName == 'Tranche_Party__c')
                    {
                        relationshipPartiesItem.Tranche_Party__c =  eachRelationshipPartyWrapper.partyId;
                    }  
                    
                    //Add to insert list.
                    relationshipPartiesList.add(relationshipPartiesItem);
                }
            }
            
            //Insert notification records for both objects.
            if(!relationshipPartiesList.isEmpty())
            {
                insert relationshipPartiesList;
            }
        } catch(Exception e)
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }
    }
    
    public class ParticipantWrapper
    {
        public Boolean selected { get; set; }
        public advpm__Participant__c participant { get; set; }
        
        //Blank constructor.
        public ParticipantWrapper() { 
        selected = false;}
    }
    
    public class DistroGroupWrapper
    {
        public Boolean selected { get; set; }
        public Distribution_Group__c distroGroup { get; set; }
        
        //Blank constructor.
        public distroGroupWrapper() { 
        selected = false;}
    }
    
    public class FinancialCovenantsWrapper
    {
        public Boolean selected { get; set; }
        public Condition__c financialCovenant { get; set; }
        
        //Blank constructor.
        public FinancialCovenantsWrapper() {
        selected = false;}
    }
    
    public class RelationshipPartiesWrapper
    {
        public Boolean selected { get; set; }
        public Id partyId { get; set; }
        public String partyName { get; set; }
        public String partyType { get; set; }
        
        //Blank constructor.
        public RelationshipPartiesWrapper() {
          selected = false;  
        }
    }
}