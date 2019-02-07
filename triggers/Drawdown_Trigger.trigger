/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
12/07/2017 - PG     - Created trigger.
15/09/2017 - PG     - Removed inline logic and moved logic to helper class.
2017-11-18 - Rudolf Niehaus - CloudSmiths - implement drawdown roll-up calculations                                                   
**/    
trigger Drawdown_Trigger on Drawdown__c (after update, after insert) 
{
    //AFTER UPDATE CONTEXT
    if(Trigger.isAfter)
    {
        List<Drawdown__c> drawdownList  = new List<Drawdown__c>();
        if(Trigger.isUpdate){
            for(Drawdown__c eachDrawdown : Trigger.new)
            {
                if(eachDrawdown.Supporting_Documentation_Uploaded__c == True || eachDrawdown.Status__c == 'Cancelled')
                {
                    drawdownList.add(eachDrawdown);
                }
            }
            
            if(!drawdownList.isEmpty())
            {
                Drawdown_Helper.afterUpdate(drawdownList, Trigger.oldMap);
            } 
        }
        //RN - CloudSmiths
        //Drawdown_Helper.rollUpCalculation(Trigger.new);
    }
    //AFTER UPDATE CONTEXT - END
    
}