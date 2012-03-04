var updateInterval = 2000;

var selectedConfig = null;
var selectedBranch = null;
var selectedBuild = null;

function Branch_ListBuilds(branch) {
	var table = $('#builds table');
	table.empty();

	var time = new Date();
	for (key in branch.builds) {
		var build = branch.builds[key];

		time.setTime(build.time * 1000);
		tr = $('<tr class="' + (build.result == 0 ? 'ok' : 'broken') + '"><td>' + build.number + '</td><td>' + time.toGMTString() + '</td></tr>');

		table.prepend(tr);
	}
}

function Branch_Show(branch) {
	selectedBranch = branch;
	selectedBuild = null;

	$('#branches li.selected').removeClass('selected');
	branch.li.addClass('selected');

	if (branch.builds == null || branch.number != branch.builds[branch.builds.length - 1].number) {
		$('#builds table').empty();
		$.ajax({
			url: "cgi-bin/builds.cgi?" + branch.config + "/" + branch.branch,
			success: function(builds) {
				branch.builds = builds;
				Branch_ListBuilds(branch);
			}
		});
	} else {
		Branch_ListBuilds(branch);
	}
}

function Branch_Status(branch) {
	var status = branch.status;
	if (branch.running) {
		status = 'running';
	}
	return status;
}

function Branch_Sort() {
	$('#branches ol li').sort(function(a, b) {
		first = $(a);
		second = $(b);

		if (first.hasClass('inactive') && !second.hasClass('inactive')) {
			return 1;
		} else if (!first.hasClass('inactive') && second.hasClass('inactive')) {
			return -1;
		} else {
			return $(a).text().toLowerCase() > $(b).text().toLowerCase() ? 1 : -1;
		}
	}).appendTo('#branches ol');
}

function Branch_Create(branch) {
	var li = $('<li>' + branch.branch + '</li>');

	$('#branches ol').append(li);
	Branch_Sort();

	li.click(function() {
		Branch_Show(branch);
	});

	return li;
}

function Branch_UpdateEntry(branch) {
	ol = $('#branches ol');

	var li = null;
	$('#branches ol li').each(function(k, v){
		if ($(v).text() == branch.branch) {
			li = $(v);
		}
	});

	if (li == null) {
		li = Branch_Create(branch);
	}

	branch.li = li;

	li.removeClass('ok broken running');
	li.addClass(Branch_Status(branch));

	li.removeClass('active inactive build release');
	li.addClass(branch.action);
}

function Config_Show(config) {
	selectedConfig = config;
	selectedBranch = null;
	selectedBuild = null;

	ol = $('#branches ol');
	ol.empty();

	for (key in config.branches) {
		Branch_UpdateEntry(config.branches[key]);
	}

	$('#configs li.selected').removeClass('selected');
	config.li.addClass('selected');
}

function Config_Create(config) {
	ol = $('#configs ol');

	li = $('<li>' + config.config + '</li>');
	ol.append(li);

	ol.children().sort(function(a, b) {
		return $(a).text() > $(b).text() ? 1 : -1;
	}).appendTo(ol);

	li.click(function() {
		Config_Show(config);
	});

	return li;
}

function Config_Status(config) {
	var status = 'ok';
	for (key in config.branches) {
		var branch = config.branches[key];
		if (branch.status == 'broken') {
			status = 'broken';
		}
		if (branch.running) {
			status = 'running';
			break;
		}
	}
	return status;
}

function Config_UpdateEntry(config) {
	var li = null;
	$('#configs li').each(function(i, v){
		if ($(v).text() == config.config) {
			li = $(v);
		}
	});

	if (li == null) {
		li = Config_Create(config);
	}

	config.li = li;

	config.status = Config_Status(config);
	li.removeClass('ok broken running');
	li.addClass(config.status);
}

function Config_Update(config) {
	$.ajax({
		url: "cgi-bin/status.cgi?" + config.config,
		success: function(status) {
			config.user = status.user;

			if (config.branches == null) {
				config.branches = status.branches;
				for (key in config.branches) {
					config.branches[key].config = config.config;
					config.branches[key].builds = null;
				}
			} else {
				// update or add new entries
				for (keys in status.branches) {
					found = false;
					for (keyc in config.branches) {
						if (config.branches[keyc].branch == status.branches[keys].branch) {
							found = true;
							for (attr in status.branches[keys]) {
								config.branches[keyc][attr] = status.branches[keys][attr];
							}
							break;
						}
					}
					if (!found) {
						status.branches[keys].config = config.config;
						status.branches[keys].builds = null;
						config.branches[config.branches.length] = status.branches[keys];
					}
				}
			}

			Config_UpdateEntry(config);

			if (selectedConfig != null && config.config == selectedConfig.config) {
				for (key in config.branches) {
					Branch_UpdateEntry(config.branches[key]);
				}
			}
		}
	});
}

function Config_Init(config) {
	config.branches = null;

	Config_Update(config);
	window.setInterval(function(){ Config_Update(config) }, updateInterval);
}

$(document).ready(function() {
	// show version
	$.ajax({
		url: "cgi-bin/version.cgi",
		success: function (version) {
			$('header h2 a').text("gitce " + version);
		}
	});

	// initialize list of configurations once
	$.ajax({
		url: "cgi-bin/list.cgi",
		success: function (configs) {
			for (key in configs) {
				Config_Init(configs[key]);
			}
		}
	});
});
