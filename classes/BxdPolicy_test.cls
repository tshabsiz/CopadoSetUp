@IsTest
public class BxdPolicy_test {
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json = '{\"type\":\"A\",\"status\":\"A\",\"retention_length\":1,\"policy_type\":\"A\",\"policy_name\":\"A\",\"is_ongoing\":false,\"id\":\"1\",\"filter_started_at\":\"A\",\"filter_ended_at\":\"A\",\"disposition_action\":\"A\",\"description\":\"A\"}';
        BxdPolicy r = BxdPolicy.parse(json);
        BxdPolicy.getJsonString(r);
        System.assert(r != null);
        
        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        BxdPolicy objBxdPolicy = new BxdPolicy(System.JSON.createParser(json));
        System.assert(objBxdPolicy != null);
        System.assert(objBxdPolicy.type_Z == null);
        System.assert(objBxdPolicy.status == null);
        System.assert(objBxdPolicy.retention_length == null);
        System.assert(objBxdPolicy.policy_type == null);
        System.assert(objBxdPolicy.policy_name == null);
        System.assert(objBxdPolicy.is_ongoing == null);
        System.assert(objBxdPolicy.id == null);
        System.assert(objBxdPolicy.filter_started_at == null);
        System.assert(objBxdPolicy.filter_ended_at == null);
        System.assert(objBxdPolicy.disposition_action == null);
        System.assert(objBxdPolicy.description == null);
    }
}