GITCE.overview = function (parameters) {
    var options = $.extend({
        refreshTime:2000
    }, parameters);

    var tplServer = $('<li class="server"><h2/><ul class="configs clearfix"></ul>');
    var tplConfig = $('<li class="config"><h3 class="name"/>' +
        '<h4>broken</h4><ul class="branches branches-broken"/>' +
        '<h4>pending</h4><ul class="branches branches-next"/>' +
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

    function branchHasAuthor(states, branch) {
        for(var index in branch.authors) {
            if (states.user == branch.authors[index].email) {
                return true;
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
                    var index, branch, branchContainer;

                    // Pending Branches
                    var branchesPending = $('.branches-next', configContainer).empty();
                    for (index in status['next']) {
                        branch = status['next'][index];

                        branchContainer = tplBranch.clone().appendTo(branchesPending);
                        if (branchHasStatus(status, "running", branch.branch)) {
                            branchContainer.find('span').text(branch.branch + ' *');
                            branchContainer.find('a').attr('href', '/log.html?server=' + server.url + '&config=' + name + '/' + branch.branch + '/' + branch.number);
                        } else {
                            branchContainer.find('span').text(branch['branchContainer']);
                            branchContainer.find('a').remove();
                        }
                    }

                    if (branchesPending.children().size()) {
                        branchesPending.prev().show();
                    } else {
                        branchesPending.prev().hide();
                    }

                    // Broken Branches
                    var branchesBroken = $('.branches-broken,', configContainer).empty();
                    var broken = false;
                    var responsible = false;
                    for (index in status['broken']) {
                        branch = status['broken'][index];

                        broken = true;
                        responsible = responsible || branchHasAuthor(status, branch);

                        branchContainer = tplBranch.clone().appendTo(branchesBroken);
                        branchContainer.find('span').text(branch.branch);
                        branchContainer.find('a').attr('href', '/log.html?server=' + server.url + '&config=' + name + '/' + branch.branch + '/' + branch.number);
                    }

                    if (branchesBroken.children().size()) {
                        branchesBroken.prev().show();
                    } else {
                        branchesBroken.prev().hide();
                    }

                    if (broken) {
                        configContainer.addClass('broken');
                        if (responsible) {
                            configContainer.addClass('you-broke-it');
                        }
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