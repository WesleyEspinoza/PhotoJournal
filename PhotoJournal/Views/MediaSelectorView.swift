//
//  MediaSelectorView.swift
//  PhotoJournal
//
//  Created by Erick Wesley Espinoza on 4/25/20.
//  Copyright © 2020 HazeStudio. All rights reserved.
//

import Foundation
import UIKit

class MediaSelectorView: UIView {
    
    var delegate: PhotoJournalViewController? = nil
    
    let galleryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Gallery", for: .normal)
        button.addTarget(self, action: #selector(galleryButtonClicked), for: .touchUpInside)
        return button
    }()
    
    let cameraButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .lightGray
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Camera", for: .normal)
        button.addTarget(self, action: #selector(cameraButtonClicked), for: .touchUpInside)
        return button
    }()
    
    @objc func galleryButtonClicked(){
        let vc = UIImagePickerController()
        vc.sourceType = .savedPhotosAlbum
        vc.allowsEditing = true
        vc.delegate = delegate
        delegate?.navigationController?.present(vc, animated: true, completion: {
            self.delegate?.animateViewFrame(animation: .MediaSelectorToPhotoList)
        })
    }
    
    @objc func cameraButtonClicked(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = delegate
        delegate?.navigationController?.present(vc, animated: true, completion: {
            self.delegate?.animateViewFrame(animation: .MediaSelectorToPhotoList)
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        
        setupButtons()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupButtons() {
        self.addSubview(galleryButton)
        self.addSubview(cameraButton)
        
        
        NSLayoutConstraint.activate([
            galleryButton.heightAnchor.constraint(equalToConstant: 50),
            galleryButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.5),
            galleryButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            galleryButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -30),
            
            cameraButton.heightAnchor.constraint(equalToConstant: 50),
            cameraButton.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width / 1.5),
            cameraButton.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            cameraButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 30),
            
        ])
    }
    
}
