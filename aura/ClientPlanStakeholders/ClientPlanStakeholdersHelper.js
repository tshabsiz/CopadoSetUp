({
	onBeforePrepareStakeholders : function(cmp) {
		
        var helper = this;
        var action = cmp.get("c.getStakeholders");
        var planId = cmp.get("v.planId");
        
        action.setParams({ "planId" : planId });
        action.setCallback(this, function(response) {
            
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var dataJson = response.getReturnValue();
                var data = JSON.parse(dataJson);
                
                if (data.length == 0) {
                    cmp.set("v.showPlaceholder", true);
                } else {
                    helper.processStakeholdersItems(cmp, data);
                }
            } else  {
                console.log(response);
                alert('An error occured during communication with server.');
            }
        });
        $A.enqueueAction(action);
	},
    processStakeholdersItems : function(cmp, data) {
        data = this.addPlusesToElements(data);
        var uniqueClass = new Date().getTime();
        
        var items = [];
        for (var i = 0; i < data.length; i++) {
            var el = data[i];
            
            items.push(new primitives.orgdiagram.ItemConfig({
                id: el.id,
                aprId: el.aprId,
                parent: el.parent,
                title: el.title,
                jobRole: el.jobRole,
                jobTitle: el.jobTitle,
                clientStrength: el.clientStrength,
                templateName: el.templateName,
                clientStrength: el.clientStrength,
                comment: el.comment,
                barclaysContacts: el.barclaysContacts,
                uniqueClass: uniqueClass
            }));
        }
        
        this.prepareOrganogram(items, cmp, uniqueClass);
    },
    prepareOrganogram : function(items, cmp, uniqueClass) {
        
        var html = '<div id="stakeholders" class="stakeholders" style="width: 100%; height: 400px;"/>';
        //$('#stakeholdersWrapper').html(html);
        
        var options = new primitives.orgdiagram.Config();
        options.buttons = [];
        options.templates = [this.getPlusTemplate(), this.getContactTemplate()];
        options.onItemRender = this.onTemplateRender;
        //options.onCursorRender = onCursorRender;
        //options.onMouseClick = onMouseClick;
        options.hasButtons = primitives.common.Enabled.False;
        options.hasSelectorCheckbox = primitives.common.Enabled.False;
        options.leavesPlacementType = primitives.orgdiagram.ChildrenPlacementType.Matrix;
        options.pageFitMode = primitives.common.PageFitMode.None;
        options.orientationType = primitives.common.OrientationType.Top;
        options.horizontalAlignment = primitives.common.HorizontalAlignmentType.Center;
        options.items = items;
        
        console.log('stakeholders rendering finished');
        $('#stakeholdersWrapper div').orgDiagram(options);
        
    },
    addPlusesToElements : function(elems) {
        var pluses = new Array();
        var elem;
        
        for (var i = 0; i < elems.length; i++) {
            elem = elems[i];
            elem.templateName = 'contactTemplate';
            
            //plus above root element
            if (elem.parent == null) {
                var plusAbove = {};
                plusAbove.id = 'above-' + elem.id;
                plusAbove.aprId = elem.aprId;
                plusAbove.parent = null;
                plusAbove.title = elem.title;
                plusAbove.jobRole = '';
                plusAbove.jobTitle = '';
                plusAbove.clientStrength = '';
                plusAbove.templateName = 'plusTemplate';
                plusAbove.comment = '';
                plusAbove.barclaysContacts = [];
                pluses.push(plusAbove);
                
                elem.parent = plusAbove.id;
            }
            
            pluses.push(elem);
            
            var plus = {};
            plus.id = 'sub-'+elem.id;
            plus.aprId = elem.aprId;
            plus.parent = elem.id;
            plus.title = elem.title;
            plus.jobRole = '';
            plus.jobTitle = '';
            plus.templateName = 'plusTemplate';
            plus.clientStrength = '';
            plus.comment = elem.comment;
            plus.barclaysContacts = [];
            pluses.push(plus);
        }
        return pluses;
    },
    onTemplateRender : function(event, data) {
        
        var itemConfig = data.context;
        if (data.templateName == 'contactTemplate') {
            data.element.find('.mapSlider').attr({"data-slider-value": itemConfig.clientStrength});
            data.element.find('.mapSlider').attr({"aprid": itemConfig.aprId});
            
            var editButton = data.element.find('#menu-27-0');
            editButton.attr('onclick', 'showEditContactModal(\'' + itemConfig.aprId +'\', \'' 
                            + itemConfig.title + '\', \'' 
                            + itemConfig.clientStrength + '\');return false;');
            var removeButton = data.element.find('#menu-27-1');
            removeButton.attr('onclick', 'removeContact(\'' + itemConfig.id +'\');return false;');
            var goToContactButton = data.element.find('#menu-27-2');
            goToContactButton.attr('onclick', 'openContact(\'' + itemConfig.id +'\');return false;');
            
            var progressBar = data.element.find('#influence');
            progressBar.val(itemConfig.clientStrength*20);
            
            var fields = ["title", "jobRole", "jobTitle", "clientStrength"];
            for (var index = 0; index < fields.length; index++) {
                var field = fields[index];
                
                var element = data.element.find("[name=" + field + "]");
                if (element.text() != itemConfig[field]) {
                    element.text(itemConfig[field]);
                    element.attr("title", itemConfig[field]);
                }
            }
            
            data.element.find('.barclays-contacts').empty();
            var barclaysContacts = itemConfig.barclaysContacts;
            if(barclaysContacts != null && barclaysContacts.length > 0){
                data.element.find('.barclays-contacts').append(
                    '<div class="slds-grid slds-grid--align-spread slds-has-flexi-truncate">'
                    +  '<span class="slds-tile__title slds-truncate">Barclays contacts ('+barclaysContacts.length+')</span>'
                    +'</div>'
                );
            } else{
                data.element.find('.barclays-contacts').append(
                    '<div>'
                    +  '<button class="slds-button slds-button--neutral slds-button--small" onclick="showAddBarclaysContactModal(\''+itemConfig.aprId+'\');return false;">Add Barclays contact</button>'
                    +'</div>'
                );
            }
        }
        
        if(data.templateName == 'plusTemplate'){
            var button = data.element.find('button');
            button.attr('onclick', 'addRelatedContact(\'' + itemConfig.parent + '\', \'' + itemConfig.aprId + '\');return false;');
        }
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
    getContactTemplate : function() {
        
        var result = new primitives.orgdiagram.TemplateConfig();
        result.name = 'contactTemplate';
        
        var buttons = [];
        buttons.push(new primitives.orgdiagram.ButtonConfig("comment", "ui-icon-comment", "Comment"));
        
        result.buttons = buttons;
        
        result.itemSize = new primitives.common.Size(220, 200);
        result.minimizedItemSize = new primitives.common.Size(3, 3);
        console.log(jQuery);
        var itemTemplate = jQuery(
            '<div class="bp-item bp-corner-all bt-item-frame">'
            +  '<div name="id" class="slds-grid slds-wrap" style="height: ' + result.itemSize.height + 'px; padding: 6px;">'
            +    '<div class="slds-col slds-size--1-of-1 slds-align-top">'
            +      '<div class="slds-grid slds-grid--align-spread slds-has-flexi-truncate">'
            +        '<div class="slds-media slds-tile slds-hint-parent">'
            +          '<div class="slds-media__figure">'
            +            '<span class="slds-avatar slds-avatar--circle slds-avatar--small">'
            +              '<img src="/resource/SLDS/assets/images/avatar2.jpg" alt="" />'
            +            '</span>'
            +          '</div>'
            +          '<div class="slds-media__body">'
            +            '<p name="title" class="slds-tile__title slds-text-body--regular"></p>'
            +            '<div class="slds-tile__detail slds-text-body--small">'
            +              '<p name="jobTitle" class="slds-tile__detail slds-text-body--small"></p>'
            +            '</div>'
            +          '</div>'
            +        '</div>'
            +        '<div class="slds-dropdown-trigger">'
            +          '<button class="slds-button slds-button--icon-border-filled slds-button--icon-small" onclick="return false;">'
            +            '<svg aria-hidden="true" class="slds-button__icon">'
            +              '<use xlink:href="/resource/SLDS/assets/icons/utility-sprite/svg/symbols.svg#settings"></use>'
            +            '</svg>'
            +          '</button>'
            +          '<div class="slds-dropdown slds-dropdown--right slds-nubbin--top-right slds-dropdown--menu">'
            +            '<ul class="slds-dropdown__list" role="menu">'
            +              '<li id="menu-27-0" href="#" class="slds-dropdown__item">'
            +                '<a class="slds-truncate" role="menuitem">Edit</a>'
            +              '</li>'
            +              '<li id="menu-27-1" href="#" class="slds-dropdown__item">'
            +                '<a class="slds-truncate" role="menuitem">Remove</a>'
            +              '</li>'
            +              '<li id="menu-27-2" href="#" class="slds-dropdown__item">'
            +                '<a class="slds-truncate" role="menuitem">Go to contact</a>'
            +              '</li>'
            +            '</ul>'
            +          '</div>'          
            +        '</div>'
            +      '</div>'
            +    '</div>'
            +    '<div class="slds-col slds-size--1-of-1 slds-align-middle">'
            +      '<dl class="dl--horizontal slds-text-body--small">'
            +        '<dt class="slds-dl--horizontal__label">'
            +          '<p class="slds-truncate">Influence</p>'
            +        '</dt>'
            +        '<dd class="slds-dl--horizontal__detail slds-tile__meta">'
            +           '<progress id="influence" value="80" max="100"></progress>'
            +        '</dd>'
            +      '</dl>'
            +      '<dl class="dl--horizontal slds-text-body--small">'
            +        '<dt class="slds-dl--horizontal__label">'
            +          '<p class="slds-truncate">Job role</p>'
            +        '</dt>'
            +        '<dd class="slds-dl--horizontal__detail slds-tile__meta">'
            +          '<div name="jobRole"></div>'
            +        '</dd>'
            +      '</dl>'
            +    '</div>'
            +    '<div class="slds-col slds-size--1-of-1 slds-align-bottom">'
            +      '<div class="barclays-contacts">'
            +      '</div>'
            +    '</div>'
            +  '</div>'
            + '</div>'
        ).addClass("bp-item bp-corner-all bt-item-frame");
        
        result.itemTemplate = itemTemplate.wrap('<div>').parent().html();
        
        result.cursorPadding = new primitives.common.Thickness(2, 2, 2, result.itemSize.height);
        var cursorTemplate = jQuery('<div class="barclays-contacts-panel"><div class="barclays-contacts-list slds-scrollable--y"></div></div>');
        
        result.cursorTemplate = cursorTemplate.wrap('<div>').parent().html();
        
        return result;
    }
})