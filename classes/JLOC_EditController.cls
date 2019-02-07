/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a controller for JLOC_Edit page.
* @Date:        10/2015
* @ConstructorParam:    stdController - Standard Controller for "JLOC" object
* @TestClass:   ZZTEST_JLOC_EditController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 04/12/2015  Marta Malinowska   Saving Existing Facilities and Potential Future Opportunities fix 
* 24/03/2016  Marek Cech         added uploadConflictClearance and uploadPreScreening, constructor modification
* 14/04/2016  Nakedi Mashapa     added a field called RWA
* 18/08/2016  JW                 Full rewrite based on aligning with the new generated JLOC design
* 30/06/2017  Dino Scarcella	 Added ability to retrieve and save opportunity selections for a JLOC in DRAFT Status
* 14/07/2017  Mabhedle Tonga     Added ability to retrieve information from client plan to be visible of the jloc edit section when users are editing
* 25/07/2017  Dino Scarcella	 Disallow linking opportunity already linked to another JLOC and added table for open opportunities not linked to this JLOC
* 03/10/2017  Dino Scarcella	 Added quick save feature when navigating between tabs
*------------------------------------------------------------*/
public with sharing class JLOC_EditController {
    private static Integer softLockMinutes = 10;
    private static String STATUS_DRAFT = 'Draft';

    private JLOC__c jloc;

    public List<OpportunityLineItem> products { get; set; }
    public List<Opportunity> SelectedOpportunities{get;set;}
    public List<OpportunityTeamMember> teamMembers { get; set; }
    public List<Budget_Revenue__c> existingProducts { get; set; }
    public Client_Plan_Revenue_By_Product__c revByProduct { get; set; }
    
    
    public List<Financial_Information__c> financeList {get;set;}
    public List<Client_Plan_Facility__c> otherFacility {get;set;}
    public List<Country_Presence__c> otherCountry{get;set;}
    public List<Client_Plan_Borrowers_Guarantors__c> borrowersGuarantors{get;set;}
    public List<Budget_Revenue__c> jlocExistingProducts { get; set; }
    public List<Client_Plan_Security__c> absaSecurity{get;set;}
    public Budget_Revenue__c jlocExistingProductsTotals { get; set; }
    Public Opportunity jlocOpportunity{get;set;}
    
    public List<Attachment> attachments { get; set; }
    public Client_Plan__c clientPlan { get; set; }

    public Id attachIdToDelete { get; set; }
    public Map<Integer,String> tabs { get; set; }
    public Boolean softLockWarning {get;set;}
    
    public Boolean isOpportunityListEmpty { get; set; }
	public List<JLOC_CreateNewController.OpportunityWrapper> opportunityItems { get; set; }
    private Map<Id, Opportunity> opportunitiesMap;
    public List<Opportunity> jlocOpenOpportunitiesExcluded { get; set; }
    
    public ClientPlanController planController{get;set;}

    public JLOC_EditController(ApexPages.StandardController stdController) {
        //Tonga MM : Modified constructer to dynamically include fields onto controller everytime new fields are added
        List<String> fieldNames  = new List<String>();
        
        Map<String, Schema.SObjectField> schemaFieldMap = Schema.SObjectType.JLOC__c.fields.getMap();
        for (String fieldName: schemaFieldMap.keySet()) {
            fieldNames.add(fieldName);
        }
        if(!test.isRunningTest()) {
            stdController.addFields(fieldNames);
        }	

        jloc = (JLOC__c)stdController.getRecord();

        products = new List<OpportunityLineItem>();
        teamMembers = new List<OpportunityTeamMember>();
        existingProducts = new List<Budget_Revenue__c>();

        attachments = new List<Attachment>();

        if(String.isNotBlank(jloc.Id)){
            
            if(jloc.Date_of_last_JLOC__c==null){
                getLastJLOC(jloc.Organisation__c);
            }
            
            jlocOpportunity = JLOC_PrintViewController.getJLOCOpportunity(jloc.Id);
            for(OpportunityLineItem oli : JLOC_Utility.getProposedProducts(jloc.Id)) {
                products.add(oli);
            }

            for(OpportunityTeamMember otm : [
                    SELECT      Id, Opportunity.Name, User.Name, TeamMemberRole 
                    FROM        OpportunityTeamMember 
                    WHERE       Opportunity.JLOC__c = :jloc.Id
                    ORDER BY    Opportunity.Name
                ]) {
                teamMembers.add(otm);
            }

            this.queryAttachments();

            //Query ClientPlan
            if(jloc.Organisation__c != null) {
                List<Client_Plan__c> clientPlans = [SELECT Id, Org_Structure_Image_ID__c, Financial_Information_Image_ID__c, TFL__c, Relationship__c, Financial_Year_End__c, RoRWA_Existing__c, DG__c, LGD__c, Client_Overview__c, FinancialCommentary__c
                                                    FROM Client_Plan__c WHERE Relationship__c = :jloc.Organisation__c ORDER BY CreatedDate DESC];
                if(!clientPlans.isEmpty() && clientPlans.size() > 0) {
                    clientPlan = clientPlans[0];
                } else {
                    clientPlan = null;
                }

                if(clientPlan != null) {
                    existingProducts =JLOC_Utility.getExistingProduct(clientPlan.Id);
                }

                if(clientPlan != null) {
                    List<Client_Plan_Revenue_By_Product__c> revByProdList = JLOC_Utility.getRevenueByProduct(clientPlan.Id);

                    revByProduct = null;
                    if(!revByProdList.isEmpty()) {
                        revByProduct = revByProdList.get(0);
                    }
                    
                    //Tonga : MM add method calls to other functions to call client plan information, 
                    //this required we update existing classes in ordwer to reuse code
                    financeList =  ClientFinancialsController.queryFinancialInformation(clientPlan, 0, 5);
                    otherFacility = ClientFinancialsController.QueryOtherFacility(clientPlan);
                    otherCountry = ClientPresenceController.queryCountries(clientPlan.Id);
                    absaSecurity = ClientFinancialsController.queryAbsaSecurity(clientPlan.Relationship__c);
                    getBorrowersGuarantors(clientPlan.Relationship__c);
                    
                    ApexPages.currentPage().getParameters().put('planId',clientPlan.Id);
                    planController = new ClientPlanController();
                    
                }
                
                getOpportunityItems();
            }

            if(jloc.JLOC_Status__c != STATUS_DRAFT){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'JLOC has been submitted and is not editable any more.'));
            }
        }

        //Init tab structure
        tabs = new Map<Integer,String>();
        tabs.put(1, 'Executive Summary');
        tabs.put(2, 'Products');
        tabs.put(3, 'About');
        tabs.put(4, 'Key Credit Risks and Mitigants');
        tabs.put(5, 'Underwrite or distribution');
        tabs.put(6, 'Declaration');
        tabs.put(7, 'Appendix');
        tabs.put(8, 'Attachments');
        if (jloc.JLOC_Status__c == STATUS_DRAFT) tabs.put(9, 'Link Opportunities');
    }

    //If another user has opened this JLOC for editing in the last X minutes display a warning
    public PageReference checkSoftLock() {
        System.debug('### checkSoftLock [LastBy: ' + jloc.Last_Opened_For_Editing_By__c + ', LastAt: ' + jloc.Last_Opened_For_Editing_At__c + ']');
        System.debug('### checkSoftLock [Current: ' + UserInfo.getUserId() + ', Now: ' + Datetime.now() + ']');
        softLockWarning = false;

        //No one has opened this recently or it has already been saved
        if(jloc.Last_Opened_For_Editing_By__c == null && jloc.Last_Opened_For_Editing_At__c == null) {
            //Set the values
            setSoftLock();
        } else if(jloc.Last_Opened_For_Editing_By__c != null && jloc.Last_Opened_For_Editing_At__c != null) {
            if(jloc.Last_Opened_For_Editing_By__c != UserInfo.getUserId()) {
                //Someone has opened it and it's not the current user - check how long ago this was using epoch

                Decimal minutes = ((Datetime.now().getTime())/1000/60) - ((jloc.Last_Opened_For_Editing_At__c.getTime())/1000/60);
                System.debug('### checkSoftLock [minutes: ' + minutes + ']');

                if(minutes <= softLockMinutes) {
                    softLockWarning = true;
                } else {
                    //It's been too long ago - assume this user has abondonded the session
                    setSoftLock();
                }
            }
        }

        System.debug('### checkSoftLock determines: ' + softLockWarning);

        if(softLockWarning) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Warning, 'This JLOC has been opened for Editing recently by ' + jloc.Last_Opened_For_Editing_By__r.Name));
        }

        return null;
    }

    private void setSoftLock() {
        jloc.Last_Opened_For_Editing_By__c = UserInfo.getUserId();
        jloc.Last_Opened_For_Editing_At__c = Datetime.now();

        try {
            UPDATE jloc;
        } catch(Exception e) {
            System.debug('Failed to update JLOC with soft lock timestamps [msg: ' + e.getMessage() + ']');
        }
    }

    private void queryAttachments() {
        attachments = [
            SELECT  Id, ContentType, Name
            FROM    Attachment 
            WHERE   ParentId = :jloc.Id
                    AND Id != :jloc.Pricing_and_Returns_Document_ID__c
                    AND Id != :jloc.Ancillary_Calculation_Document_ID__c
                    AND Id != :jloc.JLOC_Document_ID__c
        ];
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to save JLOC and related Potential Future Opportunities and Existing Facilities.
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference save() {
        try {
            //Clear softlock values
            jloc.Last_Opened_For_Editing_At__c = null;
            jloc.Last_Opened_For_Editing_By__c = null;

            //Save
            UPDATE jloc;
            //Save Opportunities Selected
            if (!saveOpportunityItems()) return null;
        } catch(DmlException ex) {
            ApexPages.addMessages(ex);
            System.debug(ex);
            return null;
        }

        return new PageReference('/' + jloc.Id + '?saved=true');
    }

    /**
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: This method is used to quick save a JLOC
    * @param        None
    * @Returns:     NULL (we don't want to return to view page when quicksaving)
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference quicksave() {
        try {
			//Save
            UPDATE jloc;
            //Save Opportunities Selected
            if (!saveOpportunityItems()) return null;
        } catch(DmlException ex) {
            ApexPages.addMessages(ex);System.debug(ex);return null;
        }
		return null;        
    }
    
    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to cancel changes and redirect to view page.
    * @param        None
    * @Returns:     view page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference cancel() {
        return new PageReference('/' + jloc.Id);
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to save changes and redirect to adding attachments page.
    * @param        None
    * @Returns:     standard page for adding attachments
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference addAttachment() {
        save();
        PageReference pageRef = new PageReference('/p/attach/NoteAttach');
        pageRef.getParameters().put('pid', jloc.Id);
        pageRef.getParameters().put('retURL', '/apex/JLOC_Edit?id=' + jloc.Id + '#/8');
        return pageRef;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to save changes and redirect to upload document page.
    * @param        None
    * @Returns:     standard page for adding attachments
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference uploadPricingAndReturnsDocument() {
        save();
        PageReference pageRef = Page.JLOC_UploadDocument;
        pageRef.getParameters().put('id', jloc.Id);
        pageRef.getParameters().put('fileType', 'PricingAndReturns');
        pageRef.getParameters().put('anchor','/7');
        return pageRef;
    }

    public PageReference uploadAncillaryCalculationDocument() {
        save();
        PageReference pageRef = Page.JLOC_UploadDocument;
        pageRef.getParameters().put('id', jloc.Id);
        pageRef.getParameters().put('fileType', 'AncillaryCalculation');
        pageRef.getParameters().put('anchor','/7');
        return pageRef;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to delete attachment.
    * @param        None
    * @Returns:     edit page for JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference deleteAttachment() {
        try {
            DELETE [
                SELECT  Id 
                FROM    Attachment 
                WHERE   Id = :attachIdToDelete
            ];
        } catch(Exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(0)));
            return null;
        }

        //Re-query all attachments
        this.queryAttachments();

        return null;
    }
    
    /**
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: This method is used to query all open Opportunities for selected Organisation
    * @param        None
    * @Returns:     the list of open Opportunities
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public void getOpportunityItems() {
    	opportunityItems = new List<JLOC_CreateNewController.OpportunityWrapper>();
        opportunitiesMap = new Map<Id, Opportunity>();
        SelectedOpportunities = new List<Opportunity>();
        List<Opportunity> allOpenRelationshipOpportunities;
		jlocOpenOpportunitiesExcluded = new List<Opportunity>();
       
        allOpenRelationshipOpportunities = [
            SELECT  Id, Name,Related_Group_Client__c, StageName, CloseDate, JLOC__c, Probability, RecordType.Name, 
                	Annualised_Income__c,OwnerID,Owner.Name, Total_Balance_Facility_Size__c, (SELECT Id, Product_Name__c, Product_Level_3__c FROM OpportunityLineItems)
            FROM    Opportunity 
            WHERE   (AccountId = :jloc.Organisation__c OR Related_Group_Client__c = :jloc.Organisation__c
            		 OR Account_Name__c = :jloc.Organisation__c
                    )
            AND IsClosed = false
            ORDER BY CloseDate ASC
        ];
       
        

		for(Opportunity opp : allOpenRelationshipOpportunities) {
            System.debug('### Opp [Name: ' + opp.Name + '] being inspected');

            Boolean opportunityIsSelectable = true;
            Boolean opportunitySelected = false;

            //Exclude opportunities that have no OppLineItems associated with it
            if(opp.OpportunityLineItems.size() == 0) {
                System.debug('### Opp [Name: ' + opp.Name + '] skipped: no OpportunityLineItems');
                opportunityIsSelectable = false;
            } else {
                //Exclude opportunities that have OppLineItems associated with it for a lvl1 or lvl2 product (and no lvl3) or already linked to another JLOC
                for(OpportunityLineItem oli : opp.OpportunityLineItems) {
                    if(oli.Product_Level_3__c == null || (opp.JLOC__c != null && jloc.Id != opp.JLOC__c)) {
                        System.debug('### Opp [Name: ' + opp.Name + '] skipped: found OpportunityLineItem with no lvl3 product or Opportunity already allocated to another JLOC');
                        opportunityIsSelectable = false;
                        break;
                    }
                }
            }

            if (jloc.Id == opp.JLOC__c){
              opportunitySelected = true;
                SelectedOpportunities.add(opp);  
            }
            
            opportunityItems.add(new JLOC_CreateNewController.OpportunityWrapper(opportunityIsSelectable, opportunitySelected, opp));
            opportunitiesMap.put(opp.Id, opp);
            
            //create a list of all other opportunities (opportunities not linked to this JLOC)
            if (opp.JLOC__c == null || jloc.Id != opp.JLOC__c) jlocOpenOpportunitiesExcluded.add(opp);
    	}

		if(opportunityItems.isEmpty()) {
			isOpportunityListEmpty = true;
		} else {
			isOpportunityListEmpty = false;
		}
	}
    
    /**
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: This method is used to save selected Opportunities for this JLOC
    * @param        None
    * @Returns:     Boolean if it saved or not
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public Boolean saveOpportunityItems() {
    	Boolean isOpportunitySelected = false;
        Boolean isPrivateOpportunitySelected = false;
        for(JLOC_CreateNewController.OpportunityWrapper oppWrapp : opportunityItems) {
        	if(oppWrapp.isSelected) {
        		isOpportunitySelected = true;
        		if(oppWrapp.opportunity.RecordType.Name == 'Private opportunity') isPrivateOpportunitySelected = true;
        	}
        }
        
        if(isOpportunitySelected && !(isPrivateOpportunitySelected && jloc.Is_this_a_closed_JLOC__c == false)) {
            List<Opportunity> opportunitiesToUpd = new List<Opportunity>();
            for(JLOC_CreateNewController.OpportunityWrapper oppWrapp : opportunityItems) {
                // Only change the JLOC field on the opportunity if it's selectable and it has been changed
                if(oppWrapp.isSelectable && oppWrapp.isSelected != oppWrapp.isSelectedOriginalValue) {
                    Id JlocId = (oppWrapp.isSelected) ? jloc.Id : NULL;
                    opportunitiesToUpd.add(new Opportunity(Id=oppWrapp.opportunity.Id, JLOC__c = JlocId));
                }
            }
        	try {
                // Only update if we have opportunities to update
        		if (opportunitiesToUpd.size() > 0) UPDATE opportunitiesToUpd;
        	} catch(DmlException ex) {
                for(Integer i=0; i < ex.getNumDml(); i++) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, opportunitiesMap.get(ex.getDmlId(i)).Name+': '+ex.getDmlMessage(i)));
                }
                return false;
        	}
        } else {
        	if (!isOpportunitySelected) Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_AtLeastOneOpportunityForJLOC));
            if (isPrivateOpportunitySelected && jloc.Is_this_a_closed_JLOC__c == false) Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_JLOCPrivateOpportunitySelected));
            return false;
        }
        return true;
    }
    public List<Client_Plan_Borrowers_Guarantors__c> borrowers{get;set;}
    public List<Client_Plan_Borrowers_Guarantors__c> guarantors{get;set;}
    
    public void getLastJLOC(String relationShipID)
    {
         
        if(String.isNotBlank(relationShipID))
        {
         	List<JLOC__c> jlocList = [select ID,Date_of_last_JLOC__c,Date__c 
                                      from JLOC__c 
                                      where Organisation__c =:relationShipID
                                      and JLOC_Status__c =:JLOC_ViewController.STATUS_SUBMITTED_TO_SECRETARY
                                      order by Date__c]; 
            
            
            if(jlocList.size()>0)
            {
                JLOC__c lastJoc = jlocList.get(jlocList.size()-1);
                jloc.Date_of_last_JLOC__c = lastJoc.Date__c;
                
            }
        }
    }
    public void getBorrowersGuarantors(ID relationShipID)
    {
        borrowers = new List<Client_Plan_Borrowers_Guarantors__c>();
        List<Client_Plan_Borrowers_Guarantors__c> borrowersGuarantors = new List<Client_Plan_Borrowers_Guarantors__c>();
        guarantors = new List<Client_Plan_Borrowers_Guarantors__c>();
        
        if(relationshipID != null) {
            borrowersGuarantors = [
                SELECT    Id, Type__c, Value__c
                FROM      Client_Plan_Borrowers_Guarantors__c 
                WHERE     Relationship__c = :relationshipID
                ORDER BY  Value__c
            ];
            
            if(!borrowersGuarantors.isEmpty()) {
                for(Client_Plan_Borrowers_Guarantors__c bgItem : borrowersGuarantors) {
                    if(bgItem.Type__c == 'Borrower') {
                        borrowers.add(bgItem);
                    } else if(bgItem.Type__c == 'Guarantor') {
                        guarantors.add(bgItem);
                    }
                }
            }
        }
    }
    
    public PageReference uploadStressCaseImage() {
        
        if(jloc.Forecast_Not_Available__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.lbl_NotApplicable));
            return null;
        }
        save();
        PageReference pageRef = Page.JLOC_UploadDocument;
        pageRef.getParameters().put('id', jloc.Id);
        pageRef.getParameters().put('fileType', 'StressCase');
        pageRef.getParameters().put('anchor','/3');
        return pageRef;
    }
    public PageReference uploadBankCaseImage() {
         if(jloc.Forecast_Not_Available__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.lbl_NotApplicable));
            return null;
        }
        save();
        PageReference pageRef = Page.JLOC_UploadDocument;
        pageRef.getParameters().put('id', jloc.Id);
        pageRef.getParameters().put('fileType', 'BankCase');
        pageRef.getParameters().put('anchor','/3');
        return pageRef;
    }
    public PageReference uploadManagementCaseImage() {
         if(jloc.Forecast_Not_Available__c)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.lbl_NotApplicable));
            return null;
        }
        save();
        PageReference pageRef = Page.JLOC_UploadDocument;
        pageRef.getParameters().put('id', jloc.Id);
        pageRef.getParameters().put('fileType', 'ManagementCase');
        pageRef.getParameters().put('anchor','/3');
        return pageRef;
    }
    
    public PageReference getPageToRedirect(String anchor)
    {
        PageReference pageRef = new ApexPages.StandardController(jloc).edit();
        pageRef.setAnchor('/' + anchor);
        pageRef.setRedirect(true);
        return pageRef;
    }
    public PageReference removeStressCase()
    {
        JLOC_UploadDocumentController.deletePreviousVersion(jloc.Stress_Case_ID__c);
        jloc.Stress_Case_ID__c=null;
		save();
        return getPageToRedirect('3');
    }
    public PageReference removeBankCase()
    {
       JLOC_UploadDocumentController.deletePreviousVersion(jloc.Banker_Case_ID__c);
        jloc.Banker_Case_ID__c=null;
		save();
        return getPageToRedirect('3');
    }
    public PageReference removeManagementCase()
    {
       JLOC_UploadDocumentController.deletePreviousVersion(jloc.Management_Case_ID__c);
        jloc.Management_Case_ID__c=null;
		save();
        return getPageToRedirect('3');
    }
    public PageReference removePricingAndReturnsDocument()
    {
        JLOC_UploadDocumentController.deletePreviousVersion(jloc.Pricing_and_Returns_Document_ID__c);
        jloc.Pricing_and_Returns_Document_ID__c=null;
		save();
        return getPageToRedirect('7');
    }
    public PageReference displayMessage()
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.lbl_ForecastWarning));
        return null;
    }
}