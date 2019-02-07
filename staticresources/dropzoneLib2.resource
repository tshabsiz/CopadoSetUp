	//Variable declaration	
	var file, reader;
    var base64File;
    var $data, $size, $type, $test, $width, $height;
	var filename;    
	window.dataURL = ''; 
    
    var defaults;
    $.fn.pasteImageReader;
    
	window.loadPasteImageReader = function (){
        
        //disable button        
        
        //register event
        $.event.fix = (function (originalFix) {
            return function (event) {
                event = originalFix.apply(this, arguments);
                if (event.type.indexOf('copy') === 0 || event.type.indexOf('paste') === 0) {                                        
                    event.clipboardData = event.originalEvent.clipboardData;
                }
                return event;
            };
        })($.event.fix);
        
        //set default option
        defaults = {
            callback: $.noop,
            matchType: /image.*/
        };
        
        //define Jq function imagePaste 
        $.fn.pasteImageReader = function (options) {           
            if (typeof options === "function") {
                options = {
                    callback: options
                };
            }
            
            options = $.extend({}, defaults, options);
            return this.each(function () {
                
                var $this, element;
                element = this;
                $this = $(this);
                
                return $this.bind('paste', function (event) {
                    
                    var clipboardData, found;
                    found = false;
                    clipboardData = event.clipboardData;
                    
                    return Array.prototype.forEach.call(clipboardData.types, function (type, i) {
                        
                        if (found) {
                            return;
                        }
                        if (type.match(options.matchType) || clipboardData.items[i].type.match(options.matchType)) {
                            
                            file = clipboardData.items[i].getAsFile();                            
                            reader = new FileReader();
                            
                            reader.onload = function (evt) {
                                return options.callback.call(element, {
                                    dataURL: evt.target.result,
                                    event: evt,
                                    file: file,
                                    name: file.name
                                });
                            };
                            
                            reader.readAsDataURL(file);
                            return found = true;
                        }
                    });
                });
            });
        };
        
        //set variable values
        $data = $('.data');
        $size = $('.size');
        $type = $('.type');
        $test = $('#test');
        $width = $('#width');
        $height = $('#height');     
        
        
        //Jq function "imagePaste" calling
        $("html").pasteImageReader(function (results) {           
            filename = results.filename;
            window.dataURL = results.dataURL;
            $data.text(window.dataURL);
            $size.val(results.file.size);
            $type.val(results.file.type);
            $test.attr('href', window.dataURL);
            var img = document.createElement('img');
            img.src = window.dataURL;
            var w = img.width;
            var h = img.height;
            $width.val(w);
            $height.val(h);
            
            return $(".active").css({
                backgroundImage: "url(" + window.dataURL + ")"
            }).data({'width': w, 'height': h});
            
        });  
        
        //-- Make target div Active
        //$('.target').on('click', function(event) {        
        $('.drop-zone').on('click', '.target',function(event) {              
            event.preventDefault();
            
            var $this = $(this);
            var bi = $this.css('background-image');
            if (bi != 'none') {
                $data.text(bi.substr(4, bi.length - 6));
            }
            
            $('.active').removeClass('active');
            $this.addClass('active');                    
        });
    }