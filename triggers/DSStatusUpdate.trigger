trigger DSStatusUpdate on dsfs__DocuSign_Status__c (after insert, after update) {
    System.debug('DOCUSIGN STATUS TRIGGER : '+ Trigger.newMap.size());
   		List<dsfs__DocuSign_Status__c> docusignStatuses = [SELECT Id, Agreement__c, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c WHERE Id IN :Trigger.newMap.keySet()]; 
    
    	List<Attachment> attachmentDelete =  new List<Attachment>();
        List<BoxDocument__c> boxDocuments =  new List<BoxDocument__c>();
    
    	for(dsfs__DocuSign_Status__c docusignStatus : docusignStatuses) {
            if(docusignStatus.dsfs__Envelope_Status__c == 'Sent') {
                // Delete the attachment from Agreement
                attachmentDelete = [Select Id, Name, ParentID FROM Attachment WHERE ParentID =: docusignStatus.Agreement__c];
                
                for(Attachment att : attachmentDelete) {
                    String AttName = '';
                    String[] nameSplit = (att.Name).split('\\.');
                    boolean hasExtension = nameSplit.size() > 1;
                    if(hasExtension && nameSplit[1] == 'pdf'){
                        AttName = att.Name;
                    } else {
                        AttName = nameSplit[0] + '.pdf';
                    }
                    // Create a insert the box document object
                    BoxDocument__c boxDocument = new BoxDocument__c(
                        Name = 'Signed_'+AttName,
                        Agreement__c = docusignStatus.Agreement__c,
                        PII__c = 'Yes',
                        Owner_Type__c = 'Agreement__c',
                        Status__c = 'Final',
                        Type__c = 'Agreement'
                    );
                   boxDocuments.add(boxDocument);
                }
            } 
            
        }
    
    	if(boxDocuments.size() > 0) {
            insert boxDocuments;
        }
        
        if(attachmentDelete.size() > 0) {
            Delete attachmentDelete;
        }
}