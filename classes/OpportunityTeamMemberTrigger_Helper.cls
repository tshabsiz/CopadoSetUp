/**
* @author Deloitte 
* @date 2015
*
* @group Opportunity
*
* @description Helper class opportunity team member trigger
*/
public class OpportunityTeamMemberTrigger_Helper{

	/**
    * @description Checks compliance for given opportunity team members
    * @param List<OpportunityTeamMember> oppTeamMembers
    */
	static public void checkCompliance(List<OpportunityTeamMember> oppTeamMembers){
		//Collect related opportunity ids
		Set<Id> oppIds = new Set<Id>();
		for(OpportunityTeamMember oppTeamMember : oppTeamMembers){
			oppIds.add(oppTeamMember.OpportunityId);
		}
		//Get opportunities
		Map<Id, Opportunity> oppMap = new Map<ID, Opportunity>([SELECT Id, RecordTypeId FROM Opportunity WHERE Id IN :oppIds]);
		//Check Compliance
		for(OpportunityTeamMember oppTeamMember : oppTeamMembers){
			if(oppMap.containsKey(oppTeamMember.OpportunityId) && oppMap.get(oppTeamMember.OpportunityId).RecordTypeId == Schema.Sobjecttype.Opportunity.getRecordTypeInfosByName().get('Private opportunity').getRecordTypeId() 
				&& oppTeamMember.I_confirm_team_member_has_been_cleared__c == false){
				oppTeamMember.I_confirm_team_member_has_been_cleared__c.addError(System.Label.errMsg_OpportunityTeamMemberCheckCompliance);
			}
		}
	}

	/**
    * @description Adds chatter subscriptions (follow opportunity) for given opportunity team members
    * @param List<OpportunityTeamMember> oppTeamMembers
    */
	static public void followOpportunityByTeamMember(List<OpportunityTeamMember> oppTeamMembers){
		//Check if follower already exist
		List<EntitySubscription> subscriptionsToInsert = new List<EntitySubscription>();
		for(OpportunityTeamMember oppTeamMember : oppTeamMembers){
			subscriptionsToInsert.add(ChatterUtils.addFollower(oppTeamMember.UserId, oppTeamMember.OpportunityId));
		}

		//Insert subscriptions
		Database.insert(subscriptionsToInsert, false);
	}

	/**
    * @description Removes chatter subscriptions (unfollow opportunity) for given opportunity team members
    * @param List<OpportunityTeamMember> oppTeamMembers
    */
	static public void stopFollowingOpportunityByTeamMember(List<OpportunityTeamMember> oppTeamMembers){
		Map<Id, Set<Id>> mapOpportunitiesToTeamMembers = new Map<Id, Set<Id>>();
		for(OpportunityTeamMember oppTeamMember : oppTeamMembers){
			if(mapOpportunitiesToTeamMembers.containsKey(oppTeamMember.OpportunityId)){
				mapOpportunitiesToTeamMembers.get(oppTeamMember.OpportunityId).add(oppTeamMember.UserId);
			} else{
				mapOpportunitiesToTeamMembers.put(oppTeamMember.OpportunityId, new Set<Id>{oppTeamMember.UserId});
			}
		}

		List<EntitySubscription> subscriptionsToDelete = new List<EntitySubscription>();

		for(EntitySubscription subscription : [SELECT Id, parentId, subscriberId FROM EntitySubscription 
												WHERE parentId IN :mapOpportunitiesToTeamMembers.keySet()]){
			if(mapOpportunitiesToTeamMembers.get(subscription.parentId).contains(subscription.subscriberId)){
				subscriptionsToDelete.add(subscription);
			}
		}

		delete subscriptionsToDelete;
	}

	/**
    * @description Adds chatter post for opportunity team members provided
    * @param Map<Id, OpportunityTeamMember> oppTeamMembersMap
    */
	static public void addPostToOpportunityTeamMember(Map<Id, OpportunityTeamMember> oppTeamMembersMap){
		List<FeedItem> feedItems = new List<FeedItem>();

		for(OpportunityTeamMember oppTeamMember : [SELECT User.Name, CreatedBy.Name, Opportunity.Name, TeamMemberRole, UserId, OpportunityId FROM OpportunityTeamMember 
													WHERE Id IN :oppTeamMembersMap.keySet()]){
			/*
			String body = 'You has been added as a team member of opportunity "' + oppTeamMember.Opportunity.Name
							+'" with role "' + oppTeamMember.TeamMemberRole + '".';
			feedItems.add(ChatterUtils.addLinkPost('Opportunity Link', body, oppTeamMember.UserId, oppTeamMember.OpportunityId));
			*/
			String body = oppTeamMember.User.Name + ' has been added by ' + oppTeamMember.CreatedBy.Name
							+ ' as a team member of opportunity "' + oppTeamMember.Opportunity.Name
							+'" with role "' + oppTeamMember.TeamMemberRole + '".';
			feedItems.add(ChatterUtils.addTextPost(oppTeamMember.OpportunityId, body));
		}

		insert feedItems;
	}

	public static void shareJlocsWithOpportunityTeamMembers(Map<Id, OpportunityTeamMember> oppTeamMembers){
    	List<OpportunityTeamMember> oppTeamMembersToShare = [SELECT Id, Opportunity.JLOC__c, UserId FROM OpportunityTeamMember WHERE Id IN :oppTeamMembers.keySet()];
    	JlocTrigger_Helper.shareJlocsWithOpportunityTeamMembers(oppTeamMembersToShare);
	}

	public static void stopSharingJlocsWithOpportunityTeamMembers(List<OpportunityTeamMember> oppTeamMembers){
		Set<Id> oppIds = new Set<Id>();
		for(OpportunityTeamMember oppTeamMember : oppTeamMembers){
			oppIds.add(oppTeamMember.OpportunityId);
		}
		Set<Id> jlocIds = new Set<Id>();
    	for(Opportunity opp : [SELECT Id, JLOC__c FROM Opportunity WHERE Id IN :oppIds]){
        	if(opp.JLOC__c != null){
        		jlocIds.add(opp.JLOC__c);
        	}
        }

    	if(jlocIds.size() > 0){
            JlocTrigger_Helper.recalculateJlocSharingWithOpportunityTeamMembers(jlocIds);
        }
	}
}