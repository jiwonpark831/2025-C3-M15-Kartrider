//
//  IosConnectManager.swift
//  Kartrider
//
//  Created by jiwon on 6/4/25.
//

import Foundation
import WatchConnectivity

class IosConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    @Published var stage: String = ""
    @Published var timerStarted: Bool = false
    @Published var ttsStatus: String = ""
    @Published var decisionIndex: Int = 0
    @Published var selectedChoice: String = ""
    @Published var isFirstRequest: Bool = false
    @Published var decisionCount: Int = 0
    @Published var isInterrupt: Bool = false

    var session: WCSession

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {

    }

    func sessionDidBecomeInactive(_ session: WCSession) {

    }

    func sessionDidDeactivate(_ session: WCSession) {

    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        DispatchQueue.main.async {
            if let newTtsStatus = message["ttsStatus"] as? String {
                self.ttsStatus = newTtsStatus
            }
            if let newSelectedChoice = message["selectedChoice"] as? String {
                self.selectedChoice = newSelectedChoice
            }
            if let newDecisionCount = message["decisionCount"] as? Int {
                self.decisionCount = newDecisionCount
            }
        }
    }

    func sendStage(_ stage: String) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["stage": stage], replyHandler: nil)
        }
    }
    func sendTimerStart(_ timerStarted: Bool) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(
                ["timerStarted": timerStarted], replyHandler: nil)
        }
    }

    func sendTtsStatus(_ ttsStatus: String) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(["ttsStatus": ttsStatus], replyHandler: nil)
        }
    }

    func sendDecisionIndex(_ decisionIndex: Int) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(
                ["decisionIndex": decisionIndex], replyHandler: nil)
        }
    }

    func sendSelectedChoice(_ selectedChoice: String) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(
                ["selectedChoice": selectedChoice], replyHandler: nil)
        }
    }

    func sendIsFirstRequest(_ isFirstRequest: Bool) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(
                ["isFirstRequest": isFirstRequest], replyHandler: nil)
        }
    }

    func sendIsInterrupt(_ isInterrupt: Bool) {
        let session = WCSession.default
        if session.isReachable {
            session.sendMessage(
                ["isInterrupt": isInterrupt], replyHandler: nil)
        }
    }
}
