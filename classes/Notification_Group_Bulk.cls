/**
*** CHANGE LOG ***
 
 16/11/2017 - TdB    - Created Class.
 21/02/2018 - TdB    - Add DrawDown and Fit to Lend functionality

**/ 

public class Notification_Group_Bulk {
    
    public List<sObject_Scheduling_Occurences.DistroGroupWrapper> distroGroupsWrapper { get; set; }
    public List<Notification_Group__c> existingNotificationGroup { get; set; }
    public List<Distribution_Group__c> existingnotifications { get; set; }
    public List<sObject> objectParentRecord { get; set; }
    public Set<Id> existingnotificationsSet { get; set; }
    public Map<Id, Id> groupNotificationGroup { get; set; }
    public Boolean showError { get; set; }
    public Id currentObjectId;
    public String currentObjectName; 
    public Id parentObjectId;
    
    public Notification_Group_Bulk()
    {
        //Empty wrappers
        distroGroupsWrapper = new  List<sObject_Scheduling_Occurences.DistroGroupWrapper>();
        existingNotificationGroup = new List<Notification_Group__c>();
        existingnotifications = new  List<Distribution_Group__c>();
        objectParentRecord = new List<sObject>();
        existingnotificationsSet = new Set<Id>();
        groupNotificationGroup = new Map<Id, Id>();
        
        //Get Record Id from URL
        if(ApexPages.currentPage().getParameters().get('sObjectId') != null)
        {
            currentObjectId = Id.valueOf(ApexPages.currentPage().getParameters().get('sObjectId'));
        }
        
        //Get Object API Name based on Id
        currentObjectName = currentObjectId.getSObjectType().getDescribe().getName();
        
        //Margin Ratchet
        if(currentObjectName  == 'Margin_Ratchet__c')
        {
            //Get Margin Ratchet Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Agreement__r.Matter_Deal__c  FROM Margin_Ratchet__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification notifications
            existingNotificationGroup = [SELECT Id, Margin_Ratchet__c,Distribution_Group__c FROM Notification_Group__c WHERE Margin_Ratchet__c = : currentObjectId];
        }
        //Collateral Vaulation
        else if(currentObjectName  == 'Collateral_Valuation__c')
        {
            //Get Collateral Vaulation Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Deal__c  FROM Collateral_Valuation__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification notifications
            existingNotificationGroup = [SELECT Id, Collateral_Valuation__c,Distribution_Group__c FROM Notification_Group__c WHERE Collateral_Valuation__c = : currentObjectId];
        }
        //Collateral Monitoring
        else if(currentObjectName  == 'Collateral_Monitoring__c')
        {
            //Get Collateral Vaulation Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Deal__c  FROM Collateral_Monitoring__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification notifications
            existingNotificationGroup = [SELECT Id, Collateral_Monitoring__c,Distribution_Group__c FROM Notification_Group__c WHERE Collateral_Monitoring__c = : currentObjectId];
        }
        //Trigger
        else if(currentObjectName  == 'Trigger__c')
        {
            //Get Trigger Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Deal__c  FROM Trigger__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification notifications
            existingNotificationGroup = [SELECT Id, Trigger__c,Distribution_Group__c FROM Notification_Group__c WHERE Trigger__c = : currentObjectId];
        }
        //DrawDown
        else if(currentObjectName  == 'Drawdown__c')
        {
            //Get Trigger Record (sObject)
            objectParentRecord = [SELECT Id, Agreement__c, Deal__c  FROM Drawdown__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification notifications
            existingNotificationGroup = [SELECT Id, Drawdown__c,Distribution_Group__c FROM Notification_Group__c WHERE Drawdown__c = : currentObjectId];
        }
        //Fit to Lend
        else if(currentObjectName  == 'Fit_To_Lend_Checklist__c')
        {
            //Get Trigger Record (sObject)
            objectParentRecord = [SELECT Id, Deal__c  FROM Fit_To_Lend_Checklist__c WHERE Id = :currentObjectId limit 1];
            //Get existing Notification notifications
            existingNotificationGroup = [SELECT Id, Fit_To_Lend__c,Distribution_Group__c FROM Notification_Group__c WHERE Fit_To_Lend__c = : currentObjectId];
        }
        
        if(objectParentRecord.size() > 0)
        {
            //Call class with method to get list of notifications
            sObject_Scheduling_Occurences.getDistributionGroupList();
            //Get notifications linked to Agreement
            existingnotifications = sObject_Scheduling_Occurences.distroGroups;
        }
        
        
        if(!existingNotificationGroup.isEmpty())
        {
            //Build a set of existing Notification notifications
            for(Notification_Group__c eachNotificationnotification : existingNotificationGroup)
            {
                if(!existingnotificationsSet.contains(eachNotificationnotification.Distribution_Group__c))
                {
                    existingnotificationsSet.add(eachNotificationnotification.Distribution_Group__c);  
                } 
                
                //Add to map for use later to track deselected.
                groupNotificationGroup .put(eachNotificationnotification.Distribution_Group__c, eachNotificationnotification.Id);
            } 
        }
        
        initialiseWrapperList();
    }
    
    public void initialiseWrapperList()
    {
        //Loop through notifications Wrapper, check if notification already created as a Notification notification and flag as True
        for(Distribution_Group__c eachnotification : existingnotifications)
        {
            sObject_Scheduling_Occurences.DistroGroupWrapper wrapperItem = new sObject_Scheduling_Occurences.DistroGroupWrapper();
            wrapperItem.distroGroup = eachnotification;
            
            if(existingnotificationsSet.contains(eachnotification.Id))
            {
                wrapperItem.selected = true;   
            }
            
            //Add to main wrapper list.
            distroGroupsWrapper.add(wrapperItem);
        }
    }
    
    public PageReference saveRecord() 
    {
        
        List<Notification_Group__c> notificationGroupInsert = new List<Notification_Group__c>();
        List<Notification_Group__c> notificationGroupDelete = new List<Notification_Group__c>();
        Map <String, Schema.RecordTypeInfo> NOTI_GROUP_TYPES = Notification_Group__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        //Reset error message.
        showError = true;
        
        //Loop through wrapper list.
        for(sObject_Scheduling_Occurences.DistroGroupWrapper eachWrapper : distroGroupsWrapper)
        {
            //If selected
            if(eachWrapper.selected)
            {
                //One is selected at least.
                showError = false;
                
                if(!existingnotificationsSet.contains(eachWrapper.distroGroup.Id))
                {
                    //New Notification notification
                    Notification_Group__c notificationGroupItem = new Notification_Group__c();
                    //Margin Ratchet
                    if(currentObjectName  == 'Margin_Ratchet__c')
                    {
                        notificationGroupItem.Margin_Ratchet__c = currentObjectId;
                        notificationGroupItem.RecordTypeId = NOTI_GROUP_TYPES.get('Margin Ratchet').getRecordTypeId();
                    }
                    //Collateral Valuation
                    else if(currentObjectName  == 'Collateral_Valuation__c')
                    {
                        notificationGroupItem.Collateral_Valuation__c = currentObjectId;
                        notificationGroupItem.RecordTypeId = NOTI_GROUP_TYPES.get('Collateral Valuation').getRecordTypeId();
                    }
                    //Collateral Monitoring
                    else if(currentObjectName  == 'Collateral_Monitoring__c')
                    {
                        notificationGroupItem.Collateral_Monitoring__c = currentObjectId;
                        notificationGroupItem.RecordTypeId = NOTI_GROUP_TYPES.get('Collateral Monitoring').getRecordTypeId();
                    }
                    //Trigger
                    else if(currentObjectName  == 'Trigger__c')
                    {
                        notificationGroupItem.Trigger__c = currentObjectId;
                        notificationGroupItem.RecordTypeId = NOTI_GROUP_TYPES.get('Trigger').getRecordTypeId();
                    }
                    //DrawDown
                    else if(currentObjectName  == 'Drawdown__c')
                    {
                        notificationGroupItem.Drawdown__c = currentObjectId;
                        notificationGroupItem.RecordTypeId = NOTI_GROUP_TYPES.get('Drawdown').getRecordTypeId();
                    }
                    //Fit to Lend
                    else if(currentObjectName  == 'Fit_To_Lend_Checklist__c')
                    {
                        notificationGroupItem.Fit_To_Lend__c = currentObjectId;
                        notificationGroupItem.RecordTypeId = NOTI_GROUP_TYPES.get('Fit To Lend Checklist').getRecordTypeId();
                    }
                    notificationGroupItem .Distribution_Group__c = eachWrapper.distroGroup.Id;
                    
                    //Add to list.
                    notificationGroupInsert.add(notificationGroupItem );
                }
            }
            //If deselected
            else
            {
                if(existingnotificationsSet.contains(eachWrapper.distroGroup.Id))
                {
                    //Id of notification to delete.
                    Id notificationGroupId = (Id)groupNotificationGroup.get(eachWrapper.distroGroup.Id);
                    
                    //Notification notification to delete.
                    Notification_Group__c notificationGroupToDelete = new Notification_Group__c(Id = notificationGroupId); 
                    
                    //Add to delete list.
                    notificationGroupDelete.add(notificationGroupToDelete);
                }
            }
        }
        
        
        //Execute changes.
        try 
        {
            //Insert new records.
            if(!notificationGroupInsert.isEmpty())
            {
                insert notificationGroupInsert;
            }
            
            //Delete deselected records.
            if(!notificationGroupDelete.isEmpty())
            {
                delete notificationGroupDelete;
            }
            
            //New Page Setup
            PageReference standardPage = new PageReference('/'+ currentObjectId); 
            standardPage.setRedirect(true);
            
            //Redirect.
            return standardPage;
        }
        catch(Exception e)
        {
            //Error Message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'Error: '+e.getMessage()));
        }
        return null;
    }
}