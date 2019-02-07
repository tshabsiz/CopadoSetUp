/**
* @Author               Marek Cech
* @Company:             Deloitte
* @Description:         Controller class for CusRep_CustomReport VF component.
* @Date:                14.12.2015
* @ConstructorParam:    None
* @TestClass:           ZZTEST_CusRep_CustomReportController
* History
* <Date>      <Authors Name>     <Brief Description of Change>
* 11.01.2016  Marta Malinowska   Adding range filter to display sliders and dynamic picklist filter.
* 16.03.2016  Caro  Reinecke     Adding dependent picklist filter.
*------------------------------------------------------------*/ 
public with sharing class CusRep_CustomReportController {
    
    public CusRep_Settings__c crs {get;set;}
    
    public String filtersUIDataJson {get;set;}
    
    public String filtersUIDataToApplyJson {get;set;}
    
    public String errorMessage {get;set;}
    
    public String resultJson {get;set;}
    
    //not universal
    public Boolean allowAssigning {get;set;}
    
    //not universal
    public String idsToAssignJson {get;set;}

    public String settingsName {
        get {
            return settingsName;
        }
        set {
            settingsName = value;
            loadSettings();
        }
    }
    
    @testVisible
    private Boolean settingsSetterCalled;
    
    @testVisible 
    private List<CusRep_Filter__c> filters;
    
    @testVisible
    private Map<Id, CusRep_Filter__c> filtersMap;
    
    @testVisible
    private FiltersDto filtersUIData;
    
    @testVisible
    private Map<String, Set<String>> permissionSetVisibilities;
    
    @testVisible
    private String columnsPartOfQuery;
    
    @testVisible
    private List<CusRep_Column__c> columns;
    
    @testVisible
    private List<ColumnDto> columnsUIData;
    
    @testVisible
    private String lastWherePart;
    
    private static final String PICKLIST = 'Picklist';

    private static final String DYNAMIC_PICKLIST = 'Dynamic Picklist';

    private static final String DEPENDENT_PICKLIST = 'Dependent Picklist';
      
    private static final String NUM = 'Number';
    
    private static final String TEXT = 'Text';

    private static final String RANGE = 'Range';
    
    private static final String SELECT_STR = 'SELECT';
    
    private static final String FROM_STR = 'FROM';
    
    private static final String WHERE_STR = 'WHERE';

    private static final String GROUP_BY_STR = 'GROUP BY';

    private static final String HAVING_STR = 'HAVING';
    
    private static final String LIKE_STR = 'LIKE';

    private static final String IN_STR = 'IN';
    
    private static final String OR_STR = 'OR';
    
    private static final String AND_STR = 'AND';
    
    private static final String LIMIT_STR = 'LIMIT';
    
    private static final String ORDER_BY = 'ORDER BY';
    
    private static final String ASC_STR = 'ASC';
    
    private static final String DESC_STR = 'DESC';
    
    private static final String NULLS_LAST = 'NULLS LAST';
    
    private static final String OFFSET_STR = 'OFFSET';
    
    private static final String LESS = '<';

    private static final String LESS_OR_EQUAL = '<=';
    
    private static final String MORE = '>';

    private static final String MORE_OR_EQUAL = '>=';
    
    private static final String SPACE = ' ';
    
    private static final String EMPTY_STRING = '';
    
    private static final String COMMA = ',';
    
    private static final String EQUALS = '=';
    
    private static final String QUOTE = '\'';
    
    private static final String PERCENTAGE = '%';
    
    private static final String OWNER_ID = 'OwnerId';
    
    private static final String OWNER = 'Owner';
    
    private static final String NAME = 'Name';
    
    private static final String COUNT_QUERY = 'SELECT count() FROM ';

    public CusRep_CustomReportController() {
        settingsSetterCalled = false;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Makes request for assignment of matrix leads to banker.
      * @Returns:         PageReference - null
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public PageReference requestForAssignment() {
        Set<Id> ids = (Set<Id>) JSON.deserialize(idsToAssignJson, Set<Id>.class);
        
        String result = MatrixLeadApprovalProcessUtils.requestMatrixLeadsAssignment(ids);
        if (result != null) {
            resultJson = result;
        } else {
            resultJson = '';
        }
        
        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Applies filters and prepares result data.
      * @Returns:         PageReference - null
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    public PageReference applyFilters() {
    
        FilterRequestDto request = (FilterRequestDto) JSON.deserialize(filtersUIDataToApplyJson, FilterRequestDto.class);
        String query = prepareQuery(request);
        
        List<SObject> result;
        errorMessage = '';
        try {
            result = Database.query(query);
        } catch (Exception e) {
            System.debug(e);
            
            errorMessage = Label.errMsg_ErrorLoadingData;
        }
        
        ResultDto rdto = new ResultDto();
        if (errorMessage != '') {
            rdto.errorMessage = errorMessage;
        } else {
            rdto.columnsUIData = columnsUIData;
            rdto.data = processResultData(result);
            rdto.recordsCount = getRecordsCount();
        }

        //TODO: Update Dependent Picklist values in filtersUIDataJson based on Controlling Picklist
        // Loop through the Filters and find the picklists of type Dependent_Picklists and refresh the values
        // possible call ro prepareFilters()
        prepareFilters();
        resultJson = JSON.serialize(rdto);
        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Loads settings of report.
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void loadSettings() {
    
        if (!settingsSetterCalled) {
            settingsSetterCalled = true;
            
            List<CusRep_Settings__c> settingsList = [
                SELECT Id, Page_Label__c, Rows_In_Result__c,
                  (
                    SELECT API_Name__c, Label__c, Is_Owner_Field__c, Alignment__c, Is_Link_To_Record__c
                    FROM CusRep_Columns__r
                    ORDER BY Order__c
                  )
                FROM CusRep_Settings__c
                WHERE Name = :settingsName
            ];
            
            if (settingsList.isEmpty()) {
                return;
            }
            crs = settingsList[0];
            
            filters = [
                SELECT Id, CusRep_Settings__c, Field_Name__c, Field_Type__c, Label__c, Default_Values__c, Order__c, Minimum__c, Maximum__c, Step__c, Placeholder__c, Source_Display_Field__c, Source_Object__c, Source_Criteria_Field__c, Controlling_Filter__c, Controlling_Filter__r.Id,
                  (
                    SELECT CusRep_Filter__c, Value__c, Label__c, Field_Name__c, Apply_Running_User_Filter__c,
                        Permission_Set_Visibility__c
                    FROM CusRep_Filter_Values__r
                  )
                FROM CusRep_Filter__c
                WHERE CusRep_Settings__c = :crs.Id
            ];
            
            filtersMap = new Map<Id, CusRep_Filter__c>(filters);
            processColumns();
            prepareFilters();
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Process columns part of report's metadata.
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void processColumns() {
        columns = crs.CusRep_Columns__r;
        columnsUIData = new List<ColumnDto>();
        columnsPartOfQuery = '';
    
        for (CusRep_Column__c col: crs.CusRep_Columns__r) {
            columnsPartOfQuery += col.API_Name__c + COMMA + SPACE;
            
            ColumnDto dto = new ColumnDto(col.Label__c, col.Alignment__c);
            columnsUIData.add(dto);
        }
        
        if (columnsPartOfQuery.length() > 2) {
            columnsPartOfQuery = columnsPartOfQuery.substring(0, columnsPartOfQuery.length() - 2);
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Process filters part of report's metadata.
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void prepareFilters() {
        permissionSetVisibilities = new Map<String, Set<String>>();
    
        filtersUIData = new FiltersDto();
    
        for (CusRep_Filter__c filter: filters) {
          system.debug(filter);
            if (filter.Field_Type__c == PICKLIST) {
                preparePicklist(filter);
            
            } else if(filter.Field_Type__c == DYNAMIC_PICKLIST) {
                prepareDynamicPicklist(filter);

            } else if(filter.Field_Type__c == DEPENDENT_PICKLIST) {
                prepareDependentPicklist(filter);
 
            } else if (filter.Field_Type__c == NUM) {
                prepareNumber(filter);
            
            } else if (filter.Field_Type__c == TEXT) {
                prepareText(filter);

            } else if (filter.Field_Type__c == RANGE) {
                prepareRange(filter);
            }
        }
        
        filtersUIDataJson = JSON.serializePretty(filtersUIData);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares text filter.
      * @Params           CusRep_Filter__c filter to proccess
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void prepareText(CusRep_Filter__c filter) {
        BasicDto dto = new BasicDto(filter.Id, filter.Label__c, filter.Order__c);
        filtersUIData.texts.add(dto);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares number filter.
      * @Params           CusRep_Filter__c filter to proccess
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void prepareNumber(CusRep_Filter__c filter) {
        BasicDto dto = new BasicDto(filter.Id, filter.Label__c, filter.Order__c);
        filtersUIData.numbers.add(dto);
    }

    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     Prepares range filter.
      * @Params           CusRep_Filter__c filter to proccess
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void prepareRange(CusRep_Filter__c filter) {
        RangeDto dto = new RangeDto();
        dto.min = filter.Minimum__c;
        dto.max = filter.Maximum__c;
        dto.step = filter.Step__c;
        if(dto.min == null || dto.max == null){
            String query = SELECT_STR + SPACE + 'MIN(' + filter.Field_Name__c + ') min' + COMMA + SPACE + 'MAX(' + filter.Field_Name__c + ') max' + SPACE + FROM_STR + SPACE + settingsName;
            try {
                AggregateResult[] result = Database.query(query);
                if(dto.min == null){
                    dto.min = (Decimal)result[0].get('min');
                }
                if(dto.max == null){
                    dto.max = (Decimal)result[0].get('max');
                }
            } catch (Exception e) {}
        }
        dto.label = filter.Label__c;
        dto.id = filter.Id;
        dto.order = filter.Order__c;
        filtersUIData.ranges.add(dto);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares picklist filter.
      * @Params           CusRep_Filter__c filter to proccess
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void preparePicklist(CusRep_Filter__c filter) {
    
        Set<String> values = new Set<String>();
        Set<String> defaultValues = new Set<String>();
        Set<String> toExcludeFromMetadataValues = new Set<String>();
        
        for (CusRep_Filter_Value__c fv: filter.CusRep_Filter_Values__r) {
            
            Boolean addValue = true;
            if (fv.Permission_Set_Visibility__c != null) {
                addValue = addValueForCurrentUser(fv.Permission_Set_Visibility__c);
                
                //not universal
                allowAssigning = addValue;
            }
            
            if (addValue) {
                values.add(fv.Label__c);
                
                if (fv.Value__c != null) {
                    toExcludeFromMetadataValues.add(fv.Value__c);
                }
            }
        }
        
        //getting picklist values from metadata
        Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(new String[]{settingsName});
        Map<String, Schema.SObjectField> objectFields = descResult[0].fields.getMap();
        Schema.DescribeFieldResult f = objectFields.get(filter.Field_Name__c).getDescribe();
        
        List<Schema.PicklistEntry> p = f.getPicklistValues();
        
        for (Schema.PicklistEntry e: p) {
            if (!toExcludeFromMetadataValues.contains(e.getLabel())) {
                values.add(e.getLabel());
            }
        }

        if(String.isNotBlank(filter.Default_Values__c)){
            for(String dv : filter.Default_Values__c.split(';')){
                if(values.contains(dv)){
                    defaultValues.add(dv);
                }
            }
        }
        
        PicklistDto dto = new PicklistDto();
        dto.controllingFilter = filter.Controlling_Filter__c;
        dto.isDynamic = false;
        dto.isDependent = false;
        dto.values = new List<String>(values);
        dto.values.sort();
        dto.defaultValues = new List<String>(defaultValues);
        dto.defaultValues.sort();
        dto.label = filter.Label__c;
        dto.id = filter.Id;
        dto.order = filter.Order__c;
        dto.placeholder = filter.Placeholder__c;
        
        filtersUIData.picklists.add(dto);
    }

    /**
      * @Author:          Marta Malinowska
      * @Company:         Deloitte
      * @Description:     Prepares dynamic picklist filter - search for values .
      * @Params           CusRep_Filter__c filter to proccess
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void prepareDynamicPicklist(CusRep_Filter__c filter) {
    
        Set<String> values = new Set<String>();

        //getting picklist values from database
        String query = SELECT_STR + SPACE + filter.Field_Name__c + SPACE + FROM_STR + SPACE + settingsName + SPACE + GROUP_BY_STR + SPACE + filter.Field_Name__c;
        for(AggregateResult ar : Database.query(query)){
            String value = (String)ar.get(filter.Field_Name__c);
            if(value != null){
                values.add(value);
            }
        }
        
        PicklistDto dto = new PicklistDto();
        dto.controllingFilter = filter.Controlling_Filter__c;
        dto.isDynamic = true;
        dto.isDependent = false;
        dto.values = new List<String>(values);
        dto.label = filter.Label__c;
        dto.id = filter.Id;
        dto.order = filter.Order__c;
        dto.placeholder = filter.Placeholder__c;
        
        filtersUIData.picklists.add(dto);
    }

    /**
      * @Author:          Caro Reinecke
      * @Company:         Deloitte
      * @Description:     Prepares dependent picklist filter - search for values .
      * @Params           CusRep_Filter__c filter to proccess
      * @Returns:         void
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private void prepareDependentPicklist(CusRep_Filter__c filter) {
    
        Set<String> values = new Set<String>();

        //Controlling Filter
        String query = '';

        String picklistQuery = '';
        if (null != filtersUIDataToApplyJson) {

            FilterRequestDto request = (FilterRequestDto) JSON.deserialize(filtersUIDataToApplyJson, FilterRequestDto.class);

            for (PicklistRequestDto ControllingPLdto : request.picklists) {

                if (ControllingPLdto.id == filter.Controlling_Filter__c) {

                    for (String value: ControllingPLdto.values) {
                        picklistQuery+= SPACE + filter.Source_Criteria_Field__c + SPACE + EQUALS + SPACE + QUOTE + value + QUOTE + SPACE + OR_STR;
                    }
                }
            }
        }

        /*
        for (PicklistRequestDto DependentPLdto : request.picklists) {
            
          if (DependentPLdto.Id != filter.Id) {

            continue;

          } else {
            for (PicklistRequestDto ControllingPLdto : request.picklists) {
             if (ControllingPLdto.id != filter.Controlling_Filter__c) {
              continue;
              } else {

                for (String value: ControllingPLdto.values) {

                  picklistQuery+= SPACE + filter.Source_Criteria_Field__c + SPACE + EQUALS + SPACE + QUOTE + value + QUOTE + SPACE + OR_STR;
                
                }
              }
            }
          }
        }
      }
      */

        //getting picklist values from database
        if (picklistQuery != '') {
            picklistQuery = picklistQuery.substring(0, picklistQuery.length() - 3);
            query = SELECT_STR + SPACE + filter.Source_Display_Field__c + COMMA + filter.Source_Criteria_Field__c + SPACE + FROM_STR + SPACE + filter.Source_Object__c + SPACE + GROUP_BY_STR + SPACE + filter.Source_Criteria_Field__c + COMMA + filter.Source_Display_Field__c + SPACE + HAVING_STR + SPACE + picklistQuery + SPACE + ORDER_BY + SPACE + filter.Source_Display_Field__c + SPACE + LIMIT_STR + SPACE + 2000 ;

            for (AggregateResult ar : Database.query(query)) {
                String value = (String)ar.get(filter.Source_Display_Field__c);
                if(value != null){
                    values.add(value);
                }
            }
        } 
        /*
        else {
            query = SELECT_STR + SPACE + filter.Source_Display_Field__c + COMMA + filter.Source_Criteria_Field__c + SPACE + FROM_STR + SPACE + filter.Source_Object__c + SPACE + GROUP_BY_STR + SPACE + filter.Source_Criteria_Field__c + COMMA + filter.Source_Display_Field__c + SPACE + ORDER_BY + SPACE + filter.Source_Display_Field__c + SPACE + LIMIT_STR + SPACE + 2000 ;
        }
        */

        
        
        
        
        PicklistDto dto = new PicklistDto();
        dto.controllingFilter = filter.Controlling_Filter__c;
        dto.isDynamic = true;
        dto.isDependent = true;
        dto.values = new List<String>(values);
        dto.label = filter.Label__c;
        dto.id = filter.Id;
        dto.order = filter.Order__c;
        dto.placeholder = filter.Placeholder__c;
        
        filtersUIData.picklists.add(dto);
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Decision algorithm of adding picklist values for current user.
      * @Params           String permissionSetName - name of permission set
      * @Returns:         Boolean indication if picklist value should be added for current user.
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private Boolean addValueForCurrentUser(String permissionSetName) {
        Set<String> userIds = permissionSetVisibilities.get(permissionSetName);
        if (userIds == null) {
            userIds = queryUsersAssignedToPermSet(permissionSetName);
        }
        
        if (userIds.contains(UserInfo.getUserId())) {
            return true;
        } else {
            return false;
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Queries users assigned to permission set.
      * @Params           String permissionSetName - name of permission set
      * @Returns:         Set<String> ids of users assignned to permission set
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private Set<String> queryUsersAssignedToPermSet(String permissionSetName) {
    
        List<PermissionSetAssignment> psas = [
            SELECT AssigneeId
            FROM PermissionSetAssignment
            WHERE PermissionSetId IN
              (
                SELECT Id
                FROM PermissionSet
                WHERE Name = :permissionSetName
              )
        ];
        
        Set<String> result = new Set<String>();
        for (PermissionSetAssignment psa: psas) {
            result.add(psa.AssigneeId);
        }
        return result;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Prepares query from request in param.
      * @Params           FilterRequestDto request - request to process
      * @Returns:         String - prepared query
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private String prepareQuery(FilterRequestDto request) {
        String q = SELECT_STR + SPACE + columnsPartOfQuery + SPACE + FROM_STR + SPACE + settingsName + SPACE + WHERE_STR;
        lastWherePart = '';
        
        //processing text filters
        for (TextRequestDto dto: request.texts) {
            CusRep_Filter__c filter = filtersMap.get(dto.id);
            lastWherePart += SPACE + filter.Field_Name__c + SPACE + LIKE_STR + SPACE + QUOTE + dto.value + PERCENTAGE + QUOTE + SPACE + AND_STR;
        }
        
        //processing number filters
        for (NumberRequestDto dto: request.numbers) {
            CusRep_Filter__c filter = filtersMap.get(dto.id);
            lastWherePart += SPACE + filter.Field_Name__c + SPACE;
            
            if (dto.isLess) {
                lastWherePart += LESS;
            } else {
                lastWherePart += MORE;
            }
            
            lastWherePart += SPACE + dto.value + SPACE + AND_STR;
        }

        //processing range filters
        for (RangeRequestDto dto: request.ranges) {
            CusRep_Filter__c filter = filtersMap.get(dto.id);
            
            if (dto.min != null) {
                lastWherePart += SPACE + filter.Field_Name__c + SPACE + MORE_OR_EQUAL + SPACE + dto.min + SPACE + AND_STR;
            } 
            if (dto.max != null) {
                lastWherePart += SPACE + filter.Field_Name__c + SPACE + LESS_OR_EQUAL + SPACE + dto.max + SPACE + AND_STR;
            }
            
        }
        
        //processing picklist filters
        for (PicklistRequestDto dto: request.picklists) {
            CusRep_Filter__c filter = filtersMap.get(dto.id);
            
            String picklistQuery = '';
            for (String value: dto.values) {
                CusRep_Filter_Value__c cfv = getFilterValueOfSelectedValue(value, filter);
                
                //picklist value renamed for ui
                if (cfv != null && cfv.Value__c != null) {
                    picklistQuery += SPACE + cfv.Field_Name__c + SPACE + EQUALS + SPACE + QUOTE + cfv.Value__c + QUOTE +  SPACE + OR_STR;
                
                //my records filtering
                } else if (cfv != null && cfv.Apply_Running_User_Filter__c == true) {
                    lastWherePart += SPACE + OWNER_ID + SPACE + EQUALS + SPACE + QUOTE + UserInfo.getUserId() + QUOTE + SPACE + AND_STR;
                
                //picklist value filtering
                } else {
                    picklistQuery += SPACE + filter.Field_Name__c + SPACE + EQUALS + SPACE + QUOTE + value + QUOTE + SPACE + OR_STR;
                }
            }
            
            if (picklistQuery != '') {
                picklistQuery = picklistQuery.substring(0, picklistQuery.length() - 3);
                lastWherePart += SPACE + '(' + picklistQuery + ')' + SPACE + AND_STR;
            }
        }
        
        //removing AND from the end of where part
        if (lastWherePart != '') {
            lastWherePart = lastWherePart.substring(0, lastWherePart.length() - 4);
        }
        
        q += lastWherePart;
        
        //removing WHERE from query if there is no where part
        if (lastWherePart == '') {
            q = q.substring(0, q.length() - 6);
        }
        
        // ordering
        if (request.colOrder != -1) {
            String colApiName = getApiNameOfColWithOrderNumber(request.colOrder);
            String order = request.isAsc ? ASC_STR : DESC_STR;
            
            if (colApiName != null) {
                q += SPACE + ORDER_BY + SPACE + colApiName + SPACE + order + SPACE + NULLS_LAST;
            }
        }
        
        //limitation
        q += SPACE + LIMIT_STR + SPACE + crs.Rows_In_Result__c;
        
        //pagination
        if (request.offset > 0) {
            q += SPACE + OFFSET_STR + SPACE + request.offset;
        }
        
        return q;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Returns API name of column of column with order number in param.
      * @Params           Integer colOrder - order number of column
      * @Returns:         String - prepared 
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    private String getApiNameOfColWithOrderNumber(Integer colOrder) {
        if (colOrder > columns.size() - 1 || colOrder < 0) {
            return null;
        } else {
            return columns[colOrder].API_Name__c;
        }
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Returns filter value object of filter and selected value in params.
      * @Params           String selectedValue - selected picklist value, CusRep_Filter__c filter - applied filter
      * @Returns:         CusRep_Filter_Value__c - found filter value object or null if not found
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private CusRep_Filter_Value__c getFilterValueOfSelectedValue(String selectedValue, CusRep_Filter__c filter) {
        
        for (CusRep_Filter_Value__c cfv: filter.CusRep_Filter_Values__r) {
            if (cfv.Label__c == selectedValue) {
                return cfv;
            }
        }
        return null;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Processes result data in param.
      * @Params           List<SObject> data - data to process
      * @Returns:         List<List<Object>> - data in rows and columns
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private List<List<Object>> processResultData(List<SObject> data) {
    
        List<List<Object>> result = new List<List<Object>>();
        
        //changing type of list
        Schema.sObjectType sot = data.getSObjectType();
        String listType = 'List<' + sot + '>';
        
        List<SObject> castRecords = (List<SObject>) Type.forName(listType).newInstance();
        castRecords.addAll(data);
        
        //processing records
        for (Integer i = 0; i < castRecords.size(); i++) {
            List<Object> record = new List<Object>();
        
            for (CusRep_Column__c col: columns) {
            
                if (col.Is_Owner_Field__c) {
                    Object ownerName = castRecords[i].getSObject(OWNER).get(NAME);
                    record.add(ownerName);
                    
                } else if(col.Is_Link_To_Record__c) {
                    String apiName = (String) castRecords[i].get(col.API_Name__c);
                    LinkToRecordDto dto = new LinkToRecordDto(castRecords[i].Id, apiName);
                    record.add(dto);
                    
                } else {
                    Object value = castRecords[i].get(col.API_Name__c);
                    if (value != null) {
                        record.add(value);
                    } else {
                        record.add(EMPTY_STRING);
                    }
                }
            }
            result.add(record);
        }
        return result;
    }
    
    /**
      * @Author:          Marek Cech
      * @Company:         Deloitte
      * @Description:     Getter of records count of current query.
      * @Returns:         Integer - records count
      * History
      * <Date>      <Authors Name>     <Brief Description of Change>
      *------------------------------------------------------------*/
    @testVisible
    private Integer getRecordsCount() {
        String query;
        if (lastWherePart == '') {
            query = COUNT_QUERY + settingsName;
        } else {
            query = COUNT_QUERY + settingsName + SPACE + WHERE_STR + SPACE + lastWherePart;
        }
        return Database.countQuery(query);
    }
    
    
    //private classes for JSON serialization / parsing
    
    private class ResultDto {
        
        public String errorMessage;
        public Integer recordsCount;
        public List<ColumnDto> columnsUIData;
        public List<List<Object>> data;
        
    }
    
    @testVisible
    private class LinkToRecordDto {
        
        public String id;
        public String value;
        
        public LinkToRecordDto(String id, String value) {
            this.id = id;
            this.value = value;
        }
        
    }
    
    private class ColumnDto {
        
        public String label;
        public String alignment;
        
        public ColumnDto(String label, String alignment) {
            this.label = label;
            this.alignment = alignment;
        }
        
    }
    
    @testVisible
    private class FilterRequestDto {
        
        public List<PicklistRequestDto> picklists;
        public List<NumberRequestDto> numbers;
        public List<RangeRequestDto> ranges;
        public List<TextRequestDto> texts;

        public Integer colOrder;
        public Boolean isAsc;
        public Integer offset;
        
    }
    
    @testVisible
    private class PicklistRequestDto {
        
        public String id;
        public List<String> values;
        
    }
    
    @testVisible
    private class NumberRequestDto {
    
        public String id;
        public Boolean isLess;
        public Decimal value;
    
    }

    @testVisible
    private class RangeRequestDto {
    
        public String id;
        public Decimal min;
        public Decimal max;
    
    }
    
    @testVisible
    private class TextRequestDto {
        
        public String id;
        public String value;
        
    }
    
    private class FiltersDto {
        
        public List<PicklistDto> picklists;
        public List<BasicDto> numbers;
        public List<BasicDto> ranges;
        public List<BasicDto> texts;
    
        public FiltersDto() {
            picklists = new List<PicklistDto>();
            numbers = new List<BasicDto>();
            ranges = new List<BasicDto>();
            texts = new List<BasicDto>();
        }
        
    }
    
    virtual private class BasicDto {
    
        public String id;
        public String label;
        public Decimal order;
        public String placeholder;
        
        public BasicDto() {
        }
        
        public BasicDto(String id, String label, Decimal order) {
            this.id = id;
            this.label = label;
            this.order = order;
        }
        
    }
    
    private class PicklistDto extends BasicDto {
        
        public String controllingFilter;
        public Boolean isDynamic;
        public Boolean isDependent;
        public List<String> values;
        public List<String> defaultValues;

    }

    private class RangeDto extends BasicDto {
        
        public Decimal min;
        public Decimal max;
        public Decimal step;

    }
    
}