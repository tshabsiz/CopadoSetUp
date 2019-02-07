/**
* 2017-03-14
* Rudolf Niehaus - CloudSmiths
* Default Case Comment trigger
**/
trigger Case_Comment_Trigger on CaseComment (before delete, after insert) {
    
    
	//block any case comment deletion for any case type by any user
    if(trigger.isBefore && trigger.isDelete){
    	for(CaseComment cmt : Trigger.old){    
        	cmt.addError('You cannot Delete Case Comments. Update your comment instead');
    	}
    }
    //New Case Comments 
    if(trigger.isAfter && trigger.isInsert){
    	Case_Comment_Trigger_Functions.resetCaseFlags(trigger.new);
    }
}