/**
* Date   : 2016-12-15
* Author : RN - CloudSmiths
* Desc   : Controller that links complaint type cases to existing cases
* 
**/
public class CM_Quick_Action_Link_Case_Cont {
    
	public list<Case> relatedCases{get;set;}
    public list<CaseWrapper> lstCaseWrapper {get;set;}
    public Case c {get;set;}
    public String caseItem {get;set;}
    public String searchSubject{get;set;}
    public String searchCaseNumber{get;set;}
    
    private Case linkCase = new Case();
    
    public CM_Quick_Action_Link_Case_Cont(ApexPages.StandardController controller){
        
       this.linkCase = (Case)controller.getRecord();
       this.linkCase = [Select Id, Contact.Name, CaseNumber, Email_From_Address__c,Email_Sender_Name__c,Web_Email__c,Web_Name__c From Case Where Id = :this.linkCase.Id];
        
       relatedCases = [Select Id, Subject, Status, CaseNumber,Owner.Name,Service_Type__c, Department__c,
                       Service_Category__c, Service_Sub_Category__c, Channel__c,
                       Description, Contact.Name, Contact.Email, Web_Email__c,
                       Web_Name__c, Email_From_Address__c, IsClosed, CreatedDate, Account.Name 
                       From Case 
                       Where (Email_From_Address__c = :linkCase.Email_From_Address__c OR 
                              Contact.Name = :linkCase.Contact.Name OR 
                              Web_Email__c = :linkCase.Web_Email__c OR 
                              Web_Name__c = :linkCase.Web_Name__c) AND 
                       RecordType.DeveloperName = 'Complaint' AND CaseNumber != :linkCase.CaseNumber 
                       Order by CreatedDate Desc Limit 6];
        
        lstCaseWrapper = new list<CaseWrapper>();
        
        for(Case c :relatedCases){
            
            Case aCase = c;
            
            CaseWrapper wrapperCase = new CaseWrapper(aCase,false);
            
            lstCaseWrapper.add(wrapperCase);     
        }
        
    }
    
    public PageReference searchCases(){
        
        String  sql = 'Select Id, Subject, Status, CaseNumber,Owner.Name,Service_Type__c, Department__c,' + 
                      'Service_Category__c, Service_Sub_Category__c, Channel__c,' +
                      'Description, Contact.Name, Contact.Email, Web_Email__c,' + 
                      'Web_Name__c, Email_From_Address__c, IsClosed, CreatedDate, Account.Name ' + 
            		  'From Case Where RecordType.DeveloperName = \'Complaint\'';
        			  
        if(String.isNotBlank(searchCaseNumber) && String.isNotBlank(searchSubject)){
            sql+= ' AND (CaseNumber like \'' + searchCaseNumber + '%\' AND Subject like \'' + searchSubject + '%\')';
        }else{
			if(String.isNotBlank(searchCaseNumber)){
            	sql+= ' AND CaseNumber like \'' + searchCaseNumber + '%\'';
            }else{
                sql+= ' AND Subject like \'' + searchSubject + '%\'';
            }
        }

        sql+= ' Order by CreatedDate Desc Limit 6';
        
        system.debug('SQL:' + sql);
        
        relatedCases = Database.query(sql);
        
        lstCaseWrapper = new list<CaseWrapper>();
        
        for(Case c :relatedCases){
            
            Case aCase = c;
            
            CaseWrapper wrapperCase = new CaseWrapper(aCase,false);
            
            lstCaseWrapper.add(wrapperCase);      
        }
        
    	return null;
    }
    
    public PageReference linkCaseToCase(){

            //Loop through all the selected related Cases
            for(CaseWrapper cw :lstCaseWrapper){
                if(cw.IsChecked){
                   this.linkCase.ParentId = cw.wCase.Id;
                }
            }

        return null;
    }
    
	 //NESTED CLASSES
    //Cases wrapper class to keep track of selected related Case
    public class CaseWrapper{
        
        public Case wCase {get;set;}
        public Boolean IsChecked {get;set;}
        
        public CaseWrapper(Case rec, Boolean chk){
            this.wCase = rec;
            this.IsChecked = chk;
        }
    }
}