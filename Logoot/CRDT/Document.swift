//
//  Document.swift
//  Logoot
//
//  Created by Igor Nikitin on 11/2/19.
//  Copyright © 2019 Igor Nikitin. All rights reserved.
//

import Foundation

final class Document {
    
    private let site: SiteID
    private var clock: [SiteID: UInt64]
    
    private var content: [Atom]
    
    init(site: SiteID) {
        self.site = site
        self.clock = [site: 2]
        
        self.content = [
            Atom(id: AtomID(position: [ID(position: 0, site: site)], clock: 0), char: "\0"),
            Atom(id: AtomID(position: [ID(position: .max, site: site)], clock: 1), char: "\0"),
        ]
    }
    
    @discardableResult
    func insert(_ char: Unicode.Scalar, at index: Int) -> RemoteOperation {
        defer { assert(content.count >= 2) }
        
        let position = generatePosition(
            previous: content[index].id.position,
            next: content[index + 1].id.position,
            site: site
        )
        
        let atom = Atom(id: atomID(with: position, for: site), char: char)
        content.insert(atom, at: index + 1)
        return RemoteOperation(kind: .insert, position: atom.id.position, site: site, char: atom.char)
    }
    
    @discardableResult
    func remove(at index: Int) -> RemoteOperation {
        defer { assert(content.count >= 2) }
        
        let atom = content.remove(at: index + 1)
        return RemoteOperation(kind: .remove, position: atom.id.position, site: site, char: atom.char)
    }
    
    func apply(_ operation: RemoteOperation) -> LocalOperation? {
        switch operation.kind {
        case .insert:
            let id = atomID(with: operation.position, for: operation.site)
            let atom = Atom(id: id, char: operation.char)
            let index = content.insertionIndex(of: atom)
            
            content.insert(atom, at: index)
            return LocalOperation(kind: .insert, index: index - 1, char: operation.char)
            
        case .remove:
            let id = atomID(with: operation.position, for: operation.site)
            if let index = content.firstIndex(where: { $0.id.order(relativeTo: id) == .equal }) {
                content.remove(at: index)
                return LocalOperation(kind: .remove, index: index - 1, char: operation.char)
            }
        }
        
        return nil
    }
    
    private func generatePosition(previous: Position, next: Position, site: SiteID) -> Position {
        var position = Position()
        var offset = 0
        
    loop: while true {
            let previousHead = previous[likelyAt: offset] ?? content.first!.id.position[0]
            let nextHead = next[likelyAt: offset] ?? content.last!.id.position[0]
            
            let (previousPos, previousSite) = (previousHead.position, previousHead.site)
            let nextPos = nextHead.position
            
            switch previousHead.order(relativeTo: nextHead) {
            case .less:
                let diff = nextPos - previousPos
                if diff > 1 {
                    let random = UInt16.random(in: previousPos + 1 ... nextPos - 1)
                    position.append(ID(position: random, site: site))
                    break loop
                } else if diff == 1 && site > previousSite {
                    position.append(ID(position: previousPos, site: site))
                    break loop
                } else {
                    position.append(previousHead)
                }
                
            case .equal:
                position.append(previousHead)
                
            case .greater:
                assertionFailure("'next' position was less that 'previous' position")
            }
            
            offset += 1
        }
        
        return position
    }
    
    private func atomID(with position: Position, for site: SiteID) -> AtomID {
        var clock = self.clock[site] ?? 0
        defer { clock = clock &+ 1; self.clock[site] = clock }
        
        return AtomID(position: position, clock: clock)
    }
}

extension Document {
    var string: String {
        let scalars = String.UnicodeScalarView(content[1 ..< content.count - 1].map { $0.char })
        return String(scalars)
    }
}

// MARK: - Private extensions

private extension Array {
    subscript(likelyAt index: Index) -> Element? {
        guard index < endIndex else { return nil }
        guard index >= startIndex else { return nil }
        
        return self[index]
    }
}

private extension Array where Element: Ordering {
    // TODO: binary search
    func insertionIndex(of element: Element) -> Index {
        for i in startIndex ..< endIndex {
            if self[i].order(relativeTo: element) != .less {
                return i
            }
        }
        
        return endIndex
    }
}
