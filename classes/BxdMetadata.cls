public class BxdMetadata {

    /**
     * Specifies the name of the default 'properties' metadata template.
     */
    public static final String DEFAULT_METADATA_TYPE = 'properties';

    /**
     * Specifies the 'global' metadata scope.
     */
    public static final String GLOBAL_METADATA_SCOPE = 'global';

    /**
     * Specifies the 'enterprise' metadata scope.
     */
    public static final String ENTERPRISE_METADATA_SCOPE = 'enterprise';

    /**
     * The default limit of entries per response.
     */
    public static final Integer DEFAULT_LIMIT = 100;

    /**
     * Values contained by the metadata object.
     */
    private final BoxGenericJsonObject values;

    /**
     * Creates an empty metadata.
     */
    public BxdMetadata() {
        this.values = new BoxGenericJsonObject();
    }

    /**
     * Creates a new metadata.
     * @param values the initial metadata values.
     */
    public BxdMetadata(BoxGenericJsonObject values) {
        this.values = values;
    }

    /**
     * Creates a copy of another metadata.
     * @param other the other metadata object to copy.
     */
    public BxdMetadata(BxdMetadata other) {
        this.values = new BoxGenericJsonObject(other.values);
    }

    /**
     * Returns the 36 character UUID to identify the metadata object.
     * @return the metadata ID.
     */
    public String getID() {
        return this.get('/$id');
    }

    /**
     * Returns the metadata type.
     * @return the metadata type.
     */
    public String getTypeName() {
        return this.get('/$type');
    }

    /**
     * Returns the parent object ID (typically the file ID).
     * @return the parent object ID.
     */
    public String getParentID() {
        return this.get('/$parent');
    }

    /**
     * Returns the scope.
     * @return the scope.
     */
    public String getScope() {
        return this.get('/$scope');
    }

    /**
     * Returns the template name.
     * @return the template name.
     */
    public String getTemplateName() {
        return this.get('/$template');
    }
    
    /**
     * Adds a new metadata value.
     * @param path the path that designates the key. Must be prefixed with a "/".
     * @param value the value.
     * @return this metadata object.
     */
    public BxdMetadata add(String path, String value) {
        this.values.addValue(this.pathToProperty(path), value);
        return this;
    }

    /**
     * Returns a value.
     * @param path the path that designates the key. Must be prefixed with a '/'.
     * @return the metadata property value.
     */
    public String get(String path) {
        return this.values.getValue(this.pathToProperty(path));
    }
    
    /**
     * Returns a list of metadata property paths.
     * @return the list of metdata property paths.
     */
    public List<String> getPropertyPaths() {
        List<String> result = new List<String>();

        for (String property : this.values.children.keySet()) {
            if (!property.startsWith('$')) {
                result.add(this.propertyToPath(property));
            }
        }

        return result;
    }

    /**
     * Returns the JSON representation of this metadata.
     * @return the JSON representation of this metadata.
     */
    public override String toString() {
        return this.values.getJsonString();
    }

    /**
     * Converts a JSON patch path to a JSON property name.
     * Currently the metadata API only supports flat maps.
     * @param path the path that designates the key.  Must be prefixed with a '/'.
     * @return the JSON property name.
     */
    private String pathToProperty(String path) {
        if (path == null || !path.startsWith('/')) {
            return null;
        }
        return path.substring(1);
    }

    /**
     * Converts a JSON property name to a JSON patch path.
     * @param property the JSON property name.
     * @return the path that designates the key.
     */
    private String propertyToPath(String property) {
        if (property == null) {
            return null;
        }
        return '/' + property;
    }

    public static String scopeBasedOnType(String typeName) {
        String scope;
        if (typeName.equals(DEFAULT_METADATA_TYPE)) {
            scope = GLOBAL_METADATA_SCOPE;
        } else {
            scope = ENTERPRISE_METADATA_SCOPE;
        }
        return scope;
    }
}