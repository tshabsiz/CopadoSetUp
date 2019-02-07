trigger UploadDocusignDocument on Attachment (after insert) {
    
    for(Attachment att : trigger.New) {
        
        List<dsfs__DocuSign_Status__c> docusignStatuses = [SELECT Id,dsfs__Envelope_Status__c,Agreement__c FROM dsfs__DocuSign_Status__c WHERE Id =: att.ParentId];
        
        if(docusignStatuses.size() > 0) {
            
            if(docusignStatuses.get(0).dsfs__Envelope_Status__c == 'Completed') {
                // Upload the document onto box
                String attachmentName = 'Signed_' + att.Name; 
                List<BoxDocument__c> bxDocuments = [SELECT Id, Name, Box_Unique_Id__c, Agreement__c, Type__c, Status__c, Owner_Type__c,
                               PII__c FROM BoxDocument__c WHERE Agreement__c =: docusignStatuses.get(0).Agreement__c AND Name =:attachmentName LIMIT 1];
                
                if(bxDocuments.size() > 0) {
                    // Call Upload method
                    BxdDocumentService.uploadHotDocsToBoxFuture(bxDocuments.get(0).Id, att.Body, att.Id);
                }                
            }
        }
	}
}