/*
* 
* 17-08-09  DH  IMplemented the new RSVP_Status and Registration_Status values and rules
*               Rename DelegateRespSting to RSVP
Throw all exceptions for now. Can do local handling of some later, but need to implement a site error page to handle many of them
  17-08-17  DF Updating to use new delegate fields and removing contact update
DF - please see some comments from DH->DF
DP - Added custom metadata settings
* 
*/

public class evRSVP_Controller  
{
    public class MyException extends Exception {} 
    public Id                       DelegateID ;
    public evSetting__mdt   customMeta;
    public Contact                  thisContact                     {get;set;} 
    public Delegate__c              thisDelegate                    {get;set;} 
    Public Event__c                 thisEvent                       {get;set;}
    Public string                   RSVP                            {get;set;}//Holds response from delegate when they click the accept or reject in the inviation email sent to them
    public String                   inputEmailAddressToVerify       {get;set;}
    public boolean                  accept1                         {get;set;}
    public boolean                  accept3                         {get;set;}
    public Boolean                  isDisableMandatoryFields        {get;set;}
    public Boolean                  PartnersInserted		        {get;set;}
    public Map<String, String>      errorList                       = new Map<String, String>();
    public string phoneNumberFormatREGEX {get;set;}
    public string mobileNumberFormatREGEX {get;set;}
    public string phoneNumberFormatDesc {get;set;}
    public string mobileNumberFormatDesc {get;set;}
    
    //public MAP<Integer,Delegate__c> delegatePartnerMap {get;set;}
    public List<Delegate__c> listOfPartnerDelegates  {get;set;}
    public Integer SelectedIndex{get;set;}
    
    public evRSVP_Controller()
    {
      
        
        customMeta = evRegistration.GetCustomMetadata('Bhalisa_Default');
        
        try
        {
            phoneNumberFormatREGEX = customMeta.Phone_Number_Format_REGEX__c;
            mobileNumberFormatREGEX = customMeta.Mobile_Number_Format_REGEX__c;
            phoneNumberFormatDesc = customMeta.Phone_Number_Format_description__c;
            mobileNumberFormatDesc = customMeta.Mobile_Number_Format_description__c;
        }
        catch (exception e)
        {
            ApexPages.addMessages(new MyException ('An unexpected error (ERR-METADATA) has been encountered.  Please accept our apologies for any inconvenience.\n\n' ));
            throw e;
        }
        
        try
        {
            DelegateID = ApexPages.currentPage().getParameters().get('delid'); 
            RSVP = ApexPages.currentPage().getParameters().get('rsvp');
            
            system.debug('DelegateID: '+DelegateID);
            system.debug('RSVP: '+RSVP);
            
            String DisableMandatoryFieldsString =  ApexPages.currentPage().getParameters().get('mandatory');
            if(DisableMandatoryFieldsString != null && DisableMandatoryFieldsString == 'false')
            {
                isDisableMandatoryFields = true;
            }
            else
            {
                isDisableMandatoryFields = false;
            }
        }
        catch (exception e)
        {
            ApexPages.addMessages(new MyException ('An unexpected error (ERR-ID) has been encountered.  Please accept our apologies for any inconvenience.\n\n'));
            throw e;
        }
        
        try
        {
            ////////////////////////////Prebooked Delegate Handler
            thisDelegate = evRegistration.GetDelegate(DelegateID);
            thisContact = evRegistration.GetContact(thisDelegate.Contact__c);
            thisEvent = evRegistration.Getevent(thisDelegate.event__c);
            
            listOfPartnerDelegates =  new list<Delegate__c>();// delegatePartnerMap = new MAP<Integer,Delegate__c>();
            Integer count = 0;
            if(thisEvent.Maximum_Number_Of_Partners_Per_Delegate__c != null && thisEvent.Maximum_Number_Of_Partners_Per_Delegate__c > 0  )
            {
                while (count < thisEvent.Maximum_Number_Of_Partners_Per_Delegate__c)  
                { 
                    listOfPartnerDelegates.add(new Delegate__c());
                    count++;
                }
            }
            
          /*   
            if(string.isBlank(thisDelegate.Company__C) == true)
            {
                thisDelegate.Company__C = thisContact.Company_name__C;
            } */
            
            if(string.isBlank(thisDelegate.first_name__c) == true)
            {
                thisDelegate.first_name__c = thisContact.firstname;
            }
            
            if(string.isBlank(thisDelegate.last_name__c) == true)
            {
                thisDelegate.last_name__c = thisContact.lastname;
            }
            
           /*   if(string.isBlank(thisDelegate.Industry__C) == true)
            {
                thisDelegate.Industry__C = thisContact.Industry__c;
            }
           if(string.isBlank(thisDelegate.email__c) == true) //email used as verification so may not be populated
            {
                thisDelegate.email__c = thisContact.email;
            }
            thisDelegate.email__c = '';
            if(string.isBlank(thisDelegate.Assistant_Email__c) == true)
            {
                thisDelegate.Assistant_Email__c = thisContact.Assistant_Email__c;
            }
            
            if(string.isBlank(thisDelegate.mobile__c) == true)
            {
                thisDelegate.mobile__c = thisContact.mobilePhone;
            }
            
            if(string.isBlank(thisDelegate.Phone__c) == true)
            {
                thisDelegate.Phone__c = thisContact.phone;
            }
            
            if(string.isBlank(thisDelegate.Salutation__c) == true)
            {
                thisDelegate.Salutation__c = thisContact.Salutation;
            }
            
            if(string.isBlank(thisDelegate.title__c) == true)
            {
                thisDelegate.title__c   = thisContact.title;
            }
            
            if(string.isBlank(thisDelegate.id__C) == true)
            {
                thisDelegate.id__C = thisContact.id__c;
            }
             
            if(string.isBlank(thisDelegate.Emergency_Contact_Name__c) == true)
            {
                thisDelegate.Emergency_Contact_Name__c = thisContact.Emergency_Contact_Name__c;
            }
             
            if(string.isBlank(thisDelegate.Emergency_Contact_Relationship__c) == true)
            {
                thisDelegate.Emergency_Contact_Relationship__c = thisContact.Emergency_Contact_Relationship__c;
            }
             
            if(string.isBlank(thisDelegate.Emergency_Contact_Tel__c) == true)
            {
                thisDelegate.Emergency_Contact_Tel__c = thisContact.Emergency_Contact_Tel__c;
            }
             
            if(string.isBlank(thisDelegate.Main_Member_Name__c) == true)
            {
                thisDelegate.Main_Member_Name__c = thisContact.Main_Member_Name__c;
            }
             
            if(string.isBlank(thisDelegate.Medical_Aid_Name__c) == true)
            {
                thisDelegate.Medical_Aid_Name__c = thisContact.Medical_Aid_Name__c;
            }
             
            if(string.isBlank(thisDelegate.Medical_Aid_No__c) == true)
            {
                thisDelegate.Medical_Aid_No__c = thisContact.Medical_Aid_No__c;
            }
            
            if(string.isBlank(thisDelegate.Nationality__c) == true)
            {
                thisDelegate.Nationality__c = thisContact.Nationality__c;
            }
            
            if(string.isBlank(thisDelegate.Medical_Conditions__c) == true)
            {
                thisDelegate.Medical_Conditions__c = thisContact.Medical_Conditions__c;
            }
            
            if(string.isBlank(thisDelegate.Postal_Code__c) == true)
            {
                thisDelegate.Postal_Code__c = thisContact.Postal_Code__c;
            }
            
            if(string.isBlank(thisDelegate.Type_of_Identification__c) == true)
            {
                thisDelegate.Type_of_Identification__c = thisContact.Type_of_Identification__c;
            }*/
            thisDelegate.Company__C = null;
            thisDelegate.Industry__C = null;
            thisDelegate.email__c = null;
            thisDelegate.mobile__c = null; 
            thisDelegate.Phone__c = null;
            thisDelegate.Salutation__c = null;
            thisDelegate.title__c = null;
            thisDelegate.id__C = null;
            thisDelegate.Emergency_Contact_Name__c = null;
            thisDelegate.Emergency_Contact_Relationship__c = null;
            thisDelegate.Emergency_Contact_Tel__c = null;
            thisDelegate.Main_Member_Name__c = null;
            thisDelegate.Medical_Aid_Name__c = null;
            thisDelegate.Medical_Aid_No__c = null;
      
            thisDelegate.Medical_Conditions__c = null;
            thisDelegate.Postal_Code__c = null;
            thisDelegate.Type_of_Identification__c = null;
            thisDelegate.Nationality__c = null;
            thisDelegate.Country_Of_Residence__c = null;
			thisDelegate.Transport_Required__c = false;
        }
        catch (exception e)
        {
            system.debug('Exception: '+e);
            ApexPages.addMessages(new MyException ('An unexpected error (ERR-Data) has been encountered.  Please accept our apologies for any inconvenience.\n\n' ));
            throw e; 
        }
        
    }
    
    Public pagereference HandleResponse()
    {
        system.debug(logginglevel.DEBUG, 'HandleResponse Starting...');
        //DH->DF and checking parameters should be done as the first step before processing anything
        //check that RSVP has valid value
        /*if (String.isBlank(RSVP) || (RSVP != 'Yes' && RSVP !='No' && RSVP !='Maybe')) 
        {
            MyException e = new MyException ('An unexpected error (ERR-R2) has been encountered.  Please accept our apologies for any inconvenience.\n\n');
            ApexPages.addMessages(e);
            throw e;
        }*/
        //ensure that we have a valid delegate
        if (thisDelegate == Null) 
        {
            MyException e =new MyException ('An unexpected error (ERR-R3) has been encountered.  Please accept our apologies for any inconvenience.\n\n'  );
            ApexPages.addMessages(e);
            throw e;
        }
        
        String rs = String.isBlank(thisDelegate.Registration_Status__c) ? '' : thisDelegate.Registration_Status__c;
        
        // Is this registration already complete?
        if (rs == 'Accepted' || rs == 'Declined' || rs == 'Confirmed' || rs == 'Cancelled')
        {
            pagereference pr =  page.evRSVP_Info;
            /*DH->DF As we have ONE controller with multiple pages you do not need to do this... the view state will go with to the new page
pr.getParameters().put('delid', thisDelegate.id); 
pr.setRedirect(true);
*/
            return pr;
        }
        //DH->DF we need to explicitly cater for all defined values in this type of logic.  Esle is very dangerous
        else if (rs == 'Pending' || rs == '') 
        {
            if (RSVP == 'Yes') 
            {
                thisDelegate.RSVP_Status__c = RSVP;
                thisDelegate.Registration_Status__c = 'Pending';
                thisDelegate.Registered_Date__c = null;
            }
            else if (RSVP == 'No')
            {
                thisDelegate.RSVP_Status__c = RSVP;
                thisDelegate.Registration_Status__c = 'Declined';
                thisDelegate.Registered_Date__c = null;
            }
            else if (RSVP == 'Maybe') 
            {
                thisDelegate.RSVP_Status__c = RSVP;
                thisDelegate.Registration_Status__c = 'Pending';
                thisDelegate.Registered_Date__c = null;
            }
            else if (string.isBlank(RSVP)) 
            {
                thisDelegate.RSVP_Status__c = RSVP;
                thisDelegate.Registration_Status__c = 'Pending';
                thisDelegate.Registered_Date__c = null;
            }
            //Time stamp the first time the delegate RSVP's
            if (thisDelegate.RSVP_Time__C == null) 
            {
                thisDelegate.RSVP_Time__C = dateTime.now();
            }
            
            //DH->DF  Make try section only where we expect possible errors:  debug the rest
            try
            {
                update thisDelegate;
            }
            catch (exception e)
            {
                ApexPages.addMessages(new MyException ('An unexpected error (ERR-HR) has been encountered.  Please accept our apologies for any inconvenience.\n\n' ));
                throw e;
            }
            
        }
        else  // unexpected value
        {
            MyException e = new MyException ('An unexpected error (ERR-X) has been encountered.  Please accept our apologies for any inconvenience.\n\n'  );
            ApexPages.addMessages(e);
            throw e;
        }
        return null;
    }
    
    //DH->DF This code (old accept method) was very confusing as you overloaded this method for the Accept button on two different pages with two totally different logic
    //and used a value on the delegate to control the behaviou
    //I have split it into TWO methods for the TWO button
    //
    Public pagereference ConfirmAccept()
    {
        system.debug(logginglevel.DEBUG, 'ConfirmAccept Starting...');
        
        //validate input fields on the form        
        if(isInvalidDelegateForm()) 
        {
            return null;
        }   
        
        //check that email address entered matches the invitee
        if ( thisDelegate.email__c != thisContact.email)
        {
            errorList.put('1','The email address provided does not match that on the invitation.  This invitation is not transferable');
            return null;
        }
        
        //check that tersm and conditions have been accepted
        if(accept1!=true )
        {
            errorList.put('1','Please agree to the Terms and Conditions below');
            return null;
        }
        
        try
        {
            system.debug(LoggingLevel.DEBUG, 'thisContact: ' + thisContact);

            
            thisDelegate.Registration_Status__c = 'Accepted';
            thisDelegate.Registered_Date__c = dateTime.now();
            
            Update thisDelegate;
            
            //**** WE CANNOT SIMPLY UPDATE CONTACTS IN BARCLAYS SCENARIO
            //This could overwrite valuable client data
            //Update thisContact;
            
            errorList.remove('1'); 
            errorList.remove('2'); 
            errorList.remove('3');
        }
        catch (exception e)
        {
            ApexPages.addMessages(new MyException ('An unexpected error (ERR-DU) has been encountered.  Please accept our apologies for any inconvenience.\n\n' ));
            throw e;
        } 
        return null;
    }
    
    Public pagereference CancelAccept()
    {  
        pagereference pr =  page.evDecline;
        pr.getParameters().put('delid', thisDelegate.id);
        pr.getParameters().put('rsvp', 'No');
        pr.setRedirect(true);
        return pr;
    } 
    
    
    
    Public pagereference CancelDecline()
    {  
        pagereference pr =  page.evRSVP;
        pr.getParameters().put('delid', thisDelegate.id);
        pr.getParameters().put('rsvp', 'Yes');
        pr.setRedirect(true);
        return pr;
    } 
    
    Public void InsertPartnerDelegates()
    {
        List<delegate__c> DelegatesToInsert  = new List<delegate__c>();
        if(listOfPartnerDelegates.size() > 0)
        {
            List<delegate__c> ContactToInsert = new List<delegate__c>();
            integer numberOfPartners = 1;
            for(delegate__c DelRec :listOfPartnerDelegates) 
            {
                if(DelRec.Last_Name__C == '' || DelRec.Last_Name__C == ' ')
                {
                    DelRec.Last_Name__C = null;
                }
                if(DelRec.Email__c != null ||  DelRec.Last_Name__C != null || DelRec.Partner_Type__c !=  null|| DelRec.first_name__c != null )
                {
                    
                    //only run validation on delegates records that have at least one field filled in
                    if(DelRec.Email__c ==null ||  DelRec.Last_Name__C ==null || DelRec.Partner_Type__c ==  null|| DelRec.first_name__c == null )
                    { 
                        //if delegate is missing one of the fields, through error
                        SYstem.debug(DelRec.Email__c);
                        SYstem.debug(DelRec.Last_Name__C);
                        SYstem.debug(DelRec.Partner_Type__c);
                        SYstem.debug(DelRec.first_name__c);
                        ApexPages.addMessages(new MyException ('Please ensure all fields have been completed' ));
                        return;
                    }
                }
                
                
                //DelRec.Contact_Reference__c = delegatesToInsert.get(0).ID;
                DelRec.partner__c = thisDelegate.ID;
                DelRec.event__c = thisDelegate.Event__c;
                DelRec.Registration_Status__c = 'Accepted';
                DelRec.Delegate_Type__c = 'Partner';
                DelegatesToInsert.add(DelRec);
                
                
                numberOfPartners= numberOfPartners+ 1;
                
            }
            System.debug(DelegatesToInsert);
            try
            {              
                if(DelegatesToInsert.size() > 0)
                {
                    insert DelegatesToInsert;
                    thisDelegate.Actual_Number_Of_Partners__c = numberOfPartners;
                    PartnersInserted = true;
                }
                
            }
            catch(exception e)
            {
                ApexPages.addMessages(new MyException ('An unexpected error (ERR-PI) has been encountered.  Please accept our apologies for any inconvenience.\n\n' ));
            }
        }
    }
    
  /*  Public void AddPartnerRow()
    {
        //Make instance of Contact. Add to Contact Item List
        delegate__c newDel = new delegate__c();
        //SYstem.debug(delegatePartnerMap.size());
       // delegatePartnerMap.put(delegatePartnerMap.size()+1,newDel);
    }

    public PageReference RemoveRow()
    {
        SYstem.debug(SelectedIndex);
        
        delegatePartnerMap.remove(SelectedIndex);
        return null;
    }*/
    
    //ERROR HANDLERS
    public Boolean getHasErrorsLevel1() 
    {
        if(errorList.get('1') == null) 
        {
            return false;
        }
        return true;
    }
    public String getErrorsLevel1() 
    {
        if(errorList.get('1') == null) 
        {
            return 'NONE';
        }
        return errorList.get('1');
    }
    
    public Boolean isInvalidDelegateForm() 
    {
        Boolean isInvalid = false;
        String missingFields = '';
        String errorMessages = '';
        errorList.remove('1');
        //Booking_confirmation_mandatory_fields__c,//(CC010)
        System.debug('Booking_confirmation_mandatory_fields__c :' + thisEvent.Booking_confirmation_mandatory_fields__c );
        
        if (thisDelegate.first_name__c==NULL || thisDelegate.first_name__c=='')
        {
            missingFields += (missingFields != '' ? ', ' : '') + 'First Name';
        }
        if (thisDelegate.last_name__c ==NULL || thisDelegate.last_name__c=='') 
        {
            missingFields += (missingFields != '' ? ', ' : '') + 'Last Name';
        }
        if (thisDelegate.email__c==NULL || thisDelegate.email__c=='' ) 
        {
            missingFields += (missingFields != '' ? ', ' : '') + 'Email Address';
        }
        IF( isDisableMandatoryFields == false)
        {
            if ( thisEvent.Booking_confirmation_mandatory_fields__c.contains('Company')  &&(thisDelegate.Company__c == Null || thisDelegate.Company__c=='')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Company';
            }
            if(thisEvent.Booking_confirmation_mandatory_fields__c.contains('Industry')  && (thisDelegate.Industry__c==NULL || thisDelegate.Industry__c=='' || thisDelegate.Industry__c=='Select' ) )
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Industry';
            }
            
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Job Title')  &&(thisDelegate.Title__c==NULL || thisDelegate.Title__c==''))
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Job Title';
            }
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Mobile')  &&(thisDelegate.Mobile__c==NULL || thisDelegate.Mobile__c=='')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Mobile';
            }
            
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('ID Number')  &&(thisDelegate.id__c==NULL || thisDelegate.id__c=='')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'ID Number';
            }
            
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Delegate Type')  &&(thisDelegate.Delegate_Type__c==NULL || thisDelegate.Delegate_Type__c=='' || thisDelegate.Delegate_Type__c == '-Select-')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Delegate Type';
            }
            
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Salutation')  &&(thisDelegate.Salutation__c==NULL || thisDelegate.Salutation__c=='')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Salutation';
            }
            
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Visit Reason')  &&(thisDelegate.Event_Visit_Reason__c==NULL || thisDelegate.Event_Visit_Reason__c =='' || thisDelegate.Event_Visit_Reason__c == '-Select-')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Visit Reason';
            }
            
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Lead Source')  &&(thisDelegate.Lead_Source__c==NULL || thisDelegate.Lead_Source__c=='' || thisDelegate.Lead_Source__c == '-Select-')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Lead Source';
            }
            
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Emergency Contact')  &&(thisDelegate.Emergency_Contact_Name__c ==NULL || thisDelegate.Emergency_Contact_Relationship__c =='' || thisDelegate.Emergency_Contact_Tel__c == '')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Emergency Contact';
            }
            
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Nationality')  &&(thisDelegate.Nationality__c==NULL || thisDelegate.Nationality__c=='')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Nationality';
            }
            
             if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Country Of Residence')  &&(thisDelegate.Country_Of_Residence__c==NULL || thisDelegate.Country_Of_Residence__c=='')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Country Of Residence';
            }
            
             if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Assistant Email')  &&(thisDelegate.Assistant_Email__c==NULL || thisDelegate.Assistant_Email__c=='')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Assistant Email';
            }
            
            
            if (thisEvent.Booking_confirmation_mandatory_fields__c.contains('Assistant Phone Number')  &&(thisDelegate.Assistant_Phone_Number__c ==NULL || thisDelegate.Assistant_Phone_Number__c=='')) 
            {
                missingFields += (missingFields != '' ? ', ' : '') + 'Assistant Phone Number';
            }
            
            if(thisDelegate.email__c!= null && thisDelegate.email__c!= '' && !Pattern.matches('^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$', thisDelegate.email__c) ) 
            {
                errorMessages += (errorMessages != '' ? '<br/>' : '') + 'Email address is incorrectly formatted.';
                isInvalid = true;
            } 
            if(thisDelegate.Assistant_Email__c != null && thisDelegate.Assistant_Email__c != '' && !Pattern.matches('^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$', thisDelegate.Assistant_Email__c) ) 
            {
                errorMessages += (errorMessages != '' ? '<br/>' : '') + 'Assistant email address is incorrectly formatted.';
                isInvalid = true;
            } 
        }
        
        if (missingFields != '')
        {
            
            errorMessages += (errorMessages != '' ? '<br/>' : '') + 'Please ensure the required fields ('+missingFields+') have been completed.';
            isInvalid = true; //null
        }
        
        if (isInvalid) 
        {
            errorList.put('1',errorMessages);
        }
        return isInvalid;
    }
    
    
    public List<SelectOption> getEventIndustryTypes()  
    {
        Schema.DescribeFieldResult fieldResult = Delegate__c.Industry__C.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-select-'));  
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }  
        return options;
    }
    
    public List<SelectOption> getDelegateTypes()  
    {
        Schema.DescribeFieldResult fieldResult = Delegate__c.Delegate_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-select-'));  
        for( Schema.PicklistEntry f : ple)
        {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }  
        return options;
    }
    
    public List<SelectOption> getEventGenderTypes()  
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-select-')); 
        options.add(new SelectOption('Male','Male')); 
        options.add(new SelectOption('Female','Female')); 
        options.add(new SelectOption('Other','Other')); 
        System.debug('options +' + options);
        return options;
    }
    
    public List<SelectOption> getIdentificationTypes()  
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-select-','-select-')); 
        options.add(new SelectOption('SA ID Number','SA ID Number')); 
        options.add(new SelectOption('Passport','Passport')); 
        options.add(new SelectOption('Non SA ID Number','Non SA ID Number')); 
        System.debug('options +' + options);
        return options;
    }
    
    //PICK LIST VALUES
    public List<SelectOption> getDietOptions() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('None','None'));
        options.add(new SelectOption('Halaal','Halaal'));
        options.add(new SelectOption('Kosher','Kosher'));
        options.add(new SelectOption('Vegetarian','Vegetarian'));
        options.add(new SelectOption('Vegan','Vegan'));
        return options;
    }
    
    public List<SelectOption> getCurrencyOptions() 
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('ZAR','ZAR'));
        options.add(new SelectOption('USD','USD'));
        options.add(new SelectOption('EUR','EUR'));
        return options;
    }
    
    public List<SelectOption> GetCompanyOrIndividualBookingTypes()
    {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Individual','Individual'));
        options.add(new SelectOption('Company','Company'));
        
        return options;
    }      
}