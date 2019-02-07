/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used as a controller for JLOC_CreateNew page.
* @Date:        10/2015
* @ConstructorParam:    stdController - Standard Controller for "JLOC" object
* @TestClass:   ZZTEST_JLOC_CreateNewController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 2017.06.28  Dino Scarcella	 Added functionality to clone JLOC
* 2017.07.25  Dino Scarcella	 Disallow linking opportunity already linked to another JLOC
*------------------------------------------------------------*/
public with sharing class JLOC_CreateNewController {
    private static String YES = 'Yes';
    private static String NO = 'No';
	private static String STATUS_DRAFT = 'Draft';
	private JLOC__c jloc;

	public Boolean isOrganisationSelected { get; set; }
	public Boolean isOpportunityListEmpty { get; set; }
	public List<OpportunityWrapper> opportunityItems { get; set; }
    private Map<Id, Opportunity> opportunitiesMap;
    public String isThisClosedJLOC { get; set; }
    private String JLOCToCloneId;
    private Account ParentAccount{get;set;}

    public JLOC_CreateNewController(ApexPages.StandardController stdController) {
        jloc = (JLOC__c)stdController.getRecord(); 	
        
        //Check if JLOCIdToClone parameter is populated and retrieve details to clone for this new JLOC
        if(ApexPages.currentPage().getParameters().get('JLOCIdToClone') != null) {
            JLOC__c JLOCToClone;
            JLOCToCloneId = ApexPages.currentPage().getParameters().get('JLOCIdToClone');
            JLOCToClone = getJLOCToClone(JLOCToCloneId);
            if (JLOCToClone != null) jloc = JLOCToClone.clone(false, false, false, false);
        }
        
		if(String.isNotBlank(jloc.Organisation__c)) {
			isOrganisationSelected = true;
            //Tonga MM : get parent account upon created, recordtype is required on creation
            ParentAccount = new Account();
            ParentAccount = [select RecordTypeID from account where ID =:jloc.Organisation__c];
			getOpportunityItems();
		} else {
			isOrganisationSelected = false;
		}
        
	}

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to query all open Opportunities for selected Organisation.
    * @param        None
    * @Returns:     current page with list of open Opportunities
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
	public PageReference next() {
        if(String.isNotBlank(jloc.Organisation__c)) {
        	isOrganisationSelected = true;
        	getOpportunityItems();
        }
        
        return null;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to save new JLOC.
    * @param        None
    * @Returns:     the edit page of created JLOC
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public PageReference save() {
        jloc.JLOC_Status__c = STATUS_DRAFT;

        if(String.isNotBlank(isThisClosedJLOC)){
            if(isThisClosedJLOC == YES) {
                jloc.Is_this_a_closed_JLOC__c = true;
            }
            if(isThisClosedJLOC == NO) {
                jloc.Is_this_a_closed_JLOC__c = false;
            }
        } else {
            
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_IsThisAClosedJLOCRequired));
            return null;
        }
        
        Boolean isOpportunitySelected = false;
        Boolean isPrivateOpportunitySelected = false;
        for(OpportunityWrapper oppWrapp : opportunityItems) {
        	if(oppWrapp.isSelected) {
        		isOpportunitySelected = true;
        		if(oppWrapp.opportunity.RecordType.Name == 'Private opportunity') isPrivateOpportunitySelected = true;
        	}
        }
        
        if (isPrivateOpportunitySelected && jloc.Is_this_a_closed_JLOC__c == false) {
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_JLOCPrivateOpportunitySelected));
            return null;
        }
        
        if(isOpportunitySelected) {
            Savepoint sp = Database.setSavepoint();
        	try {
        		INSERT jloc;
        	} catch(DmlException ex) {
                System.debug(' ex '+ex.getMessage());
        		Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getDmlMessage(0)));
        		return null;
        	}

            List<Opportunity> opportunitiesToUpd = new List<Opportunity>();
            for(OpportunityWrapper oppWrapp : opportunityItems) {
                if(oppWrapp.isSelectable && oppWrapp.isSelected) {
                    opportunitiesToUpd.add(new Opportunity(Id=oppWrapp.opportunity.Id, JLOC__c = jloc.Id));
                }
            }
        	try {
        		UPDATE opportunitiesToUpd;
        	} catch(DmlException ex) {
                System.debug(' ex '+ex.getMessage());
                Database.rollback(sp);
                for(Integer i=0; i < ex.getNumDml(); i++) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, opportunitiesMap.get(ex.getDmlId(i)).Name+': '+ex.getDmlMessage(i)));
                }
        		return null;
        	}

            return new ApexPages.StandardController(jloc).edit();
        } else {
            system.debug('Error');
        	Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_AtLeastOneOpportunityForJLOC));
        	return null;
        }
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to query all open Opportunities for selected Organisation
    * @param        None
    * @Returns:     the list of open Opportunities
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public void getOpportunityItems() {
    	opportunityItems = new List<OpportunityWrapper>();
        opportunitiesMap = new Map<Id, Opportunity>();
        List<Opportunity> allOpenRelationshipOpportunities;
         allOpenRelationshipOpportunities= [
            SELECT  Id, Name, StageName,Related_Group_Client__r.name, CloseDate, JLOC__c, (SELECT Id, Product_Level_3__c FROM OpportunityLineItems), RecordType.Name
            FROM    Opportunity 
            WHERE   (AccountId = :jloc.Organisation__c OR Related_Group_Client__c = :jloc.Organisation__c
                    OR Account_Name__c = :jloc.Organisation__c)
            AND IsClosed = false
       
        ];
       	for(Opportunity opp : allOpenRelationshipOpportunities) {
            System.debug('### Opp [Name: ' + opp.Name + '] being inspected');

            Boolean opportunityIsSelectable = true;

            //Exclude opportunities that have no OppLineItems associated with it
            if(opp.OpportunityLineItems.size() == 0) {
                System.debug('### Opp [Name: ' + opp.Name + '] skipped: no OpportunityLineItems');
                opportunityIsSelectable = false;
            } else {
                //Exclude opportunities that have OppLineItems associated with it for a lvl1 or lvl2 product (and no lvl3)
                for(OpportunityLineItem oli : opp.OpportunityLineItems) {
                    if(oli.Product_Level_3__c == null || opp.JLOC__c != null) {
                        System.debug('### Opp [Name: ' + opp.Name + '] skipped: found OpportunityLineItem with no lvl3 product or Opportunity already allocated to JLOC');
                        opportunityIsSelectable = false;
                        break;
                    }
                }
            }

            System.debug('### Opp [Name: ' + opp.Name + '] selectable [' + opportunityIsSelectable + ']');
            opportunityItems.add(new OpportunityWrapper(opportunityIsSelectable, false, opp));
            opportunitiesMap.put(opp.Id, opp);
    	}

		if(opportunityItems.isEmpty()) {
			isOpportunityListEmpty = true;
			Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, System.Label.errMsg_NoOpportunityForOrganisation));
		} else {
			isOpportunityListEmpty = false;
		}
	}

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to create select options list for "Is this a Closed JLOC?"
    * @param        None
    * @Returns:     the list of select options
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public List<SelectOption> getIsThisClosedJLOCList() {
        List<SelectOption> isThisClosedJLOCList = new List<SelectOption>();
        isThisClosedJLOCList.add(new SelectOption(YES, YES));
        isThisClosedJLOCList.add(new SelectOption(NO, NO));
        return isThisClosedJLOCList;
    }

    /**
    * @Author:      Dino Scarcella
    * @Company:     Absa Capital
    * @Description: This method is used to Query all the fields required to clone a JLOC
    * @param        JLOCIdToClone (the id of the JLOC we are cloning)
    * @Returns:     the JLOC to clone
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public JLOC__c getJLOCToClone(String JLOCIdToClone) {
        List<JLOC__c> jloclist = [SELECT Organisation__c, Compliance__c, Date__c, Date_of_last_JLOC__c, Reason_for_JLOC__c, Future_RoRWA__c,
									Total_RoRWA__c, Total_Fin_Limits_Proposed__c, Status__c, CLGD_Consumption__c, 
                           			Brief_Transaction_Description_Without__c, Transaction_Structure__c, Recommendation__c,
									Client_Revenue_History_and_Projections__c, Key_Risks__c, Key_Mitigants__c, Syndicate__c,
									Deal_Presented_To_Deal_Forum__c, Go_Approval_From_Deal_Forum_Quorum__c, 
                           			Approved_By_Financial_Crime_Compliance__c, Deal_Cleared_For_Conflicts__c, 
                           			Affected_of_Exchange_Control_Regulation__c, Securitized_Assets_Liquidity_Facility__c,
									Absa_Hold_5_of_the_Net_Economic_Value__c, Transferee_Options_Discussed__c,
                           			Discussed_with_RM_re_FX_IRD_other_op__c, Discussed_with_BBT_re_operating_product__c,
									Sub_investment_grade_credit__c, Market_to_bookrun_this_facility__c, 
                           			Syn_team_advised_on_Facility_Syndicati__c, Volcker_Rule_Guidance_Document_Completed__c,
									Discussed_with_Credit__c, Credit_Appetite_Comment__c, Asset_Hub_Framework_considered__c,
									Asset_Hub_Comment__c, Deal_Team_Polices_Confirmation__c, Pricing_and_Returns_Document_ID__c,
									Pricing_Justification__c, Guidelines_Mandate_and_Scale__c, Guidelines_CLGD__c, 
                           			Guidelines_MEG__c, Ancillary_Calculation_Document_ID__c, ReputationalMatters__c
							FROM JLOC__c
							WHERE Id =: JLOCToCloneId
							LIMIT 1];
        if (!jloclist.isEmpty()) return jloclist[0]; else return null;
    }
    
	public class OpportunityWrapper {
        public Boolean isSelectable { get; set; }
		public Boolean isSelected { get; set; }
        public Boolean isSelectedOriginalValue { get; set; }
		public Opportunity opportunity { get; set; }

		public OpportunityWrapper(Boolean isSelectable, Boolean isSelected, Opportunity opportunity) {
            this.isSelectable = isSelectable;
			this.isSelected = isSelected;
            this.isSelectedOriginalValue = isSelected;
			this.opportunity = opportunity;
		}
	}
}