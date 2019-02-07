/**
* @author Deloitte 
* @date 2015
*
* @group Organisation (Account) 
*
* @description Account Team Member Trigger Helper class
*/
public class AccountTeamMemberTrigger_Helper {
	public static String READ_ONLY = 'Read Only';
	public static String READ_WRITE = 'Read/Write';
	public enum AccessLevel {NONE, READ, EDIT, ALL}
	public static Map<String, AccessLevel> mapAccessLevels = new Map<String, AccessLevel>{
		READ_ONLY => AccessLevel.READ,
		READ_WRITE => AccessLevel.EDIT
	};
	
	/**
	* @description Checks for duplicates
	* @param List<Account_Team_Member__c> accTeamMembers
	* @return Map<Id, Set<Id>>
	*/
	public static Map<Id, Set<Id>> checkForDuplicates(List<Account_Team_Member__c> accTeamMembers){
		Set<Id> accountIds = new Set<Id>();
		for(Account_Team_Member__c accTeamMember : accTeamMembers){
			accountIds.add(accTeamMember.Organisation__c);
		}
		Map<Id, Set<Id>> mapAccountToTeamMembers = createMapAccountToTeamMembers([SELECT Id, Organisation__c, Team_Member__c 
																					FROM Account_Team_Member__c
																					WHERE Organisation__c IN :accountIds]);
		for(Account_Team_Member__c accTeamMember : accTeamMembers){
			if(mapAccountToTeamMembers.containsKey(accTeamMember.Organisation__c)){
				if(mapAccountToTeamMembers.get(accTeamMember.Organisation__c).contains(accTeamMember.Team_Member__c)){
					accTeamMember.addError('User is already added to Organisation Team');
				} else{
					mapAccountToTeamMembers.get(accTeamMember.Organisation__c).add(accTeamMember.Team_Member__c);
				}
			} else{
				mapAccountToTeamMembers.put(accTeamMember.Organisation__c, new Set<Id>{accTeamMember.Team_Member__c});
			}
		}
		return mapAccountToTeamMembers;
	}

	private static AccessLevel getOrgAccessLevel(Organization org){
		for(AccessLevel lev : AccessLevel.values()){
			if(org.DefaultAccountAccess == lev.name()){
				return lev;
			}
		}
		return null;
	}

	/**
	* @description Creates account team members
	* @param List<Account_Team_Member__c> accTeamMembers 
	*/
	public static void createAccountTeamMembers(List<Account_Team_Member__c> accTeamMembers) {
		//Query OWD
		Organization org = [SELECT Id, DefaultAccountAccess, DefaultCaseAccess, DefaultContactAccess, DefaultOpportunityAccess FROM Organization];
		AccessLevel orgAccLev = getOrgAccessLevel(org);

		List<AccountTeamMember> accTeamMembersToIns = new List<AccountTeamMember>();
		Map<Id, Map<Id, String>> mapAccountTeamMemberAccessLevels = new Map<Id, Map<Id, String>>();

		for(Account_Team_Member__c accTeamMember : accTeamMembers){

			//Create Account Team Member standard object
			AccountTeamMember accTeamMemberStd = new AccountTeamMember();
			accTeamMemberStd.AccountId = accTeamMember.Organisation__c;
			accTeamMemberStd.UserId = accTeamMember.Team_Member__c;
			accTeamMemberStd.TeamMemberRole = accTeamMember.Team_Role__c;
			accTeamMembersToIns.add(accTeamMemberStd);

			//Create Account Sharing only if selected Access Level is above OWD
			AccessLevel selAccLev = mapAccessLevels.get(accTeamMember.Organisation_Access__c);
			if(selAccLev.ordinal() > orgAccLev.ordinal()){
				addValToAccountTeamMemberMap(mapAccountTeamMemberAccessLevels, accTeamMember.Organisation__c, accTeamMember.Team_Member__c, selAccLev.name());
			}
		}

		try {
			//Insert Account Team Members
			insert accTeamMembersToIns;
			//Insert Account Sharing
			createAccountSharingForTeamMembers(mapAccountTeamMemberAccessLevels, org);
		} catch (Exception e) {
			System.debug('XXXXXXXXXXXX Create Account Team Members exception: ' + e);
		}
	}

	private static void createAccountSharingForTeamMembers(Map<Id, Map<Id, String>> mapAccountTeamMemberAccessLevels, Organization org){
		List<AccountShare> accShareToIns = new List<AccountShare>();
		for(Id accId : mapAccountTeamMemberAccessLevels.keySet()){
			for(Id userId : mapAccountTeamMemberAccessLevels.get(accId).keySet()){
				accShareToIns.add(new AccountShare(
									AccountAccessLevel = mapAccountTeamMemberAccessLevels.get(accId).get(userId),
									ContactAccessLevel = org.DefaultContactAccess,
									OpportunityAccessLevel = org.DefaultOpportunityAccess,
									CaseAccessLevel = org.DefaultCaseAccess,
									AccountId = accId,
									UserOrGroupId = userId
				));
			}
		}
		//Insert Account Sharing
		insert accShareToIns;
	}

	/**
	* @description Updates existing account team members
	* @param Map<Id, Account_Team_Member__c> oldAccTeamMembers
	* @param Map<Id, Account_Team_Member__c> newAccTeamMembers
	*/
	public static void updateAccountTeamMembers(Map<Id, Account_Team_Member__c> oldAccTeamMembers, Map<Id, Account_Team_Member__c> newAccTeamMembers){
		//Query OWD
		Organization org = [SELECT Id, DefaultAccountAccess, DefaultCaseAccess, DefaultContactAccess, DefaultOpportunityAccess FROM Organization];
		AccessLevel orgAccLev = getOrgAccessLevel(org);

		Map<Id, Map<Id, String>> mapAccountToTeamMemberAccessLevelToIns = new Map<Id, Map<Id, String>>();
		Map<Id, Map<Id, String>> mapAccountToTeamMemberAccessLevelToUpd = new Map<Id, Map<Id, String>>();
		Map<Id, Set<Id>> mapAccountToTeamMemberToDel = new Map<Id, Set<Id>>();
		Map<Id, Map<Id, String>> mapAccountToTeamMemberRole = new Map<Id, Map<Id, String>>();
		for(Id accTeamMemberId : newAccTeamMembers.keySet()){
			if(newAccTeamMembers.get(accTeamMemberId).Organisation_Access__c != oldAccTeamMembers.get(accTeamMemberId).Organisation_Access__c){
				
				if(newAccTeamMembers.get(accTeamMemberId).Team_Role__c != oldAccTeamMembers.get(accTeamMemberId).Team_Role__c){
					addValToAccountTeamMemberMap(mapAccountToTeamMemberRole, newAccTeamMembers.get(accTeamMemberId).Organisation__c, newAccTeamMembers.get(accTeamMemberId).Team_Member__c, newAccTeamMembers.get(accTeamMemberId).Team_Role__c);
				}
				
				AccessLevel selAccLevOld = mapAccessLevels.get(oldAccTeamMembers.get(accTeamMemberId).Organisation_Access__c);
				AccessLevel selAccLevNew = mapAccessLevels.get(newAccTeamMembers.get(accTeamMemberId).Organisation_Access__c);
				if(selAccLevOld.ordinal() > orgAccLev.ordinal() && selAccLevNew.ordinal() > orgAccLev.ordinal()){
					//update
					addValToAccountTeamMemberMap(mapAccountToTeamMemberAccessLevelToUpd, newAccTeamMembers.get(accTeamMemberId).Organisation__c, newAccTeamMembers.get(accTeamMemberId).Team_Member__c, selAccLevNew.name());
				}
				if(selAccLevOld.ordinal() > orgAccLev.ordinal() && selAccLevNew.ordinal() <= orgAccLev.ordinal()){
					//delete
					if(mapAccountToTeamMemberToDel.containsKey(oldAccTeamMembers.get(accTeamMemberId).Organisation__c)){
						mapAccountToTeamMemberToDel.get(oldAccTeamMembers.get(accTeamMemberId).Organisation__c).add(oldAccTeamMembers.get(accTeamMemberId).Team_Member__c);
					} else{
						mapAccountToTeamMemberToDel.put(oldAccTeamMembers.get(accTeamMemberId).Organisation__c, new Set<Id>{oldAccTeamMembers.get(accTeamMemberId).Team_Member__c});
					}	
				}
				if(selAccLevOld.ordinal() <= orgAccLev.ordinal() && selAccLevNew.ordinal() > orgAccLev.ordinal()){
					//insert
					addValToAccountTeamMemberMap(mapAccountToTeamMemberAccessLevelToIns, newAccTeamMembers.get(accTeamMemberId).Organisation__c, newAccTeamMembers.get(accTeamMemberId).Team_Member__c, selAccLevNew.name());
				}
			}
		}
		try {
			//Update Account Team Members
			updateAccountTeamMemberRoles(mapAccountToTeamMemberRole);
			//Update Account Sharing
			updateAccountSharingForTeamMembers(mapAccountToTeamMemberAccessLevelToUpd);
			//Delete Account Sharing
			deleteAccountSharingForTeamMembers(mapAccountToTeamMemberToDel);
			//Insert Account Sharing
			createAccountSharingForTeamMembers(mapAccountToTeamMemberAccessLevelToIns, org);
		} catch (Exception e) {
			System.debug('XXXXXXXXXXXX Update Account Team Members exception: ' + e);
		}
	}

	/**
	* @description Updates existing account team member roles
	* @param Map<Id, Map<Id, String>> mapAccountToTeamMemberRole
	*/
	public static void updateAccountTeamMemberRoles(Map<Id, Map<Id, String>> mapAccountToTeamMemberRole){
		List<AccountTeamMember> accTeamMembersToUpd = new List<AccountTeamMember>();
		for(AccountTeamMember accTeamMember : [SELECT Id, TeamMemberRole, AccountId, UserId 
											FROM AccountTeamMember 
											WHERE AccountId IN :mapAccountToTeamMemberRole.keySet()]){
			if(mapAccountToTeamMemberRole.get(accTeamMember.AccountId).containsKey(accTeamMember.UserId)){
				accTeamMember.TeamMemberRole = mapAccountToTeamMemberRole.get(accTeamMember.AccountId).get(accTeamMember.UserId);
				accTeamMembersToUpd.add(accTeamMember);
			}
		}
		//Update Account Team Members
		update accTeamMembersToUpd;
	}

	/**
	* @description Updates existing account team member sharing rules
	* @param Map<Id, Map<Id, String>> mapAccountTeamMemberAccessLevels
	*/
	public static void updateAccountSharingForTeamMembers(Map<Id, Map<Id, String>> mapAccountTeamMemberAccessLevels){
		//Account Sharing
		List<AccountShare> accShareToUpd = new List<AccountShare>();
		for(AccountShare accShare : [SELECT Id, AccountAccessLevel, AccountId, UserOrGroupId 
											FROM AccountShare 
											WHERE AccountId IN :mapAccountTeamMemberAccessLevels.keySet() 
											AND (RowCause = 'Team' OR RowCause = 'Manual')]){
			if(mapAccountTeamMemberAccessLevels.get(accShare.AccountId).containsKey(accShare.UserOrGroupId)){
				accShare.AccountAccessLevel = mapAccountTeamMemberAccessLevels.get(accShare.AccountId).get(accShare.UserOrGroupId);
				accShareToUpd.add(accShare);
			}
		}
		//Update Account Sharing
		update accShareToUpd;
	}

	/**
	* @description Deletes account team members
	* @param List<Account_Team_Member__c> accTeamMembers
	*/
	public static void deleteAccountTeamMembers(List<Account_Team_Member__c> accTeamMembers) {
		Map<Id, Set<Id>> mapAccountToTeamMembers = createMapAccountToTeamMembers(accTeamMembers);
		List<AccountTeamMember> accTeamMembersToDel = new List<AccountTeamMember>();
		for(AccountTeamMember accTeamMember : [SELECT Id, AccountId, UserId FROM AccountTeamMember WHERE AccountId = :mapAccountToTeamMembers.keySet()]){
			if(mapAccountToTeamMembers.get(accTeamMember.AccountId).contains(accTeamMember.UserId)){
				accTeamMembersToDel.add(accTeamMember);
			}
		}

		try {
			//Delete Account Team Members
			delete accTeamMembersToDel;
			//Delete Account Sharing
			deleteAccountSharingForTeamMembers(mapAccountToTeamMembers);
		} catch (Exception e) {
			System.debug('XXXXXXXXXXXX Delete Account Team Members exception: ' + e);
		}
	}

	/**
	* @description Deletes account sharing for provided team members
	* @param Map<Id, Set<Id>> mapAccountToTeamMember 
	*/
	public static void deleteAccountSharingForTeamMembers(Map<Id, Set<Id>> mapAccountToTeamMember){
		//Account Sharing
		List<AccountShare> accShareToDel = new List<AccountShare>();
		for(AccountShare accShare : [SELECT Id, AccountAccessLevel, AccountId, UserOrGroupId 
											FROM AccountShare 
											WHERE AccountId IN :mapAccountToTeamMember.keySet() 
											AND (RowCause = 'Team' OR RowCause = 'Manual')]){
			if(mapAccountToTeamMember.get(accShare.AccountId).contains(accShare.UserOrGroupId)){
				accShareToDel.add(accShare);
			}
		}
		//Delete Account Sharing
		delete accShareToDel;
	}

	/**
	* @description Initiates subscription for provided team members
	* @param List<Account_Team_Member__c> accTeamMembers
	*/
	public static void followAccountByTeamMember(List<Account_Team_Member__c> accTeamMembers){
		List<EntitySubscription> subscriptionsToInsert = new List<EntitySubscription>();
		for(Account_Team_Member__c accTeamMember : accTeamMembers){
			subscriptionsToInsert.add(ChatterUtils.addFollower(accTeamMember.Team_Member__c, accTeamMember.Organisation__c));
		}

		//Insert subscriptions
		Database.insert(subscriptionsToInsert, false);
	}

	/**
	* @description Stops subscription for provided team members
	* @param List<Account_Team_Member__c> accTeamMembers
	*/
	public static void stopFollowingCallReportByAttendee(List<Account_Team_Member__c> accTeamMembers){
		Map<Id, Set<Id>> mapAccountToTeamMembers = createMapAccountToTeamMembers(accTeamMembers);

		List<EntitySubscription> subscriptionsToDelete = new List<EntitySubscription>();

		for(EntitySubscription subscription : [SELECT Id, parentId, subscriberId FROM EntitySubscription 
												WHERE parentId IN :mapAccountToTeamMembers.keySet()]){
			if(mapAccountToTeamMembers.get(subscription.parentId).contains(subscription.subscriberId)){
				subscriptionsToDelete.add(subscription);
			}
		}

		delete subscriptionsToDelete;
	}

	/**
	* @description Adds post for each of provided attendees
	* @param Set<Id> accTeamMemberIds
	*/
	public static void addPostToAttendee(Set<Id> accTeamMemberIds){
		List<FeedItem> feedItems = new List<FeedItem>();
		for(Account_Team_Member__c accTeamMember : [SELECT Organisation__r.Name, Team_Member__r.Name, Team_Role__c, CreatedBy.Name, Organisation__c 
													FROM Account_Team_Member__c 
													WHERE Id IN :accTeamMemberIds]){
			String body = accTeamMember.Team_Member__r.Name + ' has been added by ' + accTeamMember.CreatedBy.Name
							+' as the team member of organisation "' + accTeamMember.Organisation__r.Name + '" with role "'
							+ accTeamMember.Team_Role__c + '".';
			feedItems.add(ChatterUtils.addTextPost(accTeamMember.Organisation__c, body));
		}
		insert feedItems;
	}

	/**
	* @description shares client plans with new team members
	* @param List<Account_Team_Member__c> members
	*/
	public static void shareClientPlans(List<Account_Team_Member__c> members) {

		//getting accounts ids
		Set<Id> accIds = new Set<Id>();
		for (Account_Team_Member__c member: members) {
			accIds.add(member.Organisation__c);
		}

		//getting client plans
		Map<Id, List<Client_Plan__c>> plansPerAcc = getClientPlansPerAccount(accIds);

		//creating sharing records
        List<Client_Plan__Share> shareRecs = new List<Client_Plan__Share>();

        for (Account_Team_Member__c member: members) {

        	if (plansPerAcc.containsKey(member.Organisation__c)) {
	        	for (Client_Plan__c plan: plansPerAcc.get(member.Organisation__c)) {
	        		shareRecs.add(ClientPlanUtils.createSharingInstance(plan.Id, member.Team_Member__c));
	        	}
	        }
        }

        //inserting
        Database.insert(shareRecs, false);
	}

	/**
	* @description unshares client plans
	* @param List<Account_Team_Member__c> members
	*/
	public static void unshareClientPlans(List<Account_Team_Member__c> members) {

		//getting users ids and accounts ids
		Set<Id> userIds = new Set<Id>();
		Set<Id> accIds = new Set<Id>();
		for (Account_Team_Member__c member: members) {
			userIds.add(member.Team_Member__c);
			accIds.add(member.Organisation__c);
		}

		//getting client plans ids
		List<Client_Plan__c> plans = getClientPlansOfAccounts(accIds);

		//getting sharing records
		List<Client_Plan__Share> shareRecs = [
			SELECT Id
			FROM Client_Plan__Share
			WHERE ParentId IN :plans AND UserOrGroupId IN :userIds
		];

		//deleting
		Database.delete(shareRecs, false);
	}
    public static void shareAnnualPricing(List<Account_Team_Member__c> members) {
        
        //getting accounts ids
        Set<Id> accIds = new Set<Id>();
        List<Account_Team_Member__c> membersCSM = new List<Account_Team_Member__c>();
        
        for (Account_Team_Member__c member: members) {
            if(member.Team_Role__c == 'Coverage Support Manager'){
                accIds.add(member.Organisation__c);
                membersCSM.add(member);
            }
        }
        
        
        //getting Annual pricing
        Map<Id, List<Annual_Pricing__c>> pricingPerAcc = getAnnualPricingsPerAccount(accIds);
        
        //creating sharing records
        List<Annual_Pricing__Share> shareRecs = new List<Annual_Pricing__Share>();
        
        for (Account_Team_Member__c member: membersCSM) {
            
            if (pricingPerAcc.containsKey(member.Organisation__c)) {
                for (Annual_Pricing__c AnnualPricing: pricingPerAcc.get(member.Organisation__c)) {
                    shareRecs.add(APT_AnnualPricingUtils.createSharingInstance(AnnualPricing.Id, member.Team_Member__c));
                }
            }
        }
        
        //inserting
        Database.insert(shareRecs, false);
    }

	/**
	* @description queries of client plans related to accounts in param
	* @param Set<Id> accIds
	*/
	private static List<Client_Plan__c> getClientPlansOfAccounts(Set<Id> accIds) {

		return [
			SELECT Id
			FROM Client_Plan__c
			WHERE Relationship__c IN :accIds
		];
	}

	/**
	* @description queries of client plans related to accounts in param, result is a map
	* @param Set<Id> accIds
	*/
	private static Map<Id, List<Client_Plan__c>> getClientPlansPerAccount(Set<Id> accIds) {

		//getting client plans
		List<Client_Plan__c> plans = [
			SELECT Id, Relationship__c
			FROM Client_Plan__c
			WHERE Relationship__c IN :accIds
		];

		//classifying plans
		Map<Id, List<Client_Plan__c>> plansPerAcc = new Map<Id, List<Client_Plan__c>>();
		for (Client_Plan__c plan: plans) {

			if (plansPerAcc.containsKey(plan.Relationship__c)) {
				List<Client_Plan__c> accPlans = plansPerAcc.get(plan.Relationship__c);
				accPlans.add(plan);

			} else {
				List<Client_Plan__c> accPlans = new List<Client_Plan__c>();
				accPlans.add(plan);
				plansPerAcc.put(plan.Relationship__c, accPlans);
			}
		}

		return plansPerAcc;
	}

	private static void addValToAccountTeamMemberMap(Map<Id, Map<Id, String>> mapAccountTeamMemberAccessLevels, Id accountId, Id userId, String val){
		if(mapAccountTeamMemberAccessLevels.containsKey(accountId)){
			mapAccountTeamMemberAccessLevels.get(accountId).put(userId, val);
		} else{
			mapAccountTeamMemberAccessLevels.put(accountId, new Map<Id, String>{userId => val});
		}
	}

	private static Map<Id, Set<Id>> createMapAccountToTeamMembers(List<Account_Team_Member__c> accTeamMembers){
		Map<Id, Set<Id>> mapAccountToTeamMembers = new Map<Id, Set<Id>>();
		for(Account_Team_Member__c accTeamMember : accTeamMembers){
			if(mapAccountToTeamMembers.containsKey(accTeamMember.Organisation__c)){
				mapAccountToTeamMembers.get(accTeamMember.Organisation__c).add(accTeamMember.Team_Member__c);
			} else{
				mapAccountToTeamMembers.put(accTeamMember.Organisation__c, new Set<Id>{accTeamMember.Team_Member__c});
			}
		}
		return mapAccountToTeamMembers;
	}
    
 private static Map<Id, List<Annual_Pricing__c>> getAnnualPricingsPerAccount(Set<Id> accIds) {

		//getting client plans
		List<Annual_Pricing__c> AnnualPricings = [
			SELECT Id, Organisation__c
			FROM Annual_Pricing__c
			WHERE Organisation__c IN :accIds
		];

		//classifying plans
		Map<Id, List<Annual_Pricing__c>> pricingPerAcc = new Map<Id, List<Annual_Pricing__c>>();
		for (Annual_Pricing__c AnnualPricing: AnnualPricings) {

			if (pricingPerAcc.containsKey(AnnualPricing.Organisation__c)) {
				List<Annual_Pricing__c> accPricings = pricingPerAcc.get(AnnualPricing.Organisation__c);
				accPricings.add(AnnualPricing);

			} else {
				List<Annual_Pricing__c> accPricings = new List<Annual_Pricing__c>();
				accPricings.add(AnnualPricing);
				pricingPerAcc.put(AnnualPricing.Organisation__c, accPricings);
			}
		}

		return pricingPerAcc;
	}



}