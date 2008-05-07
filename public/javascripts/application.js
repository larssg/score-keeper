var scoreKeeper = {
	matchUpdate: {
		interval: 60,
		
		init: function() {
			if (scoreKeeper.matchUpdate.isShowingDashboard()) {
				scoreKeeper.matchUpdate.run();
			}
		},
		
		run: function() {
			$.get('/', {
					game_id: scoreKeeper.matchUpdate.gameId(),
					last_update: scoreKeeper.matchUpdate.lastUpdate()
				},
				function(data, status) {
					setTimeout(scoreKeeper.matchUpdate.run, scoreKeeper.matchUpdate.interval * 1000);
					if (jQuery.trim(data) != '') {
						$('#main').html(data);
						scoreKeeper.tableSort();
					}
				}
			);
		},
		
		isShowingDashboard: function() {
			return $('#logs').length > 0;
		},
		
		lastUpdate: function() {
			return scoreKeeper.matchUpdate.getValue('last_update');
		},
		
		gameId: function() {
			return scoreKeeper.matchUpdate.getValue('game_id');
		},
		
		getValue: function(value) {
			var elements = $("#dashboard_data ." + value);
			if (elements.length > 0) {
				var element = elements[0];
				return element.innerHTML;
			}
			return false;
		}
	},
	
	tableSort: function() {
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

		$('#teammates').tablesorter({
			sortList: [[6, 1]],
			widgets: ['zebra'],
			headers: {
				0: { sorter: false },
				1: { sorter: false },
				2: { sorter: false }
			}
		});
	},
};

$(document).ready(function() {
	$('body.login #login').focus();
	scoreKeeper.tableSort();
	scoreKeeper.matchUpdate.init();
});