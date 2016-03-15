// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//
//  XCTimeUtilities.swift
//  Some simple functions for working with "time intervals".
//

#if os(Linux) || os(FreeBSD)
    import Glibc
    import Foundation
#else
    import Darwin
    import SwiftFoundation
#endif

/// Returns the number of seconds since the reference time as a Double.
private func currentTimeIntervalSinceReferenceTime() -> NSTimeInterval {
    var tv = timeval()
    let currentTime = withUnsafeMutablePointer(&tv, { (t: UnsafeMutablePointer<timeval>) -> NSTimeInterval in
        gettimeofday(t, nil)
        return NSTimeInterval(t.pointee.tv_sec) + NSTimeInterval(t.pointee.tv_usec) / 1000000.0
    })
    return currentTime
}

/// Execute the given block and return the time spent during execution
internal func measureTimeExecutingBlock(@noescape block: () -> Void) -> NSTimeInterval {
    let start = currentTimeIntervalSinceReferenceTime()
    block()
    let end = currentTimeIntervalSinceReferenceTime()

    return end - start
}

/// Returns a string version of the given time interval rounded to no more than 3 decimal places.
internal func printableStringForTimeInterval(timeInterval: NSTimeInterval) -> String {
    return String(round(timeInterval * 1000.0) / 1000.0)
}
