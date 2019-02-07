/**
* @author Deloitte
* @date 2015
*
* @group SDS Integration
*
* @description Class responsible for parsing the XML from SDS service 
* handles exceptions and logging, along with update the data within Salesforce
*/
global class WS_SDS {
    // Possible values used for status field for logging object
    private static final String SUCCESS_STATUS = 'Success';
    private static final String ERROR_STATUS = 'Error';

    // Values used for more convenient accesibility of map containing parsed values from xml
    private static final String SDS_ID = 'SDS_ID';
    private static final String ULTIMATE_PARENT_ID = 'ultimateParent';
    private static final String LEGAL_NAME = 'legalName';
    private static final String CREDIT_GROUP = 'creditGroup';
    private static final String CO_INCORPORATION = 'countryOfIncorporation';
    private static final String CO_OPERATION = 'countryOfOperation';

    /* 
    * @description Country of Operation acceptable values required for filtering -> define those here and only here 
    */
    public enum COO_Accepted_enum {ZA, KE, ZM, GH}
    /* 
    * @description Country of Operation acceptable values required for filtering -> define those here and only here 
    */
    public enum COI_Accepted_enum {ZA, KE, ZM, GH}

    // Containers (sets) for the above to simplify access and filtering
    private static Set<String> COO_ACCEPTED = new Set<String>();
    private static Set<String> COI_ACCEPTED = new Set<String>();

    /*******************************************************************************************************
    * @description Webservice method for handling incoming SDS XML 
    * @param String xmlAttachement incoming SDS XML content
    * @return String possible error / success message describing XML parsing result
    */ 
    webservice static String parseSDSinterim(String xmlAttachement)
    {
        // Interim solution - quick soap ui fix (ugly chars)
        Integer firstIndex = xmlAttachement.indexOf('<');
        if(firstIndex > 0)
            xmlAttachement = xmlAttachement.substring(firstIndex);

        ReturnMessageSDS returnMessage = new ReturnMessageSDS(); 
    	Dom.Document domDoc = new Dom.Document();

        // Check general integrity of provided XML
        try {
            domDoc.load(xmlAttachement);
        } catch (Exception e) {
            returnMessage.addToMessage('\nProvided XML is impossible to parse. Please check your email. Exception details:\n' + e.getMessage() + ' ' + e.getLineNumber());
            WS_SDS.createErrorRecord(returnMessage,xmlAttachement);
            return returnMessage.getContent();
        }

        Dom.XMLNode root = domDoc.getRootElement();
        Map<String, Map<String,String>> sdsItemContainer = new Map<String, Map<String,String>>();
        try {
            analyzeEachSDSItemData(root, sdsItemContainer, returnMessage);
        } catch (Exception e) {
            returnMessage.addToMessage('\nThere was an unexpected exception during parsing of XML.');
            returnMessage.addToMessage('\nDatabase was not updated. Please check your email. Exception details:\n' + e.getMessage() + ' ' + e.getLineNumber());
            createErrorRecord(returnMessage,xmlAttachement);
            return returnMessage.getContent();
        }

        try {
            updateOrganisations(sdsItemContainer,returnMessage);
        } catch(Exception e)
        {
            returnMessage.addToMessage('\nFailure to update accounts.');
            returnMessage.addToMessage('\nDatabase was not updated. Please check your email. Exception details:\n' + e.getMessage() + ' ' + e.getLineNumber());
            createErrorRecord(returnMessage,xmlAttachement);
            return returnMessage.getContent();
        }
        createSuccessRecord(returnMessage);
        return returnMessage.getFinalMessage();
    }

    /*******************************************************************************************************
    * @description general methods which parses the data from SDS XML into prepared container (sdsItemContainer)
    * @param DOM.XMLNode root XML root document to parse
    * @param Map<String, Map<String,String>> sdsItemContainer container for each <item> from xml converted to key-value map, matched by SDS key provided
    * @param ReturnMessageSDS returnMessage return message wrapper 
    */
    private static void analyzeEachSDSItemData(DOM.XMLNode root, Map<String, Map<String,String>> sdsItemContainer, ReturnMessageSDS returnMessage)
    {
        fillCOOandCOI();
        String namespace = root.getNamespace();
        Dom.XmlNode[] items = root.getChildElement('Data',namespace).getChildElements();

        returnMessage.addToStatistic('\nTotal number of identified potential SDS updates - before filtering (XML items size): ' + items.size());

        for(Integer i = 0; i < items.size(); i++)
        {
            Dom.XmlNode[] clientNodeChildren = items[i].getChildElements()[0].getChildElements();
            Map<String,String> fieldToValue = new Map<String,String>();
            for(Integer j = 0; j < clientNodeChildren.size(); j++)
            {
                if(clientNodeChildren[j].getName() == 'counterpartyId')
                {
                    fieldToValue.put(SDS_ID,clientNodeChildren[j].getChildElements()[0].getChildElements()[1].getText());
                }
                if(clientNodeChildren[j].getName() == 'legalName')
                {
                    fieldToValue.put(LEGAL_NAME,clientNodeChildren[j].getText());
                }
                if(clientNodeChildren[j].getName() == 'ultimateParent')
                {
                    fieldToValue.put(ULTIMATE_PARENT_ID,clientNodeChildren[j].getChildElements()[0].getChildElements()[1].getText());
                }
                if(clientNodeChildren[j].getName() == 'groupId')
                {
                    fieldToValue.put(CREDIT_GROUP,clientNodeChildren[j].getText());
                }
                if(clientNodeChildren[j].getName() == 'countries')
                {
                    getCoIandCoO(clientNodeChildren[j].getChildElements(), fieldToValue);
                }
            }
            if(validateSDSItemData(fieldToValue, returnMessage))
                sdsItemContainer.put(fieldToValue.get(SDS_ID), fieldToValue);
        }
        returnMessage.addToStatistic('\nTotal number of identified SDS updates - after validation: ' + sdsItemContainer.size());
    }

    /*******************************************************************************************************
    * @description general methods which initiates the process of update of organisations using provided parsed xml data (pre-validation)
    * @param Map<String, Map<String,String>> sdsItemContainer container for each <item> from xml converted to key-value map, matched by SDS key provided
    * @param ReturnMessageSDS returnMessage return message wrapper 
    */
    private static void updateOrganisations(Map<String, Map<String,String>> sdsItemContainer, ReturnMessageSDS returnMessage)
    {
        List<Account> matchedBySDS = matchBySDS(sdsItemContainer, returnMessage);

        returnMessage.addToStatistic('\nTotal number of updates to be performed: ' + matchedBySDS.size());

        if(matchedBySDS.size() > 0)
            update matchedBySDS;

        if(sdsItemContainer.size() > 0){
           logUnmatchedSDSAccounts(sdsItemContainer, returnMessage);
           returnMessage.addToStatistic('\nTotal number of unmatchable items: ' + sdsItemContainer.size());
        }   
    }

    /*******************************************************************************************************
    * @description helper method which appends return message about provided valid SDS accounts which were impossible to match
    * @param Map<String, Map<String,String>> sdsItemContainer container for each <item> from xml converted to key-value map, matched by SDS key provided
    * @param ReturnMessageSDS returnMessage return message wrapper 
    */
    private static void logUnmatchedSDSAccounts(Map<String, Map<String,String>> sdsItemContainer, ReturnMessageSDS returnMessage)
    {
        returnMessage.addToMessage('\nSDS Accounts below were not updated (system was unable to match):');
        for(String sdsKey : sdsItemContainer.keyset()){
            returnMessage.addToMessage(sdsMapContentToText(sdsItemContainer.get(sdsKey)));
            returnMessage.addToMessage('**************************************************');
        }
    }

    /*******************************************************************************************************
    * @description method matches existing accounts (organisations) from SF using provided SDS ID from XML
    * @param Map<String, Map<String,String>> sdsItemContainer container for each <item> from xml converted to key-value map, matched by SDS key provided
    * @param ReturnMessageSDS returnMessage return message wrapper 
    * @return List<Account> list of matched accounts by provided SDS id from XML
    */
    private static List<Account> matchBySDS(Map<String, Map<String,String>> sdsItemContainer, ReturnMessageSDS returnMessage)
    {
        String clientRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Map<Id, Account> matchedSdsAcc = new Map<ID, Account>([
                                    SELECT Id, 
                                           Name, 
                                           SDS__c, 
                                           Country_of_Operation__c, 
                                           Country_of_Incorporation__c, 
                                           Credit_Group__c, 
                                           Global_Parent__r.SDS__c,
                                           Global_Parent__r.Name,
                                           RecordTypeId
                                    FROM Account 
                                    WHERE SDS__c IN : sdsItemContainer.keySet()
                                    AND RecordTypeId =: clientRT_Id]);

        returnMessage.addToMessage('matches by sds id: ' + matchedSdsAcc.size());
        updateAccountListWithSDSData(sdsItemContainer, matchedSdsAcc, returnMessage);
        return matchedSdsAcc.values();
    }

    /*******************************************************************************************************
    * @description method validates data from XML, matches and eventually updates organisations
    * @param Map<String, Map<String,String>> sdsItemContainer container for each <item> from xml converted to key-value map, matched by SDS key provided
    * @param Map<Id, Account> matchedSdsAcc map containing matched accounts from Salesforce by SDS IDs from XML (thus, accounts to be updated)
    * @param ReturnMessageSDS returnMessage return message wrapper 
    */
    private static void updateAccountListWithSDSData(Map<String, Map<String,String>> sdsItemContainer, Map<Id, Account> matchedSdsAcc, ReturnMessageSDS returnMessage)
    {
         Map<Account,String> accToNewParentSds = new Map<Account,String>();
        // Remove matched keys from sds item container to avoid duplicate matches in next steps
        for(Account matchedAcc : matchedSdsAcc.values())
        {
            returnMessage.addToMessage('\nUpdates for Organisation: ' + matchedAcc.Name + '; ID: ' + matchedAcc.Id);
            if(sdsItemContainer.get(matchedAcc.SDS__c).get(CO_OPERATION) != matchedAcc.Country_of_Operation__c)
            {
                returnMessage.addToMessage('\nCoO change from: ' + matchedAcc.Country_of_Operation__c + ' to: ' + sdsItemContainer.get(matchedAcc.SDS__c).get(CO_OPERATION));
                matchedAcc.Country_of_Operation__c = sdsItemContainer.get(matchedAcc.SDS__c).get(CO_OPERATION);
            }
            if(sdsItemContainer.get(matchedAcc.SDS__c).get(CO_INCORPORATION) != matchedAcc.Country_of_Incorporation__c)
            {
                returnMessage.addToMessage('\nCoI change from: ' + matchedAcc.Country_of_Incorporation__c + ' to: ' + sdsItemContainer.get(matchedAcc.SDS__c).get(CO_INCORPORATION));
                matchedAcc.Country_of_Incorporation__c = sdsItemContainer.get(matchedAcc.SDS__c).get(CO_INCORPORATION);
            }
            if(sdsItemContainer.get(matchedAcc.SDS__c).get(CREDIT_GROUP) != matchedAcc.Credit_Group__c)
            {
                returnMessage.addToMessage('\nCredit Group ID change from: ' + matchedAcc.Credit_Group__c + ' to: ' + sdsItemContainer.get(matchedAcc.SDS__c).get(CREDIT_GROUP));
                matchedAcc.Credit_Group__c = sdsItemContainer.get(matchedAcc.SDS__c).get(CREDIT_GROUP);
            }
            if(sdsItemContainer.get(matchedAcc.SDS__c).get(LEGAL_NAME) != matchedAcc.Name)
            {
                returnMessage.addToMessage('\nOrganisation Name change from: ' + matchedAcc.Name + ' to: ' + sdsItemContainer.get(matchedAcc.SDS__c).get(LEGAL_NAME));
                matchedAcc.Name = sdsItemContainer.get(matchedAcc.SDS__c).get(LEGAL_NAME);
            }
            sdsItemContainer.remove(matchedAcc.SDS__c);
            // Rules for matching vs ultimate parent have to be defined yet
            /*if(sdsItemContainer.get(matchedAcc.SDS__c).get(ULTIMATE_PARENT_ID) != matchedAcc.Global_Parent__r.SDS__c)
            {
                accToNewParentSds.put(matchedAcc,sdsItemContainer.get(matchedAcc.SDS__c).get(ULTIMATE_PARENT_ID));
            }*/
        }
        /* Rules for matching vs ultimate parent have yet to be defined 
        if(accToNewParentSds.size() > 0)
        {
            String ultParentRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
            String TYPE_OF_CLIENT = 'SDS Ultimate Parent';
            List<Account> ultimateParents = [SELECT Id, Name, SDS__c, Type FROM Account WHERE SDS__c IN : accToNewParentSds.values()];
            // Find the accounts for which the parent should be updated
            for(Account accWithParentUpdate : accToNewParentSds.keyset())
            {
                for(Account ultimateParent : ultimateParents)
                {
                    if(accToNewParentSds.get(accWithParentUpdate).compareTo(ultimateParent.SDS__c) == 0 && TYPE_OF_CLIENT.compareTo(ultimateParent.Type) == 0)
                    {
                        returnMessage.addToMessage('\nOrganisation Ultimate Parent change from: ' + accWithParentUpdate.Global_Parent__r.Name + ' to: ' + ultimateParent.Name);
                        returnMessage.addToMessage('\nPrevious Ult Parent SDS ID: ' + accWithParentUpdate.Global_Parent__r.SDS__c + ' new one from SDS: ' + sdsItemContainer.get(accWithParentUpdate.SDS__c).get(ULTIMATE_PARENT_ID));
                        matchedSdsAcc.get(accWithParentUpdate.Id).Global_Parent__c = ultimateParent.Id;
                    }
                }
            }
        }*/
    }

    /*******************************************************************************************************
    * @description method validates data <item> from XML and checks its usefulness (e.g. skips non accepted CoO/CoI)
    * @param Map<String, String> fieldToValue <item> from xml converted to key-value map
    * @param ReturnMessageSDS returnMessage return message wrapper 
    * @param boolean true if data within <item> was useful & integrity was ok; false otherwise
    */
    private static boolean validateSDSItemData(Map<String,String> fieldToValue, ReturnMessageSDS returnMessage)
    {
        // returnMessage.addToMessage('Content within validation: ' + sdsMapContentToText(fieldToValue));
        if(!COO_ACCEPTED.contains(fieldToValue.get(CO_OPERATION)) && !COI_ACCEPTED.contains(fieldToValue.get(CO_INCORPORATION)))
            return false;

        if(fieldToValue.get(SDS_ID) == '')
        {
            returnMessage.addToMessage('This client data has missing entries - SDSID:');
            returnMessage.addToMessage(sdsMapContentToText(fieldToValue));
            return false;
        }

        return true;
    }

    /*******************************************************************************************************
    * @description helper method to present result of parsing <ITEM> object from XML into human-readable string
    * @param Map<String, String> fieldToValue <item> from xml converted to key-value map
    * @param String parameter map content converted to human-readable string
    */
    private static String sdsMapContentToText(Map<String, String> fieldToValue)
    {
        String retMsg = '\n[SDS ID: '+fieldToValue.get(SDS_ID)+']\n[LEGAL_NAME: '+fieldToValue.get(LEGAL_NAME)+']';
        retMsg += '\n[ULTIMATE PARENT ID: '+fieldToValue.get(ULTIMATE_PARENT_ID)+']\n'+'[CREDIT GROUP ID: '+fieldToValue.get(CREDIT_GROUP)+']';
        retMsg += '\n[COUNTRY OF OPERATION: '+fieldToValue.get(CO_OPERATION)+']\n'+'[COUNTRY OF INCORPORATION: '+fieldToValue.get(CO_INCORPORATION)+']';
        retMsg += '\n';

        return retMsg;
    }

    /*******************************************************************************************************
    * @description creates log record with status = success, which indicates successful completion of parsing and updating
    * @param Account updatedOrg updates Organisation record
    * @param ReturnMessageSDS returnMessage wrapper object for return message 
    * @return Database.SaveResult result of saving the log object with status = success
    */
    private static void createSuccessRecord(ReturnMessageSDS returnMessage)
    {
        SDS_Integration_Log__c successLog = new SDS_Integration_Log__c();
        successLog.Name = 'SDS LOG (SUCCESS) ' + DateTime.now().format();
        successLog.Status__c = SUCCESS_STATUS;
        successLog.Description__c = '\nAdditional details (if any):';
        successLog.Description__c += returnMessage.getFinalMessage();
        insert successLog;

        returnMessage.addToMessage('\nOperation completed successfuly, log details at: ' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + successLog.Id);
    }

    /*******************************************************************************************************
    * @description creates log record with status = error, which documents in detail reason of failure of process
    * error log records are saved with incoming SDS XML as attachment
    * method is also invoking the error email message to administrator
    * @param ReturnMessageSDS returnMessage wrapper object for return message 
    * @param String xmlAttachement incoming xml content
    */
    private static void createErrorRecord(ReturnMessageSDS returnMessage, String xmlAttachement)
    {
        Database.SaveResult result;
        SDS_Integration_Log__c errorLog = new SDS_Integration_Log__c();
        errorLog.Name = 'SDS LOG (ERROR) ' + DateTime.now().format();
        errorLog.Status__c = ERROR_STATUS;
        errorLog.Description__c = returnMessage.getContent();

        result = Database.insert(errorLog);
        Attachment attachment = new Attachment();
        // check if error log record was inserted successfuly
        if(result.isSuccess())
        {
            attachment.body = Blob.valueOf(xmlAttachement);
            attachment.name = 'xmlAttachement_SDS_' + DateTime.now().format() +'.xml';
            attachment.parentId = errorLog.Id;
            result = Database.insert(attachment);
        }
        else {
            returnMessage.addToMessage('\nFAILED TO SAVE ERROR LOG OBJECT');
        }

        // check if attachment was saved without errors
        if(!result.isSuccess())
            returnMessage.addToMessage('\nFAILED TO SAVE XML REQUEST ATTACHED LOG OBJECT ID: ' + errorLog.Id);

        errorLog.XmlAttachment__c = attachment.Id;
        result = Database.update(errorLog);
        // check if error log record update with attachment was successful 
        if(!result.isSuccess())
            returnMessage.addToMessage('\nFAILED TO UPDATE ERROR LOG OBJECT - NO ATTACHMENT ATTACHED; ID: ' + errorLog.Id);

        sendErrorNotificationEmail(errorLog);
    }

    /*******************************************************************************************************
    * @description constructs and sends error message describing failure of processs
    * with reference to the created error log record
    * @param SDS_Integration_Log__c errorRecord error log record to be referenced within email message 
    */
    private static void sendErrorNotificationEmail(SDS_Integration_Log__c errorRecord)
    {
        SDS_Integration_CS__c cs = SDS_Integration_CS__c.getInstance('SendErrorLogToAddress');
        String sendToAddress = cs.SendErrorLogToAddress__c;
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[]{sendToAddress});
        mail.setSenderDisplayName('SDS Integration Error Notfication; ID: ' + errorRecord.Id + '; ' + DateTime.now().format()); 
        mail.setUseSignature(false);
        mail.setBccSender(false);
        mail.setSaveAsActivity(true);

        String bodyMsg = 'There was an error during SDS integration process.\n';
        bodyMsg += '\nDescription: ' + errorRecord.Description__c;
        bodyMsg += '\n\nDetails are described within the object accessible at: ' +  URL.getSalesforceBaseUrl().toExternalForm() + '/' + errorRecord.Id;
        mail.setPlainTextBody(bodyMsg); // Add here reference to the errorRecord id to let user obtain details

        if(!Test.isRunningTest())
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    /*******************************************************************************************************
    * @description helper method to extract Country of Incorporation (CoI) and Country of Operation (CoO) from incoming XML
    * @param Dom.XMLNode root root node for required parameters 
    * @param Map<String,String> fieldToValue map containing values from XML 
    */
    private static void getCoIandCoO(Dom.XmlNode[] countries, Map<String,String> fieldToValue)
    {
        for(Integer i = 0; i < countries.size(); i++)
        {
            String countryType = countries[i].getChildElements()[0].getText().toUpperCase();
            if(countryType == 'Incorporation'.toUpperCase())
                fieldToValue.put(CO_INCORPORATION,countries[i].getChildElements()[1].getText());

            if(countryType == 'Operation'.toUpperCase())
                fieldToValue.put(CO_OPERATION,countries[i].getChildElements()[1].getText());
        }
    }

    /*******************************************************************************************************
    * @description helper method to fill the set containers for allowed CoI/CoO values
    */
    private static void fillCOOandCOI()
    {
        for(Integer i = 0; i < COO_Accepted_enum.values().size(); i++)
           COO_ACCEPTED.add(String.valueOf(COO_Accepted_enum.values()[i]));

        for(Integer i = 0; i < COI_Accepted_enum.values().size(); i++)
           COI_ACCEPTED.add(String.valueOf(COI_Accepted_enum.values()[i]));
    }

    /**
    * @author Jan Cicharski @ Deloitte
    * @date 2015
    *
    * @group SDS Integration
    *
    * @description Wrapper class around return message simply to overcome pass by value in terms of String 
    */
    public class ReturnMessageSDS
    {
        private String content = '';
        private String statisticsContent = '';
        public void addToMessage(String msg)
        {
            content += msg;
        }

        public void addToStatistic(String msg)
        {
            statisticsContent += msg;
        }

        public String getContent()
        {
            return content;
        }

        public String getFinalMessage()
        {   
            return '\n' + content + '\nStatistics: ' + statisticsContent + '\n';
        }
    }

    /*
    private static List<Account> matchByLegalName(Map<String, Map<String,String>> sdsItemContainer, ReturnMessageSDS returnMessage)
    {
        String clientRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Map<String,String> sdsToLegalName = new Map<String,String>();
        for(String sdsId : sdsItemContainer.keySet())
            sdsToLegalName.put(sdsId, sdsItemContainer.get(sdsId).get(LEGAL_NAME));

        Map<Id, Account> matchedByLegalNameAccs = new Map<ID, Account>([
                                    SELECT Id, 
                                           Name, 
                                           SDS__c, 
                                           Country_of_Operation__c, 
                                           Country_of_Incorporation__c, 
                                           Credit_Group__c, 
                                           Global_Parent__r.SDS__c,
                                           Global_Parent__r.Name
                                    FROM Account 
                                    WHERE Name IN : sdsToLegalName.values()
                                    AND RecordTypeId =: clientRT_Id
                                    AND SDS__c != null]);

        returnMessage.addToMessage('\nmatches by legal name: ' + matchedByLegalNameAccs.size());
        updateAccountListWithSDSData(sdsItemContainer, matchedByLegalNameAccs, returnMessage);                              
        return matchedByLegalNameAccs.values();
    }

    private static List<Account> matchByParentId(Map<String, Map<String,String>> sdsItemContainer, ReturnMessageSDS returnMessage)
    {
        String clientRT_Id = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Client').getRecordTypeId();
        Map<String,String> sdsToParentId = new Map<String,String>();
        for(String sdsId : sdsItemContainer.keySet())
        {
            //TODO: HANDLING CASES WHEN YOU HAVE NO ULTIMATE PARENT ID 
            if(sdsItemContainer.get(sdsId).get(ULTIMATE_PARENT_ID) != null)
                sdsToParentId.put(sdsId, sdsItemContainer.get(sdsId).get(ULTIMATE_PARENT_ID));
        }

        Map<Id, Account> matchedByParentIdAccs = new Map<ID, Account>([
                                    SELECT Id, 
                                           Name, 
                                           SDS__c, 
                                           Country_of_Operation__c, 
                                           Country_of_Incorporation__c, 
                                           Credit_Group__c, 
                                           Global_Parent__r.SDS__c,
                                           Global_Parent__r.Name
                                    FROM Account 
                                    WHERE Global_Parent__r.SDS__c IN : sdsToParentId.values()
                                    AND RecordTypeId =: clientRT_Id
                                    AND SDS__c != null]);

        returnMessage.addToMessage('\nmatches by parent sds id: ' + matchedByParentIdAccs.size());
        updateAccountListWithSDSData(sdsItemContainer, matchedByParentIdAccs, returnMessage);
        return matchedByParentIdAccs.values();
    }
*/
}