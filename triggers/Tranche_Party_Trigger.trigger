/**
 
*** CHANGE LOG ***

13/12/2017 - TdB    - Created Trigger. 

**/
trigger Tranche_Party_Trigger on Tranche_Party__c (before update) 
{
	if(Trigger.isBefore && Trigger.isUpdate)
	{
		Tranche_Party_Helper.calculateLenderPortion(Trigger.new, Trigger.oldMap);
	}
}