Public Class LegalQuoteRequest_handler {
    private static FolderHandler folderHandler = new FolderHandler();
    Public List<LawFirm> LstLawFirm { get; set; }
    Public List<FixedServiceActivity> lstFixedServiceActivity { get; set; }
    Public List<Legal_Quote__c> lst_LegalQuote { get; set; }
    Public Legal_Quote_Request__c LegalQuoteRequest { get; set; }
    Public RecordType rt;
    Public User UserName { get; set; }

    public String retURL { get; set; }
    public String rType { get; set; }
    Public Boolean LitigationRequest { get; set; }
    Public Boolean LegalfirmOffPanelShow { get; set; }
    Public Boolean MotivationError { get; set; }
    Public Integer FirmCount;

    Public String strRecordTypeName;

    Public static Boolean LegalQuoteRequestVF;

    public LegalQuoteRequest_handler(ApexPages.StandardController controller) {

        List<Account> lst_Account = new List<Account>([Select id,Name,BEE_Status__c,BO__c,BWO__c, (Select id,Name From Contacts) From Account Where RecordType.Name = 'On/Off Panel Law Firm' and Approved__c = True Order by Name ASC]);

        if (test.isRunningTest() == false) {
            controller.Addfields(new List<String>{
                    'RecordTypeId'
            });
        }
        LegalQuoteRequest = new Legal_Quote_Request__c();
        LegalQuoteRequest = (Legal_Quote_Request__c) controller.getRecord();

        LegalQuoteRequest.Status__c = 'Draft';

        if (ApexPages.currentPage().getParameters().get('RecordType') == null) {
            Schema.DescribeSObjectResult describeRequest = Schema.SObjectType.Legal_Quote_Request__c;
            List<Schema.RecordTypeInfo> rtInfos = describeRequest.getRecordTypeInfos();
            for (Schema.RecordTypeInfo rtInfo : rtInfos) {
                // walk through the map to determine the correct record type, this is done with the isAvailable() function
                if (rtInfo.getName() != 'Master' && rtInfo.isAvailable()) {
                    // below lines will only run one time only
                    System.debug('The RecordType :' + rtInfo.getName() + ' and the id: ' + rtInfo.getRecordTypeId() + ' is available, adding it as parameter to the page.');

                    strRecordTypeName = rtInfo.getName();
                    LegalQuoteRequest.RecordTypeId = rtInfo.getRecordTypeId();
                }
            }
        } else {
            strRecordTypeName = Schema.SObjectType.Legal_Quote_Request__c.getRecordTypeInfosById().get(LegalQuoteRequest.RecordTypeId).getName();
        }

        system.debug('**DDDD***' + strRecordTypeName);

        if (LegalQuoteRequest.Matter__c != null) {
            advpm__Matter__c[] Matter = [Select id,Cost_Centre__c From advpm__Matter__c Where id = :LegalQuoteRequest.Matter__c limit 1];
            LegalQuoteRequest.Cost_Centre__c = Matter[0].Cost_Centre__c;
        }

        if (strRecordTypeName == 'Litigation Request') {
            List<Fixed_Service_Activity__c> lst_Service = new List<Fixed_Service_Activity__c>([Select id,Name From Fixed_Service_Activity__c Order By Name ASC]);
            lstFixedServiceActivity = new List<FixedServiceActivity>();

            for (Fixed_Service_Activity__c s : lst_Service) {
                FixedServiceActivity ServiceActivity = new FixedServiceActivity();
                ServiceActivity.ServiceActivity = s;
                lstFixedServiceActivity.add(ServiceActivity);
            }

            LitigationRequest = True;
        } else {
            LitigationRequest = false;
        }
        MotivationError = false;

        LegalfirmOffPanelShow = true;

        UserName = [Select id,Name From User Where id = :UserInfo.getUserId()];

        LstLawFirm = new List<LawFirm>();

        for (Account a : lst_Account) {
            LawFirm LawFirm = new LawFirm();
            LawFirm.AccountName = a.Name;
            LawFirm.AccounId = a.id;
            LawFirm.BEEStatus = a.BEE_Status__c;
            LawFirm.BO = a.BO__c;
            LawFirm.BWO = a.BWO__c;

            List<SelectOption> ContactsOptions = new List<SelectOption>();
            for (Contact c : a.Contacts) {
                ContactsOptions.add(new SelectOption(c.id, c.name));
            }
            LawFirm.Contacts = ContactsOptions;
            LstLawFirm.Add(LawFirm);
        }
    }

    Public Pagereference Redirect() {


        PageReference pageRef;
        pageRef = new PageReference('/apex/LegalQuoteRequest');
        Return pageRef;
    }

    Public void ChangeCostInformation() {
        advpm__Matter__c[] Matter = [Select id,Cost_Centre__c From advpm__Matter__c Where id = :LegalQuoteRequest.Matter__c limit 1];

        // system.debug('**Matter**'+LegalQuoteRequest.Matter__c);

        if (Matter[0].Cost_Centre__c != null) {
            LegalQuoteRequest.Cost_Centre__c = Matter[0].Cost_Centre__c;
        }
    }

    Public void HideFirmsLegalOffPanel() {

        if (LegalQuoteRequest.Request_Off_Panel__c) {
            LegalfirmOffPanelShow = false;
            // LitigationRequest = false;
        } else if (!LegalQuoteRequest.Request_Off_Panel__c) {
            LegalfirmOffPanelShow = true;
        }
    }


    Public Pagereference Save() {

        FirmCount = 0;
        Boolean CheckLawFirms;

        if (!LegalQuoteRequest.Request_Off_Panel__c) {

            for (LawFirm l : LstLawFirm) {
                if (l.SelectFirm) {
                    FirmCount++;
                }

            }
            CheckLawFirms = True;
        } else {
            CheckLawFirms = false;
        }

        MotivationError = false;
        if (CheckLawFirms) {
            if (FirmCount < 3 && String.Isblank(LegalQuoteRequest.Request_Motivation__c)) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'You selected fewer then 3 firms. Please Provide motivation in Request Motivation box below'));
                MotivationError = true;
                return null;
            }
        }

        if (String.Isblank(LegalQuoteRequest.Request_Motivation__c) && LegalQuoteRequest.Request_Off_Panel__c) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Please give motivation and firm name for Off Panel Request'));
            MotivationError = true;
            return null;
        }


        try {
            Insert LegalQuoteRequest;

            List<Legal_Quote_Service__c> lst_LegalQuoteService;

            lst_LegalQuote = new List<Legal_Quote__c>();
            lst_LegalQuote = AddLegalQuote();

            lst_LegalQuoteService = new List<Legal_Quote_Service__c>();

            if (LitigationRequest) {
                for (FixedServiceActivity f : lstFixedServiceActivity) {

                    if (f.SelectService) {
                        Legal_Quote_Service__c LegalService = new Legal_Quote_Service__c();
                        LegalService.Fixed_Service_Activity__c = f.ServiceActivity.id;
                        LegalService.Legal_Quote_Request__c = LegalQuoteRequest.id;
                        lst_LegalQuoteService.Add(LegalService);
                    }
                }
                Insert lst_LegalQuoteService;
            }

            //DONT let Legal Quote trigger fire
            LegalQuoteRequestVF = True;

            Insert lst_LegalQuote;

            createBoxFolder(LegalQuoteRequest.id);
        } catch (exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Error:' + e));
            return null;
        }

        PageReference pageRef = new PageReference('/' + LegalQuoteRequest.id);
        Return pageRef;
    }

    Public List<Legal_Quote__c> AddLegalQuote() {
        List<Legal_Quote__c> lst_LegalQuote;

        lst_LegalQuote = new List<Legal_Quote__c>();

        system.debug('****APPROVED USER****');

        Legal_Quote_Request__c [] LQuoteRequest = [Select recordtype.Name,Quote_Approver__c From Legal_Quote_Request__c where id = :LegalQuoteRequest.id limit 1];

        for (LawFirm l : LstLawFirm) {
            if (l.SelectFirm != null && l.SelectFirm) {
                Legal_Quote__c LegalQuote = new Legal_Quote__c();
                LegalQuote.Law_Firm__c = l.AccounId;
                LegalQuote.Contact__c = l.Contact;
                LegalQuote.External_Counsel_Name__c = l.PreferredExternalCounsel;
                LegalQuote.Legal_Quote_Request__c = LegalQuoteRequest.id;

                system.debug('****RT Name****' + LQuoteRequest[0].recordtype.Name);

                if (LQuoteRequest[0].recordtype.Name == 'Legal Request') {
                    LegalQuote.Status__c = 'New';
                } else {
                    LegalQuote.Status__c = 'Requested';
                }

                if (LQuoteRequest.size() > 0) {
                    LegalQuote.Quote_Approver__c = LQuoteRequest[0].Quote_Approver__c;
                }
                lst_LegalQuote.Add(LegalQuote);
                FirmCount++;
            }
        }
        return lst_LegalQuote;
    }

    Public static void updatequoteStatus(List<Legal_Quote_Request__c> LQuoteRequest, List<Legal_Quote_Request__c> LQuoteRequestOld) {

        Set<String> Set_QuoteId = new Set<String>();
        Map<String, String> Map_old = new Map<String, String>();

        for (Legal_Quote_Request__c q : LQuoteRequestOld) {
            Map_old.Put(q.id, q.Status__c);
        }

        for (Legal_Quote_Request__c q : LQuoteRequest) {
            if (q.Status__c == 'Requested' && Map_old.get(q.id) == 'Draft') {
                Set_QuoteId.Add(q.id);
            }
        }

        if (Set_QuoteId.size() > 0) {
            List<Legal_Quote__c> legalQuotesToUpdate = new List<Legal_Quote__c>([Select id,Status__c From Legal_Quote__c where Legal_Quote_Request__c in:Set_QuoteId]);

            for (Legal_Quote__c l : legalQuotesToUpdate) {
                l.Status__c = 'Requested';
            }
            update legalQuotesToUpdate;
        }
    }

    Public Pagereference Cancel() {

        PageReference pageRef = new PageReference('/a43/o');
        Return pageRef;
    }

    Public Class LawFirm {

        Public Boolean SelectFirm { get; set; }
        Public String AccountName { get; set; }
        Public String AccounId { get; set; }
        Public String BEEStatus { get; set; }
        Public String BO { get; set; }
        Public String BWO { get; set; }
        Public String Contact { get; set; }
        public List<SelectOption> Contacts { get; set; }
        Public String PreferredExternalCounsel { get; set; }

    }

    Public Class FixedServiceActivity {
        Public Boolean SelectService { get; set; }
        Public Fixed_Service_Activity__c ServiceActivity { get; set; }

    }

    @Future(callout = true)
    public static void createBoxFolder(String LegalQuoteRequestId) {

        List<Legal_Quote__c> BOXlst_LegalQuote = new List<Legal_Quote__c>([Select Id, Name, Contact__c, Law_Firm__c, Status__c, Quote_Approver__c, Legal_Quote_Request__c, Motivation_Comments__c, Quote_Amount__c, RecordTypeId From Legal_Quote__c where Legal_Quote_Request__c = :LegalQuoteRequestId]);
        Legal_Quote_Request__c BOXLegalQuoteRequest = new Legal_Quote_Request__c();
        BOXLegalQuoteRequest = [Select Id, Name, Matter__c, Quote_Title__c, Box_Quote_Request_Link__c, RecordTypeId From Legal_Quote_Request__c Where id = :LegalQuoteRequestId];

        //Legal Quote Request Folder Structure
        Box_Folder_Structure__c requestStructure = folderHandler.getFolderStructure(Legal_Quote_Request__c.SObjectType, BOXLegalQuoteRequest.RecordTypeId);

        //Legal Quote Folder Structure
        Box_Folder_Structure__c quoteStructure;
        if (BOXlst_LegalQuote != null && !BOXlst_LegalQuote.isEmpty()) {
            quoteStructure = folderHandler.getFolderStructure(Legal_Quote__c.SObjectType, BOXlst_LegalQuote[0].RecordTypeId);
        }

        String requestWhere = '%' + BOXLegalQuoteRequest.Matter__c + '%';
        String quoteWhere = '%' + BOXLegalQuoteRequest.Id + '%';
        List<Custom_FRUP__c> details = [
                SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c
                FROM Custom_FRUP__c
                WHERE CustomKey__c like :requestWhere OR CustomKey__c like :quoteWhere
        ];

        Map<String, List<Custom_FRUP__c>> frupMap = new Map<String, List<Custom_FRUP__c>>();
        List<Custom_FRUP__c> lst;
        for (Custom_FRUP__c l : details) {
            if (frupMap.get(l.CustomKey__c) == null) {
                lst = new List<Custom_FRUP__c>();
                lst.Add(l);
                frupMap.put(l.CustomKey__c, lst);
            } else {
                lst.Add(l);
                frupMap.put(l.CustomKey__c, lst);
            }
        }
        BxdLegalQuoteRequestService.createBoxFolders(BOXLegalQuoteRequest, BOXlst_LegalQuote, frupMap, requestStructure, quoteStructure);
    }

    public static void createBoxFolderTrigger(List<Legal_Quote__c> lst_LegalQuote) {
        Set<String> legalQuoteSet = new Set<String>();
        for (Legal_Quote__c l : lst_LegalQuote) {
            legalQuoteSet.Add(l.id);
        }

        createBoxFolderTrigger(legalQuoteSet);
    }

    @Future(callout = true)
    public static void createBoxFolderTrigger(Set<String> legalQuoteSet) {
        Legal_Quote_Request__c BOXLegalQuoteRequest;
        Set<String> Set_LQRequest = new Set<String>();

        List<Legal_Quote__c> quoteList = new List<Legal_Quote__c>([Select Id, Name, Contact__c, Law_Firm__c, Status__c, Quote_Approver__c, Legal_Quote_Request__c, Motivation_Comments__c, Quote_Amount__c, RecordTypeId From Legal_Quote__c where id in:legalQuoteSet Order by Legal_Quote_Request__c ASC]);

        for (Legal_Quote__c l : quoteList) {
            Set_LQRequest.Add(l.Legal_Quote_Request__c);
        }

        List<Legal_Quote_Request__c> requestList = new List<Legal_Quote_Request__c>([Select Id, Name, Matter__c, Quote_Title__c, Box_Quote_Request_Link__c, RecordTypeId From Legal_Quote_Request__c Where id in:Set_LQRequest]);

        if (requestList != null && !requestList.isEmpty()) {
            BOXLegalQuoteRequest = requestList[0];
        }

        //Legal Quote Request Folder Structure
        Box_Folder_Structure__c requestStructure = folderHandler.getFolderStructure(Legal_Quote_Request__c.SObjectType, BOXLegalQuoteRequest.RecordTypeId);

        //Legal Quote Folder Structure
        Box_Folder_Structure__c quoteStructure;
        if (quoteList != null && !quoteList.isEmpty()) {
            quoteStructure = folderHandler.getFolderStructure(Legal_Quote__c.SObjectType, quoteList[0].RecordTypeId);
        }

        String requestWhere = '%' + BOXLegalQuoteRequest.Matter__c + '%';
        String quoteWhere = '%' + BOXLegalQuoteRequest.Id + '%';
        List<Custom_FRUP__c> details = [
                SELECT Id, CustomKey__c, FolderId__c, ParentFolderId__c
                FROM Custom_FRUP__c
                WHERE (CustomKey__c like :requestWhere AND CustomKey__c like :quoteWhere) OR (CustomKey__c like :requestWhere OR CustomKey__c like :quoteWhere)
        ];

        Map<String, List<Custom_FRUP__c>> frupMap = new Map<String, List<Custom_FRUP__c>>();
        List<Custom_FRUP__c> lst;
        for (Custom_FRUP__c l : details) {
            if (frupMap.get(l.CustomKey__c) == null) {
                lst = new List<Custom_FRUP__c>();
                lst.Add(l);
                frupMap.put(l.CustomKey__c, lst);
            } else {
                lst.Add(l);
                frupMap.put(l.CustomKey__c, lst);
            }
        }
        system.debug('***request****' + requestStructure + '***quote***' + quoteStructure);
        BxdLegalQuoteRequestService.createBoxFolders(BOXLegalQuoteRequest, quoteList, frupMap, requestStructure, quoteStructure);
    }

    @Future(callout = true)
    public static void createBoxFolderTriggerBulk(Set<String> legalQuoteSet) {
        Map<String, List<Legal_Quote__c>> Maps_BOXLegal = new Map<String, List<Legal_Quote__c>>();
        Set<String> Set_LQRequest;

        List<Legal_Quote_Request__c> BOXLegalQuoteRequest = new List<Legal_Quote_Request__c>();

        List<Legal_Quote__c> BOXlst_LegalQuote;

        Set_LQRequest = new Set<String>();

        BOXlst_LegalQuote = new List<Legal_Quote__c>([Select Id, Name, Contact__c, Law_Firm__c, Status__c, Quote_Approver__c, Legal_Quote_Request__c, Motivation_Comments__c, Quote_Amount__c From Legal_Quote__c where id in:legalQuoteSet Order by Legal_Quote_Request__c ASC]);
        List<Legal_Quote__c> lst;
        for (Legal_Quote__c l : BOXlst_LegalQuote) {
            Set_LQRequest.Add(l.Legal_Quote_Request__c);

            if (Maps_BOXLegal.get(l.Legal_Quote_Request__c) == null) {
                lst = new List<Legal_Quote__c>();
                lst.Add(l);
                Maps_BOXLegal.put(l.Legal_Quote_Request__c, lst);
            } else {
                lst.Add(l);
                Maps_BOXLegal.put(l.Legal_Quote_Request__c, lst);
            }

        }
        BOXLegalQuoteRequest = new List<Legal_Quote_Request__c>([Select Id, Name, Matter__c, Quote_Title__c, Box_Quote_Request_Link__c, RecordTypeId From Legal_Quote_Request__c Where id in:Set_LQRequest]);
    }

    private class FolderHandler extends BxdFolderHandler {
        private FolderHandler() {
            super();
        }
    }
}