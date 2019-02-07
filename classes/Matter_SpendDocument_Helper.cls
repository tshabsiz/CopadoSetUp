/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 28/07/2017 - PG    - Created class.
 31/07/2017 - PG    - Renamed method to "addSpendScheduleItems".
                    - Updated logic to handle new statuses.
 01/08/2017 - PG    - Added method "updateStatusDates" to handle timestamps of status.
 07/08/2017 - PG    - Updated "addSpendScheduleItems" to use the law firm and owner as unique identifier.
 08/08/2017 - PG    - Change methods "updateStatusDates" to "updateRecordTypeDates".
                    - Eliminate WF rules to change RT's.
 16/08/2017 - PG    - Added new method "getSpendDocumentMatterOwners". Consolidate some code.
                    - Added new methods "documentApproverInRole" to handle manager approval processing.
                    - Updated "beforeUpdate" logic to use new manager approval process.
                    - Added "beforeInsert" method.
                    - Added "determineDocumentApprovers" method.
 17/08/2017 - PG    - Added some test handling logic to force roles etc.
 28/09/2017 - SP    - Added logic to make matter owner the default owner of document
 03/10/2017 - SP    - Commented out code which checks user role hiechrachy for Matter Document Approval - See comment below on which code
                    - Added logic to check for Litigation approvers based on VAT/Non Vat and Approval amount
 20/06/2018 - KA    - Code cleap up as a part of code handover
**/

public class Matter_SpendDocument_Helper {

    /**
    * Vars.
    **/
    public static Map<Id, UserRole> userRoles = new Map<Id, UserRole>();
    public static Map<Id, User> users = new Map<Id, User>();
    public static Map <String, Schema.RecordTypeInfo> spendDocumentTypes = Matter_Spend_Document__c.sObjectType.getDescribe().getRecordTypeInfosByName();

    /**
    * Before Update trigger handler.
    **/
    public static void beforeUpdate(List<Matter_Spend_Document__c> inputNewList, Map<Id, Matter_Spend_Document__c> inputOldMap) {
        System.debug('### Matter_SpendDocument_Helper : beforeUpdate');

        //Blank list.
        List<Matter_Spend_Document__c> readyForSchedeule = new List<Matter_Spend_Document__c>();
        List<Matter_Spend_Document__c> statusChanged = new List<Matter_Spend_Document__c>();

        //Loop through documents.
        for (Matter_Spend_Document__c spendDocument : inputNewList) {
            //Has is moved from 'Pending Approval' to 'Approved'?
            if (spendDocument.Status__c == 'Approved' && inputOldMap.get(spendDocument.Id).Status__c == 'Pending Approval') {
                readyForSchedeule.add(spendDocument);
            }

            //Has the status changed on Document?
            if (spendDocument.Status__c != inputOldMap.get(spendDocument.Id).Status__c) {
                statusChanged.add(spendDocument);
            }
        }

        //Anything to process.
        if (!readyForSchedeule.isEmpty()) {
            addSpendScheduleItems(readyForSchedeule);
        }

        if (!statusChanged.isEmpty()) {
            updateRecordTypeDates(statusChanged);
        }
    }

    /**
    * Before Insert trigger handler.
    **/
    public static void beforeInsert(List<Matter_Spend_Document__c> inputNewList) {
        //Populate the spend document with their approver.
        determineDocumentApprovers(inputNewList);
    }

    /**
    * After Update trigger handler.
    **/
    public static void afterUpdate(List<Matter_Spend_Document__c> inputNewList, Map<Id, Matter_Spend_Document__c> inputOldMap) {
        System.debug('### Matter_SpendDocument_Helper : afterUpdate');

        //Blank set.
        Set<Id> updateSchedules = new Set<Id>();

        //Loop through documents.
        for (Matter_Spend_Document__c spendDocument : inputNewList) {
            if (spendDocument.Status__c == 'Ready For Payment' && (inputOldMap.get(spendDocument.Id).Status__c == 'New' || inputOldMap.get(spendDocument.Id).Status__c == 'Queried')) {
                updateSchedules.add(spendDocument.Matter_Spend_Schedule__c);
            }

            if (inputOldMap.get(spendDocument.Id).Status__c == 'Approved' && spendDocument.Status__c == 'Queried') {
                updateSchedules.add(inputOldMap.get(spendDocument.Id).Matter_Spend_Schedule__c);
            }

            if (spendDocument.Status__c == 'Approved For Payment' && inputOldMap.get(spendDocument.Id).Status__c == 'Approved') {
                updateSchedules.add(spendDocument.Matter_Spend_Schedule__c);
            }

            if (spendDocument.Status__c == 'Paid' && inputOldMap.get(spendDocument.Id).Status__c == 'Pending Payment') {
                updateSchedules.add(spendDocument.Matter_Spend_Schedule__c);
            }

            if (spendDocument.Status__c == 'Queried' && inputOldMap.get(spendDocument.Id).Status__c == 'Pending Payment') {
                updateSchedules.add(inputOldMap.get(spendDocument.Id).Matter_Spend_Schedule__c);
            }
        }

        //Anything to process.
        if (!updateSchedules.isEmpty()) {
            Matter_SpendSchedule_Helper.updateSchedulesStatuses(updateSchedules);
        }
    }

    // Owners come directly from the Matter or from the Lookup Object--Change done by Sean---
    /**
    * submitForApproval
    **/
    public static void determineDocumentApprovers(List<Matter_Spend_Document__c> inputSpendDocuments) {
        System.debug('### Matter_SpendDocument_Helper : submitForApproval');

        //Blank variables.
        Set<Id> matterIds = new Set<Id>();
        Map<Id, Id> spendDocumentMatterOwners = new Map<Id, Id>();
        Map<Id, Id> spendDocumentApprovers = new Map<Id, Id>();

        //Finally allocate the spend document approver or indicate error on record.
        for (Matter_Spend_Document__c spendDocument : inputSpendDocuments) {
            //Add to document to spend document owner map.
            if (Test.isRunningTest() == true) {
                spendDocument.Approver__c = UserInfo.getUserId();
            }

            if (spendDocument.Matter__c != null) //Updated by Sean 28/9
            {
                //Set record approver.
                //Updated by Sean 28/9 - Owner of Matter is first Approver of spend document
                spendDocument.Approver__c = assignMatterOwnertoApprover(spendDocument.Matter__c);      //= spendDocumentApprovers.get(spendDocument.Id);
            } else {
                //Return error for UI purposes.
                spendDocument.addError('Unable to determine spend document approver.   Please contact your system administrator.');
            }
        }
    }

    //Added by Sean 28/9- Owner of Matter is first Approver of spend document
    Public Static Id assignMatterOwnertoApprover(Id MatterId) {
        advpm__Matter__c[] Matter = [Select OwnerId from advpm__Matter__c where id = :MatterId];
        return Matter[0].OwnerId;
    }

    /**
    *
    **/
    public static void addSpendScheduleItems(List<Matter_Spend_Document__c> inputSpendDocuments) {
        System.debug('### Matter_SpendDocument_Helper : addSpendScheduleItems');

        //Blank vars.
        Set<Id> matterIds = new Set<Id>();
        Map<Id, advpm__Matter__c> matters = new Map<Id, advpm__Matter__c>();
        Map<Id, Id> spendDocumentMatterOwners = new Map<Id, Id>();
        Map<Id, Id> spendDocumentScheduleOwners = new Map<Id, Id>();
        List<Matter_Spend_Schedule__c> existingSpendSchedules = new List<Matter_Spend_Schedule__c>();
        List<Matter_Spend_Schedule__c> newSpendSchedules = new List<Matter_Spend_Schedule__c>();

        //Retrieve the id map for owners.
        //Main lists.
        Map<String, Id> existingSchedulesMap = new Map<String, Id>();

        //--Litigation/Legal VAT/NON VAT and spend total Approval assignment
        Map<String, Decimal> mapVAT = new Map<String, Decimal>();
        Map<String, Decimal> mapNONVAT = new Map<String, Decimal>();

        Map<String, Decimal> mapVATLeg = new Map<String, Decimal>();
        Map<String, Decimal> mapNONVATLeg = new Map<String, Decimal>();

        for (Matter_Spend_Document__c spendDocument : inputSpendDocuments) {
            if (spendDocument.Matter_Record_Type__c == 'Litigation Matter') {
                System.Debug('**LIT**');
                if (spendDocument.Total_Vat_Amount__c == 0) {
                    if (mapNONVAT.get(spendDocument.Law_Firm__c + 'Non Vat') == Null) {
                        mapNONVAT.put(spendDocument.Law_Firm__c + 'Non Vat', spendDocument.Grand_Total__c);
                    } else {
                        mapNONVAT.put(spendDocument.Law_Firm__c + 'Non Vat', mapNONVAT.get(spendDocument.Law_Firm__c + 'Non Vat') + spendDocument.Grand_Total__c);
                    }
                } else {
                    if (mapVAT.get(spendDocument.Law_Firm__c + 'VAT') == null) {
                        mapVAT.put(spendDocument.Law_Firm__c + 'VAT', spendDocument.Grand_Total__c);
                    } else {
                        mapVAT.put(spendDocument.Law_Firm__c + 'VAT', mapVAT.get(spendDocument.Law_Firm__c + 'VAT') + spendDocument.Grand_Total__c);
                    }
                }
                spendDocumentScheduleOwners.put(spendDocument.Id, spendDocument.Approver__c);
            } else {
                if (spendDocument.Total_Vat_Amount__c == 0) {
                    if (mapNONVATLeg.get(spendDocument.Law_Firm__c + 'Non Vat') == Null) {
                        mapNONVATLeg.put(spendDocument.Law_Firm__c + 'Non Vat', spendDocument.Grand_Total__c);
                    } else {
                        mapNONVATLeg.put(spendDocument.Law_Firm__c + 'Non Vat', mapNONVATLeg.get(spendDocument.Law_Firm__c + 'Non Vat') + spendDocument.Grand_Total__c);
                    }
                } else {
                    if (mapVATLeg.get(spendDocument.Law_Firm__c + 'VAT') == null) {
                        mapVATLeg.put(spendDocument.Law_Firm__c + 'VAT', spendDocument.Grand_Total__c);
                    } else {
                        mapVATLeg.put(spendDocument.Law_Firm__c + 'VAT', mapVATLeg.get(spendDocument.Law_Firm__c + 'VAT') + spendDocument.Grand_Total__c);
                    }
                }
                spendDocumentScheduleOwners.put(spendDocument.Id, spendDocument.Approver__c);
            }
        }

        System.Debug('**One**' + mapNONVATLeg);

        //Retrieve open schedules.
        existingSpendSchedules = [
                SELECT
                        Id,
                        Name,Total_Spend_Amount__c,Vat_Type__c,Matter_Type__c,
                        Law_Firm__c,Status__c,Litigation_Approver__c,Litigation_Approval_Started__c,
                        OwnerId
                FROM Matter_Spend_Schedule__c
                WHERE
                Status__c = 'Open' OR Status__c = 'Approved'
        ];

        //Any schedules returned
        List<Lookup__c> lst_LitUser = [Select id,User__c,Approval_Group__c,Less_than__c from Lookup__c Where RecordType.Name = :'Litigation User Approval Levels'];
        Map<String, String> Map_LitUser = new Map<String, String>();

        for (Lookup__c l : lst_LitUser) {
            Map_LitUser.put(l.Approval_Group__c, l.User__c);
        }

        Map<String, String> Map_SchDocOwner = new Map<String, String>();

        if (!existingSpendSchedules.isEmpty()) {
            //Loop through existing schedules.
            for (Matter_Spend_Schedule__c spendSchedule : existingSpendSchedules) {

                System.Debug('**Two**');

                //Add to unique map.
                if (spendSchedule.Matter_Type__c == 'Litigation') {
                    if (spendSchedule.Vat_Type__c == 'VAT') {
                        System.Debug('**Three**');
                        if (mapVAT.get(spendSchedule.Law_Firm__c + 'VAT') != null && spendSchedule.Litigation_Approval_Started__c == false) {
                            spendSchedule.Total_Spend_Amount__c = spendSchedule.Total_Spend_Amount__c + mapVAT.get(spendSchedule.Law_Firm__c + 'VAT');


                            String compoundedIndex = spendSchedule.Law_Firm__c + '-' + 'VAT';
                            existingSchedulesMap.put(compoundedIndex, spendSchedule.Id);
                        }
                    } else if (spendSchedule.Vat_Type__c == 'Non Vat') {

                        System.Debug('**Four**');
                        if (mapNONVAT.get(spendSchedule.Law_Firm__c + 'Non Vat') != null && spendSchedule.Litigation_Approval_Started__c == false) {
                            spendSchedule.Total_Spend_Amount__c = spendSchedule.Total_Spend_Amount__c + mapNONVAT.get(spendSchedule.Law_Firm__c + 'Non Vat');


                            String compoundedIndex = spendSchedule.Law_Firm__c + '-' + 'NONVAT';
                            existingSchedulesMap.put(compoundedIndex, spendSchedule.Id);
                        }
                    }
                } else if (spendSchedule.Matter_Type__c == 'Legal' && spendSchedule.Status__c == 'Open') {

                    if (spendSchedule.Vat_Type__c == 'VAT') {
                        System.Debug('**Three**');
                        if (mapVATLeg.get(spendSchedule.Law_Firm__c + 'VAT') != null) {
                            spendSchedule.Total_Spend_Amount__c = spendSchedule.Total_Spend_Amount__c + mapVATLeg.get(spendSchedule.Law_Firm__c + 'VAT');


                            String compoundedIndex = spendSchedule.Law_Firm__c + '-' + 'VATLeg';
                            existingSchedulesMap.put(compoundedIndex, spendSchedule.Id);
                        }
                    } else if (spendSchedule.Vat_Type__c == 'Non Vat') {

                        System.Debug('**Four**');
                        if (mapNONVATLeg.get(spendSchedule.Law_Firm__c + 'Non Vat') != null) {
                            spendSchedule.Total_Spend_Amount__c = spendSchedule.Total_Spend_Amount__c + mapNONVATLeg.get(spendSchedule.Law_Firm__c + 'Non Vat');


                            String compoundedIndex = spendSchedule.Law_Firm__c + '-' + 'NONVATLeg';
                            existingSchedulesMap.put(compoundedIndex, spendSchedule.Id);
                        }
                    }

                    System.Debug('**Five**');
                }
                if ((mapVAT.get(spendSchedule.Law_Firm__c + 'VAT') != null || mapNONVAT.get(spendSchedule.Law_Firm__c + 'Non Vat') != null) && spendSchedule.Litigation_Approval_Started__c == false) {
                    if (spendSchedule.Total_Spend_Amount__c <= 1800000) {
                        spendSchedule.OwnerId = Map_LitUser.get('One');
                        Map_SchDocOwner.Put(spendSchedule.id, spendSchedule.OwnerId);
                    } else if (spendSchedule.Total_Spend_Amount__c > 1800000 && spendSchedule.Total_Spend_Amount__c <= 5000000) {
                        spendSchedule.OwnerId = Map_LitUser.get('Two');
                        Map_SchDocOwner.Put(spendSchedule.id, spendSchedule.OwnerId);
                    } else if (spendSchedule.Total_Spend_Amount__c > 5000000) {
                        spendSchedule.OwnerId = Map_LitUser.get('Three');
                        Map_SchDocOwner.Put(spendSchedule.id, spendSchedule.OwnerId);
                    }
                }
            }
            update existingSpendSchedules;
        }

        //Loop through spend documents from trigger.
        for (Matter_Spend_Document__c spendDocument : inputSpendDocuments) {
            //Existing schedule for document?
            Boolean Addnew = False;
            if (spendDocument.Matter_Record_Type__c == 'Litigation Matter') {
                if (spendDocument.Vat_Type__c == 'VAT' && !existingSchedulesMap.containsKey(spendDocument.Law_Firm__c + '-' + 'VAT') && mapVAT.get(spendDocument.Law_Firm__c + 'VAT') != null) {
                    Addnew = true;
                    System.Debug('**six**');
                } else if (spendDocument.Vat_Type__c == 'Non Vat' && !existingSchedulesMap.containsKey(spendDocument.Law_Firm__c + '-' + 'NONVAT') && mapNONVAT.get(spendDocument.Law_Firm__c + 'Non Vat') != null) {
                    Addnew = true;
                    System.Debug('**Seven**');
                }
            } else if (spendDocument.Matter_Record_Type__c == 'Legal') {
                if (spendDocument.Vat_Type__c == 'VAT' && !existingSchedulesMap.containsKey(spendDocument.Law_Firm__c + '-' + 'VATLeg') && mapVATLeg.get(spendDocument.Law_Firm__c + 'VAT') != null) {
                    Addnew = true;
                    System.Debug('**six**');
                } else if (spendDocument.Vat_Type__c == 'Non Vat' && !existingSchedulesMap.containsKey(spendDocument.Law_Firm__c + '-' + 'NONVATLeg') && mapNONVATLeg.get(spendDocument.Law_Firm__c + 'Non Vat') != null) {
                    Addnew = true;
                    System.Debug('**Seven**');
                }
            }
            if (Addnew) {
                //Only update where we can. 
                if (spendDocumentScheduleOwners.containsKey(spendDocument.Id)) {
                    Matter_Spend_Schedule__c newSchedule = new Matter_Spend_Schedule__c();
                    newSchedule.Law_Firm__c = spendDocument.Law_Firm__c;
                    newSchedule.OwnerId = spendDocumentScheduleOwners.get(spendDocument.Id);
                    newSchedule.Status__c = 'Open';
                    //Add to insert list
                    newSpendSchedules.add(newSchedule);
                    System.Debug('**eight**');
                }
            }
        }
        String ApprovalUserId = '';

        //Anything to process?
        if (!newSpendSchedules.isEmpty()) {
            //Insert new schedules needed i.e. dont exist for law firms.
            insert newSpendSchedules;

            //Loop through inserted schedules.
            for (Matter_Spend_Schedule__c spendSchedule : newSpendSchedules) {
                //Build a unique "id / string".

                System.Debug('**Nine**');

                if (mapVAT.get(spendSchedule.Law_Firm__c + 'VAT') != null) {
                    System.Debug('**Eleven**');
                    if (spendSchedule.Total_Spend_Amount__c == Null) {
                        spendSchedule.Total_Spend_Amount__c = mapVAT.get(spendSchedule.Law_Firm__c + 'VAT');

                    } else {
                        spendSchedule.Total_Spend_Amount__c = spendSchedule.Total_Spend_Amount__c + mapVAT.get(spendSchedule.Law_Firm__c + 'VAT');
                    }
                    spendSchedule.Vat_Type__c = 'VAT';

                    String compoundedIndex = spendSchedule.Law_Firm__c + '-' + 'VAT';
                    existingSchedulesMap.put(compoundedIndex, spendSchedule.Id);

                } else if (mapNONVAT.get(spendSchedule.Law_Firm__c + 'Non Vat') != null) {
                    System.Debug('**Twelve**');
                    if (spendSchedule.Total_Spend_Amount__c == Null) {
                        spendSchedule.Total_Spend_Amount__c = mapNONVAT.get(spendSchedule.Law_Firm__c + 'Non Vat');
                    } else {
                        spendSchedule.Total_Spend_Amount__c = spendSchedule.Total_Spend_Amount__c + mapNONVAT.get(spendSchedule.Law_Firm__c + 'Non Vat');
                    }
                    spendSchedule.Vat_Type__c = 'Non Vat';

                    String compoundedIndex = spendSchedule.Law_Firm__c + '-' + 'NONVAT';
                    existingSchedulesMap.put(compoundedIndex, spendSchedule.Id);
                } else if (mapVATLeg.get(spendSchedule.Law_Firm__c + 'VAT') != null) {
                    System.Debug('**Eleven**');
                    if (spendSchedule.Total_Spend_Amount__c == Null) {
                        spendSchedule.Total_Spend_Amount__c = mapVATLeg.get(spendSchedule.Law_Firm__c + 'VAT');

                    } else {
                        spendSchedule.Total_Spend_Amount__c = spendSchedule.Total_Spend_Amount__c + mapVATLeg.get(spendSchedule.Law_Firm__c + 'VAT');
                    }
                    spendSchedule.Vat_Type__c = 'VAT';
                    String compoundedIndex = spendSchedule.Law_Firm__c + '-' + 'VATLeg';
                    existingSchedulesMap.put(compoundedIndex, spendSchedule.Id);

                } else if (mapNONVATLeg.get(spendSchedule.Law_Firm__c + 'Non Vat') != null) {
                    System.Debug('**Twelve**');
                    if (spendSchedule.Total_Spend_Amount__c == Null) {
                        spendSchedule.Total_Spend_Amount__c = mapNONVATLeg.get(spendSchedule.Law_Firm__c + 'Non Vat');
                    } else {
                        spendSchedule.Total_Spend_Amount__c = spendSchedule.Total_Spend_Amount__c + mapNONVATLeg.get(spendSchedule.Law_Firm__c + 'Non Vat');
                    }
                    spendSchedule.Vat_Type__c = 'Non Vat';
                    String compoundedIndex = spendSchedule.Law_Firm__c + '-' + 'NONVATLeg';
                    existingSchedulesMap.put(compoundedIndex, spendSchedule.Id);
                }

                if (mapVAT.get(spendSchedule.Law_Firm__c + 'VAT') != null || mapNONVAT.get(spendSchedule.Law_Firm__c + 'Non Vat') != null) {

                    if (spendSchedule.Total_Spend_Amount__c <= 1800000) {

                        ApprovalUserId = spendSchedule.OwnerId = Map_LitUser.get('One');
                        Map_SchDocOwner.Put(spendSchedule.id, spendSchedule.OwnerId);
                    } else if (spendSchedule.Total_Spend_Amount__c > 1800000 && spendSchedule.Total_Spend_Amount__c <= 5000000) {

                        ApprovalUserId = spendSchedule.OwnerId = Map_LitUser.get('Two');
                        Map_SchDocOwner.Put(spendSchedule.id, spendSchedule.OwnerId);
                    } else if (spendSchedule.Total_Spend_Amount__c > 5000000) {

                        ApprovalUserId = spendSchedule.OwnerId = Map_LitUser.get('Three');
                        Map_SchDocOwner.Put(spendSchedule.id, spendSchedule.OwnerId);
                    }

                    spendSchedule.Matter_Type__c = 'Litigation';
                } else {
                    spendSchedule.Matter_Type__c = 'Legal';
                    ApprovalUserId = spendSchedule.OwnerId;
                    System.Debug('**Thirteen**');
                }
            }
            update newSpendSchedules;
        }

        //Finally associate the documents with the schedules.
        users = new Map<Id, User>([
                SELECT
                        Id,
                        Username,
                        UserRoleId,
                        UserRole.Name,
                        Can_Approve_Spend_Documents__c,
                        Profile.UserLicense.LicenseDefinitionKey
                FROM User
                WHERE
                        id = :ApprovalUserId
        ]);

        for (Matter_Spend_Document__c spendDocument : inputSpendDocuments) {
            //Existing schedule for document?
            //Update the schedule for doc.
            system.debug('*****' + spendDocument.Vat_Type__c + '****' + existingSchedulesMap + '*****' + mapVAT);
            system.debug('*****' + spendDocument.Law_Firm__c + '-' + spendDocumentScheduleOwners.get(spendDocument.Id) + 'VAT');

            if (spendDocument.Vat_Type__c == 'VAT' && existingSchedulesMap.containsKey(spendDocument.Law_Firm__c + '-' + 'VAT') && mapVAT.get(spendDocument.Law_Firm__c + 'VAT') != null) {
                spendDocument.Matter_Spend_Schedule__c = existingSchedulesMap.get(spendDocument.Law_Firm__c + '-' + 'VAT');
                System.Debug('**SevenTeen**');
            } else if (spendDocument.Vat_Type__c == 'Non Vat' && existingSchedulesMap.containsKey(spendDocument.Law_Firm__c + '-' + 'NONVAT') && mapNONVAT.get(spendDocument.Law_Firm__c + 'Non Vat') != null) {
                spendDocument.Matter_Spend_Schedule__c = existingSchedulesMap.get(spendDocument.Law_Firm__c + '-' + 'NONVAT');
                System.Debug('**eighten**');
            }

            else if (spendDocument.Vat_Type__c == 'VAT' && existingSchedulesMap.containsKey(spendDocument.Law_Firm__c + '-' + 'VATLeg') && mapVATLeg.get(spendDocument.Law_Firm__c + 'VAT') != null) {
                spendDocument.Matter_Spend_Schedule__c = existingSchedulesMap.get(spendDocument.Law_Firm__c + '-' + 'VATLeg');
                System.Debug('**SevenTeen**');
            } else if (spendDocument.Vat_Type__c == 'Non Vat' && existingSchedulesMap.containsKey(spendDocument.Law_Firm__c + '-' + 'NONVATLeg') && mapNONVATLeg.get(spendDocument.Law_Firm__c + 'Non Vat') != null) {
                spendDocument.Matter_Spend_Schedule__c = existingSchedulesMap.get(spendDocument.Law_Firm__c + '-' + 'NONVATLeg');
                System.Debug('**eighten**');
            }
        }
    }

    /**
    * Sets the date field for a status change on a document.
    **/
    public static void updateRecordTypeDates(List<Matter_Spend_Document__c> inputSpendDocuments) {
        System.debug('### Matter_SpendDocument_Helper : updateStatusDates');

        Id lockedType = spendDocumentTypes.get('Matter Spend Document (Locked)').getRecordTypeId();
        Id unlockedType = spendDocumentTypes.get('Matter Spend Document').getRecordTypeId();

        //Loop thought records and detemine what status changed.
        for (Matter_Spend_Document__c spendDocument : inputSpendDocuments) {
            if (spendDocument.Status__c == 'New') {
                spendDocument.RecordTypeId = unlockedType;
                spendDocument.Matter_Spend_Schedule__c = null;
            } else if (spendDocument.Status__c == 'Queried') {
                spendDocument.Queried_Date__c = Date.Today();
                spendDocument.RecordTypeId = unlockedType;
                spendDocument.Spend_Schedules_Owners_Email__c = null;
            } else if (spendDocument.Status__c == 'Pending Approval') {
                spendDocument.Submitted_For_Approval_Date__c = Date.Today();
                spendDocument.RecordTypeId = lockedType;
            } else if (spendDocument.Status__c == 'Approved') {
                spendDocument.Approved_Date__c = Date.Today();
                spendDocument.RecordTypeId = lockedType;
            } else if (spendDocument.Status__c == 'Approved For Payment') {
                spendDocument.Approved_For_Payment_Date__c = Date.Today();
                spendDocument.RecordTypeId = lockedType;
            } else if (spendDocument.Status__c == 'Pending Payment') {
                spendDocument.Pending_Payment_Date__c = Date.Today();
                spendDocument.RecordTypeId = lockedType;
            } else if (spendDocument.Status__c == 'Paid') {
                spendDocument.Paid_Date__c = Date.Today();
                spendDocument.RecordTypeId = lockedType;
            } else if (spendDocument.Status__c == 'Cancelled') {
                spendDocument.Cancelled_Date__c = Date.Today();
                spendDocument.RecordTypeId = unlockedType;
            }
        }
    }
}