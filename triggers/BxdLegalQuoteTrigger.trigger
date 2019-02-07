trigger BxdLegalQuoteTrigger on Legal_Quote__c (after insert, after update) {
    //AFTER context
    if(Trigger.isAfter)
    {
        //INSERT context
        if(Trigger.isInsert)
        {
            if(LegalQuoteRequest_handler.LegalQuoteRequestVF == Null){              
                LegalQuoteRequest_handler.createBoxFolderTrigger(Trigger.new);
            } 
        }
        //INSERT context end.
        //UPDATE context
        if(Trigger.isUpdate)
        {
            if(!System.isFuture()){
                for (Legal_Quote__c quote : Trigger.new) {
                    Id legalQuoteRequestId = quote.Legal_Quote_Request__c;
                    List<Legal_Quote_Request__c> legalQuoteRequests = [Select Id, Box_Supplier_Link__c From Legal_Quote_Request__c Where id =: legalQuoteRequestId];
                    if(quote.Request_for_Service__c){
                        //Create Invoice Folder
                        System.debug('***CREATE INVOICE FOLDER? ' + String.isBlank(quote.Invoice_Received_Box_Link__c));
                        if(!legalQuoteRequests.isEmpty() && String.isBlank(quote.Invoice_Received_Box_Link__c)){
                            BxdInvoiceService.createInvoiceBoxFolder(legalQuoteRequests[0].Id, quote.Id);
                        }
                        
                        //Create Supplier Folder
                        System.debug('***CREATE SUPPLIER FOLDER? ' + String.isBlank(legalQuoteRequests[0].Box_Supplier_Link__c));
                        if(!legalQuoteRequests.isEmpty() && String.isBlank(legalQuoteRequests[0].Box_Supplier_Link__c)){
                            BxdInvoiceService.createSupplierBoxFolder(legalQuoteRequests[0].Id, quote.Id);
                        }  
                    }               
                }
            }  
        }
        //UPDATE context end.
    }        
    //AFTER Context end.
}