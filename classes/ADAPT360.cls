/**
* @Author:          Dino Scarcella
* @Company:         Absa Capital
* @Description:     SFAFRICA-63 - View CIF Details in Salesforce. This class was built to retrieve the client
*                   details from the ADAPT360 service through REST call. All settings for the service are in 
*                   Custom Meta Data types. Helper methods have been created to set Authority Info for mandates
*                   (makes retrieving this data easier) as well as retrieving the Primary Client. JSON returned
*                   from the REST call is deserialized into the classes created.
* History
* 2016-12-13 - Rudolf Niehaus - CloudSmiths : Change logic to cater for Complaints and not only for CSC
* 2017-01-23 - Rudolf Niehaus - CloudSmiths : CIF Conditional rendering based on Profile
* 2017-04-07 - Rudolf Niehaus - CloudSmiths : Bypass duplication rules
* 2017-05-08 - Rudolf Niehaus - CloudSmiths :  
* 2017-08-10 - Mabhedle Tonga - Barclays : Catered to assign Account ID's if case are created from accounts
* 2018-02-05 - Rudolf Niehaus - CloudSmiths : Add CIF search audit logging feature
*------------------------------------------------------------*/

public class ADAPT360 {
    
    public String BASE_ENDPOINT = '';
    public String OPERATION_GETALLVIEWS = '';
    public String OPERATION_GETCLIENTS = '';
    public Integer TIMEOUT = 0;
    public String X_IBM_Client_Id = ''; 
    public String X_IBM_Client_Secret = ''; 
    public String REGID_FIELD = '';
    public String QUERYTYPE_FIELD = '';
    public String CIB_VIEW = '';
    public List<ClientDetail> Client_Details = new List<ClientDetail>();
    public String errors = '';
    public Case theCase{get;set;}
    public list<String> queryTypeList = new list<String>();
    public String qType{get;set;}
    public String qValue{get;set;}
    public String relCIF{get;set;}
    public String cifName{get;set;}
    public String relName{get;set;}
    public String relID{get;set;}
    public list<Account> rel{get;set;} 
    public boolean isCSCProfile{get;set;}
    public boolean isNotCSCProfile{get;set;}
    public string UDFServiceTypes{get;set;}
    public string ChargesServiceTypes{get;set;}
    public boolean isDOSProfile{get;set;}
    private boolean noAccount = false;
    private map<String,String> cifNameMap = new map<String,String>();
    private boolean isComplaint = false;
    
    //RN : CloudSmiths - add standard controller constructor
    public ADAPT360(ApexPages.StandardController controller){
      
        rel = new list<Account>();
        
        if(Apexpages.Currentpage().getParameters().get('Id') != null){
        	this.theCase = (Case)controller.getRecord();
        	this.theCase = [Select Id, AccountId, OwnerId, Account.Name, Email_Sender_Name__c, Email_From_Address__c,
                            RecordTypeId, Status, Priority, Incident_Date__c, Origin__c, MNPI__c, Opportunity_Name__c,
                            Subject, Description, Queue__c, Type_Of_Complaint__c, Service_Type__c, Severity__c, Service_Sub_Category__c,
                            Service_Category__c, Channel__c, Staff_Error__c, Staff_Error_Description__c, Staff_Member_Name__c,
                            Business_Area__c, Nature_Of_Complaint__c, Impact__c, Root_Cause_Category__c, Root_Cause__c,Resolved_In_Favour_Of__c,
							Business_Owner_Action__c,Action_Taken__c,Desired_Action__c,Account.CIF__c,
                            Operational_Risk_Event_Reference__c, Suppress_Acknowledge_Alert__c 
                            From Case Where Id = :this.theCase.Id];
            
            //complaint via the CSC quick action 
            if(Apexpages.Currentpage().getParameters().get('comptaint') != null){
                String compRecId = [Select Id From RecordType Where DeveloperName = 'Complaint'].Id;
                this.theCase.RecordTypeId = compRecId;
                isComplaint = true;
                
            }
        }else{
            
            this.theCase = new Case();
            
            //Check if a recordType was selected
            if(Apexpages.Currentpage().getParameters().get('RecordType') != null){
                
                String recId = Apexpages.Currentpage().getParameters().get('RecordType');
                String AccountID = Apexpages.Currentpage().getParameters().get('cas4_lkid');
  
                String recDevName = [Select DeveloperName From RecordType Where Id = :recId limit 1].DeveloperName;
                
                 if(recDevName == 'Digital_Ops_Cases'){
                    this.theCase.Queue__c = 'DOS - General';
                }
                
                this.theCase.RecordTypeId = recId;
                this.theCase.OwnerId = UserInfo.getUserId();
                if(!String.isBlank(AccountID))
                {
                	this.theCase.AccountId = AccountID;    
                }
                
           
            }else{
                 //default to this
                this.theCase.RecordTypeId = [Select Id From RecordType Where Developername = 'CSC_Manual_Cases'].Id;
            }
            
            this.theCase.OwnerId = UserInfo.getUserId();
            
        }
        
        //initial value
        this.accountOptions = new SelectOption[]{};
        this.accountOptions.add(new SelectOption('----- No Relationship Linked------' , '----- No Relationship Linked------'));
        this.cifdataOptions = new SelectOption[]{};
            
        //Determine profile of running user
        Id profileId = userinfo.getProfileId();
		
        String profileName = [Select Id,Name from Profile where Id = :profileId].Name;
        
        if(profileName.contains('CSC')){
            isCSCProfile = true;
            isNotCSCProfile = false;
        }else if(profileName.contains('Digital Ops')){
            isCSCProfile = false;
            isNotCSCProfile = false;
            isDOSProfile = true;
        }else{
			isCSCProfile = false;
            isNotCSCProfile = true;
        }
        
        if(isComplaint){
            isCSCProfile = false;
            isNotCSCProfile = true;
        }
        
        setSessionVariables();
        getUDFServiceTypes();
        getChargesServiceTypes();
    }
    
    //Mabee - Barclays
    public void addAsTeamMember()
    {
        try
        {
            if(Apexpages.Currentpage().getParameters().get('comptaint') != null)
            {
                List<Case> caseList = new List<Case>();
                caseList.add(theCase);
                CSC_Case_Trigger_Functions.addCreatorAsTeamMember(caseList);
            }
        }
        catch(Exception exc)
        {
            
        }
        
    }
        
    public String isClosed{get;set;}
   	public boolean isClosedStatus{get;set;}
    public void CslosedStatus()
    {
        System.debug('CslosedStatus ');
		isClosedStatus =false;
		if(this.theCase.status.Contains('Closed'))
        {
            isClosedStatus=true;
        }
        System.debug('CslosedStatus '+isClosedStatus);
    }
    
    public PageReference autoPopulateFields(){
        
        CSC_Case_Functions caseFunc = new CSC_Case_Functions(this.theCase);
        this.theCase.Department__c = caseFunc.getDepartment();
        this.theCase.Team_Manager__c = caseFunc.getTeamManager();
        this.theCase.Team__c = caseFunc.getTeam();
        this.theCase.Business_Hours__c = caseFunc.getBusinessHours();
        this.theCase.Full_Department__c = caseFunc.getFullDepartment();
        return null;
    }
    public SelectOption[] accountOptions {
        public get;
        public set;
    }
    public SelectOption[] cifdataOptions {
        public get;
        public set;
    }
    //RN - CloudSmiths
    public void searchSalesforceAccounts(){
        
        list<String> cifNumbers = new list<String>();
        accountOptions.clear();
        cifdataOptions.clear();
        cifNameMap.clear();
        
        if(qType.equals('cif') || qType.equals('ucode')){
            //Get CIF for the SF account record
            System.debug('RN : Search SF on =' + qValue);
            
            if(qType.equals('cif')){
                 rel = [Select Id, Name, CIF__c From Account Where Name like :qValue+'%' AND RecordType.Name != 'Relationship Group' Order by Name ASC limit 15];
            }
            //else{
             //    String usercodes = '%' + qValue + '%';
             //    rel = [Select Id, Name, CIF__c From Account Where User_Code__c like :usercodes AND RecordType.Name != 'Relationship Group' Order by Name ASC limit 15];
            //}

            if(rel.size() >= 1){
                relID = rel[0].Id;
                relName = rel[0].Name;
                //get the first relationship until a user change the selection option, there could be multaple CIF numbers
                if(String.isNotBlank(rel[0].CIF__c)){
                    cifNumbers.addAll(rel[0].CIF__c.split(','));
                }
                
                if(!cifNumbers.isEmpty()){
                    
                    qValue = cifNumbers[0];
                    
                    System.debug('RN : Search CIF on =' + qValue);
                    //get CIF data - will only get one record if weusethe CIF number - registrtaion number and ID could return more than one
                    ClientDetails = RetrieveClientDetails('cif', qValue, CIB_VIEW,true);
                    SetAuthorityInfo();
                    SetAdditionalAccounts();
                    
                    for(Account a :rel){
                        this.accountOptions.add(new SelectOption(a.Name , a.Name + ' : ' + a.CIF__c));
                    }
                    
                    System.debug('RN : CIF Array value' + cifNumbers[0]);
                    relCIF = cifNumbers[0];
                    System.debug('RN : CIF Field Value' + relCIF);
                    
                    //First relationship found has a CIF Number, we've searched on that CIF number
                    UpdateAccountInfo(relID, relCIF);
                    
                    //if(PrimaryClient == null && PrimaryClient.individual == null){
                    //     ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There is no CIF data for this CIF number : ' + cifNumbers[0] ));
                    //}else{
                    //    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Found CIF Data For : ' + relName ));
                    // }
                }else{
                    //add the rest of the accounts to a dropdown list
                    for(Account a :rel){
                        this.accountOptions.add(new SelectOption(a.Name , a.Name + ' : ' + a.CIF__c));
                    }
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a CIF Number in Salesforce for this Relationship'));
                }
                
            }else if(rel.size() == 0){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a Relationship in Salesforce with this Name : ' + qvalue));
            }
        }else{
            
            String cifsearch = '';
            if(qType.equals('cif2cif')){
                cifsearch=qType;
                qType='cif';
            }
            
            System.debug('RN123 : Search CIF on qType =' + qType + ' AND Value = ' + qValue);
            
            ClientDetails = RetrieveClientDetails(qType, qValue, CIB_VIEW,true);
            
            SetAuthorityInfo();
            SetAdditionalAccounts();
            qType = 'cif';
            
            //more than one CIF record
            if(PrimaryClients.size() >= 1){
                
                for(ClientDetail p :PrimaryClients){
                    
                    String cname = '';
                    String ccif = '';
                    
                    if(p.individual != null){
                        if(p.individual.surname != null){
                            if(String.isNotBlank(p.individual.surname.value)){
                                if(p.identifications != null){
                                    for (IdentificationsInfo ii : p.identifications) {
                                        System.debug(ii.type.code);
                                        if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                                            cifNumbers.add(ii.numbers);
                                            ccif = ii.numbers;
                                        }  
                                    } 
                                }
                                
                                if(String.isNotBlank(p.individual.nameInitials.value)){
                                    this.cifdataOptions.add(new SelectOption(p.individual.nameInitials.value + ' ' + p.individual.surname.value + ' : ' + ccif , p.individual.nameInitials.value + ' ' + p.individual.surname.value + ' : ' + ccif));
                                    cname = p.individual.nameInitials.value + ' ' + p.individual.surname.value + ' : ' + ccif;
                                }else{
                                    this.cifdataOptions.add(new SelectOption(p.individual.surname.value + ' : ' + ccif , p.individual.surname.value + ' : ' + ccif));
                                    cname = p.individual.surname.value + ' : ' + ccif;
                                }
                                
                                System.debug('PUT MAP->' + cname + '-' + ccif);
                                cifNameMap.put(cname,ccif);
                            }
                        }
                    }
                }//end loop
                
                String q='';
                if(cifNumbers.size() > 0){
                    q = '%' + cifNumbers[0] + '%';
                }else{
                    cifNumbers.add(qValue);
                    q = '%' + cifNumbers[0] + '%';
                }
                
                rel = [Select Id, Name, CIF__c From Account Where CIF__c like :q limit 1];
                
                if(rel.size() == 1){
                    
                    if(cifNumbers.size() > 0){
                        qValue = cifNumbers[0];
                    }else{
                        cifNumbers.add(qValue);
                    }
                    
                    if(!cifNumbers.isEmpty()){
                        
                        //add the rest of the accounts to a dropdown list
                        for(Account a :rel){
                            this.accountOptions.add(new SelectOption(a.Name , a.Name));
                        }
                        
                        relCIF = cifNumbers[0];
                        relID = rel[0].Id;
                        relName = rel[0].Name;
                        
                        //Have searched and found a number of clients from CIF and need to update the first one
                        UpdateAccountInfo(relID, relCIF);
                    }else{
                        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a CIF Number in Salesforce for this Relationship'));
                    }
                }else if(rel.size() == 0){
                    
                    String rectypeid = [Select Id From RecordType Where Name = 'Client'].id;
                  	List <Account> ParentList = new List<Account>([Select Id,Segment__c  From Account Where Name = :Label.lblUnknownParent]);
                     
                    
                    
                    Account newAcc = new Account();
                    newAcc.CIF__c = cifNumbers[0];
                    newAcc.RecordTypeId = rectypeid;
                    newAcc.OwnerId = UserInfo.getUserId();
                    
                    if (!ParentList.isEmpty())
                    {
                        newAcc.ParentId = ParentList[0].id;
                        newAcc.Segment__c = ParentList[0].Segment__c;
                    }              
                    
                    if(PrimaryClient != null){
                        if(PrimaryClient.individual != null){
                            if(PrimaryClient.individual.surname != null){
                                if(String.isNotBlank(PrimaryClient.individual.surname.value)){
                                    if(String.isNotBlank(PrimaryClient.individual.nameInitials.value)){
                                        newAcc.Name = PrimaryClient.individual.nameInitials.value + ' ' + PrimaryClient.individual.surname.value;
                                    }else{
                                        newAcc.Name = PrimaryClient.individual.surname.value;
                                    }
                                }else{
                                    newAcc.Name = 'Missing Name - See CIF Number';
                                }
                                
                                if(PrimaryClient.customerDetails != NULL && PrimaryClient.customerDetails.groupScheme != NULL && PrimaryClient.customerDetails.groupScheme.description != NULL) {
                                    newAcc.groupScheme__c = PrimaryClient.customerDetails.groupScheme.description.value;
                                }
                                
                                try{
                                    //RN - Relationship Duplication rule bypass
                                    Database.DMLOptions dml = new Database.DMLOptions();
                                    
                                    dml.DuplicateRuleHeader.AllowSave = true;
                                    
                                    Database.SaveResult sr = Database.insert(newAcc, dml);
                                    
                                    if (sr.isSuccess()) {
                                        
                                        relName = newAcc.Name;
                                        relCIF = newAcc.CIF__c;
                                        relID = newAcc.Id;
   
                                    }else{               
                                        for(Database.Error err : sr.getErrors()) {
                                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'The following error has occurred.'));
                                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,err.getStatusCode() + ': ' + err.getMessage()));
                                            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Relationship fields that affected this error: ' + err.getFields()));
                                        }
                                        
                                    }
                                }catch(DMLException ex){
                                    System.debug(ex.getMessage());
                                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
                                }                            
                            }
                        }
                    }
                }
                
                
            }
        }
    }
    
    public void cifSelection(){
        
        list<String> cifNumbers = new list<String>();
        
        qValue = cifNameMap.get(cifName);
        qType = 'cif';
        
        ClientDetails = RetrieveClientDetails(qType, qValue , CIB_VIEW,true);
        SetAuthorityInfo();
        SetAdditionalAccounts();
        
        String q = '%' + qValue + '%';
        rel = [Select Id, Name, CIF__c From Account Where CIF__c like :q limit 1];
        
        if(rel.size() == 1){
            
            
            if(String.isNotBlank(qValue)){
                
                //add the rest of the accounts to a dropdown list
                for(Account a :rel){
                    this.accountOptions.add(new SelectOption(a.Name , a.Name));
                }
                
                relCIF = qValue;
                relID = rel[0].Id;
                relName = rel[0].Name;
                
                // We've selected another CIF and found an account with that CIF, update that account
                UpdateAccountInfo(relID, relCIF);
            }else{
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a CIF Number for this Relationship'));
            }
            
        }else if(rel.size() == 0){
            
            String rectypeid = [Select Id From RecordType Where Name = 'Prospect'].id;
            
            Account newAcc = new Account();
            newAcc.CIF__c = qValue;
            newAcc.RecordTypeId = rectypeid;
            newAcc.OwnerId = UserInfo.getUserId();
            
            String[] theName = cifName.split(':');
            newAcc.Name = theName[0].trim();
            
            ClientDetail cd = ClientDetailFromCIF(newAcc.CIF__c);
            if(cd != NULL && cd.customerDetails != NULL && cd.customerDetails.groupScheme != NULL && cd.customerDetails.groupScheme.description != NULL) 
                    newAcc.groupScheme__c = cd.customerDetails.groupScheme.description.value;
            
            try{
                insert newAcc;
                relName = newAcc.Name;
                relCIF = newAcc.CIF__c;
                relID = newAcc.Id;
            }catch(DMLException ex){
                System.debug(ex.getMessage());
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,ex.getMessage()));
            }
        }
    }
    
    public void accountSelection(){
        
        list<String> cifNumbers = new list<String>();
        
        rel = [Select Id, Name, CIF__c From Account Where Name = :relName limit 1];
        relID = rel[0].Id;
        relName = rel[0].Name;
        
        //get the first relationship until a user change the selection option, there could be multaple CIF numbers
        if(String.isNotBlank(rel[0].CIF__c)){
            cifNumbers.addAll(rel[0].CIF__c.split(','));
        }
        
        if(cifNumbers.size() >0){
            qValue = cifNumbers[0];
            relCIF = cifNumbers[0];
        }else{
            qValue=null; 
        }
        if(!cifNumbers.isEmpty()){
            
            //get CIF data - will only get one record if weusethe CIF number - registrtaion number and ID could return more than one
            ClientDetails = RetrieveClientDetails('cif', qValue, CIB_VIEW,true);
            SetAuthorityInfo();
            SetAdditionalAccounts();
            
            // We've selected another CIF and found an account with that CIF, update that account
            UpdateAccountInfo(relID, relCIF);
            //if(PrimaryClient==null || PrimaryClient.individual==null){
            //    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There is no CIF data for this CIF number : ' + relCIF ));
            //}else if(PrimaryClient != null || PrimaryClient.individual != null){
            //    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Found CIF Data For : ' + relName ));
            //}
        }else{
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Could not find a CIF Number in Salesforce for this Relationship'));
        }
    }
    
    
    // Constructor gets all settings, query strings, runs REST call and sets data
    public ADAPT360() {
        setSessionVariables(); 
    }
    
    public void runQueryFromURL(){
        
        if (ApexPages.currentPage().getParameters().get(REGID_FIELD)!=null && ApexPages.currentPage().getParameters().get(REGID_FIELD)!=''
            && ApexPages.currentPage().getParameters().get(QUERYTYPE_FIELD)!=null && ApexPages.currentPage().getParameters().get(QUERYTYPE_FIELD)!='') {
                
                ClientDetails = RetrieveClientDetails(ApexPages.currentPage().getParameters().get(QUERYTYPE_FIELD), 
                                                      ApexPages.currentPage().getParameters().get(REGID_FIELD), 
                                                      CIB_VIEW, 
                                                      true);
                
                SetAuthorityInfo(); //sets the authority info for the non primary clients (ie. account authentication details)
                SetAdditionalAccounts(); //adds additional accounts to primary client 
            }
    }
    
    public void setSessionVariables(){
        for(ADAPT360_Integration_Setting__mdt settings : [SELECT DeveloperName, Setting__c FROM ADAPT360_Integration_Setting__mdt WHERE DeveloperName IN('BASE_ENDPOINT','OPERATION_GETALLVIEWS','OPERATION_GETCLIENTS','TIMEOUT','X_IBM_Client_Id','X_IBM_Client_Secret','QUERYTYPE_FIELD','QUERYTYPES','REGID_FIELD','CIB_VIEW')]){
            if (settings.DeveloperName == 'BASE_ENDPOINT') BASE_ENDPOINT = settings.Setting__c;
            if (settings.DeveloperName == 'OPERATION_GETALLVIEWS') OPERATION_GETALLVIEWS = settings.Setting__c;
            if (settings.DeveloperName == 'OPERATION_GETCLIENTS') OPERATION_GETCLIENTS = settings.Setting__c;
            if (settings.DeveloperName == 'TIMEOUT') TIMEOUT = integer.valueof(settings.Setting__c);
            if (settings.DeveloperName == 'X_IBM_Client_Id') X_IBM_Client_Id = settings.Setting__c;
            if (settings.DeveloperName == 'X_IBM_Client_Secret') X_IBM_Client_Secret = settings.Setting__c;
            if (settings.DeveloperName == 'QUERYTYPE_FIELD') QUERYTYPE_FIELD = settings.Setting__c;
            if (settings.DeveloperName == 'REGID_FIELD') REGID_FIELD = settings.Setting__c;
            if (settings.DeveloperName == 'CIB_VIEW') CIB_VIEW = settings.Setting__c;
            //RN - CloudSmiths
            //if (settings.DeveloperName == 'QUERYTYPES') queryTypeList.addAll(settings.Setting__c.split(','));
        }
    }
    
    public void getUDFServiceTypes(){
        UDFServiceTypes = '';
        for(DynamicSectionRendering__mdt settings : [Select Label From DynamicSectionRendering__mdt Where Object__c = 'Case' AND Section__c = 'UDF' AND Field__c = 'Service_Type__c']) {
        	UDFServiceTypes = UDFServiceTypes + ';' + settings.Label;
        }
    }
    
    public void getChargesServiceTypes(){
        ChargesServiceTypes = '';
        for(DynamicSectionRendering__mdt settings : [Select Label From DynamicSectionRendering__mdt Where Object__c = 'Case' AND Section__c = 'Charges' AND Field__c = 'Service_Type__c']) {
        	ChargesServiceTypes = ChargesServiceTypes + ';' + settings.Label;
        }
    }
    
    // Action method which synchronously calls the Get Client Details operation with specified parameters
    // queryType: Type of query, valids ones are: cif, passport, identityDocument and suid
    // regId: Registration number, ID number, passport number etc depending on the query type
    // view: Predefined views of the client information. If it is null or empty "BASIC_VIEW" will be used
    // hideMeta: Boolean flag, if set to true then no extra meta data will be shown. Default is false
    public List<ClientDetail> RetrieveClientDetails(String queryType, String regId, String view, Boolean hideMeta) {
        // Builds the query strings based on the parameters passed to the method
        String QueryString='';
        if (queryType != '') QueryString = QueryString + '?queryType=' + queryType;
        if (regId != '') QueryString = QueryString + (QueryString=='' ? '?' : '&') + 'regId=' + regId;
        if (view != '') QueryString = QueryString + (QueryString=='' ? '?' : '&') + 'view=' + view;
        QueryString = QueryString + (QueryString=='' ? '?' : '&') + 'hideMeta=' + (hideMeta ? 'true' : 'false');
        
        System.debug('** Query = ' + QueryString);
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(BASE_ENDPOINT + OPERATION_GETCLIENTS + QueryString.replace(' ','%20'));
        request.setMethod('GET');
        request.setHeader('Accept', 'application/json');
        request.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
        request.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
        request.setTimeout(TIMEOUT);
        
        HttpResponse response;
        ClientDetails = new List<ClientDetail>();
        try {
            response = http.send(request);
            if (response.getStatusCode() == 200)
                try {
                    // Deserialize the list of Client Details from the JSON string
                    ClientDetails = (List<ClientDetail>)JSON.deserialize(response.getBody().replace('"limit":','"limits":').replace('"$ref":','"ref":').replace('"number":','"numbers":').replace('"_links":','"links":').replace('"$id":','"id":'), List<ClientDetail>.class);  
                }catch(Exception e){ 
                    System.debug(e.getMessage());
                    errors = response.getBody(); 
                }else{
                    
                    errors = response.getBody();
                }
            
        } catch(Exception e){ 
            System.debug(e.getMessage());
            errors = e.getMessage(); 
        }
        
        
        String caseId = '';
        String caseCIF = '';
        String caseRelationshipName = '';
        
        if(PrimaryClient!=null){
            if(PrimaryClient.individual!=null){
                if(PrimaryClient.individual.salutationType!=null && PrimaryClient.individual.nameInitials!=null && PrimaryClient.individual.surname!=null){
                    if(PrimaryClient.individual.salutationType.description.value!=null && PrimaryClient.individual.nameInitials.value!=null && PrimaryClient.individual.surname.value!=null){
                        caseRelationshipName = PrimaryClient.individual.salutationType.description.value + ' ' + PrimaryClient.individual.nameInitials.value + ' ' + PrimaryClient.individual.surname.value;
                    }
                }
                
                if(String.isNotBlank(PrimaryClient.individual.surname.value)){
                    if(String.isNotBlank(PrimaryClient.individual.nameInitials.value)){
                        caseRelationshipName= PrimaryClient.individual.nameInitials.value + ' ' + PrimaryClient.individual.surname.value;
                    }else{
                        caseRelationshipName= PrimaryClient.individual.surname.value;
                    }
                }else{
                    caseRelationshipName= 'Missing Name - See CIF Number';
                }
            }
        }
            
            
            
        
        
        SYstem.debug(ClientDetails);
        if(theCase != null){
            caseId = theCase.Id;
            caseCIF = theCase.Account.CIF__c;
            caseRelationshipName = theCase.Account.Name;
        }else{
            if(ApexPages.currentPage().getParameters().get('audit') != null){
               caseId = ApexPages.currentPage().getParameters().get('audit');
               caseCIF = regId; 
            }
        }
        
        CleanLargeAccountLists();
        
        auditCIFSearch(queryType, regId, UserInfo.getUserId(), caseId, caseCIF,caseRelationshipName);
        
        return ClientDetails;
    }
    
    // Property method for Client Details found
    public list<ClientDetail> ClientDetails {
        get { return Client_Details; }
        set { Client_Details = value; }
    }
    
    // Property method to get the Primary Client and set the CIFNumber for the client we are currently seeing
    public ClientDetail PrimaryClient {
        get {
            for (ClientDetail pc : PrimaryClients) {
                if (pc.identifications != null) {
                    for (IdentificationsInfo ii : pc.identifications) {
                        if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                            // drop down hasn't been changed yet, set to the first one we find
                            if (CIFNumber == null) {
                                CIFNumber = ii.numbers;
                                return pc;
                            }
                            // dropdown has been changed, set to this one if the CIF corresponds
                            if (ii.numbers == CIFNumber) return pc;
                        }
                    }  
                }
            }
            return null;
        }
    }
    
    // Property method to put PrimaryClient Accounts in a Map. Avoids limitation when displaying on VF page
    public Map<AccountInfo, String> PrimaryClientAccounts {
        get {
            if (PrimaryClient != null && PrimaryClient.account != null && PrimaryClient.account.size() > 0) {
                Map<AccountInfo, String> accounts = new Map<AccountInfo, String>();
                for(AccountInfo acc : PrimaryClient.account) {
                	accounts.put(acc, '');
                }
                return accounts;
            }
            return null;
        } 
    }
    
    // Property method to get all the Primary Clients for the search done
    public List<ClientDetail> PrimaryClients {
        get
        {
            List<ClientDetail> PrimaryClients = new List<ClientDetail>();
            if (ClientDetails != null && ClientDetails.size() > 0) {
                for (ClientDetail cd : ClientDetails) {
                    if (cd.meta != null
                        && cd.meta.queryResult != null
                        && cd.meta.queryResult.sourceSystem != null
                        && cd.meta.queryResult.sourceSystem == 'cif'
                        && cd.meta.queryResult.type != null
                        && cd.meta.queryResult.type == 'related')
                        PrimaryClients.add(cd);
                }
            }
            return PrimaryClients;
        }
    }
    
    // Property method to build the dropdown that shows the CIF of all the Primary Clients one can show on the CIF screen
    public List<SelectOption> CIFOptions {
        get {
            List<SelectOption> cif_options = new List<SelectOption>();
            for (ClientDetail pc : PrimaryClients) {
                if (pc.identifications != null) {
                    for (IdentificationsInfo ii : pc.identifications) {
                        if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                            String Label = ii.numbers;
                            if (pc.customerDetails != null 
                                && pc.customerDetails.groupScheme != null 
                                && pc.customerDetails.groupScheme.description != null 
                                && pc.customerDetails.groupScheme.description.value != null 
                                && pc.customerDetails.groupScheme.description.value.trim() != '') 
                                Label = Label + ' - ' + pc.customerDetails.groupScheme.description.value;
                            SelectOption option = new SelectOption(ii.numbers,Label);
                            cif_options.add(option);
                        }  
                    }  
                }  
            }
            return cif_options;
        }
    }
    
    // Property method to return a list of strings containing the CIF Numbers of the Primary Clients
    public List<String> CIFNumbers {
        get {
            List<String> cifs = new List<String>();
            for (ClientDetail pc : PrimaryClients) {
                if (pc.identifications != null) {
                    for (IdentificationsInfo ii : pc.identifications) {
                        if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                            cifs.add(ii.numbers);
                        }  
                    }  
                }  
            }
            return cifs;
        }
    }
    
    // Property method for the selected item of the CIF dropdown
    public String CIFNumber { get;set; }
    public List<ClientDetail> Mandates {
        get
        {
            List<ClientDetail> Mandates = new List<ClientDetail>();
            for (ClientDetail cd : ClientDetails) {
                if (cd.meta != null
                    && cd.meta.queryResult != null
                    && cd.meta.queryResult.sourceSystem != null
                    && cd.meta.queryResult.sourceSystem == 'auth')
                    if (IsMandateOfPrimaryClient(cd)) Mandates.add(cd);
            }
            Mandates.sort();
            return Mandates;
        }
    }
    
    // Method that checks if a client is a mandate of the Primary Client
    public Boolean IsMandateOfPrimaryClient(ClientDetail cd) {
        if (PrimaryClient != null && PrimaryClient.authority != null && cd.id != null) {
            for (AuthorityInfo authinfo : PrimaryClient.authority) {
                if (authinfo.signatoryDetails != null && authinfo.signatoryDetails.size() > 0) {
                    for (SignatoryDetailsInfo siginfo : authinfo.signatoryDetails) {
                        if (siginfo.entity != null && siginfo.entity.ref != null) {
                            if (siginfo.entity.ref == cd.id) return true;
                        }
                    }
                }
            }
        }
        return false;
    }
    
    // Property method to return any errors that come out of the REST API call
    public String Error { 
        get { return errors; }
    }
    // sets the Authority 
    private void SetAuthorityInfo() {
        if (ClientDetails!=null && ClientDetails.size() > 0) {
            for (ClientDetail cifcd : ClientDetails) {
                if (cifcd.authority != null
                    && cifcd.meta != null
                    && cifcd.meta.queryResult != null
                    && cifcd.meta.queryResult.sourceSystem != null
                    && cifcd.meta.queryResult.sourceSystem == 'cif') {
                        for (AuthorityInfo authinfo : cifcd.authority) {
                            for (ClientDetail cd : ClientDetails) {
                                if (cd.id != null && cd.id.trim() != '' && authinfo.signatoryDetails.size() > 0 && cd.id == authinfo.signatoryDetails[0].entity.ref) {
                                    cd.authority = new List<AuthorityInfo>();
                                    cd.authority.add(authinfo);
                                }
                            }
                        }   
                    }  
            }
        }
    }
    
    // Gets all the additional accounts on client details with ClientDetail.MetaInfo.QueryResultInfo.sourceSystem = cif and ClientDetail.MetaInfo.QueryResultInfo.sourceSystem.type = additionalcif
    // and add these accounts to the accounts with ClientDetail.MetaInfo.QueryResultInfo.sourceSystem = cif and ClientDetail.MetaInfo.QueryResultInfo.sourceSystem.type = related
    private void SetAdditionalAccounts() {
        if (ClientDetails!=null && ClientDetails.size() > 0) {
            for (ClientDetail cifcd : ClientDetails) {
                if (cifcd.meta != null
                    && cifcd.meta.queryResult != null
                    && cifcd.meta.queryResult.sourceSystem != null
                    && cifcd.meta.queryResult.sourceSystem == 'cif'
                    && cifcd.meta.queryResult.type != null
                    && cifcd.meta.queryResult.type == 'related') {
                        for (ClientDetail addtnlcd : ClientDetails) {
                            if (addtnlcd.meta != null
                                && addtnlcd.meta.queryResult != null
                                && addtnlcd.meta.queryResult.sourceSystem != null
                                && addtnlcd.meta.queryResult.sourceSystem == 'cif'
                                && addtnlcd.meta.queryResult.type != null
                                && addtnlcd.meta.queryResult.type == 'additionalCIF'
                                && addtnlcd.account != null
                                && addtnlcd.account.size() > 0) {
                                    if (cifcd.account == null || cifcd.account.size() == 0)
                                        cifcd.account = addtnlcd.account;
                                    else
                                        cifcd.account.addAll(addtnlcd.account);      
                                }                    
                        }
                        if (cifcd.account != null && cifcd.account.size() > 0) cifcd.account.sort(); //sort the accounts for display purposes
                    }      
            }  
        }  
    }
    
        
    // This method updates any account info we would like to update from the ADAPT360 service. Primary Client holds the current client selected
    private void UpdateAccountInfo(Id accountId, String CIF) {
        ClientDetail cd = ClientDetailFromCIF(CIF);
        if(cd != NULL && cd.customerDetails != NULL && cd.customerDetails.groupScheme != NULL && cd.customerDetails.groupScheme.description != NULL) {
        	Account accToUpdate = new Account(Id = accountId, groupScheme__c = cd.customerDetails.groupScheme.description.value);
            try {
            	update accToUpdate;
            } catch (Exception ex) {
                System.debug('Error updating account info:' + ex.getMessage());
            }
       	}
    }
    
    private ClientDetail ClientDetailFromCIF(String CIF) {
    	if (CIF != NULL && CIF != '') {
        	for (ClientDetail pc : PrimaryClients) {
                if (pc.identifications != null) {
                	for (IdentificationsInfo ii : pc.identifications) {
                    	if (ii.type != null && ii.type.code != null && ii.type.code == 'cif' && ii.numbers != null) {
                        	// found CIF number to update
                            if (ii.numbers == CIF) {
                           		return pc;
                            }
                        }
                    }
                }
        	}    
        }
        return null;
    }
    
    private void CleanLargeAccountLists() {
    	// Piece to clear out big account Lists
        for (ClientDetail cd : ClientDetails) {
            if (cd.account != NULL && cd.account.size() > 500) {
                for(Integer j = 0; j < cd.account.size(); j++) {
                    if (cd.account[j].accountStatus != NULL && cd.account[j].accountStatus.value != NULL && cd.account[j].accountStatus.value == 'CLOSED') {
                        cd.account.remove(j);                        
                    }
                }
            }    
        }    
    }
    
    // Class which defines the Client details returned in Adapt360 Service
    public class ClientDetail implements Comparable {
        public AccountInfo[] account{get;set;}
        public IndividualInfo individual{get;set;}
        public CustomerDetailsInfo customerDetails{get;set;}
        public LocationInfo location{get;set;}
        public ContactInfo contact{get;set;}
        public CorporateEntityInfo corporateEntity{get;set;}
        public CustomerInfo customer{get;set;}
        public MetaInfo meta{get;set;}
        public IdentificationsInfo[] identifications{get;set;}
        public String links{get;set;}
        public FlagInfo flags{get;set;}
        public AuthorityInfo[] authority{get;set;}
        public String id{get;set;}
        
        // we order clients alphabetically by AuthorityType, then Name
        public Integer compareTo(Object compareTo) {
            String thisCombined;
            if (individual.salutationType.description.value != null) thisCombined = thisCombined + individual.salutationType.description.value.trim();
            if (individual.nameInitials.value != null) thisCombined = thisCombined + individual.nameInitials.value.trim();
            if (individual.surname.value != null) thisCombined = thisCombined + individual.surname.value.trim();
            if (authority.size() > 0 && authority[0].authorityType.value != null) thisCombined = authority[0].authorityType.value + thisCombined;
            ClientDetail compareToclient = (ClientDetail)compareTo;
            String compareTocombined;
            if (compareToclient.individual.salutationType.description.value != null) compareTocombined = compareTocombined + compareToclient.individual.salutationType.description.value.trim();
            if (compareToclient.individual.nameInitials.value != null) compareTocombined = compareTocombined + compareToclient.individual.nameInitials.value.trim();
            if (compareToclient.individual.surname.value != null) compareTocombined = compareTocombined + compareToclient.individual.surname.value.trim();
            if (compareToclient.authority.size() > 0 && compareToclient.authority[0].authorityType.value != null) compareTocombined = compareToclient.authority[0].authorityType.value.trim() + compareTocombined;
            return thisCombined.compareTo(compareTocombined);
        }
    }
    
    public class AccountInfo implements Comparable {
        public attribute accountNumber{get;set;}
        public attribute product{get;set;}
        public attribute productType{get;set;}
        public attribute availableBalance{get;set;}
        public Decimal availableBalanceFormatted {
            get {
                if (availableBalance!=null && availableBalance.value!=null) return Decimal.valueOf(availableBalance.value); else return null;
            }
        }
        public attribute availableBalanceSpecified{get;set;}
        public attribute balance{get;set;}
        public Decimal balanceFormatted {
            get {
                if (balance!=null && balance.value!=null) return Decimal.valueOf(balance.value); else return null;
            }
        }
        public attribute balanceSpecified{get;set;}
        public attribute balanceTxt{get;set;}
        public attribute branch{get;set;}
        public attribute corporationCode{get;set;}
        public attribute dateClosed{get;set;}
        public attribute detail{get;set;}
        public attribute limits{get;set;}
        public attribute limitSpecified{get;set;}
        public attribute accountStatus{get;set;}
        public entityreference entity{get;set;}
        
        // we order accounts alphabetically by Status then Account Number
        public Integer compareTo(Object compareTo) {
            String thisCombined;
            if (accountStatus.value != null) thisCombined = thisCombined + accountStatus.value.trim();
            if (accountNumber.value != null) thisCombined = thisCombined + accountNumber.value.trim();
            String compareTocombined;
            if (((AccountInfo)compareTo).accountStatus.value != null) compareTocombined = compareTocombined + ((AccountInfo)compareTo).accountStatus.value;
            if (((AccountInfo)compareTo).accountNumber.value != null) compareTocombined = compareTocombined + ((AccountInfo)compareTo).accountNumber.value;
            return thisCombined.compareTo(compareTocombined);
        }
    }
    
    public class IndividualInfo {
        public attribute givenName{get;set;}
        public attribute nameInitials{get;set;}
        public attribute surname{get;set;}
        public keyvaluepair salutationType{get;set;}
        public keyvaluepair countryPassport{get;set;}
        public keyvaluepair countryOfBirth{get;set;}
        public keyvaluepair gender{get;set;}
        public keyvaluepair nationality{get;set;}
        public keyvaluepair employmentStatusType{get;set;}
        public DocumentDetailsInfo documentDetails{get;set;}
        public attribute birthDate{get;set;}
        public keyvaluepair countryOfOrigin{get;set;}
        public keyvaluepair countryOfResidence{get;set;}
    }
    
    public class CustomerDetailsInfo {
        public keyvaluepair identificationTypeId{get;set;}
        public attribute individualId{get;set;}
        public attribute universalResourceLocator{get;set;}
        public keyvaluepair customerType{get;set;}
        public keyvaluepair groupScheme{get;set;}
        public keyvaluepair sourceOfFundsCode{get;set;}
        public keyvaluepair sourceOfIncomeCode{get;set;}
        public keyvaluepair corporateDivision{get;set;}
        public attribute NCAThreshold{get;set;}
        public attribute CPAThreshold{get;set;}
        public keyvaluepair sbuSegment{get;set;}
        public attribute forensicHold{get;set;}
        public attribute inLiquidation{get;set;}
        public attribute underJudicialManagement{get;set;}
        public attribute financialCrime{get;set;}
        public attribute inBusinessRescue{get;set;}
        public attribute inBusinessRescueAffectedParty{get;set;}
        public attribute placedInBusinessRescueBy{get;set;}
        public attribute casaReference{get;set;}
    }
    
    public class LocationInfo {
        public Address physicalAddress{get;set;}
        public Address postalAddress{get;set;}
        public Address businessAddress{get;set;}
        public Address headOfficeAddress{get;set;}
    }
    
    public class Address {
        public attribute addressName1{get;set;}
        public attribute addressName2{get;set;}
        public attribute suburbName{get;set;}
        public attribute cityName{get;set;}
        public attribute postCodeArea{get;set;}
        public attribute addressTypeCode{get;set;}
        public attribute addressType{get;set;}
    }
    
    public class ContactInfo {
        public attribute cellPhoneNumber{get;set;}
        public keyvaluepair communicationChannelType{get;set;}
        public attribute workPhone{get;set;}
        public attribute homePhone{get;set;}
        public attribute telephoneNumber{get;set;}
        public attribute eMailUserId{get;set;}
        public attribute contactPerson{get;set;}
        public attribute designation{get;set;}
    }
    
    public class CorporateEntityInfo {
        public keyvaluepair incorporatedCountry{get;set;}
        public keyvaluepair standardIndustryCode{get;set;}
    }
    
    public class CustomerInfo {
        public CustomerDetails Details;
    }
    
    public class CustomerDetails {
        public attribute CPAThreshold{get;set;}
    }
    
    public class MetaInfo {
        public QueryResultInfo queryResult;
    }
    
    public class QueryResultInfo {
        public String sourceSystem{get;set;}
        public String type{get;set;}
    }
    
    public class IdentificationsInfo {
        public IdentificationType type{get;set;}
        public String numbers{get;set;}
        public Boolean personalIdentificationFlag{get;set;}
        public Boolean systemIdentificationFlag{get;set;}
        public String issueDate{get;set;}
        public String expiryDate{get;set;}
        public String country{get;set;}
    }
    
    public class IdentificationType {
        public String code;
        public String description;
    }
    
    public class FlagInfo {
        public attribute compliant{get;set;}
        public keyvaluepair reason{get;set;}
    }
    
    public class AuthorityInfo {
        public SignatoryDetailsInfo[] signatoryDetails{get;set;}
        public attribute authorityTypeCode{get;set;}
        public attribute customerCode{get;set;}
        public attribute accountNumber{get;set;}
        public attribute changeTrackingNumber{get;set;}
        public attribute courtAuthorityCode{get;set;}
        public attribute numberOfSignatures{get;set;}
        public attribute employeeNumber{get;set;}
        public attribute originalCourtAuthorityCode{get;set;}
        public attribute originalNumberOfSignatures{get;set;}
        public attribute originalSpecialConditions{get;set;}
        public attribute overrideEmployeeNumber{get;set;}
        public attribute specialConditions{get;set;}
        public attribute status{get;set;}
        public attribute changedSignatory{get;set;}
        public attribute authorityType{get;set;}
    }
    
    public class SignatoryDetailsInfo {
        public ProductInfo product;
        public attribute dateIssued{get;set;}
        public attribute expiryDate{get;set;}
        public attribute maximumAmount{get;set;}
        public Decimal maximumAmountFormatted {
            get {
                if (maximumAmount!=null && maximumAmount.value!=null) return Decimal.valueOf(maximumAmount.value); else return null;
            }
        }
        public entityreference entity{get;set;}
    }
    
    public class ProductInfo {
        public attribute accountNumber{get;set;}
    }
    
    public class DocumentDetailsInfo {
        public DocumentInfo idDoc{get;set;}
        public DocumentInfo addDoc{get;set;}
    }
    
    public class DocumentInfo {
        public attribute casaTier{get;set;}
        public keyvaluepair documentType{get;set;}
        public keyvaluepair documentStatusReason{get;set;}
        public attribute casaSequence{get;set;}
        public attribute imageId{get;set;}
        public attribute casaReference{get;set;}
        public attribute documentRecieved{get;set;}
        public attribute documentInOrder{get;set;}
        public attribute qualityAssurance{get;set;}
        public attribute allCorrectRecieved{get;set;}
        public attribute allCorrectInOrder{get;set;}
    }
    
    public class attribute { public String value{get;set;} }
    public class entityreference { public String ref{get;set;} }
    public class keyvaluepair {
        public attribute code{get;set;}
        public attribute description{get;set;}    
    }
    
    //RN - CloudSmiths 
    @future
    private static void auditCIFSearch(String queryType, String queryValue, String userId, String caseId, String caseCIF,String AccountName){
        
        CIF_Search_Audit__c audit = new CIF_Search_Audit__c();
        audit.CaseId__c = caseId;
        audit.CaseCIFNumber__c = caseCIF;
        audit.UserId__c = userId;
        audit.SearchAction__c = queryType;
        audit.SearchValue__c = queryValue;
        audit.Relationship__c = AccountName;
        
        try{
            
            insert audit;
            
        }catch(DMLException ex){
            System.debug('There was an Error when logging the audit record for CIF searches');
            System.debug(ex.getMessage());
        }
    }
}