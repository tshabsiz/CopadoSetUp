/* 20170405
 * RN - CloudSmiths
 * Schedulable apex class that resets the 24 hour limit values 
 * at 02:00Am (GMT+2) in the limits tracking object
 */
global class scheduledResetLimits implements Schedulable {
   global void execute(SchedulableContext SC) {
       resetLimits();
   }
    
   private void resetLimits(){
       
   		list<System_Limits_Tracker__c> resetList = new list<System_Limits_Tracker__c>();
       
        for(System_Limits_Tracker__c tr :[Select Id, X24_Running_Limit__c,Limit_Was_Reset_At__c,Use_WorkAround__c,Warning_Sent__c   
                                          From System_Limits_Tracker__c 
                                          Where Activate_Rule__c = true]){
            tr.X24_Running_Limit__c = 0;
            tr.Limit_Was_Reset_At__c = System.now();
            tr.Use_WorkAround__c = false;
            tr.Warning_Sent__c = false;
            
            resetList.add(tr);
        }
       
        try{
            update resetList;
        }catch(DMLException ex){
            System.debug('There was an error while resetting the limits in the limits tracking object');
            System.debug(ex.getMessage());
        }
   }
}