/**
* Date   : 2017-02-07
* Author : RN - CloudSmiths
* Desc   : Extention for the external complaints page used on sites
* -------------------------------------------------------------------
* 2017-03-23 - RN - CoudSmiths - Add header and footer info to page
* 2017-03-23 - RN - CoudSmiths - Add email validation javascript
**/

public Without Sharing class CM_External_Page_Ext {

    public boolean caseCreated {get;set;}
    public Case theCase{get;set;}
    public String relId{get;set;}
    public String header{get;set;}
    public String subscript{get;set;}
    public String footer{get;set;}
    
    public CM_External_Page_Ext(ApexPages.StandardController controller){
        caseCreated = false;
        theCase = (Case)controller.getRecord();
        
        list<RecordType> compType = [Select Id From RecordType Where DeveloperName = 'Complaint'];
        
        if(compType.size()>0){
             theCase.RecordTypeId = compType[0].Id;
        }
        
		theCase.OwnerId = userInfo.getUserId();
        theCase.Queue__c = 'Complaints Client';
        
        //get custome settings
        list<Complaints_Settings__c> cs = [Select Sites_Page_Header__c, Sites_Page_Header_Subscript__c, Sites_Page_Footer__c 
                                        From Complaints_Settings__c  
                                        Where Name = 'Sites Page'];
        if(cs.size() > 0){
        	header = cs[0].Sites_Page_Header__c;
            subscript = cs[0].Sites_Page_Header_Subscript__c;
            footer = cs[0].Sites_Page_Footer__c;
        }else{
        	header = '';
            subscript = '';
            footer = '';
        }
    }
    public String myAccountId{get;set;}
    public Pagereference submitCase(){
        
        String newCaseId = '';
        
        String accid = ApexPages.currentPage().getParameters().get('accountId');
      
        try{
            theCase.AccountId = accid;
            list<Case> insertList = new list<Case>();
            insertList.add(theCase);
            set<Id> newIds = new set<Id>();
           
            Database.SaveResult[] srList = Database.insert(insertList, false);

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