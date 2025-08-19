//
//  SharedConnectManager.swift
//  SharedConnectManager
//
//  Created by jiwon on 8/18/25.
//

import Foundation
import WatchConnectivity

#if os(watchOS)
    import WatchKit
#endif

class ConnectManager: NSObject, WCSessionDelegate, ObservableObject {

    static let shared = ConnectManager()

    var session: WCSession

    #if os(iOS)
        @Published var message: [String: Any] = [:]
        @Published var isTTSPlaying: Bool = true
        @Published var decisionIndex: Int = 0
        @Published var decisionCount: Int = 0
        @Published var selectedChoice: String = ""
    @Published var timerEnd: Date? = nil
        @Published var selectedOption: StoryChoiceOption? = nil
        @Published var isTimeout: Bool? = false
        @Published var isFirstRequest: Bool = true
    #endif

    #if os(watchOS)
        @Published var message: [String: Any] = [:]
        @Published var currentStage: String = ""
        @Published var hasStartedContent: Bool = false
        @Published var timerEnd: Date? = nil
        @Published var isTimerRunning: Bool = false
        @Published var isTTSPlaying: Bool = true
        @Published var decisionIndex: Int = 0
        @Published var isFirstRequest: Bool = false
        @Published var isInterrupted: Bool = false
    #endif

    private enum messageKey: String {
        case currentStage
        case isTTSPlaying
        case decisionIndex
        case isFirstRequest

        case hasStartedContent
        case timerEnd
        case isTimerRunning
        case isInterrupted
        case decisionCount

        case selectedChoice
        case selectedOption
        case isTimeout
    }

    private init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any])
    {
        DispatchQueue.main.async {
            print("[DEBUG] Received message: \(message)")

            #if os(iOS)
                if let isTTSPlaying = message[messageKey.isTTSPlaying.rawValue]
                    as? Bool
                {
                    self.isTTSPlaying = isTTSPlaying
                }

                if let decisionIndex = message[
                    messageKey.decisionIndex.rawValue
                ]
                    as? Int
                {
                    self.decisionIndex = decisionIndex
                }

                if let decisionCount = message[
                    messageKey.decisionCount.rawValue
                ]
                    as? Int
                {
                    self.decisionCount = decisionCount
                }

                if let isTimeout = message[messageKey.isTimeout.rawValue]
                    as? Bool
                {
                    self.isTimeout = isTimeout
                }

                if let isFirstRequest = message[
                    messageKey.isFirstRequest.rawValue
                ]
                    as? Bool
                {
                    self.isFirstRequest = isFirstRequest
                }

                if let selectedChoiceRaw = message[
                    messageKey.selectedChoice.rawValue
                ] as? String,
                    let selectedChoice = StoryChoiceOption(
                        rawValue: selectedChoiceRaw
                    )
                {
                    self.selectedOption = selectedChoice
                }
            #endif

            #if os(watchOS)
                guard
                    let currentStage = message[
                        messageKey.currentStage.rawValue
                    ]
                        as? String
                else {
                    print("[ERROR] stage is nil")
                    return
                }
                print(
                    "[DEBUG] stage raw value: '\(currentStage)' (type: \(type(of: currentStage)))"
                )

                if let hasStartedContent = message[
                    messageKey.hasStartedContent.rawValue
                ] as? Bool {
                    self.hasStartedContent = hasStartedContent
                }
                if let timerEnd = message[messageKey.timerEnd.rawValue] as? Date
                {
                    self.timerEnd = timerEnd
                }

                if let isTimerRunning = message[
                    messageKey.isTimerRunning.rawValue
                ]
                    as? Bool
                {
                    self.isTimerRunning = isTimerRunning
                    if !isTimerRunning {
                        self.timerEnd = nil
                    }
                }
                if let isTTSPlaying = message[
                    messageKey.isTTSPlaying.rawValue
                ]
                    as? Bool
                {
                    self.isTTSPlaying = isTTSPlaying
                }
                if let decisionIndex = message[
                    messageKey.decisionIndex.rawValue
                ]
                    as? Int
                {
                    self.decisionIndex = decisionIndex
                }
                if let isFirstRequest = message[
                    messageKey.isFirstRequest.rawValue
                ]
                    as? Bool
                {
                    self.isFirstRequest = isFirstRequest
                }
                if let isInterrupted = message[
                    messageKey.isInterrupted.rawValue
                ]
                    as? Bool
                {
                    self.isInterrupted = isInterrupted
                }

                print("[STAGE] stage: \(currentStage)")

                self.currentStage = currentStage
                print("[DEBUG] stage did change to '\(self.currentStage)'")

                switch currentStage {
                case Stage.idle.rawValue:
                    print("[IDLE] startContent: \(self.hasStartedContent)")
                    self.message = [
                        "currentStage": "idle",
                        "hasStartedContent": self.hasStartedContent,
                    ]
                case Stage.exposition.rawValue:
                    print("[EXPOSITION] isPlayTTS: \(self.isTTSPlaying)")
                    self.message = [
                        "currentStage": "exposition",
                        "isTTSPlaying": self.isTTSPlaying,
                    ]
                case Stage.decision.rawValue:
                    print(
                        "[DECISION] isTimerRunning: \(self.isTimerRunning), decisionIndex: \(self.decisionIndex), isFirstRequest: \(self.isFirstRequest)"
                    )
                    self.message = [
                        "currentStage": "decision",
                        "isTimerRunning": self.isTimerRunning,
                        "decisionIndex": self.decisionIndex,
                        "isFirstRequest": self.isFirstRequest,
                    ]
                case Stage.ending.rawValue:
                    print("[ENDING] isTimerRunning: \(self.isTimerRunning)")
                    self.message = [
                        "currentStage": "ending",
                        "isTimerRunning": self.isTimerRunning,
                    ]
                default:
                    print("[ERROR] wrong stage: \(currentStage)")
                }

            #endif
        }
    }
    #if os(iOS)
        func sendStageIdle() {
            let message: [String: Any] = [
                "currentStage": "idle",
                "hasStartedContent": true,
            ]

            let session = WCSession.default
            // TODO: Logger같은 것들?
            print("[DEBUG] idle message 보내기: \(message)")

            if session.isReachable {
                print("[DEBUG] 워치로 idle 메시지 전송")
                session.sendMessage(message, replyHandler: nil)
            } else {
                print("[INFO] 세션 도달 불가. 1초 뒤 재시도.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.sendStageIdle()
                }
            }
        }

        func sendStageExpositionWithPause() {
            let message: [String: Any] = [
                "currentStage": "exposition",
                "isTTSPlaying": false,
            ]
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        }

        func sendStageExpositionWithResume() {
            let message: [String: Any] = [
                "currentStage": "exposition",
                "isTTSPlaying": true,
            ]
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        }

        func sendStageDecisionWithFirstTTS(_ decisionIndex: Int) {
                        
            let message: [String: Any] = [
                "currentStage": "decision",
                "isTimerRunning": false,
                "decisionIndex": decisionIndex,
                "isFirstRequest": true,
            ]
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        }

        func sendStageDecisionWithFirstTimer(_ decisionIndex: Int) {
            let endTime = Date().addingTimeInterval(10)
            self.timerEnd = endTime

            let message: [String: Any] = [
                "currentStage": "decision",
                "isTimerRunning": true,
                "timerEnd": endTime,
                "decisionIndex": decisionIndex,
                "isFirstRequest": true,
            ]
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        }

        func sendStageDecisionWithSecTTS(_ decisionIndex: Int) {
            let message: [String: Any] = [
                "currentStage": "decision",
                "isTimerRunning": false,
                "decisionIndex": decisionIndex,
                "isFirstRequest": false,
            ]
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        }

        func sendStageDecisionWithSecTimer(_ decisionIndex: Int) {
            let endTime = Date().addingTimeInterval(10)
            self.timerEnd = endTime

            let message: [String: Any] = [
                "currentStage": "decision",
                "isTimerRunning": true,
                "timerEnd": endTime,
                "decisionIndex": decisionIndex,
                "isFirstRequest": false,
            ]
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        }

        func sendChoiceInterrupt() {
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(
                    [
                        "currentStage": "decision",
                        "isInterrupted": true,
                    ],
                    replyHandler: nil
                )
            }
        }

        func sendStageEndingTTS() {
            let message: [String: Any] = [
                "currentStage": "ending",
                "isTimerRunning": false,
            ]
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        }

        func sendStageEndingTimer() {
            let endTime = Date().addingTimeInterval(10)
            self.timerEnd = endTime

            let message: [String: Any] = [
                "currentStage": "ending",
                "isTimerRunning": true,
                "timerEnd": endTime,
            ]
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        }
    #endif

    #if os(watchOS)
        func sendStageExpositionWithPause() {
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(["isTTSPlaying": false], replyHandler: nil)
            }
        }

        func sendStageExpositionWithResume() {
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(["isTTSPlaying": true], replyHandler: nil)
            }
        }

        func sendFirstChoiceToIos(
            _ decisionIndex: Int,
            _ selectedChoice: String
        ) {
            let message: [String: Any] = [
                "decisionIndex": decisionIndex,
                "selectedChoice": selectedChoice,
                "decisionCount": 1,
            ]
            let session = WCSession.default
            if session.isReachable {
                session.sendMessage(message, replyHandler: nil)
            }
        }

        func sendSecChoiceToIos(_ decisionIndex: Int, _ selectedChoice: String)
        {
            let message: [String: Any] = [
                "decisionIndex": decisionIndex,
                "selectedChoice": selectedChoice,
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
                "isTimeout": true,
                "isFirstRequest": isFirstRequest,
            ]
            guard session.isReachable else { return }
            session.sendMessage(message, replyHandler: nil)
        }

        func sendFirstTimeout(_ decisionIndex: Int) {
            sendTimeoutToIos(decisionIndex, isFirstRequest: true)
        }

        func sendSecondTimeout(_ decisionIndex: Int) {
            sendTimeoutToIos(decisionIndex, isFirstRequest: false)
        }
    #endif

    func session(
        _ session: WCSession,
        activationDidCompleteWith activationState: WCSessionActivationState,
        error: Error?
    ) {}

    #if os(iOS)
        func sessionDidBecomeInactive(_ session: WCSession) {}

        func sessionDidDeactivate(_ session: WCSession) {}
    #endif
}
