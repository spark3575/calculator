//
//  CalculatorBrain.swift
//  calculator
//
//  Created by Shin Park on 4/10/17.
//  Copyright © 2017 shinDev. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    private var pendingBinaryOperation: PendingBinaryOperation?
    var description = " "
    private var previousDescription = ""
    private var previousRandom = ""
    private var variable = ""
    
    private enum Operation {
        case constant(Double)
        case randomNumberOperation(() -> UInt32)
        case unaryOperation((Double) -> Double)
        case binaryOperation((Double,Double) -> Double)
        case equals
        case clear
    }
    
    private var operations: Dictionary<String,Operation> = [
        "rand" : Operation.randomNumberOperation(arc4random),
        "π" : Operation.constant(Double.pi),
        "e" : Operation.constant(M_E),
        "√" : Operation.unaryOperation(sqrt),
        "sin" : Operation.unaryOperation(sin),
        "cos" : Operation.unaryOperation(cos),
        "tan" : Operation.unaryOperation(tan),
        "eˣ" : Operation.unaryOperation(exp),
        "ln" : Operation.unaryOperation(log),
        "log" : Operation.unaryOperation(log10),
        "⁺∕₋" : Operation.unaryOperation({ -$0 }),
        "x²" : Operation.unaryOperation({ $0 * $0 }),
        "×" : Operation.binaryOperation({ $0 * $1 }),
        "÷" : Operation.binaryOperation({ $0 / $1 }),
        "+" : Operation.binaryOperation({ $0 + $1 }),
        "−" : Operation.binaryOperation({ $0 - $1 }),
        "=" : Operation.equals,
        "C" : Operation.clear
    ]
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .randomNumberOperation(let function):
                let formatter = NumberFormatter()
                formatter.minimumFractionDigits = 0
                formatter.maximumFractionDigits = 6
                accumulator = Double(function())
                let stringForRandom = formatter.string(for: accumulator)!
                if resultIsPending {
                    description = description.replacingOccurrences(of: previousRandom, with: "")
                    description += stringForRandom
                    previousRandom = stringForRandom
                } else {
                    description = stringForRandom
                }
            case .constant(let value):
                accumulator = value
                if resultIsPending {
                    description = description.replacingOccurrences(of: previousDescription, with: "")
                    description += symbol
                } else {
                    description = symbol
                }
                previousDescription = symbol
            case .unaryOperation(let function):
                if accumulator != nil {
                    if resultIsPending {
                        description = description.replacingOccurrences(of: previousDescription, with: "")
                        let currentDescription = symbol + "(" + previousDescription + ")"
                        description += currentDescription
                        previousDescription = currentDescription
                    } else {
                        let currentDescription = symbol + "(" + description + ")"
                        description = currentDescription
                        previousDescription = currentDescription
                    }
                    accumulator = function(accumulator!)
                }
            case .binaryOperation(let function):
                performPendingBinaryOperation()
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    accumulator = nil
                    description += " " + symbol + " "
                }
            case .equals:
                performPendingBinaryOperation()
            case .clear:
                clearCalculator()
            }
        }
    }
    
    private mutating func clearCalculator() {
        pendingBinaryOperation = nil
        accumulator = nil
        description = " "
    }
    
    private mutating func performPendingBinaryOperation() {
        if resultIsPending && accumulator != nil {
            accumulator = pendingBinaryOperation!.perform(with: accumulator!)
            pendingBinaryOperation = nil
        }
    }
    
    private struct PendingBinaryOperation {
        let function: (Double,Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 6
        if resultIsPending {
            description += formatter.string(for: accumulator)!
            previousDescription = formatter.string(for: accumulator)!
        } else {
            description = formatter.string(for: accumulator)!
        }
    }
    
    var resultIsPending: Bool {
        return pendingBinaryOperation != nil ? true : false
    }
    
    var result: Double? {
        get {
            return accumulator
        }
    }
    
    mutating func addUnaryOperation(named symbol: String, _ operation: @escaping (Double) -> Double) {
        operations[symbol] = Operation.unaryOperation(operation)
    }
}















