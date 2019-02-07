/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class CardWallController {
    @RemoteAction
    global static Task addTask(String Title, String currentMatter) {
        return null;
    }
    @RemoteAction
    global static void changeTaskOwner(Id taskId, String ownerId) {

    }
    @RemoteAction
    global static void deleteTask(Id taskId) {

    }
    @RemoteAction
    global static List<Map<String,String>> getMatter(String recId) {
        return null;
    }
    @RemoteAction
    global static List<Map<String,String>> getMatters(String searchText) {
        return null;
    }
    @RemoteAction
    global static List<Task> matterFilterList(Id matterId, String currentBoardId, Id selectedGroupId) {
        return null;
    }
    @RemoteAction
    global static void toggleFollowTask(String taskId) {

    }
    @RemoteAction
    global static void updateTaskStatus(Id taskId, String currentStatus) {

    }
}
