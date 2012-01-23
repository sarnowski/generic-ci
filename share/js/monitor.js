var wasBroken = false;

$(document).ready(function() {
	// load given configuration
	var urlParts = window.location.href.split('?');
	if (urlParts.length != 2 || urlParts[1] == '') {
		$('#loading span').html('<h2>No configuration given!</h2>');
	} else {
		loadConfiguration(urlParts[1]);
	}
});

function loadConfiguration(config) {
	window.setInterval(function() {
		$.ajax({
			url: "cgi-bin/status.cgi?" + config,
			success: function(response){
				updateConfiguration(config, response);
			}
		});
	}, 3000);
}

function updateConfiguration(config, status) {
	$('#loading').hide();
	$('.config').html(config);

	if (status.running.length > 0) {
		$('#branch').html(status.running[0].branch);
		$('#commit').html(status.running[0].message);
		var authors = '';
		var first = true;
		for (index in status.running[0].authors) {
			var author = status.running[0].authors[index];
			if (first) {
				first = false;
			} else {
				authors += ', ';
			}
			authors += author.name;
		}
		$('#authors').html(authors);

		$('#monitor-idle').hide();
		$('#monitor-running').show();
	} else {
		$('#monitor-idle').show();
		$('#monitor-running').hide();
	}

	if (status.broken.length > 0) {
		var first = true;
		var branches = 'BROKEN: ';
		var authors = '';
		for (index in status.broken) {
			var branch = status.broken[index];
			if (first) {
				first = false;
			} else {
				branches += ', ';
			}
			branches += branch.branch;

			var afirst = true;
			for (aindex in branch.authors) {
				var author = branch.authors[aindex];
				if (authors.indexOf(author.name) < 0) {
					if (afirst) {
						afirst = false;
					} else {
						authors += ', ';
					}
					authors += author.name;
				}
			}
		}
		$('#branches').html(branches);
		$('#broken_authors').html(authors);

		$('#broken').show();
		$('body').attr('class', 'failure');

		if (!wasBroken) {
			// initially broken!
			playAlarm();
		}
		wasBroken = true;
	} else {
		$('#broken').hide();
		$('body').attr('class', 'success');

		if (wasBroken) {
			// ok again
		}
		wasBroken = false;
	}
}

function playAlarm() {
	var alarmSound = new Audio('sound/alarm.ogg');
	alarmSound.play();
}
