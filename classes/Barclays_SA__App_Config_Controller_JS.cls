/*
This file is generated and isn't the actual source code for this
managed global class.
This read-only file shows the class's global constructors,
methods, variables, and properties.
To enable code to compile, all methods return null.
*/
global class App_Config_Controller_JS {
    @RemoteAction
    global static Barclays_SA__Category__c addCategory(String categoryName, String parentCategoryId) {
        return null;
    }
    @RemoteAction
    global static Barclays_SA__Category__c addCategory2(Id mobileAppConfigId, String categoryName, String parentCategoryId) {
        return null;
    }
    @RemoteAction
    global static Barclays_SA__CategoryMobileConfig__c addMobileCategoryConfigToMAC(String currentMobileCategoryConfigId, String categoryId) {
        return null;
    }
    @RemoteAction
    global static Barclays_SA__CategoryMobileConfig__c getCategoryConfig(String categoryConfigId) {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA__CategoryMobileConfig__c> getCategoryConfigsWithoutRepair(Id mobileAppConfigId) {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA__CategoryMobileConfig__c> getCategoryConfigs(Id mobileAppConfigId) {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA__CategoryMobileConfig__c> getCategoryConfigurationForMobApp(String mobileAppConfigId, Boolean isDraft) {
        return null;
    }
    @RemoteAction
    global static List<Barclays_SA__Category__c> getSubCategories(String parentCategoryId) {
        return null;
    }
    @RemoteAction
    global static Boolean isAnyCategoryConfigSelected(String mobileAppConfigId) {
        return null;
    }
    @RemoteAction
    global static Integer isOtherActiveAppConfiguration(String currentMobileAppConfigId) {
        return null;
    }
    @RemoteAction
    global static Integer isOtherDefaultCategoryConfiguration(String currentMobileCategoryConfigId, String mobileAppConfigId) {
        return null;
    }
    @RemoteAction
    global static void removeMobileCategoryConfigFromMAC(String categoryMobileConfigId) {

    }
    @RemoteAction
    global static String removeMobileCategoryConfigFromMAC1(String categoryMobileConfigId) {
        return null;
    }
    @RemoteAction
    global static void saveDraggedButton(String categoryMobileConfigId, String landscapeX, String landscapeY, String portraitX, String portraitY) {

    }
    @RemoteAction
    global static void updateCategoryTree(String categoryMobileConfigId) {

    }
}
