/**
 * This class is used for Matters - Creating a Matter
------------------------------------------------------------------------------------------------------
@ Modified By   : Kyle Alexander
@ Date          : 29/03/2018
@ Description   : Forced status to be set as 'Open' for Legal and Litigation Matters
------------------------------------------------------------------------------------------------------
@ Modified By   : Kyle Alexander
@ Date          : 20/06/2018
@ Description   : Code cleap up as a part of code handover
------------------------------------------------------------------------------------------------------
**/

Public with Sharing class KnowledgeHandlerV2 {

    Public String Name1, Name2, BusinessUnit, Summary, MatterType, Category, Notes;
    Public String MatterId;
    Public advpm__Matter__c Matter { get; set; }
    Public Set<String> ContentSelected;
    Public Boolean refreshPage { get; set; }

    Public RecordType[] ContentRecordType;

    Public String Description { get; set; }

    public static Map <String, Schema.RecordTypeInfo> mapParticipantRecordTypes = advpm__Participant__c.sObjectType.getDescribe().getRecordTypeInfosByName();
    public advpm__Participant__c participantControl { get; set; }

//------Litigation
    public String boxEmbedURL { get; set; }

    public Boolean showDuplicates { get; set; }
    public List<Duplicate> potentialDuplicates { get; set; }
    public List<Business_Unit_Claim__c> claims { get; set; }
    public List<advpm__Participant__c> participants { get; set; }
    public Boolean showBox { get; set; }
    Public Boolean showClosure { get; set; }

    Public String selectedType { get; set; }

    Public Boolean showCancel { get; set; }
    Public Boolean showDocuments { get; set; }
    public String boxFolderId { get; set; }
    Public Map<String, String> Map_BusinesUnit;

    Public Boolean showUser { get; set; }
    Public Boolean showContact { get; set; }

    public List<ContentVersion> ContentVersions { get; set; }
    public List<KnowledgeLibrary> lst_LibraryDisplay { get; set; }
    public List<KnowledgeLibrary> lst_LibrarySelected { get; set; }

    Public List<Case> CaseSearch { get; set; }
    public List<CaseApproval> lst_CaseDisplay { get; set; }
    public List<CaseApproval> lst_CaseSelected { get; set; }


    Public String strRecordTypeName { get; set; }

    public KnowledgeHandlerV2() {}
    
    /**
     * Construtor used to setup data and varibles on page load.
     * 
     * Sets up varibles used later by other methods, intializes lists , then calls  checkRecordType(); method, then calls the  addClaim(); method, if the invoking url has a matter id then it populates the 
     * Matter varible based on the Matter Id paremeter passed by the page, else it uses the standard controller to generate a new matter record and then sets up data on the new matter record by selecting product info
     * and sets matter record type to one passed as a paremeter.
     * then CaseSearch list is populated via soql where Status='Ready For Review'
     * lst_Business list is popluated via soql
     * 
     * @return void returns null as it is a void method.
     */
    public KnowledgeHandlerV2(ApexPages.StandardController controller) {
        
        //Clear the selected participant role and record type for participant add functions.
        participantControl = new advpm__Participant__c(advpm__Role__c = '');
        participantControl.RecordTypeId = mapParticipantRecordTypes.get('Contact').getRecordTypeId();
        showContact = true;
        showUser = false;
		
        //Initialise default selected view.
        checkRecordType();
		
        //Clear inputs.
        Name1 = '';
        Name2 = '';
        BusinessUnit = '';
        Description = '';
        Summary = '';
        MatterType = '';
        Category = '';
        Notes = '';
        showClosure = false;
        
        //Litigation
        if (potentialDuplicates == null) {
            potentialDuplicates = new List<Duplicate>();
        }

        participants = new List<advpm__Participant__c>();
        claims = new List<Business_Unit_Claim__c>();
        addClaim();

        showDuplicates = false;
        showBox = false;

        ContentSelected = new Set<String>();
        CaseSearch = new List<Case>([Select id,Description,SuggestedTags__c,SuggestedLibrary__c,Subject From Case where Status = 'Ready For Review' limit 950]);

        AddtoWrapper();

        Matter = new advpm__Matter__c();
        showDocuments = true;
        showCancel = true;

        if (strRecordTypeName == 'Legal') {
            showDocuments = false;
        }

        if (apexpages.currentpage().getparameters().get('id') != null) {
            MatterId = apexpages.currentpage().getparameters().get('Id');
            Matter = [
                    Select recordType.Name,Name,Reputational_Risk__c,advpm__Engagement_Date__c,Cost_Centre__c,
                            Jurisdiction__c,Customer_account_number_policy_number__c,Litigation_Status__c,Client_Branch_code__c,
                            advpm__Description__c,Total_Claim_Percentage__c,Matter_Type__c,Category__c,advpm__Legal_Hold__c,
                            Claim_By_Against_Barclays__c,Reasonably_Possible__c,Approval_Status__c,Probable_For_Approval__c,
                            Financial_Value_Unknown__c,Matter_Value__c,Attainable_litigation_objective__c,Securitization_value__c,
                            Current_Status__c,Notes__c,Previous_current_status__c,Disposition_Type__c,advpm__Projected_Date_Of_Closure__c,
                            Disposition_Description__c,Probable_Approved__c,Positive_Outcome_Before_All_Costs__c,Negative_Outcome_Before_All_Costs__c,Costs_Awarded_Against_Barclays__c,
                            Costs_Actually_Recovered__c,Remote__c, Lead_Lawyer_Office__c, Business_Unit_Cluster_Segment__r.Name,Business_Unit_Cluster_Segment__c,advpm__Status__c,
                            Date_of_Closure__c,TotalDispositionAmount__c,Reputational_Risk_Type__c,Percentage__c,advpm__Primary_Account__c,advpm__Primary_Contact__c,Owner.Name,
                            Review_Frequency_days__c,Next_Review_Date__c
                    From advpm__Matter__c
                    Where Id = :MatterId
                    limit 1
            ];

            strRecordTypeName = Matter.recordType.Name;
            system.debug('**One**' + strRecordTypeName);

            Name1 = Matter.Name;
            Name2 = Matter.Name;
            if (Matter.Business_Unit_Cluster_Segment__r.Name != null) {
                BusinessUnit = Matter.Business_Unit_Cluster_Segment__r.Name;
            }


            if (Matter.advpm__Description__c != null) {
                Summary = Matter.advpm__Description__c;
            }


            if (Matter.Matter_Type__c != null) {
                MatterType = Matter.Matter_Type__c;
            }

            if (Matter.Category__c != null) {
                Category = Matter.Category__c;
            }

            if (Matter.Notes__c != null) {
                Notes = Matter.Notes__c;
            }

            showClosure = true;
            FullSearch();
        } else {

            Matter = (advpm__Matter__c) controller.getRecord();

            List<Product_Level_2__c> products = new List<Product_Level_2__c>();
            products = [select id, name from Product_Level_2__c where name = 'Legal Agreement Product' limit 1];
            if (products.size() > 0) {
                Matter.Product2__c = products.get(0).id;
            }

            if (ApexPages.currentPage().getParameters().get('RecordType') == null) {
                Schema.DescribeSObjectResult describeRequest = Schema.SObjectType.advpm__Matter__c;
                List<Schema.RecordTypeInfo> rtInfos = describeRequest.getRecordTypeInfos();

                for (Schema.RecordTypeInfo rtInfo : rtInfos) {
                    // walk through the map to determine the correct record type, this is done with the isAvailable() function
                    if (rtInfo.getName() != 'Master' && rtInfo.isAvailable()) {
                        // below lines will only run one time only
                        System.debug('The RecordType :' + rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() + ' is available, adding it as parameter to the page.');

                        strRecordTypeName = rtInfo.getName();
                        Matter.RecordTypeId = rtInfo.getRecordTypeId();
                    }
                }

            } else {
                strRecordTypeName = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosById().get(Matter.RecordTypeId).getName();
            }

            if (strRecordTypeName != 'Legal') {
                showCancel = false;
            }
        }

        List<Business_Unit__c> lst_Business = [Select id,name from Business_Unit__c];
        Map_BusinesUnit = new Map<String, String>();

        for (Business_Unit__c b : lst_Business) {
            Map_BusinesUnit.put(b.id, b.name);
        }
    }
	
     /**
     * Used to determine which section is rendered on the VF page.
     * 
     * Used to set showUser and showContact varibles to true or false based on recordType selected by the current user on the VF page.
     * 
     * @return void returns null as it is a void method.
     */
    public void checkRecordType() {
        if (selectedType == mapParticipantRecordTypes.get('User').getRecordTypeId()) {
            showUser = true;
            showContact = false;
        } else if (selectedType == mapParticipantRecordTypes.get('Contact').getRecordTypeId()) {
            showUser = false;
            showContact = true;
        }
    }

     /**
     * Runs the search with parameters passed via Javascript, checks and setups the varibles based on the strRecordTypeName varible and calls the FullSearch method.
     * 
     * @return PageReference Returns null which causes the VF page to refresh
     * 
     * @return void returns null as it is a void method.
     */
    public PageReference runContactSearch() {

        if (strRecordTypeName == 'Legal') {
            if (Matter.name == Null) {
                Name1 = '';
            } else {
                Name1 = Matter.name;
            }

            if (Matter.Business_Unit_Cluster_Segment__c == Null) {
                BusinessUnit = '';
            } else {
                BusinessUnit = Map_BusinesUnit.get(Matter.Business_Unit_Cluster_Segment__c);
            }
        }

        else {

            if (Matter.name == Null) {
                Name2 = '';
            } else {
                Name2 = Matter.name;
            }

            if (Matter.advpm__Description__c == Null) {
                Summary = '';
            } else {
                Summary = Matter.advpm__Description__c;
            }

            if (Matter.Matter_Type__c == Null) {
                MatterType = '';
            } else {
                MatterType = Matter.Matter_Type__c;
            }
            if (Matter.Matter_Type__c == Null) {
                Category = '';
            } else {
                Category = Matter.Matter_Type__c;
            }


            if (Matter.Notes__c == Null) {
                Notes = '';
            } else {
                Notes = Matter.Notes__c;
            }
        }

        system.debug('**N**' + Name1 + '**BU**' + BusinessUnit);

        FullSearch();

        return null;

    }

     /**
     * Searches for cases linked to the matter for later use and adds them to a wrapper list for latter use.
     * 
     * Searches for cases using sosl and then soql if sosl returns no results, it then populates the CaseSearch list with the search results, then the AddtoWrapper();
     * 
     * @return void returns null as it is a void method.
     */
    Public void FullSearch() {


        String FinalSearch = '';

        if (Description != Null && Description.length() > 1) {
            FinalSearch = Description;
        }
        if (strRecordTypeName == 'Legal') {


            if (Name1.length() > 1) {
                if (FinalSearch.length() > 1) {
                    FinalSearch += ' OR ' + Name1;
                } else {
                    FinalSearch = Name1;
                }
            }
            if (BusinessUnit.length() > 1) {
                if (FinalSearch.length() > 1) {
                    FinalSearch += ' OR ' + BusinessUnit;
                } else {
                    FinalSearch = BusinessUnit;
                }
            }
        } else {


            if (Name2.length() > 1) {
                if (FinalSearch.length() > 1) {
                    FinalSearch += ' OR ' + Name2;
                } else {
                    FinalSearch = Name2;
                }
            }

            if (Summary.length() > 1) {
                if (FinalSearch.length() > 1) {
                    FinalSearch += ' OR ' + Summary;
                } else {
                    FinalSearch = Summary;
                }
            }
            if (MatterType.length() > 1) {
                if (FinalSearch.length() > 1) {
                    FinalSearch += ' OR ' + MatterType;
                } else {
                    FinalSearch = MatterType;
                }
            }
            if (Category.length() > 1) {
                if (FinalSearch.length() > 1) {
                    FinalSearch += ' OR ' + Category;
                } else {
                    FinalSearch = Category;
                }
            }
            if (Notes.length() > 1) {
                if (FinalSearch.length() > 1) {
                    FinalSearch += ' OR ' + Notes;
                } else {
                    FinalSearch = Notes;
                }
            }
        }


        system.Debug('**FinalSearch***' + FinalSearch);

        if (FinalSearch.length() > 1) {

            list<list<sObject>> searchList = [
                    FIND:FinalSearch
                    IN ALL FIELDS
                            RETURNING Case(Description, SuggestedTags__c, SuggestedLibrary__c, Subject Where Status = 'Ready For Review' )
                    limit 950
            ];


            if (lst_CaseDisplay.size() > 0) {
                system.debug('**Check1***');
                checkSelected();
            }
            CaseSearch = (Case[]) searchList[0];


        } else {
            if (lst_CaseDisplay.size() > 0) {
                system.debug('**Check2***');
                checkSelected();
            }

            CaseSearch = [Select id,Description,SuggestedTags__c,SuggestedLibrary__c,Subject From Case where Status = 'Ready For Review' limit 950];
        }

        AddtoWrapper();

        system.Debug('**LIB*' + lst_LibraryDisplay);
    }

     /**
     * Runs through the CaseApproval list lst_CaseDisplay and adds or removes the CaseApproval varible from the ContentSelected list based on the CasSelect attribute.
     */
    public void checkSelected() {
        for (CaseApproval d : lst_CaseDisplay) {

            if (d.CasSelect == true) {
                ContentSelected.Add(d.CasId);
                system.debug('**ADD***');
            } else if (d.CasSelect == false && ContentSelected.contains(d.CasId)) {
                ContentSelected.remove(d.CasId);
                system.debug('**REMOVE***');
            }
        }
        system.debug('**CON1***' + ContentSelected);
    }

     /** 
     * Populates lst_CaseDisplay for later use based off CaseSearch.
     * 
     * Runs through the case list CaseSearch and creates a new CaseApproval var for each case in the list and adds each new CaseApproval to the CaseApproval list lst_CaseDisplay.
     * 
     * @return void returns null as it is a void method.
     */
    Public void AddtoWrapper() {

        lst_CaseDisplay = new List<CaseApproval>();

        system.debug('**CON2***' + ContentSelected);

        for (Case v : CaseSearch) {
            CaseApproval cas = new CaseApproval();
            cas.CasId = v.id;
            cas.CasSubject = v.Subject;
            cas.CasSuggestedTags = v.SuggestedTags__c;
            cas.CasSuggestedLibrary = v.SuggestedLibrary__c;
            cas.CasDescription = v.Description;
            if (ContentSelected.contains(v.id)) {
                cas.CasSelect = true;
            }

            lst_CaseDisplay.Add(cas);
        }
    }

     /**
     *  Creates or updates current matter record and Adds new matter content based on what the user has selected on the VF page.
     * 
     *  Sets up data on the matter record, then calls checkSelected(); and populates the case list CaseSearch, then upserts the matter record, if the strRecordTypeName is equal to 'Litigation Matter' 
     *  the saveClaims();, saveParticipants(); and   saveRelations(); methods are called to insert the related records of the matter.
     *  then Matter_Content__c list lst_Content is defined and intilized, then runs through the case list CaseSearch and creates a Matter_Content__c record for each case
     *  and adds the record to the lst_Content and insert the lst_Content list. Boolean refreshPage set to true and user redirected to the standard view page of the matter record previously inserted.
     * 
     * @return Pagereference Redirects to the user to the matter view page.
     */
    Public Pagereference Save() {

        Matter.Division__c = 'Legal';

        Matter.advpm__Status__c = 'Open';

        List<TMG_Product_Level_1__c> coverageAreaList = new List<TMG_Product_Level_1__c>([select id from TMG_Product_Level_1__c where Division__c = 'Legal' limit 1]);
        List<TMG_Product_Level_2__c> productAreaList = new List<TMG_Product_Level_2__c>();
        List<TMG_Product_Level_3__c> AgreementProdGroupingList = new List<TMG_Product_Level_3__c>();

        if (coverageAreaList.size() > 0) {
            Matter.TMG_Product_Level_1__c = coverageAreaList.get(0).id;
            productAreaList = [select id from TMG_Product_Level_2__c where TMG_Product_Level_1__c = :coverageAreaList.get(0).id limit 1];
        }

        if (productAreaList.size() > 0) {
            Matter.TMG_Product_Level_2__c = productAreaList.get(0).id;
            AgreementProdGroupingList = [select id from TMG_Product_Level_3__c where TMG_Product_Level_2__c = :productAreaList.get(0).id limit 1];
        }

        if (productAreaList.size() > 0) {
            Matter.TMG_Product_Level_3__c = AgreementProdGroupingList.get(0).id;
        }

        checkSelected();
        CaseSearch = new List<Case>([Select id,Description,SuggestedTags__c,SuggestedLibrary__c,Subject From Case where id in:ContentSelected]);


        Upsert Matter;

        if (strRecordTypeName == 'Litigation Matter') {
            saveClaims();
            saveParticipants();
            saveRelations();
            system.debug('**INLIT**');
            if (strRecordTypeName == 'Legal') {
                if (!Test.isRunningTest()) {
                    createBoxfolder(Matter.Id);
                }
            }
        }

        List<Matter_Content__c> lst_Content = new List<Matter_Content__c>();
        for (Case c : CaseSearch) {
            Matter_Content__c Content = new Matter_Content__c();
            Content.Case__c = c.id;
            Content.Matter__c = Matter.id;
            lst_Content.Add(Content);
        }

        Insert lst_Content;
        refreshPage = true;

        PageReference pageRef;
        pageRef = new PageReference('/' + Matter.id);
        Return pageRef;
    }

     /**
     *  Adds new matter content based on what the user has selected on the VF page.
     * 
     *  Calls the checkSelected(); method, then populates the ContentVersion list ContentVersions based on ContentSelected list populated by checkSelected(); method,
     *  then Matter_Content__c list lst_Content is defined and intilized, then runs through the ContentVersion list ContentVersions and creates a Matter_Content__c record for each ContentVersion
     *  and adds the record to the lst_Content and insert the lst_Content lst. Boolean refreshPage set to true and VF page is refreshed.
     * 
     * @return Pagereference returns null causing the VF page to refresh.
     */
    Public Pagereference SaveEmbed() {

        checkSelected();
        ContentVersions = [select id,advpm__Matter__c, Title, Description,Matter_Category__c,Matter_Type__c, FileType, Owner.Name, VersionNumber from ContentVersion Where id in:ContentSelected];

        List<Matter_Content__c> lst_Content = new List<Matter_Content__c>();
        for (ContentVersion c : ContentVersions) {
            Matter_Content__c Content = new Matter_Content__c();
            Content.Content_Id__c = c.id;
            Content.Matter__c = Matter.id;
            lst_Content.Add(Content);
        }

        Insert lst_Content;
        refreshPage = true;


        Return null;
    }

     /**
     * Checks for duplicate matters using the matter name of the current matter and populates potentialDuplicates for later use.
     * 
     * Checks if matter.name is blank and throws an error if true, else advpm__Matter__c list queryResult is defined and populated with soql where advpm__Matter__c.name is like the name of the matter being created,
     * then runs through queryResult and populates Duplicate list potentialDuplicates with duplicate varibles generated from the matters. Boolean showDuplicates set to true and VF page is refreshed. 
     * 
     * @return Pagereference returns null causing the VF page to refresh.
     */
    public PageReference searchDupes() {
        if (!potentialDuplicates.isEmpty()) {
            potentialDuplicates.clear();
        }
        if (String.isBlank(Matter.Name)) {

            showDuplicates = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Potential duplicates cannot be determined without a name!'));
        } else {
            String likeToken = String.format('%{0}%', new List<String>{
                    Matter.Name
            });
            List<advpm__Matter__c> queryResult = [SELECT Id, Name, OwnerId, advpm__Description__c, Business_Unit_Cluster_Segment__c FROM advpm__Matter__c WHERE Name LIKE :likeToken limit 950];

            for (advpm__Matter__c res : queryResult)
                potentialDuplicates.add(new Duplicate(res));

            showDuplicates = true;
        }

        return null;
    }

     /**
     * Adds a new Business_Unit_Claim__c record to the claims list.
     * 
     * @return Pagereference returns null causing the VF page to refresh.
     */
    public PageReference addClaim() {
        claims.add(new Business_Unit_Claim__c());
        return null;
    }

     /**
     * Removes the last Business_Unit_Claim__c record in the Business_Unit_Claim__c list claims.
     * 
     * @return Pagereference returns null causing the VF page to refresh.
     */
    public PageReference removeClaim() {

        Integer endList = claims.size() - 1;

        if (endList > 0)
            claims.remove(endList);

        return null;

    }

     /*
     * Clears participantControl varible
     * 
     * Checks what recordtype is selected based on the selectedType varible and initialized advpm__Participant__c participantControl varible to new advpm__Participant__c and 
     * set participantControl record type to user or Contact based on selectedType, then calls checkRecordType();
     * 
     * @return Pagereference returns null causing the VF page to refresh.
     */
    public PageReference actionClearParticipantControl() {
        //Add to main participant list
        if (selectedType == mapParticipantRecordTypes.get('User').getRecordTypeId()) {
            participantControl = new advpm__Participant__c();
            participantControl.RecordTypeId = mapParticipantRecordTypes.get('User').getRecordTypeId();
        } else if (selectedType == mapParticipantRecordTypes.get('Contact').getRecordTypeId()) {
            participantControl = new advpm__Participant__c();
            participantControl.RecordTypeId = mapParticipantRecordTypes.get('Contact').getRecordTypeId();
        }

        checkRecordType();

        return null;
    }

     /**
     * Adds the advpm__Participant__c participantControl record to the advpm__Participant__c list participants.
     * 
     * @return Pagereference returns null causing the VF page to refresh.
     */
    public PageReference addParticipant() {

        participants.add(participantControl);
        return null;
    }

     /**
     * Removes the last advpm__Participant__c record in the advpm__Participant__c list participants.
     * 
     * @return Pagereference returns null causing the VF page to refresh.
     */
    public PageReference removeParticipant() {
        if (participants.size() > 0) {
            participants.remove(participants.size() - 1);
        }
        return null;
    }
    public class Duplicate {

        public advpm__Matter__c matter { get; set; }
        public Boolean isRelated { get; set; }

        public Duplicate(advpm__Matter__c potentialDuplicate) {
            this.matter = potentialDuplicate;
            this.isRelated = false;
        }

    }

    @future(callout=true)
    public static void createBoxfolder(Id Matterid) {

        String boxFolderId = BxdMatterDealService.createBoxFolderSync(Matterid);
    }


    public void newSave() {

        if (Matter.Id == null)
            insert Matter; else
                update Matter;

    }

     /**
     * Used to create a box folder for the current matter and sets boolean varibles used to render different sections on the VF page.
     * 
     * Calls TotalUnitsCalulate() method and returns null if TotalUnitsCalulate() returns false, if TotalUnitsCalulate() returns true, then boxEmbedURL is populated 
     * by calling the createBoxFolderSync(Matter.Id) method from the BxdMatterDealService class. Sets Boolean showBox to true, Sets showCancel showBox to true and Sets showDocuments showBox to 
     * true to control section rendering on the page.
     * 
     * @return Pagereference returns null causing the VF page to refresh.
     */
    public PageReference createBox1() {
        if (!TotalUnitsCalulate()) {

            return null;
        }


        boxEmbedURL = BxdMatterDealService.createBoxFolderSync(Matter.Id);
        system.debug('****boxEmbedURL***' + boxEmbedURL);
        showBox = true;
        showCancel = true;
        showDocuments = false;
        return null;

    }

     /**
     * Used to return user to Matter/Deal tab and delete the current matter if string strRecordTypeName != 'Legal'
     * 
     * Checks if string strRecordTypeName is not equal to 'Legal' and if Matter.id is not null and if both are true, the Matter record is deleted and then a page reference to the Matter/Deal tab
     * is returned. 
     * 
     * @return Pagereference returns pagereference to the Matter/Deal Tab.
     */
    Public Pagereference Cancel() {
        if (strRecordTypeName != 'Legal' && Matter.id != null) {
            Delete Matter;
        }
        PageReference pageRef = new PageReference('/a3A/o');
        Return pageRef;
    }

    Public Boolean Required;

     /**
     * DOES NOT CREATE BOX FOLDER - However Javascript on the VF page calls createBox1 method after completion of this method. Used verify inputted data and then creates or updates the matter record and create a list
     * of linked advpm__Participant__c records.
     * 
     * Calls claimTypeChange(); method, then upserts the Matter record, then declares and initializes varibles for later use, then runs through Business_Unit_Claim__c list claims 
     * and if the Business_Unit_Claim__c record Business_Unit__c field is not null, hasUnits is set to true, if claim.Portion_of_Claim__c is not null then claim.Portion_of_Claim__c is added to totalPercentage else numberNullClaims is incremented.
     * then if totalPercentage < 100 && hasUnits = true, and the claim.Portion_of_Claim__c field is null, then the claim.Portion_of_Claim__c is set to the differenceInClaims divided by the number of claims. 
     * Adds pagemessages if totalPercentage equal to 100 and if hasUnits is true. Then runs through advpm__Participant__c List participants and if participant.advpm__Staff__c is not null it sets participant.advpm__Matter__c to Matter Record Id and
     * adds the participant.advpm__Staff__c to the id set userIds and adds the participantrecord to the advpm__Participant__c list toSave. Then checks if the selected participants are 'Litigation' profile users and if not then it adds pagemessages.
     * Then if the page has messages then null is returned so the users can view the messages, if there no page messages then the  saveParticipants(); method is called to insert the participants.Sets Boolean showBox to true, Sets showCancel showBox 
     * to true and Sets showDocuments showBox to true to control section rendering on the page, null is then returned and the VF page is refreshed. 
     * 
     * @return Pagereference returns null to refreash the VF page.
     */
    public PageReference createBox() {

        claimTypeChange();

        Upsert Matter;
        System.debug('### createBox : Matter.Id : ' + Matter.Id);

        Decimal totalPercentage = 0;
        Boolean hasUnits = false;
        Integer numberNullClaims = 0;
        for (Business_Unit_Claim__c claim : claims) {
            if (claim.Business_Unit__c != null) {
                hasUnits = true;
                if (claim.Portion_of_Claim__c != null) {
                    totalPercentage += claim.Portion_of_Claim__c;
                } else {
                    numberNullClaims++;
                }
            }
        }

        if (totalPercentage < 100 && hasUnits) {
            Decimal differenceInClaims = 100 - totalPercentage;
            Decimal differenceAddedToEachNullClaim;
            if (numberNullClaims == 0) {
                differenceAddedToEachNullClaim = differenceInClaims;
            } else {
                differenceAddedToEachNullClaim = differenceInClaims / numberNullClaims;
            }
            for (Business_Unit_Claim__c claim : claims) {
                if (claim.Portion_of_Claim__c == null) {
                    claim.Portion_of_Claim__c = differenceAddedToEachNullClaim;
                    totalPercentage += differenceAddedToEachNullClaim;
                }
            }
        }

        if (totalPercentage > 100 && hasUnits) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Claim apportions cannot add up to a value greater than 100%'));
            return null;
        }

        if (totalPercentage != 100 && hasUnits) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Claims must add up to 100%'));
            return null;
        }

        Set<Id> userIds = new Set<Id>();
        List<advpm__Participant__c> toSave = new List<advpm__Participant__c>();
        for (advpm__Participant__c part : participants) {
            if (part.advpm__Staff__c != null) {
                part.advpm__Matter__c = Matter.Id;
                userIds.add(part.advpm__Staff__c);
                toSave.add(part);
            }
        }
        Map<Id, User> participantUsersMap = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :userIds]);
        for (advpm__Participant__c part : toSave) {
            system.debug('**UName**' + participantUsersMap.get(part.advpm__Staff__c).Profile.Name.contains('Litigation'));
            if (!participantUsersMap.get(part.advpm__Staff__c).Profile.Name.contains('Litigation')) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'All participants must be Litigation users'));
                return null;
            }
        }

        if (ApexPages.getMessages().isEmpty() == false) {
            return null;
        }

        saveParticipants();

        showBox = true;
        showCancel = true;
        showDocuments = false;
        return null;

    }

     /**
     * Used to verify Business_Unit_Claim__c records and data is correct and return true or false based on the data to be used in other methods.
     * 
     * Declares and initializes varibles for later use, then runs through Business_Unit_Claim__c list claims and if the Business_Unit_Claim__c record Business_Unit__c field is not null, hasUnits is set to true, 
     * if claim.Portion_of_Claim__c is not null then claim.Portion_of_Claim__c is added to totalPercentage else numberNullClaims is incremented.
     * Then if totalPercentage < 100 && hasUnits = true, and the claim.Portion_of_Claim__c field is null, then the claim.Portion_of_Claim__c is set to the differenceInClaims divided by the number of claims. 
     * Adds pagemessages and returns if totalPercentage is not equal to 100 and if hasUnits is true else it returns true.
     * 
     * @return boolean returns true or false based on the Business_Unit_Claim__c data.
     */
    Public Boolean TotalUnitsCalulate() {

        Decimal totalPercentage = 0;
        Boolean hasUnits = false;
        Integer numberNullClaims = 0;
        for (Business_Unit_Claim__c claim : claims) {
            if (claim.Business_Unit__c != null) {
                hasUnits = true;
                if (claim.Portion_of_Claim__c != null) {
                    totalPercentage += claim.Portion_of_Claim__c;
                } else {
                    numberNullClaims++;
                }
            }
        }

        if (totalPercentage < 100 && hasUnits) {
            Decimal differenceInClaims = 100 - totalPercentage;
            Decimal differenceAddedToEachNullClaim;
            if (numberNullClaims == 0) {
                differenceAddedToEachNullClaim = differenceInClaims;
            } else {
                differenceAddedToEachNullClaim = differenceInClaims / numberNullClaims;
            }
            for (Business_Unit_Claim__c claim : claims) {
                if (claim.Portion_of_Claim__c == null) {
                    claim.Portion_of_Claim__c = differenceAddedToEachNullClaim;
                    totalPercentage += differenceAddedToEachNullClaim;
                }
            }
        }

        if (totalPercentage > 100 && hasUnits) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Claim apportions cannot add up to a value greater than 100%'));
            return false;
        }

        if (totalPercentage != 100 && hasUnits) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Claims must add up to 100%'));
            return false;
        }

        return true;
    }

	 /**
     * Used to verify Business_Unit_Claim__c records and data is correct and then create or update the Business_Unit_Claim__c records linked to the Matter record.
     * 
     * Does nothing and returns null if the VF pages has apex page messages, if there are no apex page messages then it runs through the Business_Unit_Claim__c list claims and
     * sets the claim.Matter__c to the Matter record id and adds the claim record to the Business_Unit_Claim__c list toSave which is then upserted and cleared. If the toSave list is empty 
     * then a page message is added to prompt the user to ensure the claim records have a business unit.
     * 
     * 
     * @return void returns null as it is a void method.
     */
    private void saveClaims() {
        system.debug('***MESSAGE**' + ApexPages.getMessages());
        if (ApexPages.getMessages().isEmpty() == false) {
            return;
        }

        List<Business_Unit_Claim__c> toSave = new List<Business_Unit_Claim__c>();

        for (Business_Unit_Claim__c claim : claims) {
            if (claim.Business_Unit__c != null) {
                claim.Matter__c = Matter.Id;
                toSave.add(claim);
            }
        }

        if (toSave.size() != 0) {
            upsert toSave;
            toSave.clear();
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Must have business unit'));
        }

    }

     /**
     * Used to verify advpm__Participant__c records and data is correct and then create or update the advpm__Participant__c records linked to the Matter record.
     * 
     * Does nothing and returns null if the VF pages has apex page messages, if there are no apex page messages then it runs through the advpm__Participant__c list participants and
     * if Participant.advpm__Staff__c is not null then the Participant.advpm__Staff__c is added to the is set userIds else if Participant.advpm__Contact__c is not null then 
     * sets the Participant.advpm__Matter__c to the Matter record id and adds the Participant record to the advpm__Participant__c list toSave. Then runs through the toSave list 
     * list again and checks if the advpm__Staff__c user has a 'Litigation' profile and if not then adds a apex page message and an error to the Participant.advpm__Matter__c field.
     * then the toSave list is then upserted and cleared if the page does not have apex messages.
     * 
     * @return void returns null as it is a void method.
     */
    public void saveParticipants() {

        if (ApexPages.getMessages().isEmpty() == false) {
            return;
        }

        List<advpm__Participant__c> toSave = new List<advpm__Participant__c>();
        Set<Id> userIds = new Set<Id>();

        for (advpm__Participant__c part : participants) {
            if (part.advpm__Staff__c != null) {
                part.advpm__Matter__c = Matter.Id;
                userIds.add(part.advpm__Staff__c);
                toSave.add(part);
            } else if (part.advpm__Contact__c != null) {
                part.advpm__Matter__c = Matter.Id;
                toSave.add(part);
            }
        }

        Map<Id, User> participantUsersMap = new Map<Id, User>([SELECT Id, Profile.Name FROM User WHERE Id IN :userIds]);

        for (advpm__Participant__c part : toSave) {
            if (part.advpm__Staff__c != null) {
                system.debug('**UName**' + participantUsersMap.get(part.advpm__Staff__c).Profile.Name.contains('Litigation'));
                if (!participantUsersMap.get(part.advpm__Staff__c).Profile.Name.contains('Litigation')) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'All participants must be Litigation users'));
                    part.advpm__Staff__c.addError('User is not a Litigation user');
                }
            }
        }

        system.debug('**Tosave**' + toSave);

        if (ApexPages.getMessages().isEmpty()) {
            upsert toSave;
            toSave.clear();
        }

    }

     /**
     * Used to create matter relation records to potential duplicate matter records.
     * 
     * Does nothing and returns null if the potentialDuplicates list is null, then runs the Duplicate list potentialDuplicates and if Duplicate.isRelated is true, it creates a new 
     * matter_relation__c record and adds it to the Matter_Relation__c list toInsert. The insert method from the database class is then called with the toInsert list and set to allow partial success.
     * 
     * 
     * @return void returns null as it is a void method.
     */
    private void saveRelations() {

        system.Debug('***DUP**' + potentialDuplicates);

        if (potentialDuplicates == null)
            return;

        system.Debug('***DUP2**' + ApexPages.getMessages());

        system.Debug('***DUP3**');

        List<Matter_Relation__c> toInsert = new List<Matter_Relation__c>();

        for (Duplicate dup : potentialDuplicates) {
            system.debug('***ISDUP3333**');
            if (dup.isRelated) {
                system.debug('***ISDUP**');
                toInsert.add(new Matter_Relation__c(Matter1__c = Matter.Id, Matter2__c = dup.matter.Id, Name = dup.matter.Name));
            }
        }
        Database.SaveResult[] results = Database.Insert(toInsert, false);
    }

     /**
     * Used to clear fields on the matter record
     * 
     * sets Matter.Reasonably_Possible__c, Matter.Probable_For_Approval__c and Matter.Securitization_value__c to null and then returns null.
     *  
     * @return null returns null
     */
    public PageReference clearFinancial() {

        Matter.Reasonably_Possible__c = null;
        Matter.Probable_For_Approval__c = null;
        Matter.Securitization_value__c = null;

        return null;
    }

     /**
     * Used to populate ParticipantTypes selectOption List from mapParticipantRecordTypes if the record type is not 'Account' or 'Master'
     * 
     * @return List<SelectOption> returns list of selectOptions to be used on VF page.
     */
    public List<SelectOption> getParticipantTypes() {
        List<SelectOption> options = new List<SelectOption>();

        for (String recordType : mapParticipantRecordTypes.keySet()) {
            if (recordType != 'Master' && recordType != 'Account') {
                options.add(new SelectOption(mapParticipantRecordTypes.get(recordType).getRecordTypeId(), recordType));
            }
        }

        return options;
    }

     /**
     * Used to populate the Matter.Probable_Approved__c and Matter.Probable_For_Approval__c fields based on the Matter.Claim_By_Against_Barclays__c field
     */
    public void claimTypeChange() {

        if (Matter.Claim_By_Against_Barclays__c == 'Claim By Barclays') {

            Matter.Probable_Approved__c = Matter.Probable_For_Approval__c;
            Matter.Probable_For_Approval__c = null;

        } else if (Matter.Claim_By_Against_Barclays__c == 'Claim Against Barclays') {

            Matter.Probable_For_Approval__c = Matter.Probable_Approved__c;
            Matter.Probable_Approved__c = null;

        }
    }

    //----------------------------------------Convert Matter to Case for Knowledge
    Public Class KnowledgeLibrary {

        Public string LibId { get; set; }
        Public string LibTitle { get; set; }
        Public string LibDescription { get; set; }
        Public string LibMatterCategory { get; set; }
        Public string LibMatterType { get; set; }
        Public boolean LibSelect { get; set; }

    }

    Public Class CaseApproval {

        Public string CasId { get; set; }
        Public string CasSubject { get; set; }
        Public string CasDescription { get; set; }
        Public string CasSuggestedTags { get; set; }
        Public string CasSuggestedLibrary { get; set; }
        Public boolean CasSelect { get; set; }

    }
}