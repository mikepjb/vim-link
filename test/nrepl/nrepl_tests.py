import sys
import os

dir_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(dir_path + '/../../nrepl')

import nrepl_client

def test_equality(test_name, method_output, expected_output):
  print(test_name)
  if method_output != expected_output:
    exit(1)

test_equality("Testing basic eval payload generation",
    nrepl_client.create_nrepl_eval_payload('hello', 'test-id'),
    'd4:code5:hello2:id7:test-id2:op4:eval7:session7:test-ide')
