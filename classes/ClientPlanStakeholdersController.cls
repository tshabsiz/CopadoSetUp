/**
* @Author       Marta Malinowska
* @Company:     Deloitte
* @Description: Controller class for ClientPlanStakeholders VF page.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanStakeholdersController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public without sharing class ClientPlanStakeholdersController  extends ClientPlanUtils{

    public String planId;
    
    public Client_Plan__c plan { get; set; }
    
    public Boolean planLoaded {get;set;}

    public String contactId {get;set;}
    
    public Map<Id, Client_Plan_Relationship__c> contactsMap {get;set;}
    
    private List<Client_Plan_Relationship__c> cprsToDelete;

    private List<Client_Plan_Relationship_Item__c> cprisToDelete;

    public ClientPlanStakeholdersController() {
        super(ApexPages.currentPage().getParameters().get('planId'),'planId');
        planId = ApexPages.currentPage().getParameters().get('planId');
        if (!String.isEmpty(planId)) {
            queryPlan();
        } else {
            planLoaded = false;
        }
    }
    
    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     remove contact and its subordinates from stakeholders hierarchy
      * @param            None
      * @Returns:         PageReference
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public PageReference remove() {
        prepareContactsMap();
        cprsToDelete = new List<Client_Plan_Relationship__c>();
        cprisToDelete = new List<Client_Plan_Relationship_Item__c>();
        if(!contactsMap.containsKey(contactId)){
            return null;
        }
        cprsToDelete.add(contactsMap.get(contactId));
        cprisToDelete.addAll(contactsMap.get(contactId).Client_Plan_Relationship_Items__r);
        removeSubordinates(contactId);
        
        delete cprisToDelete;
        delete cprsToDelete;
        
        return null;
    }
    
    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     remove contact's subordinates from stakeholders hierarchy
      * @param            Id of Contact
      * @Returns:         None
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void removeSubordinates(Id contactId) {
        for(Client_Plan_Relationship__c cpr : contactsMap.values()) {
            if(cpr.Reports_to__c == contactId) {
                cprsToDelete.add(contactsMap.get(cpr.Contact__c));
                cprisToDelete.addAll(contactsMap.get(cpr.Contact__c).Client_Plan_Relationship_Items__r);
                removeSubordinates(cpr.Contact__c);
            }
        }
    }
    
    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     query Client Plan record
      * @param            None
      * @Returns:         None
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void queryPlan() {
        List<Client_Plan__c> plans = [SELECT Id, Relationship__c FROM Client_Plan__c WHERE Id = :planId];
        
        if (plans.isEmpty()) {
            planLoaded = false;
        } else {
            planLoaded = true;
            plan = plans[0];
        }
    }

    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     prepare map of Client Plan Relationship
      * @param            None
      * @Returns:         None
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void prepareContactsMap() {
        contactsMap = new Map<Id, Client_Plan_Relationship__c>();
        for(Client_Plan_Relationship__c cpr : [SELECT Id, Contact__c, Contact__r.Name, Contact__r.Job_Role__c, Reports_To__c, Client_Strength__c,
                                                    (SELECT Id, Barclays_Contact_User__c, Influence__c, Primary_Contact__c, Strength_of_Relationship__c 
                                                    FROM Client_Plan_Relationship_Items__r)
                                                FROM Client_Plan_Relationship__c
                                                WHERE Client_Plan__c = :planId]){
            contactsMap.put(cpr.Contact__c, cpr);
        }
    }

}