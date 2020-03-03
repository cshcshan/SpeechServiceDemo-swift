//
//  SpeechTranslationViewController.swift
//  speechservicedemo
//
//  Created by Han Chen on 2020/3/3.
//  Copyright © 2020 Han Chen. All rights reserved.
//

import UIKit
import AVFoundation

class SpeechTranslationViewController: UIViewController {
    
    var label: UILabel!
    var translateButton: UIButton!
    var stopButton: UIButton!
    
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
        label.text = "Please press \"Translate\" button below then speech ... \n* 繁中 to English only at the mement."
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        translateButton = generateButton(title: "Translate", selector: #selector(translateButtonPressed))
        stopButton = generateButton(title: "Stop", selector: #selector(stopButtonPressed))
        addVerticalConstraints()
        addHorizontalConstraint(label, id: "label")
        addHorizontalConstraint(translateButton, id: "translateButton")
        addHorizontalConstraint(stopButton, id: "stopButton")
    }
    
    private func generateButton(title: String, selector: Selector) -> UIButton {
        let uiwidth = UIScreen.main.bounds.width - 40
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: uiwidth, height: 50)))
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.setTitleColor(.blue, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        return button
    }
    
    private func addVerticalConstraints() {
        let views: [String: UIView] = ["view": view,
                                       "label": label,
                                       "translateButton": translateButton,
                                       "stopButton": stopButton]
        let metrics: [String: CGFloat] = ["buttonHeight": 50, "top": 20 + 44, "bottom": 20 + 20]
        var verticalFormat = "V:|-(top)-[label]-10@100-[translateButton(buttonHeight)]"
        verticalFormat.append("-5-[stopButton(buttonHeight)]-(bottom)-|")
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: verticalFormat, options: .directionLeadingToTrailing, metrics: metrics, views: views)
        view.addConstraints(verticalConstraint)
    }
    
    private func addHorizontalConstraint(_ button: UIView, id: String) {
        let views: [String: UIView] = ["view": view,
                                       "label": label,
                                       "translateButton": translateButton,
                                       "stopButton": stopButton]
        let metrics: [String: CGFloat] = ["buttonHeight": button.frame.height]
        let horizontalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-20-[\(id)]-20-|", options: .directionLeadingToTrailing, metrics: metrics, views: views)
        view.addConstraints(horizontalConstraint)
    }
    
    @objc func translateButtonPressed() {
        label.text = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.viewModel.translateSpeechToSpeech(fromLang: "zh-TW", toLang: "en", voiceName: "en-US-JessaRUS")
        }
    }
    
    @objc func stopButtonPressed() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.viewModel.stop(needUpdateLabel: true)
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

extension SpeechTranslationViewController {
    
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
