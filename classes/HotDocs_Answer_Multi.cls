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
public class HotDocs_Answer_Multi extends HotDocs_Answer implements IHotDocs_Answer
{
	public List<IHotDocs_Answer> value = new List<IHotDocs_Answer>();

	/**
	* Constructor - List
	**/
	public HotDocs_Answer_Multi(String inputName, List<IHotDocs_Answer> inputValue)
	{			
		name = inputName; 
		dataType = 'MULTI';
		value = inputValue; 
	}

	/**
	* Constructor - Single
	**/
	public HotDocs_Answer_Multi(String inputName, IHotDocs_Answer inputValue)
	{			
		name = inputName; 
		dataType = 'MULTI';
		value.add(inputValue);
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