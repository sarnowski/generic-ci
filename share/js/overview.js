function d(a) {
    if (console.info !== undefined) {
        console.info(a);
    }
}

var overview = function (parameters) {
    var options = $.extend({
        refreshTime:2000
    }, parameters);

    var tplServer = $('<li class="server"><h2/><ul class="configs clearfix"></ul>');
    var tplConfig = $('<li class="config"><h3 class="name"/>' +
        '<h4>broken</h4><ul class="branches branches-broken"/>' +
        '<h4>next</h4><ul class="branches branches-next"/>' +
        '</li>');
    var tplBranch = $('<li class="branch"><span/><a>log</a>')

    var that = {
        servers:null,
        serverList:[
            {name:'localhost', url:'/'},
        ],

        update:function () {
            that.servers.empty();

            for (var index in that.serverList) {
                that.initServer(that.serverList[index]);
            }
        },

        updateConfig:function (name, configContainer, server) {
            $.ajax({
                url:server.url + "cgi-bin/status.cgi?" + name,
                success:function (status) {
                    var index, item, branch;

                    var branchesBroken = $('.branches-broken,', configContainer).empty();
                    var branchesNext = $('.branches-next', configContainer).empty();

                    for (index in status['next']) {
                        item = status['next'][index];

                        branch = tplBranch.clone().appendTo(branchesNext);
                        branch.find('span').text(item['branch']);
                        branch.find('a').attr('href', '/log.html?server=' + server.url + '&config=' + item['branch'] + '/' + name + '/0');
                    }

                    for (index in status['broken']) {
                        item = status['broken'][index];
                        branch = tplBranch.clone().appendTo(branchesBroken);
                        branch.find('span').text(item['branch']);
                        branch.find('a').attr('href', '/log.html?server=' + server.url + '&config=' + name + '/' + item['branch'] + '/0');
                    }
                }
            });
        },

        initServer:function (server) {
            var serverContainer = tplServer.clone().appendTo(that.servers);

            serverContainer.find('h2').html(server.name);

            $.ajax({
                url:server.url + 'cgi-bin/list.cgi',
                success:function (configs) {
                    for (var index in configs) {
                        that.initConfig(configs[index], serverContainer, server);
                    }
                }
            });
        },

        initConfig:function (name, serverContainer, server) {
            var configContainer = tplConfig.clone().appendTo(serverContainer.find('.configs'));

            configContainer.find('h3').html(name);

            that.updateConfig.call(that, name, configContainer, server);

            window.setInterval(function () {
                that.updateConfig.call(that, name, configContainer, server);
            }, options.refreshTime);
        },

        init:function () {
            that.servers = $('.servers');

            for (var index in that.serverList) {
                that.initServer(that.serverList[index]);
            }
        }
    };

    return that;
};