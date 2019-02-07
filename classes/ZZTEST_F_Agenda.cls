/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Initiative
*/
@isTest
public class ZZTEST_F_Agenda {
	public enum AgendaRecordType {DEFAULT_AGENDA}

    private static ZZTEST_F_Agenda instance;

    private Integer productCounter;
   	
    private ZZTEST_F_Agenda() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Agenda getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Agenda();
        }
        return instance;
    }

    public Agenda__c getProduct(AgendaRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getDefaultAgenda(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Agenda__c getInsertedProduct(AgendaRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getInsertedDefaultAgenda(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Agenda__c getDefaultAgenda(ZZTEST_DataContainer dataContainer) {
        Agenda__c agenda = new Agenda__c();
        agenda.Description__c = 'Agenda Description';
        agenda.Order__c = 1;
        agenda.Private__c = true;
        agenda.Start_Time__c = Date.today();
        agenda.End_Time__c = Date.today().addDays(7) ;

        return agenda;
    }

    private Agenda__c getInsertedDefaultAgenda(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Agenda__c.getSObjectType()).isEmpty()) {
            Agenda__c agenda = this.getDefaultAgenda(dataContainer);
            insert agenda;
            dataContainer.put(agenda);
            return agenda;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Agenda__c.getSobjectType(), null).values()) {
                return (Agenda__c) s;
            }
        }
        return null;
    }
}