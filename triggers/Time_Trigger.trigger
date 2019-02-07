/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
**/      
trigger Time_Trigger on advpm__Time__c (before insert) {

/*
    List<Id> matterIdList { get; set; }
    Id userId = UserInfo.getUserId();
    
    //BEFORE CONTEXT
    if(Trigger.isBefore)
    {
        //INSERT CONTEXT
        if(Trigger.isInsert)
        {  
            //Clear map & list.
            matterIdList = new List<Id>();
            
            //Loop through records.
            for(advpm__Time__c timeEntry : Trigger.new)
            {
                //Linked to a matter
                if(!String.isBlank(timeEntry.advpm__Matter__c))
                {   
                    //Selected matter id
                    matterIdList.add(timeEntry.advpm__Matter__c);
                }
            }
            System.debug('### Time_Trigger : matterIdSet : '+matterIdList);
            
            //Get a Map of matters where the user is a participant.
            Map<Id, advpm__Matter__c> matterMap = new Map<Id, advpm__Matter__c>(
                [
                    SELECT 
                        Id,
                        OwnerId
                    FROM 
                        advpm__Matter__c
                    WHERE 
                        Id IN (SELECT advpm__Matter__c FROM advpm__Participant__c WHERE advpm__Staff__c = :userId) AND Id IN :matterIdList
                ]
            );
            System.debug('### Time_Trigger : matterMap : '+matterMap);
            
            //Add any matters the user is the owner/lead lawyer of to the matterMap as well.
            for(advpm__Matter__c matterItem : [SELECT Id, OwnerId FROM advpm__Matter__c WHERE Id IN :matterIdList]) 
            {
                if(matterItem.OwnerId == userId)
                {
                    matterMap.put(matterItem.Id, matterItem);
                }
            }
            System.debug('### Time_Trigger : matterMap : '+matterMap);
            
            //Loop again and add errors
            for(advpm__Time__c timeEntry : Trigger.new)
            {
                System.debug('### Time_Trigger : timeEntry.advpm__Matter__c : '+timeEntry.advpm__Matter__c);
                
                //Linked to a matter
                if(!String.isBlank(timeEntry.advpm__Matter__c))
                {
                    //Is this in a map of matter we are a participant in OR the owner of?
                    if(matterMap.get(timeEntry.advpm__Matter__c) == null)
                    {
                        //Show error.
                        timeEntry.addError('You may not add time for a Matter / Deal which you are not a participant on.');
                    }
                    else {
                        System.debug('### Time_Trigger : FOUND MATTER : ');
                    }
                }
            }
            
        }
    }
    */
}