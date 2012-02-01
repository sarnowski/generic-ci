var GITCE = {

    debug: false,
    d: function d(a) {
        if (!this.debug) return;

        if (console.info === undefined) {
            alert(a);
        } else {
            console.info(a);
        }
    }

};