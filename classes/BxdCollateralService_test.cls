@Istest
public class BxdCollateralService_test {
    Public static void setup(){
	Account TestAccount;
    Collateral__c TestCollateral;
    Collateral_Relationship__c TestCollateralRelationship;      
        System.debug('TestAccount : '+ TestAccount);
        //ACCOUNT
        TestAccount = new Account
            (
                Name ='test',
                Type = 'Client',
                SDS__c = 'SDS'
            );
        Insert TestAccount;
        System.debug('ACCOUNT : '+ TestAccount);
        
        // COLLATERAL GROUP
        Collateral_Group__c TestCollateralGroup = new Collateral_Group__c
            (
                Name = 'AVIATION BOND',
                Credit_Code__c = 'AVIATION_BOND'
            );
		insert TestCollateralGroup;
        
        // COLLATERAL TYPE
        Collateral_Type__c TestCollateralType = new Collateral_Type__c
            (
                Name = 'AVIATION BOND',
                Collateral_Group__c = TestCollateralGroup.Id,
                Credit_Code__c = 'AVIATION_BOND',
                Push_to_ACM__c = true
            );
        Insert TestCollateralType;
        
        // COLLATERAL
        TestCollateral = new Collateral__c
            (
                Scope__c = 'Beneficiary',
                Name = 'Collateral Test',
                Status__c = 'Outstanding',
                Beneficiary__c = TestAccount.Id,
                Account__c = TestAccount.Id,
                Collateral_Group__c = TestCollateralGroup.Id,
                Collateral_Type1__c = TestCollateralType.Id
            );
        insert TestCollateral;

        //COLLATERAL RELATIONSHIP
        TestCollateralRelationship = new Collateral_Relationship__c
        (
            Collateral__c = TestCollateral.Id,
            Relationship__c = TestAccount.Id,
            Relationship_Type__c = 'Beneficiary'
        );
        insert TestCollateralRelationship;
        system.debug('COLL REL '+TestCollateralRelationship);
    }
    
    
    Public Static testmethod void BxdLegalQuoteServiceM(){
        test.StartTest();
        setup(); 
        test.StopTest();   
    }
}