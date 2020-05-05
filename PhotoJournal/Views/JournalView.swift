//
//  JournalView.swift
//  PhotoJournal
//
//  Created by Erick Wesley Espinoza on 4/25/20.
//  Copyright © 2020 HazeStudio. All rights reserved.
//

import Foundation
import UIKit

class JournalView: UIView {
    
    let journalEntryTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .white
        textView.backgroundColor = .darkGray
        textView.isEditable = true
        textView.isSelectable = true
        
        return textView
    }()
    
    let photoView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "testImage")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView(){
        self.addSubview(journalEntryTextView)
        self.addSubview(photoView)
        
        NSLayoutConstraint.activate([
            
            photoView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: 0),
            photoView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            photoView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            photoView.heightAnchor.constraint(equalToConstant: 350),
            
            journalEntryTextView.topAnchor.constraint(equalTo: self.photoView.bottomAnchor, constant: 0),
            journalEntryTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            journalEntryTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            journalEntryTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
}
