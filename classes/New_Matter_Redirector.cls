public with sharing class New_Matter_Redirector {

    private advpm__Matter__c matter;
    private Boolean isLit_LegUser;
    public String strRecordTypeName;
    public String profileName { get; set; }

    public New_Matter_Redirector()
    {
        
    }
    
    public New_Matter_Redirector(ApexPages.StandardController stdController) 
    {
        this.matter = (advpm__Matter__c)stdController.getRecord();
        determineLitigator();

        List<Profile> profiles = [SELECT Id, Name FROM Profile WHERE Id= :UserInfo.getProfileId() LIMIT 1];
        profileName = profiles[0].Name;
    }
/*
    public New_Matter_Redirector(ApexPages.StandardSetController stdController) 
    {
        
    }
*/
    
    public PageReference redirect() 
    {
        
        String MatterId;
        if(profileName == 'TMG Standard User')
        {
            PageReference customPage = new PageReference('/apex/Matter_Deal_Override');
            customPage.getParameters().putAll(ApexPages.CurrentPage().getParameters());
            return customPage;
        }

        if (ApexPages.currentPage().getParameters().get('RecordType') == null) 
        {           
            Schema.DescribeSObjectResult describeRequest = Schema.SObjectType.advpm__Matter__c;
            List<Schema.RecordTypeInfo> rtInfos = describeRequest.getRecordTypeInfos();            
             
            for(Schema.RecordTypeInfo rtInfo : rtInfos) 
            {
                if(rtInfo.getName() != 'Master' && rtInfo.isAvailable()) 
                {
                    strRecordTypeName = rtInfo.getName();
                    Matter.RecordTypeId= rtInfo.getRecordTypeId();                    
                }
            }

            MatterId = ApexPages.currentPage().getParameters().get('id');

            if(MatterId !=null)
            {               
               advpm__Matter__c[] Matter = [Select id,RecordType.Name from advpm__Matter__c Where id=: MatterId];
               strRecordTypeName = Matter[0].RecordType.Name;     
            }
            
            }   
        else
        {
            strRecordTypeName=Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosById().get(Matter.RecordTypeId).getName();
        }

        if(strRecordTypeName=='Legal' || strRecordTypeName=='Litigation Matter')
        {
            PageReference customPage;
            if(MatterId !=null){
                 customPage = new PageReference('/'+MatterId+'/e?nooverride=1&');   
            }
            else{
                customPage = new PageReference('/apex/MatterKnowledgeDisplayV2');
            }        
            customPage.getParameters().putAll(ApexPages.CurrentPage().getParameters());
            return customPage;
        } 
        else if(strRecordTypeName=='Deal')
        {
            PageReference customPage = new PageReference('/apex/Matter_Deal_Override');
            customPage.getParameters().putAll(ApexPages.CurrentPage().getParameters());
            return customPage;
        }
         else if(strRecordTypeName=='Market Transaction' || strRecordTypeName=='Market Transaction - Prime Services')
        {
            if(MatterId !=null) {
                PageReference customPage = new PageReference('/apex/Matter_Deal_Override_MarketTransaction?matterId=' + MatterId);
                return customPage;
            }
            else
            {
                PageReference customPage = new PageReference('/apex/Matter_Deal_Override_MarketTransaction');
                return customPage;
            }
        }
        else 
        {
            Schema.DescribeSObjectResult token = advpm__Matter__c.SObjectType.getDescribe();
            PageReference standardPage = new PageReference('/' + token.getKeyPrefix() + '/e');
            standardPage.getParameters().putAll(ApexPages.CurrentPage().getParameters());           
            standardPage.getParameters().remove('save_new');
            standardPage.getParameters().remove('save');
            standardPage.getParameters().put('nooverride', '1');
            return standardPage;
        }
    }

    private void determineLitigator() 
    {
        List<Profile> lit_LegProfileId = [
            SELECT 
                Id 
            FROM Profile 
            WHERE 
                Name = 'Litigation Standard User' 
                OR Name = 'Legal Standard User' 
                OR Name like '%Admin%'];
        
        for(Profile i:lit_LegProfileId)
        {
            if(UserInfo.getProfileId() == i.id)
            {
                isLit_LegUser = True;
            }
        }
    }
}