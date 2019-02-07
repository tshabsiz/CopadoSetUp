/**
* Date   : 2016-12-20
* Author : RN - CloudSmiths
* Desc   : Class containing supporting methods for the Service_Mapping__c Trigger
* 		   1 - validateData()
		   The method validates the data enterd by the user for a new or exiting service mapping record
* 2017-02-15 - RN
* Add logic for feeedback template validation
**/
public class ServiceMapping_Trigger_Methods {
    
    public static void validateData(list<Service_Mapping__c> recs){
     	//get email template names
     	set<String> templateName = new set<String>();
        for(EmailTemplate et : [Select DeveloperName From EmailTemplate]){
            templateName.add(et.DeveloperName);
        }
        
     	//get record type names
     	set<String> devName = new set<String>();
        for(RecordType r :[Select DeveloperName From RecordType Where SobjectType = 'Case']){
            devName.add(r.DeveloperName);
        }
        
        //validating mapping data values
        for(Service_Mapping__c sm :recs){
            //Email templates
            if(String.isNotBlank(sm.Template_Name_Email_Receipt__c)){
                if(!templateName.contains(sm.Template_Name_Email_Receipt__c)){
                	sm.addError('The Email Template Developer Name \'' + sm.Template_Name_Email_Receipt__c + '\' is not a Valid');
            	}
            }
            if(String.isNotBlank(sm.Template_Name_Case_Creation__c)){
                if(!templateName.contains(sm.Template_Name_Case_Creation__c)){
                	sm.addError('The Email Template Developer Name \'' + sm.Template_Name_Case_Creation__c + '\' is not a Valid');
            	}
            }
            if(String.isNotBlank(sm.Template_Name_Case_Close__c)){
                if(!templateName.contains(sm.Template_Name_Case_Close__c)){
                	sm.addError('The Email Template Developer Name \'' + sm.Template_Name_Case_Close__c + '\' is not a Valid');
            	}
            }
            if(String.isNotBlank(sm.Template_Name_Feedback_Email__c)){
                if(!templateName.contains(sm.Template_Name_Feedback_Email__c)){
                	sm.addError('The Email Template Developer Name \'' + sm.Template_Name_Feedback_Email__c + '\' is not a Valid');
            	}
            }
            //Record types
            if(String.isNotBlank(sm.Convert_To_RecordType__c)){
                if(!devName.contains(sm.Convert_To_RecordType__c)){
                	sm.addError('The Record Type Developer Name \'' + sm.Convert_To_RecordType__c + '\' is not a valid record type for Cases');
            	}
            }
		}       
    }
}