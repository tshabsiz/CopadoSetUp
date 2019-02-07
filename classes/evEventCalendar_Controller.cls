Public class  evEventCalendar_Controller 
{
    /****************************************************************************
* @Author     : Daniel Field
* @Date       : 06/11/2016
* @Description: Controller class used for the caseware training customer success services page
* @Purpose    : Controller class
* @Pages      : 
* @Test Class : 
//----------------------------------------------------------------------------*/
    
    public String userCurrentView {get; set;}//Used to hold current user calander view
    public String EventTypeSearchString {get; set;}
    //public List<CQS_Course__c>  CarouselCourseList  {get;Set;}
    Public	evEventCalendar_Controller()
    {
        userCurrentView = 'month';
        //END/////populate search options for market and product////////////////
    }
    
    public List<SelectOption> getEventTypeSelectOptions() 
    {
        List<SelectOption> EventTypeSelectOptions = new List<SelectOption>();
        EventTypeSelectOptions.add(new SelectOption('All','Displaying ALL event types'));
        EventTypeSelectOptions.add(new SelectOption('Breakfast','Breakfast'));
        EventTypeSelectOptions.add(new SelectOption('Lunch','Lunch'));
        EventTypeSelectOptions.add(new SelectOption('Dinner','Dinner'));
		EventTypeSelectOptions.add(new SelectOption('Analyst Marketing: Roadshow','Analyst Marketing: Roadshow'));
        EventTypeSelectOptions.add(new SelectOption('Company Marketing: Roadshow','Company Marketing: Roadshow'));
        EventTypeSelectOptions.add(new SelectOption('Client Conference Calls','Client Conference Calls'));
        EventTypeSelectOptions.add(new SelectOption('Bespoke Client Meetings','Bespoke Client Meetings'));
        EventTypeSelectOptions.add(new SelectOption('Company/Site Visits','Company/Site Visits'));
        EventTypeSelectOptions.add(new SelectOption('Conference','Conference'));
        EventTypeSelectOptions.add(new SelectOption('Industry Expert Event','Industry Expert Event'));
        EventTypeSelectOptions.add(new SelectOption('Investor/Sector Field Trip','Investor/Sector Field Trip'));
        EventTypeSelectOptions.add(new SelectOption('Management Meeting','Management Meeting'));
        return EventTypeSelectOptions;
    }
    
    public List<SelectOption> getCitySelectOptions() 
    {
        List<SelectOption> CitySelectOptions = new List<SelectOption>();
        CitySelectOptions.add(new SelectOption('','All'));
        CitySelectOptions.add(new SelectOption('Johannesburg','Johannesburg'));
        CitySelectOptions.add(new SelectOption('Cape Town','Cape Town'));
        CitySelectOptions.add(new SelectOption('Durban','Durban'));
        CitySelectOptions.add(new SelectOption('East London','East London'));
        CitySelectOptions.add(new SelectOption('Port Elizabeth','Port Elizabeth'));
        CitySelectOptions.add(new SelectOption('Bloemfontein','Bloemfontein'));
        CitySelectOptions.add(new SelectOption('Nelspruit','Nelspruit'));
        CitySelectOptions.add(new SelectOption('Polokwane','Polokwane'));
        
        CitySelectOptions.add(new SelectOption('Other','Other'));
        return CitySelectOptions;
    }
    
    public pagereference doFilterCourseList()//Method That filters courses on the CourseList page
    {     
        return null;
    }
    
}