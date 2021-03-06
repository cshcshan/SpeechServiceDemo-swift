//
//  ViewModel.swift
//  speechservicedemo
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
    
    private var speechRecognizer: SPXSpeechRecognizer?
    private var translationRecognizer: SPXTranslationRecognizer?
    
    func recognizeFileToText(wavFilePath: String, fromLang: String) {
        stop(needUpdateLabel: false)
        
        guard let speechConfig = getSpeechConfig() else {
            print("speechConfig is null")
            return
        }
        
        speechConfig.speechRecognitionLanguage = fromLang
        
        guard let audioConfig = getAudioConfigFromFile(wavFilePath) else {
            print("audioConfig is null")
            return
        }
        
        print("Recognizing file to text ...")
        updateLabel(text: "Recognizing file to text ... ", color: .gray)
        
        speechRecognizer = try! SPXSpeechRecognizer(speechConfiguration: speechConfig,
                                                    audioConfiguration: audioConfig)
        
        guard let recognizer = speechRecognizer else { return }
        
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
        stop(needUpdateLabel: false)
        
        guard let translationConfig = getTranslationConfig() else {
            print("translationConfig is null")
            return
        }
        
        translationConfig.speechRecognitionLanguage = fromLang
        for lang in toLangs {
            translationConfig.addTargetLanguage(lang)
        }
        
        guard let audioConfig = getAudioConfigFromFile(wavFilePath) else {
            print("audioConfig is null")
            return
        }
        
        print("Translating file to text ...")
        updateLabel(text: "Translating file to text ...", color: .gray)
        
        translationRecognizer = try! SPXTranslationRecognizer(speechTranslationConfiguration: translationConfig,
                                                              audioConfiguration: audioConfig)
        
        guard let recognizer = translationRecognizer else { return }
        
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
        stop(needUpdateLabel: false)
        
        guard let translationConfig = getTranslationConfig() else {
            print("translationConfig is null")
            return
        }
        
        translationConfig.speechRecognitionLanguage = fromLang
        translationConfig.addTargetLanguage(toLang)
        translationConfig.voiceName = voiceName
        
        guard let audioConfig = getAudioConfigFromFile(wavFilePath) else {
            print("audioConfig is null")
            return
        }
        
        print("Translating file to speech ...")
        updateLabel(text: "Translating file to speech ...", color: .gray)
        
        translationRecognizer = try! SPXTranslationRecognizer(speechTranslationConfiguration: translationConfig,
                                                              audioConfiguration: audioConfig)
        
        guard let recognizer = translationRecognizer else { return }
        
        recognizer.addSynthesizingEventHandler { [weak self] (reco, env) in
            guard let audio = env.result.audio else {
                print("audio is null")
                return
            }
            guard audio.count > 0 else { return }
            print("audio size: \(audio.count)")
//            print("AUDIO SYNTHESIZED: \(audio.count) byte(s)")
//            print("AUDIO SYNTHESIZED: \(audio.count) byte(s) (COMPLETE)")
//            if let data = Data(base64Encoded: audio.base64EncodedData(), options: .ignoreUnknownCharacters) {
//                self?.playAudio(data)
//            }
            self?.playAudio(audio)
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
    
    func translateSpeechToSpeech(fromLang: String, toLang: String, voiceName: String) {
        stop(needUpdateLabel: false)
        
        guard let translationConfig = getTranslationConfig() else {
            print("translationConfig is null")
            return
        }
        
        translationConfig.speechRecognitionLanguage = fromLang
        translationConfig.addTargetLanguage(toLang)
        translationConfig.voiceName = voiceName
        
        guard let audioConfig = getAudioConfigFromMic() else {
            print("audioConfig is null")
            return
        }
        
        print("Translating speech to speech ...")
        updateLabel(text: "Translating speech ...", color: .gray)
        
        translationRecognizer = try! SPXTranslationRecognizer(speechTranslationConfiguration: translationConfig,
                                                              audioConfiguration: audioConfig)
        
        guard let recognizer = translationRecognizer else { return }
        
        recognizer.addSynthesizingEventHandler { [weak self] (reco, env) in
            guard let audio = env.result.audio else {
                print("audio is null")
                return
            }
            guard audio.count > 0 else { return }
            print("audio size: \(audio.count)")
            self?.playAudio(audio)
        }
        
        recognizer.addRecognizingEventHandler { [weak self] (reco, env) in
            print("intermediate recognition result: \(env.result.text ?? "(no result)")")
            self?.updateLabel(text: env.result.text ?? "", color: .gray)
        }
        
        //
        
        recognizer.addRecognizedEventHandler { [weak self] (reco, env) in
            let result = env.result
            print("RecognizedEventHandler ")
            switch result.reason {
            case .translatedSpeech:
                print(result.translations)
                var msg = "RECOGNIZED \(fromLang) : \(result.text ?? "")"
                msg += "\nTRANSLATED into \(toLang) : \(result.translations[toLang] ?? "")"
                print(msg)
                self?.updateLabel(text: msg, color: .black)
            case .recognizedSpeech:
                print("RECOGNIZED \(fromLang) : \(result.text ?? "") (text could not be translated)")
            case .noMatch:
                print("NOMATCH: Speech could not be recognized.")
            case .canceled:
                let detail = try! SPXCancellationDetails(fromCanceledRecognitionResult: result)
                print("cancelled, detail: \(detail.errorDetails!)")
                self?.updateLabel(text: "cancelled, detail: \(detail.errorDetails!)", color: .black)
                if detail.reason == .error {
                    print("CANCELED: ErrorCode=\(detail.errorCode)")
                    print("CANCELED: ErrorDetails=\(detail.errorDetails ?? "")")
                    print("CANCELED: Did you update the subscription info?")
                }
            default:
                print("There was an error.")
                self?.updateLabel(text: "Speech Recognition Error", color: .red)
            }
        }
        
        recognizer.addCanceledEventHandler { (reco, env) in
            print("cancel recognizer")
        }
        
        recognizer.addSessionStartedEventHandler { (reco, env) in
            print("session started")
        }
        
        recognizer.addSessionStoppedEventHandler { (reco, env) in
            print("session stopped")
        }
        
        try! recognizer.startContinuousRecognition()
//        try! recognizer.stopContinuousRecognition()
        
//        let result = try! recognizer.recognizeOnce()
//
//        switch result.reason {
//        case .translatedSpeech:
//            print(result.translations)
//            var msg = "RECOGNIZED \(fromLang) : \(result.text ?? "")"
//            msg += "\nTRANSLATED into \(toLang) : \(result.translations[toLang] ?? "")"
//            print(msg)
//            updateLabel(text: msg, color: .black)
//        case .recognizedSpeech:
//            print("RECOGNIZED \(fromLang) : \(result.text ?? "") (text could not be translated)")
//        case .noMatch:
//            print("NOMATCH: Speech could not be recognized.")
//        case .canceled:
//            let detail = try! SPXCancellationDetails(fromCanceledRecognitionResult: result)
//            print("cancelled, detail: \(detail.errorDetails!)")
//            updateLabel(text: "cancelled, detail: \(detail.errorDetails!)", color: .black)
//            if detail.reason == .error {
//                print("CANCELED: ErrorCode=\(detail.errorCode)")
//                print("CANCELED: ErrorDetails=\(detail.errorDetails ?? "")")
//                print("CANCELED: Did you update the subscription info?")
//            }
//        default:
//            print("There was an error.")
//            updateLabel(text: "Speech Recognition Error", color: .red)
//        }
    }
    
    func translateStreamToSpeech(wavFilePath: String, fromLang: String, toLang: String, voiceName: String) {
        stop(needUpdateLabel: false)
        
        guard let translationConfig = getTranslationConfig() else {
            print("translationConfig is null")
            return
        }
        
        translationConfig.speechRecognitionLanguage = fromLang
        translationConfig.addTargetLanguage(toLang)
        translationConfig.voiceName = voiceName
        
        guard let audioConfig = getAudioConfigInputStream(wavFilePath) else {
            print("audioConfig is null")
            return
        }
        
        print("Translating stream to speech ...")
        updateLabel(text: "Translating file stream to speech ...", color: .gray)
        
        translationRecognizer = try! SPXTranslationRecognizer(speechTranslationConfiguration: translationConfig,
                                                              audioConfiguration: audioConfig)
        
        guard let recognizer = translationRecognizer else { return }
        
        recognizer.addSynthesizingEventHandler { [weak self] (reco, env) in
            guard let audio = env.result.audio else {
                print("audio is null")
                return
            }
            guard audio.count > 0 else { return }
            print("audio size: \(audio.count)")
            self?.playAudio(audio)
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
    
    func stop(needUpdateLabel: Bool) {
        if let recognizer = speechRecognizer {
            try! recognizer.stopContinuousRecognition()
            if needUpdateLabel {
                updateLabel(text: "Speech recognizer is terminated\n\nPlease press \"Translate\" button below then speech ... \n* 繁中 to English only at the mement.", color: .black)
            }
        }
        if let recognizer = translationRecognizer {
            try! recognizer.stopContinuousRecognition()
            updateLabel(text: "Translation recognizer is terminated\n\nPlease press \"Translate\" button below then speech ... \n* 繁中 to English only at the mement.", color: .black)
        }
        speechRecognizer = nil
        translationRecognizer = nil
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
    
    private func getAudioConfigFromMic() -> SPXAudioConfiguration? {
        return SPXAudioConfiguration()
    }
    
    private func getAudioConfigFromFile(_ wavFilePath: String) -> SPXAudioConfiguration? {
        guard !wavFilePath.isEmpty else { return nil }
        return SPXAudioConfiguration(wavFileInput: wavFilePath)
    }
    
    private func getAudioConfigInputStream(_ wavFilePath: String) -> SPXAudioConfiguration? {
        guard !wavFilePath.isEmpty else { return nil }
        let fileUrl = URL(fileURLWithPath: wavFilePath)
        guard let data = try? Data(contentsOf: fileUrl) else { return nil }
        guard let format = SPXAudioStreamFormat(usingPCMWithSampleRate: 16000, bitsPerSample: 16, channels: 1) else { return nil }
        guard let inputStream = SPXPushAudioInputStream(audioFormat: format) else { return nil }
        inputStream.write(data)
        return SPXAudioConfiguration(streamInput: inputStream)
    }
    
    private func getTranslationConfig() -> SPXSpeechTranslationConfiguration? {
        return try? SPXSpeechTranslationConfiguration(subscription: subscriptionKey, region: subscriptionRegion)
    }
}
