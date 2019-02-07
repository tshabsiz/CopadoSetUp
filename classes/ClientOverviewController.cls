/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientOverview VF page.
* @Date:        10/2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientOverviewController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 11.2.2016     Svata Sejkora       changing methods for querying strenghts and weaknesses to acompany new field. adding methods to query threats and opportunities
*------------------------------------------------------------*/


public class ClientOverviewController extends ClientPlanUtils{

    public Client_Plan__c plan {get;set;}
    
    public Boolean planLoaded {get;set;}
    
    public List<Client_Score__c> strengths {get;set;}
    
    public List<Client_Score__c> weaknesses {get;set;}

    public List<Client_Score__c> threats {get;set;}

    public List<Client_Score__c> opportunities {get;set;}
    
    //score modification variables
    public String scoreType {get;set;} //isStrength
    
    public String scoreId {get;set;}
    
    public String scoreName {get;set;}
    
    public String description {get;set;}
    
    @testVisible
    private String errorMessage;
    private final String STRENGTH = 'Strength';
    private final String OPPORTUNITY = 'Opportunity';
    private final String THREAT = 'Threat';
    private final String WEAKNESS = 'Weakness';
    
    public ClientOverviewController() {
        super(ApexPages.currentPage().getParameters().get('planId'),'planId');
        String planId = ApexPages.currentPage().getParameters().get('planId');
        if(String.isEmpty(planId)) {
            planId = ApexPages.currentPage().getParameters().get('id');
        }
        if (!String.isEmpty(planId)) {
            queryPlan(planId);
            if (planLoaded) {
                queryStrengths();
                queryWeaknesses();
                queryOpportunities();
                queryThreats();
            }
        } else {
            planLoaded = false;
        }
    }
    
     /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of sector overview
      * @Params:          Id of client plan
      * @Returns:         String - sector overview data
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String getSectorOverview(String planId) {
        List<Client_Plan__c> plans = [SELECT Sector_Overview__c FROM Client_Plan__c WHERE Id = :planId];
        
        if (!plans.isEmpty()) {
            return plans[0].Sector_Overview__c == null ? '' : plans[0].Sector_Overview__c;
        } else {
            return null;
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of client overview
      * @Params:          Id of client plan
      * @Returns:         String - client overview data
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String getClientOverview(String planId) {
        List<Client_Plan__c> plans = [SELECT Client_Overview__c FROM Client_Plan__c WHERE Id = :planId];
        
        if (!plans.isEmpty()) {
            return plans[0].Client_Overview__c == null ? '' : plans[0].Client_Overview__c;
        } else {
            return null;
        }
    }
    @RemoteAction
    public static String getExecutiveSummary(String planId) {
        List<Client_Plan__c> plans = [SELECT Executive_Summary__c FROM Client_Plan__c WHERE Id = :planId];
        
        if (!plans.isEmpty()) {
            return plans[0].Executive_Summary__c == null ? '' : plans[0].Executive_Summary__c;
        } else {
            return null;
        }
    }
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     saves richtext content
      * @Params:          Id of client plan, content to save, boolean indicating whether 
      *                       data is for sector or client
      * @Returns:         Boolean - true if an error occured, false otherwise
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static Boolean saveRichtext(String planId, String data, Boolean isSector) {
        List<Client_Plan__c> plans = [
            SELECT Id, Client_Overview__c, Sector_Overview__c
            FROM Client_Plan__c 
            WHERE Id = :planId];
            
        if (plans.isEmpty()) {
            return true;
        }
        
        Client_Plan__c plan = plans[0];
        if (isSector) {
            plan.Sector_Overview__c = data;
        } else {
            plan.Client_Overview__c = data;
        }
        
        try {
            update plan;
        } catch (DmlException e) {
            System.debug(e);
            return true;
        }
        return false;
    }
    @RemoteAction
    public static Boolean saveExecutiveSummary(String planId, String data) {
        List<Client_Plan__c> plans = [
            SELECT Id, Client_Overview__c, Sector_Overview__c,Executive_Summary__c
            FROM Client_Plan__c 
            WHERE Id = :planId];
        
        if (plans.isEmpty()) {
            return true;
        }
        
        Client_Plan__c plan = plans[0];
        
        plan.Executive_Summary__c = data;
        
        try {
            update plan;
        } catch (DmlException e) {
            System.debug(e);
            return true;
        }
        return false;
    }
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     removes score
      * @Returns:         PageReference - null
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public PageReference removeScore() {
        Client_Score__c cs = getScoreToModify(true);
        if (cs == null) {
            setErrorMessage(Label.errMsg_RecordNotFound);
            return null;
        }
        
        try {
            delete cs;
        } catch (Exception e) {
            System.debug(e);
            setErrorMessage(Label.errMsg_ErrorDuringSaving);
        }
        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     modifies score
      * @Returns:         PageReference - null
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public PageReference modifyScore() {
        if (scoreId == '') {
            addScore();
        } else {
            editScore();
        }
        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     adds score
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      * 11.2.2016   Svata Sejkora       Changed logic for determining type of score to acompany change of data model
      *------------------------------------------------------------*/
    private void addScore() {
        Client_Score__c score = new Client_Score__c();
        score.Client_Plan__c = plan.Id;
        score.Score_Type__c = scoreType;
        score.Name = scoreName;
        score.Description__c = description;
        
        try {
            INSERT score;
        } catch (Exception e) {
            System.debug(e);
            
            if (scoreType == STRENGTH) {
                setErrorMessage(Label.errMsg_ErrorAddingClientStrength);
            } else if (scoreType == WEAKNESS) {
                setErrorMessage(Label.errMsg_ErrorAddingClientWeakness);
            } else if (scoreType == OPPORTUNITY) {
                setErrorMessage(Label.errMsg_ErrorAddingClientOpportunity);
            } else {
                setErrorMessage(Label.errMsg_ErrorAddingClientThread);
            }

            return;
        }
        
        if (scoreType == STRENGTH) {
            strengths.add(score);
        } else if (scoreType == WEAKNESS){
            weaknesses.add(score);
        } else if (scoreType == OPPORTUNITY) {
            System.debug('SCORE WUBWUB' + score);
            opportunities.add(score);
        } else {
            threats.add(score);
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     score editation
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void editScore() {
        Client_Score__c cs = getScoreToModify(false);
        if (cs == null) {
            setErrorMessage(Label.errMsg_RecordNotFound);
            return;
        }
        
        cs.Name = scoreName;
        cs.Description__c = description;
        
        try {
            update cs;
        } catch (Exception e) {
            System.debug(e);
            setErrorMessage(Label.errMsg_ErrorDuringEditation);
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     looks for score to modify
      * @Params           Boolean remove - indicates whether score has to be removed from list of scores
      * @Returns:         Client_Score__c - score to modify
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private Client_Score__c getScoreToModify(Boolean remove) {
        List<Client_Score__c> toIterate;
        if (scoreType == STRENGTH) {
            toIterate = strengths;
        } else if(scoreType == WEAKNESS) {
            toIterate = weaknesses;
        } else if (scoreType == OPPORTUNITY) {
            toIterate = opportunities;
        } else {
            toIterate = threats;
        }
        
        Client_Score__c cs;
        for (Integer i = 0; i < toIterate.size(); i++) {
            cs = toIterate.get(i);
            try {
                if (cs.Id == scoreId) {
                    if (remove) {
                        return toIterate.remove(i);
                    } else {
                        return cs;
                    }
                }
            } catch (Exception e) {
                continue;
            }
        }
        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     queries strengths
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void queryStrengths() {
        strengths = [
            SELECT Id, Name, Description__c
            FROM Client_Score__c
            WHERE Client_Plan__c = :plan.Id AND Score_Type__c = :STRENGTH
            ORDER BY CreatedDate ASC
        ];
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     queries weaknesses
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void queryWeaknesses() {
        weaknesses = [
            SELECT Id, Name, Description__c
            FROM Client_Score__c
            WHERE Client_Plan__c = :plan.Id AND Score_Type__c = :WEAKNESS
            ORDER BY CreatedDate ASC
        ];
    }

    /**
      * @Author:          Svatopluk Sejkora
      * @Company:         Deloitte
      * @Description:     queries opportunities
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void queryOpportunities() {
        opportunities = [
            SELECT Id, Name, Description__c
            FROM Client_Score__c
            WHERE Client_Plan__c = :plan.Id AND Score_Type__c = :OPPORTUNITY
            ORDER BY CreatedDate ASC
        ];
    }

    /**
      * @Author:          Svata Sejkora
      * @Company:         Deloitte
      * @Description:     queries threats
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void queryThreats() {
        threats = [
            SELECT Id, Name, Description__c
            FROM Client_Score__c
            WHERE Client_Plan__c = :plan.Id AND Score_Type__c = :THREAT
            ORDER BY CreatedDate ASC
        ];
    }    
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     queries client plan
      * @Params:          Id of client plan
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void queryPlan(String planId) {
        List<Client_Plan__c> plans = [
                SELECT Id
                FROM Client_Plan__c 
                WHERE Id = :planId];
            
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
      * @Params           String errorMessage to set
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public void setErrorMessage(String errorMessage) {
        this.errorMessage = errorMessage;
    }
    
}