public class lscEmailOutputFromExchangeTest {
    public lscEmailOutputFromExchangeTest (Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
        
         //----- RN - DEBUG SECTION -----
        System.debug(' ---------------- EMAIL DEBUG SECTION START ------------------');
        System.debug('email.headers:' + email.headers);
        System.debug('email.fromAddress:' + email.fromAddress);
        System.debug('email.fromName:' + email.fromName);
        System.debug('email.inReplyTo:' + email.inReplyTo);
        System.debug('email.messageId:' + email.messageId);
        System.debug('email.replyTo:' + email.replyTo);
        System.debug('email.toAddresses:' + email.toAddresses);
        System.debug('email.references:' + email.references);
        System.debug('email.ccAddresses:' + email.ccAddresses);
        System.debug('envelope.fromAddress:' + envelope.fromAddress);
        System.debug('envelope.toAddress:' + envelope.toAddress);
        System.debug(' ---------------- EMAIL DEBUG SECTION STOP ------------------');

    }
}