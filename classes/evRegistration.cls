/*
* 
DP - Added GetCustomMetadata method 
DF - updated the reference to the contact field Postal_Code__c to Post_Code__c to avoid duplicate fields
*/

public class evRegistration 
{
    public Static Event__c GetEvent(string EventId)
    {
        event__C   tempEvent   = 
            [
                SELECT 
                Administrator__c,
                Allow_Delegate_to_be_Invoiced_in_Forex__c,
                Request_Delegates_Dietary_Requirements__c,
                Allow_Booking_Online_for_New_Customers__c,
                //Country__c, 
                OwnerId, 
                //Start_Time_c__c, 
                EventStartTime__c,
                EventEndTime__c,
                Start_Date__c, 
                End_Date__c, 
                CurrencyISOCode, 
                Id, 
                Name, 
                Venue__r.Name, 
                Venue__r.Address__c,
                City__c, 
                Country__c,
                Web_pages_banner_url__c , 
                ID_Number_Passport_at_Booking__c,
                //Course__r.Prerequisite_Course__r.name,
                //Course__r.Banner_Url__c,
                Supported_client_discount__c,
                Price__c,
                Discount__c, 
                Discount_Threshold__c, 
                Discount_2__c, 
                Discount_Threshold_2__c,
                Price_Book_Entry_Id__c,
                //Course__r.ID,
                Description__c ,
                //Style_Sheet__c,
                Use_additional_options_1__c,
                Additional_Options_1__c,
                use_ticket_types_Batches__C,
                Terms_and_Conditions_Document_URL__c,
                Additional_Options_1_Name__c,
                Private_Delegate_Account_Name__c,
                //Merchandise__c,
                Use_additional_options_2__c,
                Additional_Options_2__c,
                Additional_Options_2_Name__c,
                Visit_Reason_Options__c,
                Lead_Source_Options__c,
                Use_Default_Delegate_Type__c,
                Default_Delegate_Type__c,
                Online_Processing__c,
                Company_Payment_Option__c,
                Individual_Payment_Option__c,
                Dietary_Requirements_Requiring_Payment__c,
                Online_Payment_Handler__c,
                Do_Dietary_Requirements_Require_Payment__c,
                Dietary_Requirements_Payment_Message__c,
                Use_Default_Ticket_Type__c,
                //Event_Sessions__c,
                theme__r.Primary_Logo__c,
                theme__r.Secondary_Logo__c,
                theme__r.Web_Pages_Background_Color__c,
                theme__r.Web_Pages_Font_Color__c,
                theme__r.Web_Pages_Heading_Font_Color__c,
                theme__r.Web_Pages_Foreground_Color__c,
                theme__r.Primary_Button_Background_Color__c,
                theme__r.Primary_Button_Text_Color__c,
                theme__r.Primary_Button_Background_Color_Hover__c,
                theme__r.Primary_Button_Text_Color_Hover__c,
                theme__r.Hyperlink_color__c,
                theme__r.Template__c,
                SupportEmailAddress__c,
                RSVPInformation__c,
                Terms_and_Conditions__r.Disclaimer__c,
                Terms_and_Conditions__r.Website_Privacy_policy__c,
                Process_Walk_ins_at_Registration__c,
                Accept_QR_Codes_at_Registration__c,
                Badges__c,
                Badge_Style__c,
                Badge_Style__r.Badge_Title__c,
                Badge_Style__r.Badge_Optional__c,
                Badge_Style__r.Badge_X__c,
                Badge_Style__r.Badge_Y__c,
                Badge_Style__r.Badge_Width__c,
                Badge_Style__r.Badge_Gutter__c,
                Badge_Style__r.Badge_Font_Family__c,
                Web_Page_Footer_URL__c,
                Booking_Confirmation_Fields__c,
                Booking_confirmation_mandatory_fields__c,
                Check_In_Confirmation_Fields__c,
                Check_In_Confirmation_Mandatory_Fields__c,
                Read_Only_Fields_On_Checkin__C,
                Allow_Pre_Reg__c,
                Allow_Badge_Reprints__c,
                RSVP_Date__c,
                Transport_Information__c,
                Allow_Partners__c,
                Maximum_Number_Of_Partners_Per_Delegate__c
                FROM 
                Event__c 
                WHERE 
                Id = :EventId
            ];
        return tempEvent;
    }
    
    
    public Static delegate__c GetDelegate(string delegateId)
    {
        delegate__c   tempDelegate   = 
            [
                SELECT
                Id,
                Name, 
                Event__c,
                Event__r.Name,
                Contact__r.Name,
                Contact__r.Account.Name,
                Contact__c,
                Status__c,
                Do_not_print_badge__c,
                Delegate_Type__C, //(CC 003)
                Industry__c,
                Age__C,
                Gender__C,
                Booking_Reference_Number__c,
                Payment_Reference__c,
                Payment_Type__c,
                //Ticket_Type__c,
                //Ticket_Type__r.name,
                Dietary_Requirement__c,     
                Additional_Option_1_selected__c,
                Additional_Option_2_selected__c,
                Event_Visit_Reason__c,
                Lead_Source__c,
                Company__c,
                Event_booking__C,
                Availibility__C,
                Accessibility__c,
                Invitation_Status__c,
                RSVP_Status__c,
                Registration_Status__c,
                RSVP_Time__c,
                Optional_Badge_Data__c,
                Event__r.Check_In_Confirmation_Fields__c,
                Event__r.Badges__c,
                Event__r.Start_Date__c,
                Event__r.End_date__c,
                Badge_Print_Counter__c,
                first_name__c,                                    
                last_name__c,                                    
                email__c,                                      
                Assistant_Email__c,                             
                mobile__c,                                      
                Phone__c,                                      
                Salutation__c,                                 
                title__c,                                      
                id__c,                                          
                Emergency_Contact_Name__c,                     
                Emergency_Contact_Relationship__c,             
                Emergency_Contact_Tel__c,                       
                Main_Member_Name__c,                           
                Medical_Aid_Name__c,                           
                Medical_Aid_No__c,                              
                Nationality__c,                                
                Medical_Conditions__c,                         
                Address__c,                                   
                Postal_Code__c,                               
                Type_of_Identification__c,
                Assistant_Phone_Number__c,
                Assistant_Name__c,
                Country_Of_Residence__c,
                Transport_Required__c,
                Maximum_Number_Of_Partners__c 
                FROM
                Delegate__c
                WHERE
                ID = :DelegateID
            ];
        return tempDelegate;
    }
    public Static Contact GetContact(string ContactId)
    {
        Contact tempContact  = 
            [
                SELECT
                Id, 
                Salutation,
                Name,
                FirstName,
                LastName,
                Phone, 
                MobilePhone,
                Title, 
                Email,
                Assistant_Email__c,
                Account.Name,
                Account.id,
                Account.industry
                FROM
                Contact
                WHERE
                Id = :ContactId
            ];
        return tempContact;
    }
   /* public Static CS_Event_Management__c GetEventSettings(string SettingName)
    {
        CS_Event_Management__c  settings; 
        if (Test.IsRunningTest()) 
        {
            //These settings cannot be inserted in the test class - known issue - RF
            settings = new CS_Event_Management__c();
            settings.SetupOwnerId = Userinfo.getOrganizationId();
            settings.Opportunity_Owner__c = UserInfo.getUserId();
            
            settings.Online_Payments_URL__c = 'http://somewhere.com';
            settings.Error_Message__c = 'Test Error Msg';
        }   
        else
        {
            if (SettingName != null && SettingName.trim() != '') 
            {
                settings = CS_Event_Management__c.getInstance(SettingName);
            }
            else
            {
                settings = CS_Event_Management__c.getOrgDefaults();
            }
        }
        return settings;
    }*/
    
    public Static evSetting__mdt GetCustomMetadata(string metadataName)
    {
        
        evSetting__mdt customMeta = 
            [
                select 
                Phone_Number_Format_REGEX__c, 
                Phone_Number_Format_description__c, 
                Mobile_Number_Format_REGEX__c,
                Mobile_Number_Format_description__c,
                Event_Team_Member_Partner_1__c,
                Event_Team_Member_Partner_2__c
                from 
                evSetting__mdt 
                where 
                QualifiedApiName =:metadataName 
                limit 1
            ] ;
        
        return customMeta;
    }
    
}