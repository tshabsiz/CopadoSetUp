@istest
public class BxdLegalHoldAssignment_test {
    public static testmethod void BxdLegalHoldAssignment(){
        
         BXDtesclassdata.setupFolder();  
        test.startTest();
       	BXDtesclassdata.setupBase();
        test.stopTest();
        BxdLegalHoldAssignment Bxd = new BxdLegalHoldAssignment();
        
        BxdLegalHoldAssignment.parse(JsonString());
   }
    
   public static String JsonString(){
    String   json='{ '+
'  \"type\": \"legal_hold_policy_assignment\",'+
'  \"id\": \"255613\", '+
'  \"legal_hold_policy\": {'+
'    \"type\": \"legal_hold_policy\",'+
'    \"id\": \"166757\",'+
'	\"policy_id\": \"166757\",'+
'	\"deleted_at\": \"2016-05-18T17:38:03-07:00\",'+
'    \"TESTNODE\": \"166757\",'+
'    \"policy_name\": \"Bug Bash 5-12 Policy 3 updated\"'+
'  },'+
'  \"assigned_to\": {'+
'    \"type\": \"file\",'+
'    \"id\": \"5025127885\"'+
'  },'+
'  \"assigned_by\": {'+
'    \"type\": \"user\",'+
'    \"id\": \"2030388321\",'+
'   \"name\": \"Steve Boxuser\",'+
'    \"login\": \"sboxuser@box.com\"'+
'  },'+
'   \"assign_to\": {'+
'    \"type\": \"user\",'+
'    \"id\": \"2030388321\",'+
'   \"name\": \"Steve Boxuser\",'+
'    \"login\": \"sboxuser@box.com\"'+
'  },'+
'  \"assigned_at\": \"2016-05-18T17:38:03-07:00\",'+
'  \"deleted_at\": null'+
'}';
return json;
   
   }   
}