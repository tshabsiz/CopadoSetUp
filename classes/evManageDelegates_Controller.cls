/**
* Author: Unknown
----------------------------------------d
* Updated : Rudolf Niehaus
* Date   : 2017-10-10 / 11
* Desc   :
----------------------------------------
**/
public class evManageDelegates_Controller{
    
    Public String confirmedAlist {get;set;}
    Public String confirmedBlist {get;set;}
    public List<Delegate__c> delegateAList {get; set;}
    public List<Delegate__c> delegateBList {get; set;}
    public String eventId {get; set;}
    Public event__c EventRec {get;set;}
    public Boolean ConfirmSuccess {get;set;}
    public String DelegateIDsString;
    
    
    public evManageDelegates_Controller(){
        
        confirmedAlist = '';
        confirmedBlist = ''; 
        eventId = '';
        eventId = ApexPages.currentPage().getParameters().get('id');
        system.debug('eventId :'+eventId);
        EventRec = evRegistration.Getevent(eventId);
        
        delegateAList = [Select Id, Name, Contact__r.FirstName, Contact__r.LastName, 
                         Contact__r.Title, Contact__r.Job_title__c,Contact__r.Account.Name, Host__r.Name, isFlaggedForDeletion__c   
                         From Delegate__c 
                         Where Invitation_List__c = true and 
                         Event__r.Id = :eventId and 
                         RSVP_Status__c != 'Invited' and 
                         RSVP_Status__c != 'Yes' and 
                         RSVP_Status__c != 'Maybe'];
        delegateBList = [Select Id,Name,Contact__r.FirstName,Contact__r.LastName,Contact__r.Title, 
                         Contact__r.Job_title__c,Contact__r.Account.Name,Host__r.Name, isFlaggedForDeletion__c  
                         From Delegate__c 
                         Where Invitation_List__c = false and 
                         Event__r.Id = :eventId and 
                         RSVP_Status__c != 'Invited' and 
                         RSVP_Status__c != 'Yes' and 
                         RSVP_Status__c != 'Maybe' 
                         order by Waiting_List_Priority__c asc];
    }
    
    public void confirm(){
        
        ConfirmSuccess = false;
        
        List<String> ListA = new List<String>();
        List<String> ListB = new List<String>();
        
        Map<String, Integer> bListOrder = new Map<String, Integer>();
        
        if(confirmedAlist.length() > 0){
            ListA.addAll(confirmedAlist.split(','));
        }
        
        if(confirmedBlist.length() > 0){
            ListB.addAll(confirmedBlist.split(','));
        }
        
        Integer delOrderNumber = 0;
        for(String delId : ListB){
            bListOrder.put(delId, ++delOrderNumber);    
        }
        
        list<Delegate__c> updateLists = new list<Delegate__c>();
        
        for(Delegate__c d :[Select Waiting_List_Priority__c, Invitation_List__c From Delegate__c Where Id IN :ListA and Event__r.Id = :eventId]){
            d.Invitation_List__c = true;
            d.Waiting_List_Priority__c = 0;
            updateLists.add(d);
        }
        
        for(Delegate__c d :[Select Id, Waiting_List_Priority__c, Invitation_List__c From Delegate__c Where Id IN :ListB and Event__r.Id = :eventId]){
            d.Invitation_List__c = false;
            d.Waiting_List_Priority__c = bListOrder.get(string.ValueOf(d.Id));
            updateLists.add(d);
        }
        
        try{
            update updateLists;
        }
        catch(Exception e){
            System.debug(e.getMessage());
            apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an issue updating the delegates, please contact a system administrator for further assistance'));
        }
        
        ConfirmSuccess = true;
    }
    
    
    public PageReference cancel(){
        
        return new PageReference('/' + eventId);
    }
    
    public PageReference delDelegate() 
    { 
        if(test.isRunningTest() == false)
        {
            DelegateIDsString = Apexpages.currentPage().getParameters().get('combinedDelList');
        }
        system.debug('DelegateIDsString :' +DelegateIDsString);  
        
        list<string> delegateIDstoDeleteStrings = DelegateIDsString.split(',');
        list<id> delegateIDstoDelete = new list<id>();
        
        for(string IdVarString : delegateIDstoDeleteStrings)
        {
            if(IdVarString != '' && IdVarString != ' ')
            {
                delegateIDstoDelete.add(IdVarString);
            }
            
        }
        
        List<delegate__c > DelegatesToDelete = new  List<delegate__c >();
        
        system.debug('delegateIDstoDelete :' +  delegateIDstoDelete);
        
        for(id IdVar : delegateIDstoDelete)
        {
            delegate__c del = new delegate__c();
            del.id = IdVar;
            DelegatesToDelete.add(del);
        }
        try
        {
            delete DelegatesToDelete;
        }
        catch(exception e)
        {
            System.debug(e.getMessage());
            apexpages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an issue deleting the delegates, please contact a system administrator for further assistance'));
            return null;  
        }
        
        PageReference PR =  page.evManageDelegates;
        PR.setRedirect(true);
        PR.getParameters().put('id', eventId);
        return PR;//new PageReference('/' + eventId)
        //return null;
    }
}