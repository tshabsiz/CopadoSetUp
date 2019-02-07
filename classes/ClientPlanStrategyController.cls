/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanStrategy VF page.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanStrategyController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 2.2.2016      svata Sejkora   added methods to enable linking of potential opportunity
* 13.06.2017 	Dino Scarcella	Modified AddOpportunity Method to include country
*------------------------------------------------------------*/
public class ClientPlanStrategyController extends ClientPlanUtils{

	public Boolean planLoaded {get;set;}
	public Client_Plan__c plan {get;set;}
	public List<Client_Plan_Strategy__c> strategies {get;set;}
	public Map<Id, List<Opportunity>> optysMap {get;set;}
	public Map<Id, List<Potential_Opportunity__c>> unqOptysMap {get;set;}

	//variables used for rich text editation
	public String strategyId {get;set;}
	public Boolean isClientStrategy {get;set;}
	public String strategyName {get;set;}
	public String clientContent {get;set;}
	public String bankContent {get;set;}
	
	//variables for managing opportunities
	public Opportunity optyToAdd {get;set;}
	
	public Potential_Opportunity__c unqOptyToAdd {get;set;}
	public String selectedProductLevel {get;set;}
	public String selectedProductId {get;set;}
	
	public String closeDateMillisString {get;set;}
	public String unqOptyId {get;set;}
	public String unqOptyJson {get;set;}
	public String managedUnqOptyId {get;set;}
	
	//variables for showing error messages
	public String errorMessage;
	
	//variables for linking optys
	public List<Opportunity> optysToLink {get;set;}
	public String optysToLinkJson {get;set;}
	public String optyId {get;set;}

	//variables for linking potential optys
	public List<Potential_Opportunity__c> potOptysToLink {get;set;}
	public String potOptysToLinkJson {get;set;}
	public String potOptyId {get;set;}
	
	//private variables
	@testVisible
	public String planId;
	
	@testVisible
	private Map<Id, Client_Plan_Strategy__c> strategiesMap;
	
	@testVisible
	private List<Potential_Opportunity__c> unqOptys;
	private List<Opportunity> optys;
	private List<Potential_Opportunity__c> potOptys;
	
	private static final String ON_RECORD_WITH_ID = 'on record with id: ';
	private static final String CLOSED_WON = 'Closed Won';
	private static final String CLOSED_LOST = 'Closed Lost';

	public ClientPlanStrategyController() {
        super(ApexPages.currentPage().getParameters().get('planId'),'planId');
		planId = ApexPages.currentPage().getParameters().get('planId');
		if(String.isEmpty(planId)) {
			planId = ApexPages.currentPage().getParameters().get('id');
		}
		if(!String.isEmpty(planId)) {
			queryPlan();
			if(planLoaded) {
				queryStrategies();
				queryOptys();
				queryUnqOptys();
				prepareUnqOptyToAdd();
				prepareOptyToAdd();
				queryOptysToLink();
				queryPotOptysToLink();
			}
		}
		errorMessage = null;
	}

	/**
	  * @Author:          Marta Malinowska
	  * @Company:         Deloitte
	  * @Description:     get list of all strategies that starts with typed text
	  * @Param:           strategy name, Id of Client Plan
	  * @Returns:         List of Client Plan Strategies
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	  @RemoteAction
	public static List<Client_Plan_Strategy__c> getStrategiesList(String strategyName, String accountPlanId) {
		strategyName += '%';
		List<Client_Plan_Strategy__c> items = new List<Client_Plan_Strategy__c>();

		for(Client_Plan_Strategy__c strategy: [
			SELECT 	Id, Name, Client_Strategy__c, Bank_Strategy__c, CreatedDate, (
				SELECT 	Id, Name, Probability 
				FROM 	Opportunities__r), (
				SELECT 	Id, Name, Probability__c 
				FROM 	Unqualified_Opportunities__r 
				WHERE 	IsConverted__c = false)
			FROM 	Client_Plan_Strategy__c 
			WHERE 	Client_Plan__c = :accountPlanId AND Name LIKE :strategyName
			ORDER BY CreatedDate]
		) {
			items.add(strategy);
		}

		return items;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     adds new strategy to client plan
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	@RemoteAction
	public static String addStrategy(String strategyName, String clientContent, String bankContent, String accountPlanId) {
		Client_Plan_Strategy__c cps = new Client_Plan_Strategy__c();

		try {
			cps.Client_Plan__c = accountPlanId;
			cps.Name = strategyName;
			cps.Client_Strategy__c = clientContent;
			cps.Bank_Strategy__c = bankContent;
			INSERT cps;
		} catch(Exception e) {
			return 'Error: '+Label.errMsg_AddStrategy;
		}

		return cps.Id;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     unlinks opportunities and deletes strategy
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	@RemoteAction
	public static String removeStrategy(String strategyId) {
		Client_Plan_Strategy__c cps;
		try {
			cps = [
				SELECT 	Id, Name, (
					SELECT 	Id, Name, Client_Plan_Strategy__c 
					FROM 	Opportunities__r), (
					SELECT 	Id, Name 
					FROM 	Unqualified_Opportunities__r) 
				FROM 	Client_Plan_Strategy__c WHERE Id = :strategyId
			];
		} catch(QueryException e){
			return Label.errMsg_ErrorDeletingStrategy;
		}

		if(!cps.Unqualified_Opportunities__r.isEmpty()) {
			return Label.errMsg_StrategyHasOpportunities;
		}

		List<Opportunity> optys = cps.Opportunities__r;
		for(Opportunity opty: optys) {
			opty.Client_Plan_Strategy__c = null;
		}

		Savepoint sp = Database.setSavepoint();
		try {
			UPDATE optys;
			} catch (Exception e) {
				System.debug(e);
				return Label.errMsg_ErrorUnlinkingOptys;
			}

			try {
				DELETE cps;
		} catch (Exception e) {
			Database.rollback(sp);
			System.debug(e);
			return Label.errMsg_ErrorDeletingStrategy;
		}

		return null;
	}

	/**
	  * @Author:          Marta Malinowska
	  * @Company:         Deloitte
	  * @Description:     add new opportunity and relate it to strategy
	  * @Param:           Id of strategy, strategy name, opportunity stage, opportunity type, opportunity close date, Id of Client Plan
	  * @Returns:         String - opportunity Id or error message
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	@RemoteAction
	public static String addOpportunity(String strategyId, String name, String stage, String type, String opportunity_country, String closeDate, String accountPlanId) {
		Opportunity opp = new Opportunity();
		Client_Plan__c accountPlan;
		try {
			accountPlan = [
				SELECT 	Id, Relationship__c 
				FROM 	Client_Plan__c 
				WHERE 	Id = :accountPlanId
			];
		} catch(QueryException e){
			return 'Error: Client Plan cannot be found.';
		}

		opp.AccountId = accountPlan.Relationship__c;
		opp.Client_Plan_Strategy__c = strategyId;
		opp.Name = name;
		opp.StageName = stage;
		opp.Type = type;
        opp.Opportunity_Country__c = opportunity_country;

		if(closeDate != null && closeDate != '0') {
			Long closeDateMillis;

			try {
				closeDateMillis = Long.valueOf(closeDate);
			} catch(Exception e) {
				System.debug(e);
				return 'Error: '+Label.errMsg_ErrorDuringAddingOpty;
			}

			opp.CloseDate = Datetime.newInstance(closeDateMillis).date();
		}

		try {
			INSERT opp;
		} catch(DmlException e) {
			System.debug(e);
			return 'Error: '+ e.getDmlMessage(0);
		}

		return opp.Id;
	}

	/**
	  * @Author:          Marta Malinowska
	  * @Company:         Deloitte
	  * @Description:     save strategy
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public PageReference editStrategy() {
		Client_Plan_Strategy__c cps = strategiesMap.get(strategyId);
		
		if(cps == null) {
			setErrorMessage(Label.errMsg_ErrorDuringSaving);
			return null;
		}
		cps.Name = strategyName;
		cps.Client_Strategy__c = clientContent;
		cps.Bank_Strategy__c = bankContent;

		try {
			UPDATE cps;
		} catch(Exception e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringSaving);
		}
		return null;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     signpost method for managing opportunities, currently add implemented
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public PageReference manageOpty() {
		addOpty();
		return null;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     signpost method for managing potential opportunities, currently add and 
	  * edit implemented
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public PageReference manageUnqOpty() {
		if(managedUnqOptyId == '') {
			addUnqOpty();
		} else {
			editUnqOpty();
		}
		return null;
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

		List<Potential_Opportunity__c> orgs = [
			SELECT 	Client_Plan_Strategy__r.Client_Plan__r.Relationship__c
			FROM 	Potential_Opportunity__c
			WHERE 	Id = :managedUnqOptyId
		];

		if(orgs.isEmpty()) {
			setErrorMessage(Label.errMsg_ErrorConvertingOpportunity);
			return null;
		}

		Opportunity opp = new Opportunity();
		opp.Name = uo.Name;
		opp.CloseDate = uo.Close_Date__c;
		opp.Type = uo.Type__c;
		opp.StageName = 'Opportunity Identified';
		opp.AccountId = orgs[0].Client_Plan_Strategy__r.Client_Plan__r.Relationship__c;
		opp.Client_Plan_Strategy__c = uo.Client_Plan_Strategy__c;
		//NO PRODUCTS ARE MOVED ACCROSS

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
		} catch(DmlException e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorConvertingOpportunity);
			Database.rollback(sp);
			uo.Opportunity__c = null;
		}

		queryOptys();
		return null;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     loading method for vieving additional information about potential opportunity
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public PageReference loadUnqOpty() {
		List<Potential_Opportunity__c> optys = [
			SELECT  Id, Name, Close_Date__c, Product_Level_1__c, Product_Level_1__r.Name, Product_Level_2__c, Product_Level_2__r.Name, Product_Level_3__c, Product_Level_3__r.Name, Stage__c, Probability__c, Type__c, Opportunity__c
			FROM    Potential_Opportunity__c
			WHERE   Id = :unqOptyId
		];

		if(optys.isEmpty()) {
			setErrorMessage(Label.errMsg_ErrorLoadingData);
		} else {
			Potential_Opportunity__c uo = optys[0];

			Long millis = 0;
			if(uo.Close_Date__c != null) {
				Date d = uo.Close_Date__c.addDays(1);
				millis = DateTime.newInstance(d.year(), d.month(), d.day()).getTime();
			}

			UnqOptyDto dto = new UnqOptyDto(uo.Id, uo.Name, millis, uo.Product_Level_1__r.Name, uo.Product_Level_1__c, uo.Product_Level_2__r.Name, uo.Product_Level_2__c, uo.Product_Level_3__r.Name, uo.Product_Level_3__c, uo.Stage__c, uo.Probability__c, uo.Type__c, uo.Opportunity__c);
			unqOptyJson = JSON.serialize(dto);

			System.debug('### Returning unqOptyJson [' + unqOptyJson + ']');
		}

		return null;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     links opportunities to a client strategy
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public PageReference linkOptys() {
		List<String> optyIds;
		try {
			optyIds = (List<String>) JSON.deserialize(optysToLinkJson, List<String>.class);
		} catch(JSONException e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringLinkingOptys);
			return null;
		}

		Map<Id, Opportunity> optysMap = new Map<Id, Opportunity>(optysToLink);
		List<Opportunity> optys = new List<Opportunity>();

		for(String id: optyIds) {
			Opportunity opty = optysMap.get(id);

			if(opty == null) {
				setErrorMessage(Label.errMsg_ErrorDuringLinkingOptys);
				return null;
			} else {
				try {
					opty.Client_Plan_Strategy__c = strategyId;
				} catch(StringException e) {
					System.debug(e);
					setErrorMessage(Label.errMsg_ErrorDuringLinkingOptys);
				}
				optys.add(opty);
			}
		}

		try {
			UPDATE optys;
		} catch(DmlException e) {
			setErrorMessage(Label.errMsg_ErrorDuringLinkingOptys + processDmlException(e));
			System.debug(e);
			return null;
		}

		queryOptys();
		queryOptysToLink();
		return null;
	}

	/**
	  * @Author:          Svata Sejkora
	  * @Company:         Deloitte
	  * @Description:     links potential opportunities to a client strategy
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public PageReference linkPotOptys() {
		List<String> potOptyIds;
		try {
			potOptyIds = (List<String>) JSON.deserialize(potOptysToLinkJson, List<String>.class);
		} catch(JSONException e) {
			System.debug(e);
			setErrorMessage(Label.errMsg_ErrorDuringLinkingPotOptys);
			return null;
		}

		Map<Id, Potential_Opportunity__c> potOptysMap = new Map<Id, Potential_Opportunity__c>(potOptysToLink);
		List<Potential_Opportunity__c> potOptys = new List<Potential_Opportunity__c>();

		for(String id: potOptyIds) {
			Potential_Opportunity__c potOpty = potOptysMap.get(id);

			if(potOpty == null) {
				setErrorMessage(Label.errMsg_ErrorDuringLinkingPotOptys);
				return null;
			} else {
				try {
					potOpty.Client_Plan_Strategy__c = strategyId;
				} catch(StringException e) {
					System.debug(e);
					setErrorMessage(Label.errMsg_ErrorDuringLinkingPotOptys);
				}
				potOptys.add(potOpty);
			}
		}

		try {
			UPDATE potOptys;
		} catch(DmlException e) {
			setErrorMessage(Label.errMsg_ErrorDuringLinkingPotOptys + processDmlException(e));
			System.debug(e);
			return null;
		}

		queryUnqOptys();
		queryPotOptysToLink();
		return null;
	}    

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     unlinks opportunity from client strategy
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public PageReference unlinkOpty() {
		Opportunity opty;
		for(Opportunity o: optys) {
			if(o.Id == optyId) {
				opty = o;
				break;
			}
		}

		if(opty == null) {
			setErrorMessage(Label.errMsg_ErrorUnlinkingOptys);
			return null;
		}

		opty.Client_Plan_Strategy__c = null;
		try {
			UPDATE opty;
		} catch(DmlException e) {
			setErrorMessage(Label.errMsg_ErrorUnlinkingOptys + processDmlException(e));
			System.debug(e);
			return null;
		}

		queryOptys();
		optysToLink.add(opty);
		return null;
	}

	/**
	  * @Author:          Svata Sejkora
	  * @Company:         Deloitte
	  * @Description:     unlinks potential opportunity from client strategy
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public PageReference unlinkPotOpty() {
		Potential_Opportunity__c potOpty;
		for(Potential_Opportunity__c o: unqOptys) {
			if(o.Id == potOptyId) {
				potOpty = o;
				break;
			}
		}

		if(potOpty == null) {
			setErrorMessage(Label.errMsg_ErrorUnlinkingPotOptys);
			return null;
		}

		potOpty.Client_Plan_Strategy__c = null;
		try {
			UPDATE potOpty;
		} catch(DmlException e) {
			setErrorMessage(Label.errMsg_ErrorUnlinkingPotOptys + processDmlException(e));
			System.debug(e);
			return null;
		}

		queryUnqOptys();
		potOptysToLink.add(potOpty);
		return null;
	}    

	/**
	  * @Author:          Marta Malinowska
	  * @Company:         Deloitte
	  * @Description:     delete potential opportunity and remove from client strategy
	  * @Returns:         PageReference
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public PageReference deleteUnqOpty() {
		Potential_Opportunity__c unqOpty = new Potential_Opportunity__c();
		unqOpty.Id = unqOptyId;
		try {
			DELETE unqOpty;
		} catch(DmlException e) {
			setErrorMessage(processDmlException(e));
			System.debug(e);
			return null;
		}
		return null;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     getter of errorMessage
	  * @Returns:         String - error message or null if not defined
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
	  * @Description:     setter method for errorMessage
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	public void setErrorMessage(String errorMessage) {
		this.errorMessage = errorMessage;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     adds new opportunity
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void addOpty() {
		Boolean errorOccured = convertCloseDateMillis(false);
		if(errorOccured) {
			setErrorMessage(Label.errMsg_ErrorDuringAddingOpty);
			return;
		}

		try {
			INSERT optyToAdd;
		} catch(DmlException e) {
			setErrorMessage(Label.errMsg_ErrorDuringAddingOpty + processDmlException(e));
			System.debug(e);
			return;
		}

		queryOptys();
		queryOptysToLink();
		prepareOptyToAdd();
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     adds new potential opportunity
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void addUnqOpty() {
		Boolean errorOccured = convertCloseDateMillis(true);
		if(errorOccured) {
			setErrorMessage(Label.errMsg_ErrorDuringAddingPotOpty);
			return;
		}
		System.debug('### unqOptyToAdd: ' + unqOptyToAdd);

		//Deal with Products - Determine levels
		System.debug('### selected product [selectedProductId: ' + selectedProductId + ', selectedProductLevel: ' + selectedProductLevel + ']');
		if(String.isNotEmpty(selectedProductLevel) || String.isNotEmpty(selectedProductId)) {
			Integer selectedProductLevelInt = Integer.valueOf(selectedProductLevel);

			String newProductLevel1 = null;
			String newProductLevel2 = null;
			String newProductLevel3 = null;

			ProductSelection_Helper psHelper = new ProductSelection_Helper();

			if(selectedProductLevelInt == 1) {
				newProductLevel1 = selectedProductId;
			} else if(selectedProductLevelInt == 2) {
				newProductLevel2 = selectedProductId;
				newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
			} else if(selectedProductLevelInt == 3) {
				newProductLevel3 = selectedProductId;
				newProductLevel2 = psHelper.getProductParent(3, newProductLevel3);
				newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
			}

			unqOptyToAdd.Product_Level_1__c = newProductLevel1;
			unqOptyToAdd.Product_Level_2__c = newProductLevel2;
			unqOptyToAdd.Product_Level_3__c = newProductLevel3;
		}

		try {
			INSERT unqOptyToAdd;
		} catch(DmlException e) {
			setErrorMessage(Label.errMsg_ErrorDuringAddingPotOpty);
			System.debug(e);
			return;
		}

		queryUnqOptys();
		prepareUnqOptyToAdd();
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     method for validation before editation of potential opportunity
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void editUnqOpty() {
		Boolean errorOccured = convertCloseDateMillis(true);
		if(errorOccured) {
			setErrorMessage(Label.errMsg_ErrorDuringEditingPotOpty);
			return;
		}

		Potential_Opportunity__c uo = getUnqOptyById(managedUnqOptyId);
		if(uo == null) {
			setErrorMessage(Label.errMsg_ErrorDuringEditingPotOpty);
			return;
		}

		editUnqOpty(uo);
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     method for editatation of potential opportunity
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void editUnqOpty(Potential_Opportunity__c uo) {
		uo.Name = unqOptyToAdd.Name;
		uo.Close_Date__c = unqOptyToAdd.Close_Date__c;
		uo.Stage__c = unqOptyToAdd.Stage__c;
		uo.Type__c = unqOptyToAdd.Type__c;

		//Deal with Products - Determine levels
		System.debug('### selected product [selectedProductId: ' + selectedProductId + ', selectedProductLevel: ' + selectedProductLevel + ']');
		if(String.isNotEmpty(selectedProductLevel) || String.isNotEmpty(selectedProductId)) {
			Integer selectedProductLevelInt = Integer.valueOf(selectedProductLevel);

			String newProductLevel1 = null;
			String newProductLevel2 = null;
			String newProductLevel3 = null;

			ProductSelection_Helper psHelper = new ProductSelection_Helper();

			if(selectedProductLevelInt == 1) {
				newProductLevel1 = selectedProductId;
			} else if(selectedProductLevelInt == 2) {
				newProductLevel2 = selectedProductId;
				newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
			} else if(selectedProductLevelInt == 3) {
				newProductLevel3 = selectedProductId;
				newProductLevel2 = psHelper.getProductParent(3, newProductLevel3);
				newProductLevel1 = psHelper.getProductParent(2, newProductLevel2);
			}

			uo.Product_Level_1__c = newProductLevel1;
			uo.Product_Level_2__c = newProductLevel2;
			uo.Product_Level_3__c = newProductLevel3;
		}

		try {
			UPDATE uo;
		} catch(DmlException e) {
			setErrorMessage(Label.errMsg_ErrorDuringEditingPotOpty);
			System.debug(e);
		}

		queryUnqOptys();
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
	  * @Description:     returns potential opportunity by Id in parameter, null if not found
	  * @Param            Boolean isUnqualified - indicates whether converting on standard opportunity
	  * @Returns:         Boolean indicating if an error occured
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	@testVisible
	private Boolean convertCloseDateMillis(Boolean isUnqualified) {
		if(closeDateMillisString != null && closeDateMillisString != '0') {

			Long closeDateMillis;
			try {
				closeDateMillis = Long.valueOf(closeDateMillisString);
			} catch(Exception e) {
				System.debug(e);
				return true;
			}

			Date closeDate = Datetime.newInstance(closeDateMillis).date();
			System.debug(closeDate);
			if(isUnqualified) {
				unqOptyToAdd.Close_Date__c = closeDate;
			} else {
				optyToAdd.CloseDate = closeDate;
			}
		}
		return false;
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
		List<Client_Plan__c> plans = [
			SELECT 	Id, Relationship__c
			FROM 	Client_Plan__c 
			WHERE 	Id = :planId
		];

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
	  * @Description:     queries client strategies
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void queryStrategies() {
		strategies = [
			SELECT 	Id, Name, CreatedDate, Client_Strategy__c, Bank_Strategy__c
			FROM 	Client_Plan_Strategy__c
			WHERE 	Client_Plan__c = :planId
			ORDER BY CreatedDate DESC
		];

		strategiesMap = new Map<Id, Client_Plan_Strategy__c>(strategies);
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     queries client strategies
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void queryOptys() {
		optysMap = new Map<Id, List<Opportunity>>();

		optys = [
			SELECT 	Id, Name, Probability, Client_Plan_Strategy__c
			FROM 	Opportunity
			WHERE 	(AccountId = :plan.Relationship__c OR Account_Name__c = :plan.Relationship__c)
            AND     Client_Plan_Strategy__c != null
			ORDER BY Name
		];

		for(Opportunity o : optys) {
			if(optysMap.containsKey(o.Client_Plan_Strategy__c)) {
				List<Opportunity> os = optysMap.get(o.Client_Plan_Strategy__c);
				os.add(o);
			} else {
				List<Opportunity> os = new List<Opportunity>{o};
				optysMap.put(o.Client_Plan_Strategy__c, os);
			}
		}

		for(Client_Plan_Strategy__c s : strategies) {
			if(!optysMap.containsKey(s.Id)) {
				optysMap.put(s.Id, new List<Opportunity>());
			}
		}
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     queries potential opportunities
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void queryUnqOptys() {
		unqOptysMap = new Map<Id, List<Potential_Opportunity__c>>();

		unqOptys = [
			SELECT 	Id, Client_Plan_Strategy__c, Name, Close_Date__c, Type__c, IsConverted__c, Opportunity__c, Probability__c
			FROM 	Potential_Opportunity__c
			WHERE 	Client_Plan_Strategy__r.Client_Plan__c = :planId AND IsConverted__c = false
			ORDER BY Opportunity__c NULLS FIRST, Name
		];

		for(Potential_Opportunity__c uo : unqOptys) {
			if(unqOptysMap.containsKey(uo.Client_Plan_Strategy__c)) {
				List<Potential_Opportunity__c> uos = unqOptysMap.get(uo.Client_Plan_Strategy__c);
				uos.add(uo);
			} else {
				List<Potential_Opportunity__c> uos = new List<Potential_Opportunity__c>{uo};
				unqOptysMap.put(uo.Client_Plan_Strategy__c, uos);
			}
		}

		for(Client_Plan_Strategy__c s : strategies) {
			if(!unqOptysMap.containsKey(s.Id)) {
				unqOptysMap.put(s.Id, new List<Potential_Opportunity__c>());
			}
		}
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     prepares 'empty' potential opportunity ready to be inserted
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void prepareUnqOptyToAdd() {
		closeDateMillisString = '0';
		unqOptyToAdd = new Potential_Opportunity__c();
		unqOptyToAdd.Client_Plan__c = planId;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     prepares 'empty' opportunity ready to be inserted
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void prepareOptyToAdd() {
		closeDateMillisString = '0';
		optyToAdd = new Opportunity();
		optyToAdd.AccountId = plan.Relationship__c;
	}

	/**
	  * @Author:          Marek Cech
	  * @Company:         Deloitte
	  * @Description:     queries opportunities which can be linked to a strategy
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void queryOptysToLink() {
		optysToLink = [
			SELECT 	Id, Name
			FROM 	Opportunity
			WHERE 	(AccountId = :plan.Relationship__c OR Account_Name__c = :plan.Relationship__c) 
            AND     Client_Plan_Strategy__c = null AND StageName != :CLOSED_WON AND StageName != :CLOSED_LOST
		];
	}

	/**
	  * @Author:          Svata Sejkora
	  * @Company:         Deloitte
	  * @Description:     queries potential opportunities which can be linked to a strategy
	  * @Returns:         void
	  * History
	  * <Date>      <Authors Name>     <Brief Description of Change>
	  *------------------------------------------------------------*/
	private void queryPotOptysToLink() {
		potOptysToLink = [
			SELECT 	Id, Name
			FROM 	Potential_Opportunity__c
			WHERE 	Client_Plan_Strategy__c = null AND IsConverted__c = false and Client_Plan__c = :plan.Id
		];
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

	private class UnqOptyDto {
		public String id;
		public String name;
		public Long closeDate;
		public String productLvl1Name;
		public String productLvl1Id;
		public String productLvl2Name;
		public String productLvl2Id;
		public String productLvl3Name;
		public String productLvl3Id;
		public String stage;
		public Decimal probability;
		public String type;
		public String opportunity;

		public UnqOptyDto(String id, String name, Long closeDate, String productLvl1Name, String productLvl1Id, String productLvl2Name, String productLvl2Id, String productLvl3Name, String productLvl3Id, String stage, Decimal probability, String type, String opportunity) {
			this.id = id;
			this.name = name;
			this.closeDate = closeDate;
			this.productLvl1Name = productLvl1Name;
			this.productLvl1Id = productLvl1Id;
			this.productLvl2Name = productLvl2Name;
			this.productLvl2Id = productLvl2Id;
			this.productLvl3Name = productLvl3Name;
			this.productLvl3Id = productLvl3Id;
			this.stage = stage;
			this.probability = probability;
			this.type = type;
			this.opportunity = opportunity;
		}
	}
}