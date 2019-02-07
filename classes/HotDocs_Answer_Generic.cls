/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 24/10/2017 - PG    - Created Class. 

**/ 
public class HotDocs_Answer_Generic extends HotDocs_Answer implements IHotDocs_Answer
{
	public String value { get; set; }

	public HotDocs_Answer_Generic(String inputType, String inputName, String inputValue)
	{			
		name = inputName; 
		dataType = inputType;
		value = inputValue; 
	}

	public String getName()
	{
		return name;
	}

	public String getType()
	{
		return dataType;
	}

	public Object getData()
	{
		return value;
	}
}