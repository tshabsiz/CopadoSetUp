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
public class HotDocs_Document 
{
	public String MimeType;
	public String CreatedBy;
	public String CreatedOn;
	public String FileExtension;
	public String Title;
	public String FileName;

	public static HotDocs_Document parse(String json)
	{
		return (HotDocs_Document) System.JSON.deserialize(json, HotDocs_Document.class);
	}
}