//
//  BoardViewController.swift
//  Minesweeper
//
//  Created by Justin on 8/11/16.
//  Copyright © 2016 jworks. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController {

    @IBOutlet weak var bombsLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var boardView: UIView!
    let rows = 10
    let cols = 10
    let nBombs = 10
    var board: Board!
    var squareButtons: [[SquareButton]] = []
    var flagMode = false
    var oneSecondTimer: NSTimer?
    var gameLost = false
    var gameStarted = false {
        didSet {
            if gameStarted {
                oneSecondTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(BoardViewController.incrementTime), userInfo: nil, repeats: true)
            }
            else {
                oneSecondTimer?.invalidate()
                oneSecondTimer = nil
            }
        }
    }
    
    var bombsLeft: Int! {
        didSet {
            self.bombsLabel.text = "Bombs Left: \(bombsLeft)"
        }
    }
    
    var timeTaken = 0 {
        didSet {
            self.timeLabel.text = "Time: \(timeTaken)"
        }
    }
    
    var squaresRemaining: Int! {
        didSet {
            print(squaresRemaining)
            if squaresRemaining == 0 && !gameLost {
                win()
            }
        }
    }
    
    struct Constants {
        static let deltas = [ // Offsets of 8 surrounding cells
            [-1, -1], [-1, 0], [-1, 1],
            [ 0, -1],          [ 0, 1],
            [ 1, -1], [ 1, 0], [ 1, 1]
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initializeBoard()
        resetBoard()
    }

    func initializeBoard() {
        board = Board(rows: rows, cols: cols, nBombs: nBombs)
        
        for row in 0 ..< rows {
            var squareButtonRow: [SquareButton] = []
            for col in 0 ..< cols {
                let square = board.board[row][col]
                let squareSize = self.boardView.frame.width /
                    CGFloat(max(rows, cols))
                let squareButton = SquareButton(square: square,
                                                squareSize: squareSize);
                squareButton.addTarget(
                    self, action:
                    #selector(BoardViewController.squareButtonTapped(_:)),
                    forControlEvents: .TouchUpInside)
                self.boardView.addSubview(squareButton)
                squareButtonRow.append(squareButton)
            }
            squareButtons.append(squareButtonRow)
        }
    }

    @IBAction func newGamePressed(sender: UIButton) {
        print("New Game Pressed")
        resetBoard()
    }
    
    func resetBoard() {
        gameStarted = false
        gameLost = false
        bombsLeft = nBombs
        timeTaken = 0
        squaresRemaining = rows * cols
        
        self.board.resetBoard()
        for squareButtonRow in squareButtons {
            for squareButton in squareButtonRow {
                squareButton.setBackgroundImage(UIImage(named: "hidden"), forState: .Normal)
                squareButton.setTitle("", forState: .Normal)
            }
        }
    }
    
    func incrementTime() {
        timeTaken += 1
    }
    
    @IBAction func flagToggled(sender: AnyObject) {
        flagMode = !flagMode
    }
    
    func squareButtonTapped(sender: SquareButton) {
        if !gameStarted {
            gameStarted = true
        }
        if !gameLost && !sender.square.getRevealed() {
            if !flagMode && !sender.square.getFlag(){
                revealSquare(sender)
            }
            else {
                flag(sender)
            }
        }
        else if sender.square.getRevealed() {
            revealNeighbors(sender)
        }
    }
    
    func revealSquare(squareButton: SquareButton) {
        if !gameLost {
            squaresRemaining! -= 1
            let number = squareButton.square.getNumber()
            if number > 0 {
                squareButton.setTitle("\(number)", forState: .Normal)
            }
            
            squareButton.square.setRevealed(true)
            if squareButton.square.getMine() {
                squareButton.setBackgroundImage(UIImage(named: "boom"), forState: .Normal)
                lose()
            }
            else {
                squareButton.setBackgroundImage(UIImage(named: "revealed"), forState: .Normal)
                squareButton.square.setRevealed(true)
                if number == 0 {
                    expandBlank(squareButton)
                }
            }
        }
        else {
            if !squareButton.square.getMine() && squareButton.square.getFlag() {
                squareButton.setBackgroundImage(UIImage(named: "wrongFlag"), forState: .Normal)
            }

            else if squareButton.square.getMine() && !squareButton.square.getFlag() {
                squareButton.setBackgroundImage(UIImage(named: "mine"), forState: .Normal)
            }
        }
    }
    
    func expandBlank(squareButton: SquareButton) {
        var expandStack = [squareButton]
        
        while !expandStack.isEmpty {
            let current = expandStack.popLast()!
            for delta in Constants.deltas {
                let r = current.square.getRow() + delta[0]
                let c = current.square.getCol() + delta[1]
                if (inBounds(r, col: c)) {
                    let neighbor = squareButtons[r][c]
                    if !neighbor.square.getRevealed(){
                        revealSquare(neighbor)
                        if neighbor.square.isBlank() {
                            expandStack.append(neighbor)
                        }
                    }
                }
            }
        }
    }
    
    func revealNeighbors(squareButton: SquareButton) {
        // First count neighboring flags
        
        var numFlags = 0
        
        for delta in Constants.deltas {
            let r = squareButton.square.getRow() + delta[0]
            let c = squareButton.square.getCol() + delta[1]
            if (inBounds(r, col: c)) {
                let neighbor = squareButtons[r][c]
                if !neighbor.square.getRevealed(){
                    if neighbor.square.getFlag() {
                        numFlags += 1
                    }
                }
            }
        }
        
        // If number == neighboring flags, then reveal neighbors
        
        if numFlags == squareButton.square.getNumber() {
            for delta in Constants.deltas {
                let r = squareButton.square.getRow() + delta[0]
                let c = squareButton.square.getCol() + delta[1]
                if (inBounds(r, col: c)) {
                    let neighbor = squareButtons[r][c]
                    if !neighbor.square.getRevealed() && !neighbor.square.getFlag(){
                        revealSquare(neighbor)
                    }
                }
            }
        }
    }
    
    
    func flag(squareButton: SquareButton) {
        if squareButton.square.getRevealed() {
            print("Error: Flagging a revealed square")
        }
        if !squareButton.square.getFlag() {
            squareButton.square.setFlag(true)
            squareButton.setBackgroundImage(UIImage(named: "flag"), forState: .Normal)
            if squareButton.square.getMine() {
                squaresRemaining! -= 1
                bombsLeft! -= 1
            }
        }
        else {
            squareButton.square.setFlag(false)
            squareButton.setBackgroundImage(UIImage(named: "hidden"), forState: .Normal)
            if squareButton.square.getMine() {
                squaresRemaining! += 1
                bombsLeft! += 1
            }
        }
    }
    
    
    func win() {
        print("won")
        gameStarted = false
    }
    
    func lose() {
        print("lost")
        gameStarted = false
        gameLost = true
        
        for squareButtonRow in squareButtons {
            for squareButton in squareButtonRow {
                if !squareButton.square.getRevealed() {
                    revealSquare(squareButton)
                }
            }
        }
    }
    
    func inBounds(row: Int, col: Int) -> Bool {
        return row >= 0 && row < self.rows && col >= 0 && col < self.cols;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

