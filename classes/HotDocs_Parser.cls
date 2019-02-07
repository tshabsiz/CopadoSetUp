/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 24/10/2017 - PG    - Created Class. 
 01/02/2018 - PG 	- Added "NONE" or "" handling in walkAnswerNode. Sets value to null now.

**/ 
public class HotDocs_Parser
{
	public Dom.Document xmlDocument = new Dom.Document();
	public Map<String, String> inverseNodeNaming = new Map<String, String>();
	public HotDocs_AnswerSet answerSet = new HotDocs_AnswerSet();

	public HotDocs_Parser(String inputXmlString)
	{
		xmlDocument.load(inputXmlString);
		inverseNodeNaming = getInverseNamingMap();
	}

	/**
	* getAnswer 
	**/
	public List<IHotDocs_Answer> getAnswer(String inputAnswerName) 
	{
		//Get root element of document.
		Dom.XmlNode rootNode = xmlDocument.getRootElement(); 

		//Holds the human answers.
		List<IHotDocs_Answer> answerData = new List<IHotDocs_Answer>();

		//Loop over answers.
		for(Dom.XmlNode answerNode : rootNode.getChildElements())
		{
			if(answerNode.getNodeType() == DOM.XMLNodeType.ELEMENT && answerNode.getName() == 'Answer')
			{
				//Has attributes.
				if(answerNode.getAttributeCount() > 0) 
				{
					for(Integer i = 0; i < answerNode.getAttributeCount(); i++)
					{
						//name attribute matches input string.
						if(answerNode.getAttributeValue(answerNode.getAttributeKeyAt(i), answerNode.getAttributeKeyNsAt(i)) == inputAnswerName)
						{
							//Pass over to recursive method.
							walkAnswerNode(inputAnswerName, answerNode, answerData); 
						}
					}
				}
			}
		}		

		//Default return.
		return answerData;
	}

	/**
	* walkAnswerNode 
	**/
	public void walkAnswerNode(String inputName, Dom.XmlNode inputNode, List<IHotDocs_Answer> inputData) 
	{
		//Loop over answer child nodes.
		for(Dom.XmlNode currentNode : inputNode.getChildren())
		{
			if(currentNode.getName() == answerSet.xmlNodeNaming.get('REPEAT') || currentNode.getName() == answerSet.xmlNodeNaming.get('MULTI'))
			{ 
				//Pass it back in.
				walkAnswerNode(inputName, currentNode, inputData);
			}

			if(currentNode.getName() == answerSet.xmlNodeNaming.get('TEXT') || currentNode.getName() == answerSet.xmlNodeNaming.get('BOOL') || currentNode.getName() == answerSet.xmlNodeNaming.get('SELECT'))
			{
				inputData.add(new HotDocs_Answer_Generic(inverseNodeNaming.get(currentNode.getName()), inputName, (currentNode.getText() == 'NONE' || currentNode.getText() == '') ? null : currentNode.getText()) );
			}
		}
	}

	/**
	* getInverseNamingMap 
	**/
	public Map<String, String> getInverseNamingMap()
	{
		Map<String, String> reverseMap = new Map<String, String>();

		for(String key : answerSet.xmlNodeNaming.keySet() )
		{
			reverseMap.put(answerSet.xmlNodeNaming.get(key), key);
		}

		//Default return.
		return reverseMap;
	}
}