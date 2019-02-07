@isTest

private class LsceEmailOutput_test {
    
    
 	public static testMethod void testClonePricingTemplate(){
        
        
        Messaging.InboundEmail InboundEmail  = new Messaging.InboundEmail();
        Messaging.InboundEnvelope InboundEnvelope = new Messaging.InboundEnvelope();
        
        
      lscEmailOutputFromExchangeTest a = new lscEmailOutputFromExchangeTest(InboundEmail, InboundEnvelope);
        
    }
    
}