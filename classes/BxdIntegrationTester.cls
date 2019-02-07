global class BxdIntegrationTester {
    global class BoxReponse {
        webservice Id responseId;
        webservice String responseMessage;
    }
    webService static String sendMessage(String messageId) {  
        DateTime current = System.now();
        String result = messageId + ' : ' + current ;
        return result;
    }
}