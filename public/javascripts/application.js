var scoreKeeper = {
    newMatch: {
        toggle: function() {
            var element = $('#add_match_form');
            element.toggle();
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
        }
    }
};

$(document).ready(function() {
    $('body.login #login').focus();
    scoreKeeper.matchUpdate.init();

    $('#add_match_button').click(function() {
      scoreKeeper.newMatch.toggle();
      return false;
    });

    if ($('#messages').length > 0) {
        setTimeout(function() { $('#messages').fadeOut('slow'); }, 8000);
    }
});