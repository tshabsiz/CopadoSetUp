/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Initiative
*/
@isTest
public class ZZTEST_F_Program {
	public enum ProgramRecordType {DEFAULT_PROGRAM}

    private static ZZTEST_F_Program instance;

    private Integer productCounter;
   	
    private ZZTEST_F_Program() {
        this.productCounter = 0;   
    }

    public static ZZTEST_F_Program getInstance() {
        if (instance == null) {
            instance = new ZZTEST_F_Program();
        }
        return instance;
    }

    public Program__c getProduct(ProgramRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getDefaultProgram(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }
    
    public Program__c getInsertedProduct(ProgramRecordType type, ZZTEST_DataContainer dataContainer) {
        try {
            productCounter++;
            return getInsertedDefaultProgram(dataContainer);
        } catch (Exception e) {
            return null;
        }
        return null;
    }

    private Program__c getDefaultProgram(ZZTEST_DataContainer dataContainer) {
        Program__c program = new Program__c();
        program.Name = 'Program Description';

        return program;
    }

    private Program__c getInsertedDefaultProgram(ZZTEST_DataContainer dataContainer) {
        if (dataContainer.getSObjectMap(Program__c.getSObjectType()).isEmpty()) {
            Program__c program = this.getDefaultProgram(dataContainer);
            insert program;
            dataContainer.put(program);
            return program;
        } else {
            for(SObject s :dataContainer.getRecordTypeMap(Program__c.getSobjectType(), null).values()) {
                return (Program__c) s;
            }
        }
        return null;
    }
}