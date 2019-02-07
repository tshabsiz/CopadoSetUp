/**
* Date   : 2018-11-13
* Author : Nakedi Mashapa - ABSA
* Desc   : Extention for the external Procurement used on sites
* -------------------------------------------------------------------
* 2017-03-23 - Nakedi Mashapa - Add header and footer info to page
* 2017-03-23 - Nakedi Mashapa - Add email validation javascript
**/

public Without Sharing class GP_External_Page_Ext {

    public boolean caseCreated {get;set;}
    public Case theCase{get;set;}
    public String relId{get;set;}
    public String header{get;set;}
    public String subscript{get;set;}
    public String footer{get;set;}
    
    public GP_External_Page_Ext(ApexPages.StandardController controller){
        caseCreated = false;
        theCase = (Case)controller.getRecord();
        
        list<RecordType> compType = [Select Id From RecordType Where DeveloperName = 'CSC_Default_Support_Cases'];
      id test = [Select id from account where Name = 'Test' limit 1 ].id;
        
        if(compType.size()>0){
             theCase.RecordTypeId = compType[0].Id;
        }
        
		theCase.OwnerId = '00G1q000000Yy4D';
        theCase.Queue__c = 'Group Procurement';
        theCase.Team__c = 'Procurement';
        theCase.Department__c ='Group Procurement';
        theCase.Team_Manager__c = 'Govindsamy Rowan';
        theCase.Business_Hours__c = 'Monday to Friday 08:00 - 16:30';
        theCase.Service_Type__c = 'Absa Wealth Batch';
        theCase.Service_Sub_Category__c = 'Administration';
        theCase.Service_Category__c = 'Service Request';
        theCase.Channel__c = 'Not Applicable';
        theCase.Number_of_Requests__c = 1;
        theCase.Subject = 'Procurement';
        theCase.Full_Department__c = 'Cash Send';
        
        //get custome settings
        list<Procurement_Settings__c> cs = [Select Site_Page_Header__c, Sites_Page_Header_Subscript__c, Site_Page_Footer__c 
                                        From Procurement_Settings__c  
                                        Where Name = 'Sites Page'];
        if(cs.size() > 0){
        	header = cs[0].Site_Page_Header__c;
            subscript = cs[0].Sites_Page_Header_Subscript__c;
            footer = cs[0].Site_Page_Footer__c;
        }else{
        	header = '';
            subscript = '';
            footer = '';
        }
    }
   // public String myAccountId{get;set;}
    public Pagereference submitCase(){
        
        String newCaseId = '';
        
       //String accid = ApexPages.currentPage().getParameters().get('accountId');
      
        try{
            //theCase.AccountId = accid;
            list<Case> insertList = new list<Case>();
            insertList.add(theCase);
            set<Id> newIds = new set<Id>();
           
            Database.SaveResult[] srList = Database.insert(insertList, false);
              system.debug('srList'+ srList[0].id);
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    newIds.add(sr.getId());
                }else {                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Case fields that affected this error: ' + err.getFields());
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,err.getMessage()));
                    }
                }
            }
            
            list<Case> newCase = [Select Id, CaseNumber From Case Where Id IN :newIds];
            if(newCase.size() > 0){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Succesful'));
            	ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Your Case Number is : ' + newCase[0].CaseNumber));
            }
        }catch(DMLException e){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage()));
        }
        
        caseCreated = true;
    	
        return apexPages.currentPage();  
    }
    
}