/**
* 2017-06-29
* Rudolf Niehaus - CloudSmiths
**/
public class Payments_QA_Statements_Ext {
    
    Public Case currCase {get;set;}
    Public String curr {get;set;}
    Public String custNumber {get;set;}
    Public String accNumber {get;set;}
    Public String seqNr {get;set;}
    Public String selectedType {get;set;}
    public list<SelectOption> typeOptions {get;set;}
    Public String custKey {get;set;}
    Public String inputKeyTier {get;set;}
    Public String inputKeyDeal {get;set;}
    Public Case fromDate {get;set;}
    Public Case toDate {get;set;}
    Public Boolean showS {get;set;}
    Public Boolean showI {get;set;}
    Public Boolean showB {get;set;}
    Public String stamp {get;set;}
    Public Decimal openingBal {get;set;}
    Public Payments_JSON2ApexBIC bicList {get;set;} 
    Public Payments_JSON2ApexStat stateList {get;set;}
    Public Payments_JSON2ApexDeal dealList {get;set;}
    Public Payments_JSON2ApexTier tierDetail {get;set;}
        
    public Payments_QA_Statements_Ext(ApexPages.StandardController controller){
        
        currCase = (Case)controller.getRecord();
        fromDate = new Case();
        toDate = new Case();
        fromDate.Incident_Date__c = System.today();
        toDate.Incident_Date__c = System.today();
        
        typeOptions = new list<SelectOption>();
        typeOptions.add(new SelectOption('S', 'Statement'));
        typeOptions.add(new SelectOption('I', 'Interest'));
        typeOptions.add(new SelectOption('B', 'Both'));
        //default to S - Statements
        selectedType = 'S';
        showS=true;
        showI=false;
        showB=false;
        openingBal = 0.0;
        
        //check if the controller was loaded from a BIC search
        if(ApexPages.currentPage().getParameters().get('bic') != null){
            //028738-ZAR-0000006712-01
            String[] statDetails = ApexPages.currentPage().getParameters().get('bic').split('-');
            custNumber = statDetails[0];
            curr = statDetails[1];
            accNumber = statDetails[2]; 
            seqNr = statDetails[3];    
        }
        //check if the controller was loaded from a Deal search
        if(ApexPages.currentPage().getParameters().get('custKey') != null){
            custKey = ApexPages.currentPage().getParameters().get('custKey');
        }
        //check if the controller was loaded from a tier search
        if(ApexPages.currentPage().getParameters().get('inputKeyTier') != null){
            inputKeyTier = ApexPages.currentPage().getParameters().get('inputKeyTier');
        }
        
         //check if the controller was loaded from a BIC client click thru
        if(ApexPages.currentPage().getParameters().get('tierref') != null){
            String tierCode = ApexPages.currentPage().getParameters().get('tierref');
            if(tierCode.indexOf('-') > 0){
               String[] tierDetails = tierCode.split('-');
               inputKeyTier = tierDetails[0] + tierDetails[1] + tierDetails[2] + tierDetails[3];
            }else{
                inputKeyTier = tierCode;
            }
        }
    }
    
    Public PageReference requestStatement(){
        
         //VALIDATE INPUT
        if(String.isBlank(custNumber)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter a Customer Number'));
            return null;
        }else if(String.isBlank(curr)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter a Currency'));
            return null;
        }else if(String.isBlank(accNumber)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter an Account Number'));
            return null;
        }else if(String.isBlank(seqNr)){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter a Sequence Number'));
            return null;
        }

        //format dates
        Date fdt = fromDate.Incident_Date__c;
        Date tdt = toDate.Incident_Date__c;
        
        //Validate date range and ensure it do not exceed 6 months
        if(fdt > tdt){
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Your From Date cannot be after your To Date'));
             return null;
        }else{
            
            Integer monthDiff = fdt.monthsBetween(tdt);
            
            if(monthDiff > 6){
               ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'You cannot use a date range larger than 6 months'));
               return null; 
            }
        }
        
        
        String fm = '';
        String tm = '';
        String fd = '';
        String td = '';
        
        if(fdt.month() < 10){
            fm = '0' + String.valueOf(fdt.month());
        }else{
            fm = String.valueOf(fdt.month());
        }
        if(fdt.day() < 10){
            fd = '0' + String.valueOf(fdt.day());
        }else{
            fd = String.valueOf(fdt.day());
        }
        if(tdt.month() < 10){
            tm = '0' + String.valueOf(tdt.month());
        }else{
            tm = String.valueOf(tdt.month());
        }
        if(tdt.day() < 10){
            td = '0' + String.valueOf(tdt.day());
        }else{
            td = String.valueOf(tdt.day());
        }
        String formatFromDate = String.valueOf(fdt.year()) + fm + fd;
        String formatToDate = String.valueOf(tdt.year()) + tm + td;

        //Fix input values for users and validate
        if(accNumber.length() < 10){
            Integer loopSize = (10 - accNumber.length());
            for(Integer x=1;x<=loopSize;x++){
                accNumber = '0' + accNumber;
            }
            
        }
        if(seqNr.length() == 1){
           seqNr = '0' + seqNr;
        }
        
        curr = curr.toUpperCase();

        //render correct output panel based on type of statement
        if(selectedType == 'S'){
            showS=true;
            showI=false;
            showB=false;
        }else if(selectedType == 'I'){
            showS=false;
            showI=true;
            showB=false;
        }else if(selectedType == 'B'){
            showS=false;
            showI=false;
            showB=true;
        }
        
        //postToMIDAS(String CUST,String CURR,String ACOD,String ACSQ,String FDATE,String TDATE,String STYPE,String SPAGE,String SLINE) {
        stateList = Payments_Outbound_Statements.postToMIDAS(custNumber,curr,accNumber,seqNr,formatFromDate,formatToDate,selectedType,'1','999'); 
        //reverse opening bal for all none interest statements
        openingBal = stateList.OPENBAL;
        if(selectedType != 'I'){
            if(openingBal != null){
                 openingBal = (openingBal * -1);
            }else{
                 openingBal = 0.0;
            }
           
        }
        return null;
    }
    
    Public PageReference searchBIC(){
        
        bicList = Payments_Outbound_BIC.postToMIDAS(custKey);        
        
        return null;
    }
    Public PageReference searchDeal(){
        
        dealList = Payments_Outbound_Deal.postToMIDAS(custKey);
        
         //format date
        if(!Test.isRunningTest()){
            if(String.isNotBlank(dealList.PODETAIL.IP_TMST)){
                
                String stamp = dealList.PODETAIL.IP_TMST;
                String d = stamp.substring(0,10);
                String t = stamp.substring(11, (stamp.length()-7));
                
                dealList.PODETAIL.IP_TMST = d + '   ' + t;
            }
        }
        
        //load first deal
        //if(dealList.PODETAIL > 0){
        //     dealDetail = dealList.PODETAIL[0];
        //}
        return null;
    }
    
    Public PageReference searchTier(){
        
        tierDetail = Payments_Outbound_Tier.postToMIDAS(inputKeyTier);
       
        return null;
    }
}