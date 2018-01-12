// RUN: cat %S/../Sources/PrettyStackTrace/PrettyStackTrace.swift %s | swiftc -c -emit-executable -o %t - && %t 2>&1 | %FileCheck %s

// CHECK-DAG: in first task!
// CHECK-DAG: in second task!
// CHECK-DAG: {{[fF]}}atal error: second task failed
// CHECK-DAG: Stack dump
// CHECK-DAG: -> While doing second task
// CHECK-DAG: -> While doing first task
trace("doing first task") {
  print("in first task!")
  trace("doing second task") {
    print("in second task!")
    fatalError("second task failed")
  }
}
