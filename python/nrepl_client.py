from bencode import encode, decode
from uuid import uuid1
import nrepl_transport
import os
import sys
import argparse

sends_in_progress = {}


# omitting messageLogPrinter

def create_uuid():
  return uuid1().urn[9:]

# XXX unused, no keepalive file is used currently
def writePidFile():
    pid = str(os.getpid())
    f = open(os.path.expanduser('~') + '/test.pid', 'w')

def noop():
  pass

# writePidFile()

# print(create_uuid())
# print(decode("d2:id41:fireplace-mikepjb-mini.local-1485517877-92:op5:close7:session36:dd6f2c91-2c8d-447e-a487-ecce089c675de"))
# print(encode({b'op': b'eval', b'session': create_uuid(), b'id': b'test-id'}))

# print(decode("d2:id41:fireplace-mikepjb-mini.local-1485526010-12:op5:clonee"))
# print(decode("d2:id41:fireplace-mikepjb-mini.local-1485526010-22:op8:describe7:session36:cc56426d-bb3d-41d3-adee-00347c860dcf8:verbose?i1ee"))
# print(decode("d4:code78:[(System/getProperty \"path.separator\") (System/getProperty \"fake.class.path\")]2:id41:fireplace-mikepjb-mini.local-1485526010-32:op4:evale"))
# print(decode("d2:id41:fireplace-mikepjb-mini.local-1485526010-42:op5:clonee"))
# print(decode("d2:id41:fireplace-mikepjb-mini.local-1485526010-52:op8:describe7:session36:5ae57b8c-c51f-4c84-97d3-6ba5c166e4828:verbose?i1ee"))
# print(decode("d4:code78:[(System/getProperty \"path.separator\") (System/getProperty \"fake.class.path\")]2:id41:fireplace-mikepjb-mini.local-1485526010-62:op4:evale"))
# print(decode("d2:id41:fireplace-mikepjb-mini.local-1485526010-72:op5:clone7:session36:cc56426d-bb3d-41d3-adee-00347c860dcfe"))
# print(decode("d4:code167:(when-not (find-ns 'watermarker.core) (try (#'clojure.core/load-one 'watermarker.core true true) (catch Exception e (when-not (find-ns 'watermarker.core) (throw e)))))2:id41:fireplace-mikepjb-mini.local-1485526010-82:ns4:user2:op4:eval7:session36:c8107590-c2fa-4c10-933b-4aa462481846e"))
# print(decode("d2:id41:fireplace-mikepjb-mini.local-1485526010-92:op5:close7:session36:c8107590-c2fa-4c10-933b-4aa462481846e"))
# print(decode("d4:code9:(+ 40 80)2:id42:fireplace-mikepjb-mini.local-1485526010-102:ns16:watermarker.core2:op4:eval7:session36:cc56426d-bb3d-41d3-adee-00347c860dcfe"))

# seems to cycle in a 'clone', 'describe', 'eval' sequence of calls
# how is load file different?

# d4:code9:(+ 40 40)2:id42:fireplace-mikepjb-mini.local-1485524328-102:ns16:watermarker.core2:op4:eval7:session36:4f2bd319-1c9e-4e51-8ae4-bf1fa1b76ea4e

payload_clone = encode({b'op': b'clone', b'id': b'test-id'}).decode("utf-8")
# payload_eval = encode({b'op': b'eval', b'code' : b'(def rt "hello")', b'session': create_uuid(), b'id': b'test-id'}).decode("utf-8")
# payload_describe = encode({b'op': b'describe', b'id': b'test-id', b'session': b'b41be33e-9622-437f-8165-5d607839772c', b'verbose?': 1}).decode("utf-8")
# payload_eval = encode({b'op': b'eval', b'code' : b'(def rt "hello")', b'session': b'b41be33e-9622-437f-8165-5d607839772c', b'id': b'test-id'}).decode("utf-8")

payload_eval = encode({b'op': b'eval', b'code' : b'(def rt "hello")', b'session': b'b41be33e-9622-437f-8165-5d607839772c', b'id': b'test-id'}).decode("utf-8")

def create_nrepl_eval_payload(code, session_id):
  print(code)
  print(encode({b'op': b'eval',
    b'code' : code.encode('utf-8'),
    b'session': session_id.encode('utf-8'),
    b'id': b'test-id'}).decode("utf-8"))
  return encode({b'op': b'eval',
    b'code' : code.encode('utf-8'),
    b'session': session_id.encode('utf-8'),
    b'id': b'test-id'}).decode("utf-8")

terminators = ['done']
selectors = {'id': 'test-id'}


if __name__ == "__main__":
  command = ' '.join(sys.argv[1:])
  unquoted_command = command[1:-1]
  new_session_id = nrepl_transport.dispatch("127.0.0.1", 9999, noop, None, "call", payload_clone, terminators, selectors)[0]['new-session']
  print(nrepl_transport.dispatch(
    "127.0.0.1",
    9999,
    noop,
    None,
    "call",
    create_nrepl_eval_payload(unquoted_command, new_session_id),
    terminators,
    selectors))
