/**
* Date   : 13-08-2016
* Author : RN - CloudSmiths
* Desc   : Write exception into a custom object
**/
public class CSC_AuditTrailLog {

    public static CSC_Exception_Audit_Trail__c auditTrail;
    
    public static void logException(Exception e, String status, String severity, String classname, String method, String devnote){
			
        	auditTrail = new CSC_Exception_Audit_Trail__c();	
        	auditTrail.Severity__c = severity;
            auditTrail.Status__c = status;
			auditTrail.Class_Name__c = classname;
            auditTrail.Exception_DateTime__c = System.now();
            auditTrail.Exception_Message__c = e.GetMessage();
            auditTrail.Method_Name__c = method;
            auditTrail.Line_Number__c = e.getLineNumber();
            auditTrail.Stack_Trace__c = e.getStackTraceString();
            auditTrail.Developer_Notes__c = devnote;

            try{
            	insert auditTrail;
                System.debug('Error was logged in the CSC_Exception_Audit_Trail Object');
        		System.debug(e.getMessage());
            }catch(DMLException ex){
                System.debug('Error could not be logged in the audit trail object');
        		System.debug(ex.getMessage());
                System.debug('Original Error below:');
                System.debug(e.getMessage());
            }
        
        	
    }
    
}