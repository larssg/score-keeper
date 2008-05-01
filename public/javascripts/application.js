$(document).ready(function() {
	$('body.login #login').focus();

	$('#rankings').tablesorter({
		sortList: [[0, 0]],
		widgets: ['zebra'],
		headers: {
			1: { sorter: false },
			2: { sorter: false }
		}
	});
	
	$('#newbies').tablesorter({
		sortList: [[0, 0]],
		widgets: ['zebra'],
		headers: {
			1: { sorter: false }
		}
	});
	
	$('#teams').tablesorter({
		sortList: [[1, 1]],
		widgets: ['zebra'],
		headers: {
			0: { sorter: false },
			5: { sorter: false }
		}
	});
});