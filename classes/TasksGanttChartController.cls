public with sharing class TasksGanttChartController {

    private static String COLOR_BLACK = '000000';
    private static String COLOR_RED = 'F7372F';
    private static String COLOR_YELLOW = 'F0AC28';
    private static String COLOR_GREEN = '3CC00C';
    private static String PLANNED = 'Planned';
    private static String IN_PROGRESS = 'In Progress';
    private static String COMPLETE = 'Complete';
    private static String CANCELLED = 'Cancelled';

    public TasksGanttChartController() {}

    @RemoteAction @ReadOnly
    public static String getAllPrograms() {
        List<AutocompleteItem> items = new List<AutocompleteItem>();
        for(Program__c prog : [SELECT Id, Name FROM Program__c]){
            items.add(new AutocompleteItem(prog.Name, prog.Id));
        }
        
        return JSON.serialize(items);
    }

    @RemoteAction @ReadOnly
    public static String getAllInitiatives() {
        List<AutocompleteItem> items = new List<AutocompleteItem>();
        for(Initiative__c init : [SELECT Id, Name FROM Initiative__c]){
            items.add(new AutocompleteItem(init.Name, init.Id));
        }
        
        return JSON.serialize(items);
    }

    @RemoteAction
    public static String getGanttChartDataForProgram(String programId, Boolean isPlannedSel, Boolean isInProgressSel, Boolean isCompleteSel, Boolean isCancelledSel) {
        
        //Select Program
        Program__c program;
        try{
            program = [SELECT Id, Name FROM Program__c WHERE Id = :programId];
        } catch(System.QueryException ex){
            System.debug('QueryException: '+ex);
        }

        Set<Id> initiativeIds = new Set<Id>();
        for(Program_Connector__c pc : [SELECT Initiative__c FROM Program_Connector__c WHERE Program__c = :programId]){
            initiativeIds.add(pc.Initiative__c);
        }
        
        //Select Initiatives
        String queryInitiatives = 'SELECT Id, Name, Start_Date__c, End_Date__c, Parent_Initiative__c FROM Initiative__c WHERE Id IN :initiativeIds';
        //Apply Stage Filters
        Set<String> selectedStages = new Set<String>();
        if(isPlannedSel){
            selectedStages.add(PLANNED);
        }
        if(isInProgressSel){
            selectedStages.add(IN_PROGRESS);
        }
        if(isCompleteSel){
            selectedStages.add(COMPLETE);
        }
        if(isCancelledSel){
            selectedStages.add(CANCELLED);
        }
        queryInitiatives += ' AND Stage__c IN :selectedStages';
        
        List<Initiative__c> initiativeList = Database.query(queryInitiatives);
        Map<Id, Initiative__c> mapInitiatives = new Map<Id, Initiative__c>(initiativeList);

        //Select Actions not assigned to Section
        Map<Id, Map<Id, Action__c>> mapInitiativeActions = createMapInitiativeActions(mapInitiatives);

        //Select Sections
        Map<Id, Section__c> mapSections = new Map<Id, Section__c>([SELECT Id, Name, Initiative__c FROM Section__c WHERE Initiative__c IN :mapInitiatives.keySet()]);
        Map<Id, Map<Id, Section__c>> mapInitiativeSections = createMapInitiativeSections(mapSections);

        //Select Actions with Tasks
        Map<Id, Map<Id, Action__c>> mapSectionActions = createMapSectionActions(mapSections);

        List<TaskItem> items = createTaskItems(program, mapInitiatives, mapInitiativeActions, mapInitiativeSections, mapSectionActions);
        
        if(items.isEmpty()){
            return '';
        } else{
            return JSON.serialize(items);
        }

    }

    @RemoteAction
    public static String getGanttChartDataForInitiative(String initiativeId) {

        Set<Id> initiativeIds = new Set<Id>();
        initiativeIds.add(initiativeId);
        
        List<Initiative__c> initiativeList = [SELECT Id, Name, Start_Date__c, End_Date__c, Parent_Initiative__c FROM Initiative__c WHERE Id IN :initiativeIds];
        Map<Id, Initiative__c> mapInitiatives = new Map<Id, Initiative__c>(initiativeList);

        //Select Actions not assigned to Section
        Map<Id, Map<Id, Action__c>> mapInitiativeActions = createMapInitiativeActions(mapInitiatives);

        //Select Sections
        Map<Id, Section__c> mapSections = new Map<Id, Section__c>([SELECT Id, Name, Initiative__c FROM Section__c WHERE Initiative__c IN :mapInitiatives.keySet()]);
        Map<Id, Map<Id, Section__c>> mapInitiativeSections = createMapInitiativeSections(mapSections);

        //Select Actions with Tasks
        Map<Id, Map<Id, Action__c>> mapSectionActions = createMapSectionActions(mapSections);

        List<TaskItem> items = createTaskItems(null, mapInitiatives, mapInitiativeActions, mapInitiativeSections, mapSectionActions);
        
        if(items.isEmpty()){
            return '';
        } else{
            return JSON.serialize(items);
        }

    }

    public static List<TaskItem> createTaskItems(Program__c program, Map<Id, Initiative__c> mapInitiatives, Map<Id, Map<Id, Action__c>> mapInitiativeActions,
                                                Map<Id, Map<Id, Section__c>> mapInitiativeSections, Map<Id, Map<Id, Action__c>> mapSectionActions){
        List<TaskItem> items = new List<TaskItem>();
        Map<Id, Integer> mapTaskItemIds = new Map<Id, Integer>(); 
        String link;
        String color;
        Integer counter = 0;
        Integer programId = 0;

        if(program != null){
            counter++;
            mapTaskItemIds.put(program.Id, counter);
            programId = mapTaskItemIds.get(program.Id);
            link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+program.Id;
            items.add(new TaskItem(programId, program.Name, null, null, COLOR_BLACK, link, 0, 'res', 0, 1, 0, 0));
        }

        for(Initiative__c i : mapInitiatives.values()){
            counter++;
            mapTaskItemIds.put(i.Id, counter);
            link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+i.Id;
            items.add(new TaskItem(mapTaskItemIds.get(i.Id), i.Name, i.Start_Date__c, i.End_Date__c, COLOR_BLACK, link, 0, 'res', 0, 1, programId, 0));
            if(mapInitiativeActions.containsKey(i.Id)){
                for(Action__c a : mapInitiativeActions.get(i.Id).values()){
                    counter++;
                    mapTaskItemIds.put(a.Id, counter);
                    color = getColor(a.IsClosed__c, a.IsOverdue__c);
                    link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+a.Id;
                    Integer isGroup = a.Tasks.isEmpty() ? 0 : 1;
                    items.add(new TaskItem(mapTaskItemIds.get(a.Id), a.Name, a.Start_Date__c, a.Due_Date__c, color, link, 0, 'res', 0, isGroup, mapTaskItemIds.get(a.Initiative__c), 0));

                    for(Task t : a.Tasks){
                        counter++;
                        mapTaskItemIds.put(t.Id, counter);
                        color = getColor(t.IsClosed, t.IsOverdue__c);
                        link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+t.Id;
                        items.add(new TaskItem(mapTaskItemIds.get(t.Id), t.Subject, t.ActivityDate, t.ActivityDate, color, link, 0, 'res', 0, 0, mapTaskItemIds.get(a.Id), 0));
                    }
                }
            }
            if(mapInitiativeSections.containsKey(i.Id)){
                for(Section__c m : mapInitiativeSections.get(i.Id).values()){
                    counter++;
                    mapTaskItemIds.put(m.Id, counter);
                    link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+m.Id;
                    items.add(new TaskItem(mapTaskItemIds.get(m.Id), m.Name, null, null, COLOR_BLACK, link, 0, 'res', 0, 1, mapTaskItemIds.get(i.Id), 0));
                    if(mapSectionActions.containsKey(m.Id)){
                        for(Action__c a : mapSectionActions.get(m.Id).values()){
                            counter++;
                            mapTaskItemIds.put(a.Id, counter);
                            color = getColor(a.IsClosed__c, a.IsOverdue__c);
                            link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+a.Id;
                            Integer isGroup = a.Tasks.isEmpty() ? 0 : 1;
                            items.add(new TaskItem(mapTaskItemIds.get(a.Id), a.Name, a.Start_Date__c, a.Due_Date__c, color, link, 0, 'res', 0, isGroup, mapTaskItemIds.get(a.Section__c), 0));

                            for(Task t : a.Tasks){
                                counter++;
                                mapTaskItemIds.put(t.Id, counter);
                                color = getColor(t.IsClosed, t.IsOverdue__c);
                                link = URL.getSalesforceBaseUrl().toExternalForm()+'/'+t.Id;
                                items.add(new TaskItem(mapTaskItemIds.get(t.Id), t.Subject, t.ActivityDate, t.ActivityDate, color, link, 0, 'res', 0, 0, mapTaskItemIds.get(a.Id), 0));
                            }
                        }
                    }
                }
            }
        }
        return items;
    }

    public static Map<Id, Map<Id, Action__c>> createMapInitiativeActions(Map<Id, Initiative__c> mapInitiatives){
        Map<Id, Map<Id, Action__c>> mapInitiativeActions = new Map<Id, Map<Id, Action__c>>();
        for(Action__c a : [SELECT Id, Name, Start_Date__c, Due_Date__c, IsClosed__c, IsOverdue__c, Initiative__c,
                                        (SELECT Id, Subject, CreatedDate, ActivityDate, IsClosed, IsOverdue__c FROM Tasks)
                                        FROM Action__c WHERE Start_Date__c != null AND Section__c = null 
                                        AND Initiative__c IN :mapInitiatives.keySet()
                                        ORDER BY Start_Date__c]){
            if(mapInitiativeActions.containsKey(a.Initiative__c)){
                mapInitiativeActions.get(a.Initiative__c).put(a.Id, a);
            } else{
                mapInitiativeActions.put(a.Initiative__c, new Map<Id, Action__c>{a.Id => a});
            }
        }
        return mapInitiativeActions;
    }

    public static Map<Id, Map<Id, Section__c>> createMapInitiativeSections(Map<Id, Section__c> mapSections){
        Map<Id, Map<Id, Section__c>> mapInitiativeSections = new Map<Id, Map<Id, Section__c>>();
        for(Section__c s : mapSections.values()){
            if(mapInitiativeSections.containsKey(s.Initiative__c)){
                mapInitiativeSections.get(s.Initiative__c).put(s.Id, s);
            } else{
                mapInitiativeSections.put(s.Initiative__c, new Map<Id, Section__c>{s.Id => s});
            }
        }
        return mapInitiativeSections;
    }

    public static Map<Id, Map<Id, Action__c>> createMapSectionActions(Map<Id, Section__c> mapSections){
        Map<Id, Map<Id, Action__c>> mapSectionActions = new Map<Id, Map<Id, Action__c>>();
        for(Action__c a : [SELECT Id, Name, Start_Date__c, Due_Date__c, IsClosed__c, IsOverdue__c, Section__c,
                                        (SELECT Id, Subject, CreatedDate, ActivityDate, IsClosed, IsOverdue__c FROM Tasks)
                                        FROM Action__c WHERE Start_Date__c != null AND Section__c IN :mapSections.keySet() 
                                        ORDER BY Start_Date__c]){
            if(mapSectionActions.containsKey(a.Section__c)){
                mapSectionActions.get(a.Section__c).put(a.Id, a);
            } else{
                mapSectionActions.put(a.Section__c, new Map<Id, Action__c>{a.Id => a});
            }
        }
        return mapSectionActions;
    }

    public static String convertDateToString(Date d){
        if(d != null){
            return d.month()+'/'+d.day()+'/'+d.year();
        } else{
            return '';
        }
        
    }

    public static String getColor(Boolean isClosed, Boolean isOverdue){
        if(isClosed){
            return COLOR_GREEN;
        } else if(isOverdue){
            return COLOR_RED;
        } else{
            return COLOR_YELLOW;
        }
    }

    public class AutocompleteItem {
        String value;
        Id data;

        public AutocompleteItem(String value, Id data){
            this.value = value;
            this.data = data;
        }
    }

    public class TaskItem {
        Integer pID;    //(required) is a unique ID used to identify each row for parent functions and for setting dom id for hiding/showing
        String pName;   //(required) is the task Label
        String pStart;  //(required) the task start date, can enter empty date ('') for groups. You can also enter specific time (2/10/2008 12:00) for additional percision or half days.
        String pEnd;    //(required) the task end date, can enter empty date ('') for groups
        String pColor;  //(required) the html color for this task; e.g. '00ff00'
        String pLink;   //(optional) any http link navigated to when task bar is clicked.
        Integer pMile;  //(optional) represent a milestone: 0 or 1
        String pRes;    //(optional) resource name
        Integer pComp;  //(required) completion percent
        Integer pGroup; //(optional) indicates whether this is a group(parent) - 0=NOT Parent; 1=IS Parent
        Integer pParent;//(required) identifies a parent pID, this causes this task to be a child of identified task
        Integer pOpen;  //UNUSED - in future can be initially set to close folder when chart is first drawn. You should be able to add items to the chart in realtime via javascript and issuing "g.Draw()" command.
        
        public TaskItem(Integer pID, String pName, Date pStart, Date pEnd, String pColor, String pLink, Integer pMile, String pRes, Integer pComp, Integer pGroup, Integer pParent, Integer pOpen){
            this.pID = pID;
            this.pName = pName;
            this.pStart = convertDateToString(pStart);
            this.pEnd = convertDateToString(pEnd);
            this.pColor = pColor;
            this.pLink = pLink;
            this.pMile = pMile;
            this.pRes = pRes;
            this.pComp = pComp;
            this.pGroup = pGroup;
            this.pParent = pParent;
            this.pOpen = pOpen;
        }
    }
}