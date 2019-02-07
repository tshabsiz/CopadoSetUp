public class ClientOnbaording_Controller {

    private Map <String, List<SelectOption>> legalEntitiesMaps{get;set;}
    public String selectKey{get;set;}
    public Account currentAccount{get;set;}
    public Map<String,String> legalEntityMap{get;set;}
    public Map<String,String> ContactDetailMap{get;set;}
    
    public STring BASE_ENDPOINT_ESP{get;set;}
    public String GET_LEGAL_ENTITIES{get;set;}
    public String GET_CONTACT_DETAILS{get;set;}
    public integer TIMEOUT{get;set;}
    public String X_IBM_Client_Id{get;set;}
    public String X_IBM_Client_Secret{get;set;}
    
    //Tonga MM : Selected Values from Piclist
    public String selectedIDType{get;set;}
    public String selectedLegelEntity{get;set;}
    public String selectedClientGroup{get;set;}
    public String selectedCountry{get;set;}
    public String selectedContactID{get;set;}
    public Map<ID,Contact> ContactMap{get;set;}
    
    
    public ClientOnbaording_Controller(ApexPages.StandardController stdCon)
    {
        
        String AccountID  = ApexPages.currentPage().getParameters().get('ID');
        
        if(!String.isBlank(AccountID))
        {
            currentAccount = [Select ID,Name,Country_Of_Incorporation__c,Registration_Number__c,ID_Type__c,Legal_Entity__c ,
                              (Select ID,name,phone,Email,MobilePhone 
                               from Contacts 
                               where Email !=null 
                               AND phone !=null),
                              Client_Group__c,Client_Type__c,Trust_pension_provident_other_fund_numbe__c,Date_Established__c,Contact_Detail_Type__c 
                              from Account where ID =: accountID];
        }
        
      
    legalEntitiesMaps = new Map <String, List<SelectOption>>();
        List<String>NaturalPersons = new List<String>();
        List<String>Legal_Entity_Persons = new List<String>();
        
        
        
        for(ADAPT360_Integration_Setting__mdt AIS : [SELECT DeveloperName, Setting__c FROM ADAPT360_Integration_Setting__mdt WHERE DeveloperName IN('BASE_ENDPOINT_ESP','TIMEOUT','X_IBM_Client_Id','X_IBM_Client_Secret','GET_LEGAL_ENTITIES','GET_CONTACT_DETAILS')])
        {
            if (AIS.DeveloperName == 'BASE_ENDPOINT_ESP') BASE_ENDPOINT_ESP = AIS.Setting__c;
            if (AIS.DeveloperName == 'GET_LEGAL_ENTITIES') GET_LEGAL_ENTITIES = AIS.Setting__c;
            if (AIS.DeveloperName == 'TIMEOUT') TIMEOUT = integer.valueof(AIS.Setting__c);
            if (AIS.DeveloperName == 'X_IBM_Client_Id') X_IBM_Client_Id = AIS.Setting__c;
            if (AIS.DeveloperName == 'X_IBM_Client_Secret') X_IBM_Client_Secret = AIS.Setting__c;
            if (AIS.DeveloperName == 'GET_CONTACT_DETAILS') GET_CONTACT_DETAILS = AIS.Setting__c;
    }
        
        getContactDetail();
    }
    
    public List<SelectOption> getContactNames() {
        List<SelectOption> contactOptions= new List<SelectOption>();
    ContactMap = new Map<ID,Contact>();
        
        contactOptions.add( new SelectOption('','--Select--'));
        for(Contact con : currentAccount.Contacts ) {
            contactOptions.add(new SelectOption(con.Id,con.name));
            ContactMap.put(con.Id,con);
        }
        return contactOptions;
    }
    public List<SelectOption> getContactDetail()
    {
        List<SelectOption> selectOptions = new List<SelectOption>();
         List<ESPUtility.ContactDetail> ContactDetailList = new List<ESPUtility.ContactDetail>();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setTimeout(TIMEOUT);
        
        req.setEndpoint(BASE_ENDPOINT_ESP+'/'+GET_CONTACT_DETAILS);
        req.setMethod('GET');
        req.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
        req.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
        
        //Tonga MM : For Testing Http Callout
         if(Test.isRunningTest())
        {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('ESPContactDetailResponse');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);
        }
        HTTPResponse res = h.send(req);
       
    String genString = cleanString(res.getBody());
        ContactDetailList = (List<ESPUtility.ContactDetail>)System.JSON.deserialize(genString, List<ESPUtility.ContactDetail>.class);
        ContactDetailMap = new Map<String,String>();
        
        integer index=0,foundIndex=0;
        for(ESPUtility.ContactDetail CD :ContactDetailList)
        {
            ContactDetailMap.put(CD.Code, CD.Name);
            
            if(CD.Name.equalsIgnoreCase(currentAccount.Contact_Detail_Type__c))
            {
                foundIndex=index;
            }
            index+=1;
            selectOptions.add(new SelectOption(CD.Code, CD.Name));
        }
        selectedContactDetail = selectOptions[foundIndex].getValue();
        return selectOptions;
    }
    
    public string selectedContactDetail{get;set;}
    
    public static String cleanString(String jsonBody)
    {
        String genString = jsonBody;
        genString = genString.replace('\\"', '"');
        genString = genString.replace('"[', '[');
        genString = genString.replace(']"', ']');
        genString = genString.replace('\\', '');
        return genString;
    }
    public List<SelectOption> getLegalEntity()
    {
        List<ESPUtility.LegalEntity> legalEntityList = new List<ESPUtility.LegalEntity>();
        List<SelectOption> legalEntities = new List<SelectOption>();
        
        if(Test.isRunningTest())
        {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('ESPLegalEntities');
            mock.setStatusCode(200);
            mock.setHeader('Content-Type', 'application/json');
            Test.setMock(HttpCalloutMock.class, mock);
        }
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        req.setTimeout(TIMEOUT);
      
        req.setEndpoint(BASE_ENDPOINT_ESP+'/'+GET_LEGAL_ENTITIES);
        System.debug(BASE_ENDPOINT_ESP+'/'+GET_LEGAL_ENTITIES);
        req.setMethod('GET');
        req.setHeader('X-IBM-Client-Id', X_IBM_Client_Id);
        req.setHeader('X-IBM-Client-Secret', X_IBM_Client_Secret);
        HTTPResponse res = h.send(req);
        
        
        String genString = cleanString(res.getBody());
      
        integer index=0,foundIndex=0;
        legalEntityList = (List<ESPUtility.LegalEntity>)System.JSON.deserialize(genString, List<ESPUtility.LegalEntity>.class);
        
        legalEntityMap = new Map<String,String>();
        for(ESPUtility.LegalEntity entity : legalEntityList)
        {
            legalEntityMap.put(entity.key,entity.value);
            if(entity.value.equalsIgnoreCase(currentAccount.Legal_Entity__c))
            {
                foundIndex=index;
            }
            index+=1;
            legalEntities.add(new SelectOption(entity.key,entity.Value));
        }    
        
        selectedLegelEntity = legalEntities[foundIndex].getValue();
        return legalEntities;       
    }
    
 
   
    public void sendToESP()
    {
        System.debug(selectedContactID);
        System.debug(selectedContactID);
        if(!String.isBlank(selectedContactID))
        {
            Map<String,String> val = ApexPages.currentPage().getParameters();
            System.debug(currentAccount);
            
            System.debug(selectedLegelEntity);
            currentAccount.ID_Type__c = selectedIDType;
            if(legalEntityMap.containsKey(selectedLegelEntity))
            {
                currentAccount.Legal_Entity__c = legalEntityMap.get(selectedLegelEntity);
            }
            
            if(contactDetailMap.containsKey(selectedContactDetail))
            {
                currentAccount.Contact_Detail_Type__c = contactDetailMap.get(selectedContactDetail);
            }
            
            currentAccount.Client_Group__c = selectedClientGroup;
            currentAccount.Country_of_Incorporation__c = selectedCountry;
            ESPUtility.sendAccountRequiredFields(currentAccount,X_IBM_Client_Secret,X_IBM_Client_Id,BASE_ENDPOINT_ESP,TIMEOUT,selectedLegelEntity,selectedContactDetail,contactMap.get(selectedContactID));   
            System.debug(currentAccount);
            
            if(currentAccount.ESP_ID__c.equalsIgnoreCase('00000000-0000-0000-0000-000000000000'))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'A problem occured during submission, please check all required fields are populated'));
                
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Submission to ESP has been successfull'));
            }
             updateAccount();
        
        }
        else
        {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Please select a primary contact when onboarding a client'));
        }
    }
    public PageReference Cancel()
    {
        return new PageReference('/'+currentAccount.ID);
    }
    
    private List<SelectOption> prepareSelectOptionsFromDescribeFieldResult(Schema.DescribeFieldResult f) {
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        for (Schema.PicklistEntry e: p) {
            options.add(new SelectOption(e.getLabel(), e.getValue()));
        }
        return options;
    }
     public List<SelectOption> getIDTypeOptions() {
        Schema.DescribeFieldResult f = Account.ID_Type__c.getDescribe();
         
         
         List<SelectOption> IDTypes = prepareSelectOptionsFromDescribeFieldResult(f);
         
          integer index=0,foundIndex=0;
         for(SelectOption option :IDTypes)
         {
             if(option.getValue().equalsIgnoreCase(currentAccount.ID_Type__c))
             {
                 foundIndex = index;                 
             }
            index+=1;
         }
         selectedIDType = IDTypes[foundIndex].getValue();
         return IDTypes;
    }
    public List<SelectOption> getCleintTypeOptions() {
        Schema.DescribeFieldResult f = Account.Client_Type__c.getDescribe();
        
        return prepareSelectOptionsFromDescribeFieldResult(f);
    }
    
    public List<SelectOption> getClientGroupOptions() {
        Schema.DescribeFieldResult f = Account.Client_Group__c.getDescribe();
        List<SelectOption> clientGroups =  prepareSelectOptionsFromDescribeFieldResult(f);
        
        integer index=0,foundIndex=0;
        for(SelectOption option: clientGroups)
        {
            if(option.getValue().equalsIgnoreCase(currentAccount.Client_Group__c))
            {
                foundIndex = index;                 
            }
            index+=1;
        }
        
        selectedClientGroup = clientGroups[foundIndex].getValue();
        return clientGroups;
    }
    public List<SelectOption> getCountryOptions()
    {
        Schema.DescribeFieldResult f = Account.Client_Country__c.getDescribe();
        List<SelectOption> countryOptions = prepareSelectOptionsFromDescribeFieldResult(f);
        
        integer index=0,foundIndex=0;
        for(SelectOption option : countryOptions)
        {
             if(option.getValue().equalsIgnoreCase(currentAccount.Country_of_Incorporation__c))
            {
                foundIndex = index;                 
            }
            index+=1;
        }
        
        selectedCountry = countryOptions[foundIndex].getValue();
        return countryOptions;
    }
    
    public void updateAccount()
    {
        System.debug(currentAccount.Registration_number__c);
        currentAccount.ID_Type__c = selectedIDType;
        if(legalEntityMap.containsKey(selectedLegelEntity))
        {
            currentAccount.Legal_Entity__c = legalEntityMap.get(selectedLegelEntity);
        }
        
        if(contactDetailMap.containsKey(selectedContactDetail))
        {
            currentAccount.Contact_Detail_Type__c = contactDetailMap.get(selectedContactDetail);
        }
        
        currentAccount.Client_Group__c = selectedClientGroup;
        currentAccount.Country_of_Incorporation__c = selectedCountry;
        
        Database.SaveResult sr = Database.update(currentAccount, false);

        if(sr.isSuccess())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Account information has been updated'));
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, sr.getErrors()[0].getMessage()));

        }
        
    }
    
    
}