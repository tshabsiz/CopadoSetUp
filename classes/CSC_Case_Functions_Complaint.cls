/**
* Date   : 11-05-2016
* Author : RN - CloudSmiths
* Desc   : Utility class for Cases. Contains Functions that can be used with Case creations and updates
*--------------------------------------------
* Date   : 20170322
* Author : RN - CloudSmiths
* Desc   : Add new Org Wide Address feature for responses out of SF
*
* UPDATES:
*---------
*2017-05-16: Rudolf Niehaus - CloudSmiths : Add flexi email SLA times
*2017-05-18: Rudolf Niehaus - CloudSmiths : SLA Pause feature 
*2017-07-11: Rudolf Niehaus - CloudSmmiths : SLA 3rd party pause feature
**/
public class CSC_Case_Functions_Complaint {
    
    public Case theCase {get;set;}
    public map<String,String> serviceMap = new map<String,String>();
    public list<Service_Mapping__c> sm = new list<Service_Mapping__c>();
    public map<String,String> templateMapEmailReceipt = new map<String,String>();
    public map<String,String> templateMapCaseCreation = new map<String,String>();
    public map<String,String> templateMapCaseClose = new map<String,String>();
    public map<String,String> templateMapCaseFeedback = new map<String,String>();
    public map<String,String> orgWideAddressMap = new map<String,String>();
    
    //prevent triggers firing twice after WF field updates
    public static boolean firstRun = true;
    public static boolean firstRunTracking = true;
    
    //constructor that takes only the support email address and map relevent values out for the service mapping table
    //This constructor is used in the email to case custom email handler
    public CSC_Case_Functions_Complaint(String emailAddress){
        
        //get to to email address prefix
        String[] splitEmail = emailAddress.split('@');
        String emailPrefix = splitEmail[0];
        
        //Chater for netsupport between ABSA and Barcalys
        if(emailPrefix.contains('barclaysafrica') && emailPrefix.contains('barclays.netsupport')){
            emailPrefix = 'barclays.netsupport@barclaysafrica';
        }else if(emailPrefix.contains('absa') && emailPrefix.contains('barclays.netsupport')){
            emailPrefix = 'barclays.netsupport@absa';
        }else{
            emailPrefix+= '@';
        }
        
        sm = [Select Id, Team__c, Queue_Name__c, Queue__c, Business_Hours__c, Department__c,Channel__c, Support_Email_Address__c, 
              Full_Department__c, Team_Manager__c, Response_From_Email_Address__c, Email_SLA_Time_Measure__c , Email_SLA_Units__c   
              From Service_Mapping__c 
              Where Support_Email_Address__c like :emailPrefix + '%' 
              Order By Effective_Date__c DESC limit 1];
        
        //map service type values ONLY if we get a record back from the mapping table
        if(sm.size() > 0){
            serviceMap.put('Support_Email_Address__c', sm[0].Support_Email_Address__c);
            serviceMap.put('Team_Manager__c', sm[0].Team_Manager__c);
            serviceMap.put('Team__c', sm[0].Team__c);
            serviceMap.put('Queue_Name__c', sm[0].Queue_Name__c);
            serviceMap.put('Queue__c', sm[0].Queue__c);
            serviceMap.put('Department__c', sm[0].Department__c);
            serviceMap.put('Business_Hours__c', sm[0].Business_Hours__c);
            serviceMap.put('Channel__c', sm[0].Channel__c);
            serviceMap.put('Full_Department__c ', sm[0].Full_Department__c );
            serviceMap.put('Response_From_Email_Address__c ', sm[0].Response_From_Email_Address__c );
            serviceMap.put('Id', sm[0].Id);
            serviceMap.put('Email_SLA_Time_Measure__c', sm[0].Email_SLA_Time_Measure__c);
            serviceMap.put('Email_SLA_Units__c', sm[0].Email_SLA_Units__c);
        }
    }
    
    //
    public CSC_Case_Functions_Complaint(){}
    
    //constructor - takes the Case in scope as param and retrieve the relevant service mapping for this case
    public CSC_Case_Functions_Complaint(Case c){
        
        this.theCase = c;
        if(String.isNotBlank(theCase.Complaint_Service_Category__c)){
                sm = [Select Id, Complexity__c, First_Approval__c, ID_V_Required__c, Priority__c,SLA_Pause_Status__c,SLA_Pause_Status_Internal__c,
                      SLA__c, Second_Approval__c, Team__c, Queue_Name__c,Department__c,Queue__c, Feedback_Time_Measure__c, Feedback_Units__c,   
                      First_Escalation_Time__c, Second_Escalation_Time__c, Support_Email_Address__c,Response_From_Email_Address__c, 
                      Channel__c, Business_Hours__c, SLA_Time_Measure__c , SLA_Units__c, Full_Department__c, Team_Manager__c, Convert_To_RecordType__c     
                      From Service_Mapping__c 
                      Where Queue__c = :theCase.Resolving_Team__c 
                      and Service_Category__c = :theCase.Complaint_Service_Category__c 
                      Order By Effective_Date__c DESC Limit 1 ];
            }else{
                sm = [Select Id, Complexity__c, First_Approval__c, ID_V_Required__c, Priority__c,SLA_Pause_Status__c,SLA_Pause_Status_Internal__c,
                      SLA__c, Second_Approval__c, Team__c, Queue_Name__c,Department__c,Queue__c,Feedback_Time_Measure__c, Feedback_Units__c,   
                      First_Escalation_Time__c, Second_Escalation_Time__c, Support_Email_Address__c,Response_From_Email_Address__c, 
                      Channel__c, Business_Hours__c, SLA_Time_Measure__c , SLA_Units__c, Full_Department__c, Team_Manager__c, Convert_To_RecordType__c     
                      From Service_Mapping__c 
                      Where Queue__c = :theCase.Resolving_Team__c 
                      Order By Effective_Date__c DESC Limit 1 ];
            }
            
            System.debug('sm Size '+sm.size());
            if(sm.size() == 0){
                sm = [Select Id, Complexity__c, First_Approval__c, ID_V_Required__c, Priority__c,SLA_Pause_Status__c,SLA_Pause_Status_Internal__c,
                      SLA__c, Second_Approval__c, Team__c, Queue_Name__c,Department__c,Queue__c,Feedback_Time_Measure__c, Feedback_Units__c,   
                      First_Escalation_Time__c, Second_Escalation_Time__c, Support_Email_Address__c,Response_From_Email_Address__c, 
                      Channel__c, Business_Hours__c, SLA_Time_Measure__c , SLA_Units__c, Full_Department__c, Team_Manager__c, Convert_To_RecordType__c     
                      From Service_Mapping__c 
                      Where Queue__c = :theCase.Resolving_Team__c 
                      Order By Effective_Date__c DESC Limit 1 ];
            }
        
        
        
        //map service type values ONLY if we get a record back from the mapping table
        if(sm.size() > 0){
            serviceMap.put('SLA_Time_Measure__c', sm[0].SLA_Time_Measure__c);
            serviceMap.put('SLA_Units__c', sm[0].SLA_Units__c);
            serviceMap.put('Complexity__c', sm[0].Complexity__c);
            serviceMap.put('First_Approval__c', sm[0].First_Approval__c);
            serviceMap.put('ID_V__c', sm[0].ID_V_Required__c);
            serviceMap.put('Priority', sm[0].Priority__c);
            serviceMap.put('SLA__c', sm[0].SLA__c);
            serviceMap.put('Second_Approval__c', sm[0].Second_Approval__c);
            serviceMap.put('Team__c', sm[0].Team__c);
            serviceMap.put('Team_Manager__c', sm[0].Team_Manager__c);
            serviceMap.put('Queue_Name__c', sm[0].Queue_Name__c);
            serviceMap.put('First_Escalation_Time__c', String.valueOf(sm[0].First_Escalation_Time__c));
            serviceMap.put('Second_Escalation_Time__c', String.valueOf(sm[0].Second_Escalation_Time__c));
            serviceMap.put('Business_Hours__c', sm[0].Business_Hours__c);
            serviceMap.put('Channel__c', sm[0].Channel__c);
            serviceMap.put('Department__c', sm[0].Department__c);
            serviceMap.put('Full_Department__c', sm[0].Full_Department__c );
            serviceMap.put('Queue__c', sm[0].Queue__c);
            serviceMap.put('Id', sm[0].Id);
            serviceMap.put('Convert_To_RecordType__c', sm[0].Convert_To_RecordType__c);
            serviceMap.put('Feedback_Time_Measure__c', sm[0].Feedback_Time_Measure__c);
            serviceMap.put('Feedback_Units__c', sm[0].Feedback_Units__c);
            serviceMap.put('Response_From_Email_Address__c ', sm[0].Response_From_Email_Address__c );
            serviceMap.put('SLA_Pause_Status__c', sm[0].SLA_Pause_Status__c);
            serviceMap.put('SLA_Pause_Status_Internal__c', sm[0].SLA_Pause_Status_Internal__c);
        }
    }
    
    //The method returns a map with the queue a keys and email template ID as values and the Org Wide Addresses per queue
    public void populateQueueTemplateIDMaps(){
        
        map<String,String> templateMap = new map<String,String>();
        for(EmailTemplate et :[Select Id, DeveloperName, IsActive From EmailTemplate]){
            templateMap.put(et.DeveloperName, et.Id);
        }
        
        
        for(Service_Mapping__c smap :ServiceMappingHandler.getServiceMappingInstance()){
                                          
                                          templateMapEmailReceipt.put(smap.Queue__c,templateMap.get(smap.Template_Name_Email_Receipt__c));
                                          templateMapCaseCreation.put(smap.Queue__c,templateMap.get(smap.Template_Name_Case_Creation__c));
                                          templateMapCaseClose.put(smap.Queue__c,templateMap.get(smap.Template_Name_Case_Close__c));
                                          templateMapCaseFeedback.put(smap.Queue__c,templateMap.get(smap.Template_Name_Feedback_Email__c));
                                          orgWideAddressMap.put(smap.Queue__c,smap.Response_From_Email_Address__c);
                                          
                                          
                                      }
    }
    
    //return a map that contains the Case API Field names as keys and the service mapping values per key
    public map<String,String> getServiceMapping(){
        return serviceMap;
    }
    
    //Ajust SLA End date base on queue and business hours
    public list<DateTime> getSLAEndDate(DateTime slaStartDate){
        
        String nameOfBusinessHours = '';
        if(serviceMap.containsKey('Business_Hours__c')){
            nameOfBusinessHours = serviceMap.get('Business_Hours__c');
        }
        
        list<BusinessHours> bhId = [Select Id From BusinessHours Where IsActive=true and Name = :nameOfBusinessHours];
        
        if(bhId.size() == 0){
            bhId = [Select Id From BusinessHours Where IsDefault=true];
        }
        
        String timeMeasure = serviceMap.get('SLA_Time_Measure__c');
        Integer timeUnits = Integer.valueOf(serviceMap.get('SLA_Units__c'));
        
        //hours in milliseconds
        if(timeMeasure.contains('Hour')){
            timeUnits = timeUnits * 60 * 60 * 1000;
        }else if(timeMeasure.contains('Day')){
            timeUnits = timeUnits * 9; //9 hour day
            timeUnits = timeUnits * 60 * 60 * 1000;
        }else if(timeMeasure.contains('Week')){
            timeUnits = timeUnits * 45; //5 day week at 9 hours per day
            timeUnits = timeUnits * 60 * 60 * 1000;
        }
        
        Integer warningTime = 0;
        
        if(timeUnits == (60 * 60 * 1000)){
            warningTime = 30 * 60 * 1000; //30min
        }else if(timeUnits > (60 * 60 * 1000)){
            warningTime = 60 * 60 * 1000; //60min
        }
        
        list<DateTime> returnArray = new list<DateTime>();
        
        returnArray.add(BusinessHours.add(bhId[0].Id, slaStartDate, (timeUnits - warningTime)));
        returnArray.add(BusinessHours.add(bhId[0].Id, slaStartDate, timeUnits));
        
        return returnArray;
    }
    
    //Get client feedback due date
    public DateTime getFeedbackDueDate(DateTime feedbackStartDate){
        
        String nameOfBusinessHours = '';
        if(serviceMap.containsKey('Business_Hours__c')){
            nameOfBusinessHours = serviceMap.get('Business_Hours__c');
        }
        
        list<BusinessHours> bhId = [Select Id From BusinessHours Where IsActive=true and Name = :nameOfBusinessHours];
        
        if(bhId.size() == 0){
            bhId = [Select Id From BusinessHours Where IsDefault=true];
        }
        
        String timeMeasure = 'Day';
        
        if(serviceMap.get('Feedback_Time_Measure__c') != null){
            timeMeasure = serviceMap.get('Feedback_Time_Measure__c');
        }    
        
        
        Integer timeUnits = 0;
        
        if(serviceMap.get('Feedback_Units__c') != null){
            timeUnits = Integer.valueOf(serviceMap.get('Feedback_Units__c'));
        }
        
        //hours in milliseconds
        if(timeMeasure.contains('Hour')){
            timeUnits = timeUnits * 60 * 60 * 1000;
        }else if(timeMeasure.contains('Day')){
            timeUnits = timeUnits * 9; //9 hour day
            timeUnits = timeUnits * 60 * 60 * 1000;
        }else if(timeMeasure.contains('Week')){
            timeUnits = timeUnits * 45; //5 day week at 9 hours per day
            timeUnits = timeUnits * 60 * 60 * 1000;
        }
        
        DateTime duedate = BusinessHours.add(bhId[0].Id, feedbackStartDate, timeUnits);       
        return duedate;
    }
    
    //Get Email SLA dates base on queue
    public list<DateTime> getEmailSLAEndDate(DateTime slaStartDate){
        
        String nameOfBusinessHours = '';
        if(serviceMap.containsKey('Business_Hours__c')){
            nameOfBusinessHours = serviceMap.get('Business_Hours__c');
        }
        
        list<BusinessHours> bhId = [Select Id From BusinessHours Where IsActive=true and Name = :nameOfBusinessHours];
        
        if(bhId.size() == 0){
            bhId = [Select Id From BusinessHours Where IsDefault=true];
        }
        
        String timeMeasure = serviceMap.get('Email_SLA_Time_Measure__c');
        Integer timeUnits = Integer.valueOf(serviceMap.get('Email_SLA_Units__c'));
        
        //hours in milliseconds
        if(timeMeasure.contains('Hour')){
            timeUnits = timeUnits * 60 * 60 * 1000;
        }else if(timeMeasure.contains('Day')){
            timeUnits = timeUnits * 9; //9 hour day
            timeUnits = timeUnits * 60 * 60 * 1000;
        }else if(timeMeasure.contains('Week')){
            timeUnits = timeUnits * 45; //5 day week at 9 hours per day
            timeUnits = timeUnits * 60 * 60 * 1000;
        }
        
        Integer warningTime = 0;
        
        if(timeUnits == (60 * 60 * 1000)){
            warningTime = 30 * 60 * 1000; //30min
        }else if(timeUnits > (60 * 60 * 1000)){
            warningTime = 60 * 60 * 1000; //60min
        }
        
        list<DateTime> returnArray = new list<DateTime>();
        
        returnArray.add(BusinessHours.add(bhId[0].Id, slaStartDate, (timeUnits - warningTime)));
        returnArray.add(BusinessHours.add(bhId[0].Id, slaStartDate, timeUnits));
        
        return returnArray;
    }
    
    //validate if a user selected the correct channel relevant to his service type selection
    public Boolean isChannelValid(){
        String cha = sm[0].Channel__c;
        set<String> channels = new set<String>(cha.split(';'));
        if(channels.contains(theCase.Channel__c)){
            return true;   
        }else{
            return false;
        }
    }
    
    //all below methods returns one mapping value relevant to the Case in scope based on the key
    //---------------------------------------------------------------------------------- 
    public String getSLAInternalPauseStatus(){
        if(serviceMap.containsKey('SLA_Pause_Status_Internal__c')){
            return serviceMap.get('SLA_Pause_Status_Internal__c'); 
        }else{
            return null;
        }
    }
    public String getSLAPauseStatus(){
        if(serviceMap.containsKey('SLA_Pause_Status__c')){
            return serviceMap.get('SLA_Pause_Status__c'); 
        }else{
            return null;
        }
    }
    public String getConvertRecordType(){
        if(serviceMap.containsKey('Convert_To_RecordType__c')){
            return serviceMap.get('Convert_To_RecordType__c'); 
        }else{
            return null;
        }
    } 
    public String getFullDepartment(){
        if(serviceMap.containsKey('Full_Department__c')){
            return serviceMap.get('Full_Department__c'); 
        }else{
            return null;
        }
    }
    public String getDepartment(){
        if(serviceMap.containsKey('Department__c')){
            return serviceMap.get('Department__c'); 
        }else{
            return null;
        }
    }
    public String getComplexity(){
        if(serviceMap.containsKey('Complexity__c')){
            return serviceMap.get('Complexity__c'); 
        }else{
            return null;
        }
    }
    public String getFirstApproval(){
        if(serviceMap.containsKey('First_Approval__c')){
            return serviceMap.get('First_Approval__c'); 
        }else{
            return null;
        }
    }
    public String getIDVRequired(){
        
        if(serviceMap.containsKey('ID_V__c')){
            return serviceMap.get('ID_V__c');
        }else{
            return null;
        }
    }
    public String getPriority(){
        
        if(serviceMap.containsKey('Priority')){
            return serviceMap.get('Priority');
        }else{
            return null;
        }
    }
    public String getSecondEscalationTime(){
        
        if(serviceMap.containsKey('Second_Escalation_Time__c')){
            return serviceMap.get('Second_Escalation_Time__c');
        }else{
            return null;
        }
    }
    public String getQueueAPIName(){
        
        if(serviceMap.containsKey('Queue_Name__c')){
            return serviceMap.get('Queue_Name__c');
        }else{
            return null;
        }
    }
    public String getQueueName(){
        
        if(serviceMap.containsKey('Queue__c')){
            return serviceMap.get('Queue__c');
        }else{
            return null;
        }
    }
    public String getTeam(){
        
        if(serviceMap.containsKey('Team__c')){
            return serviceMap.get('Team__c');
        }else{
            return null;
        }
    }
    public String getTeamManager(){
        
        if(serviceMap.containsKey('Team_Manager__c')){
            return serviceMap.get('Team_Manager__c');
        }else{
            return null;
        }
    }
    public String getSecondApproval(){
        
        if(serviceMap.containsKey('Second_Approval__c')){
            return serviceMap.get('Second_Approval__c');
        }else{
            return null;
        }
    }
    public String getSLA(){
        
        if(serviceMap.containsKey('SLA__c')){
            return serviceMap.get('SLA__c');
        }else{
            return null;
        }
    }
    public String getFirstEscalationTime(){
        
        if(serviceMap.containsKey('First_Escalation_Time__c')){
            return serviceMap.get('First_Escalation_Time__c');
        }else{
            return null;
        }
    }
    public String getBusinessHours(){
        
        if(serviceMap.containsKey('Business_Hours__c')){
            return serviceMap.get('Business_Hours__c');
        }else{
            return null;
        }
    }
    public String getRecordId(){
        
        if(serviceMap.containsKey('Id')){
            return serviceMap.get('Id');
        }else{
            return null;
        }
    }
    public String getSupportEmailAddress(){
        if(serviceMap.containsKey('Support_Email_Address__c')){
            return serviceMap.get('Support_Email_Address__c'); 
        }else{
            return null;
        }
    }
    public String getResponseFromEmailAddress(){
        if(serviceMap.containsKey('Response_From_Email_Address__c')){
            return serviceMap.get('Response_From_Email_Address__c'); 
        }else{
            return null;
        }
    }
}