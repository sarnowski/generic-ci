GITCE.detail = function (parameters) {
    var options = $.extend({
        refreshTime:5000
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
                    that.history = {

                        "1.0":[

                            {
                                "number":"0",
                                "commit":"8489fb65a106d0be2f4fdd769cca349afeab11f1",
                                "result":"1",
                                "time":"1325769873",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                        ],
                        "master":[

                            {
                                "number":"0",
                                "commit":"8489fb65a106d0be2f4fdd769cca349afeab11f1",
                                "result":"1",
                                "time":"1325612621",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"1",
                                "commit":"2a6867603b843e9da57e8e1df1321db3f7224e5b",
                                "result":"1",
                                "time":"1325769960",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"2",
                                "commit":"b230099931e8535c0b59b84610c0a8927a91829e",
                                "result":"1",
                                "time":"1325772720",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"3",
                                "commit":"0f366e0ac8f6201f7189025d33bf7c6bd95d804e",
                                "result":"1",
                                "time":"1326117540",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"4",
                                "commit":"3ede5df6cb12f0153f1675621772510b8c71286d",
                                "result":"1",
                                "time":"1326118261",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"5",
                                "commit":"6bfe50d5d84432fb07c2bd4a49503f864bb9b1dc",
                                "result":"1",
                                "time":"1326119700",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"6",
                                "commit":"fe11503e953c9a40dbea3f9920f7a77e308cb1d3",
                                "result":"1",
                                "time":"1326119760",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"7",
                                "commit":"af5010c76062d431a8a617789058d397ebe6a109",
                                "result":"0",
                                "time":"1326119820",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"8",
                                "commit":"b82faa8907d73a1cf1b496fd924efa520010f4af",
                                "result":"0",
                                "time":"1326119880",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"9",
                                "commit":"bce79e64a52c708b34c431947e2e14b2dd7d8eb2",
                                "result":"1",
                                "time":"1326120720",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"10",
                                "commit":"5f2c317ab5e2445fd5c96e12816e554446f67cb5",
                                "result":"0",
                                "time":"1326120780",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"11",
                                "commit":"108c7b0366efa5840965dffdb24632b5fcbd5b03",
                                "result":"1",
                                "time":"1326120900",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"12",
                                "commit":"424c8e25fc1888db375ff5b235601fe2aed0ce60",
                                "result":"0",
                                "time":"1326120960",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"13",
                                "commit":"4e7f35b55f1253ac5d9575fb9a15fe1e973d2d69",
                                "result":"0",
                                "time":"1326123420",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"14",
                                "commit":"703f0514e9b2143a26540ef1b7642366bc2c408c",
                                "result":"0",
                                "time":"1326125873",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"15",
                                "commit":"76006870c667d6f4a509e932eee5d3b80c01975d",
                                "result":"0",
                                "time":"1326126000",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"16",
                                "commit":"3ddc7fa5f29a66a6f1c098a90113497b223ccb02",
                                "result":"0",
                                "time":"1326126900",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"17",
                                "commit":"3669c07aaede6a42d570ea86bfee575770189eb7",
                                "result":"0",
                                "time":"1326126960",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"18",
                                "commit":"9535dd058749fedb8603b54a4dc94ba92c5cdd40",
                                "result":"0",
                                "time":"1326129000",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"19",
                                "commit":"d3bd2f51a965da3d5ba1ba41a06685589264f379",
                                "result":"0",
                                "time":"1326129240",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"20",
                                "commit":"973002de69e1ce89653214364f60d36116b912cd",
                                "result":"0",
                                "time":"1326129360",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"21",
                                "commit":"19f0a696d322ca69e263ac707db9fcbcd0b01b2d",
                                "result":"0",
                                "time":"1326129600",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"22",
                                "commit":"0e38dc617145471464b0866c64c018452346f3af",
                                "result":"0",
                                "time":"1327327895",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"23",
                                "commit":"189b5c80298c713a43a485f4067500a64b58d6a0",
                                "result":"0",
                                "time":"1327328040",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"24",
                                "commit":"c24df284896f97b14174b4dab0c3d7875073a10c",
                                "result":"0",
                                "time":"1327328520",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"25",
                                "commit":"141d0792801498458f51ccf046405b31d1dda858",
                                "result":"10",
                                "time":"1327328760",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"26",
                                "commit":"9b06f5097827b02cacb7e6547e27cec8b3380414",
                                "result":"0",
                                "time":"1327328881",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"27",
                                "commit":"845ee88811a93ee8f597be64c88e6c0f09f064bd",
                                "result":"0",
                                "time":"1327329300",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"28",
                                "commit":"a2fef1c2fcc51bce239a2c018b9443994ef696cb",
                                "result":"0",
                                "time":"1327329480",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"29",
                                "commit":"f5739198a5960b1bbdfcf08ec5ea1eba1f23b6c4",
                                "result":"0",
                                "time":"1327331100",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"30",
                                "commit":"471bb889c57459711cb288b1aaaaebbf38baf7d8",
                                "result":"10",
                                "time":"1327331940",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"31",
                                "commit":"446633779eb60272d9a1c7ef291543510e935ade",
                                "result":"10",
                                "time":"1327331965",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"32",
                                "commit":"b21a881ad96ad3d32df5832d64ce6cd68cb12c5a",
                                "result":"0",
                                "time":"1327332000",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"33",
                                "commit":"101e2f2ebfce5f7da99383eb67ade88b0f2b0eef",
                                "result":"0",
                                "time":"1327332180",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"34",
                                "commit":"271c95191b69343deea1f1625e8a38357a5c25b5",
                                "result":"0",
                                "time":"1327332240",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"35",
                                "commit":"8242fcaa966bb4a382d602f733d980afa55fe458",
                                "result":"0",
                                "time":"1327332361",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"36",
                                "commit":"1aa686ad3256b0a53a641b31444c8083a5cb253d",
                                "result":"10",
                                "time":"1327332540",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"37",
                                "commit":"6e054e998c912f5af7df382212d4371c3fc0a560",
                                "result":"10",
                                "time":"1327332840",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"38",
                                "commit":"811d126384b92789aaacdeb1fb21cee972afdabe",
                                "result":"10",
                                "time":"1327333080",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"39",
                                "commit":"ef07a44a3f21d8d728587a9a90a7aa9647033cf3",
                                "result":"0",
                                "time":"1327333560",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"40",
                                "commit":"c836ddc806f5f9df989aeeda8893e9ddfcb2db30",
                                "result":"10",
                                "time":"1327333740",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"41",
                                "commit":"52840980d5bc493e4e63f3ecc67b8e27358a19ef",
                                "result":"0",
                                "time":"1327334040",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"42",
                                "commit":"4db18d8066aed66e7115cea368ea14ada718a230",
                                "result":"10",
                                "time":"1327335720",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"43",
                                "commit":"f79f19c722f6c1319e45d6cdc6b014a566c940e5",
                                "result":"10",
                                "time":"1327335840",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"44",
                                "commit":"6454154a239420afde10058d86f41c7e921831be",
                                "result":"0",
                                "time":"1327335960",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"45",
                                "commit":"28e62f3a500eddf4963a80f35fa3bd3b546c0710",
                                "result":"10",
                                "time":"1327336020",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"46",
                                "commit":"ebb4ebeb64ee5b779bf4ff84b17791570fb6d0a2",
                                "result":"10",
                                "time":"1327340521",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"47",
                                "commit":"918de156d5dcccde54bb6e4f3e6fcaf1fafd6f42",
                                "result":"0",
                                "time":"1327392841",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"48",
                                "commit":"cc05731e268d0264c2e67ddd85161300b15cd655",
                                "result":"10",
                                "time":"1327392960",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"49",
                                "commit":"b8faee80188cdcd3de31a5a43c1b1d527983dc45",
                                "result":"0",
                                "time":"1327394580",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"50",
                                "commit":"e936011d94310484fcd7b7a1d4310893fc7b8aa3",
                                "result":"0",
                                "time":"1327394820",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"51",
                                "commit":"6c60bcfd7a1c9f03bd5da7ee4cb7d3ec19d06067",
                                "result":"10",
                                "time":"1327394845",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"52",
                                "commit":"2289948967bb76a16cd2162aff250369af2beb5b",
                                "result":"0",
                                "time":"1327395360",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"53",
                                "commit":"ca8ab2bab102e15b6a3b66161d138d8a1dce79f1",
                                "result":"10",
                                "time":"1327395420",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"54",
                                "commit":"6e83ee530f4a41f674e3c15d81adcef644d2d843",
                                "result":"0",
                                "time":"1327395480",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"55",
                                "commit":"1f34e4a3997cc1ff38bc3e74c2632d3818c24941",
                                "result":"0",
                                "time":"1328095981",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"56",
                                "commit":"f560713955263598382e21db52da74d45aaec7cb",
                                "result":"0",
                                "time":"1328097000",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                            ,
                            {
                                "number":"57",
                                "commit":"f3f0a3fe8da136fd341aeac626d4b5ef3a851781",
                                "result":"0",
                                "time":"1328099280",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                        ],
                        "testblub":[

                            {
                                "number":"0",
                                "commit":"b230099931e8535c0b59b84610c0a8927a91829e",
                                "result":"1",
                                "time":"1325773680",
                                "authors":[
                                    {"name":"Tobias Sarnowski", "email":"sarnowski@cosmocode.de"}
                                ]
                            }
                        ]
                    };

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
                        status = 'Broken';
                        branchColumn.addClass('status-broken');
                    } else if (branchHistory['result'] != '') {
                        status = 'OK';
                        branchColumn.addClass('status-ok');
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
                        + params.server + '&config=' + params.config + '/' + branchName + '/' + buildNo + '">show logs</a>'));

                    branchColumn.appendTo(branchTable);
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
            if (that.currentBranch != null && $('.' + that.currentBranch).length) {
                active = $('.branches li.' + that.currentBranch);
            }
            if (active) {
                active.addClass('current');
                $('.details .' + active.attr('rel')).addClass('current');
            }
        },

        init:function () {
            $('h2').html(params.config);

            // fetch Status, then History, then display it
            that.fetchStatus(function () {
                that.fetchHistory.call(that, function () {
                    that.buildHistory();
                });
            });

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