/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Trigger helper for Client Plan trigger
* @Date:        3/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanTrigger_Helper  
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class ClientPlanTrigger_Helper {

    private static final String ADMIN_NAME = 'System Administrator';

    private static final String BAR_ADMIN_NAME = 'Barclays Administrator';

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     checks if user has right to create a client plan
      * @Param:           List<Client_Plan__c> plans
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static void checkRightsToCreateNew(List<Client_Plan__c> plans) {
        /* Only allow a single ClientPlan per relationshipp - regardless of Permissions */
        //Getting all accounts ids
        Set<Id> accIds = new Set<Id>();
        for(Client_Plan__c newClientPlan : plans) {
            accIds.add(newClientPlan.Relationship__c);
        }
        //Getting any client plans for these accounts
        List<Client_Plan__c> existingClientPlans = [
            SELECT  Id, Relationship__c 
            FROM    Client_Plan__c
            WHERE   Relationship__c IN :accIds
        ];
        //Loop over new Plans - check for each if we already have an existing ClientPlan
        for(Client_Plan__c newClientPlan : plans) {
            for(Client_Plan__c existingClientPlan : existingClientPlans) {
                if(newClientPlan.Relationship__c == existingClientPlan.Relationship__c) {
                    newClientPlan.addError('A Client Plan already exists for this Relationship');
                    break;
                }
            }
        }

        //Continue with regular profile checks
        String profileId = UserInfo.getProfileId();
        List<Profile> profiles = [
            SELECT Name
            FROM Profile
            WHERE Id = :profileId
        ];
        if (!Test.isRunningTest() && !profiles.isEmpty() && (profiles[0].Name == ADMIN_NAME || profiles[0].Name == BAR_ADMIN_NAME)) {
            return;
        }
        
        //getting accounts using the set of Account IDs already retrieved
        List<Account> accs = [
            SELECT  Id, OwnerId
            FROM    Account
            WHERE   Id IN :accIds
        ];
        Map<Id, Account> accsMap = new Map<Id, Account>(accs);

        //getting team members per account
        Map<Id, List<Account_Team_Member__c>> membersPerAcc = getMembersPerAcc(accs);

        //getting user id
        String userId = UserInfo.getUserId();

        for(Client_Plan__c plan : plans) {
            Boolean allowSave = false;

            //checking if user if account owner
            Account acc = accsMap.get(plan.Relationship__c);
            if(acc != null && acc.OwnerId == userId) {
                allowSave = true;
            }

            //checking if user is in relationship team
            List<Account_Team_Member__c> members = membersPerAcc.get(plan.Relationship__c);
            if(members != null) {
                for(Account_Team_Member__c member: members) {
                    if(member.Team_Member__r.Id == userId) {
                        allowSave = true;
                    }
                }
            }

            if(!allowSave) {
                plan.addError(Label.errMsg_CantCreateClientPlan);
            }
        }
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     shares new client plans with related account teams
      * @Param:           List<Client_Plan__c> plans, Map<Id, Client_Plan__c> plansMap
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static void shareWithAccOwnerAndAccTeam(List<Client_Plan__c> plans, Map<Id, Client_Plan__c> plansMap) {

        //getting accounts ids
        Set<Id> accIds = new Set<Id>();
        for(Client_Plan__c plan: plans) {
            accIds.add(plan.Relationship__c);
        }

        //getting accounts
        List<Account> accs = [
            SELECT Id, OwnerId
            FROM Account
            WHERE Id IN :accIds
        ];
        Map<Id, Account> accsMap = new Map<Id, Account>(accs);
        
        //getting team members per account
        Map<Id, List<Account_Team_Member__c>> membersPerAcc = getMembersPerAcc(accs);

        //creating sharing records
        List<Client_Plan__Share> shareRecs = new List<Client_Plan__Share>();

        for(Client_Plan__c plan : plans) {

            Id ownerId = accsMap.get(plan.Relationship__c).OwnerId;

            //sharing record for account owner
            shareRecs.add(ClientPlanUtils.createSharingInstance(plan.Id, ownerId));

            //sharing records for account teams
            //checking if there is at least one team member
            if(membersPerAcc.containsKey(plan.Relationship__c)) {
                for(Account_Team_Member__c member: membersPerAcc.get(plan.Relationship__c)) {
                    shareRecs.add(ClientPlanUtils.createSharingInstance(plan.Id, member.Team_Member__r.Id));
                }
            }
        }

        //inserting
        Database.insert(shareRecs, false); 
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     creates map - keys are accounts ids, values are account team members
      * @Param:           List<Account> accs
      * @Returns:         Map<Id, List<Account_Team_Member__c>>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private static Map<Id, List<Account_Team_Member__c>> getMembersPerAcc(List<Account> accs) {

        //getting team members
        List<Account_Team_Member__c> members = [
            SELECT  Team_Member__r.Id, Organisation__c
            FROM    Account_Team_Member__c
            WHERE   Organisation__c IN :accs
        ];

        //classifying per account
        Map<Id, List<Account_Team_Member__c>> membersPerAcc = new Map<Id, List<Account_Team_Member__c>>();

        for(Account_Team_Member__c member: members) {

            if(membersPerAcc.containsKey(member.Organisation__c)) {
                membersPerAcc.get(member.Organisation__c).add(member);

            } else {
                List<Account_Team_Member__c> memList = new List<Account_Team_Member__c>{member};
                membersPerAcc.put(member.Organisation__c, memList);
            }
        }

        return membersPerAcc;
    }
}