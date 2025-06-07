//
//  WatchConnectManager.swift
//  Pickacha Watch App
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class WatchConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    @Published var msg: [String: Any] = [:]

    @Published var stage: String = ""
    @Published var startContent: Bool = false
    @Published var timerStarted: Bool = false
    @Published var isPlayTTS: Bool = true
    @Published var decisionIndex: Int = 0
    @Published var isFirstRequest: Bool = false
    @Published var isInterrupt: Bool = false

    var session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        if WCSession.isSupported() {
            self.session.delegate = self
            self.session.activate()
        } else {
            print("[ERROR] WCSession not supported")
        }
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {
        print("Session activated: \(activationState.rawValue)")
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        DispatchQueue.main.async {
            print("[DEBUG] Received message: \(message)")
            guard let stage = message["stage"] as? String else {
                print("[ERROR] stage is nil")
                return
            }
            print(
                "[DEBUG] stage raw value: '\(stage)' (type: \(type(of: stage)))"
            )

            if let startContent = message["startContent"] as? Bool {
                self.startContent = startContent
            }
            if let timerStarted = message["timerStarted"] as? Bool {
                self.timerStarted = timerStarted
            }
            if let isPlayTTS = message["isPlayTTS"] as? Bool {
                self.isPlayTTS = isPlayTTS
            }
            if let decisionIndex = message["decisionIndex"] as? Int {
                self.decisionIndex = decisionIndex
            }
            if let isFirstRequest = message["isFirstRequest"] as? Bool {
                self.isFirstRequest = isFirstRequest
            }
            if let isInterrupt = message["isInterrupt"] as? Bool {
                self.isInterrupt = isInterrupt
            }

            print("[STAGE] stage: \(stage)")

            print(
                "[DEBUG] stage will change from '\(self.stage)' to '\(stage)'")
            self.stage = stage
            print("[DEBUG] stage did change to '\(self.stage)'")

            switch stage {
            case "idle":
                print("[IDLE] startContent: \(self.startContent)")
                self.msg = ["stage": "idle", "startContent": self.startContent]
            case "exposition":
                print("[EXPOSITION] isPlayTTS: \(self.isPlayTTS)")
                self.msg = ["stage": "exposition", "isPlayTTS": self.isPlayTTS]
            case "decision":
                print(
                    "[DECISION] timerStarted: \(self.timerStarted), decisionIndex: \(self.decisionIndex), isFirstRequest: \(self.isFirstRequest)"
                )
                self.msg = [
                    "stage": "decision", "timerStarted": self.timerStarted,
                    "decisionIndex": self.decisionIndex,
                    "isFirstRequest": self.isFirstRequest,
                ]
            case "ending":
                print("[ENDING] timerStarted: \(self.timerStarted)")
                self.msg = [
                    "stage": "ending", "timerStarted": self.timerStarted,
                ]
            default:
                print("[ERROR] wrong stage: \(stage)")
            }
        }
    }

    func sendStageExpositionWithPause() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["isPlayTTS": false], replyHandler: nil)
        }
    }

    func sendStageExpositionWithResume() {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["isPlayTTS": true], replyHandler: nil)
        }
    }

    func sendFirstChoiceToIos(_ decisionIndex: Int, _ selectedChoice: String) {
        let message: [String: Any] = [
            "decisionIndex": decisionIndex, "selectedChoice": selectedChoice,
            "decisionCount": 1,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendSecChoiceToIos(_ decisionIndex: Int, _ selectedChoice: String) {
        let message: [String: Any] = [
            "decisionIndex": decisionIndex, "selectedChoice": selectedChoice,
            "decisionCount": 2,
        ]
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil)
        }
    }

    func sendTimeoutToIos(_ decisionIndex: Int, isFirstRequest: Bool) {
           let message: [String: Any] = [
               "decisionIndex": decisionIndex,
               "timeout": true,
               "isFirstRequest": isFirstRequest
           ]
           guard session.isReachable else { return }
           // 안정적인 전송을 위해 두 번 보내는 로직 유지
           session.sendMessage(message, replyHandler: nil)
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
               self.session.sendMessage(message, replyHandler: nil)
           }
       }

       func scheduleFirstTimeout(_ decisionIndex: Int) {
           // … first timer expiry logic …
           sendTimeoutToIos(decisionIndex, isFirstRequest: true)
       }

       func scheduleSecondTimeout(_ decisionIndex: Int) {
           sendTimeoutToIos(decisionIndex, isFirstRequest: false)
       }

}
