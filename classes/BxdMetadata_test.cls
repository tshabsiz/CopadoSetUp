@isTest
public class BxdMetadata_test {
    
    static testMethod void testBxdMetadata(){    
    	Test.startTest();
        String json = '{"/$id":"1","/type":"A","/parent":"2","/scope":"A","/template":"A"}';
        BoxGenericJsonObject objBoxGenericJsonObject = new BoxGenericJsonObject(json);
        BxdMetadata mainClass = new BxdMetadata(objBoxGenericJsonObject);
        System.assert(mainClass != null);
        System.assert(mainClass.getID() == null);
        System.assert(mainClass.getTypeName() == null);
        System.assert(mainClass.getParentID() == null);
        System.assert(mainClass.getScope() == null);
        System.assert(mainClass.getTemplateName() == null);
        Test.stopTest();
    }
    
    static testMethod void testGetPropertyPaths(){
    	Test.startTest();
        BxdMetadata mainClass = new BxdMetadata();
        
        System.assert(mainClass != null);
        System.assert(mainClass.get('/id') == null);
        System.assert(mainClass.getPropertyPaths().size() == 0);
        mainClass = mainClass.add('/id','1');
        System.assert(mainClass != null);
        System.assert(mainClass.get('id') == null);
        System.assert(mainClass.get(null) == null);
        System.assert(mainClass.get('/id') != null);
        System.assert(mainClass.getPropertyPaths().size() != 0);
        
        BxdMetadata newMainClass = new BxdMetadata(mainClass);
        System.assert(mainClass != null);
        System.assert(mainClass.get('id') == null);
        System.assert(mainClass.get('/id') != null);
        System.assert(mainClass.getPropertyPaths().size() != 0);
        Test.stopTest();
    }
    
    
        static testMethod void testScopeBasedOnType(){
    	Test.startTest();    
        String DEFAULT_METADATA_TYPE = 'properties';
	    String GLOBAL_METADATA_SCOPE = 'global';

    	String ENTERPRISE_METADATA_SCOPE = 'enterprise';
            
        BxdMetadata.scopeBasedOnType(DEFAULT_METADATA_TYPE);
        System.assert(BxdMetadata.scopeBasedOnType(DEFAULT_METADATA_TYPE) == GLOBAL_METADATA_SCOPE);
        System.assert(BxdMetadata.scopeBasedOnType(GLOBAL_METADATA_SCOPE) == ENTERPRISE_METADATA_SCOPE);
        
        Test.stopTest();
    }
}