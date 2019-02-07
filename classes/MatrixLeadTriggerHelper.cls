/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is used in trigger: MartixLeadTrigger.
* @Date:        10/2015
* @ConstructorParam:    None
* @TestClass:   ZZTEST_MatrixLeadTriggerHelper
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 02/12/2015  Marta Malinowska   Add validation to check if user has up to 5 Open Matrix Leads.
* 04/12/2015  Marta Malinowska   Add methods to assign owner, set Lead Status and Conversion Deadline within the same company.
* 12/01/2016  Marta Malinowska   Match Matrix Leads within the same company by REF NO F.
* 15/01/2016  Marta Malinowska   Fix copy Comments and Reason for unqualified leads - copy every time the field is changed (not only when status is changed).
* 31/03/2016  Masie Maseli       Changed the Validation of the Open Leads from a number to a Hierachal Custom Setting
*------------------------------------------------------------*/
public class MatrixLeadTriggerHelper {
    public static String STATUS_OPEN = 'Open';
    public static String STATUS_PENDING_ASSIGNMENT = 'Pending Assignment';
    public static String STATUS_ASSIGNED = 'Assigned';
    public static String STATUS_CONTACTED = 'Contacted';
    public static String STATUS_UNQUALIFIED = 'Unqualified';
    public static String STATUS_CONVERTED = 'Converted';
    public static String QUEUE_UNASSIGNED_LEADS = 'Unassigned';

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to set status to "Open" and assign Matrix Lead to Unassigned Leads queue.
    * @param        List of Matrix Leads
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public static void setStatusOpenAndAssignToQueue(List<Matrix_Lead__c> matrixLeads){
        Group unassignedLeadsQueue;
        try{
            unassignedLeadsQueue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = :QUEUE_UNASSIGNED_LEADS];
        } catch(QueryException ex){
            System.debug('QUEUE QUERY EXCEPTION: '+ex);
        }
        for(Matrix_Lead__c matrixLead : matrixLeads){
            matrixLead.Lead_Status__c = STATUS_OPEN;
            if(unassignedLeadsQueue != null){
                matrixLead.OwnerId = unassignedLeadsQueue.Id;
            }
        }
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to validate if new owner has no more than 5 Open Matrix Leads.
    * @param        Map of Matrix Leads with old values
    * @param        Map of Matrix Leads with new values
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 31/03/2016   Masie Maseli       Changed the Validation of the Open Leads from a number to a Hierachal Custom Setting
    *------------------------------------------------------------*/
    public static void validateIfNewOwnerHasUpTo5OpenLeads(Map<Id, Matrix_Lead__c> oldMatrixLeads, Map<Id, Matrix_Lead__c> newMatrixLeads){
        Matrix_Lead__c newMatrixLead;
        Matrix_Lead__c oldMatrixLead;
        Map<Id, Set<String>> companyRefNosByOwnerMap = new Map<Id, Set<String>>();
        Map<Id, List<Matrix_Lead__c>> matrixLeadsByOwnerMap = new Map<Id, List<Matrix_Lead__c>>();
        MatrixLeadSelectionLimit__c cs = MatrixLeadSelectionLimit__c.getInstance();
         
         

        for(Id matrixLeadId : newMatrixLeads.keySet()){
            newMatrixLead = newMatrixLeads.get(matrixLeadId);
            oldMatrixLead = oldMatrixLeads.get(matrixLeadId);
            if(newMatrixLead.OwnerId != oldMatrixLead.OwnerId && newMatrixLead.OwnerId.getSObjectType() == User.SObjectType){
                if(matrixLeadsByOwnerMap.containsKey(newMatrixLead.OwnerId)){
                    matrixLeadsByOwnerMap.get(newMatrixLead.OwnerId).add(newMatrixLead);
                } else{
                    matrixLeadsByOwnerMap.put(newMatrixLead.OwnerId, new List<Matrix_Lead__c>{newMatrixLead});
                }
                if(companyRefNosByOwnerMap.containsKey(newMatrixLead.OwnerId)){
                    companyRefNosByOwnerMap.get(newMatrixLead.OwnerId).add(newMatrixLead.REF_NO_F__c);
                } else{
                    companyRefNosByOwnerMap.put(newMatrixLead.OwnerId, new Set<String>{newMatrixLead.REF_NO_F__c});
                }
            }
        }
        if(matrixLeadsByOwnerMap.size() > 0){
            for(Matrix_Lead__c matrixLead : [SELECT Id, Name, OwnerId, REF_NO_F__c, Owner.UserRole.Name FROM Matrix_Lead__c 
                                                WHERE Lead_Status__c != :STATUS_UNQUALIFIED AND Lead_Status__c != :STATUS_CONVERTED
                                                AND OwnerId IN :matrixLeadsByOwnerMap.keySet()]){
                if(companyRefNosByOwnerMap.containsKey(matrixLead.OwnerId)){
                    companyRefNosByOwnerMap.get(matrixLead.OwnerId).add(matrixLead.REF_NO_F__c);
                } else{
                    companyRefNosByOwnerMap.put(matrixLead.OwnerId, new Set<String>{matrixLead.REF_NO_F__c});
                }
            }
            for(Id ownerId : companyRefNosByOwnerMap.keySet()){
                if(companyRefNosByOwnerMap.get(ownerId).size() > cs.Maximum_Number_of_Leads_Allowed__c){
                    for(Matrix_Lead__c matrixLead : matrixLeadsByOwnerMap.get(ownerId)){
                        matrixLead.addError(Label.errMsg_Only5OpenMatrixLeadsAllowed);
                    }
                }
            }
        }
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to set Sector Head email.
    * @param        Map of Matrix Leads with old values
    * @param        Map of Matrix Leads with new values
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public static void setSectorHeadEmail(Map<Id, Matrix_Lead__c> oldMatrixLeads, Map<Id, Matrix_Lead__c> newMatrixLeads){
        Matrix_Lead__c oldMatrixLead;
        Matrix_Lead__c newMatrixLead;

        List<Matrix_Lead__c> matrixLeadsToUpd = new List<Matrix_Lead__c>();
        Set<Id> ownerIds = new Set<Id>();
        
        for(Id matrixLeadId : newMatrixLeads.keySet()){
            oldMatrixLead = oldMatrixLeads.get(matrixLeadId);
            newMatrixLead = newMatrixLeads.get(matrixLeadId);
            if(newMatrixLead.OwnerId != oldMatrixLead.OwnerId){
                matrixLeadsToUpd.add(newMatrixLead);
                ownerIds.add(newMatrixLead.OwnerId);
            }
        }

        Map<Id, User> mapUsers = new Map<Id, User>([SELECT Id, Manager.Email FROM User WHERE Id IN :ownerIds]);

        for(Matrix_Lead__c matrixLead : matrixLeadsToUpd){
            if(mapUsers.containsKey(matrixLead.OwnerId)){
                matrixLead.Sector_Head_Email__c = mapUsers.get(matrixLead.OwnerId).Manager.Email;
            } else{
                matrixLead.Sector_Head_Email__c = '';
            }
        }
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to set contacted and conversion dates.
    * @param        Map of Matrix Leads with old values
    * @param        Map of Matrix Leads with new values
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public static void setContactedAndConversionDates(Map<Id, Matrix_Lead__c> oldMatrixLeads, Map<Id, Matrix_Lead__c> newMatrixLeads){
        Matrix_Lead__c oldMatrixLead;
        Matrix_Lead__c newMatrixLead;

        for(Id matrixLeadId : newMatrixLeads.keySet()){
            oldMatrixLead = oldMatrixLeads.get(matrixLeadId);
            newMatrixLead = newMatrixLeads.get(matrixLeadId);
            if(newMatrixLead.Lead_Status__c != oldMatrixLead.Lead_Status__c && newMatrixLead.Lead_Status__c == STATUS_CONTACTED){
                if(newMatrixLead.Assignment_Date__c != null){
                    newMatrixLead.Contacted_Date__c = Date.today();
                }
                newMatrixLead.Conversion_Deadline__c = Date.today().addDays(60);
            }
        }
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used change the owner for Matrix Lead within the same company.
    * @param        Map of Matrix Leads with old values
    * @param        Map of Matrix Leads with new values
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public static void assignMatrixLeadOwnersWithinTheSameCompany(Map<Id, Matrix_Lead__c> oldMatrixLeads, Map<Id, Matrix_Lead__c> newMatrixLeads){
        Matrix_Lead__c oldMatrixLead;
        Matrix_Lead__c newMatrixLead;
        Map<String, Matrix_Lead__c> mapMatrixLeadsByRefNos = new Map<String, Matrix_Lead__c>();
        for(Id matrixLeadId : newMatrixLeads.keySet()){
            oldMatrixLead = oldMatrixLeads.get(matrixLeadId);
            newMatrixLead = newMatrixLeads.get(matrixLeadId);
            if(newMatrixLead.OwnerId != oldMatrixLead.OwnerId && (newMatrixLead.Lead_Status__c == STATUS_OPEN 
                    || newMatrixLead.Lead_Status__c == STATUS_PENDING_ASSIGNMENT || newMatrixLead.Lead_Status__c == STATUS_ASSIGNED) 
                    && newMatrixLead.REF_NO__c != null ){
                mapMatrixLeadsByRefNos.put(newMatrixLead.REF_NO_F__c, newMatrixLead);
            }
        }

        List<Matrix_Lead__c> matrixLeadsToUpdate = new List<Matrix_Lead__c>();
        for(Matrix_Lead__c matrixLeadToUpd : [SELECT Id, OwnerId, REF_NO_F__c, Lead_Status__c FROM Matrix_Lead__c 
                                        WHERE REF_NO_F__c IN :mapMatrixLeadsByRefNos.keySet()]){
            Matrix_Lead__c matrixLeadToRef = mapMatrixLeadsByRefNos.get(matrixLeadToUpd.REF_NO_F__c);
            if(matrixLeadToUpd.OwnerId != matrixLeadToRef.OwnerId){
                matrixLeadToUpd.OwnerId = matrixLeadToRef.OwnerId;
                matrixLeadsToUpdate.add(matrixLeadToUpd);
            }
        }

        update matrixLeadsToUpdate;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used change the Lead Status for Matrix Lead within the same company.
    * @param        Map of Matrix Leads with old values
    * @param        Map of Matrix Leads with new values
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public static void assignMatrixLeadStatusesWithinTheSameCompany(Map<Id, Matrix_Lead__c> oldMatrixLeads, Map<Id, Matrix_Lead__c> newMatrixLeads){
        Matrix_Lead__c newMatrixLead;
        Matrix_Lead__c oldMatrixLead;
        Map<String, Matrix_Lead__c> mapMatrixLeadsByRefNos = new Map<String, Matrix_Lead__c>();
        for(Id matrixLeadId : newMatrixLeads.keySet()){
            newMatrixLead = newMatrixLeads.get(matrixLeadId);
            oldMatrixLead = oldMatrixLeads.get(matrixLeadId);
            if(newMatrixLead.Lead_Status__c != oldMatrixLead.Lead_Status__c && (newMatrixLead.Lead_Status__c == STATUS_OPEN 
                    || newMatrixLead.Lead_Status__c == STATUS_PENDING_ASSIGNMENT || newMatrixLead.Lead_Status__c == STATUS_ASSIGNED
                    || newMatrixLead.Lead_Status__c == STATUS_CONTACTED || newMatrixLead.Lead_Status__c == STATUS_UNQUALIFIED)
                    && newMatrixLead.REF_NO__c != null){
                mapMatrixLeadsByRefNos.put(newMatrixLead.REF_NO_F__c, newMatrixLead);
            }
        }

        Group unassignedLeadsQueue;
        try{
            unassignedLeadsQueue = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND DeveloperName = :QUEUE_UNASSIGNED_LEADS];
        } catch(QueryException ex){
            System.debug('QUEUE QUERY EXCEPTION: '+ex);
        }

        List<Matrix_Lead__c> matrixLeadsToUpdate = new List<Matrix_Lead__c>();
        for(Matrix_Lead__c matrixLeadToUpd : [SELECT Id, REF_NO_F__c, Lead_Status__c, OwnerId, Comments__c, Reason_for_unqualified_leads__c, Specify_Other__c
                                            FROM Matrix_Lead__c WHERE REF_NO_F__c IN :mapMatrixLeadsByRefNos.keySet()]){
            Matrix_Lead__c matrixLeadToRef = mapMatrixLeadsByRefNos.get(matrixLeadToUpd.REF_NO_F__c);
            if(matrixLeadToUpd.Lead_Status__c != matrixLeadToRef.Lead_Status__c){
                matrixLeadToUpd.Lead_Status__c = matrixLeadToRef.Lead_Status__c;
                if(matrixLeadToRef.Lead_Status__c == STATUS_OPEN && unassignedLeadsQueue != null){
                    matrixLeadToUpd.OwnerId = unassignedLeadsQueue.Id;
                    matrixLeadToUpd.Assignment_Date__c = null;
                    matrixLeadToUpd.Contacted_Date__c = null;
                    matrixLeadToUpd.Conversion_Deadline__c = null;
                    matrixLeadToUpd.Requested_Extension_30_days__c = false;
                }
                if(matrixLeadToRef.Lead_Status__c == STATUS_CONTACTED){
                    matrixLeadToUpd.Comments__c = matrixLeadToRef.Comments__c;
                }
                if(matrixLeadToRef.Lead_Status__c == STATUS_UNQUALIFIED){
                    matrixLeadToUpd.Reason_for_unqualified_leads__c = matrixLeadToRef.Reason_for_unqualified_leads__c;
                    matrixLeadToUpd.Specify_Other__c = matrixLeadToRef.Specify_Other__c;
                }
                matrixLeadsToUpdate.add(matrixLeadToUpd);
            }
        }

        update matrixLeadsToUpdate;
    }
    
    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used change the Comments for Matrix Lead within the same company.
    * @param        Map of Matrix Leads with old values
    * @param        Map of Matrix Leads with new values
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public static void setCommentsWithinTheSameCompany(Map<Id, Matrix_Lead__c> oldMatrixLeads, Map<Id, Matrix_Lead__c> newMatrixLeads){
        Matrix_Lead__c newMatrixLead;
        Matrix_Lead__c oldMatrixLead;
        Map<String, Matrix_Lead__c> mapMatrixLeadsByRefNos = new Map<String, Matrix_Lead__c>();
        for(Id matrixLeadId : newMatrixLeads.keySet()){
            newMatrixLead = newMatrixLeads.get(matrixLeadId);
            oldMatrixLead = oldMatrixLeads.get(matrixLeadId);
            if(newMatrixLead.Comments__c != oldMatrixLead.Comments__c && newMatrixLead.Lead_Status__c == oldMatrixLead.Lead_Status__c && newMatrixLead.REF_NO__c != null){
                mapMatrixLeadsByRefNos.put(newMatrixLead.REF_NO_F__c, newMatrixLead);
            }
        }

        List<Matrix_Lead__c> matrixLeadsToUpdate = new List<Matrix_Lead__c>();
        for(Matrix_Lead__c matrixLeadToUpd : [SELECT Id, REF_NO_F__c, Comments__c FROM Matrix_Lead__c 
                                            WHERE REF_NO_F__c IN :mapMatrixLeadsByRefNos.keySet()]){
            Matrix_Lead__c matrixLeadToRef = mapMatrixLeadsByRefNos.get(matrixLeadToUpd.REF_NO_F__c);
            if(matrixLeadToUpd.Comments__c != matrixLeadToRef.Comments__c){
                matrixLeadToUpd.Comments__c = matrixLeadToRef.Comments__c;
                matrixLeadsToUpdate.add(matrixLeadToUpd);
            }
        }

        update matrixLeadsToUpdate;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used change the Reason for Unqualified leads for Matrix Lead within the same company.
    * @param        Map of Matrix Leads with old values
    * @param        Map of Matrix Leads with new values
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public static void setReasonForUnqualifiedWithinTheSameCompany(Map<Id, Matrix_Lead__c> oldMatrixLeads, Map<Id, Matrix_Lead__c> newMatrixLeads){
        Matrix_Lead__c newMatrixLead;
        Matrix_Lead__c oldMatrixLead;
        Map<String, Matrix_Lead__c> mapMatrixLeadsByRefNos = new Map<String, Matrix_Lead__c>();
        for(Id matrixLeadId : newMatrixLeads.keySet()){
            newMatrixLead = newMatrixLeads.get(matrixLeadId);
            oldMatrixLead = oldMatrixLeads.get(matrixLeadId);
            if((newMatrixLead.Reason_for_unqualified_leads__c != oldMatrixLead.Reason_for_unqualified_leads__c || newMatrixLead.Specify_Other__c != oldMatrixLead.Specify_Other__c) 
                && newMatrixLead.Lead_Status__c == oldMatrixLead.Lead_Status__c && newMatrixLead.REF_NO__c != null){
                mapMatrixLeadsByRefNos.put(newMatrixLead.REF_NO_F__c, newMatrixLead);
            }
        }

        List<Matrix_Lead__c> matrixLeadsToUpdate = new List<Matrix_Lead__c>();
        for(Matrix_Lead__c matrixLeadToUpd : [SELECT Id, REF_NO_F__c, Reason_for_unqualified_leads__c, Specify_Other__c FROM Matrix_Lead__c 
                                            WHERE REF_NO_F__c IN :mapMatrixLeadsByRefNos.keySet()]){
            Matrix_Lead__c matrixLeadToRef = mapMatrixLeadsByRefNos.get(matrixLeadToUpd.REF_NO_F__c);
            if(matrixLeadToUpd.Reason_for_unqualified_leads__c != matrixLeadToRef.Reason_for_unqualified_leads__c || matrixLeadToUpd.Specify_Other__c != matrixLeadToRef.Specify_Other__c){
                matrixLeadToUpd.Reason_for_unqualified_leads__c = matrixLeadToRef.Reason_for_unqualified_leads__c;
                matrixLeadToUpd.Specify_Other__c = matrixLeadToRef.Specify_Other__c;
                matrixLeadsToUpdate.add(matrixLeadToUpd);
            }
        }

        update matrixLeadsToUpdate;
    }

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used change the Conversion Deadline for Matrix Lead within the same company.
    * @param        Map of Matrix Leads with old values
    * @param        Map of Matrix Leads with new values
    * @Returns:     None
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    *------------------------------------------------------------*/
    public static void setConversionDeadlineWithinTheSameCompany(Map<Id, Matrix_Lead__c> oldMatrixLeads, Map<Id, Matrix_Lead__c> newMatrixLeads){
        Matrix_Lead__c newMatrixLead;
        Matrix_Lead__c oldMatrixLead;
        Map<String, Matrix_Lead__c> mapMatrixLeadsByRefNos = new Map<String, Matrix_Lead__c>();
        for(Id matrixLeadId : newMatrixLeads.keySet()){
            newMatrixLead = newMatrixLeads.get(matrixLeadId);
            oldMatrixLead = oldMatrixLeads.get(matrixLeadId);
            if(newMatrixLead.Conversion_Deadline__c != oldMatrixLead.Conversion_Deadline__c && newMatrixLead.REF_NO__c != null){
                mapMatrixLeadsByRefNos.put(newMatrixLead.REF_NO_F__c, newMatrixLead);
            }
        }

        List<Matrix_Lead__c> matrixLeadsToUpdate = new List<Matrix_Lead__c>();
        for(Matrix_Lead__c matrixLeadToUpd : [SELECT Id, REF_NO_F__c, Conversion_Deadline__c FROM Matrix_Lead__c 
                                            WHERE REF_NO_F__c IN :mapMatrixLeadsByRefNos.keySet()]){
            Matrix_Lead__c matrixLeadToRef = mapMatrixLeadsByRefNos.get(matrixLeadToUpd.REF_NO_F__c);
            if(matrixLeadToUpd.Conversion_Deadline__c != matrixLeadToRef.Conversion_Deadline__c){
                matrixLeadToUpd.Conversion_Deadline__c = matrixLeadToRef.Conversion_Deadline__c;
                matrixLeadToUpd.Requested_Extension_30_days__c = matrixLeadToRef.Requested_Extension_30_days__c;
                matrixLeadsToUpdate.add(matrixLeadToUpd);
            }
        }

        update matrixLeadsToUpdate;
    }
}