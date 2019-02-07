/**
* Date   : 2017-10-19
* Author : RN - CloudSmiths AUS
* Desc   : Class with methods that suports the notes deafult  trigger
**/
public class Notes_Trigger_Functions {
    
    public static void blockFTLNotes(list<Note> notelst){
        for(Note n :notelst){
            Id pid = n.ParentId;
            if(String.isNotBlank(pid)){
                if(pid.getSObjectType().getDescribe().getName() == 'Fit_To_Lend_Checklist__c'){
                    n.addError('You are not allowed to add any Notes to this Fit To Lend record'); 
                }
            }
        }     
    }
}