/*
  ActionPlanCreationScripts
  version 1
  3th May 2010
  Oliver Cortinas
  
  Add <script src="ActionPlanCreationScripts.js"></script> to your HTML
*/
var taskSize = 75;
var maxDays	 = 1000;
var dP;

ActionPlanCreationScripts = {
	checkSkipWeekend : function (){
		if( document.getElementById( "editPage:apForm:editBlock:skipWeekendCheckbox" ).checked == true ){
			document.getElementById( "editPage:apForm:editBlock:skipDayTable" ).style.display = "block";
        }
        else{
			document.getElementById( "editPage:apForm:editBlock:skipDayTable" ).style.display = "none";
        }
    },

	checkDependent : function (dependent){
		var index = ( dependent.split( ":" ) );
		var cycle = false;
		var visitedTasks = new Array();
		// check itself dependency
        if( index[5] == document.getElementById( dependent ).value ){
			alert( AP_ITSELF_TASK_DEPENDENCY );
            document.getElementById( dependent ).value = 'None';
        }
        // check dependency cycles
        else{
        	while( !cycle && document.getElementById( dependent ).value != 'None' ){
				row = ( dependent.split( ":" )[5] );
				if(!visitedTasks[row]){
					visitedTasks[row] = true;
					dependent = 'editPage:apForm:editBlock:taskSection:taskTable:' + document.getElementById( dependent ).value + ':dependent';	
				}
				else{
					cycle = true;
					alert( AP_REMOVE_CYCLIC_DEPENDENCY );
					document.getElementById( dependent ).value = 'None';	
				}
        	}
        } 
    },
	checkDependent_NEW : function (cInd){
        var index = (cInd.split("_"));
        var cycle = false;
		var visitedTasks = new Array();
        if (index[1] == $(cInd).val()){
			alert ( AP_ITSELF_TASK_DEPENDENCY );
            $(cInd).val('None');
        }
        // check dependency cycles
        else{
        	while( !cycle && $(cInd).val() != 'None' ){
				row = ( cInd.split( "_" )[1] );
				if(!visitedTasks[row]){
					visitedTasks[row] = true;
					cInd = '.dependent_'+$(cInd).val();
				}
				else{
					cycle = true;
					alert( AP_REMOVE_CYCLIC_DEPENDENCY );
					$(cInd).val('None');
				}
        	}
        } 
    },
	updateRemindersOption : function (obj){

		if (obj.checked){
			ActionPlanCreationScripts.checkReminder(1);
		}else{
			ActionPlanCreationScripts.checkReminder(0);
		}
		
	},
	checkReminder : function (type){
		var taskSize = 75;
        if( type == "1" ){
			for( i = 0; i < taskSize; i++ ){
				if( document.getElementById( "editPage:apForm:editBlock:taskSection:taskTable:" + i + ":reminderSection:reminder" ) ){
					document.getElementById( "editPage:apForm:editBlock:taskSection:taskTable:" + i + ":reminderSection:reminder" ).checked = 1;
                }
            }
        }
        else{
			for( i = 0; i < taskSize; i++ ){
				if (document.getElementById( "editPage:apForm:editBlock:taskSection:taskTable:" + i + ":reminderSection:reminder" ) ){
					document.getElementById( "editPage:apForm:editBlock:taskSection:taskTable:" + i + ":reminderSection:reminder" ).checked = 0;
                }
            }
        }
        this.checkReminderPicklists();
    },
	updateSendEmail : function (obj){

		if (obj.checked){
			ActionPlanCreationScripts.checkEmail(1);
		}else{
			ActionPlanCreationScripts.checkEmail(0);
		}
		
	},
	checkEmail : function (type){
		var taskSize = 75;
		if( type == "1" ){
			for( i = 0; i < taskSize; i++ ){
				if( document.getElementById( "editPage:apForm:editBlock:taskSection:taskTable:" + i + ":emailSection:email")){
					document.getElementById( "editPage:apForm:editBlock:taskSection:taskTable:" + i + ":emailSection:email").checked = 1;
                }
            }
        }
        else{
			for( i = 0; i < taskSize; i++ ){
				if( document.getElementById( "editPage:apForm:editBlock:taskSection:taskTable:" + i + ":emailSection:email" ) ){
					document.getElementById( "editPage:apForm:editBlock:taskSection:taskTable:" + i + ":emailSection:email" ).checked = 0;
                }
            }
        }
    },
    
    checkDays : function( row ){
    	var rowSplit 	= row.split( ":" );
        var index 		= rowSplit[5];
		var days 		= document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + index + ':daysFromStart' ).value;
    	var myDays 		= ( isNaN(days) || days == '' ) ? 0 : parseInt( days );
    	
    	if(myDays > maxDays){
    		alert(AP_LARGE_DAY_NUMBER);
    		document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + index + ':daysFromStart' ).value = '';
    	}
    },

	showComments : function ( row ){
		for( i = 0; i < taskSize; i++ ){
			if (document.getElementById( "editPage:apForm:editBlock:taskSection:taskTable:" + i + ":commentPanel" ) ){
				document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + i + ':commentPanel' ).style.display = "none";
            }
        }
        var rowSplit = row.split( ":" );
        row = rowSplit[5];      
        document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + row + ':commentPanel' ).style.display = "block";
    },

	hideComments : function ( row ){
		var rowSplit = row.split( ":" );
        newRow = rowSplit[5];
        document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + newRow + ':commentPanel' ).style.display = "none";
        if( document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + newRow + ':Comments' ).value == null || document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + newRow + ':Comments' ).value == "" ){
			document.getElementById( '' + row + ':commentLink' ).innerHTML = "add";
        }   
    },
    
	toggleEventFields : function (actType,row){
 		var rowSplit = row.split(":");
 		row = rowSplit[5];
		if (actType == 'Event')
		{
			document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:'+row+':emailSection').style.display = "none";
			document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:'+row+':priorityPanel').style.display = "none";
			document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:'+row+':startTimePanel').style.display = "block";
			document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:'+row+':durationPanel').style.display = "block";
		}
		else
		{
			document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:'+row+':emailSection').style.display = "block";
			document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:'+row+':priorityPanel').style.display = "block";
			document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:'+row+':startTimePanel').style.display = "none";
			document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:'+row+':durationPanel').style.display = "none";
		}
    },
    
    enableDisableReminderPicklist : function ( row ){
    	var rowSplit = row.split( ":" );
        var newRow = rowSplit[5];
        var reminderCheckbox = document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + newRow + ':reminderSection:reminder' );
        var reminderPicklist = document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + newRow + ':reminderSection:reminderPickList' );
        
        if( reminderCheckbox.checked ){
        	reminderPicklist.disabled = false;
        }
        else{
        	reminderPicklist.disabled = true;
        }
    },
    
    checkReminderPicklists : function (){
    	var row = 0;
    	while( document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + row + ':reminderSection:reminder' ) ){
    		reminderCheckbox = document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + row + ':reminderSection:reminder' );
        	reminderPicklist = document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + row + ':reminderSection:reminderPickList' );
	    	if( !reminderCheckbox.checked ){
	        	reminderPicklist.disabled = true;
	        }
	        else{
	        	reminderPicklist.disabled = false;
	        }
	        row++;
    	}
    },
    
	reloadActionPlan : function ( templateId, selectedTemplateId ){

		var new_location 	= window.location.href;
		var reload 			= 0;	
		var refObjType 		= getElementsByClass('hidden_refOBjtype',null,'input');
		var objIds 			= getElementsByClass('hidden_refID',null,'input');
				
		// There is a template selected and different from previous one
		if (selectedTemplateId != '000000000000000' &&  templateId.match(selectedTemplateId) == null){
			
			if( templateId != "" ){
				// Replaces current selected template id into the URL
				if (new_location.match('templateId')){
					new_location = new_location.replace( templateId, selectedTemplateId );
					reload = 1;
				// Adds current selected template id into the URL
				}else{
					
					var patt1=/\?/gi;
					var txt = new String(location);
					var contat_with = "&";	
					var obj_ids_str = "";
					
					if (txt.match(patt1) == null){
						contat_with = "?";	
					}
					
					new_location += contat_with+"templateId=" + selectedTemplateId;
					
					if (refObjType.length > 0 && refObjType[0].value != ''){
						new_location = new_location +'&refType='+ refObjType[0].value;
						
						// add objects list
						
						if (objIds.length > 0 && objIds[0].value != ''){
							new_location = new_location +'&refId='+escape(objIds[0].value);
						}
					}
				reload = 1;
				}
					
			}else{
			
				var patt1=/\?/gi;
				var txt = new String(location);
				var contat_with = "&";	
				var obj_ids_str = "";
				
				if (txt.match(patt1) == null){
					contat_with = "?";	
				}
				
				new_location += contat_with+"templateId=" + selectedTemplateId;
				
				if (refObjType.length > 0 ){
					new_location = new_location +'&refType='+ refObjType[0].value;
					
					// add objects list
					if (objIds.length > 0 ){
						new_location = new_location +'&refId='+escape(objIds[0].value);
					}
				}
				reload = 1;	
			}
		
			if (reload){				
				window.location.href = new_location;	
			}
			
		}else{
			//manage invalid template ID
		}
	},
	
	clearAPName : function(ev){
		if (window.event && window.event.keyCode == 13 || ev.which == 13) {
			if(document.getElementById('editPage:apForm:editBlock:Name')){
				document.getElementById('editPage:apForm:editBlock:Name').value='';
			}
		}
	},
	
	showCalendar : function(row){
		var rowSplit 	= row.split( ":" );
        var rowIndex 	= rowSplit[5];
		var dateId 		= 'editPage:apForm:editBlock:taskSection:taskTable:' + rowIndex + ':activityDate';
		var icon 		= document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + rowIndex + ':calendarDueDate' );	
		var startDate;
		
		//Gets start date from input field
		if (document.getElementById( 'editPage:apForm:editBlock:StartDate' ) ){
			startDate = document.getElementById( 'editPage:apForm:editBlock:StartDate' ).value;
		}
		//Gets start date from readonly field
		else{
			startDate = document.getElementById( 'editPage:apForm:editBlock:StartDateReadonly' ).innerHTML;
		}
		//var new_date 	= new Date(startDate);
		var new_date = DateUtil.getDateFromValue(startDate);
		
		//var new_date = DateUtil.getDateFromValue( document.getElementById( dateId ).value );
		if(new_date != 'Invalid Date'){
			
			//Sets the due date
			this.setDueDate( new_date, rowIndex );
			
			//Creates the calendar
			dP = new DatePicker();
			dP.datePicker=new DatePicker();
			dP.datePicker.today = new Date(new_date);
			dP.datePicker.show( false, dateId, false, icon );
			
			//Creates custom date bar if it is not defined
			if(getElementsByClass('customDateBar',document,'div').length == 0){
				var dateBar 		= getElementsByClass('dateBar',document,'div')[0];
				var customDateBar 	= document.createElement('DIV');
				customDateBar.className 		= 'customDateBar';
				customDateBar.style.height 		= '20px';
				customDateBar.style.width 		= '185px';
				customDateBar.style.textAlign 	= 'center';
				dateBar.parentNode.insertBefore(customDateBar,dateBar);
			}
			
			//Set month and year of custom date bar
			var monthPicker 	= document.getElementById(DatePickerIds.MONTH_PICKER);
			var selectedIndex 	= monthPicker.selectedIndex;
			var month 			= monthPicker.options[selectedIndex].text;
			var yearPicker 		= document.getElementById(DatePickerIds.YEAR_PICKER);
			selectedIndex		= yearPicker.selectedIndex;
			var year 			= yearPicker.options[selectedIndex].text;
			getElementsByClass('customDateBar',document,'div')[0].innerHTML = month + ' - ' + year;
			
			//Shows custom date bar and hides date bar 
			getElementsByClass('dateBar',document,'div')[0].style.display = 'none';
			getElementsByClass('buttonBar',document,'div')[0].style.display = 'none';
			getElementsByClass('customDateBar',document,'div')[0].style.display = 'block';
		}	
		
	},
	
	hideCalendar : function(){
		//Hides calendar only if custom calendar has been displayed 
		if(getElementsByClass('customDateBar',document,'div').length > 0){
			getElementsByClass('dateBar',document,'div')[0].style.display = 'block';
			getElementsByClass('buttonBar',document,'div')[0].style.display = 'block';
			getElementsByClass('customDateBar',document,'div')[0].style.display = 'none';
			document.getElementById('datePicker').style.display = 'none';
			delete dP;
		}
	},
	
	refreshItemDates : function(){
		//taskTableRow
		var rowsCount	= $('table.taskTable tbody tr.taskTableRow').length;
		for( var j=0; j<rowsCount; j++ ){
			var rowIndex 	= j;
			var dateId 		= 'editPage:apForm:editBlock:taskSection:taskTable:' + rowIndex + ':activityDate';
			var icon 		= document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + rowIndex + ':calendarDueDate' );	
			var startDate;
			
			//Gets start date from input field
			if (document.getElementById( 'editPage:apForm:editBlock:StartDate' ) ){
				startDate = document.getElementById( 'editPage:apForm:editBlock:StartDate' ).value;
			}
			//Gets start date from readonly field
			else{
				startDate = document.getElementById( 'editPage:apForm:editBlock:StartDateReadonly' ).innerHTML;
			}
			//var new_date 	= new Date(startDate);
			var new_date = DateUtil.getDateFromValue(startDate);
			
			if(new_date != 'Invalid Date'){
				
				//Sets the due date
				this.setDueDate( new_date, rowIndex );
				
			}
			
		}
		
	},
	
	setDueDate : function( startDate, rowIndex ){
		var dependence	= document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + rowIndex + ':dependent' );
		var days;
		
		// Set start date
		//var splitDate 	= startDate.split("/");
		var dueDate = new Date();
		/*dueDate.setMonth	( parseInt( splitDate[0] ) - 1 );
		dueDate.setDate		( splitDate[1] );
		dueDate.setFullYear	( splitDate[2] );*/
		dueDate.setMonth	( startDate.getMonth() );
		dueDate.setDate		( startDate.getDate() );
		dueDate.setFullYear	( startDate.getFullYear() );
	
		// Add all dependent tasks to a list
		var dependentTasks = new Array();
		var i = 0;
		if( dependence != null ){
			//console.log('Calculating dependence for ... ['+rowIndex+']');
			while( dependence.value != 'None' && i <= 200){
				//console.log('... ['+i+'] '+dependence.value + ' => .dependent_'+dependence.value);
				dependentTasks[i] 	= dependence.value;
				//dependence 			= document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + dependence.value + ':dependent' );
				dependence 			= document.getElementById( $('.dependent_'+dependence.value).attr('id') );
				i++;
			}
		}
		// Calculate due date for all dependent tasks
		for( var j=dependentTasks.length-1; j>=0; j-- ){
			days		= document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + $('.dependent_'+dependentTasks[j]).attr('id').split(":")[5] + ':daysFromStart' ).value;
			dueDate		= this.calculateDueDate(dueDate, days);
			//console.log('... ... ['+j+'] Due Date calculated as ['+DateUtil.getDateStringFromUserLocale( dueDate )+'] by adding '+days+' days');
		}
		// Calculate due date for current task
		days 	= document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + rowIndex + ':daysFromStart' ).value;
		dueDate = this.calculateDueDate(dueDate, days);
		//console.log('... For ROW ['+rowIndex+'] Due Date calculated as ['+DateUtil.getDateStringFromUserLocale( dueDate )+'] by adding '+days+' days');
		
		// Sets date of current task 
		//var stringDate = (dueDate.getMonth() + 1) + '/' + dueDate.getDate() + '/' + dueDate.getFullYear();
	    document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:' + rowIndex + ':activityDate').value = DateUtil.getDateStringFromUserLocale( dueDate );
	},
	
	calculateDueDate : function(date, days){
		var skipWeekend = document.getElementById( 'editPage:apForm:editBlock:skipWeekendCheckbox' );
		var dueDate = new Date(date);
		
		days = ( isNaN(days) || days == '' ) ? 0 : parseInt( days );
		dueDate = addDays( dueDate, days );
		
		if( skipWeekend.checked ){
		    // find if the due date fall on a Saturday or Sunday.  Add 1 day for Sunday and 2 for Saturday 
		    var skipPicklist = document.getElementById( 'editPage:apForm:editBlock:skipDayPicklist' );
			var dayOfWeek = dueDate.getDay();
		    var daysAdd = 0;
		    if( skipPicklist.selectedIndex == 1 ){ 
		        // push to friday
		        daysAdd = ( dayOfWeek == 0 ) ? daysAdd - 2 	: daysAdd ;
		        daysAdd = ( dayOfWeek == 6 ) ? daysAdd - 1	: daysAdd ;
		    } 
		    else if( skipPicklist.selectedIndex == 2 ){ 
		        // push to monday
		        daysAdd = ( dayOfWeek == 0 ) ? daysAdd + 1 : daysAdd ;
		        daysAdd = ( dayOfWeek == 6 ) ? daysAdd + 2 : daysAdd ; 
		    }
		    dueDate = addDays( dueDate, daysAdd );
		} 
		return dueDate;
	},
	
	showAgain : function(){
		setTimeout("ActionPlanCreationScripts.myOnclick()",20);
	},
	
	myOnclick : function(){
		DatePicker.pickDate(true, 'editPage:apForm:editBlock:StartDate', false);
	},
	
	checkAllDependent : function (){
		var allTasks = getElementsByClass('third',document,'td');
		    allTasks = allTasks.concat(getElementsByClass('third ',document,'td'));
		var selObj = null;
		for(var i in allTasks){
		    if (allTasks[i].getElementsByTagName('select').length > 0 && allTasks[i].getElementsByTagName('select')[0].className =='selectDepending'){
		        selObj = allTasks[i].getElementsByTagName('select')[0];
		        ActionPlanCreationScripts.checkDependent(selObj .id);
		    }
		}
	},
	checkAllDependent_NEW : function (){
		var allTasks = getElementsByClass('third',document,'td');
		    allTasks = allTasks.concat(getElementsByClass('third ',document,'td'));
		var selObj = null;
		for(var i in allTasks){
		    if (allTasks[i].getElementsByTagName('select').length > 0 && allTasks[i].getElementsByTagName('select')[0].className.split(" ")[0] =='selectDepending'){
		        selObj = allTasks[i].getElementsByTagName('select')[0];
				ActionPlanCreationScripts.checkDependent_NEW('.'+selObj.className.split(" ")[1]);
		    }
		}
	},
	showTaskAssignee : function ( row ){
        var rowSplit = row.split( ":" );
        row = rowSplit[5];      
       	document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + row + ':ownerLookUpPanel' ).style.display = "block";
       	document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + row + ':ownerRecordPanel' ).style.display = "none";
        
    },
	hideTaskAssignee : function ( row ){
        var rowSplit = row.split( ":" );
        row = rowSplit[5];      
       	document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + row + ':ownerLookUpPanel' ).style.display = "none";
       	//a = getElementsByClass('lookupInput',document,'span')[2]
       	var tmp = document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + row + ':ownerLookUpPanel' );
        var a_tmp = getElementsByClass('lookupInput',tmp,'span');
        a_tmp[0].childNodes[0].value = '';
       	document.getElementById( 'editPage:apForm:editBlock:taskSection:taskTable:' + row + ':ownerRecordPanel' ).style.display = "block";
        
    },
	
	enableButtonsOnComplete : function( ){	
		if (document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:tb')){
			var rows = document.getElementById('editPage:apForm:editBlock:taskSection:taskTable:tb').rows;
			var rowsCount = rows.length;			
			if( rowsCount >= apTaskSize ){
				enableActions();
				ActionPlanCreationScripts.displayTaskAssigneeStatus();
				clearTimeout(buttonsTimeout);
			}			
		}
		
	},
	
	displayTaskAssigneeStatus : function (){
		
		var all_cols= getElementsByClass('fifth',document,'td');
		for (var h = 0; h < all_cols.length; h++) {	
		var aux_divs = getElementsByClass('ownerLookUpPanel',all_cols[h],'div');
		    for (var i = 0; i < aux_divs.length; i++) {
		    	
		    	//display lookUp or [record Owner]
		        var lkp_span = getElementsByClass('lookupInput',aux_divs[i],'span');
		        if(lkp_span.length > 0 && lkp_span[0].childNodes.length >0){
		            if (lkp_span[0].childNodes[0].value.length > 0 ){
		                var a_tmp = getElementsByClass('ownerLookUpPanel',all_cols[h],'div');
		                for ( var j = 0; j < all_cols[h].childNodes.length; j++ ){
							span = all_cols[h].childNodes[ j ];
							if ( span.nodeName == "SPAN" )
							 	var b_tmp = span;
		                	
		            	}
		                if (a_tmp[0]){ a_tmp[0].style.display = 'block'}
		                if (b_tmp){ b_tmp.style.display = 'none'}
		            }
		        }
		        
		    }
		}
		
	},
	
	showTasksListLoader : function(){
		var tableWidth 	= document.getElementById('editPage:apForm:editBlock:taskSection:taskTable').offsetWidth;
		var tableHeight = document.getElementById('editPage:apForm:editBlock:taskSection:taskTable').offsetHeight;
		document.getElementById('tasksListLoader').style.width 				= tableWidth  	+ 'px';
		document.getElementById('tasksListLoader').style.height 			= tableHeight 	+ 'px';
		document.getElementById('tasksListLoader').style.display 			= 'block';
		document.getElementById('tasksListLoaderMessage').style.marginTop	= tableHeight/2 + 'px';
	},
	
	hideTasksListLoader : function(){
		document.getElementById('tasksListLoader').style.display = 'none';
	},
	
	confirmTaskDeletion : function(dependent ){
		var display_confirmation = false;
		var index = ( dependent.split( ":" ) );
		
		//check if this tasks has any other depending on it
		var allTasks = getElementsByClass('third',document,'td');
		    allTasks = allTasks.concat(getElementsByClass('third ',document,'td'));
		var i = 0; 
		var selObj= null;   
		while (i < allTasks.length && !display_confirmation ){
			if (allTasks[i] != undefined && allTasks[i].getElementsByTagName('select').length > 0 && 
		    	allTasks[i].getElementsByTagName('select')[0].className =='selectDepending'){
				selObj = allTasks[i].getElementsByTagName('select')[0];
		        if ( index[5]== selObj.value )
		        	display_confirmation = true; 
		    }
		    i++;
		}    

		if( display_confirmation ){
			return !confirm(AP_TASKS_CONFIRM_MSG);
		}
		else{
			return false;
		}
	},
	confirmTaskDeletion_NEW : function(dependent ){
		var display_confirmation = false;
		var index = ( dependent.split( "_" ) );
		
		//check if this tasks has any other depending on it
		var allTasks = getElementsByClass('third',document,'td');
		    allTasks = allTasks.concat(getElementsByClass('third ',document,'td'));
		var i = 0; 
		var selObj= null;   
		while (i < allTasks.length && !display_confirmation ){
			if (allTasks[i] != undefined && allTasks[i].getElementsByTagName('select').length > 0 && allTasks[i].getElementsByTagName('select')[0].className.split(" ")[0] =='selectDepending'){
				selObj = allTasks[i].getElementsByTagName('select')[0];
		        if ( index[1]== selObj.value )
		        	display_confirmation = true; 
		    }
		    i++;
		}
		
		if( display_confirmation ){
			return !confirm(AP_TASKS_CONFIRM_MSG);
		}
		else{
			return false;
		}
	},
	
	showSaveSuccessSimpleDialog : function(){
		var htmlBody = '<table style=\'width:420px;\' border=\'0\' cellpadding=\'5\' cellspacing=\'5\' align=\'center\' border=\'0\'><tr><td style=\'width:40px;\'><img src=\'/img/msg_icons/confirm32.png\' style=\'margin:0 5px;\'/></td><td>The Action Plan is being applied in the background. This would usually take less than sixty seconds however it may take longer in some circumstances.</td></tr><tr><td colspan=\'2\' align=\'center\' style=\'text-align:center;\'><button class=\'btnSharing publishersharebutton cxchattersubmit btn\' style=\'width:70px;\' onclick=\'doRedirect(); return false;\'>   Ok   </button></td></tr></table>';
		var sd = new SimpleDialog("SD"+Dialogs.getNextId(), true);
		sd.setTitle('Action Plan');
	   	sd.createDialog();
	   	sd.setContentInnerHTML(htmlBody);
	   	sd.show();
	   	return sd;
	}

}
