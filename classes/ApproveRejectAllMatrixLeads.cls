/**
* @Author       Masie Maseli
* Company:      Deloitte
* @Description: Controller for VF ApproveRejecectAllMatrixLeads
* @Date:        03/2016
* @ConstructorParam:    stdController - Standard Controller for "Matrix_Lead__c" object
* @TestClass:   ZZTEST_TestApproveRejectAllMatrixLeads
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/


public with sharing class ApproveRejectAllMatrixLeads
{

    public String comments {get;set;} 
    
    
    //Instatiate the controller   
    public ApproveRejectAllMatrixLeads(ApexPages.StandardController controller) {

    }
 
 // The method for the mass Approval- create a list of all the pending approvals and process them
    public void processApprovalAction(String approvalAction) {
        List<Approval.ProcessWorkitemRequest> approvalsToProcess = new List<Approval.ProcessWorkitemRequest>();
        for(PendingAppRecs pendingApprovalRecord : pendingApprovals) {
            if(pendingApprovalRecord.selected == true) {
                Approval.ProcessWorkitemRequest approvalRequest = new Approval.ProcessWorkitemRequest();
                approvalRequest.setComments(Comments);
                approvalRequest.setAction(approvalAction);
                approvalRequest.setWorkitemId(pendingApprovalRecord.workItemId);    
                if (approvalAction == 'Approve') {
                    approvalRequest.setNextApproverIds(new List<Id> {pendingApprovalRecord.nextApprover});  
                }
                approvalsToProcess.add(approvalRequest);
            }
        }
        List<Approval.ProcessResult> approvalProcessResults = Approval.process(approvalsToProcess);
    }   

    public pagereference approveAll()
    {
        processApprovalAction('Approve');
        Pagereference pg = new pagereference('/' + ApexPages.currentPage().getParameters().get('id') );
        pg.setredirect(true);
        return pg;
    }

    public pagereference rejectAll()
    {
        processApprovalAction('Reject');
        Pagereference pg = new pagereference('/' + ApexPages.currentPage().getParameters().get('id') );
        pg.setredirect(true);
        return pg;
    }

    public pagereference cancel()
    {
       Pagereference pg = new pagereference('/' + ApexPages.currentPage().getParameters().get('id') );
        pg.setredirect(true);
        return pg;
    }

// Create a list of pending approvals for the logged in user
    public List<PendingAppRecs> pendingApprovals {
        get { if (pendingApprovals == null) {
            pendingApprovals = getPendingApprovalsForUser(UserInfo.getUserId());
            }
            return pendingApprovals;
        }
        set;
    }

    private List<PendingAppRecs> getPendingApprovalsForUser(String userId) {
        List<PendingAppRecs> pendingApprovalsForUser = new List<PendingAppRecs>();
        List<Id> matrixLeadIds = new List<Id>();
        for ( ProcessInstanceWorkitem pendingApprovalRecord : [ SELECT  p.ProcessInstance.Id, 
                                                                        p.ProcessInstance.Status, 
                                                                        p.ProcessInstance.TargetObject.Id, 
                                                                        p.ProcessInstance.TargetObject.Name, 
                                                                        p.ProcessInstance.TargetObject.Type, 
                                                                        p.ProcessInstance.CreatedDate,
                                                                        p.Actor.id,
                                                                        p.Id 
                                                                FROM ProcessInstanceWorkitem p 
                                                                WHERE p.ProcessInstance.Status = 'Pending' 
                                                                AND p.ProcessInstance.TargetObject.Type = 'Matrix_Lead__c'
                                                                AND p.Actor.id = :userId] ) {
            pendingApprovalsForUser.add(new PendingAppRecs(pendingApprovalRecord));
            matrixLeadIds.add(pendingApprovalRecord.ProcessInstance.TargetObject.Id);
        }
        Map<Id,Matrix_Lead__c> matrixLeadMap  = new Map<Id,Matrix_Lead__c>([SELECT Company_Name__c, LastModifiedBy.Name FROM Matrix_Lead__c where id IN  :matrixLeadIds ]);
        for (PendingAppRecs pendingApprovalRecord : pendingApprovalsForUser) {
            Matrix_Lead__c matrixLead = matrixLeadMap.get(pendingApprovalRecord.leadId);
            pendingApprovalRecord.leadName = matrixLead.Company_Name__c;
            pendingApprovalRecord.submittedBy = matrixLead.LastModifiedBy.Name;
        }
        return pendingApprovalsForUser;
    }
    
    public class PendingAppRecs
    {
        public String leadNumber {get;set;} 
        public String leadName {get;set;} 
        public Datetime submittedDate {get;set;} 
        public String approvalStatus {get;set;} 
        public String submittedBy {get;set;} 
        public Id leadId {get;set;}
        public Id nextApprover {get;set;}
        public Id workItemId {get;set;}

        public Boolean selected {get; set;}
        public PendingAppRecs(ProcessInstanceWorkItem pwim) {
            selected = false;
            leadNumber = pwim.ProcessInstance.TargetObject.Name;
            leadId = pwim.ProcessInstance.TargetObject.Id;
            submittedDate = pwim.ProcessInstance.CreatedDate;
            approvalStatus = pwim.ProcessInstance.Status;
            nextApprover = pwim.Actor.Id;
            workItemId = pwim.Id;
        }
    }
}