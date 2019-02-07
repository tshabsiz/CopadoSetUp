/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
                                                           
 
*** CHANGE LOG ***
 
 28/06/2017 - PG    - Created Class.
            
**/  
public class Collateral_Clone 
{
    /**
    * Variables
    **/
    public Collateral__c objectRecord { get; set; }
    public List<Collateral_Relationship__c> collateralRelationships { get; set; }
    public List<Collateral_Facility__c> collateralFacilities { get; set; }
    
    /**
    * Constructor
    **/
    public Collateral_Clone(ApexPages.StandardController stdController)
    {
        //Blank var.
        collateralRelationships = new List<Collateral_Relationship__c>();
        List<String> fields = new List<String> {
            //Details
            'id',
            'Name',
            'Value_Type__c',
            'Value__c',
            'Comments__c',
            'Status__c',
            'Country__c',
            'OwnerId',
            // Collateral Mitigant 
            'Scope__c',
            'Account__c',
            'Beneficiary__c',
            'Facility_Client__c',
            'AcmFacility__c',
            'Collateral_Group__c',
            'Collateral_Type1__c',
            //Documentation
            'Document_Name__c',
            'Supporting_Documentation_Uploaded__c',
            'Document_Type__c',
            'Document_Expiry_Date__c',
            'Physical_Location__c',
            'Manager__c',
            //Asset Information
            'Has_Underlying_Assets__c',
            'Asset_Description__c',
            //Dates
            'Expiry_Date__c',
            'Signature_Date__c'
        };
        
        if(!Test.isRunningTest())
        {
            //Add fields
            stdController.addFields(fields);
        }
                
        //Get the page record.
        Collateral__c originalRecord = (Collateral__c)stdController.getRecord();
        
        //Get originl relationships.
        collateralRelationships = [
            SELECT
                Id,
                Collateral__c,
                Relationship__c,
                Relationship_Type__c,
            	Active__c,
            	isPrimaryRelationship__c
            FROM Collateral_Relationship__c
            WHERE
                Collateral__c = :originalRecord.Id
        ];  
        
        collateralFacilities = [
            SELECT
                Id,
            	Name,
            	Collateral__c,
            	Facility_Id__c,
            	Facility_Client__c,
            	Active__c,
            	AcmFacility__c,
            	isPrimaryRelationship__c
            FROM Collateral_Facility__c
            WHERE
                Collateral__c = :originalRecord.Id
        ];
        
        //Clone the record without id.
        this.objectRecord = originalRecord.clone(false, true);
        
        //Change some fields for the cloned record.
        objectRecord.Status__c = 'Outstanding';
        objectRecord.OwnerId = UserInfo.getUserId();
        objectRecord.Supporting_Documentation_Uploaded__c = false;
        
    }
    
    /**
    * action - cloneCollateral
    **/
    public PageReference cloneCollateral()
    {
        //Database savepoint
        Savepoint dbSavePoint = Database.setSavepoint();
        
        try
        {
            //insert parent record.
            insert objectRecord;
            
            //Any facilities.
            if(!collateralFacilities.isEmpty())
            {
                //Clone original list.
                List<Collateral_Facility__c> collateralFacilitiesInserts = collateralFacilities.deepClone();
                
                //Loop through existing and build new list.
                for(Collateral_Facility__c collateralFacilityInsert : collateralFacilitiesInserts)
                {
                    collateralFacilityInsert.Collateral__c = objectRecord.Id;
                }
                
                //Insert Facilities.
                insert collateralFacilitiesInserts;
            }
            
            if(!collateralRelationships.isEmpty())
            {
                //Clone original list.
                List<Collateral_Relationship__c> collateralRelationshipInserts = collateralRelationships.deepClone();
                
                //Loop through existing and build new list.
                for(Collateral_Relationship__c collateralRelationshipInsert : collateralRelationshipInserts)
                {
                    collateralRelationshipInsert.Collateral__c = objectRecord.Id;
                }
                
                //Insert relationships.
                insert collateralRelationshipInserts;
            }
            
            //Redirect to new record page.
            PageReference standardPage = new PageReference('/'+objectRecord.Id); 
            standardPage.setRedirect(true);
            
            //Redirect.
            return standardPage;
        }
        catch(Exception e)
        {
            //Rollback db.
            Database.rollback(dbSavePoint); 
        }
        
        //Default return. 
        return null;
    }
}