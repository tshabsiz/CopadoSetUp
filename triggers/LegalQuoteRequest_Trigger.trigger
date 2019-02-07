trigger LegalQuoteRequest_Trigger on Legal_Quote_Request__c (after update, before insert, before update) 
{
    //BEFORE context.
    if(Trigger.isBefore)
    {
        //UPDATE context.
        if(Trigger.isUpdate || Trigger.isInsert) 
        {
            //Holds the ID's of assocaited matters.
            Set<Id> matterIds = new Set<Id>();
            
            //Loop through updated / inserted records.
            for(Legal_Quote_Request__c legalQuoteRequest : Trigger.new)
            {
                //Add matter id to set.
                matterIds.add(legalQuoteRequest.Matter__c); 
                
                if(Trigger.isUpdate)
                {
                    //Previous record and its values.
                    Legal_Quote_Request__c oldLegalQuoteRequest = Trigger.oldMap.get(legalQuoteRequest.Id);
                    
                    //Detemine the litigiation score.
                    if(legalQuoteRequest.Status__c == 'Draft' && (legalQuoteRequest.Matter_Difficulty__c <> oldLegalQuoteRequest.Matter_Difficulty__c || legalQuoteRequest.Matter_Value__c <> oldLegalQuoteRequest.Matter_Value__c || legalQuoteRequest.Litigation_Risk_Score__c == null))
                    {
                        legalQuoteRequest.Litigation_Risk_Score__c = LegalQuoteRequest_Helper.calculateRiskScore(legalQuoteRequest.Matter_Value__c, legalQuoteRequest.Matter_Difficulty__c);
                    }
                }
                
                if(Trigger.isInsert)
                {
                    legalQuoteRequest.Status__c = 'Draft';

                    //Detemine the litigiation score.
                    legalQuoteRequest.Litigation_Risk_Score__c = LegalQuoteRequest_Helper.calculateRiskScore(legalQuoteRequest.Matter_Value__c, legalQuoteRequest.Matter_Difficulty__c);
                }
            }
            
            //Fetch all matter fields.
            Map<Id, advpm__Matter__c> mattersMap = new Map<Id, advpm__Matter__c>([
                SELECT
                    Id,
                    OwnerId
                FROM advpm__Matter__c
                WHERE 
                    Id IN :matterIds
            ]);
            
            //Anything to process
            if(!mattersMap.isEmpty() || mattersMap != null)
            {
                //Loop through updated / inserted records.
                for(Legal_Quote_Request__c legalQuoteRequest : Trigger.new)
                {
                    //Does the current record owner match the matter owner
                    if(legalQuoteRequest.OwnerId <> mattersMap.get(legalQuoteRequest.Matter__c).OwnerId)
                    {
                        legalQuoteRequest.OwnerId           = mattersMap.get(legalQuoteRequest.Matter__c).OwnerId;
                        
                        //Get approver user.
                        User approvalUser = LegalQuoteRequest_Helper.determineApprovalUser(legalQuoteRequest.OwnerId);
                        
                        //Set quote approver, if not blank.
                        if(approvalUser != null)
                        {
                            legalQuoteRequest.Quote_Approver__c = approvalUser.Id;
                        }
                    }
                    
                    //The ownerid match, however the "Quote Approver" is blank.
                    if((legalQuoteRequest.OwnerId == mattersMap.get(legalQuoteRequest.Matter__c).OwnerId))// && String.isBlank(legalQuoteRequest.Quote_Approver__c))
                    {
                        //Get approver user.
                        User approvalUser = LegalQuoteRequest_Helper.determineApprovalUser(legalQuoteRequest.OwnerId);
                        system.debug('##ASSIGNING Approver###');
                        //Set quote approver.
                        if(approvalUser != null)
                        {
                            legalQuoteRequest.Quote_Approver__c = approvalUser.Id;
                        }
                    }
                    
                    
                }
            }
        }
        //UPDATE context end.
    }
    //BEFORE context end.
    
    //AFTER context.
    if(Trigger.isAfter)
    {
        //UPDATE context.
        if(Trigger.isUpdate)
        {   
            //Empty list of objects.
            LegalQuoteRequest_handler.updatequoteStatus(Trigger.new,Trigger.old);
            
            
            //Loop through updated records.
            //Commented out by Sean P 6/27 - Code replaced in new VF Page Handler
            /*
            for(Legal_Quote_Request__c legalQuoteRequest : Trigger.new)
            {
                //Previous record and its values.
                Legal_Quote_Request__c oldLegalQuoteRequest = Trigger.oldMap.get(legalQuoteRequest.Id);
                
                //If the status is "Requested" and was not previously this.
                if(legalQuoteRequest.Status__c == 'Requested' && oldLegalQuoteRequest.Status__C == 'Draft')
                {
                    //Make sure the contact has not bounced and has a valid email address.
                    //Law Firm 1
                    if(!String.isBlank(legalQuoteRequest.Contact_1__r.Email) && !String.isBlank(legalQuoteRequest.Contact_1__r.EmailBouncedReason))
                    {
                        legalQuoteRequest.addError('The contact on Law Firm 1 has an invalid email address.');
                    }
                    //Law Firm 2
                    else if(!String.isBlank(legalQuoteRequest.Contact_2__r.Email) && !String.isBlank(legalQuoteRequest.Contact_2__r.EmailBouncedReason))
                    {
                        legalQuoteRequest.addError('The contact on Law Firm 2 has an invalid email address.');
                    }
                    //Law Firm 3
                    else if(!String.isBlank(legalQuoteRequest.Contact_3__r.Email) && !String.isBlank(legalQuoteRequest.Contact_3__r.EmailBouncedReason))
                    {
                        legalQuoteRequest.addError('The contact on Law Firm 3 has an invalid email address.');
                    }
                    else
                    {
                        //Build "Legal Quotes" for insert.
                        //Law Firm 1
                        if(!String.isBlank(legalQuoteRequest.Law_Firm_1__c) || legalQuoteRequest.Law_Firm_1__c != null) 
                        {
                            //Blank legal quote object.
                            Legal_Quote__c legalQuote           = new Legal_Quote__c();
                            legalQuote.Legal_Quote_Request__c   = legalQuoteRequest.Id;
                            legalQuote.Law_Firm__c              = legalQuoteRequest.Law_Firm_1__c;
                            legalQuote.Contact__c               = legalQuoteRequest.Contact_1__c;
                            legalQuote.External_Counsel_Name__c = legalQuoteRequest.External_Counsel_Name_1__c;
                            legalQuote.Status__c                = 'Requested';
                            legalQuote.Quote_Approver__c        = legalQuoteRequest.Quote_Approver__c;
                            
                            //Add to insert list.
                            legalQuotesToInsert.add(legalQuote);
                        }
                        
                        //Law Firm 2
                        if(!String.isBlank(legalQuoteRequest.Law_Firm_2__c) || legalQuoteRequest.Law_Firm_2__c != null)
                        {
                            //Blank legal quote object.
                            Legal_Quote__c legalQuote           = new Legal_Quote__c();
                            legalQuote.Legal_Quote_Request__c   = legalQuoteRequest.Id;
                            legalQuote.Law_Firm__c              = legalQuoteRequest.Law_Firm_2__c;
                            legalQuote.Contact__c               = legalQuoteRequest.Contact_2__c;
                            legalQuote.External_Counsel_Name__c = legalQuoteRequest.External_Counsel_Name_2__c;
                            legalQuote.Status__c                = 'Requested';
                            legalQuote.Quote_Approver__c        = legalQuoteRequest.Quote_Approver__c;
                            
                            //Add to insert list.
                            legalQuotesToInsert.add(legalQuote);
                        }
                        
                        //Law Firm 3
                        if(!String.isBlank(legalQuoteRequest.Law_Firm_3__c) || legalQuoteRequest.Law_Firm_3__c != null)
                        {
                            //Blank legal quote object.
                            Legal_Quote__c legalQuote           = new Legal_Quote__c();
                            legalQuote.Legal_Quote_Request__c   = legalQuoteRequest.Id;
                            legalQuote.Law_Firm__c              = legalQuoteRequest.Law_Firm_3__c;
                            legalQuote.Contact__c               = legalQuoteRequest.Contact_3__c;
                            legalQuote.External_Counsel_Name__c = legalQuoteRequest.External_Counsel_Name_3__c;
                            legalQuote.Status__c                = 'Requested';
                            legalQuote.Quote_Approver__c        = legalQuoteRequest.Quote_Approver__c;
                            
                            //Add to insert list.
                            legalQuotesToInsert.add(legalQuote);
                        }
                    }
                    //Else end.
                }
                //If end.
            }
            //Loop end.
            
            //Insert records.
            if(!legalQuotesToInsert.isEmpty() || legalQuotesToInsert != null)
            {
                //Insert records.
                insert(legalQuotesToInsert);
            }
*/
            
        }
    }
}