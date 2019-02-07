/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Call Report
* 
* 25.04.2016 - Mohsin Wadee - US-1063 - in method Call_Report__c getDefaultCallReport changed Relationship type to Relationship Group.
*/
@isTest
public class ZZTEST_F_Call_Report {
    public enum CallReportRecordType {DEFAULT_CALL_REPORT}

    private static ZZTEST_F_Call_Report instance;

    private Integer productCounter;

    private ZZTEST_F_Call_Report() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Call_Report getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Call_Report();
        }
        return instance;
    }

    public Call_Report__c getProduct(CallReportRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == CallReportRecordType.DEFAULT_CALL_REPORT) {
                return getDefaultCallReport(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Call_Report__c getInsertedProduct(CallReportRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            if (type == CallReportRecordType.DEFAULT_CALL_REPORT) {
                return getInsertedDefaultCallReport(dataContainer);
            }
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Call_Report__c getDefaultCallReport(ZZTEST_DataContainer dataContainer) {
        Call_Report__c callRep = new Call_Report__c();
        callRep.Meeting_Date__c = Date.today();
        callRep.Type__c = 'Meeting';
        callRep.Subject__c = 'Introduction';
        callRep.Location__c = 'Johannesburg';
        //callRep.Team_Role__c = 'RD';
        callRep.Meeting_Reason2__c = 'Relationship';
        callRep.Description__c = 'Introduction meeting';

        ZZTEST_F_Account accountFactory = ZZTEST_DataFactoryFacade.account;
        Account acc = accountFactory.getInsertedProduct(ZZTEST_F_Account.AccountRecordType.BUYING_GROUP, dataContainer);
        callRep.Relationship__c = acc.Id;
        return callRep;
    }
    private Call_Report__c getInsertedDefaultCallReport(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Call_Report__c.getSObjectType()).isEmpty()) {
            Call_Report__c callRep = this.getDefaultCallReport(dataContainer);
            insert callRep;
            dataContainer.put(callRep);
            return callRep;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Call_Report__c.getSobjectType(), null).values()) {
                return (Call_Report__c) s;
            }
        }
        return null;
    }
}