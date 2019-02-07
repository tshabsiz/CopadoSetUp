/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Initiative
*/
@isTest
public class ZZTEST_F_Meeting {
	public enum MeetingRecordType {DEFAULT_MEETING}

    private static ZZTEST_F_Meeting instance;

    private Integer productCounter;
   	
    private ZZTEST_F_Meeting() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Meeting getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Meeting();
        }
        return instance;
    }

    public Meeting__c getProduct(MeetingRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getDefaultMeeting(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Meeting__c getInsertedProduct(MeetingRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getInsertedDefaultMeeting(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Meeting__c getDefaultMeeting(ZZTEST_DataContainer dataContainer) {
        Meeting__c meet = new Meeting__c();
        meet.Name = 'Meeting Test Description';
        meet.Private__c = true;
        meet.Start__c = Date.today();
        meet.End__c = Date.today().addDays(7) ;
        meet.Location__c = 'SA';

        return meet;
    }

    private Meeting__c getInsertedDefaultMeeting(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Meeting__c.getSObjectType()).isEmpty()) {
            Meeting__c meet = this.getDefaultMeeting(dataContainer);
            insert meet;
            dataContainer.put(meet);
            return meet;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Meeting__c.getSobjectType(), null).values()) {
                return (Meeting__c) s;
            }
        }
        return null;
    }
}