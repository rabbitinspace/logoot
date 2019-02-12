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
    
    func insert(_ char: Unicode.Scalar, at index: Int) {
        defer { assert(content.count >= 2) }
        
        let position = generatePosition(
            previous: content[index].id.position,
            next: content[index + 1].id.position,
            site: site
        )
        
        let atom = Atom(id: atomID(with: position, for: site), char: char)
        content.insert(atom, at: index + 1)
    }
    
    func remove(at index: Int) {
        defer { assert(content.count >= 2) }
        
        content.remove(at: index + 1)
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
