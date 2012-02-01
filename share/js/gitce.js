var GITCE = {

    debugState:true,
    debug:function d(a) {
        if (!this.debugState) return;

        if (console.info === undefined) {
            alert(a);
        } else {
            console.info(a);
        }
    },

    //TODO implent a more reliable parsing algo
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
    }

};