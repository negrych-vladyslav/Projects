import * as grpc from 'grpc';

import { HelloRequest, HelloResponse } from '/usr/src/app/src/proto/greeter/greeter_pb.js';
import { GreeterService, IGreeterServer } from '/usr/src/app/src/proto/greeter/greeter_grpc_pb.js';

class GreeterHandler implements IGreeterServer {
    /**
     * Greet the user nicely
     * @param call
     * @param callback
     */
    sayHello = (call: grpc.ServerUnaryCall<HelloRequest>, callback: grpc.sendUnaryData<HelloResponse>): void => {
        const reply: HelloResponse = new HelloResponse();

        reply.setMessage(`Hello, ${ call.request.getName() }`);

        callback(null, reply);
    };
}

export default {
    service: GreeterService,                // Service interface
    handler: new GreeterHandler(),          // Service interface definitions
};
