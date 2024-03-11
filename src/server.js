import {
  Fr
} from '@aztec/aztec.js';
import bodyParser from "body-parser";
import express from "express";
import { JSONRPCServer } from "json-rpc-2.0";

const PORT = 5555;
const app = express();
app.use(bodyParser.json());

const server = new JSONRPCServer();

server.addMethod("getSqrt", async (params) => {
  const values = params[0].Array.map(({ inner }) => {
    return { inner: `${Math.sqrt(parseInt(inner, 16))}` };
  });
  return { values: [{ Array: values }] };
});

app.post("/", (req, res) => {
 const jsonRPCRequest = req.body;
 server.receive(jsonRPCRequest).then((jsonRPCResponse) => {
  if (jsonRPCResponse) {
   res.json(jsonRPCResponse);
  } else {
   res.sendStatus(204);
  }
 });
});

app.listen(PORT, () => {
    console.log(`Oracle running at port: ${PORT}`)
})

export function toACVMField(
  value) {
  let buffer;
  if (Buffer.isBuffer(value)) {
    buffer = value;
  } else if (typeof value === 'boolean' || typeof value === 'number' || typeof value === 'bigint') {
    buffer = new Fr(value).toBuffer();
  } else if (typeof value === 'string') {
    buffer = Fr.fromString(value).toBuffer();
  } else {
    buffer = value.toBuffer();
  }
  return `0x${adaptBufferSize(buffer).toString('hex')}`;
}

function adaptBufferSize(originalBuf) {
  const buffer = Buffer.alloc(Fr.SIZE_IN_BYTES);
  if (originalBuf.length > buffer.length) {
    throw new Error('Buffer does not fit in field');
  }
  originalBuf.copy(buffer, buffer.length - originalBuf.length);
  return buffer;
}
