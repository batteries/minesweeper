//
//  Minesweeper.swift
//  Minesweeper
//
//  Created by Justin on 8/11/16.
//  Copyright © 2016 jworks. All rights reserved.
//  Code adopted and modified from makeschool.com and CTCI 6th Edition

import Foundation

class Square {
    var row: Int
    var col: Int
    var number = 0
    var isMine = false
    var isRevealed = false
    var isFlag = false
    
    init(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    func reset() {
        number = 0
        isMine = false
        isRevealed = false
        isFlag = false
    }
    
    func incrementNumber() {
        if !isMine {
            self.number += 1
        }
    }
    
    func setRowCol(row: Int, col: Int) {
        self.row = row
        self.col = col
    }
    
    func getRow() -> Int {
        return self.row
    }
    
    func getCol() -> Int {
        return self.col
    }
    
    func getNumber() -> Int {
        return self.number
    }
    
    func getMine() -> Bool {
        return self.isMine
    }
    
    func setMine(isMine: Bool) {
        self.isMine = isMine
        self.number = -1
    }
    
    func getRevealed() -> Bool {
        return self.isRevealed
    }
    
    func setRevealed(revealed: Bool) {
        isRevealed = revealed
    }
    
    func getFlag() -> Bool {
        return self.isFlag
    }
    
    func setFlag(isFlag: Bool) {
        self.isFlag = isFlag
    }
    
    func isBlank() -> Bool {
        return self.number == 0
    }
    
    func reveal() -> Bool {
        isRevealed = true
        return isMine
    }
    
    func flag() -> Bool {
        if !isRevealed {
            isFlag = !isFlag
        }
        return isFlag
    }
}

class Board {
    let rows: Int
    let cols: Int
    let nBombs: Int
    var numUnrevealed: Int
    var board:[[Square]] = []
    var bombs: [Square] = []
    
    init(rows: Int, cols: Int, nBombs: Int) {
        self.rows = rows
        self.cols = cols
        self.nBombs = nBombs
        self.numUnrevealed = rows * cols - nBombs
        
        initializeBoard()
        
        resetBoard()
        
    }
    
    struct Constants {
        static let deltas = [ // Offsets of 8 surrounding cells
            [-1, -1], [-1, 0], [-1, 1],
            [ 0, -1],          [ 0, 1],
            [ 1, -1], [ 1, 0], [ 1, 1]
        ]
    }
    
    func initializeBoard() {
        for row in 0 ..< self.rows {
            var squareRow:[Square] = []
            for col in 0 ..< self.cols {
                let square = Square(row: row, col: col)
                squareRow.append(square)
            }
            self.board.append(squareRow)
        }
    }
    
    func resetBoard() {
        self.bombs = []
        var remainingBombs = self.nBombs
        for row in 0 ..< self.rows {
            for col in 0 ..< self.cols {
                let square = board[row][col]
                square.reset()
                if placeBomb(square, remainingBombs: remainingBombs) {
                    self.bombs.append(square)
                    remainingBombs -= 1
                }
            }
        }
        self.setNumbers()
    }
    
    func placeBomb(square: Square, remainingBombs: Int) -> Bool {
        let remainingSquares = rows*cols - square.getRow()*cols-square.getCol()
        let bombRandomizer = Int(arc4random_uniform(UInt32(remainingSquares))+1)
        if bombRandomizer <= remainingBombs {
            square.setMine(true)
            return true
        }
        return false
    }
    
    func setNumbers() {
        for bomb in self.bombs {
            for delta in Constants.deltas {
                let r = bomb.getRow() + delta[0]
                let c = bomb.getCol() + delta[1]
                if (inBounds(r, col: c)) {
                    board[r][c].incrementNumber()
                }
            }
        }
    }
    
    func inBounds(row: Int, col: Int) -> Bool {
        return row >= 0 && row < self.rows && col >= 0 && col < self.cols;
    }
    
    func reveal(square: Square) -> Bool {
        if !square.isRevealed && !square.isFlag {
            square.reveal()
            self.numUnrevealed -= 1
            return true
        }
        return false
    }
    
}
