/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 *** CHANGE LOG ***
 
 22/03/2018 - PG    - Created initial class.
 					- Added "After Update" method for trigger.
 
**/ 
public class External_Collaboration_Request_Helper
{
	public static void afterUpdate(List<External_Collaboration_Request__c> inputNew, Map<Id, External_Collaboration_Request__c> inputOld)
	{
		//Holds approved record ids.
		Set<String> approvedRequests = new Set<String>();

		//Loop over updated records.
		for(External_Collaboration_Request__c newRecord : inputNew) 
		{
			//Record approved.
			if(newRecord.Status__c == 'Approved' && inputOld.get(newRecord.Id).Status__c != 'Approved')
			{
				approvedRequests.add(newRecord.Id);
			}
		}

		//Anythingto process.
		if(!approvedRequests.isEmpty())
		{
			//Call box.com.
			BxdExternalCollaborationService.createApprovedExternalCollaborations(approvedRequests);
		} 
	}
}