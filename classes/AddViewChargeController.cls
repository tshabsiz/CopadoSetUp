public class AddViewChargeController {
    
    public static Case currentCase {get;set;}
    public static List<Charge__c> chargeList{get;set;}
    public static List<ChargeWrapper> chargeWrapperList{get;set;}
    public static Integer CRID{get;set;}
    public static ID CurrentCaseID{get;set;}
    public static boolean isSystemAdmin{get;set;}
    public static final String UnableToEditMsg = Label.lbl_UnableToEditMsg;
    public static final String MustHaveValueErrorMsg = 'Must have a value ';
    public static String errorMsg = '';
    private static Response MyResponse = new Response();
    private static List<Dictionery> TransactionCodeList = null;
    private static List<Dictionery> CorpCodeList = null;
    private static List<Dictionery> CrAccountNoList = null;

    public class Response{
    public Case currentCase {get;set;}
    public List<Charge__c> chargeList{get;set;}
    public List<ChargeWrapper> chargeWrapperList{get;set;}
    public Integer CRID{get;set;}
    public ID CurrentCaseID{get;set;}
    public boolean isSystemAdmin{get;set;}
    public String UnableToEditMsg = Label.lbl_UnableToEditMsg;
    public String MustHaveValueErrorMsg = 'Must have a value ';
    public List<Dictionery> TransactionCodeList = null;
    public List<Dictionery> CorpCodeList = null;
    public List<Dictionery> CrAccountNoList = null;
    public String errorMsg = '';
    }
    
    public static Response parse(String json) {
		return (Response) System.JSON.deserialize(json, Response.class);
	}
    
    public static Response MapResponse()
    {
        MyResponse.currentCase = currentCase;
        MyResponse.chargeList = chargeList;
        MyResponse.chargeWrapperList = chargeWrapperList;
        MyResponse.CRID = CRID;
        MyResponse.CurrentCaseID = CurrentCaseID;
        MyResponse.isSystemAdmin = isSystemAdmin;
        MyResponse.UnableToEditMsg = UnableToEditMsg;
        MyResponse.MustHaveValueErrorMsg = MustHaveValueErrorMsg;
        
        MyResponse.errorMsg = errorMsg;
        MyResponse.TransactionCodeList = TransactionCodeList;
        MyResponse.CorpCodeList = CorpCodeList;
        MyResponse.CrAccountNoList = CrAccountNoList;
        return MyResponse;
    }
    
     public static void MapToInstance(Response instance)
    {
        currentCase = instance.currentCase;
        chargeList = instance.chargeList;
        chargeWrapperList = instance.chargeWrapperList;
        CRID = instance.CRID;
        CurrentCaseID = instance.CurrentCaseID;
        isSystemAdmin = instance.isSystemAdmin;
        TransactionCodeList = instance.TransactionCodeList;
        CorpCodeList = instance.CorpCodeList;
        CrAccountNoList = instance.CrAccountNoList;
        errorMsg = '';
        //UnableToEditMsg = instance.UnableToEditMsg;
        //MustHaveValueErrorMsg = instance.MustHaveValueErrorMsg;
        
    }
    
    //Tonga MM : Standard controller constructor
     @AuraEnabled
    public static string AddViewChargeLoad(string model, string recordId)
    {	
        //Response instance = parse(model);
        try{
        List<String> caseFields = new List<String>();
        Charge__c ppp = new Charge__c();
        TransactionCodeList = getPickValues(ppp, 'Transaction_Code__c', null);
        CorpCodeList = getPickValues(ppp, 'Corp_Code__c', null);
        CrAccountNoList = getPickValues(ppp, 'CR_Account_No__c', null);
        
        caseFields.add('Charge_Locked__c');
        
        //if(!Test.isRunningTest())
       // {
        	//controller.addFields(caseFields);    
        //}
        
        currentCase = [select id, Charge_Locked__c, RecordTypeId from case where ID=:recordId];//(Case)controller.getRecord();
        
        isSystemAdmin = isSystemAdminProfileById(UserInfo.getProfileId());
        getCaseCharge(currentCase.ID);
        
        }catch(exception e) {
            errorMsg = e.getMessage();
        }
			return JSON.serialize(MapResponse());
    }
    
    @AuraEnabled
    public static string addnewLine1(string model){
        try{
         Response instance = parse(model);
        
        MapToInstance(instance);
        addnewLine();
        }catch(exception e) {
            
            errorMsg = e.getMessage();
        }
       return JSON.serialize(MapResponse());
    }
    
     @AuraEnabled
    public static string saveUpdates1(string recordId, string model){
        try{
         Response instance = parse(model);
        
        MapToInstance(instance);
       SaveUpdates();
        }
            catch(exception e) {
            
            errorMsg = e.getMessage();
        }
       return JSON.serialize(MapResponse());
    }
    
    
    @AuraEnabled
    public static string unlock11(string recordId, string model){
        try{
         Response instance = parse(model);
        
        MapToInstance(instance);
        unlock();
            getCaseCharge(currentCase.ID);
             }
            catch(exception e) {
            
            errorMsg = e.getMessage();
        }
       return JSON.serialize(MapResponse());
    }
  
    @AuraEnabled
    public static string lockCharges1(string recordId, string model){
        try{
         Response instance = parse(model);
        
        MapToInstance(instance);
        LockCharges();
        getCaseCharge(currentCase.ID);
             }
            catch(exception e) {
            
            errorMsg = e.getMessage();
        }
       return JSON.serialize(MapResponse());
    }
    
     @AuraEnabled
    public static string deleteItem1(string recordId, string model){
        try{
         Response instance = parse(model);
         MapToInstance(instance);
        
        if(!currentCase.Charge_Locked__c)
        {
            Charge__c toDelete =  [SELECT Id FROM Charge__c WHERE Id=:recordId];
            delete toDelete;
            getCaseCharge(currentCase.ID);            
        }
             }
            catch(exception e) {
            
            errorMsg = e.getMessage();
        }
        
       return JSON.serialize(MapResponse());
    }
    
    
    public static List<Dictionery> getPickValues(Sobject object_name, String field_name, String first_val) 
    {
        
          List<Dictionery> options = new List<Dictionery>(); //new list for holding all of the picklist options
          if (first_val != null) { //if there is a first value being provided
             options.add(new Dictionery(first_val, first_val)); //add the first option
          }
          Schema.sObjectType sobject_type = object_name.getSObjectType(); //grab the sobject that was passed
          Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
          Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
          List<Schema.PicklistEntry> pick_list_values = field_map.get(field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
          for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                      
                options.add(new Dictionery(a.getValue(), a.getLabel())); //add the value and label to our final list
          }
          return options; //return the List
	}

    public class Dictionery{
        public string label{get;set;}
        public string value{get;set;}
        public boolean valueSelected{get;set;}
        
        public Dictionery(string label, string value){
            this.label = label;
            this.value = value;
            this.valueSelected = false;
        }
    }
    
    //Tonga MM : Helper method used to determine which profile is used by currently logged user
    private static boolean isSystemAdminProfileById(ID profileID)
    {
       String profileName = [Select Name from Profile where ID =:profileID limit 1].Name;
        
        if(profileName.equalsIgnoreCase('Barclays Administrator')||profileName.equalsIgnoreCase('System Administrator'))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    //Tonga MM : Method can only be access by system admin to unlock a charge
    public static void unlock()
    {
        currentCase.Charge_Locked__c = false;
        update currentCase;
    }
    
    //Tonga : Method used for apporving and locksing charges that have been captures
    public static void LockCharges()
    {
        if(currentCase.Charge_Locked__c)
           {
               // To Do : Add message stating charges have already been locked
               //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,Label.lbl_ChargeAlreadyApproved));

           }
           else
           {
               currentCase.Charge_Locked__c = true;
               update currentCase;
           }
        
    }
    
    //Tonga MM : upsert method for saving and updating existing charges
    public static void SaveUpdates()
    {
        boolean errorFound  =false;
        if(!currentCase.Charge_Locked__c)
        {
            List<Charge__c> chargeToInsert = new List<Charge__c>();
            for(ChargeWrapper currentCharge : chargeWrapperList)
            {/*
                 if(validateInput(currentCharge.charge))
                 {
                     chargeToInsert.add(currentCharge.charge);
                 }
                else
                {
                    errorFound = true;
                }*/
                
                //chargeToInsert.add(currentCharge.charge);
                if(currentCharge.charge.Id == null){
                    Charge__c newCharge = new Charge__c();
                    newCharge.Case__c = currentCharge.charge.Case__c;
                    newCharge.Charge_Account_No__c = currentCharge.charge.Charge_Account_No__c;
                    newCharge.Charge_Amount__c = currentCharge.charge.Charge_Amount__c;
                    newCharge.Corp_Code__c = currentCharge.charge.Corp_Code__c;
                    newCharge.CR_Account_No__c = currentCharge.charge.CR_Account_No__c;
                    newCharge.CR_Ref__c = currentCharge.charge.CR_Ref__c;
                    newCharge.CR_Account_No__c = currentCharge.charge.CR_Account_No__c;
                    newCharge.Transaction_Code__c = currentCharge.charge.Transaction_Code__c;
                    newCharge.Cost_Centre__c = currentCharge.charge.Cost_Centre__c;
                    newCharge.DR_Ref__c = currentCharge.charge.DR_Ref__c;
                    newCharge.Effective_Date__c = currentCharge.charge.Effective_Date__c;
                    
                    chargeToInsert.add(newCharge);
                }else{
                chargeToInsert.add(currentCharge.charge);
                }
                
            }
            
            if(chargeToInsert.size()>0 && !errorFound)
            {
                upsert chargeToInsert ID;
                getCaseCharge(CurrentCase.ID);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.lbl_ChargeSuccessMsg));
            }    
            else
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please review the below Error'));
            }
            
        }
        else
        {
            // To do : Add validation message that will show that once approved users can no longer update the charges
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, UnableToEditMsg));

        }
        
    }
    
    
    public static void getCaseCharge(ID CaseID)
    {
        chargeList= new List<Charge__c>();
        chargeWrapperList = new List<ChargeWrapper>();
        
        chargeList = [Select 
                      ID,
                      Name,
                      Charge_Account_No__c,
                      Charge_Amount__c,
                      Transaction_Code__c,
                      Corp_Code__c,
                      Cost_Centre__c,
                      Case__c,
                      CR_Ref__c,
                      DR_Ref__c,
                      CR_Account_No__c,
                      Effective_Date__c
        				from Charge__c where Case__c = :CaseID];
        
        integer index = 0;
        for(Charge__c c :chargeList)
        {
           
            chargeWrapperList.add(new ChargeWrapper(index,c));
             index+=1;
        }
    }
    public static void DeleteItem()
    {
        if(!currentCase.Charge_Locked__c)
        {
            Charge__c chargeToDelete;
     	if(!String.isBlank(String.valueOf(CRID)))
        {
            ChargeWrapper CW = chargeWrapperList.get(CRID);
            
            if(String.ISBLANK(CW.charge.ID))
            {
                chargeWrapperList.remove(CRID);
            }
            else 
            {
                chargeToDelete = new Charge__c(ID = chargeWrapperList.get(CRID).charge.Id);
                delete chargeToDelete;
                chargeWrapperList.remove(CRID);
            }
            
          updateSequence();
        }
        }
        else
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, UnableToEditMsg));
        }
        
    }
    private static void addnewLine()
    {
        if(!currentCase.Charge_Locked__c)
        {
            Integer index=chargeWrapperList.size();
            
            chargeList.add(new Charge__c(Case__c =  currentCase.Id));
            
            chargeWrapperList.add(new ChargeWrapper(index++,
               new Charge__c(
                 //  Id = null,
                Case__c =  currentCase.Id,
            	Charge_Account_No__c = '',
            	Charge_Amount__c = 0,
                Transaction_Code__c = '',
                Corp_Code__c = '',
                Cost_Centre__c = '',
                CR_Ref__c = '',
                DR_Ref__c = '',
                CR_Account_No__c = '',
                Effective_Date__c = system.today()
               				)));
        }
        else
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,UnableToEditMsg));
        }
        
    }
  
    //Tonga MM : Wrapper class used for wrapping charge record entries
    public class ChargeWrapper
    {
        public Charge__c charge{get;set;}
        public Integer index{get;set;}
        
        public ChargeWrapper(Integer index,Charge__c CR)
        {
            this.charge = CR;
            this.index = index;
        }
    }    
    
    //Tonga MM : Helper method for updating sequence for charge records 
    public static void updateSequence()
    {
        integer index = 0;
        for(ChargeWrapper chargeWR : chargeWrapperList)
        {
            chargeWR.index=0;
            index +=1;
        }
    }
/*
    public static boolean validateInput(Charge__c charge)
    {
        boolean chargeValidate = true;
        if(String.isBlank(charge.Charge_Account_No__c))
        {
            chargeValidate = false;
            charge.Charge_Account_No__c.addError(MustHaveValueErrorMsg);
        }
        if(charge.Charge_Amount__c==null)
        {
            chargeValidate = false;
            charge.Charge_Amount__c.addError(MustHaveValueErrorMsg);
        }
        if(String.isBlank(charge.Transaction_Code__c))
        {
            chargeValidate = false;
            charge.Transaction_Code__c.addError(MustHaveValueErrorMsg);
        }
        if(String.isBlank(charge.Corp_Code__c))
        {
            chargeValidate = false;
            charge.Corp_Code__c.addError(MustHaveValueErrorMsg);
        }
        
        if(String.isBlank(charge.CR_Ref__c))
        {
            chargeValidate = false;
            charge.CR_Ref__c.addError(MustHaveValueErrorMsg);
        }
        if(String.isBlank(charge.DR_Ref__c))
        {
            chargeValidate = false;
            charge.DR_Ref__c.addError(MustHaveValueErrorMsg);
        }
        if(String.isBlank(charge.CR_Account_No__c))
        {
            chargeValidate = false;
            charge.CR_Account_No__c.addError(MustHaveValueErrorMsg);
        }
        if(String.isBlank(charge.cost_Centre__c))
        {
            chargeValidate = false;
            charge.cost_Centre__c.addError(MustHaveValueErrorMsg);
        }
        if(charge.Effective_Date__c==null)
        {
            chargeValidate = false;
            charge.Effective_Date__c.addError(MustHaveValueErrorMsg);
        }
        
        return chargeValidate;
    }*/

}