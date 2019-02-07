/**
* Date   : 27-07-2016
* Author : RN - CloudSmiths
* Desc   : Update and redirect users that create manual cases inside the console
* ----------------------------------------------------------
* 20170309 - Rudolf Niehaus - CloudSmiths
* Add navigation for DOS cases
* ----------------------------------------------------------
*20170810 - Mabhedle Tonga 
* Added additional methods to test on different case record types
*-----------------------------------------------------------
**/
public class CSC_Case_Redirect_Controller {
    
    public Case theCase{get;set;}
    private String manualCaseRecTypeId = '';
    private String complaintCaseRecTypeId = '';
    private String dosCaseRecTypeId = '';
    private String newCaseTypeId = '';
    private String MNPIComplaintTypeId = '';
    
    public CSC_Case_Redirect_Controller(ApexPages.StandardController controller){
        
        this.theCase = (Case)controller.getRecord();
        
        manualCaseRecTypeId = [Select Id From RecordType Where DeveloperName = 'CSC_Manual_Cases'].Id;
        complaintCaseRecTypeId = [Select Id From RecordType Where DeveloperName = 'Complaint'].Id;
        dosCaseRecTypeId = [Select Id From RecordType Where DeveloperName = 'Digital_Ops_Cases'].Id;
        newCaseTypeId = [Select Id From RecordType Where Id = :theCase.RecordTypeId].Id;
        MNPIComplaintTypeId = [Select Id From RecordType Where DeveloperName = 'MNPI_Complaint'].Id;
    } 
    
    public PageReference redirectUser(){
        
        PageReference p;
        
        String accountParameter='';
        if(!String.isBlank(theCase.AccountId)){
            accountParameter = '&cas4_lkid='+theCase.AccountId;
        }
            
            
        if(newCaseTypeId == manualCaseRecTypeId){
            p = new  PageReference('/apex/CSC_Quick_Action_New_Manual_Case?action=edit&RecordType=' + manualCaseRecTypeId);
        }else if(newCaseTypeId == complaintCaseRecTypeId){
        	p = new  PageReference('/apex/CM_New_Manual_Case?action=edit&RecordType=' + complaintCaseRecTypeId+accountParameter);
        }else if(newCaseTypeId == dosCaseRecTypeId){
            p = new  PageReference('/apex/DOS_New_Manual_Case?action=edit&RecordType=' + dosCaseRecTypeId+accountParameter);
        }else if(newCaseTypeId == MNPIComplaintTypeId){
            p = new  PageReference('/500/e?retURL=%2F500%2Fo&RecordType=' + newCaseTypeId + '&ent=Case&nooverride=1');
        }else{
        	p = new  PageReference('/500/e?retURL=%2F500%2Fo&RecordType=' + newCaseTypeId + '&ent=Case&nooverride=1'+accountParameter); 
        }

         p.setRedirect(true);
         return p;
    }

}