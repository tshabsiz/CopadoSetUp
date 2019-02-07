trigger FitToLend_Trigger on Fit_To_Lend_Checklist__c (after update) 
{
    //Blank vars.
    Set<Id> fitToLendIds = new Set<Id>();
    
    //After Update
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        System.debug('### Approval_Trigger : AFTER UPDATE : START');
        
        //Loop through updated records.
        for(Fit_To_Lend_Checklist__c checklist : Trigger.new)
        {
            //Previous record and its values.
            Fit_To_Lend_Checklist__c oldChecklist = Trigger.oldMap.get(checklist.Id);
            
            //Moved to approved.
            if(oldChecklist.Status__c != 'Approved' && checklist.Status__c == 'Approved')
            {
               fitToLendIds.add(checklist.Id); 
            }
        }
        
        //Anything to process
        if(!fitToLendIds.isEmpty())
        {
            FitToLend_Helper.sendNotificationEmails(fitToLendIds);
        }
        
        System.debug('### Approval_Trigger : AFTER UPDATE : END');
    }
}