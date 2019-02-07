/**
 * Created by KyleAlexander on 2018/03/19.
 */

// This is our wrapper/container class. A container class is a class, a data structure, or an abstract data type whose instances are collections of other objects. In this example a wrapper class contains both the standard salesforce object Clause and a Boolean value
public class ClauseWrapper {

    public Clause__c clause {get; set;}
    public Boolean selected {get; set;}

    public ClauseWrapper() {
    }

    //This is the contructor method. When we create a new ClauseWrapper object we pass a Clause that is set to the clause property. We also set the selected value to false
    public ClauseWrapper(Clause__c c) {
        clause = c;
        selected = false;
    }
}