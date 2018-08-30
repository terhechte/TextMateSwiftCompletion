//
//  Completer.swift
//  TextMateSwiftCompletion
//
//  Created by Benedikt Terhechte on 06/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

//
//  Completer.swift
//  SourceKittenDaemon
//
//  Created by Benedikt Terhechte on 05/12/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import AppKit

enum CompletionError: Error {
    case error(message: String)
}

enum Result {
    case started
    case stopped
    case running(Bool)
    case files([String])
    case completions([String])
    case error(Error)
}

typealias Completion = (_ result: Result) -> ()

public protocol CompleterDebugDelegate {
    func calledURL(_ url: URL, withHeaders headers: [String: String])
    func startedCompleter(_ command: String)
}

/**
 Wrapper for Objective-C
*/
@objc open class CompleterWrapper: NSObject {
    @objc public static func completionsWrapper(_ completer: Completer, offset: Int, file: String, completion: @escaping (_ result: [String]?) -> ()) {
        completer.calculateCompletions(URL(fileURLWithPath: file), offset: offset) { (result) -> () in
            switch result {
            case .completions(let completions):
                completion(completions)
            default:
                completion(nil)
            }
        }
    }
}

/**
 This class takes care of all the completer / sourcekittendaemon handling. It:
 - Searches the sourcekittendaemon binary in the SwiftCode binary
 - Starts an `NSTask` with the binary
 - Does the network requests against the sourcekittendaemon
 - Converts the results to the proper types
 - And offers rudimentary error handling via the `Result` type

 This can be considered the main component for connecting to the SourceKittenDaemon
 completion engine.
 */
@objc open class Completer: NSObject {

    let port: String

    let projectURL: URL
    let task: Process?

    var debugDelegate: CompleterDebugDelegate? = nil

    /**
     Create a new Completer for an Xcode project
     - parameter project: The Xcode project to load
     - parameter finished: This will be called once the task is running and the server is started up
     */
    init(project: URL, completion: @escaping Completion) {
        self.projectURL = project
        self.port = "44876"

        /// Find the SourceKittenDaemon Binary in our bundle
        let bundle = Bundle.main
        guard let supportPath = bundle.sharedSupportPath
            else { fatalError("Could not find Support Path") }

        let daemonBinary = (supportPath as NSString).appendingPathComponent("SourceKittenDaemon.app/Contents/MacOS/SourceKittenDaemon")
        guard FileManager.default.fileExists(atPath: daemonBinary)
            else { fatalError("Could not find SourceKittenDaemon") }

        /// Start up the SourceKittenDaemon
        self.task = Process()
        self.task?.launchPath = daemonBinary
        self.task?.arguments = ["start", "--port", self.port, "--project", project.path]

        /// Create an output pipe to read the sourcekittendaemon output
        let outputPipe = Pipe()
        self.task?.standardOutput = outputPipe.fileHandleForWriting

        /// Wait until the server started up properly
        /// Read the server output to figure out if startup succeeded.
        var started = false
        super.init()
        DispatchQueue.global(qos: .userInteractive).async {
            var content: String = ""
            while true {

                let data = outputPipe.fileHandleForReading.readData(ofLength: 1)

                guard let dataString = String(data: data, encoding: String.Encoding.utf8)
                    else { continue }
                content += dataString

                if content.range(of: "\\[INFO\\] Started", options: .regularExpression) != nil &&
                    !started {
                    started = true
                    DispatchQueue.main.async(execute: { () -> Void in
                        guard let task = self.task, let arguments = task.arguments else { return }
                        self.debugDelegate?.startedCompleter(([daemonBinary] + arguments).joined(separator: " "))
                        completion(Result.started)
                    })
                }

                if content.range(of: "\\[ERR\\]", options: .regularExpression) != nil {
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion(Result.error(CompletionError.error(message: "Failed to start the Daemon")))
                    })
                    return
                }
            }
        }

        self.task?.launch()
    }


    /**
     Connect to an existing SourceKittenDaemon which may have been started somewhere else
     */
    init(port: String) {
        self.port = port
        self.projectURL = URL(fileURLWithPath: "")
        self.task = nil
    }

    /**
    Try whether the server is still running via a ping
    */
    func ping(_ completed: @escaping Completion) {
        self.dataFromDaemon("/ping", headers: [:]) { (data) -> () in
            do {
                let result = try data() as? String
                if result == "OK" {
                    completed(Result.running(true))
                } else {
                    completed(Result.running(false))
                }
            } catch let error {
                print("error", error)
                completed(Result.running(false))
            }
        }
    }

    /**
     Stop the completion server, kill the task. This will be performed when a new
     Xcode project is loaded */
    func stop(_ completed: @escaping Completion) {
        self.dataFromDaemon("/stop", headers: [:]) { (data) -> () in
            self.task?.terminate()
            completed(Result.stopped)
        }
    }

    /**
     Return all project files in the Xcode project
     */
    func projectFiles(_ completion: @escaping Completion) {
        self.dataFromDaemon("/files", headers: [:]) { (data) -> () in
            do {
                let files = try data() as? [String]
                completion(Result.files(files!))
            } catch let error {
                completion(Result.error(error))
            }
        }
    }

    // MARK: Convenience

    /**
    Get a temporary file with contents
    */
    @objc func temporaryFile(_ content: String) -> String {
        let temporaryFileName = NSTemporaryDirectory() + "/" + ProcessInfo.processInfo.globallyUniqueString + ".swift"
        FileManager.default.createFile(atPath: temporaryFileName, contents: content.data(using: String.Encoding.utf8) , attributes: [:])
        return temporaryFileName
    }

    /**
     Get the completions for the given file at the given offset
     - parameter temporaryFile: A temporary file containing the content to be completed upon
     - parameter offset: The cursor / byte position in the file for which we need completions
     */
    func calculateCompletions(_ temporaryFile: URL?, offset: Int, completion: @escaping Completion) {
        // Create the arguments
        guard let temporaryFilePath = temporaryFile?.path
            else {
                completion(Result.error(CompletionError.error(message: "No file path")))
                return
        }
        let attributes = ["X-Path": temporaryFilePath, "X-Offset": "\(offset)"]
        self.dataFromDaemon("/complete", headers: attributes) { (data) -> () in
            do {
                guard let completions = try data() as? [NSDictionary] else {
                    completion(Result.error(CompletionError.error(message: "Wrong Completion Return Type")))
                    return
                }
                var results = [String]()
                for c in completions {
                    guard let s = (c["name"] as? String) else { continue }
                    results.append(s)
                }
                completion(Result.completions(results))
            } catch let error {
                completion(Result.error(error))
            }
        }
    }

    /**
     This is the work horse that makes sure we're receiving valid data from the completer.
     It does not use the Result type as that would include too much knowledge into this function
     (i.e. do we have a files or a completion request). Instead it uses the throwing closure
     concept as explained here: http://appventure.me/2015/06/19/swift-try-catch-asynchronous-closures/
     */
    fileprivate func dataFromDaemon(_ path: String, headers: [String: String], completion: @escaping (_ data: () throws -> AnyObject) -> () ) {
        guard let url = URL(string: "http://localhost:\(self.port)\(path)")
            else {
                completion({ throw CompletionError.error(message: "Could not create completer URL") })
                return
        }

        self.debugDelegate?.calledURL(url, withHeaders: headers)

        let session = URLSession.shared

        let mutableRequest = NSMutableURLRequest(url: url)
        headers.forEach { (h) -> () in
            mutableRequest.setValue(h.1, forHTTPHeaderField: h.0)
        }


        let task = session.dataTask(with: mutableRequest  as URLRequest) { data, response, error in
            if let error = error {
                DispatchQueue.main.async(execute: { () -> Void in
                    completion({ throw CompletionError.error(message: "error: \(error.localizedDescription): \(String(describing: error._userInfo))") })
                })
                return
            }

            // ping requires an ok
            if let data = data,
                   let dataString = String(data: data, encoding: String.Encoding.utf8), dataString == "OK" {
                completion({ dataString as AnyObject })
                    return
            }

            guard let data = data,
                let parsedData = try? JSONSerialization.jsonObject(with: data, options: [])
                else {
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion({ throw CompletionError.error(message: "Invalid Json") })
                    })
                    return
            }

            // Detect errors
            if let parsedDict = parsedData as? [String: AnyObject],
                let jsonError = parsedDict["error"], parsedDict.count == 1 {
                    DispatchQueue.main.async(execute: { () -> Void in
                        completion({ throw CompletionError.error(message: "Error: \(jsonError)") })
                    })
                    return
            }

            DispatchQueue.main.async(execute: { () -> Void in
                completion({ parsedData as AnyObject })
            })
        }

        task.resume()
    }
}
