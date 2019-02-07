/**
* @author Deloitte
* @date 2015
*
* @group Unit Tests
*
* @description Unit Tests Helper - Data Container 
*/
@isTest
public class ZZTEST_DataContainer {

	private Map<Schema.sObjectType,Map<Schema.RecordTypeInfo, Map<Id, SObject>>> data;
    private Map<Id,Schema.RecordTypeInfo> storedRecTypes;
    public SObject lastInserted {get; private set;}
    private Map<Schema.sObjectType,Map<Schema.RecordTypeInfo,Sobject>> lastInsertedObjects;

	public ZZTEST_DataContainer() {
		data = new Map<Schema.sObjectType,Map<Schema.RecordTypeInfo,Map<Id,SObject>>>();
        storedRecTypes = new Map<Id,Schema.RecordTypeInfo>();
        lastInsertedObjects = new Map<Schema.sObjectType,Map<Schema.RecordTypeInfo,Sobject>>();	
    }

	/*
		Puts the object (record) inside data container. Updates last inserted.

		@param SObject rec - object to be put inside container
	*/
    public void put(SObject rec)
    {
    	// Get info about the object to be put inside map
        system.debug('Method-Start: ZZTEST_DataContainer.put');
        Id recId = rec.id;
        Schema.sObjectType objType = rec.getSObjectType();
        Schema.DescribeSObjectResult descObjRes = objType.getDescribe();
        Schema.RecordTypeInfo recTypeInfo = null;

        // Try getting record type 
        try
        {
            Id recTypeId = (Id)rec.get('recordTypeId');
            recTypeInfo = descObjRes.getRecordTypeInfosById().get(recTypeId);
            storedRecTypes.put(recTypeId, recTypeInfo);
        }
        catch(Exception exc)
        {
            System.debug('Failed to get recordTypeInfo');
        }
       	
       	// See if the record type of requested object already exists inside the map
        Map<Schema.RecordTypeInfo,Map<Id,SObject>> objMap = data.get(objType);

        if(objMap != null)
        {
            Map<Id,SObject> recTypeMap = objMap.get(recTypeInfo);
            if(recTypeMap != null)
                recTypeMap.put(rec.id, rec);
            else
                objMap.put(recTypeInfo, new Map<Id,SObject> {rec.id => rec} );
        }
        else
            data.put(objType, new Map<Schema.RecordTypeInfo,Map<Id,SObject>>{recTypeInfo => new Map<Id,SObject>{rec.id => rec}});
       
        setLastInserted(objType, recTypeInfo, rec);
       
        System.debug('Method-End: ZZTEST_DataContainer.put');
    }
   
   	/*
		Puts the object list into the data container. 
		@param List<SObject> reclist - List of objects
	*/
    public void put(List<SObject> recList)
    {
        for(SObject obj : recList)
            put(obj);
    }
   
    /*
		Puts the object set into the data container. 
		@param Set<SObject> reclist - set of objects
	*/
    public void put(Set<SObject> recSet)
    {
        for(SObject obj : recSet)
            put(obj);
    }
   
   	/*
   		Overridden toString() method to describe contents of data container in understandable format.
   		@returns customized description of the container 
   	*/
    public override String toString()
    {
        String result = '\n';
        for (Schema.sObjectType objType : data.keySet())
        {
            result += ('OBJECT TYPE '+objtype+'\n');
            for(Schema.RecordTypeInfo recTypeInfo : data.get(objType).keySet())
            {
                result += 'RECORD TYPE ';
                if (recTypeInfo == null)
                {
                    result += 'null\n';
                }
                else
                {
                    result += recTypeInfo.getName()+'\n';
                }
               
                for(Id recId : data.get(objType).get(recTypeInfo).keySet())
                {
                    result += ('ID:'+recId);
                    result += (' - - RECORD:'+data.get(objType).get(recTypeInfo).get(recId)+'\n');
                }
                result += '\n';
            }
        }
        return result;
    }
   
    /*
		Fills the log with understandable description of the contents of data container
    */
    public void debug()
    {
        system.debug(logginglevel.ERROR , toString());
    }
   
    /*
		Method to get map of existing objects within the container for provided object, considers all recordtypes
		@param Schema.sObjectType sObjType - object's type we want to get the map for
		@returns Map<Schema.RecordTypeInfo,Map<Id,SObject>> - map with relation to recordtype -> map of <Id,sObject>
	*/
    public Map<Schema.RecordTypeInfo,Map<Id,SObject>> getSObjectMap(Schema.sObjectType sObjType)
    {
        Map<Schema.RecordTypeInfo,Map<Id,SObject>> result = data.get(sObjType);
        if(result == null)
            result = new Map<Schema.RecordTypeInfo,Map<Id,SObject>>();

        //for(Schema.RecordTypeInfo recType : result.keySet())
        //    system.debug('recType: '+recType);

        return result;
    }
   
    /*
		Method to get map of existing objects within the container for specific recordType
		@param Schema.sObjectType sObjType - object's type we want to get the map for
		@param Schema.RecordTypeInfo recTypeInfo - record type of the object we want to get the map for
		@returns  Map<Id, SObject> - map of objects for requested record type
	*/
    public Map<Id, SObject> getRecordTypeMap(Schema.sObjectType sObjType, Schema.RecordTypeInfo recTypeInfo)
    {
        // System.debug('getRecordTypeMap - ObjectType: '+sObjType+', recTypeInfo: '+recTypeInfo);
        // Map<Schema.RecordTypeInfo,Map<Id,SObject>> tempDebugMap =  getSObjectMap(sObjType);
        // System.debug('tempDebugMap.containsKey(recTypeInfo): '+tempDebugMap.containsKey(recTypeInfo));
       
        Map<Schema.RecordTypeInfo,Map<Id,SObject>> objectMap = getSObjectMap(sObjType);
       
        Schema.RecordTypeInfo storedType = recTypeInfo != null ? storedRecTypes.get(recTypeInfo.getRecordTypeId()) : null;

        Map<Id,SObject> result = getSObjectMap(sObjType).get(storedType);
        if(result == null)
            result = new Map<Id,SObject>();

        return result;
    }
    
    /*
		Method to get stored record type if one exists within the container, otherwise returns null
		@param Schema.RecordTypeInfo recTypeInfo - record type info for requested record type 
		@returns Schema.RecordTypeInfo recTypeInfo - record type info for requested rt if found, otherwise null
	*/
    private Schema.RecordTypeInfo getStoredRecordType(Schema.RecordTypeInfo recTypeInfo)
    {
        if(storedRecTypes.containsKey(recTypeInfo.getRecordTypeId()))
        	return storedRecTypes.get(recTypeInfo.getRecordTypeId());
        
        return null;
    }
   
    /*
		Method to get last inserted object to data container for given record type and object type
		@param Schema.sObjectType objType - object type 
		@param Schema.RecordTypeInfo recTypeInfo - record type info
		@returns SObject - last inserted object if exists for parameters, otherwise null
	*/
    public SObject getLastInserted(Schema.sObjectType objType, Schema.RecordTypeInfo recTypeInfo)
    {
        if(lastInsertedObjects.containsKey(objType) && lastInsertedObjects.get(objType).containskey(recTypeInfo))
            return lastInsertedObjects.get(objType).get(recTypeInfo);

        return null;
    }

    /*
		Method to set last inserted object by provided paramters 
		@param Schema.sObjectType objType - object type 
		@param Schema.RecordTypeInfo recTypeInfo - record type info
		@param SObject sObj - the object itself to be set
	*/
    private void setLastInserted(Schema.sObjectType objType, Schema.RecordTypeInfo recTypeInfo, SObject sObj)
    {
        lastInserted = sObj;
        return;
        /*
        Schema.RecordTypeInfo storedRecTypeInfo = getStoredRecordType(recTypeInfo);
        if(lastInsertedObjects.containsKey(objType))
        {
            /*
             * Normaly we would ask now:             *
             * if(lastInsertedObjects.get(objType).containsKey(storedRecTypeInfo))
             *
             * But:
             * We don't care whether there is already an Record for this RecordType or not. We put it in the Map anyways.
    		*
            lastInsertedObjects.get(objType).put(storedRecTypeInfo, sObj);
           
        }
        else
        {
            lastInsertedObjects.put(objType, new Map<Schema.RecordTypeInfo,Sobject> {storedRecTypeInfo => sObj});
        } */
    }
}