"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const greeter_pb_js_1 = require("./gRPC/src/proto/greeter/greeter_pb.js");
const greeter_grpc_pb_js_1 = require("./src/proto/greeter/greeter_grpc_pb.js");
class GreeterHandler {
    constructor() {
        /**
         * Greet the user nicely
         * @param call
         * @param callback
         */
        this.sayHello = (call, callback) => {
            const reply = new greeter_pb_js_1.HelloResponse();
            reply.setMessage(`Hello, ${call.request.getName()}`);
            callback(null, reply);
        };
    }
}
exports.default = {
    service: greeter_grpc_pb_js_1.GreeterService,
    handler: new GreeterHandler(), // Service interface definitions
};
//# sourceMappingURL=greeter.js.map