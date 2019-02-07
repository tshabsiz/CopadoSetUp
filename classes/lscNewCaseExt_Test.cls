/**
23/03/2017 - DF   - Created Class.
2018-04-12 - Rudolf Niehaus - Update class, fix errors
**/

@IsTest(SeeAllData=true)

private class lscNewCaseExt_Test 
{
    @IsTest
    static void lscNewCaseExt_test()
    { 
                   
        Account testAccount = new Account();
        
        testAccount.RecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group').getRecordTypeId();
        testAccount.Name = 'LightningInterfaceAccount';
        testAccount.CIF__C = 'ASMD232;ESTEST123';
        testAccount.ShippingCountry = 'South Africa';
        
        insert testAccount;
        
        
        test.starttest(); 
        
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ADAPT360Response');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        
        Test.setMock(HttpCalloutMock.class, mock);
        
        
        
        lscNewCaseExt.qValue = testAccount.Name;
        lscNewCaseExt.relName = testAccount.Name;
        lscNewCaseExt.GetRecordTypeIds();  
        lscNewCaseExt.searchUser('api',true);
        lscNewCaseExt.fetchAccount(testAccount.Name);
        
        lscNewCaseExt.searchSalesforceAccounts('{"vfUrl":"barclaysafrica--Lightning.cs88.visual.force.com","UDFServiceTypes_r":";ND Internal 3rd Party;ND Salary Payments;SD External 3rd Party;SD Internal 3rd Party;SD Internal 1st Party;SD Salary Payments;ND Internal 1st Party;ND External 3rd Party","theCase_r":{"attributes":{"type":"Case"},"RecordTypeId":"012240000006qPYAAY","OwnerId":"0059E000004lAqNQAU"},"ResponseMessage_r":null,"relName_r":"","relID_r":"","relCIF_r":"","rel_r":null,"recordTypeDescription_r":"CSC Manual Cases","qValue_r":"'+testAccount.Name+'","queryTypeList_r":[],"qType_r":"cif","PrimaryClients_r":[],"PrimaryClient_r":null,"noAccount_r":false,"isNotCSCProfile_r":true,"isDOSProfile_r":null,"isCSCProfile_r":false,"isComplaint_r":false,"errors_r":"","Client_Details_r":[],"cifNameMap_r":{},"cifName_r":null,"cifdataOptions_r":[],"ChargesServiceTypes_r":";CPF;Home Loans - Copy Title Deed;SD Salary Payments;Cheque wrongly encoded;Unidentified Deposit;Copy of Cheque;Trace FOREX Transaction;e-Statements;CAF Armortization Schedule;Unidentified Deposit - Bulk;Copy of Transfer slip;Irregular Cheques;Sweeping Instruction - Standing;Stop Payments;Payment Confirmation / Notification;Incorrectly Processed;SD External 3rd Party;Full General;Merchant Services;SD Internal 1st Party;ND External 3rd Party;Confirm Deposit / Cash Withdrawal;Journal / Charge Queries;Safe Keeping duplicate keys;Account Balance;Create / Maintain - stop / debit order;Archive Statement;Tax Certificate;Investment;SD Journal Processing;Sweeping Instruction - Internal;Complex Enquiries;ND Salary Payments;Signature Verifications;CPF Title Deed;Home Loans - Copy of Loan Agreement;ND Internal 3rd Party;VAT Certificate;ND Journal Processing;CPF Copy of Loan Agreement;Bank Debit;Guarantees;Trace Electronic Banking Transaction;Delayed Payment;ATM Payment;Cheque clearance;Copy of Deposit slip;Term Loan;Savings;SD Internal 3rd Party;Account Confirmation;Bank Code Request;Cheque book collection;Balance Certificate;ACB Credit/Debit - Bulk;Disputed Transactions;Current Statement;AVAF;ACB Credit/Debit;Missing Deposit;Unpaid Cheque - YUFIG;Recall of Funds;Home Loans;ND Internal 1st Party;Current Enquiries;Credit Card;Order Cheque / Deposit Books","caseOwnerName_r":"Mtha Gumede","accountOptions_r":[]}');        
        
        lscNewCaseExt.decimalToBinary(1);
        lscNewCaseExt.accountSelection('{"vfUrl":"barclaysafrica--Lightning.cs88.visual.force.com","UDFServiceTypes_r":";ND Internal 3rd Party;ND Salary Payments;SD External 3rd Party;SD Internal 3rd Party;SD Internal 1st Party;SD Salary Payments;ND Internal 1st Party;ND External 3rd Party","theCase_r":{"attributes":{"type":"Case"},"RecordTypeId":"012240000006qPYAAY","OwnerId":"0059E000004lAqNQAU"},"ResponseMessage_r":null,"relName_r":"","relID_r":"","relCIF_r":"","rel_r":null,"recordTypeDescription_r":"CSC Manual Cases","qValue_r":"'+testAccount.Name+'","queryTypeList_r":[],"qType_r":"cif","PrimaryClients_r":[],"PrimaryClient_r":null,"noAccount_r":false,"isNotCSCProfile_r":true,"isDOSProfile_r":null,"isCSCProfile_r":false,"isComplaint_r":false,"errors_r":"","Client_Details_r":[],"cifNameMap_r":{},"cifName_r":null,"cifdataOptions_r":[],"ChargesServiceTypes_r":";CPF;Home Loans - Copy Title Deed;SD Salary Payments;Cheque wrongly encoded;Unidentified Deposit;Copy of Cheque;Trace FOREX Transaction;e-Statements;CAF Armortization Schedule;Unidentified Deposit - Bulk;Copy of Transfer slip;Irregular Cheques;Sweeping Instruction - Standing;Stop Payments;Payment Confirmation / Notification;Incorrectly Processed;SD External 3rd Party;Full General;Merchant Services;SD Internal 1st Party;ND External 3rd Party;Confirm Deposit / Cash Withdrawal;Journal / Charge Queries;Safe Keeping duplicate keys;Account Balance;Create / Maintain - stop / debit order;Archive Statement;Tax Certificate;Investment;SD Journal Processing;Sweeping Instruction - Internal;Complex Enquiries;ND Salary Payments;Signature Verifications;CPF Title Deed;Home Loans - Copy of Loan Agreement;ND Internal 3rd Party;VAT Certificate;ND Journal Processing;CPF Copy of Loan Agreement;Bank Debit;Guarantees;Trace Electronic Banking Transaction;Delayed Payment;ATM Payment;Cheque clearance;Copy of Deposit slip;Term Loan;Savings;SD Internal 3rd Party;Account Confirmation;Bank Code Request;Cheque book collection;Balance Certificate;ACB Credit/Debit - Bulk;Disputed Transactions;Current Statement;AVAF;ACB Credit/Debit;Missing Deposit;Unpaid Cheque - YUFIG;Recall of Funds;Home Loans;ND Internal 1st Party;Current Enquiries;Credit Card;Order Cheque / Deposit Books","caseOwnerName_r":"Mtha Gumede","accountOptions_r":[]}');
        lscNewCaseExt.newComplainCase('{"vfUrl":"barclaysafrica--Lightning.cs88.visual.force.com","UDFServiceTypes_r":";ND Internal 3rd Party;ND Salary Payments;SD External 3rd Party;SD Internal 3rd Party;SD Internal 1st Party;SD Salary Payments;ND Internal 1st Party;ND External 3rd Party","theCase_r":{"attributes":{"type":"Case"},"RecordTypeId":"012240000006qPYAAY","OwnerId":"0059E000004lAqNQAU"},"ResponseMessage_r":null,"relName_r":"","relID_r":"","relCIF_r":"","rel_r":null,"recordTypeDescription_r":"CSC Manual Cases","qValue_r":"'+testAccount.Name+'","queryTypeList_r":[],"qType_r":"cif","PrimaryClients_r":[],"PrimaryClient_r":null,"noAccount_r":false,"isNotCSCProfile_r":true,"isDOSProfile_r":null,"isCSCProfile_r":false,"isComplaint_r":false,"errors_r":"","Client_Details_r":[],"cifNameMap_r":{},"cifName_r":null,"cifdataOptions_r":[],"ChargesServiceTypes_r":";CPF;Home Loans - Copy Title Deed;SD Salary Payments;Cheque wrongly encoded;Unidentified Deposit;Copy of Cheque;Trace FOREX Transaction;e-Statements;CAF Armortization Schedule;Unidentified Deposit - Bulk;Copy of Transfer slip;Irregular Cheques;Sweeping Instruction - Standing;Stop Payments;Payment Confirmation / Notification;Incorrectly Processed;SD External 3rd Party;Full General;Merchant Services;SD Internal 1st Party;ND External 3rd Party;Confirm Deposit / Cash Withdrawal;Journal / Charge Queries;Safe Keeping duplicate keys;Account Balance;Create / Maintain - stop / debit order;Archive Statement;Tax Certificate;Investment;SD Journal Processing;Sweeping Instruction - Internal;Complex Enquiries;ND Salary Payments;Signature Verifications;CPF Title Deed;Home Loans - Copy of Loan Agreement;ND Internal 3rd Party;VAT Certificate;ND Journal Processing;CPF Copy of Loan Agreement;Bank Debit;Guarantees;Trace Electronic Banking Transaction;Delayed Payment;ATM Payment;Cheque clearance;Copy of Deposit slip;Term Loan;Savings;SD Internal 3rd Party;Account Confirmation;Bank Code Request;Cheque book collection;Balance Certificate;ACB Credit/Debit - Bulk;Disputed Transactions;Current Statement;AVAF;ACB Credit/Debit;Missing Deposit;Unpaid Cheque - YUFIG;Recall of Funds;Home Loans;ND Internal 1st Party;Current Enquiries;Credit Card;Order Cheque / Deposit Books","caseOwnerName_r":"Mtha Gumede","accountOptions_r":[]}');
        lscNewCaseExt.newManualCase('{"id":"","contactConfirmedWith":null,"clientContactTelNo":null,"dateConfirmed":null,"clientAbsaAccountNumber":null,"clientIDNumberMandateAUTH":null,"clientSignatureMandateSIGV":null,"beneficiaryName":null,"amountVerifiedandApproved":null,"beneficiaryAccNoandBank":null,"beneficiaryACBorBranchCode":null,"indemnityVerified":null,"disclaimerReadtoClient":null,"rSCConfirmsFunds":null,"duplicationsChecked":null,"typeofTransferAuthorised":null,"verifyClientAccountNumberDebit":null,"paymentAuthPaperMandate":null,"thirdPartyPaymentProcessed":null,"wip":null,"pop":null,"chargeAccountNo":null,"transactionCode":null,"costCentre":null,"corpCode":null,"dRRef":null,"cRRef":null,"effectiveDate":null,"cRAccountNo":null,"emailSenderName":"efewf","emailFromAddress":"test@tesrt.com","queue":"Cash Breaks","subject":"efewfew","description":"k.lk","priority":"Medium","urgent":false,"accountId":"0019E00000grfzgQAA","accountNumber":"","department":"Investigations","fullDepartment":"Payments Operations","teamManager":"Eleanor Snyders","businessHours":"Monday to Friday 08:00 - 16:30","team":"Cash Breaks","origin":"Telephone","serviceCategory":"Service Related","serviceSubCategory":"Service","serviceType":"Unapplied Funds","requests":"1","channel":"Intellimatch","hWasEmailToCaseAction":true,"reasonforCancellation":null,"recordTypeId":"012240000006qPYAAY","OwnerId":"0059E000004lAqNQAU","relationshipID":"0019E00000grfzgQAA"}');
        lscNewCaseExt.newDigitalOpsCase('{"id":"","contactConfirmedWith":null,"clientContactTelNo":null,"dateConfirmed":null,"clientAbsaAccountNumber":null,"clientIDNumberMandateAUTH":null,"clientSignatureMandateSIGV":null,"beneficiaryName":null,"amountVerifiedandApproved":null,"beneficiaryAccNoandBank":null,"beneficiaryACBorBranchCode":null,"indemnityVerified":null,"disclaimerReadtoClient":null,"rSCConfirmsFunds":null,"duplicationsChecked":null,"typeofTransferAuthorised":null,"verifyClientAccountNumberDebit":null,"paymentAuthPaperMandate":null,"thirdPartyPaymentProcessed":null,"wip":null,"pop":null,"chargeAccountNo":null,"transactionCode":null,"costCentre":null,"corpCode":null,"dRRef":null,"cRRef":null,"effectiveDate":null,"cRAccountNo":null,"emailSenderName":"efewf","emailFromAddress":"test@tesrt.com","queue":"Cash Breaks","subject":"efewfew","description":"k.lk","priority":"Medium","urgent":false,"accountId":"0019E00000grfzgQAA","accountNumber":"","department":"Investigations","fullDepartment":"Payments Operations","teamManager":"Eleanor Snyders","businessHours":"Monday to Friday 08:00 - 16:30","team":"Cash Breaks","origin":"Telephone","serviceCategory":"Service Related","serviceSubCategory":"Service","serviceType":"Unapplied Funds","requests":"1","channel":"Intellimatch","hWasEmailToCaseAction":true,"reasonforCancellation":null,"recordTypeId":"012240000006qPYAAY","OwnerId":"0059E000004lAqNQAU","relationshipID":"0019E00000grfzgQAA"}');
       
        lscNewCaseExt.GetAccount('{"id":"","contactConfirmedWith":null,"clientContactTelNo":null,"dateConfirmed":null,"clientAbsaAccountNumber":null,"clientIDNumberMandateAUTH":null,"clientSignatureMandateSIGV":null,"beneficiaryName":null,"amountVerifiedandApproved":null,"beneficiaryAccNoandBank":null,"beneficiaryACBorBranchCode":null,"indemnityVerified":null,"disclaimerReadtoClient":null,"rSCConfirmsFunds":null,"duplicationsChecked":null,"typeofTransferAuthorised":null,"verifyClientAccountNumberDebit":null,"paymentAuthPaperMandate":null,"thirdPartyPaymentProcessed":null,"wip":null,"pop":null,"chargeAccountNo":null,"transactionCode":null,"costCentre":null,"corpCode":null,"dRRef":null,"cRRef":null,"effectiveDate":null,"cRAccountNo":null,"emailSenderName":"efewf","emailFromAddress":"test@tesrt.com","queue":"Cash Breaks","subject":"efewfew","description":"k.lk","priority":"Medium","urgent":false,"accountId":"0019E00000grfzgQAA","accountNumber":"","department":"Investigations","fullDepartment":"Payments Operations","teamManager":"Eleanor Snyders","businessHours":"Monday to Friday 08:00 - 16:30","team":"Cash Breaks","origin":"Telephone","serviceCategory":"Service Related","serviceSubCategory":"Service","serviceType":"Unapplied Funds","requests":"1","channel":"Intellimatch","hWasEmailToCaseAction":true,"reasonforCancellation":null,"recordTypeId":"012240000006qPYAAY","OwnerId":"0059E000004lAqNQAU","relationshipID":"0019E00000grfzgQAA"}',null,null);
        test.stopTest();
    }
    @IsTest
    static void lscNewCaseExt_Pos(){
       
                
        case testCase = new case();
        
        testCase.RecordTypeId  = Schema.SObjectType.case.getRecordTypeInfosByName().get('CSC Emails').getRecordTypeId();
        testCase.Queue__c = 'EBSH - Passwords';
        testCase.Subject = 'Support test ';
        testCase.Origin = 'Email';
        testCase.Status = 'New';

        testcase.Department__c = 'EBSH';
        testCase.Full_Department__c = 'Absa Electronic Banking Helpdesk';
        testCase.SLA_Time_Measure__c= 'Hour(s)';
        testCase.SLA_Units__c= 2;
        
        insert testCase;
        
     Group testq = new Group();
        testq.Name = 'testq';
        testq.Type = 'Queue'; 
        insert testq;

            EmailMessage testEmailMessage = new EmailMessage();
        
        
                testEmailMessage.Subject = 'Email Message test ';
                testEmailMessage.ParentId = testCase.id;
                testEmailMessage.MessageDate = System.now();
                testEmailMessage.isOriginalEmail__c =true;
        
         insert testEmailMessage;
        
        Attachment attachment = new Attachment(); 
           
             attachment.ParentId = testEmailMessage.Id;
             attachment.Name ='Email Body.html';   
             attachment.Body = Blob.valueOf('bodyTest');
        
         insert attachment;
        
        string CaseID = String.valueOf(testCase.id);
    
          
         test.startTest();
     
        lscNewCaseExt.lscNewCaseExt1(null,'digitalOps');
        lscNewCaseExt.lscNewCaseExt1(null,'cscManual');
        lscNewCaseExt.lscNewCaseExt1(null,'Complaint');
        lscNewCaseExt.lscNewCaseExt1(CaseID,'Complaint');
        lscNewCaseExt.NewCase('{"theCase_r":{"attributes":{"type":"Case"},"RecordTypeId":"'+testCase.RecordTypeId+'","id":"'+CaseID+'"}}','Duplicated Payment', 'Intellimatch', '1', 'Service', 'Cash Breaks', 'Service Related','Investigations');
        lscNewCaseExt.DigitalOpsCase  DigitalOpsCase = new lscNewCaseExt.DigitalOpsCase();
        lscNewCaseExt.ManualCase ManualCase= new  lscNewCaseExt.ManualCase();
        lscNewCaseExt.ComplainCase ComplainCase =  new lscNewCaseExt.ComplainCase();
        lscNewCaseExt.DocumentInfo Document = new lsCNewCaseExt.DocumentInfo();
        lscNewCaseExt.ProductInfo ProductInfo = new lsCNewCaseExt.ProductInfo();
        lscNewCaseExt.DocumentDetailsInfo DocumentDetailsInfo = new lscNewCaseExt.DocumentDetailsInfo();
        lscNewCaseExt.PicklistEntryWrapper1 PicklistEntryWrapper1 = new lscNewCaseExt.PicklistEntryWrapper1();
        
        Test.stoptest();
    }

    @IsTest
    static void lscNewCaseExt_Json(){  
        
             
        Account testAccount = new Account();
        
        testAccount.RecordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Relationship Group').getRecordTypeId();
        testAccount.Name = 'LightningInterfaceAccount';
        testAccount.CIF__C = 'AS32 ESTEST123';
        testAccount.ShippingCountry = 'South Africa';
  
        
        insert testAccount;
        

   
        Test.startTest();
        
        
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ADAPT360Response');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        lscNewCaseExt adpt360 = new lscNewCaseExt();
        
        
        lscNewCaseExt.qValue = testAccount.Name;
        lscNewCaseExt.relName = testAccount.Name;
        lscNewCaseExt.GetRecordTypeIds();  
        lscNewCaseExt.searchUser('api',true);
        lscNewCaseExt.fetchAccount( testAccount.Name);
        
        lscNewCaseExt.searchSalesforceAccounts('{"vfUrl":"barclaysafrica--Lightning.cs88.visual.force.com","UDFServiceTypes_r":";ND Internal 3rd Party;ND Salary Payments;SD External 3rd Party;SD Internal 3rd Party;SD Internal 1st Party;SD Salary Payments;ND Internal 1st Party;ND External 3rd Party","theCase_r":{"attributes":{"type":"Case"},"RecordTypeId":"012240000006qPYAAY","OwnerId":"0059E000004lAqNQAU"},"ResponseMessage_r":null,"relName_r":"","relID_r":"","relCIF_r":"","rel_r":null,"recordTypeDescription_r":"CSC Manual Cases","qValue_r":"PICK N PAY RETAILERS (PTY) LTD","queryTypeList_r":[],"qType_r":"cif","PrimaryClients_r":[],"PrimaryClient_r":null,"noAccount_r":false,"isNotCSCProfile_r":true,"isDOSProfile_r":null,"isCSCProfile_r":false,"isComplaint_r":false,"errors_r":"","Client_Details_r":[],"cifNameMap_r":{},"cifName_r":null,"cifdataOptions_r":[],"ChargesServiceTypes_r":";CPF;Home Loans - Copy Title Deed;SD Salary Payments;Cheque wrongly encoded;Unidentified Deposit;Copy of Cheque;Trace FOREX Transaction;e-Statements;CAF Armortization Schedule;Unidentified Deposit - Bulk;Copy of Transfer slip;Irregular Cheques;Sweeping Instruction - Standing;Stop Payments;Payment Confirmation / Notification;Incorrectly Processed;SD External 3rd Party;Full General;Merchant Services;SD Internal 1st Party;ND External 3rd Party;Confirm Deposit / Cash Withdrawal;Journal / Charge Queries;Safe Keeping duplicate keys;Account Balance;Create / Maintain - stop / debit order;Archive Statement;Tax Certificate;Investment;SD Journal Processing;Sweeping Instruction - Internal;Complex Enquiries;ND Salary Payments;Signature Verifications;CPF Title Deed;Home Loans - Copy of Loan Agreement;ND Internal 3rd Party;VAT Certificate;ND Journal Processing;CPF Copy of Loan Agreement;Bank Debit;Guarantees;Trace Electronic Banking Transaction;Delayed Payment;ATM Payment;Cheque clearance;Copy of Deposit slip;Term Loan;Savings;SD Internal 3rd Party;Account Confirmation;Bank Code Request;Cheque book collection;Balance Certificate;ACB Credit/Debit - Bulk;Disputed Transactions;Current Statement;AVAF;ACB Credit/Debit;Missing Deposit;Unpaid Cheque - YUFIG;Recall of Funds;Home Loans;ND Internal 1st Party;Current Enquiries;Credit Card;Order Cheque / Deposit Books","caseOwnerName_r":"Mtha Gumede","accountOptions_r":[]}');        
        
        lscNewCaseExt.ClientDetail PrimaryClient = lscNewCaseExt.PrimaryClient;
        List<lscNewCaseExt.ClientDetail> Mandates = adpt360.Mandates;
        List<SelectOption> CIFOptions = adpt360.CIFOptions;
        List<String> CIFs = adpt360.CIFNumbers;
        System.AssertEquals('', adpt360.Error);
        //System.AssertNotEquals(null, PrimaryClient);
        System.AssertEquals(3, Mandates.size());
        System.AssertEquals(10, PrimaryClient.account.size());
        System.AssertEquals(10, adpt360.PrimaryClientAccounts.size());
        System.AssertEquals(1, CIFOptions.size());
        System.AssertEquals('MUZZIE 001', CIFs[0]);
        System.AssertEquals('ES', PrimaryClient.individual.givenName.value);
        System.AssertEquals('E', PrimaryClient.individual.nameInitials.value);
        System.AssertEquals('MUZZII', PrimaryClient.individual.surname.value);
        System.AssertEquals('01', PrimaryClient.individual.salutationType.code.value);
        System.AssertEquals('MR', PrimaryClient.individual.salutationType.description.value);
        System.AssertEquals('00;', PrimaryClient.individual.countryPassport.code.value);
        System.AssertEquals('SO003', PrimaryClient.individual.countryOfBirth.code.value);
        System.AssertEquals('1', PrimaryClient.individual.gender.code.value);
        System.AssertEquals('SOU01', PrimaryClient.individual.nationality.code.value);
        System.AssertEquals('F', PrimaryClient.individual.employmentStatusType.code.value);
        lscNewCaseExt.DocumentInfo idDoc = Mandates[2].individual.documentDetails.idDoc;
        System.AssertEquals(null, idDoc.casaTier.value);
        System.AssertEquals(null, idDoc.documentType.code.value);
        System.AssertEquals(null, idDoc.documentStatusReason.code.value);
        System.AssertEquals(null, idDoc.casaSequence.value);
        System.AssertEquals(null, idDoc.imageId.value);
        System.AssertEquals(null, idDoc.casaReference.value);
        System.AssertEquals(null, idDoc.documentRecieved.value);
        System.AssertEquals(null, idDoc.documentInOrder.value);
        System.AssertEquals(null, idDoc.qualityAssurance.value);
        System.AssertEquals(null, idDoc.allCorrectRecieved.value);
        System.AssertEquals(null, idDoc.allCorrectInOrder.value);
        lscNewCaseExt.DocumentInfo addDoc = Mandates[2].individual.documentDetails.addDoc;
        System.AssertEquals(null, addDoc.casaTier.value);
        System.AssertEquals('01/09/1983 00:00:00', Mandates[2].individual.birthDate.value);
        System.AssertEquals('SO003', Mandates[2].individual.countryOfOrigin.code.value);
        System.AssertEquals('SO003', Mandates[2].individual.countryOfResidence.code.value);
        lscNewCaseExt.AccountInfo account = PrimaryClient.account[0];
        System.AssertEquals('00000000053203235', account.accountNumber.value);
        System.AssertEquals('COMBI', account.product.value);
        System.AssertEquals('CO', account.productType.value);
        System.AssertEquals('0', account.availableBalance.value);
        System.AssertEquals(0, account.availableBalanceFormatted);
        System.AssertEquals('True', account.availableBalanceSpecified.value);
        System.AssertEquals(0, account.balanceFormatted);
        System.AssertEquals('True', account.balanceSpecified.value);
        System.AssertEquals('', account.balanceTxt.value);
        System.AssertEquals('8198', account.branch.value);
        System.AssertEquals('ABS', account.corporationCode.value);
        System.AssertEquals(null, account.dateClosed.value);
        System.AssertEquals('', account.detail.value);
        System.AssertEquals('0.00', account.limits.value);
        System.AssertEquals('True', account.limitSpecified.value);
        System.AssertEquals('', account.accountStatus.value);
        System.AssertEquals('14c8f894-de45-41cd-8f32-e9990de8c5a2', account.entity.ref);
        lscNewCaseExt.CustomerDetailsInfo cusdetails = PrimaryClient.customerDetails;
        System.AssertEquals('01', cusdetails.identificationTypeId.code.value);
        System.AssertEquals('8408095231087', cusdetails.individualId.value);
        System.AssertEquals('', cusdetails.universalResourceLocator.value);
        System.AssertEquals('001', cusdetails.customerType.code.value);
        System.AssertEquals('I', cusdetails.groupScheme.code.value);
        System.AssertEquals('00;', cusdetails.sourceOfFundsCode.code.value);
        System.AssertEquals('20', cusdetails.sourceOfIncomeCode.code.value);
        System.AssertEquals('A', cusdetails.corporateDivision.code.value);
        System.AssertEquals('YES', cusdetails.NCAThreshold.value);
        System.AssertEquals('NO', cusdetails.CPAThreshold.value);
        System.AssertEquals('E', cusdetails.sbuSegment.code.value);
        System.AssertEquals('N', cusdetails.inLiquidation.value);
        System.AssertEquals('NO', cusdetails.forensicHold.value);
        System.AssertEquals('N', cusdetails.underJudicialManagement.value);
        System.AssertEquals('N', cusdetails.financialCrime.value);
        System.AssertEquals('', cusdetails.inBusinessRescue.value);
        System.AssertEquals('N', cusdetails.inBusinessRescueAffectedParty.value);
        System.AssertEquals('0', cusdetails.placedInBusinessRescueBy.value);
        System.AssertEquals(null, cusdetails.casaReference.value);
        lscNewCaseExt.LocationInfo location = PrimaryClient.location;
        System.AssertEquals('EST 123', location.physicalAddress.addressName1.value);
        System.AssertEquals('', location.physicalAddress.addressName2.value);
        System.AssertEquals('', location.physicalAddress.suburbName.value);
        System.AssertEquals('JOHANNESBURG', location.physicalAddress.cityName.value);
        System.AssertEquals('2001', location.physicalAddress.postCodeArea.value);
        System.AssertEquals('', location.postalAddress.addressTypeCode.value);
        System.AssertEquals('20', location.businessAddress.addressType.value);
        System.AssertEquals('', location.headOfficeAddress.addressName1.value);
        lscNewCaseExt.ContactInfo contact = PrimaryClient.contact;
        System.AssertEquals('0619591240', contact.cellPhoneNumber.value);
        System.AssertEquals('01', contact.communicationChannelType.code.value);
        System.AssertEquals('', contact.workPhone.value);
        System.AssertEquals('(011) 5099090', contact.homePhone.value);
        System.AssertEquals('Pinal.Shah@absa.co.za', contact.eMailUserId.value);
        System.AssertEquals('', contact.contactPerson.value);
        System.AssertEquals(null, contact.designation.value);
        System.AssertEquals('(0) ', Mandates[2].contact.telephoneNumber.value);
        lscNewCaseExt.CorporateEntityInfo corporate = PrimaryClient.corporateEntity;
        System.AssertEquals('00;', corporate.incorporatedCountry.code.value);
        System.AssertEquals('00000', corporate.standardIndustryCode.code.value);
        System.AssertEquals('NO', PrimaryClient.customer.Details.CPAThreshold.value);
        System.AssertEquals('cif', PrimaryClient.meta.queryResult.sourceSystem);
        System.AssertEquals('related', PrimaryClient.meta.queryResult.type);
        lscNewCaseExt.IdentificationsInfo identification = PrimaryClient.identifications[0];
        System.AssertEquals('cif', identification.type.code);
        System.AssertEquals(null, identification.type.description);
        System.AssertEquals('MUZZIE 001', identification.numbers);
        System.AssertEquals(false, identification.personalIdentificationFlag);
        System.AssertEquals(false, identification.systemIdentificationFlag);
        System.AssertEquals('0001-01-01T00:00:00', identification.issueDate);
        System.AssertEquals('0001-01-01T00:00:00', identification.expiryDate);
        System.AssertEquals(null, identification.country);
        lscNewCaseExt.FlagInfo flags = PrimaryClient.flags;
        System.AssertEquals('True', flags.compliant.value);
        System.AssertEquals(null, flags.reason.code.value);
        lscNewCaseExt.AuthorityInfo authority = PrimaryClient.authority[0];
        System.AssertEquals('0', authority.signatoryDetails[0].product.accountNumber.value);
        System.AssertEquals('01/01/2000 00:00:00', authority.signatoryDetails[0].dateIssued.value);
        System.AssertEquals(null, authority.signatoryDetails[0].expiryDate.value);
        System.AssertEquals('0', authority.signatoryDetails[0].maximumAmount.value);
        System.AssertEquals(0, authority.signatoryDetails[0].maximumAmountFormatted);
        System.AssertEquals('G', authority.authorityTypeCode.value);
        System.AssertEquals('MUZZIE 001', authority.customerCode.value);
        System.AssertEquals('0', authority.accountNumber.value);
        System.AssertEquals('0', authority.changeTrackingNumber.value);
        System.AssertEquals('00;', authority.courtAuthorityCode.value);
        System.AssertEquals('0', authority.numberOfSignatures.value);
        System.AssertEquals('0', authority.employeeNumber.value);
        System.AssertEquals('00;', authority.originalCourtAuthorityCode.value);
        System.AssertEquals('0', authority.originalNumberOfSignatures.value);
        System.AssertEquals('', authority.originalSpecialConditions.value);
        System.AssertEquals('0', authority.overrideEmployeeNumber.value);
        System.AssertEquals('', authority.specialConditions.value);
        System.AssertEquals('NoChange', authority.status.value);
        System.AssertEquals(null, authority.changedSignatory.value);
        System.AssertEquals('General Power of Attorney', authority.authorityType.value);
        System.AssertEquals(null, PrimaryClient.links);
        
        
        Test.stopTest();
        
    } 
    
 

}