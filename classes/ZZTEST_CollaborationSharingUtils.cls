/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests for CollaborationSharingUtils
*/
@isTest
private class ZZTEST_CollaborationSharingUtils {

	public static testMethod void testShareInitiativesWithTeamMembers(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Initiative initiativeFactory = ZZTEST_DataFactoryFacade.initiative;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Integer batchSize = 200;
		List<Initiative__c> initiatives = new List<Initiative__c>();
		for(Integer i=0; i<=batchSize; i++){
			initiatives.add(initiativeFactory.getProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer));
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(initiatives,dml);
        Set<Id> initiativeIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		initiativeIds.add(sr.getId());
        	}
        }

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        //Create Initiative Team Members
        List<Initiative_Team_Member__c> initTeamMembers = new List<Initiative_Team_Member__c>();
        for(Initiative__c init : initiatives){
        	initTeamMembers.add(new Initiative_Team_Member__c(Initiative__c=init.Id, Team_member__c=barclaysStdUser.Id));
        }
        insert initTeamMembers;
		
        List<Initiative__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Initiative__Share WHERE RowCause = 'Initiative_Team_Member__c' AND ParentId IN :initiativeIds];
        System.assertEquals(sharingsAfterIns.size(), batchSize+1);

        for(Initiative__Share share : sharingsAfterIns){
        	System.assertEquals(share.AccessLevel, CollaborationSharingUtils.AL_EDIT);
        }

        delete initTeamMembers;
        List<Initiative__Share> sharingsAfterDel = [SELECT Id FROM Initiative__Share WHERE RowCause = 'Initiative_Team_Member__c' AND ParentId IN :initiativeIds];
        System.assertEquals(sharingsAfterDel.size(), 0);

		Test.stopTest();
        }
		
	}

	public static testMethod void testShareInitiativesWithFollowers(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Initiative initiativeFactory = ZZTEST_DataFactoryFacade.initiative;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Integer batchSize = 200;
		List<Initiative__c> initiatives = new List<Initiative__c>();
		for(Integer i=0; i<=batchSize; i++){
			initiatives.add(initiativeFactory.getProduct(ZZTEST_F_Initiative.InitiativeRecordType.DEFAULT_INITIATIVE, dataContainer));
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(initiatives,dml);
        Set<Id> initiativeIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		initiativeIds.add(sr.getId());
        	}
        }

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        //Create Initiative Team Members
        List<Initiative_Follower__c> initTeamMembers = new List<Initiative_Follower__c>();
        for(Initiative__c init : initiatives){
        	initTeamMembers.add(new Initiative_Follower__c(Initiative__c=init.Id, Follower__c=barclaysStdUser.Id));
        }
        insert initTeamMembers;
		
        List<Initiative__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Initiative__Share WHERE RowCause = 'Initiative_Follower__c' AND ParentId IN :initiativeIds];
        System.assertEquals(sharingsAfterIns.size(), batchSize+1);

        for(Initiative__Share share : sharingsAfterIns){
        	System.assertEquals(share.AccessLevel, CollaborationSharingUtils.AL_READ);
        }

        delete initTeamMembers;
        List<Initiative__Share> sharingsAfterDel = [SELECT Id FROM Initiative__Share WHERE RowCause = 'Initiative_Follower__c' AND ParentId IN :initiativeIds];
        System.assertEquals(sharingsAfterDel.size(), 0);

		Test.stopTest();
        }
		
	}

	public static testMethod void testShareMeetingsWithAttendees(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Integer batchSize = 200;
		List<Meeting__c> meetings = new List<Meeting__c>();
		for(Integer i=0; i<=batchSize; i++){
			meetings.add(meetingFactory.getProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer));
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(meetings,dml);
        Set<Id> meetingIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		meetingIds.add(sr.getId());
        	}
        }

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        //Create Initiative Team Members
        List<Meeting_Attendee__c> meetingAttendees = new List<Meeting_Attendee__c>();
        for(Meeting__c meet : meetings){
        	meetingAttendees.add(new Meeting_Attendee__c(Meeting__c=meet.Id, Attendee__c=barclaysStdUser.Id));
        }
        insert meetingAttendees;
		
        List<Meeting__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Meeting__Share WHERE RowCause = 'Meeting_Attendee__c' AND ParentId IN :meetingIds];
        System.assertEquals(sharingsAfterIns.size(), batchSize+1);

        for(Meeting__Share share : sharingsAfterIns){
        	System.assertEquals(share.AccessLevel, CollaborationSharingUtils.AL_EDIT);
        }

        delete meetingAttendees;
        List<Meeting__Share> sharingsAfterDel = [SELECT Id FROM Meeting__Share WHERE RowCause = 'Meeting_Attendee__c' AND ParentId IN :meetingIds];
        System.assertEquals(sharingsAfterDel.size(), 0);

		Test.stopTest();
        }
		
	}

	public static testMethod void testShareMeetingsWithFollowers(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Integer batchSize = 200;
		List<Meeting__c> meetings = new List<Meeting__c>();
		for(Integer i=0; i<=batchSize; i++){
			meetings.add(meetingFactory.getProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer));
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(meetings,dml);
        Set<Id> meetingIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		meetingIds.add(sr.getId());
        	}
        }

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        //Create Initiative Team Members
        List<Meeting_Follower__c> meetingFollowers = new List<Meeting_Follower__c>();
        for(Meeting__c meet : meetings){
        	meetingFollowers.add(new Meeting_Follower__c(Meeting__c=meet.Id, Follower__c=barclaysStdUser.Id));
        }
        insert meetingFollowers;
		
        List<Meeting__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Meeting__Share WHERE RowCause = 'Meeting_Follower__c' AND ParentId IN :meetingIds];
        System.assertEquals(sharingsAfterIns.size(), batchSize+1);

        for(Meeting__Share share : sharingsAfterIns){
        	System.assertEquals(share.AccessLevel, CollaborationSharingUtils.AL_READ);
        }

        delete meetingFollowers;
        List<Meeting__Share> sharingsAfterDel = [SELECT Id FROM Meeting__Share WHERE RowCause = 'Meeting_Follower__c' AND ParentId IN :meetingIds];
        System.assertEquals(sharingsAfterDel.size(), 0);

		Test.stopTest();
        }
		
	}

	public static testMethod void testShareAgendasWithMeetingAttendees(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_Agenda agendaFactory = ZZTEST_DataFactoryFacade.agenda;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Meeting__c meeting = meetingFactory.getInsertedProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);

		Integer batchSize = 200;
		List<Agenda__c> agendas = new List<Agenda__c>();
		for(Integer i=0; i<=batchSize; i++){
			Agenda__c agenda = agendaFactory.getProduct(ZZTEST_F_Agenda.AgendaRecordType.DEFAULT_AGENDA, dataContainer);
			agenda.Meeting__c = meeting.Id;
			agendas.add(agenda);
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(agendas,dml);
        Set<Id> agendaIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		agendaIds.add(sr.getId());
        	}
        }

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

		Test.startTest();

        Meeting_Attendee__c attendee = new Meeting_Attendee__c(Meeting__c=meeting.Id, Attendee__c=barclaysStdUser.Id);
		insert attendee;

        List<Agenda__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Agenda__Share WHERE RowCause = 'Meeting_Attendee__c' AND ParentId IN :agendaIds];
        System.assertEquals(sharingsAfterIns.size(), batchSize+1);

		Test.stopTest();
        }
		
	}

	public static testMethod void testShareAgendasWithPresenter(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Meeting meetingFactory = ZZTEST_DataFactoryFacade.meeting;
		ZZTEST_F_Agenda agendaFactory = ZZTEST_DataFactoryFacade.agenda;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Meeting__c meeting = meetingFactory.getInsertedProduct(ZZTEST_F_Meeting.MeetingRecordType.DEFAULT_MEETING, dataContainer);

		User barclaysStdUser = userFactory.getBarclaysStandardUser();

		Integer batchSize = 200;
		List<Agenda__c> agendas = new List<Agenda__c>();
		for(Integer i=0; i<=batchSize; i++){
			Agenda__c agenda = agendaFactory.getProduct(ZZTEST_F_Agenda.AgendaRecordType.DEFAULT_AGENDA, dataContainer);
			agenda.Meeting__c = meeting.Id;
			agenda.Presenter__c = barclaysStdUser.Id;
			agendas.add(agenda);
		}

		Test.startTest();

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(agendas,dml);
        Set<Id> agendaIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		agendaIds.add(sr.getId());
        	}
        }

        List<Agenda__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Agenda__Share WHERE RowCause = 'Presenter__c' AND ParentId IN :agendaIds];
        System.assertEquals(sharingsAfterIns.size(), batchSize+1);

        for(Agenda__c agenda : agendas){
        	agenda.Presenter__c = UserInfo.getUserId();
        }
        srList = Database.update(agendas,dml);

		Test.stopTest();
        }
		
	}

	public static testMethod void testShareCommitteeWithMembers(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Committee committeeFactory = ZZTEST_DataFactoryFacade.committee;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Integer batchSize = 200;
		List<Committee__c> committees = new List<Committee__c>();
		for(Integer i=0; i<=batchSize; i++){
			committees.add(committeeFactory.getProduct(ZZTEST_F_Committee.CommitteeRecordType.DEFAULT_COMMITTEE, dataContainer));
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(committees,dml);
        Set<Id> committeeIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		committeeIds.add(sr.getId());
        	}
        }

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        //Create Initiative Team Members
        List<Committee_Member__c> committeeMembers = new List<Committee_Member__c>();
        for(Committee__c comm : committees){
        	committeeMembers.add(new Committee_Member__c(Committee__c=comm.Id, Committee_Member__c=barclaysStdUser.Id));
        }
        insert committeeMembers;
		
        List<Committee__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Committee__Share WHERE RowCause = 'Committee_Member__c' AND ParentId IN :committeeIds];
        System.assertEquals(sharingsAfterIns.size(), batchSize+1);

        for(Committee__Share share : sharingsAfterIns){
        	System.assertEquals(share.AccessLevel, CollaborationSharingUtils.AL_EDIT);
        }

        delete committeeMembers;
        List<Committee__Share> sharingsAfterDel = [SELECT Id FROM Committee__Share WHERE RowCause = 'Committee_Member__c' AND ParentId IN :committeeIds];
        System.assertEquals(sharingsAfterDel.size(), 0);

		Test.stopTest();
        }
		
	}

	public static testMethod void testShareCommitteeWitFollowers(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Committee committeeFactory = ZZTEST_DataFactoryFacade.committee;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Integer batchSize = 200;
		List<Committee__c> committees = new List<Committee__c>();
		for(Integer i=0; i<=batchSize; i++){
			committees.add(committeeFactory.getProduct(ZZTEST_F_Committee.CommitteeRecordType.DEFAULT_COMMITTEE, dataContainer));
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(committees,dml);
        Set<Id> committeeIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		committeeIds.add(sr.getId());
        	}
        }

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        //Create Initiative Team Members
        List<Committee_Follower__c> committeeFollowers = new List<Committee_Follower__c>();
        for(Committee__c comm : committees){
        	committeeFollowers.add(new Committee_Follower__c(Committee__c=comm.Id, Follower__c=barclaysStdUser.Id));
        }
        insert committeeFollowers;
		
        List<Committee__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Committee__Share WHERE RowCause = 'Committee_Follower__c' AND ParentId IN :committeeIds];
        System.assertEquals(sharingsAfterIns.size(), batchSize+1);

        for(Committee__Share share : sharingsAfterIns){
        	System.assertEquals(share.AccessLevel, CollaborationSharingUtils.AL_READ);
        }

        delete committeeFollowers;
        List<Committee__Share> sharingsAfterDel = [SELECT Id FROM Committee__Share WHERE RowCause = 'Committee_Follower__c' AND ParentId IN :committeeIds];
        System.assertEquals(sharingsAfterDel.size(), 0);

		Test.stopTest();
        }
		
	}

	public static testMethod void testShareActionWithAssignedUsers(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 = [Select ID from User where ID=: userInfo.getuserId()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Action actionFactory = ZZTEST_DataFactoryFacade.action;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Integer batchSize = 200;
		List<Action__c> actions = new List<Action__c>();
		for(Integer i=0; i<=batchSize; i++){
			actions.add(actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.MEETING_ACTION, dataContainer));
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(actions,dml);
        Set<Id> actionIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		actionIds.add(sr.getId());
        	}
        }

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        //Create Initiative Team Members
        List<Action_Assignment__c> actionAssignments = new List<Action_Assignment__c>();
        for(Action__c action : actions){
        	actionAssignments.add(new Action_Assignment__c(Action__c=action.Id, Assigned_to__c=barclaysStdUser.Id));
        }
        insert actionAssignments;
		
        List<Action__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Action__Share WHERE RowCause = 'Action_Assignment__c' AND ParentId IN :actionIds];
        System.assertEquals(sharingsAfterIns.size(), 2*(batchSize+1));

        for(Action__Share share : sharingsAfterIns){
        	System.assertEquals(share.AccessLevel, CollaborationSharingUtils.AL_EDIT);
        }

        delete actionAssignments;
        List<Action__Share> sharingsAfterDel = [SELECT Id FROM Action__Share WHERE RowCause = 'Action_Assignment__c' AND ParentId IN :actionIds];
        System.assertEquals(sharingsAfterDel.size(), batchSize+1);

		Test.stopTest();
        }
		
	}

	public static testMethod void testShareActionWithFollowers(){
		ZZTEST_DataContainer dataContainer = new ZZTEST_DataContainer();
        
        User user1 =[Select id from User where id =:UserInfo.getuserID()];
        
        System.runAs(user1)
        {
            ZZTEST_F_Action actionFactory = ZZTEST_DataFactoryFacade.action;
		ZZTEST_F_User userFactory = ZZTEST_DataFactoryFacade.user;

		Integer batchSize = 200;
		List<Action__c> actions = new List<Action__c>();
		for(Integer i=0; i<=batchSize; i++){
			actions.add(actionFactory.getProduct(ZZTEST_F_Action.ActionRecordType.MEETING_ACTION, dataContainer));
		}

		Database.DMLOptions dml = new Database.DMLOptions(); 
        dml.DuplicateRuleHeader.AllowSave = true;

        List<Database.SaveResult> srList = Database.insert(actions,dml);
        Set<Id> actionIds = new Set<Id>();
        for(Database.SaveResult sr : srList){
        	if(sr.isSuccess()){
        		actionIds.add(sr.getId());
        	}
        }

        User barclaysStdUser = userFactory.getBarclaysStandardUser();

        Test.startTest();

        //Create Initiative Team Members
        List<Action_Follower__c> actionFollowers = new List<Action_Follower__c>();
        for(Action__c action : actions){
        	actionFollowers.add(new Action_Follower__c(Action__c=action.Id, Follower__c=barclaysStdUser.Id));
        }
        insert actionFollowers;
		
        List<Action__Share> sharingsAfterIns = [SELECT Id, AccessLevel FROM Action__Share WHERE RowCause = 'Action_Follower__c' AND ParentId IN :actionIds];
        System.assertEquals(sharingsAfterIns.size(), batchSize+1);

        for(Action__Share share : sharingsAfterIns){
        	System.assertEquals(share.AccessLevel, CollaborationSharingUtils.AL_READ);
        }

        delete actionFollowers;
        List<Action__Share> sharingsAfterDel = [SELECT Id FROM Action__Share WHERE RowCause = 'Action_Follower__c' AND ParentId IN :actionIds];
        System.assertEquals(sharingsAfterDel.size(), 0);

		Test.stopTest();
        }
		
	}
}