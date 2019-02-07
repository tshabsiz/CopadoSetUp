/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
12/09/2017 - PG    - Created Trigger. 
13/03/2018 - TdB   - Add updateCurrencyIsoCode(); before insert and update to set Currency based on Facility Currency
                                                   
**/ 
trigger Facility_Tranche_Trigger on Facility_Tranche__c (after update, after insert, before insert, before Update) 
{
	//After Insert Context
	if(Trigger.isAfter && Trigger.isInsert)
	{
		//Helper class.
		Facility_Tranche_Helper.afterInsert(Trigger.new); 
	} 
	//After Insert Context End. 
	
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        Facility_Tranche_Helper.updateWatcherOccurence(Trigger.OldMap, Trigger.NewMap);
    }
    
    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
    {
        Facility_Tranche_Helper.updateCurrencyIsoCode(Trigger.new);
    }
}