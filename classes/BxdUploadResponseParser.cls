public class BxdUploadResponseParser {
    public List<Files> files;
    
	public class Files {
		public String id;
		public String name;
		public String url;
		public String parent;
	}
	
	public static BxdUploadResponseParser parse(String json) {
		return (BxdUploadResponseParser) System.JSON.deserialize(json, BxdUploadResponseParser.class);
	}
}