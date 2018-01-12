# PrettyStackTrace

PrettyStackTrace allows Swift command-line programs to print a trace of
execution behaviors when a terminating signal is raised, such as a fatal error.

To use it, wrap your actions in a call to `trace(_:)`. This will
register an entry in the stack trace and (if your process fatal errors) will
print breadcrumbs to stderr describing what was going on when you crashed.

## Installation

PrettyStackTrace is available from the Swift package manager. Add

```swift
.package(url: "https://github.com/llvm-swift/PrettyStackTrace.git", from: "0.0.1")
```

to your Package.swift file to use it.


## Example

```swift
trace("doing first task") {
  print("I'm doing the first task!")
  trace("doing second task") {
    print("I'm doing the second task!")
    fatalError("error on second task!")
  }
}
```

This will output:

```
I'm doing the first task!
I'm doing the second task!
Fatal error: error on second task
Stack dump:
-> While doing second task (func main(), in file file.swift, on line 3)
-> While doing first task (func main(), in file file.swift, on line 1)
```

## Authors

Harlan Haskins ([@harlanhaskins](https://github.com/harlanhaskins))

Robert Widmann ([@CodaFi](https://github.com/CodaFi))

## License

PrettyStackTrace is released under the MIT license, a copy of which is available
in this repository.
