Public Class AgreementSearchOnMatter {


    // SEARCH FOR KNOWLEDGE AGREEMENT   --- SEAN 1/10/2018

    Public String AgreementSearch {get;set;}
    public List<ProductAgreementTemplateWrapper > productAgreementsWrapperSearch { get; set; }
    Public list<CaseKnowlege> lst_Casesearch { get; set; }


    public List<Agreement_Template__c> Lst_agreementRecord { get; set; }

    Public List<Agreement__c> lst_Agreement {get;set;}
    public advpm__Matter__c matter { get; set; }

    Public RecordType CaseKnowlege;

    Public AgreementSearchOnMatter(){
        String paramId = ApexPages.currentPage().getParameters().get('Id'); //Matter Id

        List<advpm__Matter__c> matter1 = [SELECT Id,Name,TMG_Product_Level_3__c,Product2__r.Name,advpm__Primary_Account__c FROM advpm__Matter__c WHERE  Id = :paramId];

        matter = matter1[0];
        lst_Casesearch = new list<CaseKnowlege> ();
    }


    Public void LoadAgreements(){

        lst_Agreement = [Select Name,TMG_Product_Level_3__c,Agreement_Type__c,Agreement_Template__c,Product__c From Agreement__c Where Matter_Deal__c =:matter.Id];
    }

    public pagereference Searchagreement(){
        String SearchTmp;
        String SearchTerm = AgreementSearch;
        Set<String> Set_String;
        List<Product_Agreement__c> lst_ProductAgreement = new List<Product_Agreement__c>();

        if(SearchTerm.length()>1){
            List<Agreement_Template__c> agreementTemplates = [Select id,RecordTypeId From Agreement_Template__c];
            lst_ProductAgreement = [Select Agreement_Template__c,TMG_Product_Level_3__c,Product__c From Product_Agreement__c];

            Set_String = new Set<String>();

            for(Product_Agreement__c p:lst_ProductAgreement){
                Set_String.add(p.Agreement_Template__c);
            }

            if(!Test.isRunningTest()){
                list<list<sObject>> searchTemplate = [FIND: SearchTerm IN ALL FIELDS
                        RETURNING Agreement_Template__c(Name,Description__c Where id in:Set_String ) limit 950];

                Lst_agreementRecord = (Agreement_Template__c[])searchTemplate[0];
            }
            else{
                SearchTmp = '%' + AgreementSearch + '%';
                Lst_agreementRecord = [Select Name,Description__c From Agreement_Template__c Where Name Like:SearchTmp AND id in:Set_String];
            }
            system.debug('**Search*'+Lst_agreementRecord +'*****'+SearchTerm+'**Set**'+ Set_String);

            productAgreementsWrapperSearch = new List<ProductAgreementTemplateWrapper> ();

            for(Agreement_Template__c l: Lst_agreementRecord){
                ProductAgreementTemplateWrapper ProductAgreement = new ProductAgreementTemplateWrapper();
                ProductAgreement.record = l;
                productAgreementsWrapperSearch.Add(ProductAgreement);
            }

            List<case> lst_Case;

            if(!Test.isRunningTest()){

                list<list<sObject>> searchCase = [FIND: SearchTerm IN ALL FIELDS
                        RETURNING Case(Description,SuggestedTags__c,SuggestedLibrary__c,Subject,Matter__c Where RecordType.Name = 'Knowledge Request' AND Status = 'Ready For Use') limit 950];


                lst_Case = (Case[])searchCase[0];
            }
            else{
                SearchTmp = '%'+ AgreementSearch+ '%';
                lst_Case = [Select id,SuggestedTags__c,SuggestedLibrary__c,Subject,Description,Matter__c,Status From Case Where RecordType.Name = 'Knowledge Request' AND Status = 'Ready For Use'
                AND (SuggestedTags__c Like:SearchTmp OR SuggestedLibrary__c Like:SearchTmp OR Subject Like:SearchTmp)];
            }

            for(Case v:lst_Case){
                CaseKnowlege cas = new CaseKnowlege();
                cas.CasId = v.id;
                cas.CasSubject = v.Subject;
                cas.CasSuggestedTags = v.SuggestedTags__c;
                cas.CasSuggestedLibrary = v.SuggestedLibrary__c;
                cas.CasDescription = v.Description;
                cas.CasMatter = v.Matter__c;

                lst_Casesearch.Add(cas);
            }
        }
        return null;

    }

    Public Pagereference GenerateSearchAgreements(){

        List<Agreement__c> agreementsToInsert = new List<Agreement__c>();
        List<Product_Agreement__c> lst_ProductAgreement;

        Set<String> Set_Prod = new Set<String>();
        Map<String,String> Map_Prod = new Map<String,String>();
        Map<String,String> Map_Type = new Map<String,String>();

        if(productAgreementsWrapperSearch != null){
            for(ProductAgreementTemplateWrapper wrapperRecord : productAgreementsWrapperSearch)
            {
                //Agreement selected.
                if(wrapperRecord.selected == true)
                {
                    Set_Prod.Add(wrapperRecord.record.id);
                }
            }

            lst_ProductAgreement = [Select Agreement_Template__c,id,TMG_Product_Level_3__c,Product__c from Product_Agreement__c Where Agreement_Template__c in: Set_Prod];

            for(Product_Agreement__c p:lst_ProductAgreement){
                Map_Prod.Put(p.Agreement_Template__c,p.TMG_Product_Level_3__c);
                Map_Type.Put(p.Agreement_Template__c,p.id);
            }

            for(ProductAgreementTemplateWrapper wrapperRecord : productAgreementsWrapperSearch)
            {
                //Agreement selected.
                if(wrapperRecord.selected == true)
                {
                    //New agreement object.
                    Agreement__c agreementRecord = new Agreement__c();
                    agreementRecord.Name = wrapperRecord.record.Name;
                    agreementRecord.Agreement_Description__c = wrapperRecord.record.Description__c;
                    agreementRecord.Agreement_Template__c = wrapperRecord.record.id;
                    agreementRecord.TMG_Product_Level_3__c = Map_Prod.get(wrapperRecord.record.Id);
                    agreementRecord.Matter_Deal__c = matter.Id;
                    agreementRecord.Client_Name__c = matter.advpm__Primary_Account__c; //Relationship
                    agreementRecord.Agreement_Type__c = Map_Type.get(wrapperRecord.record.Id);
                    agreementRecord.RecordTypeId = Schema.SObjectType.Agreement__c.getRecordTypeInfosByName().get('Agreement Legal').getRecordTypeId();

                    //Add agreement object to insert list.
                    agreementsToInsert.add(agreementRecord);
                }
            }
            try
            {
                //Insert agreement records.
                insert agreementsToInsert;
            }
            catch(Exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'The was an error processing the request. Error Message: '+e.getMessage()));

                //Default return.
                return null;
            }

            PageReference pf = new PageReference('/' + matter.id);
            return pf;
        }

        return null;
    }

    public void clearData(){
        lst_Casesearch.clear();
        if(productAgreementsWrapperSearch != null){
            productAgreementsWrapperSearch.clear();
        }
        lst_Agreement.clear();
    }


    Public Pagereference AddMattertoCase(){

        List<Case> lst_Case = new List<Case>();
        Set<String> Set_id = new Set<String>();

        for(CaseKnowlege v:lst_Casesearch){
            if(v.CasSelected==True){
                Set_id.add(v.CasId);
            }
        }

        lst_Case = [Select id,Matter__c From Case Where id in:Set_id ];

        for(Case c:lst_Case){
            c.Matter__c = matter.id;
            Boolean copied = BxdKnowledgeService.copyCaseFolderToMatter(c.id, matter.id);
            System.debug('Here ' + c.id + '-----' + copied);
            if(!copied){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,'There was an error copying the Case folder to Box, Please try again'));
                return null;
            }
        }

        for(CaseKnowlege v:lst_Casesearch){
            if(v.CasSelected==True){
                v.CasMatter = matter.name;
            }
        }

        system.debug('**lst_Case**'+lst_Case);

        update lst_Case;

        PageReference pf = new PageReference('/' + matter.id);
        return pf;
    }

    public PageReference actionCancel(){

        return new pagereference('/'+matter.Id);
    }

    /**
      * Step 1 Wrapper Class
     **/

    public class ProductAgreementTemplateWrapper
    {
        public Agreement_Template__c record { get; set; }
        public Boolean selected { get; set; }
    }

    Public Class CaseKnowlege{

        Public string CasId {get;set;}
        Public string CasSubject{get;set;}
        Public string CasDescription{get;set;}
        Public string CasSuggestedTags{get;set;}
        Public string  CasSuggestedLibrary{get;set;}
        Public string  CasMatter{get;set;}
        Public boolean CasSelected  {get;set;}
    }
}