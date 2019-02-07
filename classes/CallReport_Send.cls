public with sharing class CallReport_Send {
    //Getters & Setters
    public Boolean  emailResult { get; set; }
    public String   returnURL   { get; set; }

    public String   toAddresses { get; set; }
    public String   ccAddresses { get; set; }

    //Helper vars for User Selection
    public List<String>     selectedUserIds { get; set; }
    public List<String>     removedUserIds { get; set; }
    public String           whereClause { get; set; }
    private Map<Id, String> availableUsersMap;
    private Map<Id, String> selectedUsersMap;

    //The CallReport this is on
    public Call_Report__c   callReport { get; set; }

    //Config
    private static String templateDeveloperName = 'Call_Report_VF';
    private static Set<String> whitelistedEmailDomains = new Set<String> {
        'absa.co.za',
        'barclaycapital.com',
        'barcap.com',
        'barclays.com',
        'barclayscorp.com',
        'atfs.co.za',
        'absacapital.com',
        'nbctz.com',
        'salesforce.com'
    };

    public CallReport_Send(ApexPages.StandardController stdController) {
        if(!test.isRunningTest()) {
            stdController.addFields(new List<String>{
                'Id',
                'Name'
            });
        }

        this.callReport = (Call_Report__c) stdController.getRecord();
        this.returnURL = Apexpages.currentPage().getParameters().get('returnURL');
        
        //check return url for Console or regular
        if(this.returnURL.contains('isdtp')) {
            this.returnURL = '/ui/support/servicedesk/ServiceDeskPage#/' + this.callReport.Id;
        } else {
            this.returnURL = '/' + this.callReport.Id;
        }

        //Init
        initializeCollections();
        getUsers();
    }

    public void sendTemplatedEmail() {
        try {
            //Build the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

            //Retrieve templateId
            Id templateId = null;
            List<EmailTemplate> emailTemplates = [
                SELECT  Id
                FROM    EmailTemplate 
                WHERE   DeveloperName = :templateDeveloperName
            ];
            if(! emailTemplates.isEmpty()) {
                templateId = emailTemplates.get(0).Id;
            } else {
                throw new CallReport_Send_Exception('Cannot locate Email template ["' + templateDeveloperName + '"]');
            }
            email.setTemplateid(templateId);

            //Recipients - build the list of TO and CC addresses
            List<String> allTo = new List<String>();
            List<String> allCc = new List<String>();

            //First Process the TO - Selected Users
            Set<Id> toUserIds = selectedUsersMap.keySet();              
            for(Id userId : toUserIds) {
                allTo.add((String) userId);
            }

            //Now Process the TO - Manually Entered Addresses
            if(!String.isEmpty(toAddresses)) {
                List<String> toMannualyEnteredAddresses = parseEmailAddresses(toAddresses);
                allTo.addAll(toMannualyEnteredAddresses);
            }

            //Check we have at least 1 To addressee
            if(allTo.size() == 0) {
                throw new CallReport_Send_Exception('Specify at least 1 User or 1 manually entered To address with a valid Barclays/ABSA e-mail domain');
            }

            //Recipients - the CC
            if(!String.isEmpty(ccAddresses)) {
                List<String> ccMannualyEnteredAddresses = parseEmailAddresses(ccAddresses);
                allCc.addAll(ccMannualyEnteredAddresses);
            }

            //To use a standard Email Template - with Merge - the email needs to be associated with a Contact
            //- If we have selected 'users' take one of them and create a dummy Contact with that info
            //- If we have no selected users, but only manually entered To values, create a dummy Contact with that info
            Contact tempContact = null;
            if(toUserIds.size() > 0) {
                Id randomUserId = (new List<Id>(toUserIds)).get(0);
                User user = [SELECT email, firstName, lastName FROM User WHERE id = :randomUserId];
                tempContact = new Contact(email = user.email, firstName = '|' + user.firstName + '|', lastName = '|' + user.lastName + '|');
            } else {
                String firstToAddress = allTo.get(0);
                tempContact = new Contact(email = firstToAddress, firstName = '|' + firstToAddress + '|', lastName = '|' + firstToAddress + '|');
            }
            // if a tempcontact with that email address already exists use that one, if not create it
            List<Contact> tempContacts = [SELECT email from CONTACT WHERE email =:tempContact.email LIMIT 1];
            if (tempContacts.size() == 0) {
                System.debug(LoggingLevel.DEBUG, '### tempContact about to be created ["' + tempContact + '"]');
                INSERT tempContact;
                email.setTargetObjectId(tempContact.Id);
            } else
                email.setTargetObjectId(tempContacts[0].Id);

            //Set To and CC on the email record
            System.debug(LoggingLevel.DEBUG, '### Recipients [allTo: "' + allTo + '", allCc: "' + allCc + '"]');
            email.setToAddresses(allTo);
            email.setCcAddresses(allCc);

            //Set Reference to the Call Report
            email.setWhatId(this.callReport.Id);

            //Save this as an Activity
            email.setSaveAsActivity(true);  

            //Override the from with an OrgWide default address
            //email.setorgWideEmailAddressId(orgWideEmailId);

            //Send
            System.debug(LoggingLevel.DEBUG,'### Email to be send out: ' + email);

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

            // delete contact if it was created
            if(tempContact != null && tempContacts.size() == 0) {
                DELETE tempContact;
            }

            emailResult = true;
            return;
        } catch(Exception e) {
            System.debug(LoggingLevel.DEBUG, '### Exception: ' + e);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, 'Error: ' + e.getMessage()));
        }

        emailResult = false;
    }

    //1. Parse individual e-mail addresses from a ,-seperated list
    //2. Check if they have a valid email syntax
    //3. Whitelist against Barclays/Absa Domains
    private List<String> parseEmailAddresses(String input) {
        List<String> returnList = new List<String>();

        if(! String.isEmpty(input)) {
            String[] elements = input.split(',');
            for(String element : elements) {
                String trimmedElement = element.trim();

                //Check if it's a valid e-mail syntax
                if(validateEmail(trimmedElement)) {
                    //Check if it's not in the Barclays specific whitelist
                    if(isValidBarclaysDomain(trimmedElement)) {
                        //If so add to the list
                        returnList.add(trimmedElement);
                    }
                }
            }
        }

        return returnList;
    }

    private static Boolean validateEmail(String email) {
        Boolean isValidPattern = true;
        
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$'; // source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);

        if(!MyMatcher.matches()) {
            isValidPattern = false;
        }

        System.debug(LoggingLevel.DEBUG, '### Email address validation ["' + email + '", "' + isValidPattern + '"]');
        return isValidPattern;  
    }

    private static Boolean isValidBarclaysDomain(String email) {
        Boolean isValidDomain = false;

        String lowerCaseDomain = email.substringAfter('@').toLowerCase();
        if(! String.isEmpty(lowerCaseDomain)) {
            if(whitelistedEmailDomains.contains(lowerCaseDomain)) {
                isValidDomain = true;
            }
        }
        
        System.debug(LoggingLevel.DEBUG, '### Email address Domain whitelisting ["' + email + '", "' + lowerCaseDomain + '", "' + isValidDomain + '"]');
        return isValidDomain;
    }

    //Helper methods to select Users
    private void initializeCollections() {
        selectedUserIds = new List<String>();
        removedUserIds = new List<String>();
        availableUsersMap = new Map<Id, String>();
        selectedUsersMap = new Map<Id, String>();
    }

    private void getUsers() {
        for(User u : [SELECT id, name FROM user WHERE IsActive = true ORDER BY Name LIMIT 25]) {
            availableUsersMap.put(u.Id, u.Name);
        }
    }

    public void addUser() {
        System.debug(LoggingLevel.DEBUG, '### addUser called - selectedUserIds: ' + selectedUserIds);

        if(!selectedUserIds.isEmpty()) {
            for(String userId : selectedUserIds) {
                selectedUsersMap.put(userId, availableUsersMap.get(userId));
                availableUsersMap.remove(userId);
            }
        }
    }

    public void removeUser() {
        System.debug(LoggingLevel.DEBUG, '### removeUser called - removedUserIds: ' + removedUserIds);

        if(!removedUserIds.isEmpty()) {
            for(String userId : removedUserIds) {
                availableUsersMap.put(userId, selectedUsersMap.get(userId));
                selectedUsersMap.remove(userId);
            }
        }
    }

    public List<SelectOption> getAvailableUsers() {
        List<SelectOption> availableUsers = new List<SelectOption>();
        for(Id userId : availableUsersMap.keySet()) {
            availableUsers.add(new SelectOption(userId, availableUsersMap.get(userId)));
        }
        return availableUsers;
    }

    public List<SelectOption> getSelectedUsers() {
        List<SelectOption> selectedUsers = new List<SelectOption>();
        for(String userId : selectedUsersMap.keySet()) {
            selectedUsers.add(new SelectOption(userId, selectedUsersMap.get(userId)));
        }
        return selectedUsers;
    }

    public void filterAvailableOptions() {
        System.debug(LoggingLevel.DEBUG, '### filterAvailableOptions called - whereClause: ' + whereClause);

        if(! String.isEmpty(whereClause)) {
            availableUsersMap = new Map<Id, String>();
            selectedUserIds = new List<String>();
            String likeClause = '%' + whereClause + '%';
            for(User u : [SELECT id, name FROM User WHERE name LIKE :likeClause ORDER BY Name LIMIT 25]) {
                if(!selectedUsersMap.containsKey(u.Id)) {
                    availableUsersMap.put(u.Id, u.Name);
                }
            }
        } else {
            //Reload full list
            availableUsersMap = new Map<Id, String>();
            getUsers();
        }
    }

    //Custom Exception type
    public class CallReport_Send_Exception extends Exception {}
}