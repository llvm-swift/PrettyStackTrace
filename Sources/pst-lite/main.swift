import Foundation
#if os(Linux)
    import Glibc
#endif
import LiteSupport
import Symbolic

/// Finds the named executable relative to the location of the `lite`
/// executable.
func findAdjacentBinary(_ name: String) -> URL? {
  guard let path = SymbolInfo(address: #dsohandle)?.filename else { return nil }
  let siltURL = path.deletingLastPathComponent()
    .appendingPathComponent(name)
  guard FileManager.default.fileExists(atPath: siltURL.path) else { return nil }
  return siltURL
}

/// Runs `lite` looking for `.test` files and executing them.
do {
  let fileCheck = findAdjacentBinary("filecheck")!

  let subs = [
    ("FileCheck", fileCheck.path)
  ]
  let allPassed =
    try runLite(substitutions: subs,
                pathExtensions: ["swift"],
                testDirPath: nil,
                testLinePrefix: "//",
                parallelismLevel: .automatic)
  exit(allPassed ? 0 : -1)
} catch let err as LiteError {
  fputs("error: \(err.message)", stderr)
  exit(-1)
} catch {
#if os(macOS)
  fatalError("unhandled error: \(error)")
#endif
}
