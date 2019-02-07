public class MeetingTrigger_Helper {

    public static void copyDefaultDataFromCommittee(List<Meeting__c> meetings){
        Set<Id> committeeIds = new Set<Id>();
        for(Meeting__c meeting : meetings){
            committeeIds.add(meeting.Committee__c);
        }

        addMeetingAttendeesAndFollowers(meetings, committeeIds);
        addMeetingAgenda(meetings, committeeIds);
    }

    public static void addMeetingAttendeesAndFollowers(List<Meeting__c> meetings, Set<Id> committeeIds) {

        Map<Id, List<Committee_Member__c>> committeeMembers = new Map<Id, List<Committee_Member__c>>();
        for(Committee__c committee : [SELECT Id, (SELECT Id, Committee_Member__c FROM Committee_Members__r) FROM Committee__c WHERE Id IN :committeeIds]){
            committeeMembers.put(committee.Id, committee.Committee_Members__r);
        }

        Map<Id, List<Committee_Follower__c>> committeeFollowers = new Map<Id, List<Committee_Follower__c>>();
        for(Committee__c committee : [SELECT Id, (SELECT Id, Follower__c FROM Followers__r) FROM Committee__c WHERE Id IN :committeeIds]){
            committeeFollowers.put(committee.Id, committee.Followers__r);
        }

        List<Meeting_Attendee__c> meetingAttendeesToIns = new List<Meeting_Attendee__c>();
        List<Meeting_Follower__c> meetingFollowersToIns = new List<Meeting_Follower__c>();
        for(Meeting__c meeting : meetings){
            if(String.isNotBlank(meeting.Committee__c)){
                for(Committee_Member__c committeeMember : committeeMembers.get(meeting.Committee__c)){
                    meetingAttendeesToIns.add(new Meeting_Attendee__c(Meeting__c = meeting.Id, Attendee__c = committeeMember.Committee_Member__c));
                }
                for(Committee_Follower__c committeeFollower : committeeFollowers.get(meeting.Committee__c)){
                    meetingFollowersToIns.add(new Meeting_Follower__c(Meeting__c = meeting.Id, Follower__c = committeeFollower.Follower__c));
                }
            }
        }
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        Database.SaveResult[] srList1 = Database.insert(meetingAttendeesToIns, dml);
        Database.SaveResult[] srList2 = Database.insert(meetingFollowersToIns, dml);
    }

    public static void addMeetingAgenda(List<Meeting__c> meetings, Set<Id> committeeIds) {
        Map<Id, List<Standing_Agenda__c>> committeeStandingAgenda = new Map<Id, List<Standing_Agenda__c>>();
        for(Committee__c committee : [SELECT Id, (SELECT Id, Name, Order__c, User__c FROM Default_Agenda__r) FROM Committee__c WHERE Id IN :committeeIds]){
            committeeStandingAgenda.put(committee.Id, committee.Default_Agenda__r);
        }

        List<Agenda__c> meetingAgendaToIns = new List<Agenda__c>();
        for(Meeting__c meeting : meetings){
            if(String.isNotBlank(meeting.Committee__c)){
                for(Standing_Agenda__c standingAgenda : committeeStandingAgenda.get(meeting.Committee__c)){
                    meetingAgendaToIns.add(new Agenda__c(Meeting__c = meeting.Id, Description__c = standingAgenda.Name, Order__c = standingAgenda.Order__c, Presenter__c = standingAgenda.User__c));
                }
            }
        }
        
        Database.DMLOptions dml = new Database.DMLOptions();
        dml.OptAllOrNone = false;
        Database.SaveResult[] srList = Database.insert(meetingAgendaToIns, dml);
    }

}