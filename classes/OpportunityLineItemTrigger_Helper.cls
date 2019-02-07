/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Helper class for Oportunity Line Item Trigger
* @Date:        8/2015
* @TestClasses: ZZTEST_OpportunityLineItemTrigger_Helper, 
                ZZTEST_OpportunityLineItemChatter
* History
* <Date>      <Authors Name>    <Brief Description of Change>
* 11/2015     Marek Cech        added countProductTotals method
* 12/2015 - US-0775 - Mohsin Wadee      
                                Added chatterSettings class level variable.
*                               Added IsUserAdmin property.
*                               Added CanCreateChatterPostOnInsert method.
*                               Added CanCreateChatterPostOnUpdate method.
*                               Added CanCreateChatterPostOnDelete method.
*                               Modified createChatterPostsAfterInsert method.
*                               Modified createChatterPostsAfterUpdate method.
*                               Modified createChatterPostsAfterDelete method.
* 10-Dec-2015 - US-0775 - Mohsin Wadee - chatterSettings class level variable now 
*                   instantiates DeactivateChatterPostSettings__c class, and made the corresponding changes in methods:
*                               CanCreateChatterPostOnInsert
*                               CanCreateChatterPostOnUpdate
*                               CanCreateChatterPostOnDelete       
* 21/01/2016  Marta Malinowska  Change the calculation for "Once-off Fees" (Debt products)
* 05/02/2016  Marek Cech        Changed "countProductTotals" to not use "Product2Id" on OpportunityLineItem
*31 August 2017 Sizwe Tshabalala SFA 1281 flag team member confirmation
*--------------------------------------------------------------------------------------*/
public class OpportunityLineItemTrigger_Helper {

    private static final String SPACE = ' ';
    
    private static final String DOT = '.';
    
    @testVisible
    private static final String MONTHLY = 'Monthly';
    
    @testVisible
    private static final String QUARTERLY = 'Quarterly';
    
    @testVisible
    private static final String SEMI_ANNUALLY = 'Semi-Annually';
    
    @testVisible
    private static final String ANNUALLY = 'Annually';
    
    @testVisible
    private static final String DEBT = 'Debt';
    
    @testVisible
    private static DeactivateChatterPostSettings__c chatterSettings = DeactivateChatterPostSettings__c.getValues('OpportunityLineItem');
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Same algorithm for counting totals on oli (same algorithm is in front end)
      * @Params           List<OpportunityLineItem> newOlis - olis to process
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      * 05/02/2016  Marek Cech        Changed logic to not use "Product2Id" on OpportunityLineItem
      *------------------------------------------------------------*/
    public static void countProductTotals(List<OpportunityLineItem> newOlis) {
        
        //preparing list of opty ids and pricebook entry ids
        List<Id> optyIds = new List<Id>();
        List<Id> pricebookEntryIds = new List<Id>();
        for (OpportunityLineItem oli: newOlis) {
            optyIds.add(oli.OpportunityId);
            pricebookEntryIds.add(oli.PricebookEntryId);
        }
        
        //querying pricebook entries to get product2 ids
        List<PricebookEntry> entries = [SELECT Product2Id FROM PricebookEntry WHERE Id IN :pricebookEntryIds];
        Map<Id, PricebookEntry> entriesMap = new Map<Id, PricebookEntry>(entries);
        
        List<Id> product2Ids = new List<Id>();
        for (PricebookEntry pe: entries) {
            product2Ids.add(pe.Product2Id);
        }
        
        //getting close dates of optys
        List<Opportunity> optys = [SELECT CloseDate, isExternal__c FROM Opportunity WHERE Id IN :optyIds];
        Map<Id, Opportunity> optysMap = new Map<Id, Opportunity>(optys);
        
        //getting product2 names
        List<Product2> productFamilies = [SELECT Id, Family FROM Product2 WHERE Id IN :product2Ids];
        Map<Id, Product2> productFamiliesMap = new Map<Id, Product2>(productFamilies);
        
        for (OpportunityLineItem oli: newOlis) {
            PricebookEntry pe = entriesMap.get(oli.PricebookEntryId);
        
            String productFamily = productFamiliesMap.get(pe.Product2Id).Family;
            Boolean isDebt = productFamily == DEBT ? true : false;
            
            checkOliNullFields(oli, isDebt);
            
            Decimal margin = oli.Margin__c / 100;
            Decimal utilisation = oli.Estimated_Utilisation__c / 100;
            
            Date optyCloseDate = optysMap.get(oli.OpportunityId).CloseDate;
            Boolean isExternal = optysMap.get(oli.OpportunityId).isExternal__c;
            Date endOfYear = Date.newInstance(optyCloseDate.year(), 12, 31);
            Integer daysFromCloseDateToEndOfYear = optyCloseDate.daysBetween(endOfYear);
            Integer monthsFromCloseDateToEndOfYear = optyCloseDate.monthsBetween(endOfYear);
            
            Decimal annualisedFees = 0;
            Decimal firstYearFees = 0;
            
            if (oli.Recurring_Fees_Period__c == MONTHLY) {
                annualisedFees = oli.Recurring_Fees__c * 12;
                firstYearFees = oli.Recurring_Fees__c * monthsFromCloseDateToEndOfYear;
                
            } else if (oli.Recurring_Fees_Period__c == QUARTERLY) {
                annualisedFees = oli.Recurring_Fees__c * 4;
                firstYearFees = oli.Recurring_Fees__c * monthsFromCloseDateToEndOfYear / 3;
                
            } else if (oli.Recurring_Fees_Period__c == SEMI_ANNUALLY) {
                annualisedFees = oli.Recurring_Fees__c * 2;
                firstYearFees = oli.Recurring_Fees__c * monthsFromCloseDateToEndOfYear / 6;
            
            } else if (oli.Recurring_Fees_Period__c == ANNUALLY) {
                annualisedFees = oli.Recurring_Fees__c;
            }
            
            if (isDebt) {
            	Decimal Arranging_Fee = CalculateFee(oli.Arranging_Fee__c,oli.Arranging_Fee_Deferred__c,oli.Hold_Size__c);
            	Decimal Other_Fees = CalculateFee(oli.Other_Fees__c,oli.Other_Fees_Deferred__c,oli.Hold_Size__c);
            	Decimal Participation_Fee = CalculateFee(oli.Participation_Fee__c,oli.Participation_Fee_Deferred__c,oli.Hold_Size__c);
            	Decimal Agency_Fee = CalculateFee(oli.Agency_Fee__c,oli.Agency_Fee_Deferred__c,oli.Hold_Size__c);
            	Decimal Co_ordination_Fee = CalculateFee(oli.Co_ordination_Fee__c,oli.Coordination_Fee_Deferred__c,oli.Hold_Size__c);
            	if (isExternal == NULL || isExternal == false) oli.Fees__c = Arranging_Fee + Other_Fees + Participation_Fee + Agency_Fee + Co_ordination_Fee;
            }
            
            Decimal nii = oli.Balance__c * margin * utilisation;
            Decimal annualisedIncome = nii + annualisedFees + oli.Fees__c;
            
            Decimal firstYearIncome = nii * daysFromCloseDateToEndOfYear / 365;
            firstYearIncome += firstYearFees + oli.Fees__c;
            
            oli.Annualised_Income__c = Math.round(annualisedIncome);
            oli.Income_this_Year__c = Math.round(firstYearIncome);
            oli.New_Facility__c = Math.round(annualisedIncome);
        }
        
    }
    
    /**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     Method used to work out once off fee based on deferred flag, holdsize and fee percentage 
      * @Params           fee percentage, deferred flag, holdsize
      * @Returns:         Decimal Fee
      * History
      * 07/09/2016  Dino Scarcella   Created method to calculate once off fees     
      *------------------------------------------------------------*/
    private static Decimal CalculateFee(Decimal FeePercentage, Boolean Deferred, Decimal HoldSize) {
    	Decimal FeeAmount = 0;
        if (!Deferred) FeeAmount = FeePercentage / 100 * HoldSize;
        return FeeAmount;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Posts chatter link posts to opportunity when opportunity product changes.
      * @Params           List<OpportunityLineItem> newOlis - new version of olis, List<OpportunityLineItem> oldOlis - old version of olis
      * @Returns:         void
      * History
      * 03-Dec-2015 - Mohsin Wadee - US-0775 - added check to see if custom settings will allow
      *     the creation of a chatter post when an Opportunity Line Item is updated. 
      *-----------------------------------------------------------------------------------------------------------------------------------*/
    static public void createChatterPostsAfterUpdate(List<OpportunityLineItem> newOlis, List<OpportunityLineItem> oldOlis) {
        
        if (CanCreateChatterPostOnUpdate()) {
            List<FeedItem> fis = new List<FeedItem>();
            
            OpportunityLineItem newOli;
            OpportunityLineItem oldOli;
            
            //iterating over opportunity products to process
            for (Integer i = 0; i < newOlis.size(); i++) {
                newOli = newOlis[i];
                oldOli = oldOlis[i];
                
                List<String> bodyList = new List<String>();
                
                //product level 3 has changed
                if (newOli.Product_Level_3__c != oldOli.Product_Level_3__c) {
                    List<String> productChanges = prepareStringListForProductChange(newOli, oldOli);
                    bodyList.addAll(productChanges);
                }
                
                //balance has changed
                if (newOli.Balance__c != oldOli.Balance__c) {
                    List<String> balanceChanges = prepareStringListForBalanceChange(newOli, oldOli);
                    bodyList.addAll(balanceChanges);
                }
                
                //income this year has changed
                if (newOli.Income_this_Year__c != oldOli.Income_this_Year__c) {
                    List<String> incomeThisYChanges = prepareStringListForIncomeThisYChange(newOli, oldOli);
                    bodyList.addAll(incomeThisYChanges);
                }
                
                //annualised income has changed
                if (newOli.Annualised_Income__c != oldOli.Annualised_Income__c) {
                    List<String> annIncomeChanges = prepareStringListForAnnIncomeChange(newOli, oldOli);
                    bodyList.addAll(annIncomeChanges);
                }
                
                //post preparation
                if (bodyList.size() > 0) {
                    String body = String.join(bodyList, '');
                    FeedItem fi = prepareLinkChatterPost(newOli.OpportunityId, newOli.Product_Name__c, 
                        '/' + newOli.Id, body);
                    fis.add(fi);
                }
            }
            insert fis;
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Posts chatter link posts to opportunity after opportunity product insert.
      * @Params           List<OpportunityLineItem> newOlis - olis to process
      * @Returns:         void
      * History
      * 02-Dec-2015, Mohsin Wadee, US-0775, added check to see if custom settings will allow
      *     the creation of a chatter post when an Opportunity Line Item is inserted. 
      *--------------------------------------------------------------------------------------------*/
    static public void createChatterPostsAfterInsert(List<OpportunityLineItem> newOlis) {
        
        if (CanCreateChatterPostOnInsert()) {
            List<FeedItem> fis = new List<FeedItem>();
            
            //iterating over opportunity products to process
            for (OpportunityLineItem oli: newOlis) {
                FeedItem fi = prepareLinkChatterPost(oli.OpportunityId, oli.Product_Name__c, '/' + oli.Id, 
                    Label.msg_ProductAdded);
                fis.add(fi);
            }
            insert fis;
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Posts chatter link posts to opportunity after opportunity product delete.
      * @Params           List<OpportunityLineItem> oldOlis - olis to process
      * @Returns:         void
      * History
      * 02-Dec-2015 - Mohsin Wadee - US-0775, added check to see if custom settings will allow
      *     the creation of a chatter post when an Opportunity Line Item is deleted.
      *------------------------------------------------------------------------------------------------*/
    static public void createChatterPostsAfterDelete(List<OpportunityLineItem> oldOlis) {
        
        if (CanCreateChatterPostOnDelete()) {
            List<FeedItem> fis = new List<FeedItem>();
            
            //iterating over opportunity products to process
            for (OpportunityLineItem oli: oldOlis) {
                FeedItem fi = ChatterUtils.addTextPost(oli.OpportunityId, Label.msg_ProductDeleted + ' ' + 
                    oli.Product_Name__c);
                fis.add(fi);
            }
            insert fis;
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Update product lists from modified/deleted opp line items
      * @Params           List<OpportunityLineItem> modifiedOppLineItems - olis to process
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      * 31.05.2017  Dino Scarcella     Made changes to cater for ProductLevel2+3List when Product inserted, updated and deleted
      *------------------------------------------------------------*/
    static public void updateProductListFromProductAfterModify(List<OpportunityLineItem> modifiedOppLineItems) {

        Map<Id, List<OpportunityLineItem>> remainingOppLineItems = new Map<Id, List<OpportunityLineItem>>();
        List<Opportunity> opportunities = new List<Opportunity>();
        Set<Id> oppId = new Set<Id>();
        Set<Id> oppLineItemIds = (new Map<Id,SObject>(modifiedOppLineItems)).keySet();
        List<Opportunity> oppToUpdate = new List<Opportunity>();
        String productList;
        String productLevel2List;
        String productLevel3List;

        //get Id of all Opportunities where their products have been modified
        for (OpportunityLineItem opsline : modifiedOppLineItems) {
            oppId.add(opsline.OpportunityId);
        }
        opportunities = [SELECT Id, Productlist__c,(SELECT Id, PricebookEntry.Product2.Name, Product_Level_2__c, Product_Level_2__r.Name, Product_Level_3__c, Product_Level_3_Name__c, OpportunityId FROM OpportunityLineItems) FROM Opportunity WHERE Id IN :oppId];

        //create a map of Opportunities and line items
        for (Opportunity Opp : opportunities)
        {
            for(OpportunityLineItem  existingOppLineItem : Opp.OpportunityLineItems)
            {
                if (remainingOppLineItems.containsKey(existingOppLineItem.OpportunityId)) {
                    remainingOppLineItems.get(existingOppLineItem.OpportunityId).add(existingOppLineItem);
                }
                else {
                    remainingOppLineItems.put(existingOppLineItem.OpportunityId,  new List<OpportunityLineItem>{existingOppLineItem});
                }
            }    
        }
        // iterate over all opportunities that needs to have productlist changed
        for (Opportunity opp : opportunities) {
            if (remainingOppLineItems.containsKey(opp.Id)) {
                productList = getProductString(remainingOppLineItems.get(opp.Id));
                productLevel2List = getProductLevel2String(remainingOppLineItems.get(opp.Id));
                productLevel3List = getProductLevel3String(remainingOppLineItems.get(opp.Id));
                opp.ProductList__c = productList;
                opp.ProductLevel2List__c = productLevel2List;
          		opp.ProductLevel3List__c = productLevel3List;
                oppToUpdate.add(opp);
            }
            else {
                opp.ProductList__c = '';
                opp.ProductLevel2List__c = '';
                opp.ProductLevel3List__c = '';
                opp.ProductLevel3__c='';
                oppToUpdate.add(opp);
            }
        }
        
        Database.SaveResult[] results = Database.update(oppToUpdate,false);
        for(Integer i=0; i<results.size(); i++){
			if (!results[i].isSuccess()) oppToUpdate[i].addError(results[i].getErrors()[0].getMessage()); // Add a more meaningful error for user CIBDIGSALP-1360
		}
    }
    
    /**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     Update the Product Partner on the Opportunity with Product partner of the Product created/updated
      * @Params           List<OpportunityLineItem> newOppLineItems - olis to process
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    static public void UpdateProductPartnerOnOpp(List<OpportunityLineItem> newOppLineItems, Map<Id, OpportunityLineItem> oldOppLineItems) {
    	Boolean RunTrigger = false;
    	// Sets the boolean to determine whether we need to continue (avoid running SOQL for nothing)
        for (OpportunityLineItem opsline : newOppLineItems) {
        	// If we are either creating a Product or changing the Product Partner
        	if (oldOppLineItems == null
        		||   
        		opsline.ProductPartner__c != oldOppLineItems.get(opsline.Id).ProductPartner__c)
        	{
        		RunTrigger = true;
        	}
        }
    	if (!RunTrigger) return;
    	
    	Map<Id, Set<Id>> oppteammembermap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> pendingapprovalsmap = new Map<Id, Set<Id>>();
        Map<Id, Id> oppownermap = new Map<Id, Id>();
		List<Opportunity> oppToUpdate = new List<Opportunity>();
		List<OpportunityTeamMember> oppTeamMembersToInsert = new List<OpportunityTeamMember>();
		List<OpportunityTeamMember> oppTeamMembersToDelete = new List<OpportunityTeamMember>();
		List<Approval.ProcessSubmitRequest> submit_requests = new List<Approval.ProcessSubmitRequest>();
        List<Approval.ProcessWorkitemRequest> reject_requests = new List<Approval.ProcessWorkItemRequest>();
		List<Opportunity> opportunities = new List<Opportunity>();
        Set<Id> oppId = new Set<Id>();
		
		//get Id of all Opportunities where the Opp Line Items were Created
        for (OpportunityLineItem opsline : newOppLineItems) {
            oppId.add(opsline.OpportunityId);
        }
		
		//get list of all Opportunity Team Members in the opportunities in question
        List<OpportunityTeamMember> oppteammembers = [SELECT UserId, OpportunityId, TeamMemberRole FROM OpportunityTeamMember WHERE OpportunityId IN :oppId];
		
        //get opportunities related to opp line items added and add to a map with owners
        for (Opportunity opp : [SELECT Id, OwnerId FROM Opportunity WHERE Id IN :oppId])
        	oppownermap.put(opp.Id, opp.OwnerId);
        
        //get list of all Pending Approvals for the involved opportunities
		List<ProcessInstanceWorkitem> pending_approvals = [SELECT Id, ProcessInstance.TargetObjectId 
                                                           FROM ProcessInstanceWorkitem 
                                                           WHERE ProcessInstance.Status = 'Pending' 
                                                           AND ProcessInstance.ProcessDefinition.Name = 'Product Partner Approval'
                                                           AND ProcessInstance.TargetObjectId IN :oppId];
        
		//create a map of Opportunities and Opportunity Team Members
        for (OpportunityTeamMember existingOppTeamMember : oppteammembers) {
            if (oppteammembermap.containsKey(existingOppTeamMember.OpportunityId)) {
                oppteammembermap.get(existingOppTeamMember.OpportunityId).add(existingOppTeamMember.UserId);
            } else {
                oppteammembermap.put(existingOppTeamMember.OpportunityId,  new Set<Id>{existingOppTeamMember.UserId});
            }
        }
        
        //create a map of Opportunities and Pending Approval ProcessInstanceWorkitem Ids
        for (ProcessInstanceWorkitem PIW : pending_approvals) {
            if (pendingapprovalsmap.containsKey(PIW.ProcessInstance.TargetObjectId)) {
                pendingapprovalsmap.get(PIW.ProcessInstance.TargetObjectId).add(PIW.Id);
            } else {
                pendingapprovalsmap.put(PIW.ProcessInstance.TargetObjectId, new Set<Id>{PIW.Id});
            }
        }
		
        //Iterate through all the OpportunityLineItems Created
        for (OpportunityLineItem opsline : newOppLineItems) {
        	Opportunity opp = new Opportunity();
        	// If we are either creating a Product or changing the Product Partner
        	if (oldOppLineItems == null
        		||   
        		opsline.ProductPartner__c != oldOppLineItems.get(opsline.Id).ProductPartner__c)
        	{
        		// Update the Product Partner
        		opp.Id = opsline.OpportunityId;
        		opp.ProductPartner__c = opsline.ProductPartner__c;
        		oppToUpdate.add(opp);
                // Reject Approval if pending
                if (pendingapprovalsmap.containsKey(opp.Id)) {
                    for (Id PIW_Id : pendingapprovalsmap.get(opp.Id)) {
						Approval.ProcessWorkitemRequest requestPWI = new Approval.ProcessWorkitemRequest();
                        requestPWI.setWorkItemId(PIW_Id);
                        requestPWI.setComments('Auto-Reject on change of Product Partner');
                        requestPWI.setAction('Reject');
                        reject_requests.add(requestPWI);
                    }                    
                }
                if (opsline.ProductPartner__c != null) {
                    // Auto-submit the approval
                    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
                    req.setComments('Submitting Product Partner Request for Approval');
                    req.setObjectId(opsline.OpportunityId);
                    req.setSubmitterId(oppownermap.get(opp.Id));
                    submit_requests.add(req);
                    // Add the Product Partner to the Deal Team if not there
                    if (!oppteammembermap.containsKey(opsline.OpportunityId) ||
                        !oppteammembermap.get(opsline.OpportunityId).Contains(opsline.ProductPartner__c)) {
                            OpportunityTeamMember oppTeamMember = new OpportunityTeamMember();
                            oppTeamMember.OpportunityId = opsline.OpportunityId;
                            oppTeamMember.UserId = opsline.ProductPartner__c;
                            oppTeamMember.TeamMemberRole = 'Product Partner Approver';
                            oppTeamMember.OpportunityAccessLevel = 'Edit';
                            oppTeamMember.I_confirm_team_member_has_been_cleared__c = true;
                            oppTeamMembersToInsert.add(oppTeamMember);
                    }
                }
        	}
        }
        
        try {
       		if (oppToUpdate.Size() > 0)	update oppToUpdate;
            if (reject_requests.size() > 0) Approval.process(reject_requests, true);
            if (submit_requests.size() > 0) Approval.process(submit_requests, true);
            if (oppTeamMembersToInsert.Size() > 0) insert oppTeamMembersToInsert;
            if (oppToUpdate.Size() > 0)	Approval.Unlock(oppToUpdate, false);
        } catch (Exception e) {
        	System.debug('Exception updating product partner:' + e.getMessage());
        }
    }
    
    /**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     Clear the RPF Parameters Stored related to certain fields changing on OpportunityLineItem
      * @Params           List<OpportunityLineItem> newOppLineItems - olis to process
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    static public void clearRPFCalculations(List<OpportunityLineItem> newOppLineItems, Map<Id, OpportunityLineItem> oldOppLineItems) {
        Set<String> oliIdAF = new Set<String>();
        Set<String> oliIdUA = new Set<String>();
        Set<String> oppIdDD = new Set<String>();
        
        for (OpportunityLineItem opsline : newOppLineItems) {
        	// If we have changed the Arranging Fee
            if (opsline.Arranging_Fee__c != oldOppLineItems.get(opsline.Id).Arranging_Fee__c ||
                opsline.Hold_Size__c != oldOppLineItems.get(opsline.Id).Hold_Size__c
               ) 
            {
        		oliIdAF.add(String.ValueOf(opsline.Id));
            }
            if (
                opsline.StartDate__c != oldOppLineItems.get(opsline.Id).StartDate__c ||
                opsline.Hold_Size__c != oldOppLineItems.get(opsline.Id).Hold_Size__c ||
                opsline.DrawPercentageCurrentYear__c != oldOppLineItems.get(opsline.Id).DrawPercentageCurrentYear__c ||
                opsline.DrawPercentageNextYear__c != oldOppLineItems.get(opsline.Id).DrawPercentageNextYear__c
               ) 
            {
            	oliIdUA.add(String.ValueOf(opsline.Id));
                oppIdDD.add(String.ValueOf(opsline.OpportunityId));
            }
        }
    	if (oliIdAF.size()==0 && oliIdUA.size()==0) return;
        
        List<RPFCalculation__c> RPFCs = [SELECT Id FROM RPFCalculation__c 
                                         WHERE (
                                             	OpportunityLineItemId__c IN :oliIdAF
                                         		AND Month__c IN ('ArrangingFeeUpfrontAmount','ArrangingFeeDeferredAmount')
                                               )
                                         OR
                                         	   (
                                             	OpportunityLineItemId__c IN :oliIdUA
                                         		AND Month__c NOT IN ('ArrangingFeeUpfrontAmount','ArrangingFeeDeferredAmount')
                                               )
                                        ];
        List<Drawdowns__c> DDs = [SELECT Id FROM Drawdowns__c
                                         WHERE Opportunity__c IN :oppIdDD];
        
        Savepoint sp = Database.setSavepoint();
        try {
       		if (RPFCs.Size() > 0) delete RPFCs;
            if (DDs.Size() > 0) delete DDs;
        } catch (Exception e) {
            Database.rollback(sp);
        	System.debug('Exception clearing stored RPFC calculation values and drawdowns:' + e.getMessage());
        }
    }
    
    /**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     Method which creates Cross Sell Opportunities based on the Product you have chosen
      * @Params           List<OpportunityLineItem> newOppLineItems & Map<Id, OpportunityLineItem> oldOppLineItems - olis to process
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/    
    static public void crossSellOpps(List<OpportunityLineItem> newOppLineItems, Map<Id, OpportunityLineItem> oldOppLineItems, List<OpportunityLineItem> oldOppLineItemsList) {
		crossSellDeposits(newOppLineItems, oldOppLineItems, oldOppLineItemsList);
    }
    
    /**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     Method which creates Deposit Cross Sell Opportunities
      * @Params           List<OpportunityLineItem> newOppLineItems & Map<Id, OpportunityLineItem> oldOppLineItems - olis to process
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/    
    static private void crossSellDeposits(List<OpportunityLineItem> newOppLineItems, Map<Id, OpportunityLineItem> oldOppLineItems, List<OpportunityLineItem> oldOppLineItemsList) {
        List<Opportunity> oppstoinsert = new List<Opportunity>();
        Set<Id> parentoppsforinsertion = new Set<Id>();
        Map<Id, Opportunity> parentopps = new Map<Id, Opportunity>();
        List<OpportunityLineItem> opplineitemstoinsert = new List<OpportunityLineItem>();
        List<Opportunity> parentoppstoUpdate = new List<Opportunity>();
        
        for (OpportunityLineItem opsline : newOppLineItems) {
        	if (oldOppLineItems != NULL &&
            	(
                	oldOppLineItems.get(opsline.Id).Product_Level_3_Name__c != opsline.Product_Level_3_Name__c ||
                    oldOppLineItems.get(opsline.Id).OpportunityCountry__c != opsline.OpportunityCountry__c
                )
               )
            {
                if (opsline.Product_Level_2_Name__c == 'Electronic Banking' && opsline.Product_Level_3_Name__c != NULL && opsline.Product_Level_3_Name__c.Contains('Domestic Payments') && opsline.OpportunityCountry__c == 'South Africa' && opsline.AccountSegment__c != 'Business Banking' && opsline.CrossSellOpportunity__c == false) parentoppsforinsertion.add(opsline.OpportunityId);
            }
            if (oldOppLineItems == null && opsline.Product_Level_2_Name__c == 'Electronic Banking' && opsline.Product_Level_3_Name__c != NULL && opsline.Product_Level_3_Name__c.Contains('Domestic Payments') && opsline.OpportunityCountry__c == 'South Africa' && opsline.AccountSegment__c != 'Business Banking' && opsline.CrossSellOpportunity__c == false) {
            	parentoppsforinsertion.add(opsline.OpportunityId);
            }
        }
        
        if (parentoppsforinsertion.size() == 0) return;
        
        // Only public opportunities and opportunities without a parent are in scope
        if (parentoppsforinsertion.size() > 0) {
            parentopps = new Map<ID, Opportunity>([SELECT Id, OwnerId, Name, AccountId, Related_Group_Client__c, CurrencyIsoCode, RecordTypeId, Type, Opportunity_Country__c, CloseDate, Description, Next_Steps__c, (SELECT Id, Volume__c, Transaction_Value__c FROM OpportunityLineItems) 
                                                   FROM Opportunity WHERE Id =: parentoppsforinsertion
                                                   AND RecordTypeId =: OpportunityTrigger_Helper.getOpportunityRT(OpportunityTrigger_Helper.OpportunityRT.PublicOpp)
                                                   AND Parent_Opportunity__c = NULL
                                                  ]);
            
            for(Opportunity parentopp : parentopps.values()) {
            	parentopp.Is_Parent_Opportunity__c = 'Yes';
                parentoppstoUpdate.add(parentopp);
            }
            for (Id oppId : parentoppsforinsertion) {
                if (parentopps.containsKey(oppId)) {
                	String name = 'Deposit Cross-Sell - ' + parentopps.get(oppId).Name;
                    Opportunity newopp = new Opportunity (
                            OwnerId = parentopps.get(oppId).OwnerId,
                            Name = name.SubString(0,name.length() > 120 ? 120 : name.length()),
                            AccountId = parentopps.get(oppId).AccountId,
                            Related_Group_Client__c = parentopps.get(oppId).Related_Group_Client__c,
                            CurrencyIsoCode = parentopps.get(oppId).CurrencyIsoCode,
                            RecordTypeId = parentopps.get(oppId).RecordTypeId,
                            Type = 'Cross Sell',
                            Opportunity_Country__c = parentopps.get(oppId).Opportunity_Country__c,
                            CloseDate = parentopps.get(oppId).CloseDate,
                            Description = parentopps.get(oppId).Description,
                            Next_Steps__c = parentopps.get(oppId).Next_Steps__c,
                            CrossSellOpportunity__c = true,
                            Parent_Opportunity__c = oppId,
                            StageName = 'Opportunity Identified',
                            IsPrivate = parentopps.get(oppId).IsPrivate,
                            Account_Lock__c = parentopps.get(oppId).Account_Lock__c,
                            Opportunity_Source__c = parentopps.get(oppId).Opportunity_Source__c,
                            Original_Related_Group_Client__c = parentopps.get(oppId).Original_Related_Group_Client__c,
                            Account_Name__c = parentopps.get(oppId).Account_Name__c,
                            Private_Side__c = parentopps.get(oppId).Private_Side__c,
                            PrivateSideClassification__c = parentopps.get(oppId).PrivateSideClassification__c
                    );
                    oppstoinsert.add(newopp);   
                }
            }   
        }
        
        if (oppstoinsert.size() > 0) {
            SavePoint sp = Database.setSavepoint();
            List<Product_Level_3__c> currentAccountDepositProduct = [SELECT Product_Level_2__r.Product__c, Product_Level_2__c, Id FROM Product_Level_3__c WHERE Product_Level_2__r.Product__r.Name = 'Deposits' AND Product_Level_2__r.Name = 'Current Account Deposit' AND Name = 'Current Account Deposit' LIMIT 1];
            Map<String, Id> pricebookentry = new Map<String, Id>();
            if (currentAccountDepositProduct.size() > 0) {
                for (PriceBookEntry pbe : [SELECT CurrencyIsoCode, Id FROM PriceBookEntry WHERE IsActive = true AND Product2Id =: currentAccountDepositProduct[0].Product_Level_2__r.Product__c])
                    pricebookentry.put(pbe.CurrencyIsoCode, pbe.Id);    
            }
            List<Product_Setting__mdt> ProductPartner = [SELECT Product_Partner_Team__c FROM Product_Setting__mdt WHERE ProductSet__c = 'ChequeDepositProductPartner' LIMIT 1];
            if (currentAccountDepositProduct.size() > 0 && ProductPartner.size() > 0 && pricebookentry.size() > 0) {
                try {
                    if (parentoppstoUpdate.Size() > 0) update parentoppstoUpdate;
                    if (oppstoinsert.Size() > 0) {
                        Database.SaveResult[] results = Database.insert(oppstoinsert, true);
                        for(integer i=0; i< results.size(); i++) {
                            OpportunityLineItem newopplineitem = new OpportunityLineItem (
                                    Product2Id = currentAccountDepositProduct[0].Product_Level_2__r.Product__c,
                                    Product_Level_2__c = currentAccountDepositProduct[0].Product_Level_2__c,
                                    Product_Level_3__c = currentAccountDepositProduct[0].Id,
                                    Estimated_Utilisation__c = 0.82,
                                    ProductPartner__c = ProductPartner[0].Product_Partner_Team__c,
                                    CrossSellOpportunity__c = true,
                                    PriceBookEntryId = pricebookentry.get(parentopps.get(oppstoinsert[i].Parent_Opportunity__c).CurrencyIsoCode),
                                    OpportunityId = results[i].getId()
                            );
                            opplineitemstoinsert.add(newopplineitem);
                        }
                        insert opplineitemstoinsert;
                    }
                } catch (Exception e) {
                    System.debug('Line:' + e.getLineNumber() + ' Exception on cross sell opportunities:' + e.getMessage());
                    Database.rollback(sp);
                }   
            }    
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Created new string for productList
      * @Params           List<OpportunityLineItem> oppsLineItems - olis to process
      * @Returns:         String - product list
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    static private String getProductString(List<OpportunityLineItem> oppsLineItems) {

        String productlist = '';
        Integer iterator = oppsLineItems.size();
        String product2Name = '';

        for (Integer i = 0; i < oppsLineItems.size(); i++) {

            product2Name = oppsLineItems[i].PricebookEntry.Product2.Name;
            
            if (!productlist.contains(product2Name)) {
                if (i < (iterator - 1)) {
                    productlist = productlist + product2Name + ' ';
                }
                else {
                    productlist = productlist + product2Name;
                }
            }   
        }
        return productlist;
    }
    
    /**
      * @Author:          Dino Scarcella
      * @Company:         Deloitte
      * @Description:     Created new string for product level 2 list
      * @Params           List<OpportunityLineItem> oppsLineItems - olis to process
      * @Returns:         String - product list
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    static private String getProductLevel2String(List<OpportunityLineItem> oppsLineItems) {

        String productlist = '';
        Integer iterator = oppsLineItems.size();
        String product2Name = '';

        for (Integer i = 0; i < oppsLineItems.size(); i++) {
            if (oppsLineItems[i].Product_Level_2__c != null) {
                product2Name = oppsLineItems[i].Product_Level_2__r.Name;
            
                if (!productlist.contains(product2Name)) {
                    if (i < (iterator - 1)) {
                        productlist = productlist + product2Name + ' ';
                    }
                    else {
                        productlist = productlist + product2Name;
                    }
                }
            }       
        }
        return productlist;
    }
    
    /**
      * @Author:          Dino Scarcella
      * @Company:         Deloitte
      * @Description:     Created new string for product level 3 list
      * @Params           List<OpportunityLineItem> oppsLineItems - olis to process
      * @Returns:         String - product list
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    static private String getProductLevel3String(List<OpportunityLineItem> oppsLineItems) {

        String productlist = '';
        Integer iterator = oppsLineItems.size();
        String product3Name = '';

        for (Integer i = 0; i < oppsLineItems.size(); i++) {
            if (oppsLineItems[i].Product_Level_3_Name__c != null) {
                product3Name = oppsLineItems[i].Product_Level_3_Name__c;
            
                if (!productlist.contains(product3Name)) {
                    if (i < (iterator - 1)) {
                        productlist = productlist + product3Name + ' ';
                    }
                    else {
                        productlist = productlist + product3Name;
                    }
                }
            }
        }
        return productlist;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares chatter link post from data in params.
      * @Params           Id of record to add post to, header of post, link to opportunity product, body of post
      * @Returns:         FeedItem - created chatter post
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    static private FeedItem prepareLinkChatterPost(Id recordId, String header, String link, String body) {
        return ChatterUtils.addLinkPost(recordId, header, link, body);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Return value in param if not null, 'blank value' otherwise
      * @Params           String value - value to check
      * @Returns:         String - same as in param if not null, 'blank value' otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    static private String getMessageValueFromValue(String value) {
        if (value == null) {
            return Label.lbl_BlankValue;
        } else {
            return value;
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares list of strings to join for balance change chatter post.
      * @Params           OpportunityLineItem newOli - old version of oli, OpportunityLineItem oldOli - old version of oli
      * @Returns:         List<String> - created list of string for balance change post
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    static private List<String> prepareStringListForBalanceChange(OpportunityLineItem newOli, OpportunityLineItem oldOli) {
        List<String> result = new List<String>();
        result.add(Label.msg_BalanceUpdated);
        result.add(SPACE);
        
        Decimal balance = oldOli.Balance__c == null ? 0 : oldOli.Balance__c;
        result.add(String.valueOf(balance));
        result.add(SPACE);
        result.add(Label.lbl_to);
        result.add(SPACE);
        
        balance = newOli.Balance__c == null ? 0 : newOli.Balance__c;
        result.add(String.valueOf(balance));
        result.add(DOT);
        result.add(SPACE);
        return result;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares list of strings to join for product change chatter post.
      * @Params           OpportunityLineItem newOli - old version of oli, OpportunityLineItem oldOli - old version of oli
      * @Returns:         List<String> - created list of string for product change post
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    static private List<String> prepareStringListForProductChange(OpportunityLineItem newOli, OpportunityLineItem oldOli) {
        List<String> result = new List<String>();
        result.add(Label.msg_ProductUpdated);
        result.add(SPACE);
        result.add(getMessageValueFromValue(oldOli.Product_Level_3_Name__c));
        result.add(SPACE);
        result.add(Label.lbl_to);
        result.add(SPACE);
        result.add(getMessageValueFromValue(newOli.Product_Level_3_Name__c));
        result.add(DOT);
        result.add(SPACE);
        return result;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares list of strings to join for income this year change chatter post.
      * @Params           OpportunityLineItem newOli - old version of oli, OpportunityLineItem oldOli - old version of oli
      * @Returns:         List<String> - created list of string for this year change post
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    static private List<String> prepareStringListForIncomeThisYChange(OpportunityLineItem newOli, OpportunityLineItem oldOli) {
        List<String> result = new List<String>();
        result.add(Label.msg_IncomeThisYearUpdated);
        result.add(SPACE);
        
        Decimal income = oldOli.Income_this_Year__c == null ? 0 : oldOli.Income_this_Year__c;
        result.add(String.valueOf(income));
        result.add(SPACE);
        result.add(Label.lbl_to);
        result.add(SPACE);
        
        income = newOli.Income_this_Year__c == null ? 0 : newOli.Income_this_Year__c;
        result.add(String.valueOf(income));
        result.add(DOT);
        result.add(SPACE);
        return result;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares list of strings to join for annualised income change chatter post.
      * @Params           OpportunityLineItem newOli - old version of oli, OpportunityLineItem oldOli - old version of oli
      * @Returns:         List<String> - created list of string for annualised income change post
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    static private List<String> prepareStringListForAnnIncomeChange(OpportunityLineItem newOli, OpportunityLineItem oldOli) {
        List<String> result = new List<String>();
        result.add(Label.msg_AnnIncomeUpdated);
        result.add(SPACE);
        
        Decimal income = oldOli.Annualised_Income__c == null ? 0 : oldOli.Annualised_Income__c;
        result.add(String.valueOf(income));
        result.add(SPACE);
        result.add(Label.lbl_to);
        result.add(SPACE);
        
        income = newOli.Annualised_Income__c == null ? 0 : newOli.Annualised_Income__c;
        result.add(String.valueOf(income));
        result.add(DOT);
        result.add(SPACE);
        return result;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Handles null fields in opportunity product.
      * @Params           OpportunityLineItem oli to check, Boolean isDebt indicating whether product is from Debt family
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private static void checkOliNullFields(OpportunityLineItem oli, Boolean isDebt) {
        
        if (oli.Margin__c == null) {
            oli.Margin__c = 0;
        }
        if (oli.Estimated_Utilisation__c == null) {
            oli.Estimated_Utilisation__c = 0;
        }
        if (oli.Recurring_Fees_Period__c == null) {
            oli.Recurring_Fees_Period__c = MONTHLY;
        }
        if (oli.Recurring_Fees__c == null) {
            oli.Recurring_Fees__c = 0;
        }
        if (oli.Balance__c == null) {
            oli.Balance__c = 0;
        }
        if (oli.Fees__c == null) {
            oli.Fees__c = 0;
        }
        
        if (isDebt) {
            if (oli.Hold_Size__c == null) {
                oli.Hold_Size__c = 0;
            }
            if (oli.Arranging_Fee__c == null) {
                oli.Arranging_Fee__c = 0;
            }
            if (oli.Other_Fees__c == null) {
                oli.Other_Fees__c = 0;
            }
            if (oli.Committment_Fee__c == null) {
                oli.Committment_Fee__c = 0;
            }
            if (oli.Participation_Fee__c == null) {
                oli.Participation_Fee__c = 0;
            }
            if (oli.Agency_Fee__c == null) {
                oli.Agency_Fee__c = 0;
            }
            if (oli.Co_ordination_Fee__c == null) {
                oli.Co_ordination_Fee__c = 0;
            }
        }
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Method to check if custom setting should allow Chatter post to be created when
     *                  an Opportunity Line Item is inserted.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, now checks DeactivateChatterPostSettings__c custom setting.
     *-------------------------------------------------------------------------------------------------------------------------*/  
    private static Boolean CanCreateChatterPostOnInsert() {
        Boolean create = false;
        
        if(chatterSettings != null) {
          if(!chatterSettings.Deactivate_non_Admin_Chatter_Insert_Post__c) {
            create = true;
          }
        
          if(IsUserAdmin && chatterSettings.Deactivate_All_Admin_Chatter_Posts__c)   {
            create = false;
          }
        }
        
        return create;
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Method to check if custom setting should allow Chatter post to be created when
     *                  an Opportunity Line Item is deleted.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, now checks DeactivateChatterPostSettings__c custom setting.
     *-------------------------------------------------------------------------------------------------------------------------*/  
    private static Boolean CanCreateChatterPostOnDelete() {
        Boolean create = false;
        
        if(chatterSettings != null) {
          if(!chatterSettings.Deactivate_non_Admin_Chatter_Delete_Post__c) {
            create = true;
          }
          
          if(IsUserAdmin && chatterSettings.Deactivate_All_Admin_Chatter_Posts__c) {
            create = false;
          }
        }
        
        return create;
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Method to check if custom setting should allow Chatter post to be created when
     *                  an Opportunity Line Item is updated.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, method created.
     * 10-Dec-2015, Mohsin Wadee, US-0775, now checks DeactivateChatterPostSettings__c custom setting.
     *-------------------------------------------------------------------------------------------------------------------------*/  
    private static Boolean CanCreateChatterPostOnUpdate() {   
        Boolean create = false;
        
        if(chatterSettings != null) {
          if(!chatterSettings.Deactivate_non_Admin_Chatter_Update_Post__c) {
            create = true;
          }
          
          if(IsUserAdmin && chatterSettings.Deactivate_All_Admin_Chatter_Posts__c) {
            create = false;
          }
        }
        
        return create;
    }
    
    /**
     * @Author          Mohsin Wadee
     * @Company:        Barclays Africa
     * @Description:    Property which checks if the current user is an administrator - by checking if the user's profile
     *                  name contains the word 'admin'.
     * @param:          None.
     * 
     * History:
     * 02-Dec-2015, Mohsin Wadee, US-0775, property created.
     *-------------------------------------------------------------------------------------------------------------------------*/    
    private static Boolean IsUserAdmin {
        get {
            String profileID = UserInfo.getProfileId();
            String profileName = [SELECT Name FROM Profile WHERE Id = :profileID].Name;
            
            if (profileName.toLowerCase().contains('admin')){
                return true;
            }
            else{
                return false;
            }
        }
    }
}