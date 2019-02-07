/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 09/11/2017 - PG    - Created Class. 

**/ 
@IsTest
public class HotDocs_WorkItem_Test 
{
	static testMethod void testParse() 
	{
		String json = '{'+
		'    \"Id\": \"acc416f5-d4c5-e711-a2bb-00155d21800d\",'+
		'    \"Name\": \"2a7ebf03-386c-4b66-8f28-df7719d6b9c6\",'+
		'    \"Description\": \"2a7ebf03-386c-4b66-8f28-df7719d6b9c6\",'+
		'    \"AnswerSetId\": \"4a6910e1-d4c5-e711-a2bb-00155d21800d\",'+
		'    \"PrimaryTemplate\": {'+
		'        \"TemplateId\": \"45339dd4-7e1b-472f-8ab1-5a45c287c4a4\",'+
		'        \"TemplateTitle\": \"ABSA ZAR terms\",'+
		'        \"AssembledDocuments\": ['+
		'            {'+
		'                \"DocumentId\": \"e4b531ff-d4c5-e711-a2bb-00155d21800d\"'+
		'            }'+
		'        ]'+
		'    },'+
		'    \"CreationDate\": \"2017-11-10T05:06:49.9675739+00:00\",'+
		'    \"LastModifiedDate\": \"2017-11-10T05:06:49.9675739+00:00\",'+
		'    \"CreatedBy\": \"00000000-0000-0000-0000-000000000000\",'+
		'    \"LastModifiedBy\": \"00000000-0000-0000-0000-000000000000\",'+
		'    \"InterviewSessionId\": null'+
		'}';
		
		HotDocs_WorkItem obj = HotDocs_WorkItem.parse(json);
		System.assert(obj != null);
	}
}