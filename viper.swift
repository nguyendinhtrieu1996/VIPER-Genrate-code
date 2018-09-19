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
let module = CommandLine.arguments[1]
let fileManager = FileManager.default

//MARK: URL
let workUrl           = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
let moduleUrl         = workUrl.appendingPathComponent(module)

let contractUrl       = moduleUrl.appendingPathComponent("Contract")
let viewUrl           = moduleUrl.appendingPathComponent("View")
let interactorUrl      = moduleUrl.appendingPathComponent("Interactor")
let routerUrl         = moduleUrl.appendingPathComponent("Router")
let presenterUrl      = moduleUrl.appendingPathComponent("Presenter")
let commonURL         = moduleUrl.appendingPathComponent("Common")
let serviceURL        = commonURL.appendingPathComponent("Service")

let contractFileUrl   = contractUrl.appendingPathComponent(module+"Contract").appendingPathExtension("swift")
let viewFileUrl   = viewUrl.appendingPathComponent(module+"ViewController").appendingPathExtension("swift")
let interactorFileUrl   = interactorUrl.appendingPathComponent(module+"Interacter").appendingPathExtension("swift")
let presenterFileUrl   = presenterUrl.appendingPathComponent(module+"Presenter").appendingPathExtension("swift")
let routerFileUrl   = routerUrl.appendingPathComponent(module+"Router").appendingPathExtension("swift")

//Service
let endpointFileURL = serviceURL.appendingPathComponent(module+"Endpoint").appendingPathExtension("swift")
let serviceFileURL = serviceURL.appendingPathComponent(module+"Service").appendingPathExtension("swift")

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

import UIKit

//MARK: VIEW
protocol \(module)View: class {

    var presenter: \(module)Presentation? { get set }

}

//MARK: PRESENTER
protocol \(module)Presentation {

    var view: \(module)View? { get set }
    var router: \(module)WireFrame? { get set }
    var interactor: \(module)UseCase? { get set }

}

//MARK: PRESENTER
protocol \(module)UseCase: class {
    var service: \(module)ServiceInputProtocol? { get set }
    var output: \(module)InteractorOutputProtocol? { get set }

}

protocol \(module)InteractorOutputProtocol: BaseInteracterOutputProtocol {

}

//MARK: ROUTER
protocol \(module)WireFrame: BaseRouterProtocol {

    var viewController: UIViewController? { get set }

    static func assembleModule() -> UIViewController

}

//MARK: SERVIVE
protocol \(module)ServiceInputProtocol: class {
    var requestHandler: \(module)ServiceOutputProtocol? { get set }
}

protocol \(module)ServiceOutputProtocol: BaseServiceOutputProtocol {

}

"""

//MARK: ViewController File content
let viewControllerFileContent = """
\(fileComment(for: module, type: "ViewController"))

import UIKit

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

class \(module)Interacter {
    var service: \(module)ServiceInputProtocol?

    var output: \(module)InteractorOutputProtocol?

}

//MARK: - \(module)UseCase
extension \(module)Interacter: \(module)UseCase {

}

//MARK: - \(module)ServiceOutputProtocol
extension \(module)Interacter: \(module)ServiceOutputProtocol {

    func onNoNetwork() {

    }

    func onErrorOccur(with error: String?) {

    }

}

"""

//MARK: Presenter File content
let presenterFileContent = """
\(fileComment(for: module, type: "Presenter"))

import Foundation

class \(module)Presenter {

    weak var view: \(module)View?

    var router: \(module)WireFrame?

    var interactor: \(module)UseCase?

}

//MARK: - \(module)Presentation
extension \(module)Presenter: \(module)Presentation {

}

//MARK: - \(module)InteractorOutputProtocol
extension \(module)Presenter: \(module)InteractorOutputProtocol {

    func didNoNetwork() {

    }

    func didErrorOccur(with error: String?) {

    }

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
        let service = \(module)Service()

        view.presenter = presenter

        presenter.view = view
        presenter.router = router
        presenter.interactor = interacter

        router.viewController = view

        interacter.output = presenter
        interacter.service = service

        service.requestHandler = interacter

        return view
    }

}

"""

//MARK: Endpoint File content
let endPointFileContent = """
\(fileComment(for: module, type: "Endpoint"))

import Foundation

enum \(module)Endpoint {

}

extension \(module)Endpoint: EndPointType {

    var path: String {
        return ""
    }

    var httpMethod: HTTPMethod {
        return .get
        }

    var task: HTTPTask {
        return .request
    }

    var headers: HTTPHeaders? {
        return nil
    }

    var body: Parameters? {
        return nil
    }

    var urlParams: Parameters? {
        return nil
    }

}

"""

//MARK: Service File content
let serviceFileContent = """
\(fileComment(for: module, type: "Service"))

import Foundation

class \(module)Service: \(module)ServiceInputProtocol {
    weak var requestHandler: \(module)ServiceOutputProtocol?
}

"""


//MARK: Write file

do {
    try [moduleUrl, commonURL, contractUrl, viewUrl, interactorUrl, presenterUrl, routerUrl, serviceURL].forEach {
        try fileManager.createDirectory(at: $0, withIntermediateDirectories: true, attributes: nil)
    }
    
    try contractFileContent.write(to: contractFileUrl, atomically: true, encoding: .utf8)
    try viewControllerFileContent.write(to: viewFileUrl, atomically: true, encoding: .utf8)
    try interactorFileContent.write(to: interactorFileUrl, atomically: true, encoding: .utf8)
    try presenterFileContent.write(to: presenterFileUrl, atomically: true, encoding: .utf8)
    try routerFileContent.write(to: routerFileUrl, atomically: true, encoding: .utf8)
    try endPointFileContent.write(to: endpointFileURL, atomically: true, encoding: .utf8)
    try serviceFileContent.write(to: serviceFileURL, atomically: true, encoding: .utf8)
    
} catch {
    print(error.localizedDescription)
}









