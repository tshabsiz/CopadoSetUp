/**
*** CHANGE LOG ***

10/01/2018 - TdB    - Created Class.

**/ 
@isTest(SeeAllData=false)
public class Relationship_Parties_Bulk_Test {
    public static testMethod void testClass_AgreementLevel()
    {
        //Test Data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        //VF page
        PageReference pageRef = Page.Relationship_Parties_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testEventMarginRatchet.id);

        Relationship_Parties_Bulk ec = new Relationship_Parties_Bulk();
        
         test.startTest();

        ec.relationshipParties_Wrapper[0].selected = true;

        //Methods
        ec.saveRecord();
        
        ec = new Relationship_Parties_Bulk();
        ec.relationshipParties_Wrapper[0].selected = false;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();
    }
    
    public static testMethod void testClass_FacilityLevel()
    {
        //Test Data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        testDataClass.testCovenantMarginRatchet.Facility__c = testDataClass.TestFacility.id;
        update testDataClass.testCovenantMarginRatchet;
        
         test.startTest();
        
        //VF page
        PageReference pageRef = Page.Relationship_Parties_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testCovenantMarginRatchet.id);

        Relationship_Parties_Bulk ec = new Relationship_Parties_Bulk();

        ec.relationshipParties_Wrapper[0].selected = false;

        //Methods
        ec.saveRecord();
        
        ec = new Relationship_Parties_Bulk();
        ec.relationshipParties_Wrapper[0].selected = true;
        
        //Methods
        ec.saveRecord();
        
        ec = new Relationship_Parties_Bulk();
        ec.relationshipParties_Wrapper[0].selected = false;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();
    }
    
    public static testMethod void testClass_TrancheLevel()
    {
        //Test Data
        Cloudsmiths_TestDataClass  testDataClass = new Cloudsmiths_TestDataClass();
        
        testDataClass.testCovenantMarginRatchet.Facility__c = testDataClass.TestFacility.id;
        testDataClass.testCovenantMarginRatchet.Facility_Tranche__c = testDataClass.TestFacilityTranche.id;
        update testDataClass.testCovenantMarginRatchet;
        
         test.startTest();
        
        //VF page
        PageReference pageRef = Page.Relationship_Parties_Bulk;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('sObjectId', testDataClass.testCovenantMarginRatchet.id);

        Relationship_Parties_Bulk ec = new Relationship_Parties_Bulk();

        ec.relationshipParties_Wrapper[0].selected = false;

        //Methods
        ec.saveRecord();
        
        ec = new Relationship_Parties_Bulk();
        ec.relationshipParties_Wrapper[0].selected = true;
        
        //Methods
        ec.saveRecord();
        
        test.stopTest();
    }

}