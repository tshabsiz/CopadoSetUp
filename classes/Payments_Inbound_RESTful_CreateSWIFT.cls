/**
* 20170626
* Rudolf Niehaus - CloudSmiths
**/
@RestResource(urlMapping='/createPaymentsCase/*')
global Without Sharing class Payments_Inbound_RESTful_CreateSWIFT {
    
    @HttpPost
    global static String logCase(String bicCode, String description, String relatedRef,String countryCode, String originPack, String messageType, String transactionRef) {
        
        RestRequest req = RestContext.request;

        list<Case> existingCase = new list<Case>();
        boolean validationOk = true;
        String errorMessage = '';
        String swiftId = '';
        String paymentBicCode = '';
        String ackType = '199';
        String senderAddress = '';
        String tempPaymentBicCode = '';
        String portfolioMappingCode = countryCode;
        String originalCountryCode = countryCode;
        System.debug(countryCode);
        if(bicCode.indexOf(';') > 0){
            String[] codes = bicCode.split(';');
            bicCode = codes[0];
            swiftId = codes[1];
            if(swiftId.indexOf('.') > 0){
                swiftId = swiftId.substring(0,swiftId.indexOf('.'));
            }
        }
        //get country code from the payments BIC code
        if(countryCode.indexOf(';') > 0){
            
            String[] codes = countryCode.split(';');
            List<String> paymentBicCodeArray = new List<String>();
            
            if(codes.size() == 2){
                countryCode = codes[0];
                
                paymentBicCode = codes[1];
                
                paymentBicCodeArray = paymentBicCode.split('\\\\');
                
                if(paymentBicCodeArray.size()==2)
                {
                    paymentBicCode = paymentBicCodeArray[1];
                }
                else
                {
                    paymentBicCode = paymentBicCodeArray[0];
                }
                
            }else if(codes.size() == 1){
              countryCode = codes[0];
              paymentBicCode = ''; 
            }
            
            //e.g. of value ABSAZAJJ665R
            if(paymentBicCode.length() >= 6){
                //List <String> paymentBicCodeArray = paymentBicCode.split('\n');
                //paymentBicCode = paymentBicCodeArray[1];
                if(paymentBicCodeArray.size()==2)
                {
                    tempPaymentBicCode = paymentBicCode;
                    paymentBicCode = paymentBicCode.substring(5,7);
                }
                else
                {
                    tempPaymentBicCode = paymentBicCode;
                    paymentBicCode = paymentBicCode.substring(4,6);
                }
                
            }
        }else{
            paymentBicCode = '';
        }
        
        //concatinate the query country code and the payments country code to ensure we link to the correct portfolio (Queue)
        //Only if the payments code is ZA (South Africa)
        if(paymentBicCode.equals('ZA')){
            
            if(tempPaymentBicCode.containsIgnoreCase('absazajj'))
            {
                portfolioMappingCode = countryCode + paymentBicCode;
            }
            else
            {
                portfolioMappingCode = countryCode;
            }
        }else{
            portfolioMappingCode = countryCode;
        }
        
        //Get all relative recordtypes into maps for later refer
        map<String, Schema.RecordTypeInfo> accRecordTypeMap = Account.sObjectType.getDescribe().getRecordTypeInfosByName();
        map<String, Schema.RecordTypeInfo> caseRecordTypeMap = Case.sObjectType.getDescribe().getRecordTypeInfosByName();
        map<String, Schema.RecordTypeInfo> swiftRecordTypeMap = SWIFT_Message__c.sObjectType.getDescribe().getRecordTypeInfosByName();
        
        //get message response types from the custom metadata object
        list<SWIFT_Type_Mapping__mdt> msgTypes = [Select AutoAcknowledgement__c From SWIFT_Type_Mapping__mdt 
                                                  Where MessageType__c = :messageType limit 1];
        if(msgTypes.size() > 0){
            ackType = msgTypes[0].AutoAcknowledgement__c;
        }
        //RESPONSE HEADER (pretty JSON file)
        JSONGenerator gen = JSON.createGenerator(false);
     
        gen.writeStartObject();
       
        //check JSON values
       if(String.isBlank(bicCode)){
            validationOk = false;
            errorMessage = 'Missing Value bicCode';
       }
       if(String.isBlank(swiftId)){
           validationOk = false;
           errorMessage = 'Missing Value swiftId'; 
       }
       if(String.isBlank(description)){
           validationOk = false;
           errorMessage = 'Missing Value description'; 
       }
       if(String.isBlank(relatedRef)){
           validationOk = false;
           errorMessage = 'Missing Value relatedRef';  
       }
       if(String.isBlank(countryCode)){
           validationOk = false;
           errorMessage = 'Missing Value countryCode';              
       }
       if(String.isBlank(originPack)){
           validationOk = false;
           errorMessage = 'Missing Value originPack';
       }
       if(String.isBlank(messageType)){
           validationOk = false;
           errorMessage = 'Missing Value messageType';
       }
       if(String.isBlank(transactionRef)){
           validationOk = false;
           errorMessage = 'Missing Value transactionRef';
       }
        
        if(!validationOk){
            gen.writeStringField('caseNumber','');
            gen.writeBooleanField('status',false);
            gen.writeStringField('description','Failed - ' + errorMessage);
            gen.writeStringField('relatedRef',relatedRef + ';' + ackType);
            //Close JSON response
            gen.writeEndObject();
            
            //pass JSON back to caller
            return gen.getAsString();
        }
        
        //get sender address from msg body
        senderAddress = getSenderAddress(description);
        
        SavePoint sp = Database.setSavepoint();
        
        //
        
        //Find relationship based on BIC Code
        list<Account> existingAccount = [Select Id From Account Where Swift_Code__c = :bicCode.trim()];
        
        //Create new reltionship (client) with bic code as the name
        if( existingAccount.size() == 0){
            
            Account newBicAccount = new Account();
            newBicAccount.Name = bicCode;
            newBicAccount.Swift_Code__c = bicCode;
            newBicAccount.Type = 'Bank';
            newBicAccount.RecordTypeId = accRecordTypeMap.get('Client').getRecordTypeId();
            
            try{
                upsert newBicAccount Swift_Code__c;
            }catch(DMLException ex){
                
                Database.rollback(sp);
                
                System.debug('There was an error when inserting a new Account for the bicCode ' + bicCode);
                System.debug(ex.getMessage());
                
                gen.writeStringField('caseNumber','');
                gen.writeBooleanField('status',false);
                gen.writeStringField('description','Failed - ' + ex.getMessage());
                gen.writeStringField('relatedRef',relatedRef + ';' + ackType);
                //Close JSON response
                gen.writeEndObject();
                
                //pass JSON back to caller
                return gen.getAsString();
            }
        }
        
        String qName = 'Portfolio_Unassigned';
        
        for(SWIFT_Portfolio_Mapping__mdt codes :[Select DeveloperName, CountryCodeList__c From SWIFT_Portfolio_Mapping__mdt]){
            
            if(String.isNotBlank(codes.CountryCodeList__c)){
            
                if(codes.CountryCodeList__c.indexOf(',') > 0){
                    
                    set<string> allCodes = new set<string>(codes.CountryCodeList__c.split(','));
              
                    if(allCodes.contains(portfolioMappingCode)){
                        qName = codes.DeveloperName;
                    }
                    
                }else{
                    if(codes.CountryCodeList__c == portfolioMappingCode){
                        qName = codes.DeveloperName;
                    }
                }
            }
        }
        
        list<Group> q = [Select Id From Group Where DeveloperName = :qName AND Type = 'Queue'];

        //Check if Case exists based on relatedRef OR transactionRef
        existingCase = [Select Id, CaseNumber, Subject, SWIFT_GBP_Reference__c, SWIFTTransactionReference__c, RecordTypeId, AccountId, OwnerId 
                        From Case 
                        Where SWIFT_GBP_Reference__c = :relatedRef.trim() AND 
                        SWIFT_BIC_Code__c = :bicCode.trim() limit 1];
        
        //add message to exiting case based on gbpcode, else create new case and add first message
        SWIFT_Message__c newSWIFT = new SWIFT_Message__c();
        newSWIFT.Sender_Address__c = senderAddress;
        newSWIFT.RelatedReference__c = relatedRef.trim();
        newSWIFT.QueryMessage__c = description;
        newSWIFT.PaymentMessage__c = originPack.trim();
        newSWIFT.TransactionReference__c = transactionRef.trim();
        newSWIFT.MessageType__c = messageType.right(3);
        newSWIFT.RecordTypeId = swiftRecordTypeMap.get('SWIFT Inbound').getRecordTypeId();
        newSWIFT.MessageFlowDirection__c = 'In';
        newSWIFT.IsOriginalMessage__c = true;
        
        String CaseNumber = '';
        
        Case paymentCase = new Case();
        
        if( existingCase.size() == 0 ){
            paymentCase.SWIFTId__c = swiftId;
            paymentCase.SWIFTQueryMessage__c = description;
            paymentCase.SWIFT_GBP_Reference__c = relatedRef.trim();
            paymentCase.SWIFT_BIC_Code__c = bicCode.trim();
            paymentCase.SWIFTTransactionReference__c = transactionRef.trim();
            paymentCase.RecordTypeId = caseRecordTypeMap.get('Payments').getRecordTypeId();
            paymentCase.SWIFTPaymentMessage__c = originPack.trim();
            paymentCase.SWIFTMessageType__c = messageType.right(3);
            paymentCase.Subject = 'SWIFT Query';
            paymentCase.SWIFT_Sender_Country_Code__c = countryCode;
            //paymentCase.Test_JSON__c = originalCountryCode;
            paymentCase.paymentBicCode__c = paymentBicCode;
            
            if(existingAccount.size() > 0){
                paymentCase.AccountId = existingAccount[0].Id;
            }
            if(q.size() > 0){
                paymentCase.OwnerId = q[0].Id;
            }
            
            try{
                
                insert paymentCase;
    
            }catch(DMLException e){
               
                Database.rollback(sp);
                
                gen.writeStringField('caseNumber','');
                gen.writeBooleanField('status',false);
                gen.writeStringField('description','Failed-' + e.getMessage());
                gen.writeStringField('relatedRef',relatedRef + ';' + ackType);
                gen.writeEndObject();
                //pass JSON back to caller
                return gen.getAsString();
            }
            
            newSWIFT.Case__c = paymentCase.Id;
            CaseNumber = [Select Id, CaseNumber From Case Where Id =:paymentCase.Id].CaseNumber;
            
        }else{
            newSWIFT.Case__c = existingCase[0].Id;
            CaseNumber = existingCase[0].CaseNumber;
        }
        
        //insert SWIFT message
        try{
            
            upsert newSWIFT Id;
            
            gen.writeStringField('caseNumber', CaseNumber);
            gen.writeBooleanField('status',true);
            gen.writeStringField('description','Succesful - New SWIFT Message Record was Created OR Updated in Salesforce for the relatedRef : ' + relatedRef + ' AND  transactionRef : ' + transactionRef);
            gen.writeStringField('relatedRef',relatedRef + ';' + ackType);
            
        }catch(DMLException e){
            
            Database.rollback(sp);
            
            gen.writeStringField('caseNumber','');
            gen.writeBooleanField('status',false);
            gen.writeStringField('description','Failed - Could not create a new SWIFt Message record - ' + e.getMessage()); 
            gen.writeStringField('relatedRef',relatedRef + ';' + ackType);
            gen.writeEndObject();
            //pass JSON back to caller
            return gen.getAsString();
        }
        
        
        //Close JSON response
        gen.writeEndObject();
        
        //pass JSON back to caller
        return gen.getAsString();
    }
    
    //get sender address from siwft body
    private static String getSenderAddress(String swiftMsg){
        String sAddress = '';
        /**
         * "{1:F01ABSAZAJJAXXX1967564145}{2:O1961459140103POPUESMMAXXX99195802601401031600N}{3:{108:140103145700990}}{
         * 4:\n:20:ET-2009-07\n:21:GPPTESTPF01A\n:76:THIS IS AN AUTOMATED\nACKNOWLEDGEMENT. PLEASE QUOTE OUR\n
         * REFERENCE IN ALL FUTURE\nCORRESPONDENCE.BEST REGARDS\n:11R:199\n140103\n:20:7127OPS4710Z0301\n:21:0222TRFP29884845\n:
         * 79:ATT PAYMENTS DEPT\nRE YOUR MT103 FOR THE AMOUNT OF\nZAR2970000,00 VALUE 140103 REF 0222TRFP29884845.\nWE HAVE 
         * CANCELLED YOUR MESSAGE AND TREATED IT\nAS NULL AND VOID. WE ARE UNABLE TO CREDIT DEUTDEFF\nAS THEY DO NOT MAINTAIN 
         * A RAND ACCOUNT IN OUR\nBOOKS.\nBEST REGARDS\nVOSTRO OPERATIONS\n-}{5:{MAC:00000000}{CHK:B5DD08065A55}}"
        **/
        Integer x = swiftMsg.indexOf('{2:');
        x = (x+17);
        
        if(x > 0){
            sAddress = swiftMsg.substring(x, (x + 12));
        }
        return sAddress;
    }
}