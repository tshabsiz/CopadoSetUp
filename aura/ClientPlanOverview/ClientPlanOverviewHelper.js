({
    strength : 'Strength',
    weakness : 'Weakness',
    opportunity : 'Opportunity',
    threat : 'Threat',
    
	getClientPlan : function(cmp, event, helper) {
        
		var action = cmp.get("c.getClientPlan");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                cmp.set("v.clientPlan", data);
				console.log(data);
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    getClientScores : function(cmp, event, helper) {
        
        var action = cmp.get("c.getClientScores");
        var planId = cmp.get("v.planId");
        action.setParams({ "planId" : planId });
		
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                this.classifyClientScores(cmp, data);
				
            } else  {
                console.log(response);
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
    },
    classifyClientScores : function(cmp, scores) {
        var stregths = [];
        var weaknesses = [];
        var opportunities = [];
        var threats = [];
        
        for (var i = 0; i < scores.length; i++) {
            var score = scores[i];
            
            if (score.Score_Type__c == this.strength) {
                stregths.push(score);
            } else if (score.Score_Type__c == this.weakness) {
                weaknesses.push(score);
            } else if (score.Score_Type__c == this.opportunity) {
                opportunities.push(score);
            } else if (score.Score_Type__c == this.threat) {
                threats.push(score);
            }
        }
             
        cmp.set("v.stregths", stregths);
        cmp.set("v.weaknesses", weaknesses);
        cmp.set("v.opportunities", opportunities);
        cmp.set("v.threats", threats);
    },
    fixNewLinesInScores : function() {
        
    	$('.scoreBody').each( function() {
            var content = $(this).html();
            content = content.replace(new RegExp('\n', 'g'), '<br>');
            $(this).html(content);
        });  
	},
    onEditScoreClicked : function(cmp, scoreId, scoreType) {
        var uniqueKey = new Date().getTime();
        
        var score = $('#' + scoreId).closest('.score');
        var name = $(score).find('.slds-tile__title').text();
        var value = $(score).find('.scoreBody').text();
        var planId = cmp.get("v.planId");
        scoreId = scoreId.split('-')[1];
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyClientScore",
            componentAttributes: {
                planId: planId,
                scoreId: scoreId,
                scoreType: scoreType,
                isEdit: true,
                name: name,
                value: value,
                uniqueKey: uniqueKey
            }
        });
        evt.fire();
    },
    onRemoveScoreClicked : function(cmp, scoreId) {
        var proceed = confirm('Item will be deleted. Continue?');
        if (proceed) {
            cmp.set("v.showProgressBar", true);
            scoreId = scoreId.split('-')[1];
            
            var action = cmp.get("c.removeScore");
            action.setParams({ "scoreId" : scoreId });
            action.setCallback(this, function(response) {
                cmp.set("v.showProgressBar", false);
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    var data = response.getReturnValue();
                    if (data) {
                        alert('An error occured during removing item.');
                    } else {
                        $A.get('e.force:refreshView').fire();
                    }
                } else  {
                    console.log(response);
                    alert('An error occured during removing item.');
                }
            });
            $A.enqueueAction(action);
        }
    },
    showEditClientOverviewComponent : function(cmp, isSector) {
        
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyClientOverview",
            componentAttributes: {planId: id, isSector: isSector}
        });
        evt.fire();
    },
    showAddClientScoreComponent : function(cmp, scoreType) {
        
        var uniqueKey = new Date().getTime();
        var id = cmp.get("v.planId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyClientScore",
            componentAttributes: {planId: id, scoreType: scoreType, isEdit: false, uniqueKey: uniqueKey}
        });
        evt.fire();
    },
    onBeforePrepareOrganogram : function(cmp, event, helper) {
        
    	var action = cmp.get("c.getImageId");
        var planId = cmp.get("v.planId");
        
        action.setParams({ "planId" : planId });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data == '') {
                    this.getOrganogramItems(cmp, event, helper);
                } else {
                    cmp.set("v.imageId", data);
                }
            } else  {
                console.log(response);
                alert('An error occured during communication with server.');
            }
        });
        $A.enqueueAction(action);
    },
    getOrganogramItems : function(cmp, event, helper) {
    
    	var action = cmp.get("c.getOrganogramData");
        var planId = cmp.get("v.planId");
        
        action.setParams({ "planId" : planId });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var data = response.getReturnValue();
                if (data.length > 0) {
                	this.processOrganogramItems(data, cmp);
                } else {
                    cmp.set("v.showPlaceholder", true);
                }
            } else {
                alert('An error occured during getting data.');
            }
        });
        $A.enqueueAction(action);
	},
    processOrganogramItems : function(itemsToProcess, cmp) {
        var items = [];
        for (var i = 0; i < itemsToProcess.length; i++) {
            var item = {};
            item.id = itemsToProcess[i].Id;
            item.parent = itemsToProcess[i].Related_To__c;
            item.description = itemsToProcess[i].Description__c;
            items.push(item);
        }
        
        //saving items for recursion during removing an item
        cmp.set("v.itemConfigs", items);
        
    	items = this.addPlusesToItems(items);
        var itemConfigs = [];
        var uniqueClass = new Date().getTime();
        
        for (var i = 0; i < items.length; i++) {
            var el = items[i];
                        
            itemConfigs.push(new primitives.orgdiagram.ItemConfig({
                id: el.id,
                parent: el.parent,
                description: el.description,
                templateName: el.template,
                uniqueClass: uniqueClass
            }));
        }
        
        this.prepareOrganogram(itemConfigs, cmp, uniqueClass);
    },
    prepareOrganogram : function(items, cmp, uniqueClass) {
        
        var html = '<div id="diagram" class="diagram" style="width: 100%; height: 400px;"/>';
        $('#diagramWrapper').html(html);
        
        var options = new primitives.orgdiagram.Config();
        
        options.buttons = [];
        options.templates = [this.getPlusTemplate(),this.getItemTemplate()];
        options.onItemRender = this.onTemplateRender;
        options.hasButtons = primitives.common.Enabled.False;
        options.hasSelectorCheckbox = primitives.common.Enabled.False;
        options.leavesPlacementType = primitives.orgdiagram.ChildrenPlacementType.Matrix;
        options.pageFitMode = primitives.common.PageFitMode.None;
        options.orientationType = primitives.common.OrientationType.Top;
        options.horizontalAlignment = primitives.common.HorizontalAlignmentType.Center;
        options.onButtonClick = function (e, data) {
            switch (data.name) {
                case "delete":
                    break;
                case "add":
                    break;
            }
        };
        
        options.items = items;
        
        console.log('organogram rendering finished');
        $('#diagramWrapper div').orgDiagram(options);
        
        //check if diagram is already rendered to be able to add onclicks
        var check = function(cmp, uniqueClass, helper) {
            var item = $('.' + uniqueClass);
            
            if ($(item).length > 0) {
                console.log('OK');
                
                var layer7 = $(item).closest('.Layer7');
                helper.addOnClicksToItems(cmp, uniqueClass, layer7);
                
            } else {
                console.log('not yet');
                setTimeout(check(cmp, uniqueClass, helper), 1000); 
            }
        }
        check(cmp, uniqueClass, this);
        
    },
    addOnClicksToItems : function(cmp, uniqueClass, layer7) {
        
        var helper = this;
        
        $(layer7).find('.bp-item').each( function() {
            var itemId = $(this).prop('id');
            var planId = cmp.get("v.planId");
            
            //plus item
            if (itemId.startsWith('above-') || itemId.startsWith('sub-')) {
                
                var plusButton = $(this).find('.plusButton');
                
                $(plusButton).click( function() {
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:ClientPlanModifyOrganogramItem",
                        componentAttributes: {planId: planId, relatedTo: itemId, itemId: null, value: ""}
                    });
                    evt.fire();
                });
                
            //regular item  
            } else {
                var editButton = $(this).find('.editOrgItemButton');
                $(editButton).click( function() {
                    
                    var value = $(this).closest('.bp-item').find('.orgItemDescription').text();
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef: "c:ClientPlanModifyOrganogramItem",
                        componentAttributes: {planId: planId, relatedTo: "", itemId: itemId, value: value}
                    });
                    evt.fire();
                });
                
                var removeButton = $(this).find('.removeOrgItemButton');
                $(removeButton).click( function() {
                    
                    var proceed = confirm('Item will be deleted. Continue?');
                    if (proceed) {
                        var items = cmp.get("v.itemConfigs");
                        helper.onBeforeRemoveItem(itemId, items, cmp);
                    }
                });
            }
        });
    },
    getPlusTemplate : function() {
        var result = new primitives.orgdiagram.TemplateConfig();
        result.name = 'plusTemplate';
        result.itemSize = new primitives.common.Size(35, 35);
        result.minimizedItemSize = new primitives.common.Size(0,0,0,0);
        result.highlightPadding = new primitives.common.Thickness(0,0,0,0);
        result.cursorPadding = new primitives.common.Thickness(0,0,0,0);
        
        var itemTemplate = jQuery(
            '<div class="bp-item bp-corner-all bt-item-frame" style="border-radius: 50%;background-color: #F4F6F9;">'
            +    '<button class="slds-button plusButton" style="left: 6px;">'
            +        '<svg aria-hidden="true" class="slds-icon slds-icon--small slds-icon-text-default" style="fill: #0070d2;">'
            +            '<use xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#add"></use>'
            +        '</svg>'
            +    '</button>'
            + '</div>'
        ).css({
            width: result.itemSize.width + "px",
            height: result.itemSize.height + "px"
        }).addClass("bp-item bp-corner-all bt-item-frame");
        
        result.itemTemplate = itemTemplate.wrap('<div>').parent().html();
        
        return result;
    },
    getItemTemplate : function() {
        var result = new primitives.orgdiagram.TemplateConfig();
        result.name = 'itemTemplate';
        result.itemSize = new primitives.common.Size(250, 45);
        result.minimizedItemSize = new primitives.common.Size(0,0,0,0);
        result.highlightPadding = new primitives.common.Thickness(0,0,0,0);
        result.cursorPadding = new primitives.common.Thickness(0,0,0,0);
        
        var template = jQuery(
        '<div class="bp-item bp-corner-all bt-item-frame" style="overflow: visible;background-color: white;">'
        + '<div style="width: 210px;height: 100%;display: inline-block;">'
        +   '<div class="orgItemDescription" style="position: absolute;top: 7px;left: 2px;width: 210px;color: #0070D2;font-size: 90%;"/>'
        + '</div>'
        +  '<div class="slds-dropdown-trigger" style="display: inline-block;vertical-align: top;position: absolute;top: 5px;">'
        +    '<button class="slds-button slds-button--neutral organogramItemButton">'
        +        '<svg aria-hidden="true" class="slds-button__icon">'
        +            '<use xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#settings"></use>'
        +        '</svg>'
        +    '</button>'
        +    '<div class="slds-dropdown slds-dropdown--right slds-dropdown--nubbin-top slds-dropdown--menu">'
        +        '<ul class="slds-dropdown__list" role="menu">'
        +            '<li class="editOrgItemButton slds-dropdown__item" href="#">'
        +                '<a class="slds-truncate" role="menuitem">Edit</a>'
        +            '</li>'
        +            '<li class="removeOrgItemButton slds-dropdown__item" href="#">'
        +                '<a class="slds-truncate" role="menuitem">Remove</a>'
        +            '</li>'
        +        '</ul>'
        +    '</div>'
        + '</div>'
        + '</div>'
        ).css({
            width: result.itemSize.width + "px",
            height: result.itemSize.height + "px"
        }).addClass("bp-item bp-corner-all bt-item-frame");
        
        result.itemTemplate = template.wrap('<div>').parent().html();
        
        return result;
	},
    onTemplateRender : function(event, data) {
        var itemConfig = data.context;
        var id = itemConfig['id'];
        var uniqueClass = itemConfig['uniqueClass'];
        
        data.element.attr('id', id);
        data.element.attr('class', uniqueClass + ' bp-item bp-corner-all bt-item-frame');
        
        if (data.templateName == 'itemTemplate') {
            
            var description = data.element.find('.orgItemDescription');
            description.text(itemConfig['description']);
        }
    },
    addPlusesToItems: function(elems) {
		var pluses = new Array();
        var elem;
        
        for (var i = 0; i < elems.length; i++) {
            elem = elems[i];
            elem.template = 'itemTemplate';
            
            //plus above root element
            if (elem.parent == null) {
                var plusAbove = {};
                plusAbove.parent = null;
                plusAbove.id = 'above-' + elem.id;
                plusAbove.template = 'plusTemplate';
                plusAbove.description = '';
                pluses.push(plusAbove);
                
                elem.parent = plusAbove.id;
            }
            pluses.push(elem);
            
            var plus = {};
            plus.parent = elem.id;
            plus.id = 'sub-' + elem.id;
            plus.template = 'plusTemplate';
            plus.description = '';
            pluses.push(plus);
        }
        return pluses; 
    },
    onBeforeRemoveItem : function(itemId, items, cmp) {
        var itemsToDelete = [itemId];
        
        var getSubordinateItem = function(currentItemId) {
            
            for (var i = 0; i < items.length; i++) {
                if (items[i].parent == currentItemId) {
                    itemsToDelete.push(items[i].id);
                    getSubordinateItem(items[i].id);
                }
            }
        }
        getSubordinateItem(itemId);
        
        this.removeItem(itemsToDelete, cmp);
    },
    removeItem : function(itemIds, cmp) {
        cmp.set("v.showProgressBar", true);
        
        var action = cmp.get("c.removeOrgItem");
        action.setParams({
            "itemIds" : itemIds
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var hasError = response.getReturnValue();
                if (hasError) {
                    alert('An error occured during removing item.');
                } else {
                    $A.get('e.force:refreshView').fire();
                }
            } else {
                console.log(response);
                alert('An error occured during removing item.');
            }
        });
        $A.enqueueAction(action);
    },
    onBeforeDeleteImage : function(imageId, cmp) {
        
        cmp.set("v.showProgressBar", true);
        
        var action = cmp.get("c.deleteImage");
        action.setParams({
            "imageId" : imageId
        });
		
        action.setCallback(this, function(response) {
            cmp.set("v.showProgressBar", false);
            
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
                
            } else {
                console.log(response);
                alert('An error occured during deleting image.');
            }
        });
        $A.enqueueAction(action);
    },
    onBeforeCreateHierarchy : function(planId) {
        
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ClientPlanModifyOrganogramItem",
            componentAttributes: {planId: planId, relatedTo: '', itemId: null, value: ""}
        });
        evt.fire();
    },
    
    MAX_FILE_SIZE: 4500000,
    CHUNK_SIZE: 800000,
    JPEG: 'image/jpeg',
    PNG: 'image/png',
    
    
    onBeforeUploadImage : function(component) {
        var fileInput = component.find("file").getElement();
    	var file = fileInput.files[0];
   
        if (file.size > this.MAX_FILE_SIZE) {
            alert('File size cannot exceed ' + this.MAX_FILE_SIZE + ' bytes.\n' +
    		  'Selected file size: ' + file.size);
    	    return;
        }
        
        if (file.type != this.JPEG && file.type != this.PNG) {
            alert('Only JPEG and PNG files allowed.');
            return;
        }
        
        var fr = new FileReader();
 
        var self = this;
        fr.onload = function() {
            var fileContents = fr.result;
    	    var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
 
            fileContents = fileContents.substring(dataStart);
        
    	    self.upload(component, file, fileContents);
        };
 
        fr.readAsDataURL(file);
    },  
    upload: function(component, file, fileContents) {
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + this.CHUNK_SIZE);
		
        // start with the initial chunk
        this.uploadChunk(component, file, fileContents, fromPos, toPos, false);   
    }, 
    uploadChunk : function(component, file, fileContents, fromPos, toPos, append) {
        component.set("v.showProgressBar", true);
        
        var action = component.get("c.saveImageChunk"); 
        var chunk = fileContents.substring(fromPos, toPos);
        
        action.setParams({
            planId: component.get("v.planId"),
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            append: append
        });
       
        var self = this;
        action.setCallback(this, function(a) {
            
            var hasError = a.getReturnValue();
            if (hasError) {
                component.set("v.showProgressBar", false);
                alert('An error occured during image uploading.');
                
            } else {
                fromPos = toPos;
                toPos = Math.min(fileContents.length, fromPos + self.CHUNK_SIZE);    
                if (fromPos < toPos) {
                    self.uploadChunk(component, file, fileContents, fromPos, toPos, true);  
                } else {
                    component.set("v.showProgressBar", false);
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
            
        $A.run(function() {
            $A.enqueueAction(action); 
        });
    }
})