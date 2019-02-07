/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanStakeholdersHierarchy VF component.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanStakeholdersHierarchyCt
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public without sharing class ClientPlanStakeholdersHierarchyCtr {

    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     get job role options for dropdown
      * @Params:          None
      * @Returns:         List of Select Options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public List<SelectOption> getJobRoleOptions() {
        Schema.DescribeFieldResult f = Contact.Job_Role__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }

    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     get relationship strength options for dropdown
      * @Params:          None
      * @Returns:         List of Select Options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public List<SelectOption> getRelationshipStrengthOptions() {
        Schema.DescribeFieldResult f = Client_Plan_Relationship_Item__c.Strength_of_Relationship__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }

    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     get influence options for dropdown
      * @Params:          None
      * @Returns:         List of Select Options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public List<SelectOption> getInfluenceOptions() {
        Schema.DescribeFieldResult f = Client_Plan_Relationship__c.Client_Strength__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }

    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     preparing list of select options
      * @Params:          Describe Fields Result
      * @Returns:         List of Select Options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private List<SelectOption> prepareSelectOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            options.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        return options;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares JSON with data for diagram
      * @Params:          Id of client plan
      * @Returns:         String - JSON with data
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String getHierarchyChartData(String accountPlanId) {

        List<ChartItem> items = new List<ChartItem>();

        for (Client_Plan_Relationship__c apr: 
                [SELECT Id, Contact__c, Reports_to__c, Contact__r.Name, Contact__r.Job_Role__c, 
                      Contact__r.Job_Title__c, Comment__c, Client_Strength__c,
                      (
                        SELECT Id, Barclays_Contact_User__r.Name, Strength_of_Relationship__c, Primary_Contact__c, Barclays_Contact_User__r.Senior_Sponsor__c
                        FROM Client_Plan_Relationship_Items__r
                        ORDER BY Primary_Contact__c DESC
                      )
                 FROM Client_Plan_Relationship__c
                 WHERE Client_Plan__c = :accountPlanId
                 ORDER BY Contact__r.Name]) {
                
            ChartItem ci = new ChartItem();
            ci.id = apr.Contact__c;
            ci.aprId = apr.Id;
            ci.parent = apr.Reports_to__c;
            ci.title = apr.Contact__r.Name;
            ci.jobRole = getString(apr.Contact__r.Job_Role__c);
            ci.jobTitle = getString(apr.Contact__r.Job_Title__c);
            ci.clientStrength = String.isNotBlank(apr.Client_Strength__c) ? apr.Client_Strength__c : '1';
            ci.comment = getString(apr.Comment__c);
            ci.barclaysContacts = new List<BarclaysContact>();
            for(Client_Plan_Relationship_Item__c cpri : apr.Client_Plan_Relationship_Items__r){
              BarclaysContact bc = new BarclaysContact();
              bc.id = cpri.Id;
              bc.name = String.isNotBlank(cpri.Barclays_Contact_User__c) ? cpri.Barclays_Contact_User__r.Name : '';
              bc.clientStrength = getString(cpri.Strength_of_Relationship__c);
              bc.primary = cpri.Primary_Contact__c;
              bc.seniorSponsor = (String.isNotBlank(cpri.Barclays_Contact_User__c) && cpri.Barclays_Contact_User__r.Senior_Sponsor__c) ? true : false;
              ci.barclaysContacts.add(bc);
            }
            items.add(ci);
        }
        
        if (items.isEmpty()) {
            return '';
        } else {
            return JSON.serialize(items);
        }
    }

    /**
    * @Author:          Marta Malinowska
    * @Company:         Deloitte
    * @Description:     add new Contact and add Client Plan Relationship for this contact
    * @Params:          First Name, Last Name, Job Title, Job Role, Email, Phone, Mobile, Id of Client Plan, Id of Client Plan Relationship
    * @Returns:         String - error message if error occured, null otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    @RemoteAction
    public static String addNewContact(String firstName, String lastName, String jobTitle, String jobRole, String email, 
                                        String phone, String mobile, String clientStrength, Id accountPlanId, Id parentId, Id relationshipId) {
                                        
        List<Client_Plan__c> accountPlans = [SELECT Id, Relationship__c FROM Client_Plan__c WHERE Id = :accountPlanId];
        if(accountPlans.isEmpty()){
          return 'Client Plan cannot be found.';
        }
        Contact newContact = new Contact();
        newContact.AccountId = accountPlans[0].Relationship__c;
        newContact.FirstName = firstName;
        newContact.LastName = lastName;
        newContact.Job_title__c = jobTitle;
        newContact.Job_Role__c = jobRole;
        newContact.Email = email;
        newContact.Phone = phone;
        newContact.MobilePhone = mobile;

        try {
            insert newContact;
        } catch (DmlException e) {
            return e.getDmlMessage(0);
        }

        addRelationship(accountPlanId, parentId, relationshipId, newContact.Id, clientStrength);
        
        return null;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds relationships to diagram
      * @Params:          Id of client plan, Id of parent contact, Ids of contacts to add
      * @Returns:         Boolean - false if error occured, true otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String addRelationship(Id accountPlanId, Id parentId, Id relationshipId, Id contactId, String influence) {
        Client_Plan_Relationship__c relationshipToIns = new Client_Plan_Relationship__c();
        relationshipToIns.Client_Plan__c = accountPlanId;
        relationshipToIns.Contact__c = contactId;
        relationshipToIns.Reports_to__c = String.isNotBlank(parentId) ? parentId : null;
        relationshipToIns.Client_Strength__c = influence;

        Savepoint sp = Database.setSavepoint();
        try {
            insert relationshipToIns;
        } catch (DmlException ex) {
            System.debug(ex);
            return ex.getDmlMessage(0);
        }

        if(String.isBlank(parentId) && String.isNotBlank(relationshipId)){
            Client_Plan_Relationship__c relationshipToUpd;
            try{
                relationshipToUpd = [SELECT Id, Reports_to__c FROM Client_Plan_Relationship__c WHERE Id = :relationshipId];
            } catch(QueryException ex){
                Database.rollback(sp);
                System.debug(ex);
                return ex.getDmlMessage(0);
            }
            relationshipToUpd.Reports_to__c = contactId;
            try{
                update relationshipToUpd;
            } catch (DmlException ex) {
                Database.rollback(sp);
                System.debug(ex);
                return ex.getDmlMessage(0);
            }
        }
        return null;
    }

    /**
    * @Author:          Marta Malinowska
    * @Company:         Deloitte
    * @Description:     edit Client Plan Relationship
    * @Params:          Id of client plan relationship, strenght of relationship
    * @Returns:         String - error message if error occured, null otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    @RemoteAction
    public static String editContact(Id relationshipId, String clientStrength) {
        Client_Plan_Relationship__c relationship = new Client_Plan_Relationship__c();
        relationship.Id = relationshipId;
        relationship.Client_Strength__c = clientStrength;

        try {
            update relationship;
        } catch (DmlException e) {
            return e.getDmlMessage(0);
        }

        return null;
    }

    /**
    * @Author:          Marta Malinowska
    * @Company:         Deloitte
    * @Description:     add Client Plan Relationship Item (Barclays contact) 
    * @Params:          Id of user, strenght of relationship, Id of relationship, primary contact: true or false
    * @Returns:         String - error message if error occured, null otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    @RemoteAction
    public static String addNewBarclaysContact(Id userId, String relationshipStrength, Id relationshipId, Boolean isPrimary) {
        List<Client_Plan_Relationship__c> relationships = [SELECT Id FROM Client_Plan_Relationship__c WHERE Id = :relationshipId];
        if(relationships.isEmpty()){
          return 'Client Plan Relationship cannot be found.';
        }
        List<User> users = [SELECT Id, Name FROM User WHERE Id = :userId];
        if(users.isEmpty()){
          return 'Barclays Contact is required field.';
        }
        Client_Plan_Relationship_Item__c newBarclaysContact = new Client_Plan_Relationship_Item__c();
        newBarclaysContact.Client_Plan_Relationship__c = relationships[0].Id;
        newBarclaysContact.Barclays_Contact_User__c = users[0].Id;
        newBarclaysContact.Strength_of_Relationship__c = relationshipStrength;
        newBarclaysContact.Primary_Contact__c = isPrimary;

        try {
            insert newBarclaysContact;
        } catch (DmlException e) {
            return e.getDmlMessage(0);
        }

        return null;
    }

    /**
    * @Author:          Marta Malinowska
    * @Company:         Deloitte
    * @Description:     edit Client Plan Relationship Item (Barclays contact)
    * @Params:          Id of client plan relationship item, strenght of relationship, primary contact: true or false
    * @Returns:         String - error message if error occured, null otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    @RemoteAction
    public static String editBarclaysContact(Id relationshipItemId, String relationshipStrength, Boolean isPrimary) {
        Client_Plan_Relationship_Item__c barclaysContact = new Client_Plan_Relationship_Item__c();
        barclaysContact.Id = relationshipItemId;
        barclaysContact.Strength_of_Relationship__c = relationshipStrength;
        barclaysContact.Primary_Contact__c = isPrimary;

        try {
            update barclaysContact;
        } catch (DmlException e) {
            return e.getDmlMessage(0);
        }

        return null;
    }

    /**
    * @Author:          Marta Malinowska
    * @Company:         Deloitte
    * @Description:     remove Client Plan Relationship Item (Barclays contact)
    * @Params:          Id of client plan relationship item
    * @Returns:         String - error message if error occured, null otherwise
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    @RemoteAction
    public static String removeBarclaysContact(Id relationshipItemId) {
        try {
            delete [SELECT Id, Name FROM Client_Plan_Relationship_Item__c WHERE Id = :relationshipItemId];
        } catch (DmlException e) {
            return e.getDmlMessage(0);
        }

        return null;
    }

     /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     saves relationship comment
      * @Params:          Id of contact, Id of client plan, comment
      * @Returns:         Boolean - false if error occured, true otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static Boolean saveComment(String contactId, String planId, String comment) {
        List<Client_Plan_Relationship__c> aprs = [
            SELECT Id, Comment__c 
            FROM Client_Plan_Relationship__c 
            WHERE Client_Plan__c = :planId AND Contact__c = :contactId];
            
        if (aprs.isEmpty()) {
            return false;
        }
        
        aprs[0].Comment__c = comment;
        try {
            update aprs;
        } catch (DmlException e) {
            System.debug(e);
            return false;
        }
        return true;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     search for contacts to add to diagram
      * @Params:          search text, boolean indicating whether search on all accounts, ids of contacts in diagram, Id of client plan
      * @Returns:         List<SearchResult>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static List<SearchResult> search(String name, Boolean searchAll, List<Id> existingItems, String accountPlanId) {
        name += '%';
        String soql = 'SELECT Id, Name, Account.Name FROM Contact ' +
            'WHERE (FirstName LIKE :name OR LastName LIKE :name) AND Id NOT IN :existingItems';
            
        if (!searchAll) {
            try {
                Client_Plan__c accountPlan = [SELECT Id, Relationship__c FROM Client_Plan__c WHERE Id = :accountPlanId];
                Id accountId = accountPlan.Relationship__c;
                soql += ' AND AccountId = :accountId';
            } catch (QueryException ex){
                System.debug(ex);
            }
        }
        soql += ' ORDER BY LastName, FirstName LIMIT 15';
        
        List<SearchResult> results = new List<SearchResult>();
        for (Contact contact : Database.query(soql)) {
            results.add(new SearchResult(contact.Id, contact.Name, contact.Account.Name));
        }
        
        if (results.size() == 0) {
            results.add(new SearchResult());
        }
        return results;
    }

    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     search for users to add as Barclays Contact
      * @Params:          search text - user First Name and Last Name
      * @Returns:         List<SearchResult>
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static List<SearchResult> searchBarclaysContactUser(String name) {
        name += '%';
        
        List<SearchResult> results = new List<SearchResult>();
        for (User user : [SELECT Id, Name FROM User WHERE Name LIKE :name ORDER BY Name LIMIT 15]) {
            results.add(new SearchResult(user.Id, user.Name));
        }
        
        if (results.size() == 0) {
            results.add(new SearchResult());
        }
        return results;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     returns contact by id in param
      * @Params:          Id of contact to query
      * @Returns:         SearchResult
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static SearchResult getContactById(String contactId) {
        List<Contact> contacts = [
            SELECT Id, Name, Account.Name 
            FROM Contact
            WHERE Id = :contactId];
        
        if (contacts.isEmpty()) {
            return null;
        } else {
            Contact c = contacts[0];
            return new SearchResult(c.Id, c.Name, c.Account.Name);
        }
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     saves values from map sliders on diagram
      * @Params:          List<ValueRecordDto> dtos - list of record - value pairs
      * @Returns:         Boolean - false if error occured, true otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static Boolean saveMapSliders(List<ValueRecordDto> dtos) {
        if (dtos.isEmpty()) {
            return true;
        }
        
        List<String> ids = new List<String>();
        for (ValueRecordDto dto: dtos) {
            ids.add(dto.record);
        }
        
        List<Client_Plan_Relationship__c> aprs = [
            SELECT Id, Client_Strength__c 
            FROM Client_Plan_Relationship__c 
            WHERE Id IN :ids];
            
        Map<Id, Client_Plan_Relationship__c> aprsMap = new Map<Id, Client_Plan_Relationship__c>(aprs);
        
        for (ValueRecordDto dto: dtos) {
            Client_Plan_Relationship__c apr = aprsMap.get(dto.record);
            
            if (apr != null) {
                apr.Client_Strength__c = dto.value;
            }
        }
        
        try {
            update aprs;
        } catch (DmlException e) {
            System.debug(e);
            return false;
        }
        return true;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     modifies string, returns empty string when null of empty, no modification otherwise
      * @Params:          String - string to modify
      * @Returns:         String - modified string
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private static String getString(String s){
        if(String.isBlank(s)) {
            return '';
        } else {
            return s;
        }
    }

    @testVisible
    private class SearchResult {
        public String value;
        public String label;

        public SearchResult(Id id, String name) {
            this.value = id;
            this.label = name;
        }

        public SearchResult(Id id, String name, String organisation) {
            this.value = id;
            if (organisation != null) {
                this.label = name + ' - ' + organisation;
            } else {
                this.label = name;
            }
        }
        
        public SearchResult() {
            this.value = 'value';
            this.label = 'label';
        }
    }

    private class ChartItem {
        String id;
        String aprId;
        String parent;
        String title;
        String jobRole;
        String jobTitle;
        String clientStrength;
        String comment;
        List<BarclaysContact> barclaysContacts;
    }

    private class BarclaysContact {
        String id;
        String name;
        String clientStrength;
        Boolean primary;
        Boolean seniorSponsor;
    }

    @testVisible
    private class ValueRecordDto {
        public String value;
        public String record;
    }
 
}