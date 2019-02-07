/**
* Date   : 31-05-2016
* Author : RN - CloudSmiths
* Desc   : Controller transfere an email type case to a new queue and update the initial values form the service mapping table
		   based on te new queue name
**/
public class CSC_Quick_Action_Transfer_Case_Cont {
    
    private Case consoleCase;
    public Case actionCase {get;set;}
    public list<Service_Mapping__c> sm {get;set;}
    
    public CSC_Quick_Action_Transfer_Case_Cont(ApexPages.StandardController controller){
       
       consoleCase = (Case)controller.getRecord();
        
       actionCase = new Case(); 
       actionCase = [Select Id, Team__c, Department__c, Queue__c From Case Where Id = :consoleCase.Id];
       //sm = [Select Queue__c From Service_Mapping__c Order By Effective_Date__c DESC limit 1];
	
    }
    
    public PageReference updateCase(){
        sm = [Select Id, Queue_Name__c, Queue__c, Team__c, Department__c, Business_Hours__c, Full_Department__c  
              From Service_Mapping__c  
              Where Queue__c = :actionCase.Queue__c Order By Effective_Date__c DESC limit 1];
        
		String queueId = [Select Id From Group Where DeveloperName = :sm[0].Queue_Name__c AND Type = 'Queue'].Id;
        
        if(String.isNotBlank(queueId)){
            //reset values based on new queue selection
            actionCase.OwnerId = queueId;
            actionCase.Full_Department__c = sm[0].Full_Department__c;
            actionCase.Service_Mapping_Entry__c = sm[0].Id;
            actionCase.Queue__c = actionCase.Queue__c;
        	actionCase.Team__c = sm[0].Team__c;
            actionCase.Department__c = sm[0].Department__c;
            actionCase.Business_Hours__c = sm[0].Business_Hours__c;
            actionCase.Email_Action__c = 'Transferred';
            
            try{
             	update actionCase;
            }catch(DMLException ex){
                System.debug('Error when a user transfer an email type case');
                System.debug('CSC_Quick_Action_Transfer_Case_Cont -> updateCase() -> update actionCase');
                System.debug('Additional Info:' + ex.getMessage());
            }
        }

    	return null;
    }
}