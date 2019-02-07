/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 10/11/2017 - PG    - Created Class. 

**/ 
@IsTest
public class HotDocs_Document_Test 
{	
	static testMethod void testParse()
	{
		String json = '{'+
		'  \"MimeType\": \"string\",'+
		'  \"CreatedBy\": \"string\",'+
		'  \"CreatedOn\": \"2017-11-10T10:40:05.429Z\",'+
		'  \"FileExtension\": \"string\",'+
		'  \"Title\": \"string\",'+
		'  \"FileName\": \"string\"'+
		'}';
		
		HotDocs_Document obj = HotDocs_Document.parse(json);
		System.assert(obj != null);
	}
}