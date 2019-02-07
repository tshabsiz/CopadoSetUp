@isTest

public class ZZTEST_ApproveRejectAllMatrixLeads {
    void submitAndProcessApprovalRequest() {
        // Insert an account
        Matrix_Lead__c mat = new Matrix_Lead__C (Company_Name__c='Testing Company', Lead_Status__c = 'Open');
        insert mat;
           
        User user1 = [SELECT Id FROM User WHERE Alias='StandardUser'];
            
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(mat.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(user1.Id); 
        
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('PTO_Request_Process');
        req1.setSkipEntryCriteria(true);
        
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        
        // Verify the result
        System.assert(result.isSuccess());
        
        System.assertEquals(
            'Pending', result.getInstanceStatus(), 
            'Instance Status'+result.getInstanceStatus());
        
        // Approve the submitted request
        // First, get the ID of the newly created item
        List<Id> newWorkItemIds = result.getNewWorkitemIds();
        
        // Instantiate the new ProcessWorkitemRequest object and populate it
        Approval.ProcessWorkitemRequest req2 = 
            new Approval.ProcessWorkitemRequest();
        req2.setComments('Approving request.');
        req2.setAction('Approve');
        req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        
        // Use the ID from the newly created item to specify the item to be worked
        req2.setWorkitemId(newWorkItemIds.get(0));
        
        // Submit the request for approval
        Approval.ProcessResult result2 =  Approval.process(req2);
        
        // Verify the results
        System.assert(result2.isSuccess(), 'Result Status:'+result2.isSuccess());
        
        System.assertEquals(
            'Approved', result2.getInstanceStatus(), 
            'Instance Status'+result2.getInstanceStatus());
        
            ApexPages.currentPage().getParameters().put('id',mat.id);
            ApexPages.StandardController sc = new ApexPages.standardController(mat);
            ApproveRejectAllMatrixLeads rejectApproveAll = new ApproveRejectAllMatrixLeads(sc);
            rejectApproveAll.approveAll();
            rejectApproveAll.cancel();
            rejectApproveAll.rejectAll(); 
            
            
    }
}