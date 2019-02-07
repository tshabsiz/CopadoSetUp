/**
* 2017-10-16
* Rudolf Niehaus - CloudSmiths
* TEst class for MIDAS outbound calls - Payments_Outbound_BIC
**/
@IsTest(SeeAllData=true)
public class Payments_Outbound_BIC_Test {

    static testMethod void testMIDAS_BIC() {
               
        String CUSTKEY = '028738';

       Test.startTest();  
         
       Test.setMock(HttpCalloutMock.class, new Payments_Outbound_BIC_Mock());
       Payments_Outbound_BIC.postToMIDAS(CUSTKEY);
        
       Test.stopTest();
     }
    
}