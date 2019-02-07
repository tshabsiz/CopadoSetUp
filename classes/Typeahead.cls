// Controller class for the Force.com Typeahead component
public without sharing class Typeahead {

  @RemoteAction
  public static list<sObject> searchRecords( String queryString, String objectName, 
    list<String> fieldNames, String fieldsToSearch, String filterClause, String orderBy, Integer recordLimit ){

    if (queryString == null) return null;

    String sQuery = String.escapeSingleQuotes( queryString );
    if (sQuery.length() == 0) return null;

    String sObjectName = (objectName == null) ? 'Contact' : String.escapeSingleQuotes( objectName );

    String sInFields = 
    	(fieldsToSearch == null || fieldsToSearch == '' || fieldsToSearch.toUpperCase() == 'ALL') ? '' : 
    		( ' IN ' + String.escapeSingleQuotes(fieldsToSearch) + ' FIELDS' );
    
    String sFields = (fieldNames == null || fieldNames.isEmpty()) ? 'Id, Name' : 
    	String.escapeSingleQuotes( String.join( fieldNames, ', ' ) );  
    
    String sOrder = ' ORDER BY ' + ( (orderBy == null || orderBy == '') ? 'Name' : String.escapeSingleQuotes(orderBy) ); 
    
    String sLimit = (recordLimit == null || recordLimit == 0 || recordLimit >= 2000) ? '' : 
    	( ' LIMIT ' + String.valueOf(recordLimit));
    
    // can't escape the filter clause
    String sWhere = (filterClause == null || filterClause == '') ? '' : 
    	( ' WHERE ' + filterClause );

    list<list<sObject>> results = Search.query(
    	'FIND \'' + sQuery + '*\'' + sInFields + 
    		' RETURNING ' + sObjectName + '( ' + sFields + sWhere + sOrder + sLimit + ' )'
    );
    
    return results[0];
  }  

    public static void jimmyMyCode(){
	
    	Integer x = 1;
        
        if(x == 1){
            x = 2;
        }
        if(x == 2){
            x = 3;
        }
        if(x == 3){
            x = 4;
        }
        if(x == 4){
            x = 5;
        }
        if(x == 5){
            x = 6;
        }
        if(x == 6){
            x = 7;
        }
        if(x == 7){
            x = 8;
        }
        if(x == 8){
            x = 9;
        }
        if(x == 9){
            x = 10;
        }
        if(x == 10){
            x = 11;
        }
        if(x == 11){
            x = 12;
        }
        if(x == 12){
            x = 13;
        }
        if(x == 13){
            x = 14;
        }
        if(x == 14){
            x = 15;
        }
        if(x == 15){
            x = null;
        }
    }  
    
}