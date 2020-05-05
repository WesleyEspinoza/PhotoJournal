//
//  PhotoCollectionView.swift
//  PhotoJournal
//
//  Created by Erick Wesley Espinoza on 4/25/20.
//  Copyright © 2020 HazeStudio. All rights reserved.
//

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class PhotoCollectionView: UIView {
    var delegate: PhotoJournalViewController? = nil
    let db = Firestore.firestore()
    var entries: [Entry] = [] {
        didSet{
            photoCollectionView.reloadData()
        }
    }
    let photoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setupCollectionView()
        updateCollectionView()
    }
    
    func updateCollectionView(){
        if let userId = UserDefaults.standard.string(forKey: "UserId"){
            db.collection("\(userId)").order(by: "timeStamp", descending: true).getDocuments() { (querySnapshot, err) in
                 if let err = err {
                     print("Error getting documents: \(err)")
                 } else {
                    self.entries = []
                     for document in querySnapshot!.documents {
                         let result = Result {
                             try document.data(as: Entry.self)
                         }
                         switch result {
                         case .success(let entry):
                             if let entry = entry {
                                 self.entries.append(entry)
                             } else {
                                 // A nil value was successfully initialized from the DocumentSnapshot,
                                 // or the DocumentSnapshot was nil.
                                 print("Document does not exist")
                             }
                         case .failure(let error):

                             print("Error decoding city: \(error)")
                         }
                         
                     }
                 }
             }
         }
    }
    
    func setupCollectionView(){
        photoCollectionView.delegate = self
        photoCollectionView.dataSource = self
        self.photoCollectionView.allowsMultipleSelection = false
        self.addSubview(photoCollectionView)
        
        
        NSLayoutConstraint.activate([
            photoCollectionView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            photoCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            photoCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            photoCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoCollectionView: UICollectionViewDelegate{
    
}

extension PhotoCollectionView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = photoCollectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        cell.entry = entries[indexPath.row]
        cell.photoCaptionLabel.text = entries[indexPath.row].timeStamp
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.delegate?.animateViewFrame(animation: .PhotoListToJournal)
        let cell = photoCollectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        self.delegate?.journalView.photoView.image = cell.photoView.image
        self.delegate?.journalView.journalEntryTextView.text = cell.entry?.textEntry
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
}


extension PhotoCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 4 * 1.8, height: collectionView.bounds.height / 4 )
    }
    
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 25, left: 10, bottom: 25, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 40
    }
    
    
}
