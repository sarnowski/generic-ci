var GITCE = {

    debugState:false,
    debug:function d(a) {
        if (!this.debugState) return;

        if (console.info === undefined) {
            alert(a);
        } else {
            console.info(a);
        }
    },

    //TODO implement a more reliable parsing algo
    getQueryParams:function () {
        var params = {};
        var query = window.location.href.split('?');
        if (query.length == 2) {
            var queries = query[1].split('&');
            for (var index in queries) {
                var pair = queries[index].split('=');
                params[pair[0]] = pair[1];
            }
        }

        return params;
    },

    getMachineName: function(name) {
        return name.toLowerCase().replace(/[^A-Za-z0-9]/, '-');
    },

    cookieObject: function(name, value) {
        if (arguments.length > 1) {
            return this.cookie(name, $.toJSON(value));
        }

        var cookieValue = this.cookie(name);
        return cookieValue === null ? null : $.parseJSON(cookieValue);
    },

    cookie:function (key, value) {
        if (arguments.length == 1) {
            var pairs = document.cookie.split('; ');
            for (var i = 0, pair; pair = pairs[i] && pairs[i].split('='); i++) {
                if (decodeURIComponent(pair[0]) === key) {
                    return decodeURIComponent(pair[1] || '');
                }
            }
            return null;

        } else {
            document.cookie = encodeURIComponent(key) + '=' + encodeURIComponent(value);
        }
    }
};