from bencode import encode, decode
from uuid import uuid1
import nrepl_transport
import os
import sys
import re
import argparse

# TODO create unique ids instead of using test-id everytime
# TODO vim-link output is taken from transport.py println - refactor to strip ansi colour sequences
# TODO if exception/multiline copen instead of echom?

def create_uuid():
  return uuid1().urn[9:]

def noop():
  pass

def create_nrepl_eval_payload(code, session_id):
  payload = encode({
    b'op': b'eval',
    b'code': code.encode('utf-8'),
    b'session': session_id.encode('utf-8'),
    b'id': b'test-id'
    }).decode("utf-8")
  return payload

def close_session(session_id):
  payload = encode({b'op': b'close',
    b'session': session_id.encode('utf-8'),
    b'id': b'test-id'}).decode("utf-8")
  nrepl_transport.dispatch(
      "127.0.0.1",
      9999,
      noop,
      None,
      "call",
      payload_clone,
      terminators,
      selectors)[0]['new-session']

terminators = ['done']
selectors = {'id': 'test-id'}
payload_clone = encode({b'op': b'clone', b'id': b'test-id'}).decode("utf-8")

if __name__ == "__main__":
  command = ' '.join(sys.argv[1:])
  unquoted_command = command[1:-1]
  new_session_id = nrepl_transport.dispatch("127.0.0.1", 9999, noop, None, "call", payload_clone, terminators, selectors)[0]['new-session']
  nrepl_transport.dispatch(
    "127.0.0.1",
    9999,
    noop,
    None,
    "call",
    create_nrepl_eval_payload(unquoted_command, new_session_id),
    terminators,
    selectors)
