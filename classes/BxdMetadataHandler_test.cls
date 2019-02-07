@isTest
public class BxdMetadataHandler_test {
    public static testMethod void TestMetadata() {
        //SETUP 
        List<String> expectedFooList = new List<String>();
        expectedFooList.add('/foo');
        String expectedBar = 'bar';
        
        //Test behaviors
        BxdMetadata meta = new BxdMetadata();      
        System.assertEquals('{}', meta.toString());
        BxdMetadata m1 = new BxdMetadata().add('/foo', 'bar');
        BxdMetadata m2 = new BxdMetadata(m1);
        System.assertEquals('{\"foo\":\"bar\"}', m2.toString());
        List<String> actualMetas = m2.getPropertyPaths();
        system.assertEquals(actualMetas, expectedFooList);
        String actualBar = m1.get('/foo');
        system.assertEquals(actualBar, expectedBar);
        
        m2.getID();
        m2.getParentID();
        m2.getScope();
        m2.getTemplateName();
        m2.getTypeName();   
        
        String responseR = '{"access_token":"mNr1FrCvOeWiGnwLL0OcTL0Lux5jbyBa","expires_in":4169,"restricted_to":[],"token_type":"bearer", "total_count":1,"entries":[{"type":"file","id":"198538570868"}], "shared_link":{"url":"https://app.box.com"}}';
        BxdMetadata jsonObject = new BxdMetadata(new BoxGenericJsonObject(responseR));
        system.assert(jsonObject != null);
    }
}