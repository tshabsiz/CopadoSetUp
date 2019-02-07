/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
*** CHANGE LOG ***
 
 26/10/2017 - PG    - Added "afterInsert" and "beforeDelete".
                    - Formatted class code.
 
**/
trigger BxdParticipantTrigger on advpm__Participant__c (after insert, before delete) {

    //After Insert
    if(Trigger.isAfter && Trigger.isInsert)
    {
        Set<string> Set_id = new Set<String>(); 
           
        for(advpm__Participant__c t:Trigger.new)  
        {
            Set_id.Add(t.id);             
        } 
             
        //BxdMatterDealService.ParticipantCollaberation(Trigger.new);
        BxdMatterDealService.createParticipantCollaberation(Set_id); 
        
        Participant_Helper.afterInsert(Trigger.new);
    }    

    //Before Delete
    if(Trigger.isBefore && Trigger.isDelete)
    {
        Participant_Helper.beforeDelete(Trigger.old); 
    }      
}