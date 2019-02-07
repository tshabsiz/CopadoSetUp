/**
* 2017-10-16
* Rudolf Niehaus - CloudSmiths
* TEst class for MIDAS outbound calls - Payments_Outbound_Deal
**/
@IsTest(SeeAllData=true)
public class Payments_Outbound_Deal_Test {
    
    static testMethod void testMIDAS_Deal() {
               
        String INPUTKEY = 'P170704AAAAIN00';

       Test.startTest();  
         
       Test.setMock(HttpCalloutMock.class, new Payments_Outbound_Deal_Mock());
       Payments_Outbound_Deal.postToMIDAS(INPUTKEY);
        
       Test.stopTest();
     }

}