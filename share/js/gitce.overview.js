GITCE.overview = function (parameters) {
    var options = $.extend({
        refreshTime:5000
    }, parameters);

    var tplServer = $('<li class="server"><h2/><ul class="configs clearfix"></ul>');
    var tplConfig = $('<li class="config"><h3 class="name"/>' +
        '<ul class="branches branches-next"/>' +
        '<ul class="branches branches-broken"/>' +
        '<span style="display: none;">nothing pending / broken</span>' +
        '</li>');
    var tplBranch = $('<li class="branch"><a/>');

    function branchHasStatus(states, status, branch) {
        for (var index in states[status]) {
            var branches = states[status];
            for (var key in branches) {
                if (branches[key].branch == branch) {
                    return true;
                }
            }
        }

        return false;
    }

    function branchHasAuthor(states, branch) {
        for (var index in branch.authors) {
            if (states.user == branch.authors[index].email) {
                return true;
            }
        }
        return false;
    }

    function isValidServer(server) {
        if (server.title == "" || server.url == "") {
            return false;
        }

        for(var index in that.serverList) {
            if (that.serverList.hasOwnProperty(index)) {
                if (server.url == that.serverList[index].url || server.title == that.serverList[index].title) {
                    return false;
                }
            }
        }

        return true;
    }

    var that = {
        servers:null,
        serverList:[
            {title:'localhost', url:'/', deletable:false}
        ],
        configIntervals:{},

        update:function () {
            that.servers.empty();

            for (var index in that.serverList) {
                that.initServer(that.serverList[index]);
            }
        },

        updateConfig:function (config, configContainer, server) {
            $.ajax({
                url:server.url + "cgi-bin/status.cgi?" + config.config,
                success:function (status) {
                    var index, branch, branchContainer;

                    var nothingToDo = configContainer.find('span').show();

                    // Pending Branches
                    var branchesPending = $('.branches-next', configContainer).empty();
                    for (index in status['next']) {
                        branch = status['next'][index];

                        branchContainer = tplBranch.clone().appendTo(branchesPending);
                        if (branchHasStatus(status, "running", branch.branch)) {
                            branchContainer.find('a').text(branch.branch);
                            branchContainer.find('a').attr('href', '/log.html?server=' + server.url + '&config=' + config.config + '/' + branch.branch + '/' + branch.number);
                        } else {
                            branchContainer.find('a').text(branch['branchContainer']);
                            branchContainer.find('a').remove();
                        }
                    }

                    if (branchesPending.children().size()) {
                        branchesPending.show();
                        nothingToDo.hide();
                    } else {
                        branchesPending.hide();
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
                        branchContainer.find('a').text(branch.branch);
                        branchContainer.find('a').attr('href', '/log.html?server=' + server.url + '&config=' + config.config + '&branch=' + branch.branch + '&build=' + branch.number);
                    }

                    if (branchesBroken.children().size()) {
                        branchesBroken.show();
                        nothingToDo.hide();
                    } else {
                        branchesBroken.hide();
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

            if (server.deletable) {
                serverContainer.find('h2').html(server.title + '<a href="#" class="delete-server">x</a>');
            } else {
                serverContainer.find('h2').html(server.title);
            }

            $.ajax({
                url:server.url + 'cgi-bin/list.cgi',
                success:function (configs) {
                    for (var index in configs) {
                        that.initConfig(configs[index], serverContainer, server);
                    }
                }
            });
        },

        addServer:function (server) {
            if (!isValidServer(server)) return false;

            that.serverList.push(server);
            GITCE.cookieObject('serverList', that.serverList);
            that.initServer(server);

            return true;
        },

        deleteServer:function (serverContainer) {
            var index, headline, serverName;

            // find out the server-name
            headline = serverContainer.find('h2');
            headline.find('a').remove();

            serverName = headline.html();

            for(index in that.serverList) {
                if (that.serverList[index].title == serverName && that.serverList[index].deletable) {
                    // remove from serverlist
                    that.serverList.splice(index, 1);

                    // clear all update-intervals
                    for(var key in that.configIntervals[serverName]) {
                        window.clearInterval(that.configIntervals[serverName][key]);
                    }
                    that.configIntervals[serverName] = new Array();

                    // remove from gui
                    serverContainer.remove();

                    break;
                }
            }

            GITCE.cookieObject('serverList', that.serverList);
        },

        initConfig:function (config, serverContainer, server) {
            var configContainer = tplConfig.clone().appendTo(serverContainer.find('.configs'));

            configContainer.find('h3').html($('<a href="/detail.html?server=' + server.url + '&config='+config.config+'">'+config.config+'</a>'));

            // initial and interval-driven update-process
            that.updateConfig.call(that, config, configContainer, server);
            var configInterval = window.setInterval(function () {
                that.updateConfig.call(that, config, configContainer, server);
            }, options.refreshTime);

            // save config-Interval for clearing
            if (that.configIntervals[server] === undefined) {
                that.configIntervals[server] = new Array();
            }
            that.configIntervals[server].push(configInterval);

        },

        fetchVersion: function(serverUrl, callback){
            $.ajax({
                url: serverUrl + 'cgi-bin/version.cgi',
                success: function(version) {
                    if (typeof(callback) == 'function') {
                        callback.call(that, version);
                    }
                }
            });
        },

        init:function () {
            // restore configuration
            var serverList = GITCE.cookieObject('serverList');
            if (serverList !== null && serverList.length) {
                that.serverList = serverList;
            }

            // initalize servers
            that.servers = $('.servers');

            for (var index in that.serverList) {
                that.initServer(that.serverList[index]);
            }

            // bind add-server-event
            $('#add-server').live('submit', function (e) {
                e.preventDefault();

                var server = {
                    title:$(this).find('#server-title').val(),
                    url:$(this).find('#server-location').val(),
                    deletable:true
                };

                that.addServer(server);

                return false;
            });

            // bind delete-server-event
            $('.delete-server').live('click', function (e) {
                e.preventDefault();

                that.deleteServer($(this).parents('.server'));
            });

            // display version
            that.fetchVersion('/', function(version) {
                console.log(version);
                $('.version').text(version);
            });
        }
    };

    return that;
};