//
//  ViewController.swift
//  speechservicedemo
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
    var translateFileToTextButton: UIButton!
    var translateFileToSpeechButton: UIButton!
    var translateSpeechToSpeechButton: UIButton!
    var translateStreamToSpeechButton: UIButton!
    
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
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        recognizeFileToTextButton = generateButton(title: "Recognition from file", selector: #selector(recognizeFileToTextButtonPressed))
        translateFileToTextButton = generateButton(title: "Translation from file to text", selector: #selector(translateFileToTextButtonPressed))
        translateFileToSpeechButton = generateButton(title: "Translation from file to speech", selector: #selector(translateFileToSpeechButtonPressed))
        translateSpeechToSpeechButton = generateButton(title: "Translation speech to speech", selector: #selector(translateSpeechToSpeechButtonPressed))
        translateStreamToSpeechButton = generateButton(title: "Translation stream to speech", selector: #selector(translateStreamToSpeechButtonPressed))
        addVerticalConstraints()
        addHorizontalConstraint(label, id: "label")
        addHorizontalConstraint(recognizeFileToTextButton, id: "recognizeFileToTextButton")
        addHorizontalConstraint(translateFileToTextButton, id: "translateFileToTextButton")
        addHorizontalConstraint(translateFileToSpeechButton, id: "translateFileToSpeechButton")
        addHorizontalConstraint(translateSpeechToSpeechButton, id: "translateSpeechToSpeechButton")
        addHorizontalConstraint(translateStreamToSpeechButton, id: "translateStreamToSpeechButton")
    }
    
    private func generateButton(title: String, selector: Selector) -> UIButton {
        let uiwidth = UIScreen.main.bounds.width - 40
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: uiwidth, height: 50)))
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.setTitleColor(.blue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        return button
    }
    
    private func addVerticalConstraints() {
        let views: [String: UIView] = ["view": view,
                                       "label": label,
                                       "recognizeFileToTextButton": recognizeFileToTextButton,
                                       "translateFileToTextButton": translateFileToTextButton,
                                       "translateFileToSpeechButton": translateFileToSpeechButton,
                                       "translateSpeechToSpeechButton": translateSpeechToSpeechButton,
                                       "translateStreamToSpeechButton": translateStreamToSpeechButton]
        let metrics: [String: CGFloat] = ["buttonHeight": 50, "top": 20 + 44]
        var verticalFormat = "V:|-(top)-[label]-10@100-[recognizeFileToTextButton(buttonHeight)]"
        verticalFormat.append("-5-[translateFileToTextButton(buttonHeight)]")
        verticalFormat.append("-5-[translateFileToSpeechButton(buttonHeight)]")
        verticalFormat.append("-5-[translateSpeechToSpeechButton(buttonHeight)]")
        verticalFormat.append("-5-[translateStreamToSpeechButton(buttonHeight)]-10-|")
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: verticalFormat, options: .directionLeadingToTrailing, metrics: metrics, views: views)
        view.addConstraints(verticalConstraint)
    }
    
    private func addHorizontalConstraint(_ button: UIView, id: String) {
        let views: [String: UIView] = ["view": view,
                                       "label": label,
                                       "recognizeFileToTextButton": recognizeFileToTextButton,
                                       "translateFileToTextButton": translateFileToTextButton,
                                       "translateFileToSpeechButton": translateFileToSpeechButton,
                                       "translateSpeechToSpeechButton": translateSpeechToSpeechButton,
                                       "translateStreamToSpeechButton": translateStreamToSpeechButton]
        let metrics: [String: CGFloat] = ["buttonHeight": button.frame.height]
        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[\(id)]-20-|", options: .directionLeadingToTrailing, metrics: metrics, views: views)
        view.addConstraints(horizontalConstraint)
    }
    
    @objc func recognizeFileToTextButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let path = Bundle.main.path(forResource: "whatstheweatherlike", ofType: "wav")!
            self?.viewModel.recognizeFileToText(wavFilePath: path, fromLang: "en-US")
        }
    }
    
    @objc func translateFileToTextButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var path = Bundle.main.path(forResource: "whatstheweatherlike", ofType: "wav")!
            self?.viewModel.translationFileToText(wavFilePath: path, fromLang: "en-US", toLangs: ["zh-Hant", "fr"])
            path = Bundle.main.path(forResource: "wreck-a-nice-beach", ofType: "wav")!
            self?.viewModel.translationFileToText(wavFilePath: path, fromLang: "en-US", toLangs: ["zh-Hant", "fr"])
        }
    }
    
    @objc func translateFileToSpeechButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var path = Bundle.main.path(forResource: "whatstheweatherlike", ofType: "wav")!
            // Sets the synthesis output voice name.
            // Replace with the languages of your choice, from list found here: https://aka.ms/speech/tts-languages
            // https://docs.microsoft.com/en-us/azure/cognitive-services/speech-service/language-support
            self?.viewModel.translateFileToSpeech(wavFilePath: path, fromLang: "en-US", toLang: "zh-Hant", voiceName: "zh-TW-Yating-Apollo")
            path = Bundle.main.path(forResource: "wreck-a-nice-beach", ofType: "wav")!
            self?.viewModel.translateFileToSpeech(wavFilePath: path, fromLang: "en-US", toLang: "zh-Hant", voiceName: "zh-TW-Yating-Apollo")
        }
    }
    
    @objc func translateSpeechToSpeechButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.viewModel.translateSpeechToSpeech(fromLang: "zh-TW", toLang: "en", voiceName: "en-US-JessaRUS")
        }
    }
    
    @objc func translateStreamToSpeechButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let path = Bundle.main.path(forResource: "whatstheweatherlike", ofType: "wav")!
            self?.viewModel.translateStreamToSpeech(wavFilePath: path, fromLang: "en-US", toLang: "zh-Hant", voiceName: "zh-TW-Yating-Apollo")
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
