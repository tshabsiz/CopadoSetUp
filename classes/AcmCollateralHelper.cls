public with sharing class AcmCollateralHelper {
    public static void deleteAllBeneficariesForCollateral(Id CollateralId) {
        List<Collateral_Relationship__c> collateralRelationshipsTodelete = new List<Collateral_Relationship__c>();
        List<Collateral_Relationship__c> collateralRelationshipsUpdate = new List<Collateral_Relationship__c>();
        collateralRelationshipsTodelete = [SELECT Id, Name ,Relationship__c ,Relationship_Type__c, Collateral__c, Active__c, isPrimaryRelationship__c FROM Collateral_Relationship__c WHERE Collateral__c = :CollateralId AND Relationship_Type__c = 'Beneficiary'];
        if(collateralRelationshipsTodelete.size() > 0) {
			makeBeneficiariesInactive(collateralRelationshipsTodelete);
        }
    }
    
    public static void deleteAllFacilitiesForCollateral(Id CollateralId) {
        List<Collateral_Facility__c> collateralFacilitiesTodelete = new List<Collateral_Facility__c>();
        collateralFacilitiesTodelete = [SELECT Id, Name, Collateral__C, Facility_Client__c, AcmFacility__c, isPrimaryRelationship__c,Active__c FROM Collateral_Facility__c WHERE Collateral__c = :CollateralId];
        if(collateralFacilitiesTodelete.size() > 0) {
            makeFacilitiesInactive(collateralFacilitiesTodelete);
        }
    }
    
    public static void makeBeneficiariesInactive(List<Collateral_Relationship__c> collateralRelationshipsTodelete) {
        List<Collateral_Relationship__c> collateralRelationshipsUpdate = new List<Collateral_Relationship__c>();
        for(Collateral_Relationship__c CR : collateralRelationshipsTodelete) {
            Collateral_Relationship__c crupdate = CR;
            crupdate.Active__c = false;
            collateralRelationshipsUpdate.add(crupdate);
        }
        update collateralRelationshipsUpdate;
    }
    
    private static void makeFacilitiesInactive(List<Collateral_Facility__c> collateralFacilitiesToMakeInactive) {
        List<Collateral_Facility__c> collateralFacilitiesToUpdate = new List<Collateral_Facility__c>();
        for(Collateral_Facility__c cf : collateralFacilitiesToMakeInactive) {
            Collateral_Facility__c cfUpdate = cf;
            cfUpdate.Active__c = false;
            collateralFacilitiesToUpdate.add(cfUpdate);
        }
        update collateralFacilitiesToUpdate;
    }
    
    public static void createRelationshipForCollateral(List<Collateral__c> collaterals) {
        List<Collateral_Relationship__c> collateralRelationshipstoInsert = new List<Collateral_Relationship__c>();
        for(Collateral__c collateral : collaterals) {
            collateralRelationshipstoInsert.addAll(createCollateralRelationship(collateral));
        }
        if(collateralRelationshipstoInsert.size() > 0) {
            upsert collateralRelationshipstoInsert;
        }
    }
    
    public static Collateral__c getCollateralFromId(List<Collateral__c> collaterals, Id id) {
        for(Collateral__c collateral : collaterals) {
            if(collateral.Id == id) {
                return collateral;
            }
        }
        return null;
    }
    
    public static void updateCollateralFacilities(List<Collateral__c> collaterals, List<Collateral__c> oldCollaterals) {
        List<Collateral_Facility__c> collateralFacilities = [SELECT Id, Name, Collateral__C, Facility_Client__c, AcmFacility__c, isPrimaryRelationship__c,Active__c FROM Collateral_Facility__c 
                                                             WHERE isPrimaryRelationship__c = true AND
                                                             Collateral__c IN :oldCollaterals];


        List<Collateral_Facility__c> collateralFacilitiesUpserts = new List<Collateral_Facility__c>();
        for(Collateral_Facility__c cf : collateralFacilities) {
            if(cf.Active__c == true) {
                for(Collateral__c c : collaterals){
                    if(c.Id == cf.Collateral__c) {
                        cf.Facility_Client__c = c.Facility_Client__c;
                        cf.AcmFacility__c = c.AcmFacility__c;
                    }
                }
                collateralFacilitiesUpserts.add(cf);
            }
        }
        
        for(Collateral__c c : collaterals) {
            if(c.Scope__c == 'Facility' && collateralFacilitiesUpserts.size() == 0) {
            	collateralFacilitiesUpserts.add(createCollateralFacility(c));
            }
        }

        upsert collateralFacilitiesUpserts;
    }
    
    public static void validateBeneficiaryAndFacility(List<Collateral__c> collaterals, List<Collateral__c> oldCollaterals) {
        List<Collateral_Relationship__c> collateralRelationshipInserts = new List<Collateral_Relationship__c>();
        List<Collateral_Facility__c> collateralFacilityInserts = new List<Collateral_Facility__c>();
        
        List<Id> collateralsToDeleteFacilities = new List<Id>();
        List<Id> collateralsToDeleteRelationships = new List<Id>();
        
        for(Collateral__c collateral : collaterals) {
            Collateral__c beforeUpdate = getCollateralFromId(oldCollaterals, collateral.Id);
            if(beforeUpdate != null){
                if(beforeUpdate.Scope__c == 'Facility' && collateral.Scope__c == 'Beneficiary') {
                    collateralRelationshipInserts.add(createCollateralBeneficiary(collateral));
                    collateralsToDeleteFacilities.add(beforeUpdate.Id);
                } else if(beforeUpdate.Scope__c == 'Beneficiary' && collateral.Scope__c == 'Facility') {                    
                    collateralFacilityInserts.add(createCollateralFacility(collateral));
                    collateralsToDeleteRelationships.add(beforeUpdate.Id);
                }
            }
        }
        
        if(collateralRelationshipInserts.size() > 0){
            upsert collateralRelationshipInserts;
        }
        
        if(collateralFacilityInserts.size() > 0){
            upsert collateralFacilityInserts;
        }
        
        // Delete all other non related relationships
        if(collateralsToDeleteFacilities.size() > 0)	{
            List<Collateral_Facility__c> collateralFacilities = [SELECT Id, Name, Collateral__C, Facility_Client__c, AcmFacility__c, isPrimaryRelationship__c FROM Collateral_Facility__c 
                                                                 WHERE isPrimaryRelationship__c = true AND
                                                                 Collateral__c IN :collateralsToDeleteFacilities];
            makeFacilitiesInactive(collateralFacilities);
        } 
        
        if(collateralsToDeleteRelationships.size() > 0) {
           List<Collateral_Relationship__c> collateralRelationships = [SELECT Id, Name,Relationship__c, Relationship_Type__c, Collateral__c, Active__c, isPrimaryRelationship__c FROM Collateral_Relationship__c 
                                                                WHERE isPrimaryRelationship__c = true AND
                                                                Relationship_Type__c = 'Beneficiary' AND
                                                                Collateral__c IN :collateralsToDeleteRelationships];
            makeBeneficiariesInactive(collateralRelationships);
        }
        
    }
    
    public static void updateRelationshipForCollateral(List<Collateral__c> collaterals, List<Collateral__c> oldCollaterals) {
        
        
        List<Collateral_Relationship__c> collateralRelationships = [SELECT Id, Name,Relationship__c, Relationship_Type__c, Collateral__c, Active__c, isPrimaryRelationship__c FROM Collateral_Relationship__c 
                                                                    WHERE isPrimaryRelationship__c = true AND
                                                                    Collateral__c IN :oldCollaterals];


        List<Collateral_Relationship__c> collateralRelationshipsUpserts = new List<Collateral_Relationship__c>();
        for(Collateral_Relationship__c cr : collateralRelationships) {
            if(cr.Active__c == true) {
                for(Collateral__c c : collaterals) {
                    if(c.Id == cr.Collateral__c) {
                        if(cr.Relationship_Type__c == 'Provider') {
                            cr.Relationship__c = c.Account__c;
                        } else if(cr.Relationship_Type__c == 'Beneficiary') {
                            cr.Relationship__c = c.Beneficiary__c; 
                        }
                    }
                }
                collateralRelationshipsUpserts.add(cr);
            }
        }
        upsert collateralRelationshipsUpserts;
    }
    
    public static Collateral_Relationship__c createCollateralBeneficiary(Collateral__c collateral) {
        Collateral_Relationship__c collateralRelationship = null;
        List<Collateral_Relationship__c> collateralRelationships = [SELECT Id, Relationship__c, Name, Relationship_Type__c, Collateral__c, Active__c, isPrimaryRelationship__c FROM Collateral_Relationship__c 
                                                                    WHERE Relationship__c = :collateral.Beneficiary__c 
                                                                    AND Relationship_Type__c = 'Beneficiary'
                                                                    AND Collateral__c = :collateral.Id
                                                                    AND isPrimaryRelationship__c = true
                                                                    AND Active__c = false];
        if(collateralRelationships.size() == 0) {
            collateralRelationship = new Collateral_Relationship__c(Relationship__c = collateral.Beneficiary__c, 
                                                                    Relationship_Type__c = 'Beneficiary', Collateral__c = collateral.Id, isPrimaryRelationship__c = true);
        } else {
            collateralRelationship = collateralRelationships.get(0);
            collateralRelationship.Active__c = true;
        }
        
        return collateralRelationship;   
    }
    
    public static List<Collateral_Relationship__c> createCollateralRelationship(Collateral__c collateral) {
        List<Collateral_Relationship__c> collateralRelationshipInserts = new List<Collateral_Relationship__c>(); 
        if(collateral.Account__c != null) {
            if(collateral.Scope__c == 'Beneficiary') {
                 collateralRelationshipInserts.add(createCollateralBeneficiary(collateral));
            }
            
            Collateral_Relationship__c collateralRelationship = new Collateral_Relationship__c(Relationship__c = collateral.Account__c, 
                                                                                               Relationship_Type__c = 'Provider', Collateral__c = collateral.Id, isPrimaryRelationship__c = true);
            
            collateralRelationshipInserts.add(collateralRelationship);
        }
        return collateralRelationshipInserts;
    }
    
    public static void createCollateralFacilities(List<Collateral__C> collaterals) {
        List<Collateral_Facility__c> collateralFacilitytoInsert = new List<Collateral_Facility__c>();
        for(Collateral__C collateral : collaterals) {
            Collateral_Facility__c cf = createCollateralFacility(collateral);
            if(cf != null) {
                collateralFacilitytoInsert.add(cf);
            }
        }
        upsert collateralFacilitytoInsert;
    }
    
    public static Collateral_Facility__c createCollateralFacility(Collateral__C collateral) {
        if(collateral.Scope__c == 'Facility' && collateral.AcmFacility__c != null && collateral.Facility_Client__c != null) {
            Collateral_Facility__c collateralFacility = null;
            List<Collateral_Facility__c> collateralFacilities = [SELECT Id, Name, Collateral__C, Facility_Client__c, AcmFacility__c, isPrimaryRelationship__c,Active__c
                                                                 FROM Collateral_Facility__c
                                                                 WHERE Collateral__C = :collateral.Id 
                                                                 AND Facility_Client__c = :collateral.Facility_Client__c
                                                                 AND AcmFacility__c = :collateral.AcmFacility__c
                                                                 AND isPrimaryRelationship__c = true
                                                                 AND Active__c = false];
            
            if(collateralFacilities.size() == 0) {
                collateralFacility = new Collateral_Facility__c(Collateral__C = collateral.Id, Facility_Client__c = collateral.Facility_Client__c, 
                                                                                       AcmFacility__c = collateral.AcmFacility__c, isPrimaryRelationship__c = true); 
                return collateralFacility;
            } else {
                collateralFacility = collateralFacilities.get(0);
                collateralFacility.Active__c = true;
                return collateralFacility;
            }

        }
        return null;
    }
}