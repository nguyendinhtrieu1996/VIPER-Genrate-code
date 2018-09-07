#!/usr/bin/env swift

import Foundation

guard CommandLine.arguments.count > 1 else {
    print("You have to to provide a module name as the first argument.")
    exit(-1)
}

func getUserName(_ args: String...) -> String {
    let task = Process()
    let pipe = Pipe()

    task.standardOutput = pipe
    task.standardError = pipe
    task.launchPath = "/usr/bin/env"
    task.arguments = ["git", "config", "--global", "user.name"]
    task.launch()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "GLOBEDR"
    task.waitUntilExit()
    return output
    //return (output, task.terminationStatus)
}

let userName = getUserName()
let module = CommandLine.arguments[1].capitalized
let fileManager = FileManager.default

//MARK: URL
let workUrl           = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
let contractUrl       = moduleUrl.appendingPathComponent("Contract")
let viewUrl           = moduleUrl.appendingPathComponent("View")
let interactorUrl      = implmentationsUrl.appendingPathComponent("Interactor")
let routerUrl         = implmentationsUrl.appendingPathComponent("Router")
let presenterUrl      = implmentationsUrl.appendingPathComponent("Presenter")

let contractFileUrl   = contractUrl.appendingPathComponent(module+"Contract").appendingPathExtension("swift")
let viewFileUrl   = viewUrl.appendingPathComponent(module+"ViewController").appendingPathExtension("swift")
let interactorFileUrl   = interactorUrl.appendingPathComponent(module+"Interacter").appendingPathExtension("swift")
let presenterFileUrl   = presenterUrl.appendingPathComponent(module+"Presenter").appendingPathExtension("swift")
let routerFileUrl   = routerUrl.appendingPathComponent(module+"Router").appendingPathExtension("swift")

//MARK: File comment
func fileComment(for module: String, type: String) -> String {
    let today    = Date()
    let calendar = Calendar(identifier: .gregorian)
    let year     = String(calendar.component(.year, from: today))
    let month    = String(format: "%02d", calendar.component(.month, from: today))
    let day      = String(format: "%02d", calendar.component(.day, from: today))
    
    return """
    //
    //  \(module)\(type).swift
    //  \(module)
    //
    //  Created by \(userName) on \(year). \(month). \(day)..
    //  Copyright © \(year). \(userName). All rights reserved.
    //
    """
}


//MARK: Contract File content
let contractFileContent = """
\(fileComment(for: module, type: "Contract"))

import UIkit

protocol \(module)View: class {

var presenter: \(module)Presentation? { get set }

}

protocol \(module)Presentation: class {

var view: \(module)View? { get set }
var presenter: \(module)Presentation? { get set }
var router: \(module)WireFrame? { get set }

}

protocol \(module)UseCase: class {


}

protocol \(module)WireFrame: class {

var view: UIViewController? { get set }

static func assembleModule() -> UIViewController

}

"""

//MARK: ViewController File content
let viewControllerFileContent = """
\(fileComment(for: module, type: "ViewController"))

import UIkit

class \(module)ViewController: BaseViewController, \(module)View {

//MARK: Properties
var presenter: \(module)Presentation?

//MARK: UI Elments


//MARK: Object LifeCycle

override func initialize() {

}

//MARK: SetupView


}

"""

//MARK: Interactor File content
let interactorFileContent = """
\(fileComment(for: module, type: "Interactor"))

import Foundation

class \(module)Interacter: \(module)UseCase {

}

"""

//MARK: Presenter File content
let presenterFileContent = """
\(fileComment(for: module, type: "Presenter"))

import Foundation

class \(module)Presenter: \(module)Presentation {

weak var view: \(module)View? { get set }

var presenter: \(module)Presentation? { get set }

var router: \(module)WireFrame? { get set }

}

"""

//MARK: Router File content
let routerFileContent = """
\(fileComment(for: module, type: "Router"))

import UIKit

class \(module)Router: \(module)WireFrame {

weak var viewController: UIViewController?

static func assembleModule() -> UIViewController {

let view = \(module)ViewController()
let presenter = \(module)Presenter()
let router = \(module)Router()
let interacter = \(module)Interacter()

view.presenter = presenter

presenter.view = view
presenter.router = router
presenter.interacter = interacter

router.viewController = view

return view
}

}

"""

//MARK: Write file

do {
    try [contractUrl, viewUrl, interactorUrl, presenterUrl, routerUrl].forEach {
        try fileManager.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    try contractFileUrl.write(to: contractUrl, atomically: true, encoding: .utf8)
    try viewFileUrl.write(to: viewUrl, atomically: true, encoding: .utf8)
    try interactorFileUrl.write(to: interactorUrl, atomically: true, encoding: .utf8)
    try presenterFileUrl.write(to: presenterUrl, atomically: true, encoding: .utf8)
    try routerFileUrl.write(to: routerUrl, atomically: true, encoding: .utf8)
    
    try contractFileContent.write(to: contractFileUrl, atomically: true, encoding: .utf8)
    try viewControllerFileContent.write(to: viewFileUrl, atomically: true, encoding: .utf8)
    try interactorFileContent.write(to: interactorFileUrl, atomically: true, encoding: .utf8)
    try presenterFileContent.write(to: presenterFileUrl, atomically: true, encoding: .utf8)
    try routerFileContent.write(to: routerFileUrl, atomically: true, encoding: .utf8)
    
} catch {
    print(error.localizedDescription)
}









