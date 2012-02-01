GITCE.console = function (parameters) {
    var options = $.extend({
        refreshTime:2000
    }, parameters);

    var params = GITCE.getQueryParams();

    // extend with get-parameters default-parameters
    params = $.extend({
        server:'/',
        config:'test/master/0'
    }, params);

    var logKeys = {
        'error': [
            new RegExp('err', 'i'),
            new RegExp('fail', 'i')
        ],
            'warning': [
            new RegExp('warn', 'i')
        ],
            'info': [
            new RegExp('^Build .*-\\d+$'),
            new RegExp('^Running build script .*...$'),
            new RegExp('^Return code: \\d+$')
        ],
            'success': [
            new RegExp('success', 'i')
        ]
    };

    var that = {
        highlightText: function(text) {
            var lines = text.split("\n");
            for (var index in lines) {
                lines[index] = that.highlightLine(lines[index]);
            }
            return lines.join("\n");
        },

        highlightLine: function(line) {
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

        update:function (consoleLog) {
            $.ajax({
                url:params.server + 'cgi-bin/log.cgi?' + params.config,
                success:function (response) {
                    consoleLog.html(that.highlightText(response));
                }
            });
        },

        init:function () {
            var consoleLog = $('#console');

            that.update.call(that, consoleLog);

            window.setInterval(function () {
                that.update.call(that, consoleLog);
            }, options.refreshTime);
        }
    };

    return that;
};