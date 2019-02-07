public with sharing class MeetingPrintViewController {
    private Meeting__c meating;
    private String meetingID;
    public List<Meeting__c> PreviousSessions { get; set; }
    public List<Agenda__c> Agendas { get; set; }
    public List<Action__c> Actions { get; set; }
    public Meeting__c Meeting { get{ return meating;} }
    public String imageDoneURL{get;set;}
    public String imageWarningURL{get;set;}
    public String imageErrorURL{get;set;}
    
	public MeetingPrintViewController(ApexPages.StandardController stdController) {
    	try
        {
            List<Document> documentList= [SELECT Id, Name FROM Document
                                            WHERE Name IN ('Icon Error','Icon Done','Icon Warning')];
            
            if(documentList.size()>0)
    		{
                for(Document doc : documentList) {
 					if (doc.Name == 'Icon Done') imageDoneURL = '/servlet/servlet.FileDownload?file=' + doc.id;
                    if (doc.Name == 'Icon Error') imageErrorURL = '/servlet/servlet.FileDownload?file=' + doc.id;
                    if (doc.Name == 'Icon Warning') imageWarningURL = '/servlet/servlet.FileDownload?file=' + doc.id;
                }
    		}
            
            if (String.isEmpty(meetingID)) {
                meetingID = ApexPages.currentPage().getParameters().get('id');
            }
            meating = queryMeeting(meetingID);

            if(meating!=null)
            {
                PreviousSessions = queryPreviousSessions();
                Agendas = queryAgendas();
                Actions = queryActions();
            }
        } catch(Exception exc) {
            System.debug('Error '+exc.getStackTraceString());
        }
    }
    
    private Meeting__c queryMeeting(String meetingID) {
        if (meetingID!=NULL && meetingID!='') {
 			return [SELECT Owner.Name, Committee__r.Name, Name, Start__c, Total_Time__c, Location__c,
                    (SELECT Id, Attendee__r.Name, Present__c FROM Meeting_Attendees__r),
                    (SELECT Id, Name, Description__c, Resolution__c, Agenda__r.Name FROM Decisions_Questions__r ORDER BY CreatedDate),
                    (SELECT Id, Name, Topic__c, Description__c FROM Information__r)
                    FROM Meeting__c 
                    WHERE Id =: meetingID LIMIT 1];
        }
        return NULL;
    }
    
    private List<Meeting__c> queryPreviousSessions() {
        if (meating != NULL) {
 			return [
                	SELECT Id, Start__c, (SELECT Name, IsClosed__c, Due_Date__c FROM Collaboration_Tasks__r)
                    FROM Meeting__c
                    WHERE Committee__c =: meating.Committee__c
                    AND Start__c < :meating.Start__c
            ];
        }
        return NULL;
    }
    
    private List<Agenda__c> queryAgendas() {
    	if (meating != NULL) {
 			return [
                	SELECT Id, Order__c, Name, Description__c, Presenter__r.Name, Duration__c, Private__c,
                	(SELECT Id, Title, Body FROM Notes ORDER BY CreatedDate)
                	FROM Agenda__c
                	WHERE Meeting__c =: meetingID
                	ORDER BY Order__c
            ];
        }
        return NULL;    
    }
    
    private List<Action__c> queryActions() {
    	if (meating != NULL) {
 			return [
                	SELECT Id, Name, Comments__c, Action_Owner__r.Name, Start_Date__c, Due_Date__c, Status_Icon__c, IsClosed__c, Priority__c,
                	(SELECT Assigned_to__r.Name FROM Assignments__r ORDER BY Assigned_to__r.Name)
                	FROM Action__c
                	WHERE Meeting__c =: meetingID
                	ORDER BY Due_Date__c
            ];
        }
        return NULL;     
    }
}