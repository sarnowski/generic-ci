GITCE.console = function (parameters) {
    var options = $.extend({
        refreshTime:2000
    }, parameters);

    var params = GITCE.getQueryParams();

    // extend with get-parameters default-parameters
    params = $.extend({
        server:'/',
        config:'test',
        branch:'master',
        build:'0'
    }, params);

    var logKeys = {
        'error':[
            new RegExp('err', 'i'),
            new RegExp('fail', 'i')
        ],
        'warning':[
            new RegExp('warn', 'i')
        ],
        'info':[
            new RegExp('^Build .*-\\d+$'),
            new RegExp('^Running build script .*...$'),
            new RegExp('^Return code: \\d+$')
        ],
        'success':[
            new RegExp('success', 'i')
        ]
    };

    var that = {
        highlightText:function (text) {
            var lines = text.split("\n");
            for (var index in lines) {
                lines[index] = that.highlightLine(lines[index]);
            }
            return lines.join("\n");
        },

        highlightLine:function (line) {
            for (var state in logKeys) {
                for (var keyIndex in logKeys[state]) {
                    var key = logKeys[state][keyIndex];
                    if (line.search(key) >= 0) {
                        line = '<span class="' + state + '">' + line + '</span>';
                        return line;
                    }
                }
            }
            return line;
        },

        updateConsole:function (consoleLog) {
            $.ajax({
                url:params.server + 'cgi-bin/log.cgi?' + params.config + '/' + params.branch + '/' + params.build,
                success:function (response) {
                    consoleLog.html(that.highlightText(response));
                }
            });
        },

        updateHistory:function (historyList) {
            $.ajax({
                url:params.server + 'cgi-bin/builds.cgi?' + params.config,
                success:function (history) {
                    if (typeof(history[params.branch]) != "undefined") {
                        historyList.empty();
                        for (var build in history[params.branch]) {

                            var link = $('<a>Build #' + build + '</a>');
                            link.attr('href', '/log.html?server=' + params.server + '&config='
                                + params.config + '&branch=' + params.branch + '&build=' + build);

                            if (build == params.build) {
                                historyList.append($('<li class="current"/>').append(link));
                            } else {
                                historyList.append($('<li/>').append(link));
                            }
                        }
                    }
                }
            })
        },

        init:function () {
            // initalize console-log
            var consoleLog = $('#console');

            that.updateConsole(consoleLog);
            window.setInterval(function () {
                that.updateConsole.call(that, consoleLog);
            }, options.refreshTime);

            // initalize history
            var historyContainer = $('#history');
            historyContainer.find('h2').text(params.config + '/' + params.branch);
            that.updateHistory(historyContainer.find('ul'));
        }
    };

    return that;
};