Public Class CaseUtilityHandler{



public static void AddMembers(List<Case> lst_Case){

    Set<String> Set_CaseId = new Set<String>();
    
    RecordType rt = [Select id from recordtype where Name='Knowledge Request'];
    for(Case c:lst_Case){
        if(c.Status=='Automation in progress' && c.recordtypeid==rt.id){
            Set_CaseId.Add(c.id);
        }    
    }
    
    
   // CaseTeamRole[] teamrole = [SELECT Id,Name FROM CaseTeamRole where name=: 'Leap - Document Automation Team']; Document Automation Team
   // List<CaseTeamMember> lst_CaseTeamMember = new List<CaseTeamMember>([SELECT Id,MemberId,ParentId,TeamRoleId  FROM CaseTeamMember where ParentId in: Set_CaseId AND TeamRoleId =: teamrole[0].id]);
    
    
    CaseTeamTemplate[] TeamTemplate = [SELECT Id,Name FROM CaseTeamTemplate where name='Document Automation Team']; 
    
    if(!Set_CaseId.isEmpty())
    {
        List<CaseTeamTemplateRecord> lst_TemplateRecord = [SELECT Id,ParentId,TeamTemplateId FROM CaseTeamTemplateRecord where TeamTemplateId =: TeamTemplate[0].id];
        
        
        
        Set<String> Set_CaseTmp = new Set<String>();
        
        for(CaseTeamTemplateRecord tmpl:lst_TemplateRecord){
            Set_CaseTmp.Add(tmpl.ParentId);
        }
        
     
        for(Case c:lst_Case){
            if(Set_CaseId.Contains(c.id) && !Set_CaseTmp.contains(c.id)){
                CaseTeamTemplateRecord record = new CaseTeamTemplateRecord();
                record.ParentId  = c.id;
                record.TeamTemplateId = TeamTemplate[0].id;
                system.debug('**record**'+record);
                system.debug('**case**'+c);
                Insert record;
            }    
        }
    }
  
    
}
public static void AddLegalTeam(List<Case> lst_Case){

    Set<String> Set_CaseId = new Set<String>();
    
    RecordType rt = [Select id from recordtype where Name='Knowledge Request'];
    for(Case c:lst_Case){
        if(c.Status=='Ready for Use' && c.recordtypeid==rt.id){
            Set_CaseId.Add(c.id);
        }    
    }
    
    
   // CaseTeamRole[] teamrole = [SELECT Id,Name FROM CaseTeamRole where name=: 'Leap - Document Automation Team'];
    
   // List<CaseTeamMember> lst_CaseTeamMember = new List<CaseTeamMember>([SELECT Id,MemberId,ParentId,TeamRoleId  FROM CaseTeamMember where ParentId in: Set_CaseId AND TeamRoleId =: teamrole[0].id]);
    
    
    CaseTeamTemplate[] TeamTemplate = [SELECT Id,Name FROM CaseTeamTemplate where name='Legal Team'];

    if(!Set_CaseId.isEmpty())
    {
    
        List<CaseTeamTemplateRecord> lst_TemplateRecord = [SELECT Id,ParentId,TeamTemplateId FROM CaseTeamTemplateRecord where TeamTemplateId =: TeamTemplate[0].id];
        
        
        
        Set<String> Set_CaseTmp = new Set<String>();
        
        for(CaseTeamTemplateRecord tmpl:lst_TemplateRecord){
            Set_CaseTmp.Add(tmpl.ParentId);
        }
        
     
        for(Case c:lst_Case){
            if(Set_CaseId.Contains(c.id) && !Set_CaseTmp.contains(c.id)){
                CaseTeamTemplateRecord record = new CaseTeamTemplateRecord();
                record.ParentId  = c.id;
                record.TeamTemplateId = TeamTemplate[0].id;
                system.debug('**record**'+record);
                system.debug('**case**'+c);
                Insert record;
            }    
        }
    }  
    
}



public static void checklawyer(List<Case> lst_Case){


    Set<String> Set_CaseId = new Set<String>();
    Map<string,string> Map_Reviewer = new Map<string,string>();
    
    RecordType rt = [Select id from recordtype where Name='Knowledge Request'];
    CaseTeamRole[] CaseTeamRole = [SELECT Id,Name FROM CaseTeamRole where name=:'Leap - Content Reviewer'];
    
    for(Case c:lst_Case){
        if(c.Status=='Ready for Review' && c.recordtypeid==rt.id){
            Set_CaseId.Add(c.id);
           
        }    
    }
   
   if(!Set_CaseId.isEmpty())
   {
        Set<String> Set_CaseTmp = new Set<String>();
        CaseTeamMember[] CaseTeamMember = [SELECT Id,MemberId,ParentId,TeamRoleId,TeamTemplateMemberId FROM CaseTeamMember where ParentId in:Set_CaseId AND TeamRoleId=:CaseTeamRole[0].id];
   
       

       for(CaseTeamMember tmpl:CaseTeamMember)
       {
           Set_CaseTmp.Add(tmpl.ParentId);
       }
   
    
   
       for(Case c:lst_Case){
         if(c.Status=='Ready for Review' && c.recordtypeid==rt.id){  
              if(!Set_CaseTmp.contains(c.id)){      
                  if(c.Content_Reviewer__c != null){
                       CaseTeamMember TeamMember = new CaseTeamMember();
                       TeamMember.ParentId = c.id;
                       TeamMember.MemberId = c.Content_Reviewer__c;
                       TeamMember.TeamRoleId=CaseTeamRole[0].id;
                       Insert TeamMember;
                        c.Leap_Content_review_count__c=1;
                          
                  }
                  else{
                       c.Leap_Content_review_count__c=0;
                  }
              }    
           }
        }
    }   

}


Public static void ApprovalUAT(List<Case> lst_Case){

    
   Set<String> Set_CaseId = new Set<String>();
    Map<string,string> Map_Reviewer = new Map<string,string>();
    
   id rt  = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Knowledge Request').getRecordTypeId();
    
    //RecordType rt = [Select id from recordtype where Name='Knowledge Request'];
    CaseTeamRole[] CaseTeamRole = [SELECT Id,Name FROM CaseTeamRole where name=:'Leap - Content Reviewer']; 
    
    
    for(Case c:lst_Case){
    system.debug('**Status**'+c.Status +'*****'+rt);
        if(c.Status=='Ready For UAT' && c.recordtypeid==rt){
            Set_CaseId.Add(c.id);        
        }    
    }
   
   if(!Set_CaseId.isEmpty())
   {
   
   
    
       CaseTeamMember[] CaseTeamMember = [SELECT Id,MemberId,ParentId,TeamRoleId,TeamTemplateMemberId FROM CaseTeamMember where ParentId in:Set_CaseId AND TeamRoleId=:CaseTeamRole[0].id];
       
       
       system.debug('**Set**'+Set_CaseId+'**Mem**'+CaseTeamMember);
       
       
       
       Set<String> Set_CaseTmp = new Set<String>();
       for(CaseTeamMember tmpl:CaseTeamMember){
         
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(tmpl.ParentId); // Submit on behalf of a specific submitter req1.setSubmitterId(user1.Id);
            req1.setSkipEntryCriteria(true);
            req1.setSubmitterId(tmpl.MemberId);     // we can use req1.setAction('Approve')  to approve or reject record from the class as well.
          
          if(!Approval.isLocked(tmpl.ParentId)){  
            Approval.ProcessResult result = Approval.process(req1);
          }  
       }


    }
   
   
   

}




}