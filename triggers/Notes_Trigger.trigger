/**
* Date   : 2017-10-19
* Author : RN - CloudSmiths AUS
* Desc   : Default Notes trigger
**/
trigger Notes_Trigger on Note (before insert) {
    
    if(trigger.isBefore){
        if(trigger.isInsert){
            Notes_Trigger_Functions.blockFTLNotes(trigger.new);
        }
    }

}