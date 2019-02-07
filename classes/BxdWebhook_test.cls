@isTest
public class BxdWebhook_test {

    static testMethod void testBxdWebhook(){
                String json = '{\"type\":\"A\",\"triggers\":[\"A\",\"B\"],\"target\":{\"type\":\"A\",\"id\":\"1\"},\"id\":\"1\",\"created_by\":{\"name\":\"A\",\"id\":\"1\"},\"address\":\"A\"}';
        BxdWebhook r = BxdWebhook.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        BxdWebhook.Target objTarget = new BxdWebhook.Target(System.JSON.createParser(json));
        System.assert(objTarget != null);
        System.assert(objTarget.type == null);
        System.assert(objTarget.id == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        BxdWebhook.Created_by objCreated_by = new BxdWebhook.Created_by(System.JSON.createParser(json));
        System.assert(objCreated_by != null);
        System.assert(objCreated_by.name == null);
        System.assert(objCreated_by.id == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        BxdWebhook objBxdWebhook = new BxdWebhook(System.JSON.createParser(json));
        System.assert(objBxdWebhook != null);
        System.assert(objBxdWebhook.type == null);
        System.assert(objBxdWebhook.triggers == null);
        System.assert(objBxdWebhook.target == null);
        System.assert(objBxdWebhook.id == null);
        System.assert(objBxdWebhook.created_by == null);
        System.assert(objBxdWebhook.address == null);
        
        BxdWebhook objBxdWebhookJsonString = new BxdWebhook();
        BxdWebhook.getJsonString(objBxdWebhookJsonString);
    }
}