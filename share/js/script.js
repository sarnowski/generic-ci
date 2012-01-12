function loadAllConfigurations() {
    $.ajax({
        url:"cgi-bin/list.cgi",
        success:function (response) {
            $('body').empty().append('<h1>gitce</h1><ul id="configs"></ul>');
            for (var index in response) {
                var config = response[index];
                $('#configs').append('<li>' + config + '</li>');
                watchConfiguration(config);
            }
        }
    });
}

function watchConfiguration(config) {
    $('body').append('<div id="config-' + config + '"><h2>' + config + '</h2><h4>next</h4><ul class="next"></ul><h4>active</h4><ul class="active"></ul></div>');
    window.setInterval(function () {
        $.ajax({
            url:"cgi-bin/status.cgi?" + config,
            success:function (response) {
                updateConfiguration(config, response);
            }
        });
    }, 2000);
}

function updateConfiguration(config, status) {
    var item, index, configId;

    configId = "#config-" + config;
    $(configId, '.next,.active').empty();

    for (index in status['next']) {
        item = status['next'][index];
        $(configId + ' .next').append('<li>' + item['branch'] + ' (' + item['commit'] + ')</li>');
    }

    for (index in status['active']) {
        item = status['active'][index];
        $(configId + ' .active').append('<li>' + item['branch'] + ' (' + item['commit'] + ')</li>');
    }
}

(function ($) {
    $(document).ready(function () {
        loadAllConfigurations();
    });
})(jQuery);