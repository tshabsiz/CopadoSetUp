/**
* 2017-10-16
* Rudolf Niehaus - CloudSmiths
* TEst class for MIDAS outbound calls - Payments_Outbound_Statements
**/
@IsTest(SeeAllData=true)
public class Payments_Outbound_Statements_Test {
    
     static testMethod void testMIDAS_Stat() {
         
                  
        String CUST = '028738';
        String CURR = 'ZAR';
        String ACOD = '0000006712';
        String ACSQ = '01';
        String FDATE = '20170701';
        String TDATE = '20170801';
        String STYPE = 'B';
        String SPAGE = '1';
        String SLINE = '999';
         
       Test.startTest();  
         
       Test.setMock(HttpCalloutMock.class, new Payments_Outbound_Statements_Mock());
       Payments_Outbound_Statements.postToMIDAS(CUST, CURR, ACOD, ACSQ, FDATE, TDATE, STYPE, SPAGE, SLINE);
        
       Test.stopTest();
     }

}