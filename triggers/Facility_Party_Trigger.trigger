/**
 
*** CHANGE LOG ***

13/12/2017 - TdB    - Created Trigger. 

**/
trigger Facility_Party_Trigger on Facility_Party__c (before update) 
{
    if(Trigger.isBefore && Trigger.isUpdate)
	{
		Facility_Party_Helper.calculateLenderPortion(Trigger.new, Trigger.oldMap);
	}
}