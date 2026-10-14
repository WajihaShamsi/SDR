"use strict";
var Driver = /** @class */ (function () {
    function Driver(name, id, cmds) {
        this.name = name;
        this.id = id;
        this.cmds = cmds;
    }
    Driver.prototype.getCmdRef = function (cmdName) {
        for (var _i = 0, _a = this.cmds; _i < _a.length; _i++) {
            var cmd = _a[_i];
            if (cmdName === cmd.name) {
                return cmd.id;
            }
        }
        throw new ReferenceError(cmdName + ': command not found');
    };
    Driver.prototype.getCmds = function () {
        var cmdsDict = {};
        for (var _i = 0, _a = this.cmds; _i < _a.length; _i++) {
            var cmd = _a[_i];
            cmdsDict[cmd.name] = cmd;
        }
        return cmdsDict;
    };
    return Driver;
}());
var WebSocketPool = /** @class */ (function () {
    function WebSocketPool(poolSize, url, onOpenCallback) {
        var _this = this;
        this.poolSize = poolSize;
        this.url = url;
        this.onOpenCallback = onOpenCallback;
        this.poolSize = poolSize;
        this.url = url;
        this.pool = [];
        this.freeSockets = [];
        this.dedicatedSockets = [];
        this.socketCounter = 0;
        this.exiting = false;
        for (var i = 0, end = this.poolSize - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
            var websocket = this._newWebSocket();
            this.pool.push(websocket);
            websocket.onopen = function (evt) {
                return _this.waitForConnection(websocket, 100, function () {
                    console.assert(websocket.readyState === 1, 'Websocket not ready');
                    _this.freeSockets.push(_this.socketCounter);
                    if (_this.socketCounter === 0) {
                        onOpenCallback();
                    }
                    websocket.ID = _this.socketCounter;
                    websocket.onclose = function (evt) {
                        setTimeout(function () { location.reload(); }, 1000);
                    };
                    websocket.onerror = function (evt) {
                        console.error("error: ".concat(evt.data, "\n"));
                        return websocket.close();
                    };
                    return _this.socketCounter++;
                });
            };
        }
    }
    WebSocketPool.prototype._newWebSocket = function () {
        var websocket;
        if (typeof window !== 'undefined' && window !== null) {
            websocket = new WebSocket(this.url);
        }
        else { // Node
            var clientConfig = {};
            clientConfig.fragmentOutgoingMessages = false;
            var __WebSocket = require('websocket').w3cwebsocket;
            websocket = new __WebSocket(this.url, null, null, null, null, clientConfig);
        }
        websocket.binaryType = 'arraybuffer';
        return websocket;
    };
    WebSocketPool.prototype.waitForConnection = function (websocket, interval, callback) {
        var _this = this;
        if (websocket.readyState === 1) {
            // If the client has been set to exit while establishing the connection
            // we don't initialize the socket
            if (this.exiting) {
                return;
            }
            return callback();
        }
        else {
            return setTimeout(function () {
                return _this.waitForConnection(websocket, interval, callback);
            }, interval);
        }
    };
    WebSocketPool.prototype.getSocket = function (sockid) {
        if (this.exiting) {
            return null;
        }
        if (!(this.freeSockets.some(function (x) { return x == sockid; })) && (sockid >= 0) && (sockid < this.poolSize)) {
            return this.pool[sockid];
        }
        else {
            throw new ReferenceError("Socket ID ".concat(sockid.toString(), " not available"));
        }
    };
    // Obtain a socket for a dedicated task.
    // This function is provided for long term use.
    // A new socket is opened and returned to the caller.
    // This socket is not shared and can be used for a
    // dedicated task.
    // TODO: Caller close dedicated socket
    WebSocketPool.prototype.getDedicatedSocket = function (callback) {
        var _this = this;
        var websocket = this._newWebSocket();
        this.dedicatedSockets.push(websocket);
        return websocket.onopen = function (evt) {
            return _this.waitForConnection(websocket, 100, function () {
                console.assert(websocket.readyState === 1, 'Websocket not ready');
                websocket.onclose = function (evt) {
                    var idx = _this.dedicatedSockets.indexOf(websocket);
                    if (idx > -1) {
                        return _this.dedicatedSockets.splice(idx, 1);
                    }
                };
                websocket.onerror = function (evt) {
                    console.error("error: ".concat(evt.data, "\n"));
                    return websocket.close();
                };
                return callback(websocket);
            });
        };
    };
    // Retrieve a socket from the pool.
    // This function is provided for short term socket use
    // and the socket must be given back to the pool by
    // calling freeeSocket.
    WebSocketPool.prototype.requestSocket = function (callback) {
        var _this = this;
        if (this.exiting) {
            callback(-1);
            return;
        }
        if ((this.freeSockets != null) && (this.freeSockets.length > 0)) {
            var sockid_1 = this.freeSockets[this.freeSockets.length - 1];
            this.freeSockets.pop();
            return this.waitForConnection(this.pool[sockid_1], 100, function () {
                console.assert(_this.pool[sockid_1].readyState === 1, 'Websocket not ready');
                return callback(sockid_1);
            });
        }
        else { // All sockets are busy. We wait a bit and retry.
            console.assert(this.freeSockets.length === 0, 'Non empty freeSockets');
            return setTimeout(function () {
                return _this.requestSocket(callback);
            }, 100);
        }
    };
    // Give back a socket to the pool
    WebSocketPool.prototype.freeSocket = function (sockid) {
        if (this.exiting) {
            return;
        }
        if (!(this.freeSockets.some(function (x) { return x == sockid; })) && (sockid >= 0) && (sockid < this.poolSize)) {
            return this.freeSockets.push(sockid);
        }
        else {
            if (sockid != null) {
                return console.error("Invalid Socket ID ".concat(sockid.toString()));
            }
            else {
                return console.error('Undefined Socket ID');
            }
        }
    };
    WebSocketPool.prototype.exit = function () {
        this.exiting = true;
        this.freeSockets = [];
        this.socketCounter = 0;
        for (var _i = 0, _a = this.pool; _i < _a.length; _i++) {
            var websocket = _a[_i];
            websocket.close();
        }
        return this.dedicatedSockets.map(function (socket) {
            return socket.close();
        });
    };
    return WebSocketPool;
}());
// === Helper functions to build binary buffer ===
var appendInt8 = function (buffer, value) {
    buffer.push(value & 0xff);
    return 1;
};
var appendUint8 = function (buffer, value) {
    buffer.push(value & 0xff);
    return 1;
};
var appendInt16 = function (buffer, value) {
    buffer.push((value >> 8) & 0xff);
    buffer.push(value & 0xff);
    return 2;
};
var appendUint16 = function (buffer, value) {
    buffer.push((value >> 8) & 0xff);
    buffer.push(value & 0xff);
    return 2;
};
var appendInt32 = function (buffer, value) {
    buffer.push((value >> 24) & 0xff);
    buffer.push((value >> 16) & 0xff);
    buffer.push((value >> 8) & 0xff);
    buffer.push(value & 0xff);
    return 4;
};
var appendUint32 = function (buffer, value) {
    buffer.push((value >> 24) & 0xff);
    buffer.push((value >> 16) & 0xff);
    buffer.push((value >> 8) & 0xff);
    buffer.push(value & 0xff);
    return 4;
};
var floatToBytes = function (f) {
    var buf = new ArrayBuffer(4);
    (new Float32Array(buf))[0] = f;
    return (new Uint32Array(buf))[0];
};
var bytesTofloat = function (bytes) {
    var buffer = new ArrayBuffer(4);
    (new Uint32Array(buffer))[0] = bytes;
    return new Float32Array(buffer)[0];
};
var appendFloat32 = function (buffer, value) { return appendUint32(buffer, floatToBytes(value)); };
var appendFloat64 = function (buffer, value) {
    var buf = new ArrayBuffer(8);
    (new Float64Array(buf))[0] = value;
    appendUint32(buffer, (new Uint32Array(buf, 4))[0]);
    appendUint32(buffer, (new Uint32Array(buf, 0))[0]);
    console.assert(buf.byteLength === 8, 'Invalid float64 size');
    return buf.byteLength;
};
var appendArray = function (buffer, array) {
    var bytes = new Uint8Array(array.buffer);
    return bytes.map(function (_byte) { return buffer.push(_byte); });
};
var appendVector = function (buffer, array) {
    appendUint32(buffer, array.buffer.byteLength);
    var bytes = new Uint8Array(array.buffer);
    return bytes.map(function (_byte) { return buffer.push(_byte); });
};
var appendString = function (buffer, str) {
    appendUint32(buffer, str.length);
    for (var i = 0; i < str.length; i++) {
        buffer.push(str.charCodeAt(i));
    }
};
var isStdArray = function (type) { return type.split('<')[0].trim() === 'std::array'; };
var isStdVector = function (type) { return type.split('<')[0].trim() === 'std::vector'; };
var isStdString = function (type) { return type.trim() === 'std::string'; };
var isStdTuple = function (type) { return type.split('<')[0].trim() === 'std::tuple'; };
var getStdVectorType = function (type) { return type.split('<')[1].split('>')[0].trim(); };
function Command(devId, cmd) {
    var params = [];
    for (var _i = 2; _i < arguments.length; _i++) {
        params[_i - 2] = arguments[_i];
    }
    var buffer = [];
    appendUint32(buffer, 0); // RESERVED
    appendUint16(buffer, devId);
    appendUint16(buffer, cmd.id);
    if (cmd.args.length === 0) {
        return {
            devid: devId,
            cmd: cmd,
            data: new Uint8Array(buffer)
        };
    }
    if (cmd.args.length !== params.length) {
        throw new Error("Invalid number of arguments. Expected ".concat(cmd.args.length, " receive ").concat(params.length, "."));
    }
    var buildPayload = function (args, params) {
        if (args == null) {
            args = [];
        }
        var payload = [];
        for (var i = 0; i < args.length; i++) {
            var arg = args[i];
            switch (arg.type) {
                case 'uint8_t':
                    appendUint8(payload, params[i]);
                    break;
                case 'int8_t':
                    appendInt8(payload, params[i]);
                    break;
                case 'uint16_t':
                    appendUint16(payload, params[i]);
                    break;
                case 'int16_t':
                    appendInt16(payload, params[i]);
                    break;
                case 'uint32_t':
                    appendUint32(payload, params[i]);
                    break;
                case 'int32_t':
                    appendInt32(payload, params[i]);
                    break;
                case 'float':
                    appendFloat32(payload, params[i]);
                    break;
                case 'double':
                    appendFloat64(payload, params[i]);
                    break;
                case 'bool':
                    if (params[i]) {
                        appendUint8(payload, 1);
                    }
                    else {
                        appendUint8(payload, 0);
                    }
                    break;
                default:
                    if (isStdArray(arg.type)) {
                        appendArray(payload, params[i]);
                    }
                    else if (isStdVector(arg.type)) {
                        appendVector(payload, params[i]);
                    }
                    else if (isStdString(arg.type)) {
                        appendString(payload, params[i]);
                    }
                    else {
                        throw new TypeError("Unknown type ".concat(arg.type));
                    }
            }
        }
        return payload;
    };
    return {
        devid: devId,
        cmd: cmd,
        data: new Uint8Array(buffer.concat(buildPayload(cmd.args, params)))
    };
}
var Client = /** @class */ (function () {
    function Client(IP, websockPoolSize) {
        this.IP = IP;
        this.websockPoolSize = websockPoolSize;
        if (websockPoolSize == null) {
            websockPoolSize = 5;
        }
        this.websockPoolSize = websockPoolSize;
        this.url = "ws://".concat(IP, ":8080");
        this.driversList = [];
    }
    Client.prototype.init = function (callback) {
        return this.websockpool = new WebSocketPool(this.websockPoolSize, this.url, (function () {
            return this.loadCmds(callback);
        }.bind(this)));
    };
    Client.prototype.exit = function () {
        this.websockpool.exit();
        return delete this.websockpool;
    };
    // ------------------------
    //  Send
    // ------------------------
    Client.prototype.send = function (cmd) {
        var _this = this;
        if (this.websockpool === null || typeof this.websockpool === 'undefined') {
            return;
        }
        this.websockpool.requestSocket(function (sockid) {
            if (sockid < 0) {
                return;
            }
            var websocket = _this.websockpool.getSocket(sockid);
            websocket.send(cmd.data);
            if (_this.websockpool !== null && typeof _this.websockpool !== 'undefined') {
                _this.websockpool.freeSocket(sockid);
            }
        });
    };
    // ------------------------
    //  Receive
    // ------------------------
    Client.prototype.redirectError = function (errTest, errMsg, onSuccess, onError) {
        if (errTest) {
            if (onError === null) {
                throw new TypeError(errMsg);
            }
            else {
                return onError(errMsg);
            }
        }
        else {
            return onSuccess();
        }
    };
    Client.prototype.getPayload = function (mode, evt) {
        var buffer, dvBuff, i, len;
        var dv = new DataView(evt.data);
        var reserved = dv.getUint32(0);
        var classId = dv.getUint16(4);
        var funcId = dv.getUint16(6);
        if (mode === 'static') {
            len = dv.byteLength - 8;
            buffer = new ArrayBuffer(len);
            dvBuff = new DataView(buffer);
            if (len > 0) {
                for (i = 0, end = len - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
                    var asc, end;
                    dvBuff.setUint8(i, dv.getUint8(8 + i));
                }
            }
        }
        else { // 'dynamic'
            len = dv.getUint32(8);
            console.assert(dv.byteLength === (len + 12));
            buffer = new ArrayBuffer(len);
            dvBuff = new DataView(buffer);
            if (len > 0) {
                for (i = 0, end1 = len - 1, asc1 = 0 <= end1; asc1 ? i <= end1 : i >= end1; asc1 ? i++ : i--) {
                    var asc1, end1;
                    dvBuff.setUint8(i, dv.getUint8(12 + i));
                }
            }
        }
        return [dvBuff, classId, funcId];
    };
    Client.prototype._readBase = function (mode, cmd, fn) {
        var _this = this;
        if ((this.websockpool === null || typeof (this.websockpool) === 'undefined')) {
            return fn(null);
        }
        this.websockpool.requestSocket(function (sockid) {
            if (sockid < 0) {
                return fn(null);
            }
            var websocket = _this.websockpool.getSocket(sockid);
            websocket.send(cmd.data);
            websocket.onmessage = function (evt) {
                try {
                    fn(_this.getPayload(mode, evt)[0]);
                }
                finally {
                    if (_this.websockpool !== null && typeof _this.websockpool !== 'undefined') {
                        _this.websockpool.freeSocket(sockid);
                    }
                }
            };
        });
    };
    Client.prototype.readUint32Array = function (cmd, fn) {
        this._readBase('static', cmd, function (data) {
            fn(new Uint32Array(data.buffer));
        });
    };
    Client.prototype.readInt32Array = function (cmd, fn) {
        this._readBase('static', cmd, function (data) {
            fn(new Int32Array(data.buffer));
        });
    };
    Client.prototype.readFloat32Array = function (cmd, fn) {
        this._readBase('static', cmd, function (data) {
            fn(new Float32Array(data.buffer));
        });
    };
    Client.prototype.readFloat64Array = function (cmd, fn) {
        this._readBase('static', cmd, function (data) {
            fn(new Float64Array(data.buffer));
        });
    };
    Client.prototype.readUint32Vector = function (cmd, fn) {
        this._readBase('dynamic', cmd, function (data) {
            fn(new Uint32Array(data.buffer));
        });
    };
    Client.prototype.readFloat32Vector = function (cmd, fn) {
        this._readBase('dynamic', cmd, function (data) {
            fn(new Float32Array(data.buffer));
        });
    };
    Client.prototype.readFloat64Vector = function (cmd, fn) {
        this._readBase('dynamic', cmd, function (data) {
            fn(new Float64Array(data.buffer));
        });
    };
    Client.prototype.readUint32 = function (cmd, fn) {
        this._readBase('static', cmd, function (data) {
            fn(data.getUint32(0));
        });
    };
    Client.prototype.readInt32 = function (cmd, fn) {
        this._readBase('static', cmd, function (data) {
            fn(data.getInt32(0));
        });
    };
    Client.prototype.readFloat32 = function (cmd, fn) {
        this._readBase('static', cmd, function (data) {
            fn(data.getFloat32(0));
        });
    };
    Client.prototype.readFloat64 = function (cmd, fn) {
        this._readBase('static', cmd, function (data) {
            fn(data.getFloat64(0));
        });
    };
    Client.prototype.readBool = function (cmd, fn) {
        this._readBase('static', cmd, function (data) {
            fn(data.getUint8(0) === 1);
        });
    };
    Client.prototype.readTuple = function (cmd, fmt, fn) {
        var _this = this;
        this._readBase('static', cmd, function (data) {
            fn(_this.deserialize(fmt, data));
        });
    };
    Client.prototype.deserialize = function (fmt, dv, onError) {
        if (onError == null) {
            onError = null;
        }
        var tuple = [];
        var offset = 0;
        for (var i = 0, end = fmt.length - 1, asc = 0 <= end; asc ? i <= end : i >= end; asc ? i++ : i--) {
            switch (fmt[i]) {
                case 'B':
                    tuple.push(dv.getUint8(offset));
                    offset += 1;
                    break;
                case 'b':
                    tuple.push(dv.getInt8(offset));
                    offset += 1;
                    break;
                case 'H':
                    tuple.push(dv.getUint16(offset));
                    offset += 2;
                    break;
                case 'h':
                    tuple.push(dv.getInt16(offset));
                    offset += 2;
                    break;
                case 'I':
                    tuple.push(dv.getUint32(offset));
                    offset += 4;
                    break;
                case 'i':
                    tuple.push(dv.getInt32(offset));
                    offset += 4;
                    break;
                case 'f':
                    tuple.push(dv.getFloat32(offset));
                    offset += 4;
                    break;
                case 'd':
                    tuple.push(dv.getFloat64(offset));
                    offset += 8;
                    break;
                case '?':
                    if (dv.getUint8(offset) === 0) {
                        tuple.push(false);
                    }
                    else {
                        tuple.push(true);
                    }
                    offset += 1;
                    break;
                default:
                    this.redirectError(true, "Unknown or unsupported type ".concat(fmt[i]), (function () { }), onError);
            }
        }
        return tuple;
    };
    Client.prototype.parseString = function (data, offset) {
        if (offset == null) {
            offset = 0;
        }
        return (__range__(0, data.byteLength - offset - 1, true).map(function (i) { return (String.fromCharCode(data.getUint8(offset + i))); })).join('');
    };
    Client.prototype.readString = function (cmd, fn) {
        var _this = this;
        this._readBase('dynamic', cmd, function (data) {
            fn(_this.parseString(data));
        });
    };
    Client.prototype.readJSON = function (cmd, fn) {
        this.readString(cmd, function (str) {
            fn(JSON.parse(str));
        });
    };
    // ------------------------
    //  Drivers
    // ------------------------
    Client.prototype.loadCmds = function (callback) {
        var _this = this;
        this.readJSON(Command(1, { 'id': 1, 'args': [] }), function (data) {
            for (var _i = 0, data_1 = data; _i < data_1.length; _i++) {
                var driver = data_1[_i];
                var dev = new Driver(driver.class, driver.id, driver.functions);
                // dev.show()
                _this.driversList.push(dev);
            }
            callback();
        });
    };
    Client.prototype.getDriver = function (name) {
        for (var _i = 0, _a = this.driversList; _i < _a.length; _i++) {
            var driver = _a[_i];
            if (driver.name === name) {
                return driver;
            }
        }
        throw new Error("Driver ".concat(name, " not found"));
    };
    Client.prototype.getDriverById = function (id) {
        for (var _i = 0, _a = this.driversList; _i < _a.length; _i++) {
            var driver = _a[_i];
            if (driver.id === id) {
                return driver;
            }
        }
        throw new ReferenceError("Driver ID ".concat(id, " not found"));
    };
    return Client;
}());
;
function __range__(left, right, inclusive) {
    var range = [];
    var ascending = left < right;
    var end = !inclusive ? right : ascending ? right + 1 : right - 1;
    for (var i = left; ascending ? i < end : i > end; ascending ? i++ : i--) {
        range.push(i);
    }
    return range;
}
var Imports = /** @class */ (function () {
    function Imports(document) {
        this.importLinks = document.querySelectorAll('link[rel="import"]');
        for (var i = 0; i < this.importLinks.length; i++) {
            var template = this.importLinks[i].import.querySelector('.template');
            var clone = document.importNode(template.content, true);
            var parentId = this.importLinks[i].dataset.parent;
            document.getElementById(parentId).appendChild(clone);
        }
    }
    return Imports;
}());
// LED Blinker
// (c) Koheron
var LedBlinker = /** @class */ (function () {
    function LedBlinker(client) {
        this.client = client;
        this.driver = this.client.getDriver('LedBlinker');
        this.id = this.driver.id;
        this.cmds = this.driver.getCmds();
    }
    LedBlinker.prototype.getLeds = function (cb) {
        this.client.readUint32(Command(this.id, this.cmds['get_leds']), function (value) { cb(value); });
    };
    LedBlinker.prototype.setLed = function (index, status) {
        this.client.send(Command(this.id, this.cmds['set_led'], index, status));
    };
    return LedBlinker;
}());
var LedBlinkerControl = /** @class */ (function () {
    function LedBlinkerControl(document, driver, ledCount) {
        var _this = this;
        this.document = document;
        this.driver = driver;
        this.ledCount = ledCount;
        this.ledBtns = [];
        this.ledBtns = document.getElementsByClassName("led-btn");
        this.ledStatus = [];
        this.initLedTable(this.ledCount, function () {
            _this.initLedButtons();
            _this.update();
        });
    }
    LedBlinkerControl.prototype.initLedTable = function (ledCount, callback) {
        var ledTable = document.getElementById("leds-table");
        var tr0 = document.createElement("tr");
        var th0 = document.createElement("th");
        th0.textContent = "LEDs";
        tr0.appendChild(th0);
        for (var i = 0; i < ledCount; i++) {
            var th = document.createElement("th");
            th.textContent = i.toString();
            th.style.width = "100px";
            th.style.textAlign = "center";
            tr0.appendChild(th);
        }
        ledTable.appendChild(tr0);
        var tr1 = document.createElement("tr");
        var td0 = document.createElement("td");
        td0.textContent = "ON / OFF";
        tr1.appendChild(td0);
        for (var i = 0; i < ledCount; i++) {
            var td = document.createElement("td");
            td.style.width = "100 px";
            td.style.padding = "0px 5px";
            var input = document.createElement("input");
            input.type = "button";
            input.dataset.ledindex = i.toString();
            input.className = "led-btn";
            input.style.width = "100%";
            input.style.boxShadow = "0px 4px 6px 0px #e6e6e6";
            td.appendChild(input);
            tr1.appendChild(td);
        }
        ledTable.appendChild(tr1);
        callback();
    };
    LedBlinkerControl.prototype.initLedButtons = function () {
        var _this = this;
        for (var i = 0; i < this.ledBtns.length; i++) {
            this.ledBtns[i].addEventListener('click', function (event) {
                var index = parseInt(event.currentTarget.dataset.ledindex);
                console.log(index);
                _this.driver.setLed(index, !_this.ledStatus[index]);
            });
        }
    };
    LedBlinkerControl.prototype.update = function () {
        var _this = this;
        this.driver.getLeds(function (value) {
            for (var i = 0; i < 8; i++) {
                _this.ledStatus[i] = (((value >> i) % 2) === 1);
                if (_this.ledStatus[i]) {
                    _this.ledBtns[i].value = 'OFF';
                }
                else {
                    _this.ledBtns[i].value = 'ON';
                }
            }
            ;
            requestAnimationFrame(function () { _this.update(); });
        });
    };
    return LedBlinkerControl;
}());
var App = /** @class */ (function () {
    function App(window, document, ip) {
        var _this = this;
        var client = new Client(ip, 5);
        window.addEventListener('HTMLImportsLoaded', function () {
            client.init(function () {
                _this.imports = new Imports(document);
                _this.driver = new LedBlinker(client);
                _this.control = new LedBlinkerControl(document, _this.driver, 8);
            });
        }, false);
        window.onbeforeunload = function () { client.exit(); };
    }
    return App;
}());
var app = new App(window, document, location.hostname);
