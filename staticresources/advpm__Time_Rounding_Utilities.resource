function fixAtTwo(anynum) 
{
	var numStr = anynum.toString();
	var decPos = numStr.indexOf(".");	
	if ( decPos == -1 )
	{
		return numStr + ".00";
	}
	else
	{
		numStr += "00";	
		return numStr.substr(0,decPos+3);
	}
}
function roundToNthMinute(value, roundByValue) {
	var val = value;
	var i = parseInt(roundByValue);
	
	var m = val * 60;
	var rem = fixAtTwo( m % i );
	
	var base = parseInt((m / i), 10) * i;
	var r = base + (rem>0 ? i : 0);
	
	r = r / 60;
	val = fixAtTwo( r );
	
	return val;
}
function roundToTenth(value) { // 2.53
	var arr = fixAtTwo(value).split('.'); // 2, 53
	var decimalPart = arr[0]; // 2
	var fractionPart = arr[1]; // 53
	var subArr = fixAtTwo(fractionPart / 10).split('.'); 
	var subDecimalPart = subArr[0]; //5
	var subFractionPart = subArr[1]; //3
	var val = value;
	if (subFractionPart > 0)
		val = (parseInt((value * 10), 10) + 1) / 10;
	return fixAtTwo( val );
}
function roundToHalf(value) { // 2.53
	var arr = fixAtTwo(value).split('.'); // 2, 53
	var decimalPart = arr[0]; // 2
	var fractionPart = arr[1]; // 53
	var val = value;
	if (parseInt(fractionPart,10) > 0 && parseInt(fractionPart,10) <= 49)
		val = parseFloat(value) + parseFloat(50 - parseInt(fractionPart, 10))/100;
	else if (parseInt(fractionPart,10) > 50 && parseInt(fractionPart,10) <= 99)
		val = parseFloat(value) + parseFloat(100 - parseInt(fractionPart,10))/100;
	return fixAtTwo( val );
}
function roundToQuarter(value) { // 2.53
	var arr = fixAtTwo(value).split('.'); // 2, 53
	var decimalPart = arr[0]; // 2
	var fractionPart = arr[1]; // 53
	var val = value;
	if (parseInt(fractionPart,10) > 0 && parseInt(fractionPart,10) <= 24)
		val = parseFloat(value) + parseFloat(25 - parseInt(fractionPart,10))/100;
	else if (parseInt(fractionPart,10) > 25 && parseInt(fractionPart,10) <= 49)
		val = parseFloat(value) + parseFloat(50 - parseInt(fractionPart,10))/100;
	else if (parseInt(fractionPart,10) > 50 && parseInt(fractionPart,10) <= 74)
		val = parseFloat(value) + parseFloat(75 - parseInt(fractionPart,10))/100;
	else if (parseInt(fractionPart,10) > 75 && parseInt(fractionPart,10) <= 99)
		val = parseFloat(value) + parseFloat(100 - parseInt(fractionPart,10))/100;
	return fixAtTwo( val );
}

function doTimeRounding(tmId, enableRounding, roundByValue, timeQtyObjId) {
	if (tmId == '' && roundByValue > 0 && (enableRounding == 'true' || enableRounding == '1')) {
		var obj = document.getElementById(timeQtyObjId);
		if (obj != null && roundByValue != '') {
			if (obj.value != '' && obj.value != null) {
				obj.value = roundToNthMinute(obj.value, roundByValue);
				/*if (roundByValue == 'Tenth') {
					obj.value = roundToTenth(obj.value);
				}
				else if (roundByValue == 'Quarter') {
					obj.value = roundToQuarter(obj.value);
				}
				else if (roundByValue == 'Half') {
					obj.value = roundToHalf(obj.value);
				}*/
			}
		}
	}
}