/**
* @Author       Unknown
* @Company:     Deloitte
* @Description: OpportunityTeamMember Trigger
* @Date:        2015
* @ConstructorParam:      None
* 
* History
* 01-Jul-2017	Mohsin Wadee	SFA-327     Removed call to OpportunityTeamMemberTrigger_Helper.checkCompliance() in the
*											before insert and before update trigger checks as a banker can now be added as a team member 
*											regardless of an opportunity that is private or public, 
*											or if the 'The accountable banker has been cleared' checkbox is ticked 
*											in the opportunity.

*31 August 2017 Sizwe Tshabalala SFA 1281 Uncommented the above (OpportunityTeamMemberTrigger_Helper.checkCompliance() because business
				requiress that you confirm that the team member has been cleared.
*-------------------------------------------------------------------------------------------------------------------------------*/


trigger OpportunityTeamMemberTrigger on OpportunityTeamMember (before insert, after insert, before update, after delete) {

	//before insert
    if(Trigger.isBefore && Trigger.isInsert){
    	OpportunityTeamMemberTrigger_Helper.checkCompliance(Trigger.new);
    }
    
    //after insert
    if(Trigger.isAfter && Trigger.isInsert){
    	OpportunityTeamMemberTrigger_Helper.followOpportunityByTeamMember(Trigger.new);
    	OpportunityTeamMemberTrigger_Helper.addPostToOpportunityTeamMember(Trigger.newMap);
        OpportunityTeamMemberTrigger_Helper.shareJlocsWithOpportunityTeamMembers(Trigger.newMap);
    }
    //before update
    if(Trigger.isBefore && Trigger.isUpdate){
    }
    //after delete
    if(Trigger.isAfter && Trigger.isDelete){
        OpportunityTeamMemberTrigger_Helper.stopFollowingOpportunityByTeamMember(Trigger.old);
        OpportunityTeamMemberTrigger_Helper.stopSharingJlocsWithOpportunityTeamMembers(Trigger.old);
    }
}