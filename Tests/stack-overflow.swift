// RUN: %swift %s 2>&1 | %FileCheck %s

import PrettyStackTrace

func overflow() {
  print("", terminator: "")
  overflow()
}

// CHECK-DAG: in first task!
// CHECK-DAG: in second task!
// CHECK-DAG: Stack dump
// CHECK-DAG: -> While doing second task
// CHECK-DAG: -> While doing first task
trace("doing first task") {
  print("in first task!")
  trace("doing second task") {
    print("in second task!")
    overflow()
  }
}
