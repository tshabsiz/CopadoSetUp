/**
* @Author       Marek Cech
* @Company:     Deloitte
* @Description: Controller class for ClientPlanSummary VF page.
* @Date:        1/2016
* @ConstructorParam:      None
* @TestClass:   ZZTEST_ClientPlanSummaryController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
*------------------------------------------------------------*/
public class ClientPlanSummaryController extends ClientPlanUtils{

    public String planId {get;set;}
    public Boolean planLoaded {get;set;}
    public Client_Plan__c plan {get;set;}
    
    //controllers of other client plan tabs
    public ClientPlanDetailsController detailsCtrl {get;set;}
    public ClientOverviewController overviewController {get;set;}
    public ClientPlanOrgStructureController orgStructureController {get;set;}
    public ClientFinancialsController financialsController {get;set;}
    public ClientPresenceController presenceController {get;set;}
    public ClientPlanStrategyController strategyController {get;set;}
    public ClientPlanController planController {get;set;}
    public ClientPlanRevenueByProductController planRevByProductController {get;set;}
    
    //richtexts
    public String sectorOverview {get;set;}
    public String clientOverview {get;set;}

    //What pages to render
    public String pageOverview {get;set;}
    public String pageClientSector {get;set;}
    public String pageOwnership {get;set;}
    public String pageSwot {get;set;}
    public String pageStakeHolders {get;set;}
    public String pagePresence {get;set;}
    public String pageFinancials {get;set;}
    public String pageFacilitiesBreakdown {get;set;}
    public String pageRevenuesByProduct {get;set;}
    public String pageStrategies {get;set;}
    public String pageOpportunities {get;set;}
    public String pageContactBios {get;set;}

    private static final String countriesQuery = ' AND (Engaged__c = \'Primary Bank\' OR Engaged__c = \'Not Primary Bank\'' + ' OR Engaged__c = \'Present But Not Banking\' OR Engaged__c = \'Barclays Not Present\')';

    public ClientPlanSummaryController() {
        super(ApexPages.currentPage().getParameters().get('planId'),'planId');
        this.planId = ApexPages.currentPage().getParameters().get('planId');
        this.plan = queryPlan();
        
        if(this.plan != null) {
            //details tab
            ApexPages.StandardController sc = new ApexPages.StandardController(this.plan);
            detailsCtrl = new ClientPlanDetailsController(sc);
            
            //overview tab
            overviewController = new ClientOverviewController();
            sectorOverview = ClientOverviewController.getSectorOverview(this.planId);
            clientOverview = ClientOverviewController.getClientOverview(this.planId);
            orgStructureController = new ClientPlanOrgStructureController();
            
            //financials tab
            financialsController = new ClientFinancialsController();
            financialsController.financeList = ClientFinancialsController.queryFinancialInformation(this.plan, 0, 5);
            
            //presence tab
            presenceController = new ClientPresenceController();
            
            //strategy tab
            strategyController = new ClientPlanStrategyController();
            
            //plan tab
            planController = new ClientPlanController();

            //revenue by product component controller (embedded in Plan tab)
            planRevByProductController = new ClientPlanRevenueByProductController();
            queryACMFacilities();
        }
    }

    /* New Method to generate the PDF Server-side & 2 helper functions to store Canvas images */
    public PageReference generatePdf() {
        PageReference printView = Page.ClientPlanSummaryPrintView;
        printView.getParameters().put('id', this.planId);
		printView.getParameters().put('planId', this.planId);
        printView.getParameters().put('pageOverview', 'true'); //Force pageOverview
        printView.getParameters().put('pageClientSector', pageClientSector);
        printView.getParameters().put('pageOwnership', pageOwnership);
        printView.getParameters().put('pageSwot', pageSwot);
        printView.getParameters().put('pageStakeHolders', pageStakeHolders);
        printView.getParameters().put('pagePresence', pagePresence);
        printView.getParameters().put('pageFinancials', pageFinancials);
        printView.getParameters().put('pageFacilitiesBreakdown', pageFacilitiesBreakdown);
        printView.getParameters().put('pageRevenuesByProduct', pageRevenuesByProduct);
        printView.getParameters().put('pageStrategies', pageStrategies);
        printView.getParameters().put('pageOpportunities', pageOpportunities);
        printView.getParameters().put('pageContactBio', pageContactBios);

        printView.setRedirect(true);
        
        Attachment att = new Attachment();
        Blob body = Test.isRunningTest() ? Blob.ValueOf('dummy text') : printView.getContent();
        att.Body = body;
        att.Name = 'Client Plan - ' + this.plan.Relationship__r.Name + ' - ' + System.now().format('yyyy-MM-dd') + '.pdf';
        att.ContentType = 'application/pdf';        
        att.parentId = this.planId;
        
        try {
            //Retrieve the ID for a previous PDF if it's there
            Id oldPdfAttachmentId = getDocumentId();

            //Insert new PDF
            INSERT att;

            //Delete old PDF attachment
            if(oldPdfAttachmentId != null) {
                DELETE [SELECT Id from Attachment WHERE Id = :oldPdfAttachmentId AND ContentType = 'application/pdf'];
            }

            //Requery ClientPlan
            this.plan = queryPlan();
        } catch(DmlException ex) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, ex.getMessage()));
            return null;
        }

        //PageReference pageRef = new ApexPages.StandardController(jloc).view();
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Client Plan PDF has been (re-)generated.'));
        return null;
    }

    @RemoteAction
    public static String savePresenceImg(String planId, String imgSrc) {
        if(!String.isEmpty(planId) && !String.isEmpty(imgSrc)) {
            try {
                //First locate the ClientPlan
                Client_Plan__c clientPlan = queryClientPlanForImageGeneration(planId);
                if(clientPlan == null) {
                    throw new ClientPlanSummaryException('No ClientPlan found');
                }

                //imgSrc will come in as 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA+gAAAKHCAYAAAASdmLfAAAgAElEQVR****'
                //System.debug(imgSrc);
                
                String imgSrcData = imgSrc.substring(imgSrc.indexOf(',') + 1);
                //System.debug(imgSrcData);

                Blob imgBody = EncodingUtil.base64Decode(imgSrcData);
                //String imgBody = EncodingUtil.base64Decode(imgSrc).toString();

                Attachment a = new Attachment();
                a.Body = imgBody;
                a.Name = 'PresenceMap - Generated ' + DateTime.now();
                a.ContentType = 'image/png';
                a.ParentId = planId;
                INSERT a;

                //If image was saved succesfull - update reference to it on ClientPlan
                if(a.Id != null) {
                    if(!String.isEmpty(clientPlan.Country_Presence_Image_ID__c)) {
                        //Delete old Image
                        DELETE [
                            SELECT  Id 
                            FROM    Attachment
                            WHERE   ParentId = :planId AND Id = :clientPlan.Country_Presence_Image_ID__c
                        ];
                    }

                    clientPlan.Country_Presence_Image_ID__c = a.Id;
                    UPDATE clientPlan;
                }
            } catch(Exception e) {
                System.debug(e);
                throw new ClientPlanSummaryException(e);
            }
        } else {
            throw new ClientPlanSummaryException('both planId and imgSrc are required');
        }

        return null;
    }

    @RemoteAction
    public static String saveGroupImg(String planId, String imgSrc) {
        if(!String.isEmpty(planId) && !String.isEmpty(imgSrc)) {
            try {
                //First locate the ClientPlan
                Client_Plan__c clientPlan = queryClientPlanForImageGeneration(planId);
                if(clientPlan == null) {
                    throw new ClientPlanSummaryException('No ClientPlan found');
                }

                //imgSrc will come in as 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAA+gAAAKHCAYAAAASdmLfAAAgAElEQVR****'
                //System.debug(imgSrc);
                
                //If we get a 1-byte imgSrc just delete any existing stored image
                if(imgSrc.length() == 1) {
                    if(clientPlan.Group_Structure_Image_ID__c != null) {
                        //Delete old Image
                        DELETE [
                            SELECT  Id 
                            FROM    Attachment
                            WHERE   ParentId = :planId AND Id = :clientPlan.Group_Structure_Image_ID__c
                        ];

                        clientPlan.Group_Structure_Image_ID__c = null;
                        UPDATE clientPlan;
                    }
                } else {
                    String imgSrcData = imgSrc.substring(imgSrc.indexOf(',') + 1);
                    //System.debug(imgSrcData);

                    Blob imgBody = EncodingUtil.base64Decode(imgSrcData);
                    //String imgBody = EncodingUtil.base64Decode(imgSrc).toString();

                    Attachment a = new Attachment();
                    a.Body = imgBody;
                    a.Name = 'GroupMap - Generated ' + DateTime.now();
                    a.ContentType = 'image/png';
                    a.ParentId = planId;
                    INSERT a;

                    //If image was saved succesfull - update reference to it on ClientPlan
                    if(a.Id != null) {
                        if(!String.isEmpty(clientPlan.Group_Structure_Image_ID__c)) {
                            //Delete old Image
                            DELETE [
                                SELECT  Id 
                                FROM    Attachment
                                WHERE   ParentId = :planId AND Id = :clientPlan.Group_Structure_Image_ID__c
                            ];
                        }

                        clientPlan.Group_Structure_Image_ID__c = a.Id;
                        UPDATE clientPlan;
                    }
                }
            } catch(Exception e) {
                System.debug(e);
                throw new ClientPlanSummaryException(e);
            }
        } else {
            throw new ClientPlanSummaryException('both planId and imgSrc are required');
        }

        return null;
    }

    private static Client_Plan__c queryClientPlanForImageGeneration(String clientPlanId) {
        List<Client_Plan__c> plans = [
            SELECT  Id, Country_Presence_Image_ID__c, Group_Structure_Image_ID__c
            FROM    Client_Plan__c 
            WHERE   Id = :clientPlanId
        ];
        
        if(!plans.isEmpty()) {
            return plans.get(0);
        }

        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares data for organogram
      * @Params:          Id of client plan
      * @Returns:         String - JSON with data
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String getOrganogramData(String planId) {
        return ClientPlanOrgStructureController.getData(planId);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares data for country presence map
      * @Params:          Id of client plan
      * @Returns:         String - JSON with data
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String queryCountries(String planId) {
        return ClientPresenceController.queryCountries(planId, countriesQuery);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     prepares data for stakeholders hierarchy
      * @Params:          Id of client plan
      * @Returns:         String - JSON with data
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @RemoteAction
    public static String getStakeholdersHierarchyData(String planId) {
        return ClientPlanStakeholdersHierarchyCtr.getHierarchyChartData(planId);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of Id of previously generated PDF
      * @Returns:         String - document Id or null if there is no document
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    public String getDocumentId() {
        List<Attachment> atts = [
            SELECT  Id
            FROM    Attachment
            WHERE   ContentType = 'application/pdf' AND ParentId = :this.planId
        ];
    
        if(!atts.isEmpty()) {
            return atts[0].Id;
        } else {
            return null;
        }
    }

    @testVisible
    public String getDocumentTimestamp() {
        List<Attachment> atts = [
            SELECT  CreatedDate
            FROM    Attachment
            WHERE   ContentType = 'application/pdf' AND ParentId = :this.planId
        ];
    
        if(!atts.isEmpty()) {
            String s = String.valueOfGmt(atts[0].CreatedDate);
            return s;
        } else {
            return null;
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     queries client plan
      * @Returns:         Client_Plan__c 
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private Client_Plan__c queryPlan() {
        List<Client_Plan__c> plans = [
            SELECT  Id, Org_Structure_Image_ID__c, Relationship__r.Name
            FROM    Client_Plan__c 
            WHERE   Id = :this.planId
        ];
        
        if(plans.isEmpty()) {
            planLoaded = false;
            return null;
        } else {
            planLoaded = true;
            return plans[0];
        }
    }

    public class ClientPlanSummaryException extends Exception {}
}