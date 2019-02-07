/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 10/11/2017 - PG    - Created Class. 

**/ 
public class HotDocs_WorkItem 
{
	public String Id;
	public String Name;
	public String Description;
	public String AnswerSetId;
	public PrimaryTemplate PrimaryTemplate;
	public String CreationDate;
	public String LastModifiedDate;
	public String CreatedBy;
	public String LastModifiedBy;
	public Object InterviewSessionId; 

	public class PrimaryTemplate 
	{
		public String TemplateId;
		public String TemplateTitle;
		public List<AssembledDocuments> AssembledDocuments;
	}

	public class AssembledDocuments 
	{
		public String DocumentId;
	}
	
	public static HotDocs_WorkItem parse(String json) 
	{
		return (HotDocs_WorkItem) System.JSON.deserialize(json, HotDocs_WorkItem.class);
	}
}