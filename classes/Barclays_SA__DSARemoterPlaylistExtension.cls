/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class DSARemoterPlaylistExtension {
    global DSARemoterPlaylistExtension(Barclays_SA.DSARemoter controller) {

    }
    @RemoteAction
    global static void addLike(Id feedItemId) {

    }
    @RemoteAction
    global static void addToPlaylist(Id playListId, Id contentDocumentId) {

    }
    @RemoteAction
    global static void commentOnPost(Id feedItemId, String text) {

    }
    @RemoteAction
    global static Barclays_SA.DSAPlaylist createPlaylist(String title, String description, Boolean isFeatured) {
        return null;
    }
    @RemoteAction
    global static void deletePlaylist(Id playlistId) {

    }
    @RemoteAction
    global static void followPlaylist(Id playlistId) {

    }
    @RemoteAction
    global static List<Barclays_SA.DSAPlaylist> getFeaturedPlaylistsForPrefix(String prefix) {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA.DSAPlaylist> getFeaturedPlaylists() {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA.DSAPlaylist> getFollowedPlaylists() {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA.DSAPlaylist> getFollowingPlaylistsForPrefix(String prefix) {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA.DSAPlaylist> getMyPlaylistsForPrefix(String prefix) {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA.DSAPlaylist> getMyPlaylists() {
        return null;
    }
    @RemoteAction
    global static Barclays_SA.DSAPlaylist getPlaylist(Id recordId) {
        return null;
    }
    @RemoteAction
    global static Barclays_SA.DSAPlaylistDetail getPlaylistDetail(Id recordId) {
        return null;
    }
    global static Map<String,Barclays_SA.DSAPlaylistDetail> getPlaylistDetails(List<Id> recordIds) {
        return null;
    }
    @RemoteAction
    global static Barclays_SA.DSAPaginatedList getPlaylists(Integer pageNumber) {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA.DSAPlaylist> getPlaylistsForPrefix(String prefix) {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA.DSAPlaylist> getTrendingPlaylistByViews() {
        return null;
    }
    @RemoteAction
    global static void logPlaylistReview(Id playlistId, String device, String orientation) {

    }
    @RemoteAction
    global static void orderPlaylist(Id playlistId, Map<Id,Integer> orderedContentMap) {

    }
    @RemoteAction
    global static void postOnPlaylist(Id playlistId, String text) {

    }
    @RemoteAction
    global static void removeFromPlaylist(Id playListId, Id contentDocumentId) {

    }
    @RemoteAction
    global static void removeLike(Id commentId) {

    }
    @RemoteAction
    global static void unFollowPlaylist(Id playlistId) {

    }
    @RemoteAction
    global static void updatePlaylist(Id playlistId, String title, String description, Boolean isFeatured) {

    }
}
