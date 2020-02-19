//
//  ViewModel.swift
//  speachservicedemo
//
//  Created by Han Chen on 2020/2/19.
//  Copyright © 2020 Han Chen. All rights reserved.
//

import UIKit

class ViewModel {
    
    var updateLabel = { (text: String) -> Void in }
    var updateLabelColor = { (color: UIColor) -> Void in }
    var playAudio = { (data: Data) -> Void in }
    
    /*
     lang code
     https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/language-support
     */
    
//    private let subscriptionKey: String = "af5eea9e142b400783782dad119736eb"
    private let subscriptionKey: String = "782b2f38a27c405e8120104cefd2e971"
    private var subscriptionRegion: String = "westus"
    
    func recognizeFileToText(wavFilePath: String, fromLang: String) {
        guard let speechConfig = getSpeechConfig() else {
            print("speechConfig is null")
            return
        }
        
        speechConfig.speechRecognitionLanguage = fromLang
        
        guard let audioConfig = getAudioConfig(wavFilePath: wavFilePath) else {
            print("audioConfig is null")
            return
        }
        
        print("Recognizing file to text ...")
        updateLabel(text: "Recognizing file to text ... ", color: .gray)
        
        let recognizer = try! SPXSpeechRecognizer(speechConfiguration: speechConfig,
                                                  audioConfiguration: audioConfig)
        
        recognizer.addRecognizingEventHandler { [weak self] (reco, env) in
            print("intermediate recognition result: \(env.result.text ?? "(no result)")")
            self?.updateLabel(text: env.result.text ?? "", color: .gray)
        }
        
        let result = try! recognizer.recognizeOnce()
        
        switch result.reason {
        case .recognizedSpeech:
            print("Speech recognition result received: \(result.text ?? "")")
            updateLabel(text: result.text ?? "", color: .black)
        case .canceled:
            if let detail = try? SPXCancellationDetails(fromCanceledRecognitionResult: result) {
                print("cancelled, detail: \(detail.errorDetails!)")
                updateLabel(text: "cancelled, detail: \(detail.errorDetails!)", color: .red)
            }
        default:
            print("There was an error.")
            updateLabel(text: "Speech Recognition Error", color: .red)
        }
    }
    
    func translationFileToText(wavFilePath: String, fromLang: String, toLangs: [String]) {
        guard let translationConfig = getTranslationConfig() else {
            print("translationConfig is null")
            return
        }
        
        translationConfig.speechRecognitionLanguage = fromLang
        for lang in toLangs {
            translationConfig.addTargetLanguage(lang)
        }
        
        guard let audioConfig = getAudioConfig(wavFilePath: wavFilePath) else {
            print("audioConfig is null")
            return
        }
        
        print("Translating file to text ...")
        updateLabel(text: "Translating file to text ...", color: .gray)
        
        let recognizer = try! SPXTranslationRecognizer(speechTranslationConfiguration: translationConfig,
                                                       audioConfiguration: audioConfig)
        
        recognizer.addRecognizingEventHandler { [weak self] (reco, env) in
            print("intermediate recognition result: \(env.result.text ?? "(no result)")")
            self?.updateLabel(text: env.result.text ?? "", color: .gray)
        }
        
        let result = try! recognizer.recognizeOnce()
        
        switch result.reason {
        case .translatedSpeech:
            var msg = "RECOGNIZED \(fromLang) : \(result.text ?? "")"
            for element in result.translations {
                msg += "\nTRANSLATED into \(element.key) : \(element.value)"
            }
            print(msg)
            updateLabel(text: msg, color: .black)
        case .recognizedSpeech:
            print("RECOGNIZED \(fromLang) : \(result.text ?? "") (text could not be translated)")
        case .noMatch:
            print("NOMATCH: Speech could not be recognized.")
        case .canceled:
            let detail = try! SPXCancellationDetails(fromCanceledRecognitionResult: result)
            print("cancelled, detail: \(detail.errorDetails!)")
            updateLabel(text: "cancelled, detail: \(detail.errorDetails!)", color: .black)
            if detail.reason == .error {
                print("CANCELED: ErrorCode=\(detail.errorCode)")
                print("CANCELED: ErrorDetails=\(detail.errorDetails ?? "")")
                print("CANCELED: Did you update the subscription info?")
            }
        default:
            print("There was an error.")
            updateLabel(text: "Speech Recognition Error", color: .red)
        }
    }
    
    func translateFileToSpeech(wavFilePath: String, fromLang: String, toLang: String, voiceName: String) {
        guard let translationConfig = getTranslationConfig() else {
            print("translationConfig is null")
            return
        }
        
        translationConfig.speechRecognitionLanguage = fromLang
        translationConfig.addTargetLanguage(toLang)
        translationConfig.voiceName = voiceName
        
        guard let audioConfig = getAudioConfig(wavFilePath: wavFilePath) else {
            print("audioConfig is null")
            return
        }
        
        print("Translating file to speech ...")
        updateLabel(text: "Translating file to speech ...", color: .gray)
        
        let recognizer = try! SPXTranslationRecognizer(speechTranslationConfiguration: translationConfig,
                                                       audioConfiguration: audioConfig)
        
        recognizer.addSynthesizingEventHandler { [weak self] (reco, env) in
            guard let audio = env.result.audio else {
                print("audio is null")
                return
            }
            guard audio.count > 0 else { return }
            print("audio size: \(audio.count)")
            print("AUDIO SYNTHESIZED: \(audio.count) byte(s)")
            print("AUDIO SYNTHESIZED: \(audio.count) byte(s) (COMPLETE)")
            if let data = Data(base64Encoded: audio.base64EncodedData(), options: .ignoreUnknownCharacters) {
                self?.playAudio(data)
            }
        }
        
        recognizer.addRecognizingEventHandler { [weak self] (reco, env) in
            print("intermediate recognition result: \(env.result.text ?? "(no result)")")
            self?.updateLabel(text: env.result.text ?? "", color: .gray)
        }
        
        let result = try! recognizer.recognizeOnce()
        
        switch result.reason {
        case .translatedSpeech:
//            print("RECOGNIZED \(fromLang) : \(result.text ?? "")")
//            print("TRANSLATED into \(toLang) : \(result.translations[toLang] ?? "")")
//            print("===")
//            print(result.translations)
//            updateLabel(text: (result.translations[toLang] as? String) ?? "", color: .black)
            print(result.translations)
            var msg = "RECOGNIZED \(fromLang) : \(result.text ?? "")"
            msg += "\nTRANSLATED into \(toLang) : \(result.translations[toLang] ?? "")"
            print(msg)
            updateLabel(text: msg, color: .black)
        case .recognizedSpeech:
            print("RECOGNIZED \(fromLang) : \(result.text ?? "") (text could not be translated)")
        case .noMatch:
            print("NOMATCH: Speech could not be recognized.")
        case .canceled:
            let detail = try! SPXCancellationDetails(fromCanceledRecognitionResult: result)
            print("cancelled, detail: \(detail.errorDetails!)")
            updateLabel(text: "cancelled, detail: \(detail.errorDetails!)", color: .black)
            if detail.reason == .error {
                print("CANCELED: ErrorCode=\(detail.errorCode)")
                print("CANCELED: ErrorDetails=\(detail.errorDetails ?? "")")
                print("CANCELED: Did you update the subscription info?")
            }
        default:
            print("There was an error.")
            updateLabel(text: "Speech Recognition Error", color: .red)
        }
    }
    
    func translateSpeechToSpeech(fromLang: String, toLang: String, voiceName: String) {
        guard let translationConfig = getTranslationConfig() else {
            print("translationConfig is null")
            return
        }
        
        translationConfig.speechRecognitionLanguage = fromLang
        translationConfig.addTargetLanguage(toLang)
        translationConfig.voiceName = voiceName
        
        guard let audioConfig = getAudioConfig() else {
            print("audioConfig is null")
            return
        }
        
        print("Translating speech to speech ...")
        updateLabel(text: "Translating speech to speech ...", color: .gray)
        
        let recognizer = try! SPXTranslationRecognizer(speechTranslationConfiguration: translationConfig,
                                                       audioConfiguration: audioConfig)
        
        recognizer.addSynthesizingEventHandler { [weak self] (reco, env) in
            guard let audio = env.result.audio else {
                print("audio is null")
                return
            }
            guard audio.count > 0 else { return }
            print("audio size: \(audio.count)")
            print("AUDIO SYNTHESIZED: \(audio.count) byte(s)")
            print("AUDIO SYNTHESIZED: \(audio.count) byte(s) (COMPLETE)")
            if let data = Data(base64Encoded: audio.base64EncodedData(), options: .ignoreUnknownCharacters) {
                self?.playAudio(data)
            }
        }
        
        recognizer.addRecognizingEventHandler { [weak self] (reco, env) in
            print("intermediate recognition result: \(env.result.text ?? "(no result)")")
            self?.updateLabel(text: env.result.text ?? "", color: .gray)
        }
        
        let result = try! recognizer.recognizeOnce()
        
        switch result.reason {
        case .translatedSpeech:
            print(result.translations)
            var msg = "RECOGNIZED \(fromLang) : \(result.text ?? "")"
            msg += "\nTRANSLATED into \(toLang) : \(result.translations[toLang] ?? "")"
            print(msg)
            updateLabel(text: msg, color: .black)
        case .recognizedSpeech:
            print("RECOGNIZED \(fromLang) : \(result.text ?? "") (text could not be translated)")
        case .noMatch:
            print("NOMATCH: Speech could not be recognized.")
        case .canceled:
            let detail = try! SPXCancellationDetails(fromCanceledRecognitionResult: result)
            print("cancelled, detail: \(detail.errorDetails!)")
            updateLabel(text: "cancelled, detail: \(detail.errorDetails!)", color: .black)
            if detail.reason == .error {
                print("CANCELED: ErrorCode=\(detail.errorCode)")
                print("CANCELED: ErrorDetails=\(detail.errorDetails ?? "")")
                print("CANCELED: Did you update the subscription info?")
            }
        default:
            print("There was an error.")
            updateLabel(text: "Speech Recognition Error", color: .red)
        }
    }
}

extension ViewModel {
    
    private func updateLabel(text: String, color: UIColor) {
        updateLabel(text)
        updateLabelColor(color)
    }
    
    private func getSpeechConfig() -> SPXSpeechConfiguration? {
        var speechConfig: SPXSpeechConfiguration?
        do {
            try speechConfig = SPXSpeechConfiguration(subscription: subscriptionKey, region: subscriptionRegion)
        } catch {
            print("Got an error in \(#function)\n\(error)")
            speechConfig = nil
        }
        return speechConfig
    }
    
    private func getAudioConfig(wavFilePath: String? = nil) -> SPXAudioConfiguration? {
        guard let wavFilePath = wavFilePath else {
            return SPXAudioConfiguration()
        }
        guard !wavFilePath.isEmpty else { return nil }
        return SPXAudioConfiguration(wavFileInput: wavFilePath)
    }
    
    private func getTranslationConfig() -> SPXSpeechTranslationConfiguration? {
        return try? SPXSpeechTranslationConfiguration(subscription: subscriptionKey, region: subscriptionRegion)
    }
}
