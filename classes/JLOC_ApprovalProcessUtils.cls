public without sharing class JLOC_ApprovalProcessUtils {
	public static String STATUS_SENT_TO_COMMITTEE = 'Sent to Committee';

	public JLOC_ApprovalProcessUtils() {}

	public static void insertJlocAttendees(List<JLOC_Attendee__c> jlocAttendees){
		insert jlocAttendees;
	}

	public static void updateJlocAttendees(List<JLOC_Attendee__c> jlocAttendees){
		update jlocAttendees;
	}

	public static void updateJloc(JLOC__c jloc){
		update jloc;
	}
}