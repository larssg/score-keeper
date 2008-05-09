var scoreKeeper = {
  newMatch: {
    toggle: function() {
      var element = $('#add_match_form');
      element.toggle();
      if (element.css('display') == 'block') {
        scoreKeeper.matchUpdate.interval = 10;
        $.get('/games/' + scoreKeeper.matchUpdate.gameId() + '/game_added_warning',
          {},
          function(data, status) {
            if (status == 'success') {
              $('#add_match_form .game_added_warning').html(data);
              $('#add_match_form .game_added_warning').show();
            }
          });
      } else {
        scoreKeeper.matchUpdate.interval = 60;
        $('#add_match_form .game_added_warning').html('');
        $('#add_match_form .game_added_warning').hide();
      }
    }
  },
  
	matchUpdate: {
		interval: 60,
		
		init: function() {
			if (scoreKeeper.matchUpdate.isShowingDashboard()) {
				scoreKeeper.matchUpdate.schedule();
			}
		},
		
		schedule: function() {
			setTimeout(scoreKeeper.matchUpdate.run, scoreKeeper.matchUpdate.interval * 1000);
		},
		
		run: function() {
			$.get('/', {
					game_id: scoreKeeper.matchUpdate.gameId(),
					last_update: scoreKeeper.matchUpdate.lastUpdate()
				},
				function(data, status) {
					if (jQuery.trim(data) != '') {
						$('#main').html(data);
						scoreKeeper.tableSort();
					}
					scoreKeeper.matchUpdate.schedule();
				}
			);
		},
		
		isShowingDashboard: function() {
			return $('#logs').length > 0;
		},
		
		lastUpdate: function() {
			return $('#dashboard_data .last_update').html();
		},
		
		gameId: function() {
			return $('#dashboard_data .game_id').html();
		},
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
	if ($('#messages').length > 0) {
		setTimeout(function() { $('#messages').fadeOut('slow'); }, 8000);
	}
});