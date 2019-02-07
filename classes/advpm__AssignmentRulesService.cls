/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class AssignmentRulesService {
    global AssignmentRulesService() {

    }
    @Future(callout=true)
    global static void processRuleAsync(Id ruleId, List<Id> recordIds) {

    }
    @InvocableMethod(label='Process Assignment Rule Set' description='Process Assignment Rule Set on source records for the provided Rule Set ID.')
    global static List<advpm.AssignmentRulesService.ResultWrapper> processRuleFromBuilder(List<advpm.AssignmentRulesService.InputWrapper> IW) {
        return null;
    }
    global static String processRule(Id ruleId, List<Id> recordIds) {
        return null;
    }
    global static String processRule(Id ruleId, List<Id> recordIds, Boolean previewMode) {
        return null;
    }
global class AssignmentRulesServiceResponse {
    global Set<String> dataFields {
        get;
        set;
    }
    global List<advpm.wAssignmentRuleDataRecord> dataRecords {
        get;
        set;
    }
    global String result {
        get;
        set;
    }
    global String success {
        get;
        set;
    }
    global AssignmentRulesServiceResponse() {

    }
}
global class InputWrapper {
    @InvocableVariable(label='Record ID' description='Provide source record's Id value for which rule will be executed.' required=true)
    global Id recordId;
    @InvocableVariable(label='Assignment Rule Set ID' description='Provide Assignment Rule Set Id value here.' required=true)
    global Id ruleId;
    global InputWrapper() {

    }
}
global class ResultWrapper {
    @InvocableVariable(label='Assignment Rule Result Message' required=false)
    global String body;
    @InvocableVariable(label='Assignment Rule Result Status' required=false)
    global String status;
    global ResultWrapper() {

    }
}
}
