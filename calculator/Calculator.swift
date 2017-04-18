//
//  Calculator.swift
//  calculator
//
//  Created by Shin Park on 4/10/17.
//  Copyright © 2017 shinDev. All rights reserved.
//

import UIKit

class Calculator: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var userIsInTheMiddleOfTypingDecimal = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit == "." {
                if userIsInTheMiddleOfTypingDecimal == false {
                    display.text = textCurrentlyInDisplay + digit
                    userIsInTheMiddleOfTypingDecimal = true
                }
            } else {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            if digit == "." {
                if userIsInTheMiddleOfTypingDecimal == false {
                    display.text = "0."
                    userIsInTheMiddleOfTypingDecimal = true
                    userIsInTheMiddleOfTyping = true
                }
            } else {
                display.text = digit
                userIsInTheMiddleOfTyping = true
            }
        }
    }
    
    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            if sender.currentTitle == "C" {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
                userIsInTheMiddleOfTypingDecimal = false
            }
            if sender.currentTitle == "⁺∕₋" {
                userIsInTheMiddleOfTyping = true
                userIsInTheMiddleOfTypingDecimal = true
            } else {
                userIsInTheMiddleOfTyping = false
                userIsInTheMiddleOfTypingDecimal = false
            }
        }
        if let mathematicalSymbol = sender.currentTitle {
            if mathematicalSymbol == "C" {
                display.text = "0"
                userIsInTheMiddleOfTyping = false
                userIsInTheMiddleOfTypingDecimal = false
            }
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
    }
}










