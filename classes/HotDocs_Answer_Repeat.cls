/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 24/10/2017 - PG    - Created Class. 
 22/11/2017 - PG 	- Added "constructor" for single as well.

**/ 
public class HotDocs_Answer_Repeat extends HotDocs_Answer implements IHotDocs_Answer
{
	public List<IHotDocs_Answer> value = new List<IHotDocs_Answer>();

	public HotDocs_Answer_Repeat(String inputName, List<IHotDocs_Answer> inputValue)
	{			
		name = inputName; 
		dataType = 'REPEAT';
		value = inputValue; 
	}

	/**
	* Constructor - Single
	**/
	public HotDocs_Answer_Repeat(String inputName, IHotDocs_Answer inputValue)
	{			
		name = inputName; 
		dataType = 'REPEAT';
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