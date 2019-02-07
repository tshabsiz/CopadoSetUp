/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 

**/ 
public class HotDocs_Helper 
{
    /**
    * Variables 
    **/
    public static final Map<String, RecordTypeInfo> conditionTypes = new Map<String, RecordTypeInfo>(Condition__c.sObjectType.getDescribe().getRecordTypeInfosByName()); 
    public static final Map<String, RecordTypeInfo> supportingAgreementTypes = new Map<String, RecordTypeInfo>(Supporting_Agreement__c.sObjectType.getDescribe().getRecordTypeInfosByName()); 
 
    public static void createRequest(String iWorkItemId, String iAgreementId, String supportingAgreementId) 
    {
        System.debug('### HotDocs_Helper : createRequest');
        
        HotDocs_Request__c requestItem = new HotDocs_Request__c();
        requestItem.Work_Item_ID__c = iWorkItemId;
        requestItem.Agreement__c = iAgreementId;
        requestItem.Status__c = 'Queued';
        if(supportingAgreementId != null && supportingAgreementId != '')
        {
           requestItem.Supporting_Agreement__c = supportingAgreementId;  
        }        

        //Insert request item.
        insert requestItem; 
    }

    public static void afterInsert_RequestItem(List<HotDocs_Request_Item__c> newRequestItems)
    {
        System.debug('### HotDocs_Helper : afterInsert_RequestItem : START');

        //Blank vars.
        Map<String, String> agreementAnswerSets = new Map<String, String>();
        Map<String, String> supportingAgreementAnswerSets = new Map<String, String>();
        List<Agreement__c> agreements = new List<Agreement__c>();
        List<Supporting_Agreement__c> supportingAgreements = new List<Supporting_Agreement__c>();

        try
        {
            //Request Item Ids from Trigger.
            Set<Id> requestItemsIds = new Map<Id, HotDocs_Request_Item__c>(newRequestItems).keySet();

            //Query records to get related agreement details from parent.
            Map<Id, HotDocs_Request_Item__c> requestItems = new Map<Id, HotDocs_Request_Item__c>([
                SELECT
                    Id,
                    Item_ID__c,
                    Type__c,
                    HotDocs_Request__r.Agreement__r.Id,
                    HotDocs_Request__r.Supporting_Agreement__c,
                    HotDocs_Request__r.Supporting_Agreement__r.Id
                FROM HotDocs_Request_Item__c
                WHERE 
                    Id IN :requestItemsIds
            ]);

            //Process items.
            for(String key : requestItems.keySet())
            {
                if(requestItems.get(key).Type__c == 'Answer File' && requestItems.get(key).HotDocs_Request__r.Supporting_Agreement__c != null)
                {
                    supportingAgreementAnswerSets.put(requestItems.get(key).HotDocs_Request__r.Supporting_Agreement__r.Id, requestItems.get(key).Item_ID__c);
                }
                else 
                {
                    agreementAnswerSets.put(requestItems.get(key).HotDocs_Request__r.Agreement__r.Id, requestItems.get(key).Item_ID__c);
                }
            }

            //Fetch agreements affected.
            if(!agreementAnswerSets.isEmpty() && supportingAgreementAnswerSets.isEmpty())
            {
                agreements = [
                    SELECT 
                    Id,
                    Last_HotDocs_Answer_Set_ID__c  
                    FROM Agreement__c
                    WHERE
                    Id IN :agreementAnswerSets.keySet()
                ];
                
                //Loop over agreements and assign answer set id.
                for(Agreement__c agreement : agreements)
                {
                    agreement.Last_HotDocs_Answer_Set_ID__c = agreementAnswerSets.get(agreement.Id);
                }
                
                //Update agreements.
                update agreements;
            }

             //Fetch Supporting Agreements affected.
             System.debug('agreementAnswerSets : ' + agreementAnswerSets); 
             System.debug('supportingAgreementAnswerSets : ' + supportingAgreementAnswerSets);
             if(!supportingAgreementAnswerSets.isEmpty()) 
             {
                 supportingAgreements = [
                     SELECT 
                     Id,
                     Agreement__c,
                     Last_HotDocs_Answer_Set_ID__c  
                     FROM Supporting_Agreement__c 
                     WHERE
                     Id IN :supportingAgreementAnswerSets.keySet()
                 ];
                 
                 //Loop over agreements and assign answer set id.
                for(Supporting_Agreement__c agreement : supportingAgreements)
                {
                    agreement.Last_HotDocs_Answer_Set_ID__c = supportingAgreementAnswerSets.get(agreement.Id);
                }
                 
                //Update Supporting Agreements.
                update supportingAgreements;
             }
            
            System.debug('### HotDocs_Helper : afterInsert_RequestItem : agreements : '+agreements);

        }
        catch(Exception e)
        {
            DebugLog.create( new DebugLog.Error(e, 'HotDocs_Helper', 'afterInsert_RequestItem') );
        }
    }

    public static void processAnswerXML(String iAgreementId, String iAnswerXml) 
    {
        System.debug('### HotDocs_Helper : processAnswerXML : START');

        //Blank variables.
        Map<String, Condition__c> existingConditions = new Map<String, Condition__c>();

        try
        {
            Agreement__c agreement = [
                SELECT 
                    Id,
                    Matter_Deal__c,
                    Agreement_Template__r.Clause_Origin__c,
                    (
                        SELECT
                            Id,
                            Name,
                            Active__c
                        FROM Conditions__r
                    )
                FROM Agreement__c
                WHERE
                    Id = :iAgreementId
                LIMIT 1
            ];

            //Loop over existing conditions and make an index based on name.
            for(Condition__c condition : agreement.Conditions__r)
            {
                existingConditions.put(condition.Name, condition);
            }

            //Initilise parser.
            HotDocs_Parser parser = new HotDocs_Parser(iAnswerXml);

            //Insert lists.
            List<Condition__c> conditions = new List<Condition__c>();
            List<Condition_Document__c> documents = new List<Condition_Document__c>();

            //Used to dynamically build condition variable names and record type id.
            Map<String, String> conditionVariables = new Map<String, String>{
                'CP'=>conditionTypes.get('Condition Precedent').getRecordTypeId(),
                'FC'=>conditionTypes.get('Financial Covenant').getRecordTypeId(),
                'IU'=>conditionTypes.get('Information Undertaking').getRecordTypeId()
            };

            //Make sure the Agreement Templates says we must insert from HotDocs.
            if(agreement.Agreement_Template__r.Clause_Origin__c == 'HotDocs')
            {
                //Loop over condition types.
                for(String conditionVariable : conditionVariables.keySet())
                {
                    System.debug('conditionVariable :' + conditionVariable);

                    //Clear list.
                    conditions.clear(); 
                    documents.clear();

                    //Query answer file and get data for variables.
                    List<IHotDocs_Answer> conditionNames = parser.getAnswer('ADVL_'+conditionVariable+'_Name-t'); 
                    List<IHotDocs_Answer> conditionClauses = parser.getAnswer('ADVL_'+conditionVariable+'_Clause-t');       
                    List<IHotDocs_Answer> conditionFrequencies = parser.getAnswer('ADVL_'+conditionVariable+'_Frequency-t'); 
                    List<IHotDocs_Answer> conditionRelativeDates = parser.getAnswer('ADVL_'+conditionVariable+'_Relative_Date-t'); 
                    List<IHotDocs_Answer> conditionNumberOfDays = parser.getAnswer('ADVL_'+conditionVariable+'_Number_Of_Days-t'); 
                    List<IHotDocs_Answer> conditionDueDates = parser.getAnswer('ADVL_'+conditionVariable+'_Due_Date-t');
                    List<IHotDocs_Answer> conditionOtherRelativeDates = parser.getAnswer('ADVL_'+conditionVariable+'_Other_Relative_Date-t');
                    List<IHotDocs_Answer> conditionDocuments = parser.getAnswer('ADVL_'+conditionVariable+'_Document-t');

                    //Additional condition scheduling fields.
                    List<IHotDocs_Answer> conditionDays = parser.getAnswer('ADVL_'+conditionVariable+'_Days-t'); 
                    List<IHotDocs_Answer> conditionThresholdTypes = parser.getAnswer('ADVL_'+conditionVariable+'_Threshold_Type-t'); 
                    List<IHotDocs_Answer> conditionThresholdCategories = parser.getAnswer('ADVL_'+conditionVariable+'_Threshold_Category-t'); 
                    List<IHotDocs_Answer> conditionThresholdComparators = parser.getAnswer('ADVL_'+conditionVariable+'_Threshold_Comparator-t'); 
                    List<IHotDocs_Answer> conditionBaseValues = parser.getAnswer('ADVL_'+conditionVariable+'_Base_Value-t');
                    List<IHotDocs_Answer> conditionBaseValuesFrom = parser.getAnswer('ADVL_'+conditionVariable+'_Base_Value_From-t');
                    List<IHotDocs_Answer> conditionBaseValuesTo = parser.getAnswer('ADVL_'+conditionVariable+'_Base_Value_To-t');
                    
                    System.debug('### processAnswerXML : '+conditionVariable+' : conditionNames : '+conditionNames);
                    System.debug('### processAnswerXML : '+conditionVariable+' : conditionDocuments : '+conditionDocuments);

                    //Build conditions for processing.
                    for(Integer i = 0; i < conditionNames.size()-1; i++) 
                    {
                        String conditionKey                 = (String)conditionNames.get(i).getData();
                        Condition__c condition              = new Condition__c();                       

                        //Set the id if an existing condition for update.
                        if(existingConditions.containsKey(conditionKey))
                        {
                            condition.Id                    = existingConditions.get(conditionKey).Id;
                        }
                            
                        condition.Name                      = conditionKey; 
                        System.debug('condition.Name :' + condition.Name);

                        //Needed until the template has been updated to include a clause for all condition types.
                        try
                        {
                            condition.Clause__c             = (String)conditionClauses.get(i).getData();
                        }
                        catch(ListException e)
                        {
                            condition.Clause__c             = null;
                        }

                        //Days - Days__c
                        try
                        {
                            condition.Days__c           = (String)conditionDays.get(i).getData();
                        }
                        catch(ListException e)
                        {
                            condition.Days__c           = null;
                        }

                        //Threshold Type - Threshold_Type__c
                        try
                        {
                            condition.Threshold_Type__c             = (String)conditionThresholdTypes.get(i).getData();
                        }
                        catch(ListException e)
                        {
                            condition.Threshold_Type__c             = null;
                        }

                        //Threshold Category - Threshold_Category__c
                        try
                        {
                            condition.Threshold_Category__c             = (String)conditionThresholdCategories.get(i).getData();

                        }
                        catch(ListException e)
                        {
                            condition.Threshold_Category__c             = null;
                        }

                        //Required Values - Base
                        try
                        {
                            System.debug('condition.Threshold_Type__c :' + condition.Threshold_Type__c);
                            System.debug('condition.Threshold_Category__c :' + condition.Threshold_Category__c);

                            if(condition.Threshold_Type__c == 'Base')
                            {
                                System.debug('processAnswerXML :BASE');

                                if(condition.Threshold_Category__c == 'Number')
                                {
                                    System.debug('processAnswerXML : Number');
                                    condition.Required_Base_Number__c = Decimal.valueOf( (String)conditionBaseValues.get(i).getData() ); 
                                }

                                if(condition.Threshold_Category__c == 'Multiple') 
                                {
                                    System.debug('processAnswerXML : Multiple');

                                    condition.Required_Base_Multiple__c = Decimal.valueOf( (String)conditionBaseValues.get(i).getData() );  
                                }

                                if(condition.Threshold_Category__c == 'Percentage')
                                {
                                    System.debug('processAnswerXML : Percentage');

                                    condition.Required_Base_Percentage__c = Decimal.valueOf( (String)conditionBaseValues.get(i).getData() ); 
                                }

                                if(condition.Threshold_Category__c == 'Ratio')
                                {
                                    System.debug('processAnswerXML : RATIO');

                                    condition.Required_Base_Ratio_From__c = Decimal.valueOf( (String)conditionBaseValuesFrom.get(i).getData() ); 
                                    condition.Required_Base_Ratio_To__c = Decimal.valueOf( (String)conditionBaseValuesTo.get(i).getData() ); 
                                }
                            }                           
                        }
                        catch(Exception e)
                        {
                            System.debug('processAnswerXML :EXCEPTION: ' +  e.getMessage());

                            condition.Required_Base_Number__c = null;
                            condition.Required_Base_Multiple__c = null;
                            condition.Required_Base_Percentage__c = null;
                            condition.Required_Base_Ratio_From__c = null;
                            condition.Required_Base_Ratio_To__c = null;
                        }

                        //Threshold Comparator - Threshold_Comparator__c
                        try
                        {
                            condition.Threshold_Comparator__c           = (String)conditionThresholdComparators.get(i).getData();
                        }
                        catch(ListException e)
                        {
                            condition.Threshold_Comparator__c           = null; 
                        }                   

                        //Needed until the template has been updated to include a frequency for all condition types.
                        try
                        {
                            String frequency                = (String)conditionFrequencies.get(i).getData();
                            condition.Recurrence__c         = (frequency == 'semi-annually') ? 'Bi-Annually' : frequency;
                        }
                        catch(ListException e)
                        {
                            condition.Recurrence__c         = null;  
                        }
                        
                        condition.Date__c                   = (String)conditionRelativeDates.get(i).getData();

                        try
                        {
                            condition.Number_Of_Days__c     = Decimal.valueOf( (String)conditionNumberOfDays.get(i).getData() ); 
                        }
                        catch(Exception e) 
                        {
                            condition.Number_Of_Days__c     = null; 
                        }

                        //Due date handling.
                        try
                        {
                            String strDueDate               = (String)conditionDueDates.get(i).getData();
                            List<String> dateComponents     = new List<String>(strDueDate.split('/'));
                            condition.Due_Date__c           = Date.newInstance( Integer.valueOf(dateComponents.get(2)), Integer.valueOf(dateComponents.get(1)), Integer.valueOf(dateComponents.get(0)) );
                        }
                        catch(Exception e) 
                        {
                            condition.Due_Date__c           = null; 
                        }

                        //Other Relative Date handling.
                        try
                        {
                            String strOtherRelativeDate         = (String)conditionOtherRelativeDates.get(i).getData();
                            List<String> dateComponents2        = new List<String>(strOtherRelativeDate.split('/'));
                            condition.Other_Relative_Date__c    = Date.newInstance( Integer.valueOf(dateComponents2.get(2)), Integer.valueOf(dateComponents2.get(1)), Integer.valueOf(dateComponents2.get(0)) );
                        }
                        catch(Exception e) 
                        {
                            condition.Other_Relative_Date__c            = null; 
                        }

                        condition.Agreement__c              = iAgreementId;
                        condition.Matter__c                 = agreement.Matter_Deal__c;
                        condition.RecordTypeId              = conditionVariables.get(conditionVariable); 

                        //Add to list.
                        conditions.add(condition);  
                    }

                    //Insert conditions
                    upsert conditions; 
            
                    //Loop over the documents variable .
                    for(Integer i = 0; i < conditionDocuments.size()-1; i++) 
                    {
                        String plainNames = (String)conditionDocuments.get(i).getData();

                        //Make sure it is not blank or null.
                        if(!String.isBlank(plainNames))
                        {
                            List<String> documentNames = plainNames.split(',');

                            //Loop over documents.
                            for(String name : documentNames) 
                            {
                                Condition_Document__c document = new Condition_Document__c();
                                document.Condition__c = conditions.get(i).Id;

                                String documentName = name;
                                String documentType = 'Unknown';

                                document.Name = documentName;
                                document.Document_Type__c = documentType;

                                //Add to list.
                                documents.add(document);
                            }
                        }
                    }

                    //Insert documents. 
                    insert documents;
                }
            }
        }
        catch(Exception e)
        {
            throw new HotDocs_Service.HotDocs_API_Exception('HotDocs_Helper : processAnswerXML : Line: '+e.getLineNumber()+' Message: '+e.getMessage() ); 
        }

        System.debug('### HotDocs_Helper : processAnswerXML : END');
    }
    
    public static void processIsdaAnswerXML(String iAgreementId, String iAnswerXml) 
    {
        System.debug('### HotDocs_Helper : processLibraAnswerXML : START');

        Map<String, Agreement_Clause__c> existingAgreementClauses = new Map<String, Agreement_Clause__c>();
        Map<String, String> selectedAgreementClauses = new Map<String, String>();
        Map<String, Clause__c> hotDocsClauses = new Map<String, Clause__c>();
        List<Agreement_Clause__c> agreementClauseInsert = new List<Agreement_Clause__c>();
        List<Agreement_Clause__c> agreementClauseDelete = new List<Agreement_Clause__c>();
        
        Agreement__c agreementRecord = [
                SELECT 
                    Id,
                    Matter_Deal__c,
                    Agreement_Template__r.Clause_Origin__c,
                    Cash_Amount_counterparty__c,
                    Currency_Re_Counterparty__c,
                    Equity_Percentage_Counterparty__c,
                    Governing_Law__c
                FROM Agreement__c
                WHERE
                    Id = :iAgreementId
                LIMIT 1
            ];
        
      
        //Get all Agreement Clause linked to the Agreement
        for(Agreement_Clause__c eachAgreementClause : [SELECT Id, Agreement__c,Clause__c,Clause__r.Clause_Name__c
                                                      FROM Agreement_Clause__c
                                                      WHERE Agreement__c = :iAgreementId 
                                                      AND Clause__r.HotDocs__c = TRUE])
        {
            existingAgreementClauses.put(eachAgreementClause.Clause__r.Clause_Name__c, eachAgreementClause);
        }
                
        //Get all HotDocs Clauses
        for(Clause__c eachClause : [SELECT Id, Clause_Name__c, HotDocs__c
                                   FROM Clause__c
                                   WHERE HotDocs__c = TRUE])
        {
            hotDocsClauses.put(eachClause.Clause_Name__c, eachClause);      
        }
        
        try
        {
            //Make sure the Agreement Templates says we must insert from HotDocs.
            if(!String.isBlank(agreementRecord.Agreement_Template__r.Clause_Origin__c))
            {
                //Initilise parser.
                HotDocs_Parser parser = new HotDocs_Parser(iAnswerXml);
                
                //Query answer file and get data for variables.
                List<IHotDocs_Answer> clauseNames = parser.getAnswer('ADVL_Clause-t');
                List<IHotDocs_Answer> governingLaw = parser.getAnswer('ADVL_Governing_Law-t'); 
                List<IHotDocs_Answer> thresholdCashAmount = parser.getAnswer('ADVL_Cross_Default_Threshold_Cash_Amount-t');
                List<IHotDocs_Answer> thresholdCashCurrency = parser.getAnswer('ADVL_Cross_Default_Threshold_Cash_Currenency-t');
                List<IHotDocs_Answer> thresholdPercentage = parser.getAnswer('ADVL_Cross_Default_Threshold_Percentage-t');
            
                //Assign variables to Agreement Fields
                //Governing Law
                try
                {
                    if((String)governingLaw.get(0).getData() != null)
                    {
                        agreementRecord.Governing_Law__c = (String)governingLaw.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    agreementRecord.Governing_Law__c = null;
                }
                //Counterparty Threshold Cash Amount
                try
                {
                    if((String)thresholdCashAmount.get(0).getData() != null)
                    {
                        agreementRecord.Cash_Amount_counterparty__c = decimal.valueOf((String)thresholdCashAmount.get(0).getData());
                    }
                }
                catch(ListException e)
                {
                    agreementRecord.Cash_Amount_counterparty__c = null;
                }
                
                //Counterparty Threshold Currency
                try
                {
                    if((String)thresholdCashCurrency.get(0).getData() != null)
                    {
                        agreementRecord.Currency_Re_Counterparty__c = (String)thresholdCashCurrency.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    agreementRecord.Currency_Re_Counterparty__c = null;
                }
                
                //Counterparty Threshold Percentage
                try
                {
                    if((String)thresholdPercentage.get(0).getData() != null)
                    {
                        agreementRecord.Equity_Percentage_Counterparty__c = decimal.valueOf((String)thresholdPercentage.get(0).getData());
                    }
                    
                }
                catch(ListException e)
                {
                    agreementRecord.Equity_Percentage_Counterparty__c = null;
                }
                
                //Build Clauses for processing - 
                for(Integer i = 0; i < clauseNames.size()-1; i++) 
                {
                    String clauseTempName = (String)clauseNames.get(i).getData();
                    //Check if Clause already linked to Agreement, if not add to AgreementClauseInsert List
                    if(hotDocsClauses.containsKey(clauseTempName) == True && existingAgreementClauses.containsKey(clauseTempName) == False)
                    {
                        Agreement_Clause__c agreementClause  = new Agreement_Clause__c();
                        agreementClause.Agreement__c = agreementRecord.Id;
                        agreementClause.Clause__c = hotDocsClauses.get(clauseTempName).id;
                        
                        agreementClauseInsert.add(agreementClause);
                    } 
                    selectedAgreementClauses.put(clauseTempName, clauseTempName);
                }
                
                //Check if existing Clause already linked to Agreement, if not add to AgreementClauseInsert List
                for(String eachAgreementClause : existingAgreementClauses.KeySet()) 
                {
                    if(selectedAgreementClauses.containsKey(eachAgreementClause) == False)
                    {
                        agreementClauseDelete.add(existingAgreementClauses.get(eachAgreementClause));
                    } 
                }
                
                //Update Agreement
                Update agreementRecord;
                                
                //Insert Agreement Clauses
                if(!agreementClauseInsert.isEmpty())
                {
                    insert agreementClauseInsert;
                }
                
                //Delete Agreement Clauses
                if(!agreementClauseDelete.isEmpty())
                {
                    delete agreementClauseDelete;
                }
                
            }
        }
        catch(Exception e)
        {
            throw new HotDocs_Service.HotDocs_API_Exception('HotDocs_Helper : processLibraAnswerXML : Line: '+e.getLineNumber()+' Message: '+e.getMessage() ); 
        }

        System.debug('### HotDocs_Helper : processLibraAnswerXML : END');
    }

    public static void processPrimeServicesAnswerXML(String iAgreementId, String iAnswerXml) 
    {
        System.debug('### HotDocs_Helper : processPrimeServicesAnswerXML : START');

        Map<String, Supporting_Agreement__c> existingSupportingAgreements = new Map<String, Supporting_Agreement__c>();
        Map<String, String> selectedSupportingAgreements = new Map<String, String>();
        List<Supporting_Agreement__c> supportingAgreementsInsert = new List<Supporting_Agreement__c>();
        List<Supporting_Agreement__c> supportingAgreementsDelete = new List<Supporting_Agreement__c>();
        
        Agreement__c agreementRecord = [
                SELECT 
                    Id,
                    Matter_Deal__c,
                    Agreement_Template__r.Clause_Origin__c,
                    Cash_Amount_counterparty__c,
                    Currency_Re_Counterparty__c,
                    Equity_Percentage_Counterparty__c,
                    Governing_Law__c
                FROM Agreement__c
                WHERE
                    Id = :iAgreementId
                LIMIT 1
            ];
        
        
        //Get all HotDocs Supporting Agreements linked to the Agreement
        for(Supporting_Agreement__c eachSupportingAgreement : [SELECT Id, Agreement__c,Supporting_Agreement_Type__c
                                                      FROM Supporting_Agreement__c
                                                      WHERE Agreement__c = :iAgreementId 
                                                      AND HotDocs__c = TRUE])
        {
            existingSupportingAgreements.put(eachSupportingAgreement.Supporting_Agreement_Type__c, eachSupportingAgreement);
        }
        
        try
        {
            //Make sure the Agreement Templates says we must insert from HotDocs.
            if(agreementRecord.Agreement_Template__r.Clause_Origin__c == 'HotDocs')
            {
                //Initilise parser.
                HotDocs_Parser parser = new HotDocs_Parser(iAnswerXml);
                
                //Query answer file and get data for variables.
                List<IHotDocs_Answer> supportingAgreementNames = parser.getAnswer('ADVL_Relevant_Agreement-t');
                
                //Build Supporting Agreements for processing - Insert List
                for(Integer i = 0; i < supportingAgreementNames.size()-1; i++) 
                {
                    String supportingAgreementTemp = (String)supportingAgreementNames.get(i).getData();
                    //Check if Supporting Agreement already linked to Agreement, if not add to supportingAgreementsInsert List
                    if(existingSupportingAgreements.containsKey(supportingAgreementTemp) == False && supportingAgreementTemp != 'Master Prime Broking Agreement (MPBA)')
                    {
                        Supporting_Agreement__c supportingAgreement  = new Supporting_Agreement__c();
                        supportingAgreement.Agreement__c = agreementRecord.Id;
                        supportingAgreement.Supporting_Agreement_Type__c = supportingAgreementTemp;
                        supportingAgreement.HotDocs__c = True;
                        supportingAgreement.recordTypeId = supportingAgreementTypes.get('Default Supporting Agreement').getRecordTypeId();
                        
                        supportingAgreementsInsert.add(supportingAgreement);
                    } 
                    selectedSupportingAgreements.put(supportingAgreementTemp, supportingAgreementTemp);
                }
                
                //Check if existing Supporting Agreements already linked to Agreement, if not add to supportingAgreementsDelete List
                for(String eachSupportingAgreement : existingSupportingAgreements.KeySet()) 
                {
                    if(selectedSupportingAgreements.containsKey(eachSupportingAgreement) == False)
                    {
                        supportingAgreementsDelete.add(existingSupportingAgreements.get(eachSupportingAgreement));
                    } 
                }
              
                //Insert Supporting Agreements
                if(!supportingAgreementsInsert.isEmpty())
                {
                    insert supportingAgreementsInsert;
                }
                
                //Delete Supporting Agreements
                if(!supportingAgreementsDelete.isEmpty())
                {
                    delete supportingAgreementsDelete;
                }
                
            }
        }
        catch(Exception e)
        {
            throw new HotDocs_Service.HotDocs_API_Exception('HotDocs_Helper : processPrimeServicesAnswerXML : Line: '+e.getLineNumber()+' Message: '+e.getMessage() ); 
        }

        System.debug('### HotDocs_Helper : processPrimeServicesAnswerXML : END');
    }
    
    public static void processGmslaAnswerXML(String iAgreementId, String iAnswerXml) 
    {
        System.debug('### HotDocs_Helper : processGmslaAnswerXML : START');

        Map<String, Market_Collateral__c> existingMarketCollaterals = new Map<String, Market_Collateral__c>();
        Map<String, String> selectedMarketCollaterals = new Map<String, String>();
        List<Market_Collateral__c> marketCollateralsUpsert = new List<Market_Collateral__c>();
        List<Market_Collateral__c> marketCollateralsDelete = new List<Market_Collateral__c>();
        Map<String, Market_Collateral__c> marketCollateralsMap = new Map<String, Market_Collateral__c> ();
        
        Agreement__c agreementRecord = [
            SELECT 
                Id,
                Matter_Deal__c,
                Absa_as_Agent_Principal__c,
                Counterparty_as_Agent_Principal__c,
                Agreement_Template__r.Clause_Origin__c
            FROM Agreement__c
            WHERE
                Id = :iAgreementId
            LIMIT 1
        ];
        
        
        //Get all Market Collateral linked to the Agreement
        for(Market_Collateral__c eachMarketCollateral : [SELECT Id, Agreement__c,Collateral_Type__c, Sub_Type__c
                                                      FROM Market_Collateral__c
                                                      WHERE Agreement__c = :iAgreementId 
                                                      AND HotDocs__c = TRUE])
        {
            existingMarketCollaterals.put(eachMarketCollateral.Collateral_Type__c + '###' + eachMarketCollateral.Sub_Type__c , eachMarketCollateral);
        }
                        
        try
        {
            //Make sure the Agreement Templates says we must insert from HotDocs.
            if(agreementRecord.Agreement_Template__r.Clause_Origin__c == 'HotDocs')
            {
                //Initilise parser.
                HotDocs_Parser parser = new HotDocs_Parser(iAnswerXml);
                
                //Query answer file and get data for variables.
                List<IHotDocs_Answer> collateralType = parser.getAnswer('ADVL_Collateral_Type-t');
                List<IHotDocs_Answer> collateralSubType = parser.getAnswer('ADVL_Collateral_Subtype-t');
                List<IHotDocs_Answer> collateralMarginPercentage = parser.getAnswer('ADVL_Collateral_Margin_Percentage-n');
                
                List<IHotDocs_Answer> partyA_AgencyPrincipal = parser.getAnswer('ADVL_PartyA_Agency_Principal-t'); 
                List<IHotDocs_Answer> partyB_AgencyPrincipal = parser.getAnswer('ADVL_PartyB_Agency_Principal-t'); 
            
                //Assign variables to Agreement Fields
                //Party A Agency Principal
                try
                {
                    if((String)partyA_AgencyPrincipal.get(0).getData() != null)
                    {
                        agreementRecord.Absa_as_Agent_Principal__c = (String)partyA_AgencyPrincipal.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    agreementRecord.Absa_as_Agent_Principal__c = null;
                }
                //Party B Agency Principal
                try
                {
                    if((String)partyB_AgencyPrincipal.get(0).getData() != null)
                    {
                        agreementRecord.Counterparty_as_Agent_Principal__c = (String)partyB_AgencyPrincipal.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    agreementRecord.Counterparty_as_Agent_Principal__c = null;
                }
                
                //Market Collateral - Insert/Update (To determine how many Market Collaterals to Insert)
                for(Integer i = 0; i < collateralType.size()-1; i++) 
                {
                    String collateralTypeTemp = (String)collateralType.get(i).getData();
                    if(collateralTypeTemp != 'NONE' && collateralTypeTemp != NULL && collateralTypeTemp != '')
                    {
                        Market_Collateral__c marketCollateralTemp = new Market_Collateral__c();
                        marketCollateralTemp.Collateral_Type__c = collateralTypeTemp;
                        //marketCollateralTemp.Market_Collateral_Type__c = 'Acceptable Collateral';
                        marketCollateralsUpsert.add(createMarketCollateralRecord(iAgreementId, collateralTypeTemp, (String)collateralSubType.get(i).getData(), decimal.valueOf((String)collateralMarginPercentage.get(i).getData())));  
                        marketCollateralsMap.put(collateralTypeTemp + '###' + (String)collateralSubType.get(i).getData() + '###' + decimal.valueOf((String)collateralMarginPercentage.get(i).getData()), marketCollateralTemp);
                    }
                }
                
               //Market Collateral - Delete
               
               for(String eachCollateral : existingMarketCollaterals.keyset())
               {
                    if(!marketCollateralsMap.containsKey(eachCollateral))
                    {
                        marketCollateralsDelete.add(existingMarketCollaterals.get(eachCollateral));
                    }
               }
                
                                 
                //Update Agreement
                Update agreementRecord;
                                
                //Upsert Agreement Clauses
                System.debug('marketCollateralsUpsert : ' + marketCollateralsUpsert);
                if(!marketCollateralsUpsert.isEmpty())
                {
                    Upsert marketCollateralsUpsert;
                }
                
                //Delete Agreement Clauses
                System.debug('marketCollateralsDelete : ' + marketCollateralsDelete);
                if(!marketCollateralsDelete.isEmpty())
                {
                    delete marketCollateralsDelete;
                }
                
            }
        }
        catch(Exception e)
        {
            throw new HotDocs_Service.HotDocs_API_Exception('HotDocs_Helper : processGmslaAnswerXML : Line: '+e.getLineNumber()+' Message: '+e.getMessage() ); 
        }

        System.debug('### HotDocs_Helper : processGmslaAnswerXML : END');
    }
          
    public static void processGmraAnswerXML(String iAgreementId, String iAnswerXml) 
    {
        System.debug('### HotDocs_Helper : processGmraAnswerXML : START');

        Agreement__c agreementRecord = [
                SELECT 
                    Id,
                    Matter_Deal__c,
                    Buy_Sell_Back_Applies__c,
                    Transaction_Exposure_Calculation_Method__c,
                    Agreement_Template__r.Clause_Origin__c,
                    Bank_Minimum_Transfer_Amount__c,
                    Counterparty_Minimum_Transfer_Amount__c
                FROM Agreement__c
                WHERE
                    Id = :iAgreementId
                LIMIT 1
            ];
        
              
        try
        {
            //Make sure the Agreement Templates says we must insert from HotDocs.
            if(agreementRecord.Agreement_Template__r.Clause_Origin__c == 'HotDocs')
            {
                //Initilise parser.
                HotDocs_Parser parser = new HotDocs_Parser(iAnswerXml);
                
                //Query answer file and get data for variables.
                List<IHotDocs_Answer> buySellTransaction = parser.getAnswer('ADVL_Buy_Sell_Transactions-t'); 
                List<IHotDocs_Answer> transactionExposureMethod = parser.getAnswer('ADVL_Transaction_Exposure_Method-t'); 
                List<IHotDocs_Answer> partyAMinTransferAmount = parser.getAnswer('ADVL_PartyA_Minimum_Transfer_Amount-t'); 
                List<IHotDocs_Answer> partyBMinTransferAmount = parser.getAnswer('ADVL_PartyB_Minimum_Transfer_Amount-t'); 
                List<IHotDocs_Answer> baseCurrency = parser.getAnswer('ADVL_Base_Currency-t'); 

                //Base currency field.
                try {
                    if((String)baseCurrency.get(0).getData() != null) {
                        agreementRecord.Base_Currency__c = (String)baseCurrency.get(0).getData();
                    }
                }
                catch(ListException e) {
                    agreementRecord.Base_Currency__c = null;
                }
            
                //Assign variables to Agreement Fields
                //Party A Agency Principal
                try
                {
                    if((String)buySellTransaction.get(0).getData() != null)
                    {
                        if((String)buySellTransaction.get(0).getData() == 'true')
                        {
                            agreementRecord.Buy_Sell_Back_Applies__c = 'Yes';
                        }
                        else if ((String)buySellTransaction.get(0).getData() == 'false')
                        {
                            agreementRecord.Buy_Sell_Back_Applies__c = 'No';
                        }
                        
                    }
                }
                catch(ListException e) {
                    agreementRecord.Buy_Sell_Back_Applies__c = null;
                }
                //Party B Agency Principal
                try
                {
                    if((String)transactionExposureMethod.get(0).getData() != null)
                    {
                        agreementRecord.Transaction_Exposure_Calculation_Method__c = (String)transactionExposureMethod.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    agreementRecord.Transaction_Exposure_Calculation_Method__c = null;
                }
                
                //Part A - Min Transer Amount
                try
                {
                    if((String)partyAMinTransferAmount.get(0).getData() != null)
                    {
                        agreementRecord.Bank_Minimum_Transfer_Amount__c = decimal.valueOf((String)partyAMinTransferAmount.get(0).getData());
                    }
                }
                catch(ListException e)
                {
                    agreementRecord.Bank_Minimum_Transfer_Amount__c = null;
                }
                
                //Part B - Min Transer Amount
                try
                {
                    if((String)partyBMinTransferAmount.get(0).getData() != null)
                    {
                        agreementRecord.Counterparty_Minimum_Transfer_Amount__c = decimal.valueOf((String)partyBMinTransferAmount.get(0).getData());
                    }
                }
                catch(ListException e)
                {
                    agreementRecord.Counterparty_Minimum_Transfer_Amount__c = null;
                }
                
                System.debug('### HotDocs_Helper : processGmraAnswerXML : agreementRecord : ' + agreementRecord);
               
                //Update Agreement
                Update agreementRecord;
            }
        } 
        catch(Exception e)
        {
            throw new HotDocs_Service.HotDocs_API_Exception('HotDocs_Helper : processGmraAnswerXML : Line: '+e.getLineNumber()+' Message: '+e.getMessage() ); 
        }

        System.debug('### HotDocs_Helper : processGmraAnswerXML : END');
    }

    public static void processCsaAnswerXML(String iSupportingAgreementId, String iAnswerXml) 
    {
        System.debug('### HotDocs_Helper : processCsaAnswerXML : START');
        Map<String, Market_Collateral__c> existingMarketCollaterals = new Map<String, Market_Collateral__c>();
        Map<String, String> selectedMarketCollaterals = new Map<String, String>();
        List<Market_Collateral__c> marketCollateralsUpsert = new List<Market_Collateral__c>();
        List<Market_Collateral__c> marketCollateralsDelete = new List<Market_Collateral__c>();
        Map<String, Market_Collateral__c> marketCollateralsMap = new Map<String, Market_Collateral__c> ();

        Supporting_Agreement__c supportingAgreementRecord = [
                SELECT 
                    Id,
                    Base_Currency__c,
                    Collateral_type__c,
                    Bank_Independent_Amount_Type__c,
                    Bank_Independent_Amount_Initial_Margin__c,
                    Counterparty_Independent_Amount_Type__c,
                    Counterparty_Independent_Amount__c,
                    Bank_Collateral_Threshold_Amount_Type__c,
                    Bank_Collateral_Threshold_Fixed_Amount__c,
                    Counterparty_Collateral_Threshold_Fixed__c,
                    Counterparty_Collateral_Threshold_Amount__c,
                    Bank_Minimum_Transfer_Amount_Type__c,
                    Bank_Min_Transfer_Fixed_Amount__c,
                    Counterparty_Min_Transfer_Amount_Type__c,
                    Counterparty_Min_Transfer_Fixed_Amount__c,
                    Valuation_Date__c,
                    Weekday_that_Constitutes_Valuation_Date__c,
                    Agreement_Template__r.Clause_Origin__c
                FROM Supporting_Agreement__c
                WHERE
                    Id = :iSupportingAgreementId
                LIMIT 1
            ];    
        
        //Get all Market Collateral linked to the Agreement
        for(Market_Collateral__c eachMarketCollateral : [SELECT Id, Agreement__c,Collateral_Type__c, Sub_Type__c, Applicable_Party__C, Margin__c
                                                      FROM Market_Collateral__c
                                                      WHERE Supporting_Agreement__c = :iSupportingAgreementId 
                                                      AND HotDocs__c = TRUE])
        {
            existingMarketCollaterals.put(eachMarketCollateral.Collateral_Type__c + '###' + eachMarketCollateral.Applicable_Party__C , eachMarketCollateral);
        }
        
        try
        {
            //Make sure the Agreement Templates says we must insert from HotDocs.
            if(supportingAgreementRecord.Agreement_Template__r.Clause_Origin__c == 'HotDocs')
            {
                //Initilise parser.
                HotDocs_Parser parser = new HotDocs_Parser(iAnswerXml);
                
                //Query answer file and get data for variables.
                List<IHotDocs_Answer> baseCurrency = parser.getAnswer('ADVL_ English_Law_Base_Currency-t'); 
                List<IHotDocs_Answer> collateralType = parser.getAnswer('ADVL_Unilateral_CSA-t'); 
                List<IHotDocs_Answer> partyA_IndepType = parser.getAnswer('ADVL_PartyA_Independent_Amount_Option-t'); 
                List<IHotDocs_Answer> partyA_IndepAmount = parser.getAnswer('ADVL_PartyA_Independent_Amount-t'); 
                List<IHotDocs_Answer> partyB_IndepType = parser.getAnswer('ADVL_PartyB_Independent_Amount_option-t'); 
                List<IHotDocs_Answer> partyB_IndepAmount = parser.getAnswer('ADVL_PartyB_Independent_Amount-t'); 
                List<IHotDocs_Answer> partyA_ThresholdType = parser.getAnswer('ADVL_PartyA_Threshold_Option-t'); 
                List<IHotDocs_Answer> partyA_ThresholdAmount = parser.getAnswer('ADVL_PartyA_Threshold_Amount-t'); 
                List<IHotDocs_Answer> partyB_ThresholdType = parser.getAnswer('ADVL_PartyB_Threshold_Option-t'); 
                List<IHotDocs_Answer> partyB_ThresholdAmount = parser.getAnswer('ADVL_PartyB_Threshold_Amount-t'); 
                List<IHotDocs_Answer> partyA_MinTransferType = parser.getAnswer('ADVL_PartyA_MTA-t'); 
                List<IHotDocs_Answer> partyA_MinTransferAmount = parser.getAnswer('ADVL_PartyA_MTA_Amount-t'); 
                List<IHotDocs_Answer> partyB_MinTransferType = parser.getAnswer('ADVL_PartyB_MTA-t'); 
                List<IHotDocs_Answer> partyB_MinTransferAmount = parser.getAnswer('ADVL_PartyB_MTA_Amount-t'); 
                List<IHotDocs_Answer> valuationDate = parser.getAnswer('ADVL_Valuation_Date_Local_Business_Day-t'); 
                List<IHotDocs_Answer> valuationDateWeekday = parser.getAnswer('ADVL_Applicable_Weekeday-t'); 
                List<IHotDocs_Answer> marketCollateralType = parser.getAnswer('ADVL_Collateral_Type-t');
                List<IHotDocs_Answer> marketCollateralPercentage = parser.getAnswer('ADVL_Collateral_Valuation_Percentage-t');
                List<IHotDocs_Answer> marketCollateralPartyA = parser.getAnswer('ADVL_Collateral_PartyA_Applicable-t');

                //Assign variables to Supporting Agreement Fields
                //Base Currency 
                try
                {
                    if((String)baseCurrency.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Base_Currency__c = (String)baseCurrency.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Base_Currency__c = null;
                }
                //Collateral Type 
                try
                {
                    if((String)collateralType.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Collateral_type__c = (String)collateralType.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Collateral_type__c = null;
                }
                //Independent Amount - Party A (Bank)
                try
                {
                    if((String)partyA_IndepType.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Bank_Independent_Amount_Type__c = (String)partyA_IndepType.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Bank_Independent_Amount_Type__c = null;
                }
                try
                {
                    if((String)partyA_IndepAmount.get(0).getData() != null )
                    {
                        if((String)partyA_IndepAmount.get(0).getData() != 'NONE' )
                        {
                            supportingAgreementRecord.Bank_Independent_Amount_Initial_Margin__c = decimal.valueOf((String)partyA_IndepAmount.get(0).getData());
                        }
                        else
                        {
                            supportingAgreementRecord.Bank_Independent_Amount_Initial_Margin__c = null;
                        }
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Bank_Independent_Amount_Initial_Margin__c = null;
                }
                 //Independent Amount - Party B (Counterparty)
                try
                {
                    if((String)partyB_IndepType.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Counterparty_Independent_Amount_Type__c = (String)partyB_IndepType.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Counterparty_Independent_Amount_Type__c = null;
                }
                try
                {
                    if((String)partyB_IndepAmount.get(0).getData() != null)
                    {
                        if((String)partyB_IndepAmount.get(0).getData() != 'NONE' )
                        {
                            supportingAgreementRecord.Counterparty_Ind_Amount_Initial_Margin__c = decimal.valueOf((String)partyB_IndepAmount.get(0).getData());
                        }
                        else
                        {
                            supportingAgreementRecord.Counterparty_Ind_Amount_Initial_Margin__c = null;
                        }
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Counterparty_Ind_Amount_Initial_Margin__c = null;
                }
                //Threshold Amount - Party A (Bank)
                try
                {
                    if((String)partyA_ThresholdType.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Bank_Collateral_Threshold_Amount_Type__c = (String)partyA_ThresholdType.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Bank_Collateral_Threshold_Amount_Type__c = null;
                }
                try
                {
                    if((String)partyA_ThresholdAmount.get(0).getData() != null)
                    {
                        if((String)partyA_ThresholdAmount.get(0).getData() != 'NONE' )
                        {
                            supportingAgreementRecord.Bank_Collateral_Threshold_Fixed_Amount__c = decimal.valueOf((String)partyA_ThresholdAmount.get(0).getData());
                        }
                        else
                        {
                            supportingAgreementRecord.Bank_Collateral_Threshold_Fixed_Amount__c = null;
                        }
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Bank_Collateral_Threshold_Fixed_Amount__c = null;
                }
                 //Threshold Amount - Party B (Counterparty)
                try
                {
                    if((String)partyB_ThresholdType.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Counterparty_Collateral_T_Amount_Type__c = (String)partyB_ThresholdType.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Counterparty_Collateral_T_Amount_Type__c = null;
                }
                try
                {
                    if((String)partyB_ThresholdAmount.get(0).getData() != null)
                    {
                        if((String)partyB_ThresholdAmount.get(0).getData() != 'NONE' )
                        {
                            supportingAgreementRecord.Counterparty_Collateral_Threshold_Amount__c = decimal.valueOf((String)partyB_ThresholdAmount.get(0).getData());
                        }
                        else
                        {
                            supportingAgreementRecord.Counterparty_Collateral_Threshold_Amount__c = null;
                        }
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Counterparty_Collateral_Threshold_Amount__c = null;
                }
                //Minimum Transfer Amount - Party A (Bank)
                try
                {
                    if((String)partyA_MinTransferType.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Bank_Minimum_Transfer_Amount_Type__c = (String)partyA_MinTransferType.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Bank_Minimum_Transfer_Amount_Type__c = null;
                }
                try
                {
                    if((String)partyA_MinTransferAmount.get(0).getData() != null)
                    {
                        if((String)partyA_MinTransferAmount.get(0).getData() != 'NONE' )
                        {
                            supportingAgreementRecord.Bank_Min_Transfer_Fixed_Amount__c = decimal.valueOf((String)partyA_MinTransferAmount.get(0).getData());
                        }
                        else
                        {
                            supportingAgreementRecord.Bank_Min_Transfer_Fixed_Amount__c = null;
                        }
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Bank_Min_Transfer_Fixed_Amount__c = null;
                }
                 //Minimum Transfer Amount - Party B (Counterparty)
                try
                {
                    if((String)partyB_MinTransferType.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Counterparty_Min_Transfer_Amount_Type__c = (String)partyB_MinTransferType.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Counterparty_Min_Transfer_Amount_Type__c = null;
                }
                try
                {
                    if((String)partyB_MinTransferAmount.get(0).getData() != null)
                    {
                        if((String)partyB_MinTransferAmount.get(0).getData() != 'NONE' )
                        {
                            supportingAgreementRecord.Counterparty_Min_Transfer_Fixed_Amount__c = decimal.valueOf((String)partyB_MinTransferAmount.get(0).getData());
                        }
                        else
                        {
                            supportingAgreementRecord.Counterparty_Min_Transfer_Fixed_Amount__c = null;
                        }
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Counterparty_Min_Transfer_Fixed_Amount__c = null;
                }
                 //Valuation Date
                try
                {
                    if((String)valuationDate.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Valuation_Date__c = (String)valuationDate.get(0).getData();
                    }
                }
                catch(ListException e) 
                {
                    supportingAgreementRecord.Valuation_Date__c = null;
                }
                //Valuation Date - Weekday
                try
                {
                    if((String)valuationDateWeekday.get(0).getData() != null)
                    {
                        supportingAgreementRecord.Weekday_that_Constitutes_Valuation_Date__c = (String)valuationDateWeekday.get(0).getData();
                    }
                }
                catch(ListException e)
                {
                    supportingAgreementRecord.Weekday_that_Constitutes_Valuation_Date__c = null;
                }
                
                //Market Collateral - Insert/Update (To determine how many Market Collaterals to Insert)
                for(Integer i = 0; i < marketCollateralType.size()-1; i++) 
                {
                    String marketCollateralTypeTemp = (String)marketCollateralType.get(i).getData();
                    if(marketCollateralTypeTemp != 'NONE' && marketCollateralTypeTemp != NULL && marketCollateralTypeTemp != '')
                    {
                        Market_Collateral__c marketCollateralTemp = new Market_Collateral__c();
                        marketCollateralTemp.Market_Collateral_Type__c = 'Eligible Collateral';
                        marketCollateralTemp.Collateral_Type__c = marketCollateralTypeTemp;
                        marketCollateralTemp.Value__c = decimal.valueOf((String)marketCollateralPercentage.get(i).getData());
                        marketCollateralTemp.Applicable_Party__C = (String)marketCollateralPartyA.get(i).getData();
                        marketCollateralTemp.Supporting_Agreement__c = iSupportingAgreementId;
                        marketCollateralTemp.HotDocs__c = True; 
                        if(marketCollateralTypeTemp == 'Bonds')
                        {
                            marketCollateralTemp.Country_of_Issue__c = 'South Africa'; 
                        }
                        else
                        {
                            marketCollateralTemp.Country_of_Issue__c = null; 
                        }
                        marketCollateralsUpsert.add(marketCollateralTemp);  
                        marketCollateralsMap.put(marketCollateralTypeTemp + '###' + (String)marketCollateralPartyA.get(i).getData() , marketCollateralTemp);
                    }
                }
                
               //Market Collateral - Delete
               for(String eachCollateral : existingMarketCollaterals.keyset())
               {
                    if(!marketCollateralsMap.containsKey(eachCollateral))
                    {
                        marketCollateralsDelete.add(existingMarketCollaterals.get(eachCollateral));
                    }
               }
                                
                //Upsert Agreement Clauses
                System.debug('marketCollateralsUpsert : ' + marketCollateralsUpsert);
                if(!marketCollateralsUpsert.isEmpty()) 
                {
                    Upsert marketCollateralsUpsert;
                }
                
                //Delete Agreement Clauses
                System.debug('marketCollateralsDelete : ' + marketCollateralsDelete);
                if(!marketCollateralsDelete.isEmpty())
                {
                    delete marketCollateralsDelete;
                }
                
                
                //Update Supporting Agreement
                Update supportingAgreementRecord;
            }
        }
        catch(Exception e)
        {
            throw new HotDocs_Service.HotDocs_API_Exception('HotDocs_Helper : processCsaAnswerXML : Line: '+e.getLineNumber()+' Message: '+e.getMessage() ); 
        }

        System.debug('### HotDocs_Helper : processCsaAnswerXML : END');
    }
    
    @future(Callout=true)
    public static void retrieveDocument(String iRequestItemId)
    {
        System.debug('### HotDocs_Helper : retrieveDocument : START'); 

        //Get request item record.
        HotDocs_Request_Item__c requestItem = [
            SELECT
                Id,
                Status__c,
                Item_ID__c,
                HotDocs_Request__r.Work_Item_ID__c,
                Box_Document__c
            FROM HotDocs_Request_Item__c
            WHERE
                Id = :iRequestItemId 
        ];

        try
        {
            //New API Request.
            HotDocs_API api = new HotDocs_API();
            Blob fileBody = api.getWorkItemDocument(requestItem.HotDocs_Request__r.Work_Item_ID__c, requestItem.Item_ID__c);

            //Upload to box.
            Boolean uploadResult = BxdDocumentService.uploadHotDocsToBox(requestItem.Box_Document__c, fileBody);

            //Handle upload result.
            if(uploadResult == true)
            {
                requestItem.Status__c = 'Completed';  
            }
            else
            {
                requestItem.Status__c = 'Failed';
                throw new HotDocs_Service.HotDocs_API_Exception('Upload Failed');
            }           
        }
        catch(Exception e) 
        {
            DebugLog.create( new DebugLog.Error(e, 'HotDocs_Helper', 'retrieveDocument', 'Box Document ID: '+requestItem.Box_Document__c) );
        }
        finally
        {
            //Update the request item status.
            update requestItem; 
        }

        System.debug('### HotDocs_Helper : retrieveDocument : END');
    }

    public static void checkRequestStatus(List<HotDocs_Request_Item__c> iRequestItems, Map<Id, HotDocs_Request_Item__c> iOldMap)
    {
        try
        {
            Set<Id> hotdocsRequestIds = new Set<Id>();
            List<HotDocs_Request__c> hotdocsRequests = new List<HotDocs_Request__c>();

            for(HotDocs_Request_Item__c requestItem : iRequestItems) 
            {
                if(requestItem.Status__c == 'Completed' && iOldMap.get(requestItem.Id).Status__c != 'Completed')
                {
                    hotdocsRequestIds.add(requestItem.HotDocs_Request__c);
                }

                if(requestItem.Status__c == 'Failed' && iOldMap.get(requestItem.Id).Status__c != 'Failed')
                {
                    hotdocsRequestIds.add(requestItem.HotDocs_Request__c);
                }
            }

            //Fetch requests and items.
            hotdocsRequests = [
                SELECT
                    Id,
                    Status__c,
                    (
                        SELECT
                            Id,
                            Status__c,
                            HotDocs_Request__r.Agreement__r.Id
                        FROM HotDocs_Request_Items__r
                    )
                FROM HotDocs_Request__c
                WHERE
                    Id IN :hotdocsRequestIds
            ];

            //Loop over hotdocs request and detemine the final status based on items.
            for(HotDocs_Request__c hotdocsRequest : hotdocsRequests)
            {
                Boolean completed = true;
                Boolean failed = false;

                for(HotDocs_Request_Item__c requestItem : hotdocsRequest.HotDocs_Request_Items__r)
                {
                    if(requestItem.Status__c == 'Failed')
                    {
                        failed = true;   
                    }
                    else if(requestItem.Status__c != 'Completed' && requestItem.Status__c != 'Failed')
                    {
                        completed = false;
                    }
                }

                //Set the respective status.
                if(failed == true)
                {
                    hotdocsRequest.Status__c = 'Failed';
                    continue; 
                }
                else if(completed == true)
                {
                    hotdocsRequest.Status__c = 'Completed';
                    continue; 
                }
            }

            //Update parent record statuses.
            update hotdocsRequests;
        }
        catch(Exception e)
        {
            DebugLog.create( new DebugLog.Error(e, 'HotDocs_Helper', 'checkRequestStatus') ); 
        }
    }
    
    public static Market_Collateral__c createMarketCollateralRecord (Id agreementId, String collateralType, String collateralSubType, Decimal collateralMargin)
    {
        Map<String, Market_Collateral__c> existingMarketCollaterals = new Map<String, Market_Collateral__c>();
        Market_Collateral__c marketCollateralItem = new Market_Collateral__c();
        
        //Get all Agreement Clause linked to the Agreement
        for(Market_Collateral__c eachMarketCollateral : [SELECT Id, Agreement__c,Collateral_Type__c, Sub_Type__c, Margin__c
                                                      FROM Market_Collateral__c
                                                      WHERE Agreement__c = :agreementId 
                                                      AND HotDocs__c = TRUE])
        {
            existingMarketCollaterals.put(eachMarketCollateral.Collateral_Type__c + '###' + eachMarketCollateral.Sub_Type__c + '###' + eachMarketCollateral.Margin__c, eachMarketCollateral);
        }
        
        System.debug('### HotDocs_Helper : processGmslaAnswerXML: existingMarketCollaterals' + existingMarketCollaterals);
        
        //Update existing Market Collateral
        if(existingMarketCollaterals.containsKey(collateralType + '###' +collateralSubType + '###' + collateralMargin))
        {
            marketCollateralItem.id = existingMarketCollaterals.get(collateralType + '###' +collateralSubType+ '###' + collateralMargin).id;
            marketCollateralItem.Margin__c = collateralMargin;
        }
        //Create new Market Collateral
        else
        {
            marketCollateralItem.Agreement__c =  agreementId;
            marketCollateralItem.Collateral_Type__c = collateralType;
            if(collateralType != 'Cash' || collateralType != 'Other')
            {
                marketCollateralItem.Sub_Type__c = collateralSubType;
            }
            if(collateralType != 'Cash')
            {
                marketCollateralItem.Country_of_Issue__c = 'South Africa';
                
            }
            else
            {
                marketCollateralItem.Country_of_Issue__c = null;
            }
            if(collateralType == 'Cash' || collateralType == 'Other')
            {
                marketCollateralItem.Currency__c = 'ZAR - South African Rand';
            }
            
            marketCollateralItem.Margin__c = collateralMargin;
            marketCollateralItem.HotDocs__c = True;    
            marketCollateralItem.Market_Collateral_Type__c = 'Acceptable Collateral';
        }

        return marketCollateralItem;
    }
}