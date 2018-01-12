// RUN: %swift %s 2>&1 | %FileCheck %s

import Foundation
import PrettyStackTrace

// CHECK-DAG: in first task!
// CHECK-DAG: about to raise!
// CHECK-DAG: Terminating app due to uncaught exception 'NSGenericException', reason: 'You failed'
// CHECK-DAG: Stack dump:
// CHECK-DAG: -> While raising an exception
// CHECK-DAG: -> While doing first task
trace("doing first task") {
  print("in first task!")
  trace("raising an exception") {
    print("about to raise!")
    let exception = NSException(name: .genericException, reason: "You failed")
    exception.raise()
  }
}
