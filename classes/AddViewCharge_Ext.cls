/*======================================================
@Description : This controller will be used to manage charges associated with cases
@Created Date : 2017-11-02
@Created BY : Mabhedle Tonga 
@Test Class : AddViewCharge_Ext
========================================================*/

public class AddViewCharge_Ext 
{
    public Case currentCase {get;set;}
    public List<Charge__c> chargeList{get;set;}
    public List<ChargeWrapper> chargeWrapperList{get;set;}
    public Integer CRID{get;set;}
    public ID CurrentCaseID{get;set;}
    public boolean isSystemAdmin{get;set;}
    public final String UnableToEditMsg = Label.lbl_UnableToEditMsg;
    public final String MustHaveValueErrorMsg = 'Must have a value ';
    
    //Tonga MM : Standard controller constructor
    public AddViewCharge_Ext(ApexPages.StandardController controller)
    {	
        List<String> caseFields = new List<String>();
        
        caseFields.add('Charge_Locked__c');
        
        if(!Test.isRunningTest())
        {
        	controller.addFields(caseFields);    
        }
        
        currentCase = (Case)controller.getRecord();
        
        isSystemAdmin = isSystemAdminProfileById(UserInfo.getProfileId());
        getCaseCharge(currentCase.ID);
    }
    
    //Tonga MM : Helper method used to determine which profile is used by currently logged user
    private boolean isSystemAdminProfileById(ID profileID)
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
    public void unlock()
    {
        currentCase.Charge_Locked__c = false;
        update currentCase;
    }
    
    //Tonga : Method used for apporving and locksing charges that have been captures
    public void LockCharges()
    {
        if(currentCase.Charge_Locked__c)
           {
               // To Do : Add message stating charges have already been locked
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,Label.lbl_ChargeAlreadyApproved));

           }
           else
           {
               currentCase.Charge_Locked__c = true;
               update currentCase;
           }
        
    }
    
    //Tonga MM : upsert method for saving and updating existing charges
    public void SaveUpdates()
    {
        boolean errorFound  =false;
        if(!currentCase.Charge_Locked__c)
        {
            List<Charge__c> chargeToInsert = new List<Charge__c>();
            for(ChargeWrapper currentCharge : chargeWrapperList)
            {
                 if(validateInput(currentCharge.charge))
                 {
                     chargeToInsert.add(currentCharge.charge);
                 }
                else
                {
                    errorFound = true;
                }
                
            }
            
            if(chargeToInsert.size()>0 && !errorFound)
            {
                upsert chargeToInsert ID;
                getCaseCharge(CurrentCase.ID);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, Label.lbl_ChargeSuccessMsg));
            }    
            else
            {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please review the below Error'));
            }
            
        }
        else
        {
            // To do : Add validation message that will show that once approved users can no longer update the charges
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, UnableToEditMsg));

        }
        
    }
    public void getCaseCharge(ID CaseID)
    {
        chargeList= new List<Charge__c>();
        chargeWrapperList = new List<ChargeWrapper>();
        
        chargeList = [Select ID,Name,Charge_Account_No__c,Charge_Amount__c,Transaction_Code__c,Corp_Code__c,
                      Cost_Centre__c,Case__c,CR_Ref__c,DR_Ref__c,CR_Account_No__c,Effective_Date__c
        				from Charge__c where Case__c = :CaseID];
        
        integer index = 0;
        for(Charge__c c :chargeList)
        {
           
            chargeWrapperList.add(new ChargeWrapper(index,c));
             index+=1;
        }
    }
    public void DeleteItem()
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, UnableToEditMsg));
        }
        
    }
    public void addnewLine()
    {
        if(!currentCase.Charge_Locked__c)
        {
            Integer index=chargeWrapperList.size();
            
            chargeList.add(new Charge__c(Case__c =  currentCase.Id));
            chargeWrapperList.add(new ChargeWrapper(index++,new Charge__c(Case__c =  currentCase.Id)));
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,UnableToEditMsg));
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
    public void updateSequence()
    {
        integer index = 0;
        for(ChargeWrapper chargeWR : chargeWrapperList)
        {
            chargeWR.index=0;
            index +=1;
        }
    }
    
    public boolean validateInput(Charge__c charge)
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
    }

}