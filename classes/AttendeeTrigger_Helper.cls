/**
* @author Deloitte 
* @date 2015
*
* @group Call Report 
*
* @description Helper class for Attendee Trigger
*/
/*======================================
 * Modified by : Mabhedle Tonga
 * Modification Description : enhanced the call report update to shuffle call report sharing when an update takes plce on an attendee
 * Modification Date : 26.07.2017
 *======================================*/
public class AttendeeTrigger_Helper {

	/**
    * @description Share call report with attendees
    * @param List<Attendee__c> attendees
    */
	static public void shareCallReportWithAttendee(List<Attendee__c> attendees,boolean isNew,Map<id,Attendee__c> oldAttendeeMap)
	{
		List<Call_Report__Share> crsToSave = new List<Call_Report__Share>();
        Set<ID> CallReportIDToDelete = new Set<ID>();
        Set<ID> UserIDToDelete = new Set<ID>();
        
        if(isNew){
            for(Attendee__c att : attendees)
            {
                // Do not share with contacts (clients), share with users (barclays users)
                if(att.Barclays_Attendee__c == null)
                    continue;
                
                Call_Report__Share crs = new Call_Report__Share();
                crs.ParentId = att.Call_Report__r.Id;
                crs.UserOrGroupId = att.Barclays_Attendee__c;
                crs.AccessLevel = 'Read';
                
                crsToSave.add(crs);
            }    
        }
        else
        {
            for(Attendee__c att : attendees)
                {
                    if(oldAttendeeMap.containsKey(att.ID))
                        {
                            if(oldAttendeeMap.get(att.ID).Barclays_Attendee__c!=att.Barclays_Attendee__c)
                                {
                                    Call_Report__Share crs = new Call_Report__Share();
                                    crs.ParentId = att.Call_Report__r.Id;
                                    crs.UserOrGroupId = att.Barclays_Attendee__c;
                                    crs.AccessLevel = 'Read';
                                    
                                    crsToSave.add(crs);
                                    UserIDToDelete.add(oldAttendeeMap.get(att.ID).Barclays_Attendee__c);
                                    CallReportIDToDelete.add(att.Call_Report__r.Id);
                                }
                        }
                }
        }
		

		try {
            if(CallReportIDToDelete.size()>0)
                {
                    System.debug('Found');
                    List<Call_Report__Share> shareToDeleteList =  [SELECT ID FROM Call_Report__Share
                           where UserOrGroupID IN: UserIDToDelete
                           AND ParentID IN:CallReportIDToDelete
                           AND RowCause = 'Manual'];
                    Delete shareToDeleteList;
                }
            if(crsToSave.size()>0)
            {
                insert crsToSave;
            }
            
		} catch (Exception e) {
			System.debug('XXXXXXXXXXXX Critical exception: ' + e);
		}
	}

	/**
    * @description Blocks possibility of existence of duplicate attendees for one call report
    * @param Attendee__c att
    */
	static public void dontAllowDuplicateAttendees(Attendee__c att)
	{
		List<Attendee__c> attToCheck = [SELECT Id, Call_Report__r.Id, Attendee_Name__c FROM Attendee__c WHERE Call_Report__r.Id =: att.Call_Report__c];
		for(Attendee__c existingAtt : attToCheck)
		{
			if(att.Attendee_Name__c.compareTo(existingAtt.Attendee_Name__c) == 0)
			{
				att.addError('User ' + att.Attendee_Name__c + ' is already on the attending list.');
			}
		}
	}

	/**
    * @description Deletes shared call report
    * @param Attendee__c att
    */
	static public void deleteSharedCallReport(Attendee__c att)
	{	
		List<Call_Report__Share> crsToDelete = [SELECT Id, ParentId, UserOrGroupId FROM Call_Report__Share WHERE UserOrGroupId =: att.Barclays_Attendee__c AND ParentId =: att.Call_Report__c];		
		try {
			delete crsToDelete;
		} catch (Exception e) {
			System.debug('XXXXXXXXXXXXX Critical exception: ' + e);
		}
	}

	/**
    * @description Adds subscription for given list of attendess for call report
    * @param List<Attendee__c> attendees
    */
	static public void followCallReportByAttendee(List<Attendee__c> attendees){
		//Check if follower already exist
		List<EntitySubscription> subscriptionsToInsert = new List<EntitySubscription>();
		for(Attendee__c attendee : attendees){
			//Only Barclays Employees
			if(String.isNotBlank(attendee.Barclays_Attendee__c)){
				subscriptionsToInsert.add(ChatterUtils.addFollower(attendee.Barclays_Attendee__c, attendee.Call_Report__c));
			}
		}

		//Insert subscriptions
		Database.insert(subscriptionsToInsert, false);
	}

	/**
    * @description Stops subscription for given list of attendess for call report
    * @param List<Attendee__c> attendees
    */
	static public void stopFollowingCallReportByAttendee(List<Attendee__c> attendees){
		Map<Id, Set<Id>> mapCallReportsToAttendees = new Map<Id, Set<Id>>();
		for(Attendee__c attendee : attendees){
			if(String.isNotBlank(attendee.Barclays_Attendee__c)){
				if(mapCallReportsToAttendees.containsKey(attendee.Call_Report__c)){
					mapCallReportsToAttendees.get(attendee.Call_Report__c).add(attendee.Barclays_Attendee__c);
				} else{
					mapCallReportsToAttendees.put(attendee.Call_Report__c, new Set<Id>{attendee.Barclays_Attendee__c});
				}
			}
		}

		List<EntitySubscription> subscriptionsToDelete = new List<EntitySubscription>();

		for(EntitySubscription subscription : [SELECT Id, parentId, subscriberId FROM EntitySubscription 
												WHERE parentId IN :mapCallReportsToAttendees.keySet()]){
			if(mapCallReportsToAttendees.get(subscription.parentId).contains(subscription.subscriberId)){
				subscriptionsToDelete.add(subscription);
			}
		}

		delete subscriptionsToDelete;
	}

	/**
    * @description Adds post (chatter) for given set of attendees
    * @param Set<Id> attendeeIds
    */
	static public void addPostToAttendee(Set<Id> attendeeIds){
		List<FeedItem> feedItems = new List<FeedItem>();
		for(Attendee__c attendee : [SELECT Barclays_Attendee__r.Name, CreatedBy.Name, Call_Report__r.Subject__c, Barclays_Attendee__c, Call_Report__c FROM Attendee__c 
									WHERE Barclays_Attendee__c != null AND Id IN :attendeeIds]){
			String body = attendee.Barclays_Attendee__r.Name + ' has been added by ' + attendee.CreatedBy.Name
							+' as the attendee of call report "' + replaceNullWithBlank(attendee.Call_Report__r.Subject__c) + '".';
			//feedItems.add(ChatterUtils.addLinkPost('Call Report link', body, attendee.Barclays_Attendee__c, attendee.Call_Report__c));
			feedItems.add(ChatterUtils.addTextPost(attendee.Call_Report__c, body));
		}
		insert feedItems;
	}

	/**
    * @description Replaces null with blank string
    * @param String str
    * @return String
    */
	static public String replaceNullWithBlank(String str){
		return str != null ? str : '';
	}
}