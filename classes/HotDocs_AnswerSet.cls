/**
 _____ _                 _ _____           _ _   _         
/  __ \ |               | /  ___|         (_) | | |        
| /  \/ | ___  _   _  __| \ `--. _ __ ___  _| |_| |__  ___ 
| |   | |/ _ \| | | |/ _` |`--. \ '_ ` _ \| | __| '_ \/ __|
| \__/\ | (_) | |_| | (_| /\__/ / | | | | | | |_| | | \__ \
 \____/_|\___/ \__,_|\__,_\____/|_| |_| |_|_|\__|_| |_|___/
 
 *** CHANGE LOG ***
 
 24/10/2017 - PG    - Created Class. 
 25/10/2017 - PG 	- Added "add" method to easily add answers.
 30/11/2017 - PG 	- Updated "buildXML" to insert unanswered attribute.
 04/12/2017 - PG 	- Added "NUM" support in XML.
 24/01/2018 - PG 	- Added escapeXML in answerSetXML
 01/02/2018 - PG 	- Moved escape to value / data itself, and not the entire XML string. 

**/ 
public class HotDocs_AnswerSet
{
	public List<IHotDocs_Answer> answers { get; set; }
	public Map<String, String> xmlNodeNaming { get; set; }
	public String answerSetVersion { get; set; }

	/**
	* Constructor
	**/
	public HotDocs_AnswerSet()
	{
		answers = new List<IHotDocs_Answer>();

		xmlNodeNaming = new Map<String, String>{
			'TEXT' => 'TextValue',
			'BOOL' => 'TFValue',
			'NUM' => 'NumValue',
			'MULTI' => 'MCValue',
			'SELECT' => 'SelValue',
			'REPEAT' => 'RptValue',
            'DATE' => 'DateValue'
		};

		answerSetVersion = '1.0';
	}

	/**
	* getXmlDocument -
	**/
	public String getXmlDocument()
	{
		//XML Document.
		Dom.Document xmlDocument = new Dom.Document();

		//Root Element
		Dom.XmlNode answerSetNode = xmlDocument.createRootElement('AnswerSet', null, null);

		answerSetNode.setAttribute('version', answerSetVersion);

		//Loop over each answer.
		for(IHotDocs_Answer answer : answers)
		{
			//Answer Node.
			Dom.XmlNode answerNode = answerSetNode.addChildElement('Answer', null, null);

			answerNode.setAttribute('name', answer.getName());

			//Build Answer XML.
			buildXml(answer, answerNode);
		}

		//Return
		return xmlDocument.toXmlString();
	}

	/**
	* buildXml - 
	**/
	public String buildXml(IHotDocs_Answer inputAnswer, Dom.XmlNode inputParentNode) 
	{	
		if(inputAnswer.getType() == 'TEXT' || inputAnswer.getType() == 'SELECT' || inputAnswer.getType() == 'NUM' || inputAnswer.getType() == 'BOOL' || inputAnswer.getType() == 'DATE')
		{
			Dom.XmlNode contentNode = inputParentNode.addChildElement(xmlNodeNaming.get(inputAnswer.getType()), null, null);

			if(inputAnswer.getData() == '')
			{
				contentNode.setAttribute('unans', 'true');
			}
			else
			{
				//We need to make sure the value / data is XML escaped.
				String rawData = (String)inputAnswer.getData();
				String escapedData = rawData.escapeXml();

				contentNode.addTextNode(escapedData);
			}
		}

		if(inputAnswer.getType() == 'REPEAT' || inputAnswer.getType() == 'MULTI') 
		{
			Dom.XmlNode contentNode = inputParentNode.addChildElement(xmlNodeNaming.get(inputAnswer.getType()), null, null);

			for(IHotDocs_Answer repeatAnswer : (List<IHotDocs_Answer>)inputAnswer.getData())
			{
				//Recursion
				buildXml(repeatAnswer, contentNode); 
			}
		}	
        

		//Default.	
		return null;
	}

	/**
	* add - 
	**/
	public void add(IHotDocs_Answer inputAnswer)
	{
		//Add answer to answer list.
		answers.add(inputAnswer);
	}
}