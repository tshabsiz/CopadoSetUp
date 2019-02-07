public class BoxDocumentViewHelper {
    private static final String AUTO_NUMBER_FIELD = 'Document_Number__c';
    private static BoxDocumentViewHelper instance = null;
    public Map<String, String> bxdRelLookup;
    
    private void BoxDocumentViewHelper(){}
    
    public static BoxDocumentViewHelper getInstance()
    {
        if(instance == null) instance = new BoxDocumentViewHelper();
        return instance;
    }
    
    public string QueryCreator(Id bxdId) 
    {
        return QueryCreator(bxdId, null, null);
    }
    
    public string QueryCreator(Id boxDocumentId, Id ParentId, RelatedListBxd boxRelatedList) 
    {
        SetupRelationshipsMap();
        String Query = 'Select Id, Upload_Date__c, send_to_docusign__c, PII__c, Drawdown__c, Expiry_Date__c, ParentName__c, Account__r.Name, Matter__r.Name, Agreement__r.Name, Collateral__r.Name, Condition_Occurrence__r.Name, Condition__r.Name, Drawdown__r.Name, Facility__r.Name, Facility_Tranche__r.Name, SPV_Item__r.Name, Agency_Transfer__r.Name, Collateral_Valuation__r.Name, Collateral_Monitoring__r.Name, Watcher__r.Name, Trigger__r.Name, Margin_Ratchet__r.Name, Owner_Type__c, Document_Number__c, Name, Type__c, Status__c, Box_Location__c, Box_Unique_Id__c from BoxDocument__c Where Id !=null';
        
        if (boxDocumentId != null)
        {
            Query = 'Select Id, Upload_Date__c, send_to_docusign__c, PII__c, Drawdown__c, Expiry_Date__c, ParentName__c, Account__r.Name, Matter__r.Name, Agreement__r.Name, Collateral__r.Name, Condition_Occurrence__r.Name, Condition__r.Name, Drawdown__r.Name, Facility__r.Name, Facility_Tranche__r.Name, SPV_Item__r.Name, Agency_Transfer__r.Name, Collateral_Valuation__r.Name, Collateral_Monitoring__r.Name, Watcher__r.Name, Trigger__r.Name, Margin_Ratchet__r.Name, Owner_Type__c, Document_Number__c, Name, Type__c, Status__c, Box_Location__c, Box_Unique_Id__c from BoxDocument__c Where Id = ' +'\''+ boxDocumentId +'\'';           
        }
        else
        {
            if (ParentId != null)
            {
                Query += GenerateParentQuery(ParentId);   
            }
            if (boxRelatedList != null) // seperated this out for clarity but should be combined below. Either way, compiler will take care of it
            {
                if (boxRelatedList.filtered == true)
                {
                    String filterQuery = Filter(boxRelatedList);
                    if (filterQuery == null || filterQuery == '' )
                    {
                        Query += ''; 
                    }
                    else
                    {
                        Query += filterQuery;
                    }
                }
            }
            if (boxRelatedList !=null)
            {
                Query += ' Order By ' + boxRelatedList.sortField + ' ' + Ascend(boxRelatedList);
            }
        } 
        
        system.debug('QUERY CREATOR '+Query);
        return Query;
    }
    
    private String GenerateParentQuery(Id ParentId)
    {   
        String ParentQuery;
        Schema.SObjectType ObjType =  ParentId.getSobjectType();
        if (String.valueOf(ObjType) == 'Account'||String.valueOf(ObjType) == 'Condition__c')
        {
            Schema.DescribeSObjectResult ObjTypeDesc = ObjType.getDescribe();
            String relLookupField = bxdRelLookup.get(ObjTypeDesc.getName());
            ParentQuery = ' And ( '+relLookupField+'.Id = ' + '\''+ParentId+ '\'';
            ParentQuery += getRollup(ParentId);
            ParentQuery += ')';
            return ParentQuery;
        }
        else
        {
            Schema.DescribeSObjectResult ObjTypeDesc = ObjType.getDescribe();
            String relLookupField = bxdRelLookup.get(ObjTypeDesc.getName());
            return ' And '+relLookupField+'.Id = ' + '\''+ParentId+ '\'';
        }
        
    }
    private void SetupRelationshipsMap()
    {
        bxdRelLookup = getBoxDocumentFieldRelationshipsMap();
    }
    
    private String Ascend(RelatedListBxd Bxd)
    {
        if (Bxd.ordered == true)
        {
            Bxd.ordered = false;
            return 'ASC NULLS LAST';
        }
        else
        {
            Bxd.ordered = true;
            return 'DESC NULLS LAST';
        }
    }
    
    private String Filter (RelatedListBxd boxRelatedList)
    {
        BoxDocument__c boxDocumentObj = boxRelatedList.boxDocument;
        String filterQuery = '';
        SObjectType bxdType = Schema.getGlobalDescribe().get('BoxDocument__c');
        Map<String,Schema.SObjectField> bxdFieldMap = bxdType.getDescribe().fields.getMap();
        for (Schema.SObjectField filterField : bxdFieldMap.values())
        {
            try
            {
                String filterFieldString = filterField.getDescribe().getName();
                Object filterFieldvalue = AUTO_NUMBER_FIELD.equals(filterFieldString)? String.isBlank(boxRelatedList.documentNumber) ? null : boxRelatedList.documentNumber : boxDocumentObj.get(filterField);             
                if (filterFieldvalue != null)
                {
                    Schema.DescribeFieldResult filterFieldDesc = filterField.getDescribe();
                    Schema.DisplayType filterFieldType = filterFieldDesc.getType();
                    
                    if(AUTO_NUMBER_FIELD.equals(filterFieldString)){
                        filterQuery += ' And ' + filterField + ' = '+ '\''+filterFieldvalue+'\'';
                    }
                    else if (filterFieldType == Schema.DisplayType.STRING)
                    {
                        filterQuery += ' And ' + filterField + ' LIKE \'%' + String.escapeSingleQuotes((String) filterFieldvalue) + '%\'';
                    }
                    else
                    {
                        filterQuery += ' And ' + filterField + ' = '+ '\''+filterFieldvalue+'\'';   
                    }
                }
                
            }
            catch (exception e)
            {
                system.debug('Filter - Field not populated');
                system.debug(filterField);
            }
            
        }
        
        return filterQuery;
    }
    
    
    public List<String> getBoxDocumentFieldNames(){
        List<String> result = new list<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.BoxDocument__c.fields.getMap();
        Schema.DisplayType fieldType = Schema.DisplayType.REFERENCE;
        
        for(String key : fieldMap.KeySet())
        {
            if(fieldMap.get(key).getDescribe().isCustom() && fieldType == fieldMap.get(key).getDescribe().getType()){
                result.add(fieldMap.get(key).getDescribe().getName());
            }           
        }
        return result;
    }
    
    public Map<String, String> getBoxDocumentFieldRelationshipsMap(){
        Map<String, String> result = new Map<String, String>();     
        Map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.BoxDocument__c.fields.getMap();
        Schema.DisplayType fieldType = Schema.DisplayType.REFERENCE;
        
        for(String key : fieldMap.KeySet())
        {
            if(fieldMap.get(key).getDescribe().isCustom() && fieldType == fieldMap.get(key).getDescribe().getType()){
                Schema.SObjectField field = fieldMap.get(key);
                Schema.DescribeFieldResult fieldDesc = field.getDescribe();
                result.put(fieldDesc.getReferenceTo().get(0).getDescribe().getName(), fieldMap.get(key).getDescribe().getRelationshipName());
            }           
        }
        return result;
    }
    
    public static String getRollup (Id ParentId)
    {
        /*
* Get the Account.
* From the Account get the related deals from the deal party 
* From the deals get the related agreements
* from related agreements get the related conditions
* from the related conditions get the related condition occurences
* 
* Add an or in the where caluse with a buch of related ids
*/
        system.debug('getAccountRollup');
        String query;
        ParentId.getSobjectType();
        Schema.SObjectType ObjType =  ParentId.getSobjectType();
        system.debug('ObjType');
        system.debug(ObjType);
        
        if (String.valueOf(ObjType) == 'Account')
        {
            List <String> dealParentId = new  List <String>();
            List <String> agreementParentId = new  List <String>();
            List <String> conditionParentId = new  List <String>();
            List <String> conditionOccurencesParentId = new  List <String>();
            system.debug('Related List  - Parent Object is Account');
            Account acc = [Select Id, Name, (Select Id,Party_Type__c, Name, Deal__r.Name from Deal_Parties__r) from Account where Id = :ParentId];
            system.debug('Related List - Owner Account');
            system.debug(acc);
            List <Deal_Party__c> accDealParties = acc.Deal_Parties__r;
            For (Deal_Party__c accDealParty:accDealParties)
            {
                system.debug('Deal Party');
                system.debug(accDealParty);
                if (accDealParty.Party_Type__c == 'Borrower')
                {
                    system.debug('Related List - Deal Party Borrower');
                    advpm__Matter__c deal = accDealParty.Deal__r;
                    system.debug('Related List - Deal');
                    system.debug(deal);
                    dealParentId.add('\''+deal.Id+'\'');
                    system.debug('Related List - Fetch the Agreement_Party for Deals');
                    List <Agreement_Party__c> agreementParties = [Select Name, Agreement__r.Name from Agreement_Party__c Where Deal_Party__c=:accDealParty.Id];
                    system.debug(agreementParties);
                    system.debug('Related List - Fetch the Agreement from Agreement_Party');
                    for (Agreement_Party__c agreementParty:agreementParties)
                    {
                        Agreement__c agreement = agreementParty.Agreement__r;
                        system.debug('Related List - Agreement');
                        system.debug(agreement);
                        agreementParentId.add('\''+agreement.Id+'\'');
                        system.debug('Related List - Fetch the Condition_Party for Agreement_Party');
                        List <Condition_Party__c> conditionParties = [Select Name, Condition__r.Name from Condition_Party__c Where Agreement_Party__c=:agreementParty.Id];
                        system.debug('Fetch the Condition');
                        for (Condition_Party__c conditionParty:conditionParties)
                        {
                            system.debug('Related List - Fetch the Condition');
                            Condition__c condition = conditionParty.Condition__r;
                            system.debug(condition);
                            conditionParentId.add('\''+condition.Id+'\'');
                            system.debug('Related List - Fetch the Condition_Occurences');
                            List <Condition_Occurrence__c> condition_occurences = [Select Name from Condition_Occurrence__c where Condition__c=:condition.Id];
                            for(Condition_Occurrence__c condition_occur:condition_occurences)
                            {
                                system.debug('Related List - Fetch the Condition_Occur');
                                system.debug(condition_occur);
                                conditionOccurencesParentId.add('\''+condition_occur.Id+'\'');                              
                            }
                            
                        }
                    }
                    
                }
                
                else
                {
                    system.debug('Related List: This deal party is not catered for');
                }
                
            }
            system.debug('Completed Related List Ids');
            system.debug('Completed Related List Matter');
            system.debug(dealParentId);
            system.debug('Completed Related List Agreement Id');
            system.debug(agreementParentId);
            system.debug('Completed Related List Condition Id');
            system.debug(conditionParentId);
            system.debug('Completed Related List ConditionOccur Id');
            system.debug(conditionOccurencesParentId);
            system.debug('Related List Query Parts');
            system.debug('dealQueryPart');
            String dealQueryPart = generateQuery(dealParentId, 'Matter__c');
            system.debug(dealQueryPart);
            system.debug('agreementQueryPart');
            String agreementQueryPart = generateQuery(agreementParentId, 'Agreement__c');
            system.debug(agreementQueryPart);
            system.debug('conditionQueryPart');
            String conditionQueryPart = generateQuery(conditionParentId, 'Condition__c');
            system.debug(conditionQueryPart);
            system.debug('conditionOccurenceQueryPart');
            String conditionOccurenceQueryPart = generateQuery(conditionOccurencesParentId, 'Condition_Occurrence__c');
            system.debug(conditionOccurenceQueryPart);
            system.debug('Complete Related List Query Parts ');
            query = dealQueryPart + agreementQueryPart + conditionQueryPart + conditionOccurenceQueryPart;
            system.debug(query);
        }
        Else If (String.valueOf(ObjType) == 'Condition__c')
        {
            List <String> conditionOccurencesParentId = new  List <String>();
            List <Condition_Occurrence__c> condition_occurences = [Select Name from Condition_Occurrence__c where Condition__c=:ParentId];
            for(Condition_Occurrence__c condition_occur:condition_occurences)
            {
                system.debug('Related List - Fetch the Condition_Occur');
                system.debug(condition_occur);
                conditionOccurencesParentId.add('\''+condition_occur.Id+'\'');                              
            }
            String conditionOccurenceQueryPart = generateQuery(conditionOccurencesParentId, 'Condition_Occurrence__c');
            system.debug(conditionOccurenceQueryPart);
			query = conditionOccurenceQueryPart;
        }
        Else
        {
            system.debug('Related List  - Not a Rollup Object');
            
        }
        
        Return query;
    }
    
    public static String generateQuery (List<String> IdList, String ObjectName)
    {
        system.debug('generateQuery');
        String queryPart = '';
        String packedList = packListCSV(IdList);
        system.debug('generateQuery - packedList');
        system.debug(packedList);
        packedList = packedList.trim();
        if (packedList == null||packedList ==''||packedList =='null')
        {
           //do nothing
           
        }
        else
        {
         
          system.debug('generateQuery - packedList not empty');
          queryPart += ' OR '+ObjectName+ ' in ( ';  
          queryPart += packedList;  
          queryPart +=' )';
        }
        system.debug('generateQuery - queryPart');
        system.debug(queryPart);
        return queryPart;
    }
    
    public static String packListCSV (List<String> InList)
    {
        String csvData = '';
        Integer i = 1;
        Integer lsize = InList.size();
        for (String lItem:InList) 
        {
            if (lItem == null||lItem ==''||lItem=='null')
            {
                //do nothing
            }
            else
            {
                if((lsize - i)==0)
                {
                    csvData += lItem;    
                }
                else
                {
                    csvData += lItem +',';  
                }
            }
            i++;
        }
        return csvData;
    }
    
}