/**
* Date   : 20160531
* Author : RN - CloudSmiths
* Desc   : Default case trigger
**/
trigger Case_Trigger on Case (before insert, before update, after insert, after update) {
    
    set<Id> rectypeIds = new set<Id>();
    
    for(Case c :Trigger.New){
        rectypeIds.add(c.RecordTypeId);
    }
    
    Boolean isCSC = false;
    Boolean isComplaint = false;
    Boolean isDOS = false;
    
    for(RecordType r :[Select Id, DeveloperName From RecordType Where Id IN :rectypeIds]){
        
        String devname = r.DeveloperName;
        
        if(devname.contains('CSC')){
			isCSC = true;
        }
        if(devname.contains('Complaint')){
            isComplaint = true;
        }
        if(devname.contains('Digital_Ops')){
        	isDOS = true;
        }
    }
    
    if(isCSC || isComplaint || isDOS){
        if(trigger.isBefore){
            if(trigger.isUpdate){
                CSC_utility.updateWIP(Trigger.NewMap,Trigger.OldMap);
                //update the service mapping if a user changed the queue from the GUI
                //Skip this if the Case was updated via a bulk process as we pull info from the mapping table and wil run into limits
                if(trigger.new.size() == 1){
                    if(isComplaint)
                    {
                        CSC_Case_Trigger_Functions_Complaint.updateServiceMapping(trigger.new,trigger.oldMap);
                        CSC_Case_Trigger_Functions_Complaint.feedbackResponse(trigger.new,trigger.oldMap);
                        CSC_Case_Trigger_Functions_Complaint.updateSLADdate(trigger.new,trigger.oldMap);
                    }
                    else
                    {
                        CSC_Case_Trigger_Functions.updateServiceMapping(trigger.new,trigger.oldMap);
                        CSC_Case_Trigger_Functions.feedbackResponse(trigger.new,trigger.oldMap);
                    }
                    
                }
            }else if(trigger.isInsert){
                //Skip this if the Case was updated via a bulk process as we pull info from the mapping table and wil run into limits
                //Tonga MM : Added this in code due to conflict of process builder and apex on lightning
                    CSC_Case_Trigger_Functions.updatePicCases(trigger.new,true);

                CSC_utility.DefualtWIP(Trigger.New);
                if(trigger.new.size() == 1){
                    if(isComplaint)
                    {
                        CSC_Case_Trigger_Functions_Complaint.convertManualCases(trigger.new,true);
                    }
                    else
                    {
                        CSC_Case_Trigger_Functions.convertManualCases(trigger.new,true);
                    }
					
                }
            }
            
            //Track the actual age of the Case in the hands of the client and the time it spent with support           
            CSC_Case_Trigger_Functions.trackCaseAge(trigger.new, trigger.oldMap);
        }
        
        if(trigger.isAfter){
            if(trigger.isInsert){
                if(!isComplaint){
                    //Skip this if the Case was updated via a bulk process as we pull info from the mapping table and wil run into limits
                    if(trigger.new.size() == 1){
                        
                        CSC_Case_Trigger_Functions.convertManualCases(trigger.new,false);
                    }
                }
                
                 if(!isComplaint){
                    //method sends out auto respose emails with correct template for new email type cases
                    CSC_Case_Trigger_Functions.emailResponse(trigger.new);
                 }
                else
                {
                    CSC_Case_Trigger_Functions_Complaint.emailResponse(trigger.new);
                }
                //Tonga MM : Add creator as team member
                
                CSC_Case_Trigger_Functions.addCreatorAsTeamMember(trigger.New);
                
            }else if(trigger.isUpdate){
                if(isComplaint)
                {
                    if(CSC_Case_Functions_Complaint.firstRun){
                    CSC_Case_Trigger_Functions_Complaint.caseResponse(trigger.new,trigger.oldMap);
                    CSC_Case_Functions_Complaint.firstRun = false;
				}
                }
                else
                {
                   if(CSC_Case_Functions.firstRun){
                    CSC_Case_Trigger_Functions.caseResponse(trigger.new,trigger.oldMap);
                    CSC_Case_Functions.firstRun = false;
				}
                }
                
            }
            
                if(CSC_Case_Functions.firstRunTracking){
                    CSC_Case_trigger_Functions.trackTransfer(trigger.new, trigger.oldMap);
                    CSC_Case_Functions.firstRunTracking = false;
                }
                    
        }
    }
}