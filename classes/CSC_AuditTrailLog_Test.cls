/**
* Date   : 08-08-2016
* Author : RN - CloudSmiths
* Desc   : Test class for: CSC_AuditTrailLog
**/

@IsTest(SeeAllData=false)
public class CSC_AuditTrailLog_Test {
	public static testMethod void auditTest() {
        try {
           throw new DMLException('You cannot do that here');
        }catch(DmlException e) {
            CSC_AuditTrailLog.logException(e, 'New', 'Failure', 'CSC_Inbound_Email_Service', 'handleInboundEmail', 'Unhandled exception within the email service');
        }
       
    }
}