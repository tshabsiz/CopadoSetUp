/**
* @Author:        Svatopluk Sejkora
* @Company:       Deloitte
* @Description:   Unit Tests for JsonUtils
*                 Tests executed:
*                 1 - testReturnJSONStringAndParse()
*                   Tests obtaining Json from static resource and parsing to a map (desktop version)
*                 2 - testReturnJSONStringMobileAndParse()
*                   Tests obtaining Json from static resource and parsing to a map (mobile version)
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 25.2.2016   Marek Cech         added testReturnJSONStringMobileAndParse
* ----------------------------------------------------------------------------*/
@isTest
public class ZZTEST_JsonUtils {

    private static final String STATIC_RESOURCE_NAME = 'Picklists';
    private static final String FILE_EXTENSION = 'txt';
    private static final String SIC_FILE_NAME = 'SICJSON';

    static testMethod void testReturnJSONStringAndParse() {

        //it is not possible to mock static resources in a zip file (summer 15), so I am using Test.isRunningTest to get specific string for testing purposes
        String returnedJsonString = JsonUtils.returnJSONString(STATIC_RESOURCE_NAME, SIC_FILE_NAME, FILE_EXTENSION, STATIC_RESOURCE_NAME);
        
        Map<String, String> parsedJson = JsonUtils.returnPicklistMap(returnedJsonString);

        System.assertEquals(1155, Integer.ValueOf(parsedJson.get('1 - MONETARY AUTHORITY')));
    }
    
    static testMethod void testReturnJSONStringMobileAndParse() {
        
        String returnedJsonString = JsonUtils.returnJSONStringMobile(STATIC_RESOURCE_NAME, SIC_FILE_NAME, FILE_EXTENSION, STATIC_RESOURCE_NAME);
        
        Map<String, String> parsedJson = JsonUtils.returnPicklistMap(returnedJsonString);

        System.assertEquals(1155, Integer.ValueOf(parsedJson.get('1 - MONETARY AUTHORITY')));
    }

}