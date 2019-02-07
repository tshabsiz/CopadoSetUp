public class BxdFileVersionUpload {
    public String name;	
	public static BxdFileVersionUpload parse(String json) {
		return (BxdFileVersionUpload) System.JSON.deserialize(json, BxdFileVersionUpload.class);
	}
    
    public static String getJsonString(BxdFileVersionUpload fileVersionUpload) {
        String fileUploadString = JSON.serialize(fileVersionUpload, true);
        return fileUploadString;
    }
}