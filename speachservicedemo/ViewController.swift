//
//  ViewController.swift
//  speachservicedemo
//
//  Created by Han Chen on 2020/2/19.
//  Copyright © 2020 Han Chen. All rights reserved.
//

/*
 
 Endpoint: https://westus.api.cognitive.microsoft.com/sts/v1.0
 
 Key 1: af5eea9e142b400783782dad119736eb
 Key 2: 782b2f38a27c405e8120104cefd2e971
 
 */

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    var label: UILabel!
    var recognizeFileToTextButton: UIButton!
    var translationFileToTextButton: UIButton!
    var translateFileToSpeechButton: UIButton!
    var translateSpeechToSpeechButton: UIButton!
    
    var player: AVAudioPlayer? // must be a global variable or it doesn't work
    
    private let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    private func setupUI() {
        let uiwidth = UIScreen.main.bounds.width - 40
        
        label = UILabel(frame: CGRect(x: 20, y: 20, width: uiwidth, height: 200))
        label.textColor = .black
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.text = ""
        
        recognizeFileToTextButton = UIButton(frame: CGRect(x: 20, y: 400, width: uiwidth, height: 50))
        recognizeFileToTextButton.setTitle("Recognition from file", for: .normal)
        recognizeFileToTextButton.addTarget(self, action: #selector(recognizeFileToTextButtonPressed), for: .touchUpInside)
        recognizeFileToTextButton.setTitleColor(.blue, for: .normal)
        
        translationFileToTextButton = UIButton(frame: CGRect(x: 20, y: 460, width: uiwidth, height: 50))
        translationFileToTextButton.setTitle("Translation from file to text", for: .normal)
        translationFileToTextButton.addTarget(self, action: #selector(translationFileToTextButtonPressed), for: .touchUpInside)
        translationFileToTextButton.setTitleColor(.blue, for: .normal)
        
        translateFileToSpeechButton = UIButton(frame: CGRect(x: 20, y: 520, width: uiwidth, height: 50))
        translateFileToSpeechButton.setTitle("Translation from file to speech", for: .normal)
        translateFileToSpeechButton.addTarget(self, action: #selector(translateFileToSpeechButtonPressed), for: .touchUpInside)
        translateFileToSpeechButton.setTitleColor(.blue, for: .normal)
        
        translateSpeechToSpeechButton = UIButton(frame: CGRect(x: 20, y: 580, width: uiwidth, height: 50))
        translateSpeechToSpeechButton.setTitle("Translation speech to speech", for: .normal)
        translateSpeechToSpeechButton.addTarget(self, action: #selector(translateSpeechToSpeechButtonPressed), for: .touchUpInside)
        translateSpeechToSpeechButton.setTitleColor(.blue, for: .normal)
        
        view.addSubview(label)
        view.addSubview(recognizeFileToTextButton)
        view.addSubview(translationFileToTextButton)
        view.addSubview(translateFileToSpeechButton)
        view.addSubview(translateSpeechToSpeechButton)
    }
    
    @objc func recognizeFileToTextButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let path = Bundle.main.path(forResource: "whatstheweatherlike", ofType: "wav")!
            self?.viewModel.recognizeFileToText(wavFilePath: path, fromLang: "en-US")
        }
    }
    
    @objc func translationFileToTextButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let path = Bundle.main.path(forResource: "whatstheweatherlike", ofType: "wav")!
            self?.viewModel.translationFileToText(wavFilePath: path, fromLang: "en-US", toLangs: ["zh-Hant", "fr"])
        }
    }
    
    @objc func translateFileToSpeechButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let path = Bundle.main.path(forResource: "whatstheweatherlike", ofType: "wav")!
            // Sets the synthesis output voice name.
            // Replace with the languages of your choice, from list found here: https://aka.ms/speech/tts-languages
            // https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/language-support
            self?.viewModel.translateFileToSpeech(wavFilePath: path, fromLang: "en-US", toLang: "zh-Hant", voiceName: "zh-TW-Yating-Apollo")
        }
    }
    
    @objc func translateSpeechToSpeechButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.viewModel.translateSpeechToSpeech(fromLang: "zh-TW", toLang: "en", voiceName: "en-US-JessaRUS")
        }
    }
    
    private func setupBindings() {
        viewModel.updateLabel = { text in
            DispatchQueue.main.async { [weak self] in
                self?.label.text = text
            }
        }
        viewModel.updateLabelColor = { color in
            DispatchQueue.main.async { [weak self] in
                self?.label.textColor = color
            }
        }
        viewModel.playAudio = { data in
            DispatchQueue.main.async { [weak self] in
                self?.playAudio(data: data)
            }
        }
    }
}

extension ViewController {

    private func playAudio(data: Data) {
        print("Play Audio ...")
        print("data size is \(data.count)")
        if player != nil {
            player?.stop()
            player = nil
        }
        player = try? AVAudioPlayer(data: data)
        guard let player = player else {
            print("player is null")
            return
        }
        player.play()
    }
}
