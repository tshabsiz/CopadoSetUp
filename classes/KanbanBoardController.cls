public with sharing class KanbanBoardController {

    public Decimal columnWidth { get; set; }
    public Map <Integer, ActionWrapper> kanBanUSMap{get; set;}

    public List<Section__c> sections {get; set;} 
    //public List<Initiative__c> initiatives = new List<Initiative__c>();
    
    //This is used to display the values in the VF page.
    public List<ActionWrapper> allGroupedUserStories {get;set;}
    
    public Id initiativeId;
    //public string SprintName;
    //public Set <String> sectionNames = new Set<String>();
    //public Set <Id> sectionIds = new Set<Id>();

    /*Bascailly the code picks up all the Userstory Status values from a customer setting called TKR_US_Status__c 
    and for all the selected sprints which is/are 'In Progress' it picks up the user stories against each status in the 'DispUserStories' function.
    Afterwards VF page displays all these values */  
	public KanbanBoardController(ApexPages.StandardController controller) {
		
        allGroupedUserStories = null;
        
        allGroupedUserStories = new list<ActionWrapper>();
        kanBanUSMap = new  map <Integer, ActionWrapper>();
        
        // Query all the user stories in the sprint
        initiativeId = ApexPages.currentpage().getparameters().get('Id');
        sections = [SELECT Id, Name FROM Section__c WHERE Initiative__c = :initiativeId ORDER BY Order__c];
        if(sections.size() > 0){
          columnWidth = 100 / sections.size();
        } else{
          columnWidth = 100;
        }
        
        DispUserStories();

    }
        
  // Display all user stories taking into account filters  
  Public void DispUserStories(){
    
    allGroupedUserStories = new  List<ActionWrapper>();

    Integer order = 0;

    for(Section__c section : [SELECT Id, Name, (SELECT Id, Name, Comments__c FROM Action_Items__r) FROM Section__c 
                              WHERE Initiative__c = :initiativeId ORDER BY Order__c]){
    	ActionWrapper usGrp = new ActionWrapper();
        usGrp.statusValue = section.Name ;
        usGrp.squenceValue = order++;
        usGrp.displayValue = true;
        usGrp.relatedUserStories = new List<Action__c>();
    	for(Action__c action : section.Action_Items__r){
    		usGrp.relatedUserStories.add(action);
    	}

    	allGroupedUserStories.add(usGrp);
    }
    
  }
    
    
    //Change this code
    public void updateUserStoriesSprint(){
     String  UpdateSwing     = Apexpages.currentPage().getParameters().get('UpdateSwing');
     String  userStroyID     = Apexpages.currentPage().getParameters().get('UserStoryID');
     Action__c req = new Action__c(id=userStroyID);
     
     for(Section__c sNameMapping : sections)
        {
           if(UpdateSwing==sNameMapping.Name)
            req.Section__c =sNameMapping.Id;
        }
         
     update req;
     
     }
     
     //Inner class to store the respective Userstories against the US status. 
    public class ActionWrapper{
    
        public string statusValue {get;set;}
        public boolean displayValue {get;set;}
        public Integer squenceValue {get;set;}
        public List<Action__c> relatedUserStories {get;set;}

        public ActionWrapper(){
            squenceValue = -1;
            statusValue = '';
            displayValue = false;
            relatedUserStories = new List<Action__c>();

        }
        
        public ActionWrapper(ActionWrapper usGrp)
        {
            squenceValue = usGrp.squenceValue; 
            statusValue = usGrp.statusValue;
            displayValue = usGrp.displayValue;
            relatedUserStories = usGrp.relatedUserStories;
        }
	}
}