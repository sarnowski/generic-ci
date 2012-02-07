GITCE.detail = function (parameters) {
    var options = $.extend({
        refreshTime:10000
    }, parameters);

    var params = $.extend({
        server:'/',
        config:'master'
    }, GITCE.getQueryParams());

    var tplBranch = $('<li class="branch"><h4/><table></table>');
    var tplTableHeader = $('<tr><th>Build</th><th>Time</th><th>Authors</th><th>Status</th><th></th></tr>');
    var tplTableColumn = $('<tr><td class="build"/><td class="time"/><td class="authors"/><td class="status"/><td class="actions"/></tr>');
    var tplTableShow = $('<tr class="show-all"><td colspan="5"><a href="#" class="show-all">show all</a></td></tr>');

    function isActiveBranch(name) {
        for (var index in that.status['active']) {
            if (that.status['active'][index]['branch'] == name) {
                return true;
            }
        }
        return false;
    }

    function isPendingBranch(name) {
        for (var index in that.status['next']) {
            if (that.status['next'][index]['branch'] == name) {
                return true;
            }
        }
        return false;
    }

    var that = {
        currentBranch:null,

        status:null,
        fetchStatus:function (callback) {
            $.ajax({
                url:params.server + 'cgi-bin/status.cgi?' + params.config,
                success:function (status) {
                    that.status = status;

                    if (typeof(callback) == "function") {
                        callback.call(that);
                    }
                }
            });
        },

        history:null,
        fetchHistory:function (callback) {
            $.ajax({
                url:params.server + 'cgi-bin/builds.cgi?' + params.config,
                success:function (history) {
                    that.history = history;

                    if (typeof(callback) == "function") {
                        callback.call(that);
                    }
                }
            });
        },

        buildHistory:function () {
            if (that.status == null || that.history == null) return;

            var branchDetails = $('.details');
            var branchesActive = $('.state-active ul');
            var branchesInactive = $('.state-inactive ul');

            for (var branchName in that.history) {
                // initalize a new branch-container
                var branchContainer = tplBranch.clone();
                branchContainer.find('h4').html(branchName);

                // create the history
                var branchTable = branchContainer.find('table');
                var latestBuild = that.history[branchName].length - 1;
                for (var buildNo = latestBuild; buildNo >= 0; buildNo--) {
                    that.createBranchColumn(branchName, buildNo).appendTo(branchTable);
                }

                // add history table-header and more-column
                branchTable.prepend(tplTableHeader.clone());

                // add branch to list
                var menuEntry = $('<li rel="' + GITCE.getMachineName(branchName) + '">' + branchName + '</li>');
                menuEntry.addClass(branchTable.find('tr:nth-child(2)').attr('class'));
                if (isActiveBranch(branchName)) {
                    branchesActive.append(menuEntry);
                } else {
                    branchesInactive.append(menuEntry);
                }

                branchContainer.addClass(GITCE.getMachineName(branchName)).appendTo(branchDetails);
            }

            // show first or current branch
            var active = $('.branches li:first');
            if (that.currentBranch != null && $('.branches li[rel="' + that.currentBranch+'"]').length) {
                active = $('.branches li[rel="' + that.currentBranch+'"]');
            }
            active.addClass('current');
            $('.details .' + active.attr('rel')).addClass('current');
        },

        createBranchColumn: function(branchName, buildNo) {
            var branchHistory = that.history[branchName][buildNo];
            var branchColumn = tplTableColumn.clone();

            // calculate date
            var date = branchHistory['time'];
            if (branchHistory['time'] != '') {
                var calcDate = new Date();
                calcDate.setTime(branchHistory['time'] * 1000);
                date = calcDate.toGMTString();
            }

            // format authors
            var authors = '';
            for (var index in branchHistory['authors']) {
                authors += branchHistory['authors'][index]['name'] + ', ';
            }
            if (authors != '') {
                authors = authors.substr(0, authors.length - 2);
            }

            // set Status
            var status = '';
            if (branchHistory['result'] == '0') {
                status = 'OK';
                branchColumn.addClass('status-ok');
            } else if (branchHistory['result'] != '') {
                status = 'Broken';
                branchColumn.addClass('status-broken');

            } else if (isPendingBranch(branchName)) {
                status = 'Pending';
                branchColumn.addClass('status-pending');
            }

            // fill columns
            branchColumn.find('.build').html('#' + branchHistory['number']);
            branchColumn.find('.time').html(date);
            branchColumn.find('.authors').html(authors);
            branchColumn.find('.status').html(status);
            branchColumn.find('.actions').html($('<a href="/log.html?server='
                + params.server + '&config=' + params.config + '&branch=' + branchName + '&build=' + buildNo + '">show logs</a>'));

            return branchColumn;
        },

        clearView: function() {
            $('.states .branches li, .details li').remove();
        },

        updateView: function() {
            that.status = null;
            that.history = null;

            that.fetchStatus(function () {
                that.fetchHistory.call(that, function () {
                    that.clearView();
                    that.buildHistory();
                });
            });
        },

        init:function () {
            $('h2').html(params.config);

            // initialize view and update-interval
            that.updateView();
            window.setInterval(function(){
                that.updateView();
            }, options.refreshTime);

            // bind history show-all event
            $('.states .branches li').live('click', function (e) {
                e.preventDefault();

                that.currentBranch = $(this).attr('rel');

                $('.states li').removeClass('current');
                $('.details li').removeClass('current')
                    .filter('.' + that.currentBranch)
                    .addClass('current');

                $(this).addClass('current');

                return false;
            });
        }
    };

    return that;
};