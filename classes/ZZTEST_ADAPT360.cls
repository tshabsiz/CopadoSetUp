/**
* @Author:        Dino Scarcella
* @Company:       Absa Capital
*
* @group Unit Tests
*
* @description Unit Tests for the class which returns all the data for the ADAPT360 VF page for 360 View of Client
*                   Tests executed:
*                   1 - testRetrieveClientDetails()
*                       Creates a mock REST call using the static resource (ADAPT360Response) and verifies all the properties
*                       are set correctly when the mock response is deserialized.
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* ---------------------------------------------------------------------------------------------------------------------------------------------------*/

@isTest
private class ZZTEST_ADAPT360 {
   @isTest(SeeAllData=true)
    static void testRetrieveClientDetails() {
        // Set query strings for the page
        ApexPages.currentPage().getParameters().put('queryType', 'cif');
        ApexPages.currentPage().getParameters().put('regId', 'MUZZIE 001');
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ADAPT360Response');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        ADAPT360 adpt360 = new ADAPT360();
        adpt360.runQueryFromURL();
        ADAPT360.ClientDetail PrimaryClient = adpt360.PrimaryClient;
        List<ADAPT360.ClientDetail> Mandates = adpt360.Mandates;
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
        ADAPT360.DocumentInfo idDoc = Mandates[2].individual.documentDetails.idDoc;
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
        ADAPT360.DocumentInfo addDoc = Mandates[2].individual.documentDetails.addDoc;
        System.AssertEquals(null, addDoc.casaTier.value);
        System.AssertEquals('01/09/1983 00:00:00', Mandates[2].individual.birthDate.value);
        System.AssertEquals('SO003', Mandates[2].individual.countryOfOrigin.code.value);
        System.AssertEquals('SO003', Mandates[2].individual.countryOfResidence.code.value);
        ADAPT360.AccountInfo account = PrimaryClient.account[0];
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
        ADAPT360.CustomerDetailsInfo cusdetails = PrimaryClient.customerDetails;
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
        ADAPT360.LocationInfo location = PrimaryClient.location;
        System.AssertEquals('EST 123', location.physicalAddress.addressName1.value);
        System.AssertEquals('', location.physicalAddress.addressName2.value);
        System.AssertEquals('', location.physicalAddress.suburbName.value);
        System.AssertEquals('JOHANNESBURG', location.physicalAddress.cityName.value);
        System.AssertEquals('2001', location.physicalAddress.postCodeArea.value);
        System.AssertEquals('', location.postalAddress.addressTypeCode.value);
        System.AssertEquals('20', location.businessAddress.addressType.value);
        System.AssertEquals('', location.headOfficeAddress.addressName1.value);
        ADAPT360.ContactInfo contact = PrimaryClient.contact;
        System.AssertEquals('0619591240', contact.cellPhoneNumber.value);
        System.AssertEquals('01', contact.communicationChannelType.code.value);
        System.AssertEquals('', contact.workPhone.value);
        System.AssertEquals('(011) 5099090', contact.homePhone.value);
        System.AssertEquals('Pinal.Shah@absa.co.za', contact.eMailUserId.value);
        System.AssertEquals('', contact.contactPerson.value);
        System.AssertEquals(null, contact.designation.value);
        System.AssertEquals('(0) ', Mandates[2].contact.telephoneNumber.value);
        ADAPT360.CorporateEntityInfo corporate = PrimaryClient.corporateEntity;
        System.AssertEquals('00;', corporate.incorporatedCountry.code.value);
        System.AssertEquals('00000', corporate.standardIndustryCode.code.value);
        System.AssertEquals('NO', PrimaryClient.customer.Details.CPAThreshold.value);
        System.AssertEquals('cif', PrimaryClient.meta.queryResult.sourceSystem);
        System.AssertEquals('related', PrimaryClient.meta.queryResult.type);
        ADAPT360.IdentificationsInfo identification = PrimaryClient.identifications[0];
        System.AssertEquals('cif', identification.type.code);
        System.AssertEquals(null, identification.type.description);
        System.AssertEquals('MUZZIE 001', identification.numbers);
        System.AssertEquals(false, identification.personalIdentificationFlag);
        System.AssertEquals(false, identification.systemIdentificationFlag);
        System.AssertEquals('0001-01-01T00:00:00', identification.issueDate);
        System.AssertEquals('0001-01-01T00:00:00', identification.expiryDate);
        System.AssertEquals(null, identification.country);
        ADAPT360.FlagInfo flags = PrimaryClient.flags;
        System.AssertEquals('True', flags.compliant.value);
        System.AssertEquals(null, flags.reason.code.value);
        ADAPT360.AuthorityInfo authority = PrimaryClient.authority[0];
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
    }
    
    @isTest(SeeAllData=true)
    static void testSearchSalesforceAccounts() {
        
        CSC_TestDataFactory.testDataSize = 1;
    	Case thecase = CSC_TestDataFactory.getTestCaseList('CSC Emails', UserInfo.getUserId())[0];
        insert thecase;
        
        list<Account> accList = CSC_TestDataFactory.getTestAccountList('Client');
        accList[0].CIF__c = 'RRR  001';
        insert accList[0];
        
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ADAPT360Response');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
        
        ApexPages.StandardController stdController = new ApexPages.StandardController(thecase);
        ADAPT360 adpt360case = new ADAPT360(stdcontroller);
        adpt360case.runQueryFromURL();
        adpt360case.rel = [Select Id , CIF__c From Account Where CIF__c = 'RRR  001'];
        adpt360case.qType = 'cif';
        adpt360case.searchSalesforceAccounts(); 
        adpt360case.qType = 'cif2cif';
        adpt360case.searchSalesforceAccounts();
        adpt360case.cifName = 'RRR  001,TTT  002';
        adpt360case.cifSelection();
        adpt360case.rel = [Select Id , Name, CIF__c From Account Where CIF__c = 'RRR  001'];
        adpt360case.rel[0].CIF__c = 'RRR  001,TTT  002';
        update adpt360case.rel;
        adpt360case.relName = adpt360case.rel[0].Name;
        adpt360case.accountSelection();
    }
}