# Note for these tests!

These tests all use `CHECK-DAG` in their FileCheck tests because input 
redirection using `2>&1` leads to non-deterministically ordered input when piped.
