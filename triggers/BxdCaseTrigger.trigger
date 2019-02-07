trigger BxdCaseTrigger on Case (after insert) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            if(MatterHandler_CaseConvert.convertedMatter == Null){
                BxdCaseService.createBoxFolderTrigger(Trigger.new);
            }
            
        }
        //INSERT context end.
    }
    //AFTER Context end.
}