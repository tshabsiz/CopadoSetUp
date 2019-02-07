trigger BxdWatcherTrigger on Watcher__c (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            BxdWatcherService.createBoxFolderTrigger(Trigger.new);
        }
    }
}