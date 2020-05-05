//
//  PhotoJournalViewController.swift
//  PhotoJournal
//
//  Created by Erick Wesley Espinoza on 4/25/20.
//  Copyright © 2020 HazeStudio. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

enum PhotoVCTransitionAnims {
    case PhotoListToJournal
    case JournalToPhotoList
    case PhotoListToMediaSelector
    case MediaSelectorToPhotoList
    case MediaSelectorToJournal
}

class PhotoJournalViewController: UIViewController {
    let db = Firestore.firestore()
    let storage = Storage.storage()
    let photoCollectionView = PhotoCollectionView()
    let journalView = JournalView()
    let mediaSelectorview = MediaSelectorView()
    let screen = UIScreen.main
    var leadingAnchor: NSLayoutConstraint? = nil
    var topAnchor: NSLayoutConstraint? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView(){
        photoCollectionView.delegate = self
        self.view.addSubview(photoCollectionView)
        self.view.addSubview(journalView)
        self.view.addSubview(mediaSelectorview)
        mediaSelectorview.delegate = self
        self.title = "Photo Journal"
        topAnchor = photoCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor)
        leadingAnchor = photoCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        topAnchor?.isActive = true
        leadingAnchor?.isActive = true
        NSLayoutConstraint.activate([
            photoCollectionView.heightAnchor.constraint(equalToConstant: screen.bounds.height),
            photoCollectionView.widthAnchor.constraint(equalToConstant: screen.bounds.width),
            
            journalView.topAnchor.constraint(equalTo: self.view.topAnchor),
            journalView.leadingAnchor.constraint(equalTo: self.photoCollectionView.trailingAnchor),
            journalView.widthAnchor.constraint(equalToConstant: screen.bounds.width),
            journalView.heightAnchor.constraint(equalToConstant: screen.bounds.height),
            
            
            mediaSelectorview.topAnchor.constraint(equalTo: self.photoCollectionView.bottomAnchor),
            mediaSelectorview.leadingAnchor.constraint(equalTo: self.photoCollectionView.leadingAnchor),
            mediaSelectorview.widthAnchor.constraint(equalToConstant: screen.bounds.width),
            mediaSelectorview.heightAnchor.constraint(equalToConstant: screen.bounds.height)
        ])
        
        
        let logoutBarButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(logout))
        
        self.navigationItem.leftBarButtonItems = [logoutBarButton]
        
        let addEntryBarButton = UIBarButtonItem(title: "＋", style: .plain, target: self, action: #selector(gotoMediaSelector))
        
        self.navigationItem.rightBarButtonItems = [addEntryBarButton]
        
    }
    
    @objc func addEntry(){
        showSpinner(onView: self.view)
        if let userId = UserDefaults.standard.string(forKey: "UserId"){
            var ref: DocumentReference? = nil
            let textToSave = self.journalView.journalEntryTextView.text!
            let storageRef = storage.reference()
            let imageData = journalView.photoView.image?.pngData()
            let imagesRef = storageRef.child("images/\(NSUUID().uuidString)")

            let uploadTask = imagesRef.putData(imageData!, metadata: nil) { (metadata, error) in
    
                if (error != nil) {
                    print(error?.localizedDescription as Any)
                }
                
            }
            uploadTask.observe(.success) { snapshot in
              // Upload completed successfully
                imagesRef.downloadURL { (url, error) in
                  guard let downloadURL = url else {
                    print("Could not get image URL")
                    return
                  }
                    let date = NSDate();
                    let dateFormatter = DateFormatter()
                    //To prevent displaying either date or time, set the desired style to NoStyle.
                    dateFormatter.dateFormat = "M/d/yyyy, HH:mm a"
                    dateFormatter.timeZone = NSTimeZone() as TimeZone
                    let localDate = dateFormatter.string(from: date as Date)
                    
                  ref = self.db.collection("\(userId)").addDocument(data: [
                       "imagePath": "\(downloadURL)",
                       "textEntry": "\(textToSave)",
                    "timeStamp": "\(localDate)"
                   ]) { err in
                       if let err = err {
                           print("Error adding document: \(err)")
                       } else {
                           print("Document added with ID: \(ref!.documentID)")
                        self.photoCollectionView.updateCollectionView()
                       }
                   }
                }
                self.removeSpinner()
                self.animateViewFrame(animation: .JournalToPhotoList)
            }
            self.dismissKeyboard()
        }
    }
    
    @objc func gotoMediaSelector(){
        self.animateViewFrame(animation: .PhotoListToMediaSelector)
    }
    
    
    @objc func logout(){
        
        let firebaseAuth = Auth.auth()
        
        do {
          try firebaseAuth.signOut()
            
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
            return
        }
        
        UserDefaults.standard.removeObject(forKey: "UserId")
        self.navigationController?.popViewController(animated: true)
        self.navigationController?.viewControllers = [LoginSignUpViewController()]
    }
    
    @objc func cancel(){
        self.animateViewFrame(animation: .JournalToPhotoList)
        dismissKeyboard()
    }
    
    @objc func cancelFromMediaSelector(){
        self.animateViewFrame(animation: .MediaSelectorToPhotoList)
    }
    
    
    func animateViewFrame(animation: PhotoVCTransitionAnims){
        
        switch animation {
        case .PhotoListToJournal:
            UIView.animate(withDuration: 0.25) {
                
                self.leadingAnchor?.isActive = false
                self.leadingAnchor = self.photoCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -1 * self.screen.bounds.width)
                self.leadingAnchor?.isActive = true
                self.view.layoutIfNeeded()
                
                let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancel))
                
                let saveBarButton = UIBarButtonItem(title: "Update", style: .done, target: self, action: #selector(self.addEntry))
                
                self.navigationItem.rightBarButtonItems = [saveBarButton]
                self.navigationItem.leftBarButtonItems = [cancelBarButton]
                self.hideKeyboardTapped()
            }
            
            break
        case .JournalToPhotoList:
            UIView.animate(withDuration: 0.25) {
                
                self.leadingAnchor?.isActive = false
                self.leadingAnchor = self.photoCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
                self.leadingAnchor?.isActive = true
                self.view.layoutIfNeeded()
                let addEntryBarButton = UIBarButtonItem(title: "＋", style: .plain, target: self, action: #selector(self.gotoMediaSelector))
                self.journalView.journalEntryTextView.text = ""
                self.navigationItem.rightBarButtonItems = [addEntryBarButton]
                
                let logoutBarButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(self.logout))
                
                self.navigationItem.leftBarButtonItems = [logoutBarButton]
                for gesture in self.view.gestureRecognizers!{
                    self.view.removeGestureRecognizer(gesture)
                }
                
            }
            break
        case .PhotoListToMediaSelector:
            UIView.animate(withDuration: 0.25) {
                self.topAnchor?.isActive = false
                self.topAnchor = self.photoCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant:  -1*self.screen.bounds.height)
                self.topAnchor?.isActive = true
                self.view.layoutIfNeeded()
                let addEntryBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelFromMediaSelector))
                self.navigationItem.rightBarButtonItems = [addEntryBarButton]
                self.navigationItem.leftBarButtonItems = []
            }
            break
            
        case .MediaSelectorToPhotoList:
            UIView.animate(withDuration: 0.25) {
                self.topAnchor?.isActive = false
                self.topAnchor = self.photoCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor)
                self.leadingAnchor?.isActive = true
                self.view.layoutIfNeeded()
                let addEntryBarButton = UIBarButtonItem(title: "＋", style: .plain, target: self, action: #selector(self.gotoMediaSelector))
                self.navigationItem.rightBarButtonItems = [addEntryBarButton]
                let logoutBarButton = UIBarButtonItem(title: "Logout", style: .done, target: self, action: #selector(self.logout))
                self.navigationItem.leftBarButtonItems = [logoutBarButton]
            }
            break
            
        case .MediaSelectorToJournal:
                UIView.animate(withDuration: 0.25) {
                
                self.leadingAnchor?.isActive = false
                self.leadingAnchor = self.photoCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -1 * self.screen.bounds.width)
                self.leadingAnchor?.isActive = true
                self.view.layoutIfNeeded()
                
                let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(self.cancel))
                
                let saveBarButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(self.addEntry))
                
                self.navigationItem.rightBarButtonItems = [saveBarButton]
                self.navigationItem.leftBarButtonItems = [cancelBarButton]
                    self.hideKeyboardTapped()
            }
            
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.setHidesBackButton(true, animated: true)
    }
}

extension PhotoJournalViewController: UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }
        picker.dismiss(animated: true) {
            self.journalView.photoView.image = image
            self.animateViewFrame(animation: .MediaSelectorToJournal)
        }
    }
}

extension PhotoJournalViewController: UINavigationControllerDelegate{
    
}
