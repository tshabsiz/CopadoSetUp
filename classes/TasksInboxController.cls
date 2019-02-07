public with sharing class TasksInboxController {

  public static String STATUS_OPEN = 'Open';
  public static String MY_ASSIGNMENTS = 'My Assignments';
  public static String MY_DELEGATED = 'My Delegated';
  public static String WHAT_I_FOLLOW = 'What I Follow';
  public static String ALL = 'All';
  public static String OVERDUE = 'Overdue';
  public static String TODAY = 'Today';
  public static String THIS_WEEK = 'This Week';
  public static String LATER = 'Later';
	private Date currentDate;
	private Date startOfWeekDate;
	private Date endOfWeekDate;
	private Id currentUser;
	public String filterOption { get; set; }
	public String dateFilterOption { get; set; }

	public TasksInboxController() {
    currentDate = Date.today();
    startOfWeekDate = currentDate.toStartOfWeek();
    endOfWeekDate = startOfWeekDate.addDays(7);
    currentUser = UserInfo.getUserId();
		filterOption = MY_ASSIGNMENTS;
		dateFilterOption = ALL;
	}

	public List<TaskItem> getTaskItems() {
       List<TaskItem> taskItems = new List<TaskItem>();
       //Select Actions
		    String queryActionAssignments = 'SELECT Action__r.Id, Action__r.Name, Action__r.Due_Date__c, Action__r.IsClosed__c, Action__r.IsOverdue__c, Action__r.Initiative__c, Action__r.Initiative__r.Name, Action__r.Meeting__c, Action__r.Meeting__r.Name, Assigned_to__c FROM Action_Assignment__c WHERE Action__r.Status__c = :STATUS_OPEN';
		    String queryActionFollowers = 'SELECT Action__r.Id, Action__r.Name, Action__r.Due_Date__c, Action__r.IsClosed__c, Action__r.IsOverdue__c, Action__r.Initiative__c, Action__r.Initiative__r.Name, Action__r.Meeting__c, Action__r.Meeting__r.Name, Follower__c FROM Action_Follower__c WHERE Action__r.Status__c = :STATUS_OPEN';
		    String queryDelegatedActions = 'SELECT Id, Name, Due_Date__c, IsClosed__c, IsOverdue__c, Initiative__c, Initiative__r.Name, Meeting__c, Meeting__r.Name, (SELECT Id FROM Assignments__r WHERE Assigned_to__c != :currentUser) FROM Action__c WHERE Status__c = :STATUS_OPEN';
        //Select Tasks
        String queryTasks = 'SELECT Id, Subject, ActivityDate, WhatId, What.Name, IsClosed, IsOverdue__c FROM Task WHERE Status = :STATUS_OPEN';

        if(dateFilterOption == OVERDUE){
            queryActionAssignments += ' AND Action__r.Due_Date__c < :currentDate';
            queryActionFollowers += ' AND Action__r.Due_Date__c < :currentDate';
            queryDelegatedActions += ' AND Due_Date__c < :currentDate';
            queryTasks += ' AND ActivityDate < :currentDate';
        }
        if(dateFilterOption == TODAY){
            queryActionAssignments += ' AND Action__r.Due_Date__c = :currentDate';
            queryActionFollowers += ' AND Action__r.Due_Date__c = :currentDate';
            queryDelegatedActions += ' AND Due_Date__c = :currentDate';
            queryTasks += ' AND ActivityDate = :currentDate';
        } 
        if(dateFilterOption == THIS_WEEK){
        	queryActionAssignments += ' AND Action__r.Due_Date__c >= :startOfWeekDate AND Action__r.Due_Date__c <= :endOfWeekDate';
          queryActionFollowers += ' AND Action__r.Due_Date__c >= :startOfWeekDate AND Action__r.Due_Date__c <= :endOfWeekDate';
          queryDelegatedActions += ' AND Due_Date__c >= :startOfWeekDate AND Due_Date__c <= :endOfWeekDate';
        	queryTasks += ' AND ActivityDate >= :startOfWeekDate AND ActivityDate <= :endOfWeekDate';
        }
        if(dateFilterOption == LATER){
        	queryActionAssignments += ' AND Action__r.Due_Date__c > :endOfWeekDate';
          queryActionFollowers += ' AND Action__r.Due_Date__c > :endOfWeekDate';
          queryDelegatedActions += ' AND Due_Date__c > :endOfWeekDate';
        	queryTasks += ' AND ActivityDate > :endOfWeekDate';
        }

        //Apply Filters
        if(filterOption == MY_ASSIGNMENTS){
            queryActionAssignments += ' AND Assigned_to__c = :currentUser';
            queryTasks += ' AND OwnerId = :currentUser';
            taskItems.addAll(getActionAssignments(queryActionAssignments));
            taskItems.addAll(getTasks(queryTasks));
        } else if(filterOption == MY_DELEGATED){
            queryDelegatedActions += ' AND OwnerId = :currentUser';
            queryTasks += ' AND CreatedById = :currentUser AND OwnerId != :currentUser';
            taskItems.addAll(getDelegatedActions(queryDelegatedActions));
            taskItems.addAll(getTasks(queryTasks));
        } else if(filterOption == WHAT_I_FOLLOW){
        	queryActionFollowers += ' AND Follower__c = :currentUser';
        	taskItems.addAll(getActionFollowers(queryActionFollowers));
        }
		
        return taskItems;
    }

    public List<TaskItem> getActionAssignments(String queryActionAssignments){
    	List<TaskItem> actionAssignments = new List<TaskItem>();
    	for(Action_Assignment__c a : Database.query(queryActionAssignments)){
       		if(String.isNotBlank(a.Action__r.Initiative__c)){
       			actionAssignments.add(new TaskItem(a.Action__r.Id, a.Action__r.Name, a.Action__r.Due_Date__c, a.Action__r.Initiative__c, a.Action__r.Initiative__r.Name, a.Action__r.IsClosed__c, a.Action__r.IsOverdue__c));
       		} else if(String.isNotBlank(a.Action__r.Meeting__c)){
       			actionAssignments.add(new TaskItem(a.Action__r.Id, a.Action__r.Name, a.Action__r.Due_Date__c, a.Action__r.Meeting__c, a.Action__r.Meeting__r.Name, a.Action__r.IsClosed__c, a.Action__r.IsOverdue__c));
       		}
		  }
		  return actionAssignments;
    }

    public List<TaskItem> getActionFollowers(String queryActionFollowers){
    	List<TaskItem> actionFollowers = new List<TaskItem>();
    	for(Action_Follower__c a : Database.query(queryActionFollowers)){
       		if(String.isNotBlank(a.Action__r.Initiative__c)){
       			actionFollowers.add(new TaskItem(a.Action__r.Id, a.Action__r.Name, a.Action__r.Due_Date__c, a.Action__r.Initiative__c, a.Action__r.Initiative__r.Name, a.Action__r.IsClosed__c, a.Action__r.IsOverdue__c));
       		} else if(String.isNotBlank(a.Action__r.Meeting__c)){
       			actionFollowers.add(new TaskItem(a.Action__r.Id, a.Action__r.Name, a.Action__r.Due_Date__c, a.Action__r.Meeting__c, a.Action__r.Meeting__r.Name, a.Action__r.IsClosed__c, a.Action__r.IsOverdue__c));
       		}
		  }
		  return actionFollowers;
    }

    public List<TaskItem> getDelegatedActions(String queryDelegatedActions){
      List<TaskItem> delegatedActions = new List<TaskItem>();
      for(Action__c a : Database.query(queryDelegatedActions)){
        if(!a.Assignments__r.isEmpty()){
          if(String.isNotBlank(a.Initiative__c)){
            delegatedActions.add(new TaskItem(a.Id, a.Name, a.Due_Date__c, a.Initiative__c, a.Initiative__r.Name, a.IsClosed__c, a.IsOverdue__c));
          } else if(String.isNotBlank(a.Meeting__c)){
            delegatedActions.add(new TaskItem(a.Id, a.Name, a.Due_Date__c, a.Meeting__c, a.Meeting__r.Name, a.IsClosed__c, a.IsOverdue__c));
          }
        }
      }
      return delegatedActions;
    }

    public List<TaskItem> getTasks(String queryTasks){
    	List<TaskItem> tasks = new List<TaskItem>();
    	for(Task t : Database.query(queryTasks)){
			tasks.add(new TaskItem(t.Id, t.Subject, t.ActivityDate, t.WhatId, t.What.Name, t.IsClosed, t.IsOverdue__c));
		}
		return tasks;
    }

    public List<SelectOption> getFilterOptions() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(MY_ASSIGNMENTS, MY_ASSIGNMENTS)); 
		options.add(new SelectOption(MY_DELEGATED, MY_DELEGATED));
		options.add(new SelectOption(WHAT_I_FOLLOW, WHAT_I_FOLLOW));
		return options;
    }

    public List<SelectOption> getDateFilterOptions() {
		List<SelectOption> options = new List<SelectOption>();
		options.add(new SelectOption(ALL, ALL)); 
		options.add(new SelectOption(OVERDUE, OVERDUE));
		options.add(new SelectOption(TODAY, TODAY)); 
		options.add(new SelectOption(THIS_WEEK, THIS_WEEK));
		options.add(new SelectOption(LATER, LATER));
		return options;
    }

	public class TaskItem {
    public Id ID { get; set; }
    public String Subject { get; set; }
    public Date StartDate { get; set; }
    public Date DueDate { get; set; }
    public Id RelatedToId { get; set; }
    public String RelatedToName { get; set; }
    public String Source { get; set; }
    public Boolean isClosed { get; set; }
    public Boolean isOverdue { get; set; }
        
    public TaskItem(Id ID, String Subject, Date DueDate, Id RelatedToId, String RelatedToName, Boolean isClosed, Boolean isOverdue){
      this.ID = ID;
      this.Subject = Subject;
      this.StartDate = StartDate;
      this.DueDate = DueDate;
      this.RelatedToId = RelatedToId;
      this.RelatedToName = RelatedToName;
      try{
        this.Source = String.isBlank(RelatedToId) ? '' : RelatedToId.getSobjectType().getDescribe().getLabel();
      } catch(System.SObjectException ex){
        this.Source = '';
      }
      this.isClosed = isClosed;
      this.isOverdue = isOverdue;
    }
  }
}