@Istest
public class BxdSharedLink_test {

    Public static testmethod void BxdSharedLink(){      
        test.startTest();
        	BXDtesclassdata.setupFolder();  
       	   BxdSharedLink.parse(JsonString());
            
        test.stopTest();
    }
    Public Static string JsonString(){
        
     String   json='{'+
'    \"type\": \"file\", '+
'    \"id\": \"10559150999\", '+
'    \"etag\": \"1\", '+
'    \"shared_link\": { '+
'        \"url\": \"https://blosserdemoaccount.box.com/s/7mcmdlavtye5o5i0ue8xmtwh2sx5bv8p\", '+
'        \"download_url\":              \"https://blosserdemoaccount.box.com/shared/static/7mcmdlavtye5o5i0ue8xmtwh2sx5bv8p.png\", '+
'        \"vanity_url\": null, '+
'        \"effective_access\": \"open\", '+
'        \"is_password_enabled\": true, '+
'        \"unshared_at\": null, '+
'        \"download_count\": 0, '+
'        \"preview_count\": 0, '+
'        \"access\": \"open\", '+
'        \"permissions\": { '+
'            \"can_download\": true, '+
'           \"can_preview\": true '+
'        }'+
'    }'+
' }';
        return json;
    }
    	
}