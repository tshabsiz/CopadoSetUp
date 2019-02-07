/**
* @Author       Svatopluk Sejkora
* @Company:     Deloitte
* @Description: Contains static methods for JSON processing.
* @Date:        2015
* @ConstructorParam:      None
* @TestClass:   ZZTEST_JsonUtils 
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 25.2.2016   Marek Cech         Added returnJSONStringMobile and getVisualBaseURL methods.
*------------------------------------------------------------*/
public class JsonUtils {

    private static final String visualBaseURLName = 'Visual';

    @testVisible
    private static final String TEST_JSON_RETURN = '{"pickList":[{"value":"1 - MONETARY AUTHORITY","code":1155},{"value":"2 - BANKS","code":1156}, {"value":"11510 - GAME PROPAGATION", "code":"11510"}, {"value":"Foreign Companies", "code":"9"}, {"value":"MARKETS", "code":"1225"}, {"value":"MANAGER", "code":"01"}]}';

     /**
      * @Author:          Svatopluk Sejkora
      * @Company:         Deloitte
      * @Description:     retreive JSON string from static resource
      * @Params:          String zipFile, String fileName, String extension, String resourceName
      * @Returns:         String with JSON values for picklist
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static String returnJSONString(String zipFile, String fileName, String extension, String resourceName) {
    
        String fileString;
        StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name =:resourceName LIMIT 1];
        String srPath = '/resource/' + sr.SystemModstamp.getTime() + '/' + zipFile + '/' + fileName + '.' + extension;
        
        PageReference file = new PageReference(srPath);        
        try {
            fileString = file.getContent().toString();
        } catch(Exception e) {
            System.Debug('Provided parameteres are not valid ' + e);
        }
        
        if(Test.isRunningTest()) {
            String testString = TEST_JSON_RETURN;
            return testString;    
        } else {
            return fileString;
        }
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     retreive JSON string from static resource for mobile pages
      * @Params:          String zipFile, String fileName, String extension, String resourceName
      * @Returns:         String with JSON values for picklist
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static String returnJSONStringMobile(String zipFile, String fileName, String extension, String resourceName) {
    
        String base = getVisualBaseURL();
        String fileString;
        StaticResource sr = [SELECT Id,NamespacePrefix,SystemModstamp FROM StaticResource WHERE Name =:resourceName LIMIT 1];
        String srPath =  base + '/resource/' + sr.SystemModstamp.getTime() + '/' + zipFile + '/' + fileName + '.' + extension;
        
        PageReference file = new PageReference(srPath);   
        try {
            fileString = file.getContent().toString();
        } catch(Exception e) {
            System.Debug('Provided parameteres are not valid ' + e);
        }
        
        if(Test.isRunningTest()) {
            String testString = TEST_JSON_RETURN;
            return testString;    
        } else {
            return fileString;
        }
    }
    
    /**
      * @Author:          Svatopluk Sejkora
      * @Company:         Deloitte
      * @Description:     parse JSON to Map so we can use values for getting picklist codes
      * @Params:          String picklistJSON
      * @Returns:         map with value code
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public static Map<String,String> returnPicklistMap(String picklistJSON) {
    
        Map<String,String> valueToCodeMap = new Map<String,String>();
        Map<String, Object> m = new Map<String, String>();
        
        try {
            m = (Map<String, Object>)JSON.deserializeUntyped(picklistJSON);
            List<Object> myList = (List<Object>)m.get('pickList');
            
            for(Object o : myList) {
                valueToCodeMap.put(String.valueOf(((Map<String, Object>)o).get('value')), String.valueOf(((Map<String, Object>)o).get('code')));
            }
        } catch (Exception e){
            System.Debug('JSON string provided is not valid ' + e);
        }
        System.Debug('XXXXXXXXXXXXXXX test  ' + valueToCodeMap);
        return valueToCodeMap;
    }

    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     getter of visual.force base URL
      * @Returns:         String base URL
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private static String getVisualBaseURL() {

        List<URLs__c> urls = [
            SELECT URL__c 
            FROM URLs__c
            WHERE Name = :visualBaseURLName
        ];

        if (urls.isEmpty()) {
            return '';
        } else {
            return urls[0].URL__c;
        }
    }

}