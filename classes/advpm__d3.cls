/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class d3 {
    global d3() {

    }
global class d3Data {
    global List<advpm.d3.d3Link> links {
        get;
        set;
    }
    global List<advpm.d3.d3Node> nodes {
        get;
        set;
    }
    global Set<Id> partIds {
        get;
        set;
    }
    global List<advpm__Participant__c> parts {
        get;
        set;
    }
    global List<String> roles {
        get;
        set;
    }
    global List<String> types {
        get;
        set;
    }
    global d3Data() {

    }
}
global class d3DataTree {
    global List<String> roles {
        get;
        set;
    }
    global List<advpm.d3.d3TreeNode> tree {
        get;
        set;
    }
    global List<String> types {
        get;
        set;
    }
    global d3DataTree() {

    }
}
global class d3Link {
    global String relation {
        get;
        set;
    }
    global Integer source {
        get;
        set;
    }
    global Integer target {
        get;
        set;
    }
    global d3Link(Integer s, Integer t, String r) {

    }
}
global class d3Node {
    global Boolean collapsed {
        get;
        set;
    }
    global Integer collapsing {
        get;
        set;
    }
    global Integer id {
        get;
        set;
    }
    global String image {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global String recordid {
        get;
        set;
    }
    global String type {
        get;
        set;
    }
    global d3Node(Integer i, String nm, String img) {

    }
    global d3Node(Integer i, String nm, String img, String t) {

    }
    global d3Node(Integer i, String nm, String img, String t, String rid) {

    }
}
global class d3TreeNode {
    global List<advpm.d3.d3TreeNode> children {
        get;
        set;
    }
    global String image {
        get;
        set;
    }
    global String name {
        get;
        set;
    }
    global String parent {
        get;
        set;
    }
    global String relation {
        get;
        set;
    }
    global String rid {
        get;
        set;
    }
    global SObject sobj {
        get;
        set;
    }
    global d3TreeNode() {

    }
    global d3TreeNode(String i, String nm, String pr, String rl) {

    }
    global d3TreeNode(String i, String nm, String pr, String rl, String nt) {

    }
    global d3TreeNode(String i, String nm, String pr, String rl, String nt, SObject so) {

    }
}
}
