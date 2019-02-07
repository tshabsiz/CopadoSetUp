public class ContactTriggerHandler extends TriggerHandler
{
    public override void afterInsert(){
        ContactTrigger_Helper.addToRelationshipGroup(Trigger.New);
    }
}