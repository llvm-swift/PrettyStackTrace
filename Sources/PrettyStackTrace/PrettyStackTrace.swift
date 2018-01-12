/// PrettyStackTrace.swift
///
/// Copyright 2018, The LLVMSwift Project.
///
/// This project is released under the MIT license, a copy of which is
/// available in the repository.

import Foundation

/// Represents an entry in a stack trace. Contains information necessary to
/// reconstruct what was happening at the time this function was executed.
private struct TraceEntry: CustomStringConvertible {
  /// A description, in gerund form, of what action was occurring at the time.
  /// For example, "typechecking a node".
  let action: String

  /// The function (from #function) that was being executed.
  let function: StaticString

  /// The line (from #line) that was being executed.
  let line: Int

  /// The file (from #file) that was being executed.
  let file: StaticString

  /// Constructs a string describing the entry, to be printed in order.
  var description: String {
    let base = URL(fileURLWithPath: file.description).lastPathComponent
    return """
           -> While \(action) (func \(function), in file \(base), line \(line))
           """
  }
}

// HACK: This array must be pre-allocated and contains functionally immortal
// C-strings because String may allocate when passed to write(1).
var registeredSignalInfo =
  UnsafeMutableBufferPointer<SigHandler>(start:
    UnsafeMutablePointer.allocate(capacity: killSigs.count),
                                         count: killSigs.count)
var numRegisteredSignalInfo = 0

/// A class managing a stack of trace entries. When a particular thread gets
/// a kill signal, this handler will dump all the entries in the tack trace and
/// end the process.
private class PrettyStackTraceManager {
  struct RawStackEntry {
    let data: UnsafeMutablePointer<Int8>
    let count: Int
  }

  /// Keeps a stack of serialized trace entries in reverse order.
  /// - Note: This keeps strings, because it's not safe to
  ///         construct the strings in the signal handler directly.
  var stack = [RawStackEntry]()

  private let stackDumpMsg: RawStackEntry
  init() {
    let msg = "Stack dump:\n"
    stackDumpMsg = RawStackEntry(data: strndup(msg, msg.count),
                                 count: msg.count)
  }

  /// Pushes the description of a trace entry to the stack.
  func push(_ entry: TraceEntry) {
    let str = "\(entry.description)\n"
    let entry = RawStackEntry(data: strndup(str, str.count),
                              count: str.count)
    stack.insert(entry, at: 0)
  }

  /// Pops the latest trace entry off the stack.
  func pop() {
    guard !stack.isEmpty else { return }
    stack.removeFirst()
  }

  /// Dumps the stack entries to standard error, starting with the most
  /// recent entry.
  func dump(_ signal: Int32) {
    write(STDERR_FILENO, stackDumpMsg.data, stackDumpMsg.count)
    let stackLimit = stack.count
    stack.withUnsafeBufferPointer { buffer in
      var i = 0
      while i < stackLimit {
        let bufItem = buffer[i]
        write(STDERR_FILENO, bufItem.data, bufItem.count)
        i += 1
      }
    }
  }
}

/// Storage for a thread-local context key to get the thread local trace
/// handler.
private var __stackContextKey = pthread_key_t()

/// Creates a key for a thread-local reference to a PrettyStackTraceHandler.
private var stackContextKey: pthread_key_t = {
  pthread_key_create(&__stackContextKey) { ptr in
    let unmanaged = Unmanaged<PrettyStackTraceManager>.fromOpaque(ptr)
    unmanaged.release()
  }
  return __stackContextKey
}()

/// A thread-local reference to a PrettyStackTraceManager.
/// The first time this is created, this will create the handler and register
/// it with `pthread_setspecific`.
private func threadLocalHandler() -> PrettyStackTraceManager {
  guard let specificPtr = pthread_getspecific(stackContextKey) else {
    let handler = PrettyStackTraceManager()
    let unmanaged = Unmanaged.passRetained(handler)
    pthread_setspecific(stackContextKey, unmanaged.toOpaque())
    return handler
  }
  let unmanaged = Unmanaged<PrettyStackTraceManager>.fromOpaque(specificPtr)
  return unmanaged.takeUnretainedValue()
}

/// A set of signals that would normally kill the program. We handle these
/// signals by dumping the pretty stack trace description.
let killSigs = [
  SIGILL, SIGABRT, SIGTRAP, SIGFPE,
  SIGBUS, SIGSEGV, SIGSYS, SIGQUIT
]

/// Needed because the type `sigaction` conflicts with the function `sigaction`.
typealias SigAction = sigaction

/// A wrapper that associates a signal handler with the number it handles.
struct SigHandler {
  /// The signal action, called when the handler is called.
  var action: SigAction

  /// The signal number this will fire on.
  var signalNumber: Int32
}

/// Registers the pretty stack trace signal handlers.
private func registerHandler(signal: Int32) {
  var newHandler = SigAction()
  newHandler.__sigaction_u.__sa_handler = { signalNumber in
    unregisterHandlers()

    // Unblock all potentially blocked kill signals
    var sigMask = sigset_t()
    sigfillset(&sigMask)
    sigprocmask(SIG_UNBLOCK, &sigMask, nil)

    threadLocalHandler().dump(signalNumber)
    exit(signalNumber)
  }
  newHandler.sa_flags = SA_NODEFER | SA_RESETHAND | SA_ONSTACK
  sigemptyset(&newHandler.sa_mask)

  var handler = SigAction()
  if sigaction(signal, &newHandler, &handler) != 0 {
    let sh = SigHandler(action: handler, signalNumber: signal)
    registeredSignalInfo[numRegisteredSignalInfo] = sh
  }
}

/// Unregisters all pretty stack trace signal handlers.
private func unregisterHandlers() {
  var i = 0
  while i < killSigs.count {
    sigaction(registeredSignalInfo[i].signalNumber,
              &registeredSignalInfo[i].action, nil)
    i += 1
  }

  // HACK: Must leak the old registerdSignalInfo because we cannot safely
  //       free inside a signal handler.
  // cannot: free(registeredSignalInfo)
  numRegisteredSignalInfo = 0
}

/// A reference to the previous alternate stack, if any.
private var oldAltStack = stack_t()

/// The current stack pointer for this alternate stack.
private var newAltStackPointer: UnsafeMutableRawPointer?

/// Sets up an alternate stack and registers all signal handlers with the
/// system.
private let __setupStackOnce: Void = {
  let altStackSize = UInt(MINSIGSTKSZ) + (UInt(64) * 1024)

  /// Make sure we're not currently executing on an alternate stack already.
  guard sigaltstack(nil, &oldAltStack) == 0 else { return }
  guard oldAltStack.ss_flags & SS_ONSTACK == 0 else { return }
  guard oldAltStack.ss_sp == nil || oldAltStack.ss_size < altStackSize else {
    return
  }

  /// Create a new stack struct and save the stack pointer.
  var stack = stack_t()
  stack.ss_size = altStackSize
  stack.ss_sp = malloc(Int(altStackSize))
  newAltStackPointer = stack.ss_sp

  /// Register the system signal routines to use our stack pointer.
  if sigaltstack(&stack, &oldAltStack) != 0 {
    free(stack.ss_sp)
  }

  /// Register all known signal handlers.
  for sig in killSigs {
    registerHandler(signal: sig)
  }
}()

/// Registers an action to the pretty stack trace to be printed if there is a
/// fatal system error.
///
/// - Parameters:
///   - action: The action being executed during the stack frame. For example,
///             "typechecking an AST node".
///   - actions: A closure containing the actual actions being performed.
/// - Returns: The result of calling the provided `actions` closure.
/// - Throws: Whatever is thrown by the `actions` closure.
public func trace<T>(_ action: String, file: StaticString = #file,
                     function: StaticString = #function, line: Int = #line,
                     actions: () throws -> T) rethrows -> T {
  _ = __setupStackOnce
  let h = threadLocalHandler()
  h.push(TraceEntry(action: action, function: function, line: line, file: file))
  defer { h.pop() }
  return try actions()
}

