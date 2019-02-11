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
            Atom(id: AtomID(position: [ID(position: 0, site: 0)], clock: 0), char: "\0"),
            Atom(id: AtomID(position: [ID(position: .max, site: 1)], clock: 1), char: "\0"),
        ]
    }
    
}
