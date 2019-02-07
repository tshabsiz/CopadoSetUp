/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a controller for JLOC_CheckPresence page.
* @Date:        10/2015
* @ConstructorParam:    stdController - Standard Controller for "JLOC" object
* @TestClass:   ZZTEST_JLOC_CheckPresenceController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public with sharing class JLOC_CheckPresenceController {
	private JLOC__c jloc;
	public List<JLOC_Attendee__c> jlocAttendees { get; set; }

	public JLOC_CheckPresenceController(ApexPages.StandardController stdController) {
		jloc = (JLOC__c)stdController.getRecord();

		if (String.isNotBlank(jloc.Id)) {
            jlocAttendees = [SELECT Id, Group__c, User__c, Present__c FROM JLOC_Attendee__c WHERE JLOC__c = :jloc.Id];
        } else {
        	jlocAttendees = new List<JLOC_Attendee__c>();
        }
	}

	/**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to save JLOC Attendees with updated "Presence" field.
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public PageReference save() {
		try{
			JLOC_ApprovalProcessUtils.updateJlocAttendees(jlocAttendees);
		} catch(DmlException ex){
			for(Integer i=0; i < ex.getNumDml(); i++){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(i)));
			}
			return null;
		}
		
		return new ApexPages.StandardController(jloc).view();
	}
}