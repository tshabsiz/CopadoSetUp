/**
* @Author       Marta Malinowska
* Company:      Deloitte
* @Description: This class is invoked from custom button on Matrix Lead object and its purpose is to convert Matrix Lead to Prospect.
* @Date:        10/2015
* @ConstructorParam:    None
* @TestClass:   ZZTEST_MatrixLeadConversion
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 14/12/2015  Marta Malinowska   Add Matrix Lead Position to Contact Job Role mapping.
* 12/01/2016  Marta Malinowska   Match Matrix Leads within the same company by REF NO F.
*------------------------------------------------------------*/
global class MatrixLeadConversion {
    public static String STATUS_CONVERTED = 'Converted';
    public static String SOURCE_MATRIX = 'Matrix Database';
    public static String ERR_MSG_MATRIX_LEAD_DELETED = 'ERROR: Matrix Lead has been deleted.';
    public static String ERR_MSG_REF_NO_EMPTY = 'ERROR: REF NO cannot be empty.';
    public static String ERR_MSG_PROSPECT_RECORD_TYPE = 'ERROR: Prospect cannot be created. Please contact your System Administrator.';
    public static String ERR_MSG_MATRIX_LEAD_RECORD_TYPE = 'ERROR: Matrix Lead cannot be converted. Please contact your System Administrator.';
    public static String ERR_MSG_PROSPECT_CANNOT_BE_CREATED = 'ERROR: Prospect cannot be created.';
    public static String ERR_MSG_CONTACTS_CANNOT_BE_CREATED = 'ERROR: One or more Contacts cannot be created.';
    public static String ERR_MSG_MATRIX_LEADS_CANNOT_BE_CONVERTED = 'ERROR: One or more Matrix Leads cannot be converted.';

    /**
    * @Author:      Marta Malinowska
    * @Company:     Deloitte
    * @Description: This method is used to convert Matrix Leads to Prospect Account with the related list of Contacts.
    * @param        The Id of Matrix Lead that will be converted
    * @Returns:     Id of created Prospect Account if it has been successfull
    *               Error Message in case of any errors
    * History
    * <Date>      <Authors Name>     <Brief Description of Change>
    * 14/12/2015  Marta Malinowska   Add Matrix Lead Position to Contact Job Role mapping.
    *------------------------------------------------------------*/
    @AuraEnabled
    webservice static String convertMatrixLeadToProspect(Id matrixLeadId) {
        String errMsg;
        Matrix_Lead__c mainMatrixLead;
        try{
            mainMatrixLead = [SELECT Id, Name, CurrencyIsoCode, REF_NO__c, REF_NO_F__c, Company_Name__c, Trade_Division__c, REG_No__c, SICCODE_Description__c, Bank__c, Turn_Over__c
                                FROM Matrix_Lead__c WHERE Id = :matrixLeadId];
        } catch(QueryException ex){
            System.debug('MATRIX LEAD QUERY EXCEPTION: '+ex);
            return ERR_MSG_MATRIX_LEAD_DELETED;
        }

        if(mainMatrixLead.REF_NO__c == null){
            return ERR_MSG_REF_NO_EMPTY;
        }

        RecordType prospectRecordType;
        try{
            prospectRecordType = [SELECT Id FROM RecordType  WHERE SobjectType = 'Account' AND DeveloperName = 'Prospect'];
        } catch(QueryException ex){
            System.debug('RECORD TYPE QUERY EXCEPTION: '+ex);
            return ERR_MSG_PROSPECT_RECORD_TYPE;
        }

        RecordType convertedLeadRecordType;
        try{
            convertedLeadRecordType = [SELECT Id FROM RecordType  WHERE SobjectType = 'Matrix_Lead__c' AND DeveloperName = 'Converted_Leads'];
        } catch(QueryException ex){
            System.debug('RECORD TYPE QUERY EXCEPTION: '+ex);
            return ERR_MSG_MATRIX_LEAD_RECORD_TYPE;
        }

        Savepoint sp = Database.setSavepoint();

        Account account = new Account();
        account.RecordTypeId = prospectRecordType.Id;
        account.CurrencyIsoCode = mainMatrixLead.CurrencyIsoCode;
        account.REF_NO__c = mainMatrixLead.REF_NO__c;
        account.Name = mainMatrixLead.Company_Name__c;
        account.Trade_Division__c = mainMatrixLead.Trade_Division__c;
        account.Registration_Number__c = mainMatrixLead.REG_No__c;
        account.SICCODE_Description__c = mainMatrixLead.SICCODE_Description__c;
        account.Primary_Bank_Name__c = mainMatrixLead.Bank__c;
        account.Turn_Over_Proxy__c = mainMatrixLead.Turn_Over__c;
        account.AccountSource = SOURCE_MATRIX;
        try{
            insert account;
        } catch(DmlException ex){
            return ERR_MSG_PROSPECT_CANNOT_BE_CREATED+' '+ex.getDmlMessage(0);
        }

        List<Contact> contacts = new List<Contact>();
        List<Matrix_Lead__c> matrixLeadsToUpd = new List<Matrix_Lead__c>();
        for(Matrix_Lead__c matrixLead : [SELECT Id, Name, Postal_Address1__c, Postal_Area__c, Post_Code__c, Street_Address_1__c, Tel_Code__c,
                                        Tel_No__c, Responsibility__c, Position__c, Salutation__c, First_Name__c, Surname__c, Job_Title__c, 
                                        Personal_Email__c, Province__c
                                        FROM Matrix_Lead__c WHERE REF_NO_F__c = :mainMatrixLead.REF_NO_F__c]){
            Contact contact = new Contact();
            contact.AccountId = account.Id;
            contact.Address_line_1__c = matrixLead.Postal_Address1__c;
            contact.Postal_Area__c = matrixLead.Postal_Area__c;
            contact.Post_code__c = matrixLead.Post_Code__c;
            contact.Address_line_2__c = matrixLead.Street_Address_1__c;
            contact.Phone = matrixLead.Tel_No__c;
            contact.Responsibility__c = matrixLead.Responsibility__c;
            contact.Position__c = matrixLead.Position__c;
            contact.Job_Role__c = matrixLead.Position__c;
            contact.Salutation = matrixLead.Salutation__c;
            contact.FirstName = matrixLead.First_Name__c;
            contact.LastName = matrixLead.Surname__c;
            contact.Job_title__c = matrixLead.Job_Title__c;
            contact.Email = matrixLead.Personal_Email__c;
            contact.Province__c = matrixLead.Province__c;
            contacts.add(contact);
            matrixLead.RecordTypeId = convertedLeadRecordType.Id;
            matrixLead.Lead_Status__c = STATUS_CONVERTED;
            matrixLeadsToUpd.add(matrixLead);
        }

        try{
            insert contacts;
        } catch(DmlException ex){
            Database.rollback(sp);
            errMsg = ERR_MSG_CONTACTS_CANNOT_BE_CREATED;
            for(Integer i=0; i < ex.getNumDml(); i++){
                errMsg += '\n'+ex.getDmlMessage(i);
            }
            return errMsg;
        }

        try{
            update matrixLeadsToUpd;
        } catch(DmlException ex){
            Database.rollback(sp);
            errMsg = ERR_MSG_MATRIX_LEADS_CANNOT_BE_CONVERTED;
            for(Integer i=0; i < ex.getNumDml(); i++){
                errMsg += '\n'+ex.getDmlMessage(i);
            }
            return errMsg;
        }

        return account.Id;
    }
}