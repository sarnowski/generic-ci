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

    /**
     * Adapted from jQuery Cookie plugin
     * Copyright (c) 2010 Klaus Hartl (stilbuero.de)
     */
    cookie:function (key, value, options) {
        if (arguments.length > 1 && (!/Object/.test(Object.prototype.toString.call(value)) || value === null || value === undefined)) {
            options = $.extend({}, options);

            if (value === null || value === undefined) {
                options.expires = -1;
            }

            if (typeof options.expires === 'number') {
                var days = options.expires, t = options.expires = new Date();
                t.setDate(t.getDate() + days);
            }

            value = String(value);

            return (document.cookie = [
                encodeURIComponent(key), '=', options.raw ? value : encodeURIComponent(value),
                options.expires ? '; expires=' + options.expires.toUTCString() : '',
                options.path ? '; path=' + options.path : '',
                options.domain ? '; domain=' + options.domain : '',
                options.secure ? '; secure' : ''
            ].join(''));
        }

        options = value || {};
        var decode = options.raw ? function (s) {
            return s;
        } : decodeURIComponent;

        var pairs = document.cookie.split('; ');
        for (var i = 0, pair; pair = pairs[i] && pairs[i].split('='); i++) {
            if (decode(pair[0]) === key) return decode(pair[1] || '');
        }
        return null;
    }
};