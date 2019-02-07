trigger BxdDocumentTrigger on BoxDocument__c (after insert) {
    //AFTER context
    if(Trigger.isAfter && Trigger.isInsert)
    {
        for (BoxDocument__c bxdDoc: Trigger.new) {
            if(bxdDoc != null && (bxdDoc.Prerequisite_Document__c || bxdDoc.Upload_Date__c != null))
            {
                //Skip if it is a batch job.  @Future not allowed.
                if(!System.isBatch())
                {
                    BxdDocumentService.addAdditionalBoxInfo(bxdDoc.Id);
                } 
            }       
        }
    }
    //AFTER Context end.
}