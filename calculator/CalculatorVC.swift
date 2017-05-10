//
//  CalculatorVC.swift
//  calculator
//
//  Created by Shin Park on 4/10/17.
//  Copyright © 2017 shinDev. All rights reserved.
//

import UIKit

class CalculatorVC: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var userIsInTheMiddleOfTyping = false
    var userIsInTheMiddleOfTypingDecimal = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        let textCurrentlyInDisplay = display.text!
        if userIsInTheMiddleOfTyping {
            if digit != "." {
                display.text = textCurrentlyInDisplay + digit
            } else {
                if userIsInTheMiddleOfTypingDecimal == false {
                    display.text = textCurrentlyInDisplay + digit
                } else {
                    display.text = textCurrentlyInDisplay
                }
                userIsInTheMiddleOfTypingDecimal = true
            }
        } else {
            if digit != "." {
                if userIsInTheMiddleOfTypingDecimal {
                    display.text = textCurrentlyInDisplay + digit
                } else {
                    display.text = digit
                }
                userIsInTheMiddleOfTyping = true
            } else {
                if userIsInTheMiddleOfTypingDecimal == false {
                    display.text = "0."
                }
                userIsInTheMiddleOfTypingDecimal = true
            }
        }
    }
    
    var displayValue: Double? {
        get {
            if let text = display.text, let value = NumberFormatter().number(from: text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 6
            display.text = formatter.string(for: newValue)
            let negativeValue = formatter.string(for: abs(newValue!))
            if (newValue! > 0.0 && newValue! < 1) {
                display.text = "0" + display.text!
            }
            if (newValue! < 0.0 && newValue! > -1) {
                display.text = "-0" + negativeValue!
            }
        }
    }
    
    @IBAction func backspace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            display.text!.remove(at: display.text!.index(before: display.text!.endIndex))
            if display.text == "0" || display.text!.isEmpty {
                displayValue = 0
                userIsInTheMiddleOfTyping = false
                userIsInTheMiddleOfTypingDecimal = false
            }
        }
    }
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTypingDecimal = false
            if sender.currentTitle == "C" {
                display.text = "0"
                userIsInTheMiddleOfTypingDecimal = false
            }
            if sender.currentTitle == "⁺∕₋" {
                userIsInTheMiddleOfTyping = true
                userIsInTheMiddleOfTypingDecimal = true
            }
        }
        userIsInTheMiddleOfTyping = false
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
            if let result = brain.result {
                displayValue = result
            }
            if mathematicalSymbol == "C" {
                display.text = "0"
                descriptionLabel.text = " "
            }
        }
        descriptionLabel.text = brain.description
        if (descriptionLabel.text != " ") {
            if (brain.resultIsPending) {
                descriptionLabel.text! += "..."
            } else {
                descriptionLabel.text! += " ="
            }
        } else {
            displayValue = 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brain.addUnaryOperation(named: "✅") { [weak weakSelf = self] in
            weakSelf?.display.textColor = UIColor.green
            return sqrt($0)
        }
    }
    
    private func showSizeClasses() {
        if !userIsInTheMiddleOfTyping {
            display.textAlignment = .center
            display.text = "width " + traitCollection.horizontalSizeClass.description + " height "
                 + traitCollection.verticalSizeClass.description
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showSizeClasses()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { coordinator in
            self.showSizeClasses()
        }, completion: nil)
    }
}

extension UIUserInterfaceSizeClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compact: return "Compact"
        case .regular: return "Regular"
        case .unspecified: return "??"
        }
    }
}









