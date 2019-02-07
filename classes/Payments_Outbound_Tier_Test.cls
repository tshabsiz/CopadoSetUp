/**
* 2017-10-16
* Rudolf Niehaus - CloudSmiths
* TEst class for MIDAS outbound calls - Payments_Outbound_Tier
**/
@IsTest(SeeAllData=true)
public class Payments_Outbound_Tier_Test {
    
    static testMethod void testMIDAS_Tier() {
               
        String INPUTKEY = '028787ZAR000000671201';

       Test.startTest();  
         
       Test.setMock(HttpCalloutMock.class, new Payments_Outbound_Tier_Mock());
       Payments_Outbound_Tier.postToMIDAS(INPUTKEY);
        
       Test.stopTest();
     }
}