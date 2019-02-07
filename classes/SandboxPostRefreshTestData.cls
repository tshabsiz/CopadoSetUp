/*==========================================
@Author : Mabhedle Tonga
@Description : Functional class for post refresh
@Created Date : 2018/04/c
============================================*/
public  class SandboxPostRefreshTestData {

    
    public SandboxPostRefreshTestData()
    {
        setupCSCContact();
        setupAdminUsers();
        createRelatioshipGroup();
        createOpportunity();
        createCallReport();
    }
    public void setupCSCContact()
    {
        try
        {
            Contact CSCSupportContact = new Contact(email='agents@support.co.za',firstName='Support',LastName='Agent'); 
            insert CSCSupportContact;
        }
        catch(Exception exc)
        {
            System.debug(' Error on Contact Creation : '+exc.getMessage() + ' '+exc.getStackTraceString()+' '+exc.getCause());
        }
        
    }
    public void setupAdminUsers()
    {
        try{
            List<User> adminUserList = [Select ID,email 
                                        from User 
                                        where isActive = true
                                        and (Profile.Name ='Barclays Administrator')];
            
            for(User currentUser : adminUserList)
            {
                currentUser.email = currentUser.email.replace('@example.com', '').replace('=', '@');
                System.debug(currentUser.email);
            }
            
            update adminUserList;
        }
        catch(Exception exc)
        {
            System.debug(' Error on Admin update : '+exc.getMessage() + ' '+exc.getStackTraceString()+' '+exc.getCause());
        }
    }
    public StaticResource getStaticResourceByName(String staticResName)
    {
        return [Select  Body, Name From StaticResource s where Name =:staticResName];
    }
    
    private Static Map<String,Account> nameToIDMap{get;set;}
    public Map<String,Account> getAccountNameToID()
    {
        if(nameToIDMap==null)
        {
            nameToIDMap = new Map<String,Account>();
            for(Account varAccount :[Select ID,Name,OwnerID from Account])
            {
                nameToIDMap.put(varAccount.Name,varAccount);
            }
            
        }
            
        return nameToIDMap;
    }
    public void createRelatioshipGroup()
    {
        try
        {
            //Tonga MM : get CSV file for creating relationship group accounts
            StaticResource statRes = getStaticResourceByName('Accountdata');
            
            String accountString = statRes.Body.ToString();
            String relatioshipGroupRecordTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group').getRecordTypeId();
            
            //Tonga MM : Split each line into a seperate record entry
            List<String> accountStringList = accountString.split('\n');
            List<Account> accountToInsertList = new List<Account>(); 
            
            //Tonga MM : Remove heading row in collection
            accountStringList.remove(0);
            
            for(String varStr :accountStringList)
            {
                List<String> accountStr = varStr.split(',');
                if(accountStr.size()>0){
                    Account newAccount  = new Account();
                    newAccount.OwnerID = accountStr[1];
                    newAccount.Name = accountStr[2];
                    newAccount.RecordTypeId = relatioshipGroupRecordTypeID;
                    newAccount.Type = accountStr[4];
                    // newAccount.ShippingCountry = accountStr[5];
                    newAccount.Segment__c = accountStr[6];
                    newAccount.Industry = accountStr[7];
                    accountToInsertList.add(newAccount);
                }
                
            }
            
            insert accountToInsertList; 
        }
        catch(Exception exc)
        {	
            System.debug(' Error on Account Creation : '+exc.getMessage() + ' '+exc.getStackTraceString()+' '+exc.getCause());
        }
    }
    
    public void createOpportunity()
    {
        try
        {
            //Tonga MM : get CSV file for creating opportunities
            StaticResource statRes = getStaticResourceByName('OpportunityData');
            
            String opportunityString = statRes.Body.ToString();
            
            //Tonga MM : Split each line into a seperate record entry
            List<String> opportunityStringList = opportunityString.split('\n');
            List<Opportunity> opportunityToInsertList = new List<Opportunity>(); 
            
            //Tonga MM : Remove heading row in collection
            opportunityStringList.remove(0);
            
            Map<String,Account> nameToID = getAccountNameToID();
            
            for(String varStr :opportunityStringList)
            {
                List<String> opportunityStr = varStr.split(',');
                if(nameToID.containsKey(opportunityStr[6]))
                {
                    Opportunity newOpportunity = new Opportunity();
                    newOpportunity.AccountId = nameToID.get(opportunityStr[6]).ID;
                    newOpportunity.Name = opportunityStr[0];
                    newOpportunity.Type = opportunityStr[1];
                    newOpportunity.LeadSource = opportunityStr[2];
                    newOpportunity.CurrencyISOCode = opportunityStr[3];
                    newOpportunity.Amount = Integer.valueOf(opportunityStr[4]);
                    newOpportunity.CloseDate = Date.valueOf(opportunityStr[5]);
                    newOpportunity.stageName = opportunityStr[7];
                    newOpportunity.Description = opportunityStr[8];
                    newOpportunity.OwnerId = UserInfo.getUserId();//ID.valueOf(opportunityStr[9]); 
                    opportunityToInsertList.add(newOpportunity);
                }
            }
            insert opportunityToInsertList;
        }
        catch(Exception exc)
        {
            System.debug(' Error on Opportunity Creation : '+exc.getMessage() + ' '+exc.getStackTraceString()+' '+exc.getCause());
        }
    }
    
    public void createCallReport()
    {
        try
        {
            //Tonga MM : get CSV file for creating opportunities
            StaticResource statRes = getStaticResourceByName('CallReportData');
            
            String callReportFile = statRes.Body.ToString();
            
            //Tonga MM : Split each line into a seperate record entry
            List<String> callReportStringList = callReportFile.split('\n');
            List<Call_Report__c> callReportToInsertList = new List<Call_Report__c>(); 
            
            //Tonga MM : Remove heading row in collection
            callReportStringList.remove(0);
            
            Map<String,Account> nameToID = getAccountNameToID();
            
            for(String varStr :callReportStringList)
            {
                
                List<String> callReportStr = varStr.split(',');
                System.debug(callReportStr[9].trim());
                if(nameToID.containsKey(callReportStr[9].trim()))
                {
                    Call_report__c newCallReport = new Call_report__c(CurrencyISOCode = callReportStr[0],OwnerId = nameToID.get(callReportStr[9].trim()).OwnerID,
                                                                      Description__c = callReportStr[2],Location__c = callReportStr[3],
                                                                      Meeting_Date__c = Date.ValueOf(callReportStr[4]),
                                                                      Meeting_Reason2__c = callReportStr[5],	
                                                                      Needs_Identified_Proposed_Solutions__c = callReportStr[6],
                                                                      Subject__c = callReportStr[7],Type__c = callReportStr[8],
                                                                      Relationship__c =nameToID.get(callReportStr[9].trim()).ID);
                    callReportToInsertList.add(newCallReport);
                }
            }
            
            Database.insert(callReportToInsertList,true);
        }
        catch(Exception exc)
        {
            System.debug(' Error on Call Report Creation : '+exc.getMessage() + ' '+exc.getStackTraceString()+' '+exc.getCause());
        }
        
    }
}