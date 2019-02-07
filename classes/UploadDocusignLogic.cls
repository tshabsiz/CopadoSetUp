public class UploadDocusignLogic {
    
    public static void UploadDocumentToBox(List<Attachment> attachments) {
        
        List<Id> ParentIds = new List<Id>();
        List<String> AttachmentNames = new List<String>();
        List<Id> AgreementIds = new List<Id>();
        Map<String, BoxDocument__c> boxDocumentMap = new Map<String, BoxDocument__c>();
        
        
        for(Attachment a : attachments) {
            ParentIds.add(a.ParentId);
            AttachmentNames.add(a.Name);
        }
        
        List<dsfs__DocuSign_Status__c> docusignStatuses = [SELECT Id, dsfs__Envelope_Status__c, dsfs__Sender_Email__c, Agreement__c FROM dsfs__DocuSign_Status__c WHERE Id =:ParentIds];
        
        for(dsfs__DocuSign_Status__c ds : docusignStatuses) {
            AgreementIds.add(ds.Agreement__c);
        }
        
        // Only execute if attachment has Docusign Status as Parent
        if(AgreementIds.size() > 0) {
            
            List<BoxDocument__c> bxDocuments = [SELECT Id, Name, Box_Unique_Id__c, Agreement__c, Type__c, Status__c, Owner_Type__c,PII__c 
                                                FROM BoxDocument__c WHERE Agreement__c IN:AgreementIds];
            for(BoxDocument__c bx : bxDocuments) {
                if(!boxDocumentMap.containsKey(bx.Agreement__c+':'+bx.Name)){
                    boxDocumentMap.put(bx.Agreement__c+':'+bx.Name, bx);
                }
            }
            
            
            for(Attachment att : attachments) {
                
                for(dsfs__DocuSign_Status__c dStatus : docusignStatuses) {
                    if(dStatus.dsfs__Envelope_Status__c == 'Completed') {
                        // Upload the document onto box
                        String attachmentName = 'Signed_' + att.Name; 
                        
                        if(boxDocumentMap.containsKey(dStatus.Agreement__c+':'+attachmentName)) {
                            // Call Upload method
                            System.debug('User emaills : ' + dStatus.dsfs__Sender_Email__c);
                            BxdDocumentService.uploadHotDocsToBoxFuture(boxDocumentMap.get(dStatus.Agreement__c+':'+attachmentName).Id, att.Body, att.Id, dStatus.dsfs__Sender_Email__c);
                        }                
                    }
                }
            }
        }
    }
}