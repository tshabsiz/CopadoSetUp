/*-------------------------------------------------------
@CreatedBY : Mabhedle Tonga 
@CreatedDate : 2018-08-01
@Description : Functional class for CSC functions
@Test Class : CSC_Utility_Test
------------------------------------------------------*/
public class CSC_Utility {
    
    private static String workoutFileHeader = 'Case Number,Date Actioned,BRID,Team,Service Type Task,Workout \n';
    private static string WIPFileHeader = 'Case Number,Date Actioned,Team,Subcategory,Service Type,WIP \n';
    
    public static void createWorkoutFile(List<WIP_Log__c> wipLogList)
    {
        boolean emailSent = false;
        string fileToSubmit = workoutFileHeader;
        for(WIP_Log__c wiplog : wipLogList)
        {
            String strActionedDate = DateTime.newInstance(wiplog.Date_Actioned__c.year(),wiplog.Date_Actioned__c.month(),wiplog.Date_Actioned__c.day()).format('YYYY-MM-dd');
            string recordString = wiplog.Case__r.CaseNumber+','+strActionedDate+','+wiplog.BRID__c+','+wiplog.Team__c+','+wiplog.Service_Type_Task__c+','+wiplog.Workout__c +'\n';
            fileToSubmit = fileToSubmit +recordString;
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(fileToSubmit);
        string csvname= 'WorkoutFile.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String subject ='WorkoutFile';
        
        List<String> toAddresses = new List<String>();
        toAddresses.addAll(getAOMEmailAddress());
        Id tempId =[select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName = :Label.lblSupportUserName limit 1].id;
        email.setOrgWideEmailAddressId(tempId);
        email.setTargetObjectId(userInfo.getUserId());
        email.setSubject(subject);
        email.setSaveAsActivity(false);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('createWorkoutFile CSV File');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        mails.add(email);
        
        List<Messaging.SendEmailResult> r = Messaging.sendEmail(mails);
        
        for(Messaging.SendEmailResult result: r)
        {
            if(result.isSuccess())
            {
                emailSent = true;
                break;
            }
            
        }
        
        if(emailSent)
        {
            for(WIP_Log__c wiplog : wipLogList)
            {
                wiplog.Processed__c = true;
            }
            
            update wiplogList;
        }
        
    }
    public static List<string> getAOMEmailAddress()
    {
        String emailAddresses;
        List<String> emailAddressList =new List<String>();
        for(AOM_Recipient__mdt tempAOM :[select Email__c from AOM_Recipient__mdt])
        {
            emailAddressList.add(tempAOM.Email__c);
        }
        return emailAddressList;
        
    }
    
    public static void createWIPFile(List<Case> caseList)
    {
        boolean emailSent = false;
        string fileToSubmit = WIPFileHeader;
        for(Case currentCase : caseList)
        {
            String strActionedDate = DateTime.newInstance(currentCase.CreatedDate.year(),currentCase.CreatedDate.month(),currentCase.CreatedDate.day()).format('YYYY-MM-dd');
            string recordString = currentCase.CaseNumber+','+currentCase.CreatedDate+','+currentCase.Queue__c+','+currentCase.Subcategory__c+','+currentCase.Service_Type__c+','+currentCase.WIP__c +'\n';
            fileToSubmit = fileToSubmit +recordString;
        }
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
        blob csvBlob = Blob.valueOf(fileToSubmit);
        string csvname= 'WIP.csv';
        csvAttc.setFileName(csvname);
        csvAttc.setBody(csvBlob);
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new list<string> ();
        String subject ='WIP CSV';
        toAddresses.addAll(getAOMEmailAddress());
        Id tempId =[select Id,Address,DisplayName from OrgWideEmailAddress where DisplayName = :Label.lblSupportUserName limit 1].id;
        email.setOrgWideEmailAddressId(tempId);
        email.setTargetObjectId(userInfo.getUserId());
        email.setSubject(subject);
        email.setSaveAsActivity(false);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('WIP CSV ');
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        mails.add(email);
        
        List<Messaging.SendEmailResult> r = Messaging.sendEmail(mails);
        
        for(Messaging.SendEmailResult result: r)
        {
            if(result.isSuccess())
            {
                emailSent = true;
                break;
            }
            
        }
    }
    
    
    public static void updateWIP(Map<id,Case> newCasemap, Map<ID,Case>OldCaseMap)
    {
        for(id varCaseId : OldCaseMap.keySet())
        {
            if(OldCaseMap.get(varCaseId).WIP__c!= null && newCasemap.get(varCaseId).WIP__c!=null)
            {
                if(OldCaseMap.get(varCaseId).WIP__c>newCasemap.get(varCaseId).WIP__c){
                    if(OldCaseMap.get(varCaseId).WIP__c!=newCasemap.get(varCaseId).WIP__c){
                        newCasemap.get(varCaseId).Processed_Requests__c = OldCaseMap.get(varCaseId).WIP__c-newCasemap.get(varCaseId).WIP__c;
                    } 
                }
            }
        }
    }
    
    public static void DefualtWIP(List<Case> caseNewList)
    {
        for(Case tempCase: caseNewList)
        {
            if(tempCase.Number_Of_Requests__c!=null)
            {
                tempCase.Wip__c = tempCase.Number_Of_Requests__c;
            }		
        }
    }
   
}