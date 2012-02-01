function d(a) {
    if (console.info !== undefined) {
        console.info(a);
    }
}

var consoleLog = function (parameters) {
    var options = $.extend({
        refreshTime:2000
    }, parameters);

    // parse GET-Parameters
    var params = {};
    var query = window.location.href.split('?');
    if (query.length == 2) {
        var queries = query[1].split('&');
        for (var index in queries) {
            var pair = queries[index].split('=');
            params[pair[0]] = pair[1];
        }
    }

    // extend with get-parameters default-parameters
    params = $.extend({
        server:'/',
        config:'test/master/0'
    }, params);

    var that = {
        update:function (consoleLog) {
            $.ajax({
                url:params.server + 'cgi-bin/log.cgi?' + params.config,
                success:function (response) {
                    consoleLog.text(response);
                }
            });
        },

        init:function () {
            var consoleLog = $('#consoleLog');

            that.update.call(that, consoleLog);

            window.setInterval(function () {
                that.update.call(that, consoleLog);
            }, options.refreshTime);
        }
    };

    return that;
};