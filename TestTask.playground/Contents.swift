// Short test playground for Curogram's iOS candidates.

import UIKit
import PlaygroundSupport

/**
 ---------------------------------------------------------------------------------
 How long are you in iOS coding?
 */
var iOSCodingSummary: TimeInterval = 0

let formatter = DateFormatter()
formatter.dateFormat = "yyyy/MM/dd"

let date1:Date = formatter.date(from: "2016/09/01") ?? Date()
let date2: Date = Date()

iOSCodingSummary = date2.timeIntervalSince(date1)

//iOSCodingSummary.
print(iOSCodingSummary)



/**
 ---------------------------------------------------------------------------------
 How much Swift experience do you have?
 */
var swiftCodingTime: TimeInterval = 0

swiftCodingTime = iOSCodingSummary

print(swiftCodingTime)



/**
 ---------------------------------------------------------------------------------
 Your favourite Swift frameworks
 */
var frameworks = [URL]()

if let url = URL(string: "https://github.com/Alamofire/Alamofire") { frameworks.append(url)}
if let url = URL(string: "https://github.com/ProcedureKit/ProcedureKit") { frameworks.append(url)}
if let url = URL(string: "https://github.com/SwiftyJSON/SwiftyJSON") { frameworks.append(url)}

print(frameworks)



/**
 ---------------------------------------------------------------------------------
Please describe your opinion regarding coding with patterns
 */
/*
I think, using pattern is very important for projecting app and for writing code of clearly
*/


/**
 ---------------------------------------------------------------------------------
 What are the most important skills for the developer, what do you think?
 Please provide an answer in the code manner e.g. array or something else.
 */
/*
Class, Enum, CoreData, Operaion and other
 */



/**
 ---------------------------------------------------------------------------------
 If you had a choice, would you use this "Factory" for creating UI controls or you would 
 like to make it another way. Justify your answer.
 */
enum LabelFactory {
    
    case standardLabel(text: String, textColor: UIColor, fontStyle: UIFontTextStyle, textAlignment: NSTextAlignment?, sizeToFit: Bool, adjustToFit: Bool)
    
    var new: UILabel {
        
        switch self {
        case .standardLabel(let text,let textColor,let fontStyle, let textAlignment,let sizeToFit, let adjustToFit):
            return createStandardLabel(text: text, textColor: textColor, fontStyle: fontStyle, textAlignment: textAlignment, sizeToFit: sizeToFit, adjustToFit: adjustToFit)
        }
    }
    
    private func createStandardLabel(text: String, textColor: UIColor, fontStyle: UIFontTextStyle, textAlignment: NSTextAlignment?, sizeToFit: Bool, adjustToFit: Bool) -> UILabel {
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = adjustToFit
        label.text = text
        label.font = UIFont.preferredFont(forTextStyle: fontStyle)
        label.textAlignment = textAlignment ?? .left
        label.textColor = textColor
        if sizeToFit {
            label.sizeToFit()
        }
        return label
    }
}
/*
 I  prefer used to the Storyboard or I use xib-class
 */


/// *** Answer and/or implementation goes here ***





/**
 ---------------------------------------------------------------------------------
 OPTIONAL QUESTION (so you can ignore it if you are too busy or something)
 Synchronize an execution of these three operations. They should be executed one right after another. As a result, you need to output all functions results in a reversed order into existing value.
 */

let queue = OperationQueue()
queue.maxConcurrentOperationCount = Int(Int8.max)

func operation1(with parameter: String, and completion: @escaping ((String) -> Void)) {
    queue.addOperation { 
        Thread.sleep(forTimeInterval: 0.1)
        completion(parameter)
    }
}

func operation2(with amount: UInt, and completion: @escaping ((String) -> Void)) {
    DispatchQueue.global().async {
        var result: UInt = 0
        for i in 0 ..< amount {
            Thread.sleep(forTimeInterval: 0.1)
            result += i
        }
        completion(String(describing: result))
    }
}

let operation3: ((String) -> String) = { (inStr) -> String in
    return inStr
}


class operation1_: Operation {
    private(set) var str: String = ""
    var parameter: String
    
    init(parameter: String) {
      self.parameter = parameter
    }
    
    override func main() {
        print(parameter)
        str = parameter
     }
}

class operation2_: Operation {
    private(set) var str: String = ""
    var amount: UInt
    
    init(amount: UInt) {
        self.amount = amount
    }
    
    override func main() {
        var result: UInt = 0
        for i in 0 ..< amount {
            result += i
        }
        
        str = String(describing: result)
        print(str)
      }
}

class operation3_: Operation {
    private(set) var str: String = ""
    var parameter: String
    
    init(parameter: String) {
        self.parameter = parameter
    }
    
    override func main() {
        print(parameter)
        str = parameter
    }
}



/// Main function
func main() {
    var result = [String]()
    
    let op3 = operation3_(parameter: "op3")
    op3.completionBlock = {  result.append(op3.str)  }
    
    let op2 = operation2_(amount: 5)
    op2.addDependency(op3)
    op2.completionBlock = {  result.append(op2.str)  }
    
    
    let op1 = operation1_(parameter: "op1")
    op1.addDependency(op2)
    op1.completionBlock = {  result.append(op1.str)  }

    
    queue.addOperations([op3, op2, op1], waitUntilFinished: true)
    
    
    print(result)
}

main()





/**
 ---------------------------------------------------------------------------------
 Create a single screen standalone app.
 - There should be a List on the screen, progress indicator and "Add" button. How it should look - decide by yourself.
 - That List contains numbers, and it should be sorted from the highest value to lowest. Cells UI is on your choise.
 - By pressing "Add" button, there should be a random number generated (from 0 to 100 ) and added to the List. Delay when adding should be equal to 2 seconds. There should be a load indicator shown during delay.
 - "Swipe-to-delete" should be used to remove List items. There should be an "Undo" button somewhere on the screen. By pressing that button, last removed item should be brought back to the list. Delay when restoring should be equal to 2 seconds. There should be a load indicator shown during delay.
 - When adding new items, UI should not be blocked. There should be a support for multiple items adding\restoring in the same time.
 */
