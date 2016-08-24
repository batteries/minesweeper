//
//  SquareButton.swift
//  Minesweeper
//
//  Created by Justin on 8/13/16.
//  Copyright © 2016 jworks. All rights reserved.
//

import UIKit

class SquareButton: UIButton {
    let squareSize:CGFloat
    var square:Square
    
    init(square:Square, squareSize:CGFloat) {
        self.square = square
        self.squareSize = squareSize
        let x = CGFloat(self.square.col) * squareSize
        let y = CGFloat(self.square.row) * squareSize
        let squareFrame = CGRectMake(x, y, squareSize, squareSize)
        super.init(frame: squareFrame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
