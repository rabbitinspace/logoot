//
//  ID.swift
//  Logoot
//
//  Created by Igor Nikitin on 11/2/19.
//  Copyright © 2019 Igor Nikitin. All rights reserved.
//

import Foundation

typealias SiteID = UInt64
typealias Position = [ID]

struct ID: Codable {
    let position: UInt16
    let site: SiteID
}

final class AtomID {
    let position: Position
    let clock: UInt64

    init(position: Position, clock: UInt64) {
        self.position = position
        self.clock = clock
    }
}

final class Atom {
    let id: AtomID
    let char: Unicode.Scalar
    
    init(id: AtomID, char: Unicode.Scalar) {
        self.id = id
        self.char = char
    }
}

enum Order {
    case less
    case equal
    case greater
}

protocol Ordering {
    func order(relativeTo other: Self) -> Order
}

enum OperationKind: Int, Codable {
    case insert
    case remove
}

final class RemoteOperation: Codable {

    let kind: OperationKind
    let position: Position
    let site: SiteID
    let char: Unicode.Scalar

    init(kind: OperationKind, position: Position, site: SiteID, char: Unicode.Scalar) {
        self.kind = kind
        self.position = position
        self.site = site
        self.char = char
    }
}

struct LocalOperation {
    let kind: OperationKind
    let index: Int
    let char: Unicode.Scalar
}

// MARK: - Extensions

extension ID: Ordering {
    func order(relativeTo other: ID) -> Order {
        if position > other.position { return .greater }
        if position < other.position { return .less }
        if site > other.site { return .greater }
        if site < other.site { return .less }
        return .equal
    }
}

extension ID: Equatable {
    static func ==(lhs: ID, rhs: ID) -> Bool {
        return lhs.order(relativeTo: rhs) == .equal
    }
}

extension ID: Comparable {
    static func <(lhs: ID, rhs: ID) -> Bool {
        return lhs.order(relativeTo: rhs) == .less
    }
    
    static func >(lhs: ID, rhs: ID) -> Bool {
        return lhs.order(relativeTo: rhs) == .greater
    }
}

extension AtomID: Ordering {
    func order(relativeTo other: AtomID) -> Order {
        for i in 0 ..< max(position.count, other.position.count) {
            if position.count <= i { return .less }
            if other.position.count <= i { return .greater }
            
            switch position[i].order(relativeTo: other.position[i]) {
            case .less:
                return .less
                
            case .greater:
                return .greater
                
            case .equal:
                continue
            }
        }
        
        return .equal
    }
}

extension Atom: Ordering {
    func order(relativeTo other: Atom) -> Order {
        return id.order(relativeTo: other.id)
    }
}

extension Unicode.Scalar: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(UInt32.self)
        
        self.init(value)!
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
