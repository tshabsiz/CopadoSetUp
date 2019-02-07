/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class MultiTimerService {
    global MultiTimerService() {

    }
    global static String Execute() {
        return null;
    }
    global static String Execute(Integer action) {
        return null;
    }
    global static String Execute(Integer action, String description) {
        return null;
    }
    global static String Execute(Integer action, String description, Id userId) {
        return null;
    }
    global static String Execute(Integer action, String description, Id userId, Id matterId) {
        return null;
    }
    global static String Execute(Integer action, String description, Id userId, Id matterId, Id timerId) {
        return null;
    }
    @InvocableMethod(label='Execute Timer' description='Executes Timer with provided options.')
    global static List<advpm.MultiTimerService.ResultWrapper> Execute(List<advpm.MultiTimerService.InputWrapper> IW) {
        return null;
    }
global class InputWrapper {
    @InvocableVariable(label='Action' description='Provide valid Action to execute for the Timer ( 0 = Create in Running Mode ||  1 = Create in Paused Mode ).' required=false)
    global Integer action;
    @InvocableVariable(label='Description' description='Provide Description for the Timer.' required=false)
    global String description;
    @InvocableVariable(label='Matter ID' description='Provide Matter ID to which the Timer will be attached to.' required=false)
    global Id matterId;
    @InvocableVariable(label='Timer ID' description='Provide Timer ID if Timer is to be updated.' required=false)
    global Id timerId;
    @InvocableVariable(label='User ID' description='Provide User ID for whom the Timer is being executed for.' required=false)
    global Id userId;
    global InputWrapper() {

    }
}
global class MultiTimerServiceResponse {
    global String result {
        get;
        set;
    }
    global String success {
        get;
        set;
    }
    global MultiTimerServiceResponse() {

    }
}
global class ResultWrapper {
    @InvocableVariable(label='Timer Result Message' required=false)
    global String body;
    @InvocableVariable(label='Timer Result Status' required=false)
    global String status;
    global ResultWrapper() {

    }
}
}
