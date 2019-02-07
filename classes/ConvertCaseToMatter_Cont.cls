/*****************************************************************************************************\
@ Func Area     : Matter
@ Author        : Tracy de Bruin
@ Date          : 19/06/2016
@ Test Class    : 
@ Description   : Create new Legal Matter and Close Query/Matter Case. Clone attachments on Case for Matter
------------------------------------------------------------------------------------------------------
@ Modified By   : Sean Parker   
@ Date          : 6/26
@ Description   : Commented out code on line 31 - allocating owner to a user not a queue
------------------------------------------------------------------------------------------------------
******************************************************************************************************/
public class ConvertCaseToMatter_Cont{
    
    public Case caseRecord;
    public advpm__Matter__c legalMatterRecord {get;set;}
    
    public ConvertCaseToMatter_Cont(ApexPages.StandardController controller) 
    {
        legalMatterRecord = new advpm__Matter__c();
        
        //Get Legal Matter record type
        if(Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Legal').getRecordTypeId() != null)
        {
            legalMatterRecord.RecordTypeId = Schema.SObjectType.advpm__Matter__c.getRecordTypeInfosByName().get('Legal').getRecordTypeId();
        }
        
        //Get Matter Allocation Queue for the Owner
        //Sean commented out the owner being a queue. Owner must be a user for Legal quote request trigger
        /*
        if([SELECT Id FROM Group where Name = 'Matter Allocation Queue' and Type = 'Queue' limit 1].Id != null)
        {
            legalMatterRecord.OwnerId = [SELECT Id FROM Group where Name = 'Matter Allocation Queue' and Type = 'Queue' limit 1].Id;
        }
        */
        
        //Get Case Id from URL Parameter
        if(ApexPages.currentPage().getParameters().get('caseId') != null && ApexPages.currentPage().getParameters().get('caseId') != '')
        {
            Id CaseRecordId = ApexPages.currentPage().getParameters().get('caseId');
            caseRecord = [SELECT Id, Business_Unit_Cluster_Segment__c, Status, Matter__c, Subject, Email_Sender_Name__c, Email_From_Address__c, ContactConfirmedWith__c, Description, Cost_Centre__c,External_Party_Name__c,External_Party_Email_Address__c,External_Party_Representative__c, AccountId, ContactId
                          FROM Case 
                          WHERE Id = :CaseRecordId LIMIT 1];
        }
        
        //Get case information and pre populate data on Matter fields
        if(caseRecord != null)
        {
            legalMatterRecord.Name = caseRecord.subject;
            legalMatterRecord.Business_Unit_Cluster_Segment__c = caseRecord.Business_Unit_Cluster_Segment__c;
            legalMatterRecord.Requestor_Name__c = caseRecord.Email_Sender_Name__c;
            legalMatterRecord.Requestor_Email_Address__c = caseRecord.Email_From_Address__c;
            legalMatterRecord.Business_Unit_Contact_Person__c = caseRecord.ContactConfirmedWith__c;
            legalMatterRecord.Description_enquiry__c = caseRecord.Description;
            legalMatterRecord.Cost_Centre__c = caseRecord.Cost_Centre__c;
            legalMatterRecord.External_Party_Details__c = 'Client Name: '+caseRecord.External_Party_Name__c+'\n'+'Client Email Address: '+caseRecord.External_Party_Email_Address__c+'\n'+'Client Representative: '+caseRecord.External_Party_Representative__c;
            legalMatterRecord.advpm__Primary_Account__c = caseRecord.AccountId;
            legalMatterRecord.advpm__Primary_Contact__c = caseRecord.ContactId;  
        }
    }
    
    //Upon Convert create Matter with attachments, close Case and link Matter to Case
    public PageReference convertCaseToMatter()
    {
        Id matterRecordId = null;
        List<Attachment> matterAttachments  = new List<Attachment>(); 
        
        //Insert Matter record
        try 
        {
            if(legalMatterRecord != null)
            {
                insert legalMatterRecord;
                matterRecordId = legalMatterRecord.id;
                
                //Close case and link matter to case
                if(caseRecord != null && matterRecordId != null)
                {
                    caseRecord.Status = 'Closed';
                    caseRecord.Matter__c = matterRecordId;
                    
                    //Get all attachments related to Case
                    for(attachment eachAttachment : [SELECT Id, ParentId, Name, IsPrivate, ContentType, BodyLength, Body, Description, OwnerId 
                                                     FROM Attachment 
                                                     WHERE Parentid =: caseRecord.Id])
                    {
                        Attachment newFile = eachAttachment.clone();
                        newFile.ParentId = matterRecordId;
                        matterAttachments.add(newFile);
                    }
                    
                    update caseRecord;
                    
                    if(matterAttachments.size() > 0)
                    {
                        insert matterAttachments;
                    }
                }
            }
        }
        catch(Exception e)
        {
            ApexPages.addMessages(e);
            return null;
        }
        
        if(matterRecordId != null)
        {
            pagereference pf= new pagereference('/' + matterRecordId);
            return pf;
        }
        else
        {
            pagereference pf= new pagereference('/home/home.jsp');
            return pf;
        }
    }
}