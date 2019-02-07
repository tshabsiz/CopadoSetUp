/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a help class for trigger JlocTrigger.
* @Date:        10/2015
* @ConstructorParam:    None
* @TestClass:   ZZTEST_JlocTrigger
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 04/12/2015  Marta Malinowska   Add Opportunity Team Members to JLOC followers.
*------------------------------------------------------------*/
public class JlocTrigger_Helper {
  //Public Groups
  public static String GROUP_JLOC_SECRETARY = 'JLOC Secretary';
  //Chatter Groups
  public static String GROUP_COVERAGE = 'JLOC Coverage';
  public static String GROUP_INVESTMENT_BANKING = 'JLOC Investment Banking';
  public static String GROUP_PORTFOLIO_MANAGEMENT = 'JLOC Portfolio Management';
  public static String GROUP_MARKETS = 'JLOC Markets';
  public static String GROUP_TRADE = 'JLOC Trade';
  //JLOC Statuses
  public static String STATUS_DRAFT = 'Draft';
  public static String STATUS_SUBMITTED_TO_SECRETARY = 'Submitted to Secretary';
  public static String STATUS_SENT_TO_COMMITTEE = 'Sent to Committee';
  //Apex Sharing Reasons
  public static String JLOC_SECRETARY = 'JLOC_Secretary__c';
  public static String OPPORTUNITY_TEAM_MEMBER = 'Opportunity_Team_Member__c';
  //Define maps
  private static Map<Id, List<JLOC_Attendee__c>> mapJlocAttendees;

  /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to share JLOC with opportunity team members
    * @param        List of Opportunity Team Members
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  public static void shareJlocsWithOpportunityTeamMembers(List<OpportunityTeamMember> oppTeamMembers){
      List<JLOC__Share> sharing = new List<JLOC__Share>();
      for(OpportunityTeamMember oppTeamMember : oppTeamMembers){
        if(oppTeamMember.Opportunity.JLOC__c != null){
          sharing.add(new JLOC__Share(ParentId=oppTeamMember.Opportunity.JLOC__c, UserOrGroupId=oppTeamMember.UserId, RowCause=OPPORTUNITY_TEAM_MEMBER, AccessLevel='Edit')); 
        }
      }
      Database.DMLOptions dml = new Database.DMLOptions();
      dml.OptAllOrNone = false;
      Database.SaveResult[] srList = Database.insert(sharing, dml);
  }

  /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to recalculate sharing JLOC with opportunity team members
    * @param        Set of JLOC Ids
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  public static void recalculateJlocSharingWithOpportunityTeamMembers(Set<Id> jlocIds){
    //Delete All Opportunity Team Member sharings for JLOCs
    delete [SELECT Id FROM JLOC__Share WHERE RowCause = :OPPORTUNITY_TEAM_MEMBER AND ParentId IN :jlocIds];
    //Create new sharings
    List<JLOC__Share> sharing = new List<JLOC__Share>();
    List<EntitySubscription> subscriptions = new List<EntitySubscription>();
    for(Opportunity opp : [SELECT Id, JLOC__c, (SELECT Id, UserId FROM OpportunityTeamMembers) FROM Opportunity WHERE JLOC__c IN :jlocIds]){
      for(OpportunityTeamMember oppTeamMember : opp.OpportunityTeamMembers){
        sharing.add(new JLOC__Share(ParentId=opp.JLOC__c, UserOrGroupId=oppTeamMember.UserId, RowCause=OPPORTUNITY_TEAM_MEMBER, AccessLevel='Edit'));
        subscriptions.add(ChatterUtils.addFollower(oppTeamMember.UserId, opp.JLOC__c));
      }
    }
    
    insertRecords(sharing);
    insertRecords(subscriptions);
  }

  /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to execute after JLOC update actions
    * @param        Map of new and old JLOCs
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  public static void executeAfterUpdateActions(Map<Id, JLOC__c> newJlocs, Map<Id, JLOC__c> oldJlocs){
    List<String> chatterGroups = new List<String>{GROUP_JLOC_SECRETARY, GROUP_COVERAGE, GROUP_INVESTMENT_BANKING, GROUP_PORTFOLIO_MANAGEMENT, GROUP_MARKETS, GROUP_TRADE};
    createJlocAttendeesMap(newJlocs.keySet());

    shareJlocWithSecretaryAndNotifyOnChatter(newJlocs, oldJlocs);
    shareJlocWithCommitteeMembersAndNotifyOnChatter(newJlocs, oldJlocs);
  }

  /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to share JLOC with Secretary
    * @param        Map of new and old JLOCs
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  public static void shareJlocWithSecretaryAndNotifyOnChatter(Map<Id, JLOC__c> newJlocs, Map<Id, JLOC__c> oldJlocs){
    List<JLOC__Share> sharing = new List<JLOC__Share>();
    List<EntitySubscription> subscriptions = new List<EntitySubscription>();
    List<GroupMember> jlocSecretaryMembers = [SELECT Id, UserOrGroupId FROM GroupMember WHERE Group.Name = :GROUP_JLOC_SECRETARY];
    for(Id jlocId : newJlocs.keySet()){
      if(oldJlocs.get(jlocId).JLOC_Status__c == STATUS_DRAFT && newJlocs.get(jlocId).JLOC_Status__c == STATUS_SUBMITTED_TO_SECRETARY){
        for(GroupMember jlocSecretaryMember : jlocSecretaryMembers){
          sharing.add(new JLOC__Share(ParentId=jlocId, UserOrGroupId=jlocSecretaryMember.UserOrGroupId, RowCause=JLOC_SECRETARY, AccessLevel='Edit'));
          subscriptions.add(ChatterUtils.addFollower(jlocSecretaryMember.UserOrGroupId, jlocId));
        }
      }
    }

    insertRecords(sharing);
    insertRecords(subscriptions);
  }

  /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to share JLOC with JLOC Attendees
    * @param        Map of new and old JLOCs
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  public static void shareJlocWithCommitteeMembersAndNotifyOnChatter(Map<Id, JLOC__c> newJlocs, Map<Id, JLOC__c> oldJlocs){
    List<EntitySubscription> subscriptions = new List<EntitySubscription>();

    for(Id jlocId : newJlocs.keySet()){
      if(oldJlocs.get(jlocId).JLOC_Status__c == STATUS_SUBMITTED_TO_SECRETARY && newJlocs.get(jlocId).JLOC_Status__c == STATUS_SENT_TO_COMMITTEE){
        for(JLOC_Attendee__c attendee : mapJlocAttendees.get(jlocId)){
            subscriptions.add(ChatterUtils.addFollower(attendee.User__c, jlocId));
        }
      }
    }

    insertRecords(subscriptions);
  }

  /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to create JLOC Attendees map
    * @param        Set of JLOC Ids
    * @Returns:     Map of JLOC Attendees
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  public static Map<Id, List<JLOC_Attendee__c>> createJlocAttendeesMap(Set<Id> jlocIds){
    mapJlocAttendees = new Map<Id, List<JLOC_Attendee__c>>();
    for(JLOC__c jloc : [SELECT Id, (SELECT Id, Group__c, User__c, Invited__c FROM JLOC_Attendees__r) FROM JLOC__c WHERE Id IN :jlocIds]){
      mapJlocAttendees.put(jloc.Id, jloc.JLOC_Attendees__r);
    }
    return mapJlocAttendees;
  }

  /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to perform DML operation (insert)
    * @param        List of SObject records
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
  public static void insertRecords(List<SObject> records){
    Database.DMLOptions dml = new Database.DMLOptions();
    dml.OptAllOrNone = false;
    Database.SaveResult[] srList = Database.insert(records, dml);
  }

}