GITCE.overview = function (parameters) {
    var options = $.extend({
        refreshTime:2000
    }, parameters);

    var tplServer = $('<li class="server"><h2/><ul class="configs clearfix"></ul>');
    var tplConfig = $('<li class="config"><h3 class="name"/>' +
        '<h4>broken</h4><ul class="branches branches-broken"/>' +
        '<h4>next</h4><ul class="branches branches-next"/>' +
        '</li>');
    var tplBranch = $('<li class="branch"><span/><a>log</a>');

    function branchHasStatus(states, status, branch) {
        for(var index in states[status]) {
            var branches = states[status];
            for(var key in branches) {
                if (branches[key].branch == branch) {
                    return true;
                }
            }
        }

        return false;
    }

    var that = {
        servers:null,
        serverList:[
            {title:'localhost', url:'/', deletable:false}
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
                        if (branchHasStatus(status, "running", item["branch"])) {
                            branch.find('span').text(item['branch'] + ' *');
                            branch.find('a').attr('href', '/log.html?server=' + server.url + '&config=' + name + '/' + item['branch'] + '/' + item['number']);
                        } else {
                            branch.find('span').text(item['branch']);
                            branch.find('a').remove();
                        }
                    }

                    for (index in status['broken']) {
                        item = status['broken'][index];
                        branch = tplBranch.clone().appendTo(branchesBroken);
                        branch.find('span').text(item['branch']);
                        branch.find('a').attr('href', '/log.html?server=' + server.url + '&config=' + name + '/' + item['branch'] + '/' + item['number']);
                    }
                }
            });
        },

        initServer:function (server) {
            var serverContainer = tplServer.clone().appendTo(that.servers);

            serverContainer.find('h2').html(server.title);

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

            $('#add-server').live('submit', function (e) {
                var server = {
                    title:$(this).find('#server-title').val(),
                    url:$(this).find('#server-location').val(),
                    deletable:true
                };

                // TODO nicer
                if (server.title != "" && server.url != "") {
                    that.serverList.push(server);
                    that.initServer(server);
                }

                e.preventDefault();
                return false;
            });
        }
    };

    return that;
};