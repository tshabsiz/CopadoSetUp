@IsTest
public class BxdTokenExchange_test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'    \"access_token\": \"1!cVSHtzcs5BFQC6UoeRYJK6I0cRAQR9mDB9KB0Su7a4dOumHMv1Ns-j-500yId-S0Yf-Uf8rlfU5cyUk4nWjPRafmjoEwBkiXfNqGLx0v5LvqW_TTClgK0hrUUArsWrmPy9Xb2P2BFPSZUC-onQ1jFILQZPxx9ylc11VYO1T17xRDsafj-goJWsTE6QGS9ZDDvYSsgZAxJHkX6AEplsphAsi5yT1RnE2OB1_sSx_JdYE0DUJUYICpgI4VEW5jWXxA9f9YrWnQb8HSd8dE1_DjNsMWmZVcpWml7kASD8J0kjhkfbpdaVQODAEDSiZ_Yna-cDB7UOrTL9CP2Q1HELsrNRcSR0MlMDKsOt7OAGLY5BQAGYSzHiaWKlGqN6hx4gnac9WzhAW5mj9iNkE67tZpduEnbTMkVCPKohmDVk0cAzIxehmi9MwTD8LFn8VS6ShpmtN3wh_ReoXp\",'+
		'    \"expires_in\": 4175,'+
		'    \"token_type\": \"bearer\"'+
		'}';
		BxdTokenExchange r = BxdTokenExchange.parse(json);
        BxdTokenExchange.getJsonString(r);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BxdTokenExchange objBxdTokenExchange = new BxdTokenExchange(System.JSON.createParser(json));
		System.assert(objBxdTokenExchange != null);
		System.assert(objBxdTokenExchange.access_token == null);
		System.assert(objBxdTokenExchange.expires_in == null);
		System.assert(objBxdTokenExchange.token_type == null);
	}
}