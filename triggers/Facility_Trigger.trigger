/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
12/09/2017 - PG    - Created Trigger. 
13/03/2018 - TdB - Only run Trigger when "checkRecursion.canIRun() == True"  - To avoid duplicates when cloning an Agreement
13/03/2018 - TdB   - Add updateTrancheCurrencyIsoCode(); - Update related Tranches with updated Currency
                                                   
**/ 
trigger Facility_Trigger on Facility__c (after insert, after update) 
{
    if(checkRecursion.canIRun() == True)
    {
        //After Insert Context
        if(Trigger.isAfter && Trigger.isInsert)
        {
            //Helper class.
            Facility_Helper.afterInsert(Trigger.new); 
        } 
        //After Insert Context End. 
        
        if(Trigger.isAfter && Trigger.isUpdate)
        {
            Facility_Helper.updateWatcherOccurence(Trigger.OldMap, Trigger.NewMap);
            Facility_Helper.updateTrancheCurrencyIsoCode(Trigger.new);
        }
    }
}