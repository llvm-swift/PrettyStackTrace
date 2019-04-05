// RUN: cat %S/../Sources/PrettyStackTrace/PrettyStackTrace.swift %s | swiftc -c -emit-executable -o %t - && %t 2>&1 | cat

func overflow() {
  print("", terminator: "")
  overflow()
}

// CHECK-DAG: in first task!
// CHECK-DAG: in second task!
// CHECK-DAG: Stack dump
// CHECK-DAG:   1. While doing second task
// CHECK-DAG:   2. While doing first task
trace("doing first task") {
  print("in first task!")
  trace("doing second task") {
    print("in second task!")
    overflow()
  }
}
