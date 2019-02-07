({
    component: null
    ,newsletterDetails: null
    ,recordId: null
    ,afterSaveCallback: function(response) {
        this.navigateToObjectHome();
    }
    ,afterSendCallback: function(response) {
        if( "SUCCESS" === response.getState() ) { 
            this.navigateToObjectHome();
        } else this.displayError(response);
    }
    ,displayError: function(response) {
	    var error = response.getError();
    	alert(error["0"].message);
	}
    ,getNewsletterDetailsCallback: function(response) { 
        if( "SUCCESS" === response.getState() ) { 
            this.newsletterDetails = response.getReturnValue();
            //console.log(this.newsletterDetails);
            this.component.set("v.newsletterDetails", this.newsletterDetails);
        } else this.displayError(response);
    }
    ,navigateToObjectHome: function() {
/*
         var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url": "/newsletters-list" });
        urlEvent.fire();		
/**/
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Newsletter__c"
        });
        homeEvent.fire();
/*
        var navEvent = $A.get("e.force:navigateToList");
        navEvent.setParams({
            "listViewId": "00B5E0000019Qob",
            "listViewName": null,
            "scope": "Newsletter__c"
        });
        navEvent.fire();
/**/
    }
    ,onInit: function(component, event) {
        this.component = component;
        this.recordId = component.get("v.recordId");
        // retrieve the NL details and selected posts no matter what. If creation, null is returned, of course
        var action = component.get("c.getNewsletterDetailsAndPostsUsed");
        action.setParams({
            "newsletterId": this.recordId,
            "preparingNewsletter": true
                         });
        action.setCallback(this, this.getNewsletterDetailsCallback); 
        $A.enqueueAction(action);
    }
    ,onQuestionSelectionChange: function(component, event) {
//		console.log(event.getSource().get("v.value") + " / " + event.getSource().get("v.name") + " checked= " + event.getSource().get("v.checked"));
//        console.log(this.newsletterDetails.groupsDetailsAndQuestions[0].questions[0].isSelected);
    }
    ,onSuccess: function(component, event) {
        let response = event.getParam('response');
        var action = component.get("c.saveSelectedQuestionsIds");
        var questionsIds = new Array();
        // since Salesforce crashes on sending a structure, obviously failing at serializing/deserializing, doint my own thing
        for(var i = 0; i < this.newsletterDetails.groupsDetailsAndQuestions.length; i++) {
            var groupDetailsAndQuestions = this.newsletterDetails.groupsDetailsAndQuestions[i];
	        for(var q = 0; q < groupDetailsAndQuestions.questions.length; q++) {
                var question = groupDetailsAndQuestions.questions[q];
                // groupId|post id
                if( question.isSelected ) questionsIds.push(question.id);
            }
        }
        //console.log("saving questionsIds: " + questionsIds);
        action.setParams({ "newsletterId": response.id
                          ,"questionsIds": questionsIds });
        action.setCallback(this, this.afterSaveCallback); 
        $A.enqueueAction(action);
    }
    ,sendNewsletter: function(component, event, helper) {
        try {
            var action = component.get("c.sendNewsletterServer");
            action.setParams({ "newsletterId": this.recordId,
                              "networkUrl": document.location.hostname + $A.get("$SfdcSite.pathPrefix")
                             });
            action.setCallback(this, this.afterSendCallback); 
            $A.enqueueAction(action);
            //console.log("send news letter action enqueued");
        } catch(e) {
            console.log("Error retrieveing the newsletter details: " + e);
        }
    }
})