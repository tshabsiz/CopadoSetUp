@IsTest
public class BxdFileConflict_test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'	\"conflicts\": {'+
		'		\"type\": \"file\",'+
		'		\"id\": \"251484314137\",'+
		'		\"name\": \"Dealing File NEW1.pdf\"'+
		'	}'+
		'}';
		BxdFileConflict r = BxdFileConflict.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BxdFileConflict objBxdFileConflict = new BxdFileConflict(System.JSON.createParser(json));
		System.assert(objBxdFileConflict != null);
		System.assert(objBxdFileConflict.conflicts == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		BxdFileConflict.Conflicts objConflicts = new BxdFileConflict.Conflicts(System.JSON.createParser(json));
		System.assert(objConflicts != null);
		System.assert(objConflicts.type_Z == null);
		System.assert(objConflicts.id == null);
		System.assert(objConflicts.name == null);
	}
}