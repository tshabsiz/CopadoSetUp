/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 19/11/2017 - TdB    - Created Class.
 22/01/2018 - TdB 	 - Set From email address to xracscsupport@barclayscapital.com
 12/02/2018 - TdB   - Remove Status__c refrences on Watcher

**/ 
public class Watcher_Helper {
    
    public static Map <String, Schema.RecordTypeInfo> Watcher_RecordTypes = Watcher__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    
    public static void createNextWatcherOccurence(Map<Id,Watcher__C> watcherOldMap, Map<Id,Watcher__C> watcherNewMap)
    {
        //Add all parentId's to a Set
        sObject parentRecord;
        Set<Id> parentIdSet = new Set<Id>();
        Set<Id> marginRatchetIdSet = new Set<Id>();
        Set<Id> collateralValuationIdSet = new Set<Id>();
        Set<Id> collateralMonitoringIdSet = new Set<Id>();
        Set<Id> triggerIdSet = new Set<Id>();
        Watcher__C watcherItem = new Watcher__C();
        List<Watcher__C> watcherInsertList = new List<Watcher__C>();
        Map<Id, sObject> parentMap;
        
        for(Id eachWatcher : watcherNewMap.keySet())
        {
           // parentIdSet.add(watcherNewMap.get(eachWatcher).Margin_Ratchet__C);
            //Margin Ratchet
            if(watcherNewMap.get(eachWatcher).Margin_Ratchet__C != null)
            {
                marginRatchetIdSet.add(watcherNewMap.get(eachWatcher).Margin_Ratchet__C);
            }
            //Collateral Valuation
            else if (watcherNewMap.get(eachWatcher).collateral_Valuation__c != null)
            {
                collateralValuationIdSet.add(watcherNewMap.get(eachWatcher).collateral_Valuation__c);
            }  
            //Collateral Monitoring
            else if (watcherNewMap.get(eachWatcher).collateral_Monitoring__c != null)
            {
                collateralMonitoringIdSet.add(watcherNewMap.get(eachWatcher).collateral_Monitoring__c);
            }   
            //Trigger
            else if (watcherNewMap.get(eachWatcher).Trigger__c != null)
            {
                TriggerIdSet.add(watcherNewMap.get(eachWatcher).Trigger__c);
            }   
        }
        
        if(marginRatchetIdSet.size() > 0)
        {
        	parentMap = new Map<Id, sObject>([SELECT Schedule_Start_Date__c, Schedule_End_Date__c, Id, Frequency__c, Number_of_Days__c, Days__c, Facility__c, Facility_Tranche__c, Agreement__c 
                                          FROM Margin_Ratchet__c
                                          WHERE Id IN : marginRatchetIdSet]);
        }else if (collateralValuationIdSet.size() > 0)
        {
            parentMap = new Map<Id, sObject>([SELECT Schedule_Start_Date__c, Schedule_End_Date__c, Id, Frequency__c, Number_of_Days__c, Days__c, Collateral__c, Agreement__c, Deal__c
                                          FROM Collateral_Valuation__c
                                          WHERE Id IN : collateralValuationIdSet]);
        }else if (collateralMonitoringIdSet.size() > 0)
        {
            parentMap = new Map<Id, sObject>([SELECT Schedule_Start_Date__c, Schedule_End_Date__c, Id, Frequency__c, Number_of_Days__c, Days__c, Collateral__c, Agreement__c, Deal__c
                                          FROM Collateral_Monitoring__c
                                          WHERE Id IN : collateralMonitoringIdSet]);
        
        }else if (TriggerIdSet.size() > 0)
        {
            parentMap = new Map<Id, sObject>([SELECT Schedule_Start_Date__c, Schedule_End_Date__c, Id, Frequency__c, Number_of_Days__c, Days__c, Agreement__c, Deal__c
                                          FROM Trigger__c
                                          WHERE Id IN : TriggerIdSet]);
        }
        
        //If status updated to anything except "New", create next watcher Occurence record
        for(Id eachWatcher : watcherNewMap.keyset())
        {
            System.debug('###eachWatcher.getSobjectType() :' + eachWatcher.getSobjectType());
            //Margin Ratchet
            if(watcherNewMap.get(eachWatcher).Margin_Ratchet__C != null)
            {
                parentRecord = parentMap.get(watcherOldMap.get(eachWatcher).Margin_Ratchet__C);
                watcherItem.Margin_Ratchet__c = watcherOldMap.get(eachWatcher).Margin_Ratchet__C;
                watcherItem.RecordTypeId = Watcher_RecordTypes.get('Margin Ratchet').getRecordTypeId();
            }
            //Collateral Valuation
            else if (watcherNewMap.get(eachWatcher).collateral_Valuation__c != null)
            {
                parentRecord = parentMap.get(watcherOldMap.get(eachWatcher).Collateral_Valuation__c);
                watcherItem.Collateral_Valuation__c = watcherOldMap.get(eachWatcher).Collateral_Valuation__c;
                watcherItem.RecordTypeId = Watcher_RecordTypes.get('Collateral Valuation').getRecordTypeId();
            }
            //Collateral Monitoring
            else if (watcherNewMap.get(eachWatcher).collateral_Monitoring__c != null)
            {
                parentRecord = parentMap.get(watcherOldMap.get(eachWatcher).Collateral_Monitoring__c);
                watcherItem.Collateral_Monitoring__c = watcherOldMap.get(eachWatcher).Collateral_Monitoring__c;
                watcherItem.RecordTypeId = Watcher_RecordTypes.get('Collateral Monitoring').getRecordTypeId();
            }
            //Trigger
            else if (watcherNewMap.get(eachWatcher).Trigger__c != null)
            {
                parentRecord = parentMap.get(watcherOldMap.get(eachWatcher).Trigger__c);
                watcherItem.Deal__c = watcherOldMap.get(eachWatcher).Deal__c;
                watcherItem.Trigger__c = watcherOldMap.get(eachWatcher).Trigger__c;
                watcherItem.RecordTypeId = Watcher_RecordTypes.get('Trigger').getRecordTypeId();
            }
            
            if((watcherOldMap.get(eachWatcher).Watcher_status__c == 'New' || watcherOldMap.get(eachWatcher).Watcher_status__c == 'Due' || watcherOldMap.get(eachWatcher).Watcher_status__c == 'Overdue') && (watcherNewMap.get(eachWatcher).Watcher_status__c != 'New'  && watcherNewMap.get(eachWatcher).Watcher_status__c != 'Due'  && watcherNewMap.get(eachWatcher).Watcher_status__c != 'Overdue') && parentRecord.get('Frequency__c') != 'Once Off')
            {
                //Calculate next Occurence date
                if((watcherOldMap.get(eachWatcher).Due_Date__c) != null)
                {
                    watcherItem.Due_Date__c = calculateWatcherDueDate(parentRecord,(watcherOldMap.get(eachWatcher).Due_Date__c));
                    
                    if((Date)parentRecord.get('Schedule_End_Date__c') == null)
                    {
                        watcherInsertList.add(watcherItem);
                    }
                    else if((Date)parentRecord.get('Schedule_End_Date__c') >= watcherItem.Due_Date__c)
                    {
                        watcherInsertList.add(watcherItem);
                    }
                }
            }
        }
        
        if(watcherInsertList.size() > 0)
        {
            insert watcherInsertList;
        }
    }
    
    public static Date calculateWatcherDueDate(sObject parentRecord, Date prevOccurenceDate)
    {
        Date watcherDueDate = null;
        String parentObjectName = '';
        Id parentObjectId ;
        String frequency = '';
        
        //Get inserted parent
        parentObjectId = (Id)parentRecord.get('Id');
        parentObjectName = parentObjectId.getSObjectType().getDescribe().getName();

            frequency = (String)parentRecord.get('Frequency__c');
        
        //Monthly
        if (frequency != null)
        {
            if(frequency == 'Monthly')
            {
                watcherDueDate = prevOccurenceDate.addMonths(1);
            }
            //Quarterly
            else if(frequency == 'Quarterly')
            {
                watcherDueDate = prevOccurenceDate.addMonths(3);
            }
            //Bi-Annually
            else if(frequency == 'Bi-Annually')
            {
                watcherDueDate = prevOccurenceDate.addMonths(6);
            }
            //Annually
            else if(frequency == 'Annually')
            {
                watcherDueDate = prevOccurenceDate.addYears(1);
            }
        }
        return sObject_Scheduling_Occurences.nextBusinessDate(watcherDueDate);
    }
    
    public static void sendNotification(List<Watcher__c> watcherList)
    {
        Map<Id,Id> marginRatchetWatcherMap = new Map<Id, Id>();
        Map<Id,Id> collateralValuationWatcherMap = new Map<Id, Id>();
        Map<Id,Id> collateralMonitoringWatcherMap = new Map<Id, Id>();
        Map<Id,Id> triggerWatcherMap = new Map<Id, Id>();
        
        //Get any contact for email template.  Never emailed...
        Id randomContactId = [SELECT Id FROM Contact WHERE Email != null LIMIT 1].Id;
        
        //Final list of all email messages for sending.
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();
        
        List<OrgWideEmailAddress> OrgWideEmails = [select Id from OrgWideEmailAddress where Address = 'xracscsupport@barclayscapital.com'];
        
        //Get the ids of the email template
        Id marginRatcherBreachedEmailTemplateId = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Margin_Ratchet_Breached'].Id;
        Id collateralValuationEmailTemplateId = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Collateral_Valuation_Concern_Escalated'].Id;
        Id collateralMonitoringEmailTemplateId = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Collateral_Monitoring_Expectation_Not_Met'].Id;
        Id triggerEmailTemplateId = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'TMG_Trigger_Breached'].Id;
        
        for(Watcher__c eachWatcher : watcherList)
        {
            if(eachWatcher.Margin_Ratchet__c != null)
            {
                marginRatchetWatcherMap.put(eachWatcher.Margin_Ratchet__c, eachWatcher.Id);
            }
            else if(eachWatcher.Collateral_Valuation__c != null)
            {
                collateralValuationWatcherMap.put(eachWatcher.Collateral_Valuation__c, eachWatcher.Id);
            } 
            else if(eachWatcher.Collateral_Monitoring__c != null)
            {
                collateralMonitoringWatcherMap.put(eachWatcher.Collateral_Monitoring__c, eachWatcher.Id);
            } 
            else if(eachWatcher.Trigger__c != null)
            {
                triggerWatcherMap.put(eachWatcher.Trigger__c, eachWatcher.Id);
            } 
        }     
        
        //Notification Participants
        for(Notification_Participant__c eachParticipant : [SELECT Id, Email_Address__c, Margin_Ratchet__c, Collateral_Valuation__c, Collateral_Monitoring__c, Trigger__c
                                                                       FROM Notification_Participant__c
                                                                       WHERE Margin_Ratchet__c IN : marginRatchetWatcherMap.keySet()
                                                          				OR Collateral_Valuation__c IN : collateralValuationWatcherMap.keySet()
                                                          				OR Collateral_Monitoring__c IN : collateralMonitoringWatcherMap.keySet()
                                                          				OR Trigger__c IN : triggerWatcherMap.keySet()])
        {
            //Group email address.
            List<String> toAddresses = new List<String> { eachParticipant.Email_Address__c };
                
            //Single email object.
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setTargetObjectId(randomContactId);
            singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
            singleEmail.setToAddresses(toAddresses);
            if ( OrgWideEmails.size() > 0 ) 
            {
                singleEmail.setOrgWideEmailAddressId(OrgWideEmails.get(0).Id);
            }
            if(eachParticipant.Margin_Ratchet__c != null)
            {
                singleEmail.setWhatId(marginRatchetWatcherMap.get(eachParticipant.Margin_Ratchet__c));
                singleEmail.setTemplateId(marginRatcherBreachedEmailTemplateId);
            }
            else if(eachParticipant.Collateral_Valuation__c != null)
            {
                singleEmail.setWhatId(collateralValuationWatcherMap.get(eachParticipant.Collateral_Valuation__c));
                singleEmail.setTemplateId(collateralValuationEmailTemplateId);
            }
            else if(eachParticipant.Collateral_Monitoring__c != null)
            {
                singleEmail.setWhatId(collateralMonitoringWatcherMap.get(eachParticipant.Collateral_Monitoring__c));
                singleEmail.setTemplateId(collateralMonitoringEmailTemplateId);
            }
            else if(eachParticipant.Trigger__c != null)
            {
                singleEmail.setWhatId(triggerWatcherMap.get(eachParticipant.Trigger__c));
                singleEmail.setTemplateId(triggerEmailTemplateId);
            }

            //Add to list.
            emailMessages.add(singleEmail);
        }
		
        //Notification Group
        for(Notification_Group__c eachGroup : [SELECT Id, Distribution_Group__r.Email_Address__c, Margin_Ratchet__c, Collateral_Valuation__c, Collateral_Monitoring__c, Trigger__c
                                               FROM Notification_Group__c
                                               WHERE Margin_Ratchet__c IN : marginRatchetWatcherMap.keySet()
                                               OR Collateral_Valuation__c IN : collateralValuationWatcherMap.keySet()
                                               OR Collateral_Monitoring__c IN : collateralMonitoringWatcherMap.keySet()
                                               OR Trigger__c IN : triggerWatcherMap.keySet()])
        {
            //Group email address.
            List<String> toAddresses = new List<String> { eachGroup.Distribution_Group__r.Email_Address__c };
                
            //Single email object.
            Messaging.SingleEmailMessage singleEmail = new Messaging.SingleEmailMessage();
            singleEmail.setTargetObjectId(randomContactId);
            singleEmail.setTreatTargetObjectAsRecipient(false); //Prevent sending to random contact
            singleEmail.setToAddresses(toAddresses);
            if ( OrgWideEmails.size() > 0 ) 
            {
                singleEmail.setOrgWideEmailAddressId(OrgWideEmails.get(0).Id);
            }
            if(eachGroup.Margin_Ratchet__c != null)
            {
				singleEmail.setWhatId(marginRatchetWatcherMap.get(eachGroup.Margin_Ratchet__c));   
                singleEmail.setTemplateId(marginRatcherBreachedEmailTemplateId);
            }
            else if (eachGroup.Collateral_Valuation__c != null)
            {
                singleEmail.setWhatId(collateralValuationWatcherMap.get(eachGroup.Collateral_Valuation__c));  
                singleEmail.setTemplateId(collateralValuationEmailTemplateId);
            }
            else if (eachGroup.Collateral_Monitoring__c != null)
            {
                singleEmail.setWhatId(collateralMonitoringWatcherMap.get(eachGroup.Collateral_Monitoring__c));  
                singleEmail.setTemplateId(collateralMonitoringEmailTemplateId);
            }
            else if (eachGroup.Trigger__c != null)
            {
                singleEmail.setWhatId(triggerWatcherMap.get(eachGroup.Trigger__c));  
                singleEmail.setTemplateId(triggerEmailTemplateId);
            }

            
            //Add to list.
            emailMessages.add(singleEmail);
        }
        
        //Send emails.
        if(emailMessages.size() > 0)
        {
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailMessages);
        } 
    }
}