/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/

*/
public class HotDocs_Interview extends HotDocs_Service
{
    public static Map <String, Schema.RecordTypeInfo> agreementTemplateRecordTypes = Agreement_Template__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public static Map <String, Schema.RecordTypeInfo> agreementRecordTypes = Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName(); 
    public String interviewUrl { get; set; }
    public String answerSetId { get; set; }
    public String agreementId { get; set; }
    public String supportingAgreementId { get; set; }
    public Agreement__c agreement { get; set; }
    public Supporting_Agreement__c supportingAgreement { get; set; }
    public String hotDocsTemplateId { get; set; } 
    public Boolean hasError { get; set; }
    public List<partiesWrapper> partiesWrapperList { get; set; }

    public HotDocs_Interview()
    {
        System.debug('### HotDocs_Interview : SETTINGS :'+SETTINGS);

        //Blank vars
        List<HotDocs_Request__c> existingRequests = new List<HotDocs_Request__c>();
        partiesWrapperList = new List<partiesWrapper> ();
        
        //Default values.
        hasError = false;

        try
        {
            //Agreement ID passed as a param.
            if(ApexPages.currentPage().getParameters().get('id') != null)
            {
                agreementId = ApexPages.currentPage().getParameters().get('id');
            }
            
            //Libra - Supporting Agreement Id as a param
            if(ApexPages.currentPage().getParameters().get('csaId') != null)
            {
                supportingAgreementId = ApexPages.currentPage().getParameters().get('csaId');
            }

             //Get Agreement Record for additional fields
            List<Agreement__c> agreements = [
                SELECT
                Id,
                Matter_Deal__c,
                Agreement_Status__c,
                Facility_Loan_Name__r.Name,
                Facility_Loan_Date__c,
                Loan_Name__c,
                Governing_Law__c,
                Loan_Linked__c,
                Matter_Deal__r.Relationship__c,
                Matter_Deal__r.Relationship__r.Name,
                Matter_Deal__r.Relationship_Type_picklist__c,
                Matter_Deal__r.Counterparty_Type__c,
                Matter_Deal__r.Collective_Investment_Scheme_Name__c,
                Matter_Deal__r.Collective_Investment_Scheme_Name__r.Name,
                Matter_Deal__r.Prime_Services_Client__c,
                Matter_Deal__r.Collective_Investment_Scheme_Type__c,
                Matter_Deal__r.Count_Asset_Manager__c,
                Agreement_Template__r.RecordTypeId,
                Agreement_Template__r.HotDocs_Template_ID__c,
                Agreement_Template__r.Facility_Type__c,
                Agreement_Template__r.Facility_Interest_Rate_Type__c,
                Last_HotDocs_Answer_Set_ID__c,
                Master_Agreement_Type__c,
                recordTypeId
                FROM Agreement__c
                WHERE
                Id = :agreementId
            ]; 
            
            //Get Supporting Agreement Record
            List<Supporting_Agreement__c> supportingAgreements = [
                SELECT
                Id,
                Agreement_Template__r.RecordTypeId,
                Agreement_Template__r.HotDocs_Template_ID__c,
                Agreement_Template__r.Facility_Type__c,
                Agreement_Template__r.Facility_Interest_Rate_Type__c,
                Agreement__r.Matter_Deal__r.Collective_Investment_Scheme_Name__r.Name,
                Last_HotDocs_Answer_Set_ID__c,
                Supporting_Agreement_Type__c,
                recordTypeId
                FROM Supporting_Agreement__c
                WHERE
                Id = :supportingAgreementId
            ]; 

            
            //Make sure we found an agreement.
            if(agreements.size() > 0)
            {
                agreement = agreements[0];

                //Libra - Make sure we found a Supporting Agreement
                if(supportingAgreements.size() > 0)
                {
                    supportingAgreement = supportingAgreements[0];
                    hotDocsTemplateId = supportingAgreements[0].Agreement_Template__r.HotDocs_Template_ID__c;
                }
                else
                {
                    hotDocsTemplateId = agreements[0].Agreement_Template__r.HotDocs_Template_ID__c;
                }
                
                partiesWrapperList = new List<partiesWrapper>();
                
                //LIBRA - Get all Deal Parties if Agreement Templates is "Agreement Template - Master" 
                if(agreement.Agreement_Template__r.RecordTypeId == agreementTemplateRecordTypes.get('Agreement Template - Master').getRecordTypeId())
                {
                    if((agreement.Agreement_Status__c == 'Confirmed/Completed' || agreement.Agreement_Status__c == 'Amended') && agreement.Agreement_Template__r.RecordTypeId == agreementTemplateRecordTypes.get('Agreement Template - Master').getRecordTypeId())
                    {
                    	throw new HotDocs_API_Exception('You are not allowed to regenerated the HotDocs Interview if the Agreement is "Confirmed/Completed" or "Amended"');   
                    }
                    
                    for(Deal_Party__c eachDealParty : [SELECT Id,
                                                       Deal__c,
                                                       hAuto_Created__c,
                                                       Relationship__c,
                                                       Relationship__r.Name,
                                                       Relationship_Type__c,
                                                       Relationship__r.BillingStreet,
                                                       Relationship__r.BillingCity, 
                                                       Relationship__r.BillingState, 
                                                       Relationship__r.BillingCountry,
                                                       Relationship__r.BillingPostalCode,
                                                       Relationship__r.Registration_Number__c 
                                                       FROM Deal_Party__c
                                                       WHERE Deal__c = :agreement.Matter_Deal__c] )
                    {
                        partiesWrapper partyWrapperItem = new partiesWrapper();
                        partyWrapperItem.partyId = eachDealParty.id;
                        partyWrapperItem.relationshipName = eachDealParty.Relationship__r.Name;
                        partyWrapperItem.partyType = eachDealParty.Relationship_Type__c; 
                        partyWrapperItem.agreementTemplateType = 'Master';
                        partyWrapperItem.partyB = eachDealParty.hAuto_Created__c;
                        partyWrapperItem.relationshipBillingStreet = eachDealParty.Relationship__r.BillingStreet;
                        partyWrapperItem.relationshipBillingCity = eachDealParty.Relationship__r.BillingCity;
                        partyWrapperItem.relationshipBillingState = eachDealParty.Relationship__r.BillingState;
                        partyWrapperItem.relationshipBillingCountry = eachDealParty.Relationship__r.BillingCountry;
                        partyWrapperItem.relationshipBillingPostalCode = eachDealParty.Relationship__r.BillingPostalCode;
                        partyWrapperItem.relationshipRegistrationNumber = eachDealParty.Relationship__r.Registration_Number__c;

                        System.debug('partyWrapperItem : '+partyWrapperItem);

                        partiesWrapperList.add(partyWrapperItem);
                    }
                }
                //TMG and LEAP - Get all Agreement Parties
                else
                {
                    for(Agreement_Party__c eachAgreementParty : [SELECT  Id,
                                                                 Agreement__c,
                                                                 Relationship__c,
                                                                 Party_Type__c,
                                                                 Deal_Party__r.Relationship__r.BillingStreet,
                                                                 Deal_Party__r.Relationship__r.BillingCity, 
                                                                 Deal_Party__r.Relationship__r.BillingState, 
                                                                 Deal_Party__r.Relationship__r.BillingCountry,
                                                                 Deal_Party__r.Relationship__r.BillingPostalCode,
                                                                 Deal_Party__r.Relationship__r.Registration_Number__c 
                                                                 FROM Agreement_Party__c
                                                                 WHERE Agreement__c = :agreement.Id] )
                    {
                        partiesWrapper partyWrapperItem = new partiesWrapper();
                        partyWrapperItem.partyId = eachAgreementParty.id;
                        partyWrapperItem.relationshipName = eachAgreementParty.Relationship__c;
                        partyWrapperItem.partyType = eachAgreementParty.Party_Type__c;
                        partyWrapperItem.agreementTemplateType = 'Other';
                        partyWrapperItem.relationshipBillingStreet = eachAgreementParty.Deal_Party__r.Relationship__r.BillingStreet;
                        partyWrapperItem.relationshipBillingCity = eachAgreementParty.Deal_Party__r.Relationship__r.BillingCity;
                        partyWrapperItem.relationshipBillingState = eachAgreementParty.Deal_Party__r.Relationship__r.BillingState;
                        partyWrapperItem.relationshipBillingCountry = eachAgreementParty.Deal_Party__r.Relationship__r.BillingCountry;
                        partyWrapperItem.relationshipBillingPostalCode = eachAgreementParty.Deal_Party__r.Relationship__r.BillingPostalCode;
                        partyWrapperItem.relationshipRegistrationNumber = eachAgreementParty.Deal_Party__r.Relationship__r.Registration_Number__c;
                        partiesWrapperList.add(partyWrapperItem);
                    }
                }
                
                existingRequests = [
                    SELECT
                    Id,
                    Status__c 
                    FROM HotDocs_Request__c
                    WHERE
                    Agreement__c = :agreement.Id 
                    AND (
                        Status__c = 'Queued'
                        OR (Status__c = 'Failed' AND Attempts__c < :SETTINGS.Attempts_Limit__c)
                    )
                ];

                if(existingRequests.size() > 0) 
                {
                    throw new HotDocs_API_Exception('There is a pending HotDocs Request for this Agreement.  Please try again in a few minutes.');
                }
            }
            else
            {
                throw new HotDocs_API_Exception('Unable to locate an Agreement for this requests.'); 
            }

            if(hotDocsTemplateId == null) 
            {
                throw new HotDocs_API_Exception('There is no HotDocs Template associated with this agreement.');
            } 
        }
        catch(Exception e)
        {
            hasError = true;
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()) );
        }
    }

    public PageReference actionLaunchInterview() 
    {
        //Only exeucte if there is a hotdocs template id.
        if(hotDocsTemplateId != null)
        {
            try
            {
                HotDocs_API api = new HotDocs_API();
                HotDocs_AnswerSet answerData = new HotDocs_AnswerSet();
                //Use buildAnswerFile() for TMG
                //Use buildLibraAnswerFile() for Libra as its more complex than TMG and involves more templates (ISDA, GMSLA, GIMRA and Prime Services)
                 
                if(supportingAgreement != null && supportingAgreement.Agreement_Template__r.RecordTypeId == agreementTemplateRecordTypes.get('Agreement Template - Master').getRecordTypeId())
                {
                    answerData  = buildCsaAnswerFile();
                }
                else if(agreement.Agreement_Template__r.RecordTypeId == agreementTemplateRecordTypes.get('Agreement Template - Master').getRecordTypeId())
                { 
                    //Prime Services
                    if(agreement.Master_Agreement_Type__c == 'Prime Services Agreement')
                    {
                        answerData  = buildPrimeServicesAnswerFile();
                    }
                    //GMSLA
                    else if(agreement.Master_Agreement_Type__c == 'GMSLA Agreement')
                    {
                        answerData  = buildGmslaAnswerFile();
                    }
                    //GMRA
                    else if(agreement.Master_Agreement_Type__c == 'GMRA Agreement')
                    {
                        answerData  = buildGmslaAnswerFile();
                    }
                    //ISDA
                    else if(agreement.Master_Agreement_Type__c == 'ISDA Agreement')
                    {
                        answerData  = buildIsdaAnswerFile();
                    }                   
                }
                else
                {
                    answerData  = buildAnswerFile();
                }

                //Supporting agreement.
                if(supportingAgreement != null)
                {
                    if(String.isBlank(supportingAgreement.Last_HotDocs_Answer_Set_ID__c))
                    {
                        answerSetId = api.createAnswerSet('Sample Title', 'Sample Description', answerData);
                    }
                    else
                    {
                        answerSetId = supportingagreement.Last_HotDocs_Answer_Set_ID__c;
                        //Overlay new data with existing answer set data.
                		api.createAnswerSetOverlay(answerSetId, 'Sample Title', 'Sample Description', answerData);
                    }  
                }
                //Agreement
                else
                {
                    if(String.isBlank(agreement.Last_HotDocs_Answer_Set_ID__c))
                    {
                        answerSetId = api.createAnswerSet('Sample Title', 'Sample Description', answerData);
                    }
                    else
                    {
                        answerSetId = agreement.Last_HotDocs_Answer_Set_ID__c;

                        //Overlay new data with existing answer set data.
                		api.createAnswerSetOverlay(answerSetId, 'Sample Title', 'Sample Description', answerData);
                    } 
                }

                //Get url from embedded API to serve interview.
                interviewUrl = api.getInterviewUrl(hotDocsTemplateId, answerSetId);

                //Have we set to store answer file?
                if(SETTINGS.Keep_Answer_File__c == true)
                {
                    Attachment attachment = new Attachment();
                    attachment.Body = Blob.valueOf(answerData.getXmlDocument()); 
                    attachment.Name = 'Sent-AnswerFile.xml';
                    if(supportingAgreementId != null)
                    {
                        attachment.ParentId = supportingAgreementId; 
                    }
                    else
                    {
                        attachment.ParentId = agreementId; 
                    }
                    
                    insert attachment;
                }
            }
            catch(Exception e)  
            {
                hasError = true;
                DebugLog.create( new DebugLog.Error(e, 'HotDocs_Interview', 'actionLaunchInterview') );             
                ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()) );
            }
        }

        //Default.
        return null;
    }

    public HotDocs_AnswerSet buildAnswerFile()
    {   
        //Answer Set
        HotDocs_AnswerSet answerSet = new HotDocs_AnswerSet();

        /**
        * PARTIES
        **/
        //Lists
        List<IHotDocs_Answer> partyNames        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRoles        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRolesMc      = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyTypes        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyAddresses    = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRegNos       = new List<IHotDocs_Answer>();

        //Dev Mode Settings for Answer XML
        answerSet.add( new HotDocs_Answer_Generic('NUM', 'PRC_Party_Role_UAT_Switch-n', SETTINGS.Interview_Development_Mode__c == false ? '0' : '1') );
        
        //First Party is ABSA, so need to add blank.
        partyNames.add( new HotDocs_Answer_Generic('TEXT', '', '') );
        partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Lender'));
        partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Lender') ) );
        partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Closed Corporation') ) ); 
        partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', '') ); 
        partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', '') );

        if(!partiesWrapperList.isEmpty())
        {
            for(partiesWrapper eachWrapper :partiesWrapperList)
            {
                if(eachWrapper.agreementTemplateType != 'Master')
                {
                    partyNames.add( new HotDocs_Answer_Generic('TEXT', '', eachWrapper.relationshipName) );
                    partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', eachWrapper.partyType));
                    partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', eachWrapper.partyType) ) );
                    partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Closed Corporation') ) );
                } 
                
                partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', (!String.isBlank(eachWrapper.relationshipRegistrationNumber)) ? eachWrapper.relationshipRegistrationNumber : '') );
                
                //Compounded Address Details
                String address = '';
                address += (!String.isBlank(eachWrapper.relationshipBillingStreet)) ? eachWrapper.relationshipBillingStreet+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCity)) ? eachWrapper.relationshipBillingCity+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingState)) ? eachWrapper.relationshipBillingState+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCountry)) ? eachWrapper.relationshipBillingCountry+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingPostalCode)) ? eachWrapper.relationshipBillingPostalCode : '';
                
                partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', address) );
            }
        }
        
        //Add answers.
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullName-t', partyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullNameVariable-t', partyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-t', partyRoles));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-mc', PartyRolesMc));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyEntityType-mc', partyTypes));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyPhysicalAddress-t', partyAddresses));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRegistration/IdentityNo-t', partyRegNos));

        /**
        * FACILTTY TYPE AND INTEREST
        **/ 
        if(agreement.Agreement_Template__r.Facility_Type__c != null)
        {
            answerSet.add(new HotDocs_Answer_Multi('Loan_Type-mc', new HotDocs_Answer_Generic('SELECT', '', agreement.Agreement_Template__r.Facility_Type__c) ) );
        }

        if(agreement.Agreement_Template__r.Facility_Interest_Rate_Type__c != null)
        {
            answerSet.add( new HotDocs_Answer_Multi('Loan_Interest_Rate_Type-mc', new HotDocs_Answer_Generic('SELECT', '', agreement.Agreement_Template__r.Facility_Interest_Rate_Type__c) ) );
        }

        System.debug('### Answer XML:'+answerSet.getXmlDocument());

        //Final XML
        return answerSet; 
    }
    
    public HotDocs_AnswerSet buildIsdaAnswerFile()
    {   
        //Answer Set
        HotDocs_AnswerSet answerSet = new HotDocs_AnswerSet();

        /**
        * PARTIES
        **/
        //Lists
        List<IHotDocs_Answer> partyNames        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRoles        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRolesMc      = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyTypes        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyAddresses    = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRegNos       = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> subPartyNames     = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> subPartyRoles     = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> subPartyRoles_Mc  = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> subSpecifiedEntityPartyA_Mc   = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> subSpecifiedEntityPartyB_Mc   = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> subMultiBranchPartyA_Tf   = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> subMultiBranchPartyB_Tf   = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> clientType_Mc = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> agreementType_Mc  = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> facilityAgreement_Tf  = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> facilityAgreementName = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> facilityAgreementDate_Dt  = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> collectiveInvestmentName  = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> representedByAgent  = new List<IHotDocs_Answer>();

        //Dev Mode Settings for Answer XML
        answerSet.add( new HotDocs_Answer_Generic('NUM', 'PRC_Party_Role_UAT_Switch-n', SETTINGS.Interview_Development_Mode__c == false ? '0' : '1') );
        
        //Libra : ISDA Agreement
        if(agreement.Agreement_Template__r.RecordTypeId == agreementTemplateRecordTypes.get('Agreement Template - Master').getRecordTypeId())
        {
            partyNames.add( new HotDocs_Answer_Generic('TEXT', '', '') );
            partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Party A'));
            partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party A') ) );
            partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party A') ) ); 
            partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', '') ); 
            partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', '') );
            clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'None')));
            agreementType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'South Africa Template')));
            collectiveInvestmentName.add( new HotDocs_Answer_Generic('TEXT', '', '') );
            representedByAgent.add( new HotDocs_Answer_Generic('BOOL', '', '') );

            //Loan Linked + Facility Details
            if(agreement.Loan_Linked__c == 'Yes') {  

                facilityAgreement_Tf.add( new HotDocs_Answer_Generic('BOOL', '', '1'));
                answerSet.add(new HotDocs_Answer_Repeat('Facility_Agreement-tf', facilityAgreement_Tf));

                if(agreement.Facility_Loan_Name__r.Name != null) {
                    facilityAgreementName.add( new HotDocs_Answer_Generic('TEXT', '', agreement.Facility_Loan_Name__r.Name) );
                    answerSet.add(new HotDocs_Answer_Repeat('Facility_Agreement_Name-t', facilityAgreementName));
                }               

                if(agreement.Facility_Loan_Date__c != null) {
                    facilityAgreementDate_Dt.add( new HotDocs_Answer_Generic('DATE', '',agreement.Facility_Loan_Date__c));
                    answerSet.add(new HotDocs_Answer_Repeat('Facility_Agreement_Date-dt', facilityAgreementDate_Dt));
                }
            }
            else {
                facilityAgreement_Tf.add( new HotDocs_Answer_Generic('BOOL', '', '0'));
            }         
            
            //Client Type - Create ISDA for on HotDocs Template (Party B)
            if(agreement.Matter_Deal__r.Relationship_Type_picklist__c == 'Asset Manager' || agreement.Matter_Deal__r.Relationship_Type_picklist__c == 'Collective Investment Scheme Manager')
            {
                clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', agreement.Matter_Deal__r.Relationship_Type_picklist__c)));

                if(agreement.Matter_Deal__r.Collective_Investment_Scheme_Name__c != null)
                {
                    collectiveInvestmentName.add( new HotDocs_Answer_Generic('TEXT', '', agreement.Matter_Deal__r.Collective_Investment_Scheme_Name__r.Name) ); 
                }
                answerSet.add(new HotDocs_Answer_Repeat('PRC_Collective_Investment_Scheme_Name-t', collectiveInvestmentName));
            }
            else if(agreement.Matter_Deal__r.Relationship_Type_picklist__c == 'Counterparty')
            {
                clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', agreement.Matter_Deal__r.Counterparty_Type__c)));
            }
            
            answerSet.add(new HotDocs_Answer_Repeat('PRC_Client_Type-mc', clientType_Mc));
            answerSet.add(new HotDocs_Answer_Repeat('Agreement_Type-mc', agreementType_Mc));
        }


        if(!partiesWrapperList.isEmpty())
        {
            for(partiesWrapper eachWrapper : partiesWrapperList)
            {
                //Libra
                if(eachWrapper.agreementTemplateType == 'Master')
                {
                    subPartyNames.add( new HotDocs_Answer_Generic('TEXT', '', eachWrapper.relationshipName) );
                    subPartyRoles.add( new HotDocs_Answer_Generic('TEXT', '', eachWrapper.partyType));
                    subPartyRoles_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', eachWrapper.partyType) ) );

                    //Specific Entity Party A
                    if(eachWrapper.partyType == 'Specified Entity Bank') 
                    {
                        subSpecifiedEntityPartyA_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Specific Entities')));
                    }
                    //Specific Entity Party B
                    else if (eachWrapper.partyType == 'Specified Entity Counterparty')
                    {
                        subSpecifiedEntityPartyB_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Specific Entities')));
                    }
                    //Multi-Branch Party A
                    else if (eachWrapper.partyType == 'Bank Branch')
                    {
                        subMultiBranchPartyA_Tf.add( new HotDocs_Answer_Generic('BOOL', '', '1'));
                    }
                    //Multi-Branch Party B
                    else if (eachWrapper.partyType == 'Counterparty Branch')
                    {
                        subMultiBranchPartyB_Tf.add(new HotDocs_Answer_Generic('BOOL', '', '1'));
                    }
                    
                    //ASSET MANAGER PARTY
                    //Relationship Type = Asset Manager, representBy agent = No.
                    //Relationship Type = Counter Party, Add Ässet Manager via deal parties, then representBy agent = Yes.
                    //Relationship Type = Counter Party, no Asset Manager agent = No. 

                    if(eachWrapper.partyType == 'Asset Manager') {

                        //General details
                        partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', (!String.isBlank(eachWrapper.relationshipRegistrationNumber)) ? eachWrapper.relationshipRegistrationNumber : '') );
                        partyNames.add( new HotDocs_Answer_Generic('TEXT', '', eachWrapper.relationshipName) );

                        //No agent representation on both cases.
                        representedByAgent.add(new HotDocs_Answer_Generic('BOOL', '', '0') );

                        //Is Party B
                        if(eachWrapper.partyB == true) {
                            partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Party B'));
                            partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party B') ) );
                            partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party B') )) ;
                        }
                        //No Party B.
                        else if(eachWrapper.partyB == false) {                            
                            partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Agent')); 
                            partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Agent') ) );
                            partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Agent') )) ;                            
                        }
                    }
                    else if (eachWrapper.partyB == true && eachWrapper.partyType != 'Asset Manager') {
                        partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', (!String.isBlank(eachWrapper.relationshipRegistrationNumber)) ? eachWrapper.relationshipRegistrationNumber : '') );
                        partyNames.add( new HotDocs_Answer_Generic('TEXT', '', eachWrapper.relationshipName) );
                        partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Party B'));  
                        partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party B') ) );
                        partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party B') )) ;

                        if(agreement.Matter_Deal__r.Count_Asset_Manager__c > 0) {
                            representedByAgent.add(new HotDocs_Answer_Generic('BOOL', '', '1') );
                        }
                    }
                }
                  
                partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', (!String.isBlank(eachWrapper.relationshipRegistrationNumber)) ? eachWrapper.relationshipRegistrationNumber : '') );
                  
                //Compounded Address Details
                String address = '';
                address += (!String.isBlank(eachWrapper.relationshipBillingStreet)) ? eachWrapper.relationshipBillingStreet+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCity)) ? eachWrapper.relationshipBillingCity+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingState)) ? eachWrapper.relationshipBillingState+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCountry)) ? eachWrapper.relationshipBillingCountry+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingPostalCode)) ? eachWrapper.relationshipBillingPostalCode : '';
                  
                partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', address) );
            }
        }

        //Add answers.
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullName-t', partyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullNameVariable-t', partyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-t', partyRoles));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-mc', PartyRolesMc));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyEntityType-mc', partyTypes));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyPhysicalAddress-t', partyAddresses));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRegistration/IdentityNo-t', partyRegNos));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_Sub_Party_Fullname-t', subPartyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_Sub_Party_Role-t', subPartyRoles));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_Sub_Party_Role-mc', subPartyRoles_Mc));
        answerSet.add(new HotDocs_Answer_Repeat('Party_A_Specified_Entities-mc', subSpecifiedEntityPartyA_Mc));
        answerSet.add(new HotDocs_Answer_Repeat('Party_B_Specified_Entities-mc', subSpecifiedEntityPartyB_Mc));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_Party_Multi_Branch_Party_A-tf', subMultiBranchPartyA_Tf));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_Party_Multi_Branch_Party_B-tf', subMultiBranchPartyB_Tf));

        answerSet.add(new HotDocs_Answer_Repeat('Represented_By_Agent-tf', representedByAgent));

        /**
        * FACILTTY TYPE AND INTEREST
        **/ 
        if(agreement.Agreement_Template__r.Facility_Type__c != null)
        {
            answerSet.add(new HotDocs_Answer_Multi('Loan_Type-mc', new HotDocs_Answer_Generic('SELECT', '', agreement.Agreement_Template__r.Facility_Type__c) ) );
        }

        if(agreement.Agreement_Template__r.Facility_Interest_Rate_Type__c != null)
        {
            answerSet.add( new HotDocs_Answer_Multi('Loan_Interest_Rate_Type-mc', new HotDocs_Answer_Generic('SELECT', '', agreement.Agreement_Template__r.Facility_Interest_Rate_Type__c) ) );
        }

        System.debug('### Answer XML:'+answerSet.getXmlDocument());

        //Final XML
        return answerSet; 
    }
    
    public HotDocs_AnswerSet buildPrimeServicesAnswerFile()
    {   
        System.debug('buildPrimeServicesAnswerFile');

        //Answer Set
        HotDocs_AnswerSet answerSet = new HotDocs_AnswerSet();

        //Lists
        List<IHotDocs_Answer> partyNames        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRoles        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRolesMc      = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyTypes        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyAddresses    = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRegNos       = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> clientType_Mc = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> schemeType_Mc = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> schemeName = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> collectiveInvestmentName = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> onbehalfCollectiveInvestment = new List<IHotDocs_Answer>();

        //Dev Mode Settings for Answer XML
        answerSet.add( new HotDocs_Answer_Generic('NUM', 'PRC_Party_Role_UAT_Switch-n', SETTINGS.Interview_Development_Mode__c == false ? '0' : '1') );
        
        //Party A - ABSA is always the Lender - set default
        partyNames.add( new HotDocs_Answer_Generic('TEXT', '', '') );
        partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Lender'));
        partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Lender') ) );
        partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Lender') ) ); 
        partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', '') ); 
        partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', 'None') );  
        schemeType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'None') ) );
        schemeName.add( new HotDocs_Answer_Generic('TEXT', '', '') );
        collectiveInvestmentName.add( new HotDocs_Answer_Generic('TEXT', '', '') ); 
        
        //Collective Investment Scheme Manager
        if(agreement.Matter_Deal__r.Relationship_Type_picklist__c == 'Collective Investment Scheme Manager')
        {
            onbehalfCollectiveInvestment.add(new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Yes')));
            schemeType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', agreement.Matter_Deal__r.Collective_Investment_Scheme_Type__c) ) );
            schemeName.add( new HotDocs_Answer_Generic('TEXT', '', agreement.Matter_Deal__r.Collective_Investment_Scheme_Name__r.Name) );

            if(agreement.Matter_Deal__r.Prime_Services_Client__c == 'Yes') {
                clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Prime Services Client')));
                
            }
            else if (agreement.Matter_Deal__r.Prime_Services_Client__c == 'No') {
                clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Non-Prime Services Client')));
            }
        }
        //CounterParty
        else if(agreement.Matter_Deal__r.Relationship_Type_picklist__c == 'Counterparty' && agreement.Matter_Deal__r.Prime_Services_Client__c == 'No')
        {
            onbehalfCollectiveInvestment.add(new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'No')));

            clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Non-Prime Services Client')));
        }
        else {
            onbehalfCollectiveInvestment.add(new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'No')));
        }

        if(!partiesWrapperList.isEmpty())
        {
            for(partiesWrapper eachWrapper :partiesWrapperList)
            {
                partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Counterparty'));  
                partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Counterparty') ) );
                partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Counterparty') )) ; 
 
                if(agreement.Matter_Deal__r.Collective_Investment_Scheme_Name__c != null)
                {
                    collectiveInvestmentName.add( new HotDocs_Answer_Generic('TEXT', '', agreement.Matter_Deal__r.Collective_Investment_Scheme_Name__r.Name) ); 
                }
                
                partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', (!String.isBlank(eachWrapper.relationshipRegistrationNumber)) ? eachWrapper.relationshipRegistrationNumber : '') );
                partyNames.add( new HotDocs_Answer_Generic('TEXT', '', eachWrapper.relationshipName));
                
                //Compounded Address Details
                String address = '';
                address += (!String.isBlank(eachWrapper.relationshipBillingStreet)) ? eachWrapper.relationshipBillingStreet+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCity)) ? eachWrapper.relationshipBillingCity+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingState)) ? eachWrapper.relationshipBillingState+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCountry)) ? eachWrapper.relationshipBillingCountry+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingPostalCode)) ? eachWrapper.relationshipBillingPostalCode : '';
                
                partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', address) ); 
            }
        }

        //Add answers.
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullName-t', partyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullNameVariable-t', partyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-t', partyRoles));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-mc', PartyRolesMc));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyEntityType-mc', partyTypes));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyPhysicalAddress-t', partyAddresses));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRegistration/IdentityNo-t', partyRegNos));
        answerSet.add(new HotDocs_Answer_Repeat('Client_Type-mc', clientType_Mc));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyCollectiveInvestmentSchemeType-mc', schemeType_Mc));
        answerSet.add(new HotDocs_Answer_Repeat('Collective_Investment_Scheme_Name-t', collectiveInvestmentName));
        answerSet.add(new HotDocs_Answer_Repeat('Collective_Investment_Scheme_Yes_No-mc', onbehalfCollectiveInvestment));

        //Final XML
        return answerSet; 
    }

    public HotDocs_AnswerSet buildGmslaAnswerFile()
    {   
        //Answer Set
        HotDocs_AnswerSet answerSet = new HotDocs_AnswerSet();

        /**
        * PARTIES
        **/
        //Lists
        List<IHotDocs_Answer> partyNames        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRoles        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRolesMc      = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyTypes        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyAddresses    = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRegNos       = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> clientType_Mc = new List<IHotDocs_Answer>();

        //Dev Mode Settings for Answer XML
        answerSet.add( new HotDocs_Answer_Generic('NUM', 'PRC_Party_Role_UAT_Switch-n', SETTINGS.Interview_Development_Mode__c == false ? '0' : '1') );
        
        //Libra : ISDA Agreement
        if(agreement.Agreement_Template__r.RecordTypeId == agreementTemplateRecordTypes.get('Agreement Template - Master').getRecordTypeId())
        {
            partyNames.add( new HotDocs_Answer_Generic('TEXT', '', '') );
            partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Party A'));
            partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party A') ) );
            partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party A') ) ); 
            partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', '') ); 
            partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', '') );
            clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'None')));
            
            //Client Type - Create ISDA for on HotDocs Template (Party B)
            if(agreement.Matter_Deal__r.Relationship_Type_picklist__c == 'Asset Manager' || agreement.Matter_Deal__r.Relationship_Type_picklist__c == 'Collective Investment Scheme Manager')
            {
                clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', agreement.Matter_Deal__r.Relationship_Type_picklist__c)));
            }
            else if(agreement.Matter_Deal__r.Relationship_Type_picklist__c == 'Counterparty')
            {
                clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', agreement.Matter_Deal__r.Counterparty_Type__c)));
            }
            
            answerSet.add(new HotDocs_Answer_Repeat('PRC_Client_Type-mc', clientType_Mc));
        }

        if(!partiesWrapperList.isEmpty())
        {
            for(partiesWrapper eachWrapper :partiesWrapperList)
            {
                //Libra
                if(eachWrapper.agreementTemplateType == 'Master')
                {
                    partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', (!String.isBlank(eachWrapper.relationshipRegistrationNumber)) ? eachWrapper.relationshipRegistrationNumber : '') );
                    partyNames.add( new HotDocs_Answer_Generic('TEXT', '', eachWrapper.relationshipName) );
                    partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Party B'));  
                    partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party B') ) );
                    partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party B') )) ;
                }
                  
                partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', (!String.isBlank(eachWrapper.relationshipRegistrationNumber)) ? eachWrapper.relationshipRegistrationNumber : '') );
                  
                //Compounded Address Details
                String address = '';
                address += (!String.isBlank(eachWrapper.relationshipBillingStreet)) ? eachWrapper.relationshipBillingStreet+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCity)) ? eachWrapper.relationshipBillingCity+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingState)) ? eachWrapper.relationshipBillingState+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCountry)) ? eachWrapper.relationshipBillingCountry+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingPostalCode)) ? eachWrapper.relationshipBillingPostalCode : '';
                  
                partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', address) );  
              }
          }

        //Add answers.
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullName-t', partyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullNameVariable-t', partyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-t', partyRoles));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-mc', PartyRolesMc));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyEntityType-mc', partyTypes));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyPhysicalAddress-t', partyAddresses));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRegistration/IdentityNo-t', partyRegNos));

        /**
        * FACILTTY TYPE AND INTEREST
        **/ 
        if(agreement.Agreement_Template__r.Facility_Type__c != null)
        {
            answerSet.add(new HotDocs_Answer_Multi('Loan_Type-mc', new HotDocs_Answer_Generic('SELECT', '', agreement.Agreement_Template__r.Facility_Type__c) ) );
        }

        if(agreement.Agreement_Template__r.Facility_Interest_Rate_Type__c != null)
        {
            answerSet.add( new HotDocs_Answer_Multi('Loan_Interest_Rate_Type-mc', new HotDocs_Answer_Generic('SELECT', '', agreement.Agreement_Template__r.Facility_Interest_Rate_Type__c) ) );
        }

        System.debug('### Answer XML:'+answerSet.getXmlDocument());

        //Final XML
        return answerSet; 
    }
    
    public HotDocs_AnswerSet buildCsaAnswerFile()
    {   
        //Answer Set
        HotDocs_AnswerSet answerSet = new HotDocs_AnswerSet();

        /**
        * PARTIES
        **/
        //Lists
        List<IHotDocs_Answer> partyNames        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRoles        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRolesMc      = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyTypes        = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyAddresses    = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> partyRegNos       = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> law_Mc            = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> agreementType_Mc  = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> collectiveInvestmentName = new List<IHotDocs_Answer>();
        List<IHotDocs_Answer> clientType_Mc = new List<IHotDocs_Answer>();

        //Dev Mode Settings for Answer XML
        answerSet.add( new HotDocs_Answer_Generic('NUM', 'PRC_Party_Role_UAT_Switch-n', SETTINGS.Interview_Development_Mode__c == false ? '0' : '1') );

        //Default agreement type.
        agreementType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'South Africa Template')));

        
        //Libra : CSA Agreement
        if(supportingAgreement.Agreement_Template__r.RecordTypeId == agreementTemplateRecordTypes.get('Agreement Template - Master').getRecordTypeId())
        {
            partyNames.add( new HotDocs_Answer_Generic('TEXT', '', '') );
            partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Party A'));
            partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party A') ) );
            partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party A') ) ); 
            partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', '') ); 
            partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', '') );
            collectiveInvestmentName.add( new HotDocs_Answer_Generic('TEXT', '', '') ); 
            clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'None')));
            
            //Governing Law
			if(agreement.Governing_Law__c != null)
            {
                law_Mc.add(new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', agreement.Governing_Law__c)));
            }
        }
        
        if(!partiesWrapperList.isEmpty())
        {
            for(partiesWrapper eachWrapper :partiesWrapperList)
            {
                //Libra
                if(eachWrapper.agreementTemplateType == 'Master')
                {
                    partyRegNos.add( new HotDocs_Answer_Generic('TEXT', '', (!String.isBlank(eachWrapper.relationshipRegistrationNumber)) ? eachWrapper.relationshipRegistrationNumber : '') );
                    partyNames.add( new HotDocs_Answer_Generic('TEXT', '', eachWrapper.relationshipName) );
                    partyRoles.add( new HotDocs_Answer_Generic('TEXT', '', 'Party B'));  
                    partyRolesMc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party B') ) );
                    partyTypes.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', 'Party B') )) ;
                }
                  
                //Compounded Address Details
                String address = '';
                address += (!String.isBlank(eachWrapper.relationshipBillingStreet)) ? eachWrapper.relationshipBillingStreet+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCity)) ? eachWrapper.relationshipBillingCity+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingState)) ? eachWrapper.relationshipBillingState+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingCountry)) ? eachWrapper.relationshipBillingCountry+'\n' : '';
                address += (!String.isBlank(eachWrapper.relationshipBillingPostalCode)) ? eachWrapper.relationshipBillingPostalCode : '';

                if(agreement.Matter_Deal__r.Relationship_Type_picklist__c == 'Counterparty') {
                    clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', agreement.Matter_Deal__r.Counterparty_Type__c)));
                }
                else {
                    clientType_Mc.add( new HotDocs_Answer_Multi('', new HotDocs_Answer_Generic('SELECT', '', agreement.Matter_Deal__r.Relationship_Type_picklist__c)));
                }
                  
                partyAddresses.add( new HotDocs_Answer_Generic('TEXT', '', address) );                  
            }
        }

        if(supportingAgreement.Agreement__r.Matter_Deal__r.Collective_Investment_Scheme_Name__c != null) {
            collectiveInvestmentName.add( new HotDocs_Answer_Generic('TEXT', '', supportingAgreement.Agreement__r.Matter_Deal__r.Collective_Investment_Scheme_Name__r.Name) ); 
        }

        //Add answers.
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullName-t', partyNames)); 
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyFullNameVariable-t', partyNames));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-t', partyRoles));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRole-mc', PartyRolesMc));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyEntityType-mc', partyTypes));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyPhysicalAddress-t', partyAddresses));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_PartyRegistration/IdentityNo-t', partyRegNos));
        answerSet.add(new HotDocs_Answer_Repeat('Applicable_Law-mc', law_Mc));
        answerSet.add(new HotDocs_Answer_Repeat('Agreement_Type-mc', agreementType_Mc));
        answerSet.add(new HotDocs_Answer_Repeat('Collective_Investment_Scheme_Name-t', collectiveInvestmentName));
        answerSet.add(new HotDocs_Answer_Repeat('PRC_Client_Type-mc', clientType_Mc));

        System.debug('### Answer XML:'+answerSet.getXmlDocument());

        //Final XML
        return answerSet; 
    }

    @RemoteAction
    public static void createRequest(String iWorkItemId, String agreementId, String supportingAgreementId)
    {
        System.debug('### HotDocs_Interview : createRequest : START ');

        try
        {
            HotDocs_Helper.createRequest(iWorkItemId, agreementId, supportingAgreementId); 
        }
        catch(Exception e)  
        {
            DebugLog.create( new DebugLog.Error(e, 'HotDocs_Interview', 'createRequest') ); 
            ApexPages.addMessage( new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()) );
        }

        System.debug('### HotDocs_Interview : createRequest : END ');
    } 
    
    public class partiesWrapper
    {
        //Lists
        public Id partyId;
        public String relationshipName;
        public String partyType;
        public Boolean partyB;
        public String agreementTemplateType;
        public String relationshipBillingStreet;
        public String relationshipBillingCity; 
        public String relationshipBillingState; 
        public String relationshipBillingCountry;
        public String relationshipBillingPostalCode;
        public String relationshipRegistrationNumber;
        
        public partiesWrapper() {
            
        }
    }
}