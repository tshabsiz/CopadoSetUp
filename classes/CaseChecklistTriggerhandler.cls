/*====================================================
@CreatedDate : 2017-11-15
@CreatedBy : Mabhedle Tonga 
@Description : Purpose of this Class is to house all generic functions that are being used across JLOC application
=====================================================*/
public class CaseChecklistTriggerhandler extends Triggerhandler{

    protected override void afterInsert()
    {
        
        if(CaseChecklistTriggerhandler_Functions.getValidHubs().contains(CaseChecklistTriggerhandler_Functions.getUserById(UserInfo.getUserId()).Hub__c)){
            CaseChecklistTriggerhandler_Functions.addToQuestionAnswer(Trigger.New);
        }
        
    }
    
  protected override void afterUpdate()
  {        
      if(CaseChecklistTriggerhandler_Functions.getValidHubs().contains(CaseChecklistTriggerhandler_Functions.getUserById(UserInfo.getUserId()).Hub__c)){
          CaseChecklistTriggerhandler_Functions.addToQuestionAnswer(Trigger.New);
      }
      
  }
}