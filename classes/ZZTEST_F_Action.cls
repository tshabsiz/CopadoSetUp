/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Initiative
*/
@isTest
public class ZZTEST_F_Action {
    public enum ActionRecordType { DEFAULT_ACTION, MEETING_ACTION }

    private static ZZTEST_F_Action instance;

    private Integer productCounter;
    
    private ZZTEST_F_Action() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Action getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Action();
        }
        return instance;
    }

    public Action__c getProduct(ActionRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == ActionRecordType.DEFAULT_ACTION)
            	return getDefaultAction(dataContainer);
            else if (type == ActionRecordType.MEETING_ACTION)
            	return getMeetingAction(dataContainer);
            else
            	return getDefaultAction(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Action__c getInsertedProduct(ActionRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getInsertedDefaultAction(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Action__c getDefaultAction(ZZTEST_DataContainer dataContainer) {
        Action__c action = new Action__c();
        action.Action_Owner__c = UserInfo.getUserId();
        action.Name = 'Action Subject';
        action.Start_Date__c = Date.today();
        action.Due_Date__c = Date.today().addDays(14);

        return action;
    }
    
    private Action__c getMeetingAction(ZZTEST_DataContainer dataContainer) {
        Action__c action = new Action__c();
        action.Action_Owner__c = UserInfo.getUserId();
        action.Name = 'Action Subject';
        action.Start_Date__c = Date.today();
        action.Due_Date__c = Date.today().addDays(14);
		action.RecordTypeId = getActionRT(ActionRecordType.MEETING_ACTION);

        return action;
    }

    private Action__c getInsertedDefaultAction(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Action__c.getSObjectType()).isEmpty()) {
            Action__c action = this.getDefaultAction(dataContainer);
            insert action;
            dataContainer.put(action);
            return action;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Action__c.getSobjectType(), null).values()) {
                return (Action__c) s;
            }
        }
        return null;
    }
    
    static public String getActionRT(ActionRecordType type)
    {
        if(type == ActionRecordType.DEFAULT_ACTION)
            return Schema.Sobjecttype.Action__c.getRecordTypeInfosByName().get('Initiative Action').getRecordTypeId();
        else
            return Schema.Sobjecttype.Action__c.getRecordTypeInfosByName().get('Meeting Action').getRecordTypeId();
        
        return null;
    }
}