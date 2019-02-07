/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientBudgetRevenue VF page.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientBudgetRevenue  
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 12.2.2016   Svata Sejkora       Adding classes and variables for product edit functionality
* 30.5.2017	  Dino Scarcella      Changed getOptyStageOptions to get the CIB opp stages
* 13.6.2017	  Dino Scarcella	  Add option to add country on opportunities created on the Plan Tab
*------------------------------------------------------------*/

public without sharing class ClientPlanController extends ClientPlanUtils{

	public Boolean planLoaded {get;set;}
    
    
	public List<Budget_Revenue__c> brs {get;set;}
	public List<Potential_Opportunity__c> unqOptys {get;set;}
	public List<Opportunity> pipelineOptys {get;set;}

	//pot opty variables
	public String   potOptyId {get;set;}
	public String   potOptyName {get;set;}
	public Long     closeDateMillis {get;set;}
	public String   potOptyProductLevel {get;set;}
	public String   potOptyProductId {get;set;}
	public String   potOptyStage {get;set;}
    public String   potOptyCountry {get;set;}
	public String   potOptyType {get;set;}

	private String  planId;
	public String   managedUnqOptyId {get;set;}

	//Existing product variables
	public String   existingRecordId {get;set;}
	public String   existingProductId {get;set;}
	public String   existingProductName {get;set;}
	public String   existingProductCountry {get;set;}
	public Date     existingProductMaturityDate {get;set;}
	public Long     existingProductMaturityDateMillis {get;set;}
	public Decimal  existingProductLgd {get;set;}
	public Decimal  existingProductDg {get;set;}
	public Long     existingProductLimit {get;set;}
	public Long     existingProductUtilisation {get;set;}
	public String   existingProductCurrency {get;set;}
	public Decimal  existingProductMargin {get;set;}
	public Decimal  existingProductFtp {get;set;}
	public Decimal  existingProductArrfee {get;set;}
	public Decimal  existingProductComfee {get;set;}
	public Decimal  existingProductRorwa {get;set;}

	//Save single item in Existing Products
	public String   budgetRevenueId {get;set;}
	public String   productionFieldName {get;set;}
	public String   productionValue {get;set;}

    //Existing SDS Facility variables
    public String   selectedFacilitySDS{get;set;}
    public String   selectedFacilitySDSLabel{get;set;}
    
    //Manual Facility variables
    public String	facilityId {get;set;}
	public Long     facilityExpiryDateMillis {get;set;}
    public String   facilityCurrency{get;set;}
    public Long     facilityUtilizationAmount {get;set;}
    public Long     facilityAmount {get;set;}
    public String   facilityProductDescription{get;set;}
    public Decimal  facilityLGD{get;set;}
    public Decimal grossMargin{get;set;}
    public Decimal ftpBPS{get;set;}
    public Decimal netMargin{get;set;}
    public Decimal arrangFee{get;set;}
    public Decimal comFees{get;set;}
    public Decimal roRwa{get;set;}
    public String facilityCountry{get;set;}
    
	private static final String countriesPicklistJson = JsonUtils.returnJSONString('Picklists', 'CountryPresenceJSON', 'txt', 'Picklists');
	private static Map<String, String> countriesPicklistMap = JsonUtils.returnPicklistMap(countriesPicklistJson);
	private static String countriesJson = Json.serializePretty(countriesPicklistMap.keySet());

	@testVisible
	private Client_Plan__c plan;
	
	@testVisible
	private String errorMessage;
	
	private static final String CLOSED_WON = 'Closed Won';
	private static final String CLOSED_LOST = 'Closed Lost';
	private static final String ON_RECORD_WITH_ID = 'on record with id: ';

	public ClientPlanController() {
        super(ApexPages.currentPage().getParameters().get('planId'),'planId');
		planId = ApexPages.currentPage().getParameters().get('planId');
		if(String.isEmpty(planId)) {
			planId = ApexPages.currentPage().getParameters().get('id');
		}
		if(!String.isEmpty(planId)) {
			queryPlan();
			if(planLoaded) {
				queryBudgetRevenues();
				prepareTotalsOfBudgetRevenues();
				queryUnqOptys();
				queryPipelineOptys();
                queryACMFacilities();
			}
		}
	}

	public static String getCountriesJson() {
		return countriesJson;
	}
	
	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     saves changes to budget revenue object
		* @Returns:         PageReference - null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public PageReference saveProductionValue() {
		for(Budget_Revenue__c br: brs) {
			if(br.Id == budgetRevenueId) {
				try {
					br.put(productionFieldName, Decimal.valueOf(productionValue));
					UPDATE br;
				} catch(Exception e) {
					System.debug(e);
					setErrorMessage(Label.errMsg_ErrorDuringSaving);
				}
			}
		}

		brs.remove(brs.size() - 1);
		prepareTotalsOfBudgetRevenues();
		return null;
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     modifies potential opportunity
		* @Returns:         PageReference - null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public PageReference modifyPotOpty() {
		System.debug('### modifyPotOpty called with [potOptyId: ' + potOptyId + ', potOptyProductLevel: ' + potOptyProductLevel + ', potOptyProductId: ' + potOptyProductId + ']');

		if(potOptyId == '') {
			addPotOpty();
		} else {
			editPotOpty();
		}

		return null;
	}

	/**
		* @Author:          Svata Sejkora
		* @Company:         Deloitte
		* @Description:     modifies product
		* @Returns:         PageReference - null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public PageReference modifyProduct() {
		if(String.isEmpty(existingRecordId)) {
			addProduct();
		} else {
			editProduct();
		}
		updateTFL();
		return null;
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     modifies opportunity
		* @Returns:         PageReference - null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public PageReference modifyOpty() {
		Opportunity opty = new Opportunity();
		opty.Name = potOptyName;

		if(closeDateMillis != 0) {
			opty.CloseDate = DateTime.newInstance(closeDateMillis).date();
		}
		opty.StageName = potOptyStage;
        opty.Opportunity_Country__c = potOptyCountry;
		opty.AccountId = plan.Relationship__c;

		try {
			INSERT opty;
		} catch(Exception e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringAddingOpty);
		}

		queryPipelineOptys();
		return null;
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     prepares select options of stage field
		* @Returns:         List<SelectOption> - prepared list of select options
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public List<SelectOption> getPotOptyStageOptions() {
		Schema.DescribeFieldResult f = Potential_Opportunity__c.Stage__c.getDescribe();
		return prepareSelectOptionsFromDescribeFieldResult(f);
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     prepares select options of type field
		* @Returns:         List<SelectOption> - prepared list of select options
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public List<SelectOption> getPotOptyTypeOptions() {
		Schema.DescribeFieldResult f = Potential_Opportunity__c.Type__c.getDescribe();
		return prepareSelectOptionsFromDescribeFieldResult(f);
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     prepares select options of opportunity stage field
		* @Returns:         List<SelectOption> - prepared list of select options
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public List<SelectOption> getOptyStageOptions() {
		Schema.DescribeFieldResult f = Opportunity.StageName.getDescribe();
		List<Schema.PicklistEntry> p = f.getPicklistValues();

		List<SelectOption> options = new List<SelectOption>();
		for(Schema.PicklistEntry e : p) {
        	if (e.getLabel() == 'Opportunity Identified' || e.getLabel() == 'Client Engaged' || e.getLabel() == 'Needs Established' || e.getLabel() == 'Initial Solution Proposed' || e.getLabel() == 'Credit Case Submitted')
                options.add(new SelectOption(e.getLabel(), e.getValue()));
        }
		return options;
	}
      
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     prepares select options of opportunity country field
		* @Returns:         List<SelectOption> - prepared list of select options
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public List<SelectOption> getOptyCountryOptions() {
		Schema.DescribeFieldResult f = Opportunity.Opportunity_Country__c.getDescribe();
        List<SelectOption> opp_countries = new List<SelectOption>();
        opp_countries.add(new SelectOption('',''));
        opp_countries.addAll(prepareSelectOptionsFromDescribeFieldResult(f));
		return opp_countries;
	}
    
	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     adds potential opportunity
		* @Returns:         void
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private void addPotOpty() {
		Potential_Opportunity__c opty = new Potential_Opportunity__c();
		opty.Name = potOptyName;

		if(closeDateMillis != 0) {
			opty.Close_Date__c = DateTime.newInstance(closeDateMillis).date();
		}

		//Determine product-levels
		if(String.isNotEmpty(potOptyProductLevel) || String.isNotEmpty(potOptyProductId)) {
			Integer potOptyProductLevelInt = Integer.valueOf(potOptyProductLevel);

			String newProductLevel1 = null;
			String newProductLevel2 = null;
			String newProductLevel3 = null;

			ProductSelection_Helper psHelper = new ProductSelection_Helper();

			if(potOptyProductLevelInt == 1) {
				newProductLevel1 = potOptyProductId;
			} else if(potOptyProductLevelInt == 2) {
				newProductLevel2 = potOptyProductId;
				newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
			} else if(potOptyProductLevelInt == 3) {
				newProductLevel3 = potOptyProductId;
				newProductLevel2 = psHelper.getProductParent(3, newProductLevel3);
				newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
			}

			opty.Product_Level_1__c = newProductLevel1;
			opty.Product_Level_2__c = newProductLevel2;
			opty.Product_Level_3__c = newProductLevel3;
		}

		opty.Stage__c = potOptyStage;
		opty.Type__c = potOptyType;
		opty.Client_Plan__c = planId;

		try {
			INSERT opty;
		} catch(Exception e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringAddingPotOpty);
		}

		queryUnqOptys();
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     converts potential opportunity to standard opportunity
		* @Returns:         PageReference
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public PageReference convertUnqOpty() {
		System.debug('### convertUnqOpty START');
		Potential_Opportunity__c uo = getUnqOptyById(managedUnqOptyId);

		if(uo == null) {
			setErrorMessage(Label.errMsg_ErrorConvertingOpportunity);
			return null;
		}

		Boolean isConvertible = checkUnqOptyConvertibility(uo);
		if(!isConvertible) {
			setErrorMessage(Label.errMsg_OptyNotConvertible);
			return null;
		}

		System.debug('### convertUnqOpty: [uo: ' + uo + ']');

		Opportunity opp = new Opportunity();
		opp.Name 		= uo.Name;
		opp.CloseDate 	= uo.Close_Date__c;
		opp.Type 		= uo.Type__c;
		opp.StageName 	= 'Opportunity Identified';
		opp.AccountId 	= plan.Relationship__c;
		//Not moving products accross???

		System.debug('### convertUnqOpty: [opp: ' + opp + ']');

		Savepoint sp = Database.setSavepoint();
		try {
			INSERT opp;
		} catch(DmlException e) {
			setErrorMessage(Label.errMsg_ErrorConvertingOpportunity + processDmlException(e));
			System.debug(e);
			return null;
		}

		uo.IsConverted__c = true;
		uo.Opportunity__c = opp.Id;
		try {
			UPDATE uo;
		} catch (DmlException e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorConvertingOpportunity);
			Database.rollback(sp);
			uo.Opportunity__c = null;
		}

		queryUnqOptys();
		queryPipelineOptys();
		return null;
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     processes DmlException for showing user-friendly error message
		* @Param:           DmlException  - exception to process
		* @Returns:         String - user-friendly error message
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private String processDmlException(DmlException e) {
		String message = ' ';
		for(Integer i = 0; i < e.getNumDml(); i++) {
			String currentMessage = e.getDmlMessage(i);
			if(currentMessage.contains(ON_RECORD_WITH_ID)) {
				String[] split = currentMessage.split(ON_RECORD_WITH_ID);
				message += Label.msg_DuplicateRecordFound + ' <a href="/' + split[1] + '" target="_blank">here</a>.';
			} else {
				message += ' ';
				message += currentMessage;
			}
		}
		return message;
	}    

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     returns potential opportunity by Id in parameter, null if not found
		* @Returns:         Potential_Opportunity__c
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private Potential_Opportunity__c getUnqOptyById(String optyId) {
		for(Potential_Opportunity__c opty: unqOptys) {
			if(opty.Id == optyId) {
				return opty;
			}
		}

		return null;
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     checks whether potential opportunity can be converted
		* @Param:           Potential_Opportunity__c - opportunity co check
		* @Returns:         Boolean
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	@testVisible
	private Boolean checkUnqOptyConvertibility(Potential_Opportunity__c uo) {
		if(uo.Name == null || uo.Name == '') {
			return false;
		} else if(uo.Close_Date__c == null) {
			return false;
		} else {
			return true;
		}
	}    

	public PageReference deletePotOpty() {
		try {
			for(Potential_Opportunity__c opty : unqOptys) {
				if(opty.Id == potOptyId) {
					DELETE opty;
					break;
				}
			}
		} catch(Exception e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringDeleting);
		}

		queryUnqOptys();
		return null;
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     potential opportunity editation
		* @Returns:         void
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private void editPotOpty() {
		for(Potential_Opportunity__c opty: unqOptys) {
			if(opty.Id == potOptyId) {
				//Update values
				opty.Name = potOptyName;

				if(closeDateMillis != 0) {
					opty.Close_Date__c = DateTime.newInstance(closeDateMillis).date();
				} else {
					opty.Close_Date__c = null;
				}

				//Determine product-levels
				if(String.isNotEmpty(potOptyProductLevel) || String.isNotEmpty(potOptyProductId)) {
					Integer potOptyProductLevelInt = Integer.valueOf(potOptyProductLevel);

					String newProductLevel1 = null;
					String newProductLevel2 = null;
					String newProductLevel3 = null;

					ProductSelection_Helper psHelper = new ProductSelection_Helper();

					if(potOptyProductLevelInt == 1) {
						newProductLevel1 = potOptyProductId;
					} else if(potOptyProductLevelInt == 2) {
						newProductLevel2 = potOptyProductId;
						newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
					} else if(potOptyProductLevelInt == 3) {
						newProductLevel3 = potOptyProductId;
						newProductLevel2 = psHelper.getProductParent(3, newProductLevel3);
						newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
					}

					opty.Product_Level_1__c = newProductLevel1;
					opty.Product_Level_2__c = newProductLevel2;
					opty.Product_Level_3__c = newProductLevel3;
				}

				opty.Stage__c = potOptyStage;
				opty.Type__c = potOptyType;

				try {
					UPDATE opty;
				} catch(Exception e) {
					System.debug(e);
					setErrorMessage(Label.errMsg_ErrorDuringEditingPotOpty);
				}

				queryUnqOptys();
				break;
			}
		}
	}


	/**
		* @Author:          Svatopluk Sejkora
		* @Company:         Deloitte
		* @Description:     adds product
		* @Returns:         void
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private void addProduct() {
		Budget_Revenue__c buRe = new Budget_Revenue__c();

		try {
			buRe.Client_Plan__c     = planId;
			buRe.Product_Level_3__c = existingProductId;
			buRe.Country__c         = existingProductCountry;

			if(existingProductMaturityDateMillis != null && existingProductMaturityDateMillis > 0) {
				buRe.Maturity_Date__c = DateTime.newInstance(existingProductMaturityDateMillis).date();
			} else {
				buRe.Maturity_Date__c = null;
			}

			buRe.LGD__c             = existingProductLgd;
			buRe.DG__c              = existingProductDg;
			buRe.Limit__c           = existingProductLimit;
			buRe.Utilisation__c     = existingProductUtilisation;
			buRe.CurrencyIsoCode    = existingProductCurrency;
			buRe.Margin__c          = existingProductMargin;
			buRe.FTP__c             = existingProductFtp;
			buRe.Arranging_Fee__c   = existingProductArrfee;
			buRe.Commitment_Fee__c  = existingProductComfee;
			buRe.RoRWA__c           = existingProductRorwa;

			INSERT buRe;
		} catch(Exception e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringAddingPotOpty);
		}

		queryBudgetRevenues();
		prepareTotalsOfBudgetRevenues();
	}

	/**
		* @Author:          Svata Sejkora
		* @Company:         Deloitte
		* @Description:     product editation
		* @Returns:         void
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private void editProduct() {
		for(Budget_Revenue__c buRe: brs) {
			if(buRe.Id == existingRecordId) {
				try {
					buRe.Product_Level_3__c = existingProductId;
					buRe.Country__c         = existingProductCountry;

					if(existingProductMaturityDateMillis != null && existingProductMaturityDateMillis > 0) {
						buRe.Maturity_Date__c = DateTime.newInstance(existingProductMaturityDateMillis).date();
					} else {
						buRe.Maturity_Date__c = null;
					}

					buRe.LGD__c             = existingProductLgd;
					buRe.DG__c              = existingProductDg;
					buRe.Limit__c           = existingProductLimit;
					buRe.Utilisation__c     = existingProductUtilisation;
					buRe.CurrencyIsoCode    = existingProductCurrency;
					buRe.Margin__c          = existingProductMargin;
					buRe.FTP__c             = existingProductFtp;
					buRe.Arranging_Fee__c   = existingProductArrfee;
					buRe.Commitment_Fee__c  = existingProductComfee;
					buRe.RoRWA__c           = existingProductRorwa;

					System.debug('### Existing Product about to be saved: ' + buRe);

					UPDATE buRe;
				} catch (Exception e) {
					System.debug(e);
					setErrorMessage(Label.errMsg_ErrorDuringEditingPotOpty);
				}
				queryBudgetRevenues();
				prepareTotalsOfBudgetRevenues();
				break;
			}
		}
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     queries products
		* @Returns:         void
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private void queryBudgetRevenues() {
		brs = [
			SELECT    Id, Product_Level_3__c, Product_Level_3__r.Name, Product__c, Country__c, Maturity_Date__c, LGD__c, DG__C, Limit__c, Utilisation__c, CurrencyIsoCode, Margin__c, FTP__c, Arranging_Fee__c, Commitment_Fee__c, RoRWA__c 
			FROM      Budget_Revenue__c
			WHERE     Client_Plan__c = :planId
			ORDER BY  Product__c
		];
	}

	/**
		* @Author:          Svata Sejkora
		* @Company:         Deloitte
		* @Description:     delete product
		* @Returns:         null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public PageReference deleteProduct() {
		try {
			Budget_Revenue__c buRev = [
			SELECT  Id 
			FROM    Budget_Revenue__c 
			WHERE   Id = :existingRecordId
			][0];
			if(buRev != null) {
				DELETE buRev;
			}
			updateTFL();
		} catch(Exception e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringDeleting);
		}

		queryBudgetRevenues();
		prepareTotalsOfBudgetRevenues();
		return null;
	}

    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Add/Update facilities from ACM
		* @Returns:         null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
    public PageReference addFacilities() {
        
        
        Boolean retrieved = retrieveFacilities();
        Savepoint sp = Database.setSavepoint();
        Boolean removed = removeFacilities();
       // boolean limitsInserted  = insertLimits();
        Boolean inserted = insertFacilities();
        if(!retrieved||!removed||!inserted) Database.rollback(sp); // if anything failed rollback
        queryACMFacilities();
        return null;
    }
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Method to retrieve facilities from ACM
		* @Returns:         Boolean signifying if the operation failed
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
    ACM acm_service;
    public Boolean retrieveFacilities() {
    	acm_service = new ACM();
        if(selectedFacilitySDS != null && selectedFacilitySDS != '') {
            acm_service.RetrieveFacilityFeedSync(selectedFacilitySDS, true);
            if (acm_service.errorMessage != '') {
                setErrorMessage(acm_service.errorMessage);return false;
            } else {
                return true;
            }
        } else {
            return false;
        }
    }
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Insert a list of facilities from ACM into Salesforce
		* @Returns:         Boolean signifying if the operation failed
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
    public Boolean insertFacilities() {
        List<ACMFacility__c> acmfs = new List<ACMFacility__c>();
        for (ACM.Facility f : acm_service.FacilitiesFeed) {
        	ACMFacility__c acmf = new ACMFacility__c();
            acmf.Name = f.FACILITYID;
            acmf.Facility_Id__c = f.FACILITYID;
            acmf.CPTYLABEL__c = selectedFacilitySDSLabel ;
            acmf.BANKRISKTAKER__c = f.BANKRISKTAKER;
            acmf.CLIENTPLAN__c = planId;
            acmf.FACILITYACTIVE__c = f.FACILITYACTIVE;
            acmf.FACILITYAMOUNT__c = f.FACILITYAMOUNT;
            acmf.FACILITYCURRENCY__c = f.FACILITYCURRENCY;
            acmf.LOSSGIVENDEFAULT__c = f.GetLGD;
            acmf.EXPIRYDATE__c = f.GetExpiryDate;
            acmf.MODIFIEDBY__c = f.MODIFIEDBY;
            acmf.MODIFIEDTIMESTAMP__c = f.GetModifiedTimeStamp;
            acmf.PARENTFACILITYID__c = f.PARENTFACILITYID;
            acmf.FACILITYPRODUCT__c = f.FACILITYPRODUCT;
            acmf.FACILITYPRODUCTDESCRIPTION__c = f.FACILITYPRODUCTDESCRIPTION;
			acmf.CPTYID__c = f.CPTYID;
			acmf.STARTDATE__c = f.GetStartDate;
			acmf.TENORUNIT__c = f.TENORUNIT;
            acmf.TENORVALUE__c = f.TENORVALUE;
            acmf.ACMUTILIZATIONAMOUNT__c = f.ACMUTILIZATIONAMOUNT;
            acmf.ACMUTILIZATIONCURRENCY__c = f.ACMUTILIZATIONCURRENCY;
            acmf.RETRIEVEDVIAACM__c = true;
            acmfs.add(acmf);
            
            System.debug('acmf.Name '+acmf.Name);
        }
        if (acmfs.size()>0) {
            try {
                System.debug('acmfs size '+acmfs.size());
            	upsert acmfs Name;
                return true;
            } catch (Exception e) {
                System.debug('Exception '+e);
                setErrorMessage(e.getMessage());return false;
            }
        } else {
            setErrorMessage(Label.lbl_ACMNoFacilities + ' for ' + selectedFacilitySDSLabel);return false;
        }
    }
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Delete facilities from Salesforce
		* @Returns:         null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public PageReference deleteFacilities() {
        removeFacilities();
        
        queryACMFacilities();
        return null;
    }
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Remove facilities from Salesforce
		* @Returns:         Boolean signifying if the operation failed
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
    public Boolean removeFacilities() {
        
    	List<ACMFacility__c> facilitiesToDelete = new List<ACMFacility__c>();
        if (planid != null && planid != '' && selectedFacilitySDS != null && selectedFacilitySDS != '')
        	facilitiesToDelete = [SELECT Id,ClientPlan__c 
                                  From ACMFacility__c 
                                  WHERE ClientPlan__c =:planId 
                                  AND CPTYID__c =:selectedFacilitySDS
                                  AND RETRIEVEDVIAACM__c = true];

        if (facilitiesToDelete.size()>0) {
            try {
                for(ACMFacility__c acmf:facilitiesToDelete)
                {
                    acmf.ClientPlan__c = null;
                }
                
                //Tonga : This has been modified to update by clearing the ClientPlan__c field instead of deleting
         		update facilitiesToDelete;
                
                return true;
            } catch (Exception e) {
                System.debug(e.getMessage());
                setErrorMessage(e.getMessage());return false;
            }
        } else {
            return true;
        }
    }  
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Does the addition/modification of facilities
		* @Returns:         null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
    public PageReference modifyManualFacility() {
        if(String.isEmpty(facilityId)) {
			addManualFacility();
		} else {
			editManualFacility();
		}
		return null;
	}
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Does the addition of facilities into Salesforce
		* @Returns:         null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
    private void addManualFacility() {
        ACMFacility__c acmf = new ACMFacility__c();
		try {
			acmf.ClientPlan__c = planId;
            acmf.ACMUTILIZATIONCURRENCY__c = facilityCurrency;
            acmf.ACMUTILIZATIONAMOUNT__c = facilityUtilizationAmount;
            acmf.CPTYID__c = plan.Relationship__r.Name;
            acmf.CPTYLABEL__c = plan.Relationship__r.Name;
            acmf.FACILITYACTIVE__c = 'Y';
            acmf.FACILITYCURRENCY__c = facilityCurrency;
            acmf.FACILITYAMOUNT__c = facilityAmount;
            acmf.FACILITYPRODUCTDESCRIPTION__c = facilityProductDescription;
            acmf.LOSSGIVENDEFAULT__c = facilityLGD;
            acmf.RETRIEVEDVIAACM__c = false;
            acmf.GROSS_MARGIN__c = grossMargin;
            acmf.FTP_bps__c = ftpBPS;
            acmf.Net_Margin__c = netMargin;
            acmf.Arrang_Fee__c = arrangFee;
            acmf.COM_FEES__c = comFees;
            acmf.RoRWA__c = roRwa;
            acmf.Country__c = facilityCountry;
            
            
            if(facilityExpiryDateMillis != null && facilityExpiryDateMillis > 0) {
				acmf.EXPIRYDATE__c = DateTime.newInstance(facilityExpiryDateMillis).date();
			} else {
				acmf.EXPIRYDATE__c = null;
			}
            
            insert acmf;
		} catch(Exception e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringSaving);
		}

		queryACMFacilities();
    }
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Does the modification of facility
		* @Returns:         null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
    private void editManualFacility() {
        for(ACMFacility__c acmf: acmfs) {
			if(acmf.Id == facilityId) {
				try {
                    system.debug('facilityId '+facilityId);
                    acmf.ACMUTILIZATIONCURRENCY__c = facilityCurrency;
                    acmf.ACMUTILIZATIONAMOUNT__c = facilityUtilizationAmount;
                    if(!String.isBlank(selectedFacilitySDS))
                    {
                        acmf.CPTYID__c = selectedFacilitySDS;
                        acmf.CPTYLABEL__c = selectedFacilitySDSLabel;
                    }
                    
                    acmf.FACILITYCURRENCY__c = facilityCurrency;
                    acmf.FACILITYAMOUNT__c = facilityAmount;
                    acmf.FACILITYPRODUCTDESCRIPTION__c = facilityProductDescription;
                    acmf.LOSSGIVENDEFAULT__c = facilityLGD;
                    acmf.GROSS_MARGIN__c = grossMargin;
                    acmf.FTP_bps__c = ftpBPS;
                    acmf.Net_Margin__c = netMargin;
                    acmf.Arrang_Fee__c = arrangFee;
                    acmf.COM_FEES__c = comFees;
                    acmf.RoRWA__c = roRwa;
                    acmf.Country__c = facilityCountry;
                    
                    if(facilityExpiryDateMillis != null && facilityExpiryDateMillis > 0) {
                        acmf.EXPIRYDATE__c = DateTime.newInstance(facilityExpiryDateMillis).date();
                    } else {
                        acmf.EXPIRYDATE__c = null;
                    }

					System.debug('### Existing Facility about to be saved: ' + acmf);

					UPDATE acmf;
				} catch (Exception e) {
					System.debug(e);
					setErrorMessage(Label.errMsg_ErrorDuringSaving);
				}
				queryACMFacilities();
				break;
			}
		}
    }
    
    /**
		* @Author:          Dino Scarcella
		* @Company:         Absa Capital
		* @Description:     Does the deletion of the manual facility in Salesforce
		* @Returns:         null
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
    public PageReference deleteManualFacility() {
		try {
			List<ACMFacility__c> acmfs = [
			SELECT  Id 
			FROM    ACMFacility__c 
			WHERE   Id = :facilityId
			];
			
            System.debug(facilityId);
            
			if(acmfs.size() > 0) {
				DELETE acmfs[0];
			}
		} catch(Exception e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringDeleting);
		}

		queryACMFacilities();
		return null;
	}
    
	/**
	    * @Author:          Dino Scarcella
	    * @Company:         Absa Capital
	    * @Description:     Rolls up the Limit Field on Products to the TFL__c field on Client Plan
	    * @Returns:         void
	    * History
	    * <Date>      <Authors Name>     <Brief Description of Change>
	    *------------------------------------------------------------*/
    public void updateTFL() {
	  	if (planloaded) {
	  		Decimal TFL = 0;
	  		try {
		  	  	// Loop through all the Existing Products and get users local currency limit
			  	for (Budget_Revenue__c buRev : [SELECT convertCurrency(Limit__c) ConvertedLimit 
												FROM Budget_Revenue__c
												WHERE Client_Plan__c = :planId])
		    		if (buRev.get('ConvertedLimit') != null) TFL += (Decimal)buRev.get('ConvertedLimit');
			    // Update the client plan with the new rolled up value
			    Client_Plan__c clientplan = new Client_Plan__c();
			    clientplan.Id = planid;
		      	clientplan.TFL__c = TFL;
		      	update clientplan;
		  	} catch(Exception e) {
		  		System.debug(e);
		  	}	
	  	}
  	}
	
	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     prepares totals of products table
		* @Returns:         void
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private void prepareTotalsOfBudgetRevenues() {
		AggregateResult ar = [
			SELECT 	SUM(Limit__c) totalLimit, SUM(Utilisation__c) totalUtilisation 
			FROM 	Budget_Revenue__c
			WHERE 	Client_Plan__c = :planId
		];

		Budget_Revenue__c totals = new Budget_Revenue__c();
		totals.Product__c = Label.lbl_Totals;
		totals.Country__c = ' ';
		totals.Maturity_Date__c = null;
		totals.LGD__c = null;
		totals.DG__c = null;
		totals.Limit__c = (Decimal) ar.get('totalLimit');
		totals.Utilisation__c = (Decimal) ar.get('totalUtilisation');
		totals.Margin__c = null;
		totals.FTP__c = null;
		totals.Arranging_Fee__c = null;
		totals.Commitment_Fee__c = null;
		totals.RoRWA__c = null;

		//Force the currencyCode on the Total record to be the Org Default. Limitation from using SUM in SOQL
		CurrencyType defaultOrgCurrency = [SELECT Id, IsoCode, IsCorporate FROM CurrencyType WHERE IsCorporate = true].get(0);
		totals.CurrencyIsoCode = defaultOrgCurrency.IsoCode;		

		brs.add(totals);
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     queries potential optys
		* @Returns:         void
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private void queryUnqOptys() {
		unqOptys = [
			SELECT    Id, Name, Close_Date__c, Product__c, Stage__c, Probability__c, Type__c, IsConverted__c, Product_Level_1__c, Product_Level_1__r.Name, Product_Level_2__c, Product_Level_2__r.Name, Product_Level_3__c, Product_Level_3__r.Name
			FROM      Potential_Opportunity__c
			WHERE     Client_Plan__c = :planId AND Opportunity__c = null AND IsConverted__c = false
			ORDER BY  Opportunity__c
		];
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     queries open opportunities
		* @Returns:         List<Opportunity>
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private void queryPipelineOptys() {
		pipelineOptys = [
			SELECT    Id, Name, Annualised_Income__c, StageName, Owner.Name, CloseDate, Total_Balance_Facility_Size__c, Probability
			FROM      Opportunity
			WHERE     (AccountId = :plan.Relationship__c OR 
                       Account_Name__c = :plan.Relationship__c OR 
                       Related_Group_Client__c =: plan.Relationship__c) 
            AND       StageName != :CLOSED_WON AND StageName != :CLOSED_LOST 
			ORDER BY  Annualised_Income__c DESC
		];
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     queries client plan
		* @Returns:         void
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private void queryPlan() {
		List<Client_Plan__c> plans;
		try {
			plans = [
				SELECT  Id, Relationship__c,Relationship__r.Name
				FROM    Client_Plan__c 
				WHERE   Id = :planId
			];
		} catch(Exception e) {
			planLoaded = false;
			return;
		}

		if(plans.isEmpty()) {
			planLoaded = false; 
		} else {
			planLoaded = true;
			plan = plans[0];
		}
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     prepares select options from describe field result
		* @Params           Schema.DescribeFieldResult f - field info to process
		* @Returns:         List<SelectOption> - prepared select options
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	private List<SelectOption> prepareSelectOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
		List<Schema.PicklistEntry> p = f.getPicklistValues();

		List<SelectOption> options = new List<SelectOption>();
		for(Schema.PicklistEntry e : p) {
			options.add(new SelectOption(e.getLabel(), e.getValue()));
		}
		return options;
	}

	/**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     prepares select options of currency field
      * @Returns:         List<SelectOption> - options prepared
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    
    public List<SelectOption> getCurrencyOptions() {
        Schema.DescribeFieldResult f = Client_Plan_Facility__c.CurrencyIsoCode.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
	
    /**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     prepares select options of SDS Field
      * @Returns:         List<SelectOption> - prepared options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public List<SelectOption> getSDSClients {
    	get {
    		List<Account> SDSClients;
    		List<SelectOption> SDSClientsSOps = new List<SelectOption>();
        	SDSClientsSOps.add(new SelectOption('', '- SELECT SDS -'));
	        try {
	        	SDSClients = [
	                SELECT Name, SDS__c
	                FROM Account 
	                WHERE ParentId = :plan.Relationship__c
	                AND SDS__c != NULL
	                AND SDS__c != ''
	                order by Name];
	            if (SDSClients.isEmpty()) {
	            	return SDSClientsSOps;
	        	} else {
	            	for (Account acc: SDSClients) {
	            		String Label = acc.Name + ' - ' + acc.SDS__c;
	            		SDSClientsSOps.add(new SelectOption(acc.SDS__c, Label));
	        		}
	        		return SDSClientsSOps;
	        	}
	        } catch (Exception e) {
	        	return SDSClientsSOps;
	        }	
    	}
    	set;
    }    
    
	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     getter of error message
		* @Returns:         String - error message
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public String getErrorMessage() {
		String message = errorMessage;
		errorMessage = null;

		return message;
	}

	/**
		* @Author:          Marek Cech
		* @Company:         Deloitte
		* @Description:     setter of error message
		* @Params           String errorMessage - message to set
		* @Returns:         ot
		* History
		* <Date>      <Authors Name>     <Brief Description of Change>
		*------------------------------------------------------------*/
	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
	}
    
   public List<SelectOption> getFacilityCountryOptions() {
        Schema.DescribeFieldResult f = ACMFacility__c.Country__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
}