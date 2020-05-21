//
//  ReuseIdentifying.swift
//  Tour3Systems
//
//  Created by Viorel Porumbescu on 08/12/2018.
//  Copyright © 2018 Viorel Porumbescu. All rights reserved.
//

import Foundation
import Cocoa

protocol ReuseIdentifying {
   static var reuseIdentifier: String { get }
}

extension ReuseIdentifying {
    static var reuseIdentifier: String {
        return String(describing: self)
    }

}

extension NSTableCellView: ReuseIdentifying {}


extension NSTableView {
    func makeCellView<CellClass: NSTableCellView>(of  cellType: CellClass.Type,
                                                         configure: ((CellClass) -> Void) = { _ in }) -> NSTableCellView {

        let cell = makeView(withIdentifier: NSUserInterfaceItemIdentifier.init(cellType.reuseIdentifier), owner: self)
        if let typedCell = cell as? CellClass {
            configure(typedCell)
            return typedCell
        }

        return NSTableCellView()
    }
}
