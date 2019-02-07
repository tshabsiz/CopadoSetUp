/**
* @author Deloitte 
* @date 2015
*
* @group Call Report 
*
* @description Helper class for Call Report Trigger
*/
public class CallReportTrigger_Helper{
	public static final String BARCLAYS_ATTENDEE_RT = 'Barclays_Attendee';

	/**
    * @description Creates Barclays Attendee for given call reports
    * @param List<Call_Report__c> callReports
    */
	static public void craeteBarclaysAttendee(List<Call_Report__c> callReports){
		//Create the map of Attendee Record Types
		Map<String, RecordType> mapAttendeeRT = new Map<String, RecordType>();
		for(RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'Attendee__c']){
			mapAttendeeRT.put(rt.DeveloperName, rt);
		}
		//Create the list of Attendees to be inserted
		List<Attendee__c> attendiesToInsert = new List<Attendee__c>();
		if(mapAttendeeRT.containsKey(BARCLAYS_ATTENDEE_RT)){
			Id BarclaysAttendeeRtId = mapAttendeeRT.get(BARCLAYS_ATTENDEE_RT).Id;
			for(Call_Report__c callReport : callReports){
				attendiesToInsert.add(new Attendee__c(RecordTypeId=BarclaysAttendeeRtId,
													Call_Report__c=callReport.Id,
													Barclays_Attendee__c=callReport.OwnerId));
			}
		}
		//Insert Attendees
		insert attendiesToInsert;
	}
}