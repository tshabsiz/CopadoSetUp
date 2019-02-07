/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanDetails VF page.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPresence
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class ClientPlanDetailsController extends ClientPlanUtils {

    public Client_Plan__c plan {get;set;}

    public Boolean planLoaded {get;set;}

    public String planId {get;set;}
    
    public List<Account_Team_Member__c> members {get;set;}
    
    public Account_Team_Member__c memberToAdd {get;set;}
    
    public Integer memberRowToDelete {get;set;}
    
    public Integer planProgress {get;set;}
    
    public String errorMessage;

    public ClientPlanDetailsController(ApexPages.StandardController stdController) {
        super(ApexPages.currentPage().getParameters().get('planId'),'planId');
        planId =ApexPages.currentPage().getParameters().get('planId');
        if (String.isEmpty(planId)) {
            planId = ApexPages.currentPage().getParameters().get('id');
        }
        
        if (!String.isEmpty(planId)) {
            queryPlan();
            if (planLoaded) {
                queryTeamMembers();
                prepareMemberToAdd();
                countPlanProgress(false);
            }
        }
    }
    
     /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     saves changes on client plan
      * @Returns:         PAgeReference - null
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public PageReference save() {
        try {
            update plan;
        } catch (Exception e) {
            setErrorMessage(Label.errMsg_ErrorDuringSaving);
            System.debug(e);
        }
        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds team member
      * @Returns:         PageReference - null
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public PageReference addMember() {
        List<User> users = [SELECT Name FROM User WHERE Id = :memberToAdd.Team_Member__c];
        if (users.size() != 1) {
            setErrorMessage(Label.errMsg_ErrorAddingTeamMember);
            return null;
        }
        
        try {
            insert memberToAdd;
        } catch (DmlException e) {
            String message = Label.errMsg_ErrorAddingTeamMember;
            for (Integer i = 0; i < e.getNumDml(); i++) {
                message += ' ' + e.getDmlMessage(i);
            }
        
            setErrorMessage(message);
            System.debug(e);
            return null;
        }
        queryTeamMembers();
        countPlanProgress(true);
        prepareMemberToAdd();
        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     removes team member
      * @Returns:         PageReference - null
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public PageReference removeMember() {
        if (memberRowToDelete < members.size()) {
            try {
                Account_Team_Member__c member = members.remove(memberRowToDelete);
                delete member;
            } catch (DmlException e) {
                setErrorMessage(Label.errMsg_ErrorRemovingTeamMember);
                System.debug(e);
            }
        }
        countPlanProgress(true);
        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares select options of roles
      * @Returns:         List<SelectOption> - prepared options of roles
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public List<SelectOption> getRoleOptions() {
        Schema.DescribeFieldResult f = Account_Team_Member__c.Team_Role__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares select options of stage field
      * @Returns:         List<SelectOption> - prepared options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public List<SelectOption> getStageOptions() {
        Schema.DescribeFieldResult f = Client_Plan__c.Status__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares select options of expansion policy field
      * @Returns:         List<SelectOption> - prepared options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public List<SelectOption> getExpansionPolicyOptions() {
        Schema.DescribeFieldResult f = Client_Plan__c.Expansion_Policy__c.getDescribe();
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares select options of DG field
      * @Returns:         List<SelectOption> - prepared options
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public List<SelectOption> getDGOptions() {
        Schema.DescribeFieldResult f = Client_Plan__c.DG__c.getDescribe();
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
	                SELECT Name, SDS__c, Type
	                FROM Account 
	                WHERE ParentId = :plan.Relationship__c
	                AND SDS__c != NULL
	                AND SDS__c != ''
	                order by Name];
	            if (SDSClients.isEmpty()) {
	            	return SDSClientsSOps;
	        	} else {
	            	for (Account acc: SDSClients) {
	            		String Label;
	            		Label = acc.Name + ' - ' + acc.SDS__c;
	            		if (acc.Type != null && acc.Type != '') Label = Label + ' - ' + acc.Type;
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
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     returns the Label of the currently selected SDS Client Option above
      * @Returns:         String - selected option
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public String getSelectedSDSClient {
    	get {
    		String Label = '';
    		for(SelectOption so: getSDSClients)
    			if (so.getValue() == plan.SDS__c) Label = so.getLabel();
    		return Label;
    	}
    	set;
    }
    public String SelectedSDS {get;set;}
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     counts client plan progress
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private void countPlanProgress(Boolean queryPlan) {
        if (queryPlan) {
            queryPlan();
        }
    
        planProgress = 0;
        
        //max 36 percent
        planProgress += countProgressFromPlanObject();
        
        planProgress += (members.size() == 0 ? 0 : 4);
        
        if (plan.Strengths_Count__c > 0) planProgress += 2;
        if (plan.Weakness_Count__c > 0) planProgress += 2;
        if (plan.Opportunities_Count__c > 0) planProgress += 2;
        if (plan.Threat_Count__c > 0) planProgress += 2;
        
        Integer finInfoCount = Database.countQuery('SELECT count() FROM Financial_Information__c' +
            ' WHERE (Year__c = \'' + String.valueOf(Date.today().year() - 1) + '\' OR Year__c = \'' + Date.today().year() + '\')' +
            ' AND Relationship__c = \'' + plan.Relationship__c + '\'');
        
		if (finInfoCount > 0 || plan.Financial_Information_Image_ID__c != NULL) planProgress += 10;
        
        if (plan.Country_Presence_Count__c > 0) planProgress += 3;
        
        if (plan.Relationships_Count__c > 5) planProgress += 6;
        if (plan.Relationships_Count__c > 1) planProgress += 4;
        
        if (plan.Budget_Revenues_Count__c > 0) planProgress += 6;
        
        List<Client_Plan_Revenue_By_Product__c> cprbp = Database.Query('SELECT Tot_H12_Contribution__c, Tot_F12_Contribution__c' +
            ' FROM Client_Plan_Revenue_By_Product__c' +
            ' WHERE Client_Plan__c = \'' + planId + '\'' + 
            ' ORDER BY 	CreatedDate DESC ' + 
            ' LIMIT 1');
        if (cprbp.size() > 0 && cprbp[0].Tot_H12_Contribution__c > 0 && cprbp[0].Tot_F12_Contribution__c > 0) planProgress += 3;
        
        if (plan.Potential_Opportunities_Count__c > 0) planProgress += 4;
        
        Integer optyCount = Database.countQuery('SELECT count() FROM Opportunity' + 
            ' WHERE Client_Plan_Strategy__r.Client_Plan__c = \'' + planId + '\'');
        if (optyCount > 0) planProgress += 4;
        if (optyCount > 2) planProgress += 6;
        
        if (plan.Strategies_Count__c > 0) planProgress += 3;
        
        if (plan.Org_Structure_Items_Count__c > 1 || plan.Org_Structure_Image_ID__c != NULL) planProgress += 3;
        
        plan.Progress__c = planProgress;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares empty team member
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void prepareMemberToAdd() {
        memberToAdd = new Account_Team_Member__c();
        memberToAdd.Organisation__c = plan.Relationship__c;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     queries team members
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void queryTeamMembers() {
        members = [
            SELECT Id, Team_Member__r.Name, Team_Role__c
            FROM Account_Team_Member__c
            WHERE Organisation__c = :plan.Relationship__c];
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
                SELECT Id, Relationship__c, Relationship__r.Name, Relationship__r.OwnerId, Relationship__r.Owner.Name,
                    LastModifiedDate, Status__c, Client_Overview__c, DG__c, FAIS_Status__c, Financial_Year_End__c, 
                    Latest_Audited_Financial_Statement__c, Sector_Overview__c, TFL__c, Expansion_Policy__c,
                    Org_Structure_Items_Count__c, Country_Presence_Count__c, Budget_Revenues_Count__c, 
                    Potential_Opportunities_Count__c, Relationships_Count__c, Strategies_Count__c, LGD__c, 
                    Override_Pull_DG_From_SPEAR__c, DG_Last_Pulled_From_SPEAR__c, SDS__c, Relationship__r.Type,
                	Financial_Information_Image_ID__c, Org_Structure_Image_ID__c, Strengths_Count__c, Weakness_Count__c,
                	Opportunities_Count__c, Threat_Count__c, RoRWA_Existing__c
                FROM Client_Plan__c 
                WHERE Id = :planId];
        } catch (Exception e) {
            planLoaded = false;
            return;
        }
        
        if (plans.isEmpty()) {
            planLoaded = false; 
        } else {
            planLoaded = true;
            plan = plans[0];
        }
    }
    
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     counts progress from plan object fields
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private Integer countProgressFromPlanObject() {
        Integer perc = 0;
        
        if (plan.Client_Overview__c != null && plan.Client_Overview__c.length() > 20) perc += 10;
        if (plan.Status__c != null) perc += 2;
        if (plan.Expansion_Policy__c != null) perc += 2;
        if (plan.DG__c != null && plan.DG__c != '- Not Available -') perc += 2;
        if (plan.FAIS_Status__c != null) perc += 2;
        if (plan.Financial_Year_End__c != null) perc += 2;
        if (plan.Latest_Audited_Financial_Statement__c != null) perc += 2;
        if (plan.Sector_Overview__c != null && plan.Sector_Overview__c.length() > 20) perc += 10;
        if (plan.TFL__c != null) perc += 2;
        if (plan.RoRWA_Existing__c != null) perc += 2;
        
        return perc;
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
        for (Schema.PicklistEntry e: p) {
            options.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        return options;
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
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
	
	/**
      * @Author:          Dino Scarcella
      * @Company:         Absa Capital
      * @Description:     Method to return SPEAR information on this SDS
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
   	private SPEAR sp = new SPEAR();
   	public SPEAR spear {get {return sp;} set;}
    public void getSPEARData() {
        spear.RetrieveRatingFeedSync(SelectedSDS,'','',false);
    }
    public Long DGLastPulledFromSPEARMillis {
   		get;
   		set
   		{
   			if(value > 0) {
				plan.DG_Last_Pulled_From_SPEAR__c = DateTime.newInstance(value);
			}
   		}
   	}
   	public Double offset{
   		get{
	        TimeZone tz = UserInfo.getTimeZone();
	        return tz.getOffset(DateTime.now()) / (1000 * 3600 * 24.0);
    	}
   	}
}