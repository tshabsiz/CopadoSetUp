/****************************************************************************
* @Author     : Daniel Field
* @Date       : 12/09/2017
* @Description: Trigger used to set relationship/account on delegate when conact__c field on delegate changes, and add primary host of delegate as a host on the host related list of the delegate
* @Purpose    : Trigger
* @Pages      : N/A
* @Test Class : evDelegate_Trigger_Test
-----------------------------------------------------------------------------
2017-10-10 DF : updating to handle inserts that have a host already created
****************************************************************************/
trigger evDelegate_Trigger on Delegate__c (before insert,after insert, after update, before update, Before Delete) 
{
    if
        (
            (trigger.isBefore && (trigger.isUpdate || trigger.isInsert))
            || 
            (trigger.isAfter && (trigger.isUpdate || trigger.isInsert))
        )
    {
        
      /*  for(delegate__c DelRec : trigger.new )
        {
            if(DelRec.Invitation_Status__c != null && DelRec.Invitation_Status__c !='Proposed' )
            {
                DelRec.Invitation_Status__c.adderror('Delegates may only be deleted if their invatation status is blank or \'Proposed\'');
                continue;
                
            }
        }*/
        
        Set<id> DelegateContactIDSet = new set<id>();
        Set<id> DelegateHostIdSet = new set<id>();
        Set<id> DelegateHostList = new set<id>();
        Set<id> DelegateIDSet = new set<id>();
        map<id,Contact> ContactMap;
        map<id,Event_Team_Member__c> eventTeamMemberMap;
        List<Delegate__c> DelegateHostUpdateList ;
        
        for(delegate__C Del : trigger.new)
        {
            if(trigger.isUpdate)//if trigger is update
            {
                Delegate__c oldDel = trigger.oldmap.get(Del.id);
                if(oldDel.Contact__c !=  del.Contact__c)//add contact id to DelegateContactIDSet if the contact has changed
                {
                    DelegateContactIDSet.add(Del.contact__c);
                }
                if(oldDel.Host__c !=  del.Host__c)//add del id to DelegateIDSet if the Host has changed, and add host id to DelegateHostIdSet
                {
                    DelegateIDSet.add(del.id);
                    DelegateHostIdSet.add(del.Host__c);
                }
                
            }
            else if(trigger.isInsert)//if trigger is insert add contact id to DelegateContactIDSet to ensure the account on del is correct
            {
                DelegateContactIDSet.add(Del.contact__c);
            }
        }
        
        ContactMap = new map<id,contact>
            ([
                SELECT
                id,
                name,
                accountid
                FROM
                contact
                where 
                id in  : DelegateContactIDSet
            ]);
        
        if((trigger.isUpdate && trigger.isBefore) || (trigger.isInsert && trigger.isBefore) )
        { 
            for(delegate__C Del : trigger.new)//loop through delegates being changed and ensure they have the right account.(Based on the contact account)
            {
                Contact Con =  ContactMap.get(Del.contact__c);
                if(con!= null)
                {
                    if(trigger.isUpdate && trigger.isBefore)
                    {
                        Delegate__c oldDel = trigger.oldmap.get(Del.id);//get old value to ensure it needs to be changed.
                        if(oldDel.Contact__c !=  del.Contact__c)
                        {
                            del.Account__c = con.accountid;
                        }
                    }
                    else if(trigger.isInsert && trigger.isBefore)//if insert, always set it
                    {
                        del.Account__c = con.accountid;
                    }
                }
            }
        }
        if(trigger.isUpdate && trigger.isAfter)
        {
            DelegateHostUpdateList = new list<delegate__c>//select delegates who's primary host is being changed and their releated hosts
                ([
                    SELECT
                    id,
                    name,
                    host__c,
                    (
                        SELECT
                        ID,
                        name,
                        Event_Team_Member__c
                        FROM
                        Team_Members_Delegates_Delegate__r
                    )
                    FROM
                    delegate__c
                    where 
                    id in  : DelegateIDSet
                ]);
            
            list<Event_Team_Members_Delegates__c> ListOfETMDToInsert = new list<Event_Team_Members_Delegates__c>();
            
            for(delegate__c Del : DelegateHostUpdateList )
            {
                system.debug('Del.Host__c' + Del.host__c);
                boolean isPrimaryHostOnRelatedList = false;
                for(Event_Team_Members_Delegates__c ETMD :  del.Team_Members_Delegates_Delegate__r)//run trough related hosts for each delegate and check if primaty host is already a host on the related list
                {
                    if(Del.Host__c == ETMD.Event_Team_Member__c)
                    {
                        isPrimaryHostOnRelatedList = true;//if the primary host is on the related list then isPrimaryHostOnRelatedList set to true
                    }
                }
                
                
                delegate__c newDelRec = trigger.newmap.get(del.id);
                if(isPrimaryHostOnRelatedList == false && newDelRec.Host__c != null)// if isPrimaryHostOnRelatedList =  false, then create a new host record for the delegate and  add to ListOfETMDToInsert to insert later.
                {
                    Event_Team_Members_Delegates__c NewETMD = new Event_Team_Members_Delegates__c
                        (
                            Delegate__c = del.id,
                            Event_Team_Member__c = newDelRec.Host__c
                        );
                    ListOfETMDToInsert.add(NewETMD);
                }
            }
            system.debug(' delegate update insertListOfETMDToInsert' + ListOfETMDToInsert);
            Insert ListOfETMDToInsert;
        }
        
        if(trigger.isInsert && trigger.isAfter)
        {
            list<Event_Team_Members_Delegates__c> ListOfETMDToInsert = new list<Event_Team_Members_Delegates__c>();
            set<id> DelegateIDSetForAfterInsert = new set<id>();
            for(delegate__C Del : trigger.new)
            {
                DelegateIDSetForAfterInsert.add(Del.id);
                
            }
            
            list<Event_Team_Members_Delegates__c>    temp = new list<Event_Team_Members_Delegates__c>//select delegates who's primary host is being changed and their releated hosts
                ([
                    SELECT
                    id,
                    name,
                    delegate__c
                    
                    FROM
                    Event_Team_Members_Delegates__c
                    where  
                    delegate__c in  : DelegateIDSetForAfterInsert
                ]);
            
            system.debug(' delegate insert temp' + temp);
            list<delegate__c>    DelegateHostCheckList = new list<delegate__c>//select delegates who's primary host is being changed and their releated hosts
                ([
                    SELECT
                    id,
                    name,
                    host__c,
                    (
                        SELECT
                        ID,
                        name,
                        Event_Team_Member__c
                        FROM
                        Team_Members_Delegates_Delegate__r
                    )
                    FROM
                    delegate__c
                    where  
                    id in  : DelegateIDSetForAfterInsert
                ]);
            
            system.debug(' delegate insert DelegateHostCheckList[0].Team_Members_Delegates_Delegate__r' + DelegateHostCheckList[0].Team_Members_Delegates_Delegate__r);
            for(delegate__C Del : DelegateHostCheckList)
            {
                
                boolean isPrimaryHostOnRelatedList = false;
                for(Event_Team_Members_Delegates__c ETMD :  del.Team_Members_Delegates_Delegate__r)//run trough related hosts for each delegate and check if primaty host is already a host on the related list
                {
                    system.debug(' delegate insert ETMD.Event_Team_Member__c' + ETMD.Event_Team_Member__c);
                    system.debug(' delegate insert Del.Host__c' + Del.Host__c);
                    if(Del.Host__c == ETMD.Event_Team_Member__c)
                    {
                        isPrimaryHostOnRelatedList = true;//if the primary host is on the related list then isPrimaryHostOnRelatedList set to true
                    }
                }
                
                system.debug(' delegate insert isPrimaryHostOnRelatedList' + isPrimaryHostOnRelatedList);
                
                if(Del.Host__c !=  null && isPrimaryHostOnRelatedList == false)
                {
                    Event_Team_Members_Delegates__c NewETMD = new Event_Team_Members_Delegates__c
                        (
                            Delegate__c = del.id,
                            Event_Team_Member__c = Del.Host__c
                        );
                    ListOfETMDToInsert.add(NewETMD);
                }
            }
            system.debug(' delegate insert insertListOfETMDToInsert' + ListOfETMDToInsert);
            try
            {
            Insert ListOfETMDToInsert;
            }
            catch(exception e)
            {
                e.setMessage('Please note there was an error inserting Event Team Members, please try again or contact a system administrator : ' + e.getMessage() );
            }
            }
    }
    
    
    if(trigger.isBefore && trigger.isDelete)
    {
        for(delegate__c DelRec : trigger.old)
        {
            if(DelRec.Invitation_Status__c != null && DelRec.Invitation_Status__c !='Proposed')
            {
                DelRec.Invitation_Status__c.adderror('Delegates may only be deleted if their invatation status is blank or \'Proposed\'');
                continue;
                
            }
        }
    }
}