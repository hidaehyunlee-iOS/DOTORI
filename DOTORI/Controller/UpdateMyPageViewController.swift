//
//  UpdateMyPageViewController.swift
//  DOTORI
//
//  Created by 도토리묵 on 2023/08/14.
//

import UIKit
import Photos
import PhotosUI

protocol UpdateMyPageDelegate: AnyObject {
    func updateUserInformation(profileImage: UIImage?, name: String, nickname: String, githubUrl: String, blogUrl: String, userIntro: String)
}

class UpdateMyPageViewController: UIViewController, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var updateCancelButton: UIButton!
    @IBOutlet weak var updateCompleteButton: UIButton!
    @IBOutlet weak var updateImageView: UIImageView!
    @IBOutlet weak var updateUrlTextField: UITextField!
    @IBOutlet weak var updateNameTextField: UITextField!
    @IBOutlet weak var updateTextView: UITextView!
    @IBOutlet weak var updateImageButton: UIButton!
    @IBOutlet weak var updateGitHubUrlTextField: UITextField!
    @IBOutlet weak var updateNicknameTextField: UITextField!
    
    var placeholderLabel: UILabel!
    weak var delegate: UpdateMyPageDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        defaultUserInfo()
        updateTextView.delegate = self
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "자기소개를 적어주세요"
        placeholderLabel.font = UIFont.systemFont(ofSize: 14)
        placeholderLabel.sizeToFit()
        updateTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPoint(x: 5, y: updateTextView.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor.lightGray
        placeholderLabel.isHidden = !updateTextView.text.isEmpty
    }
    
    func configureUI() {
        let uiElements: [UIView] = [updateImageView, updateUrlTextField, updateNameTextField, updateTextView, updateImageButton, updateGitHubUrlTextField, updateNicknameTextField, updateCancelButton, updateCompleteButton]
        
        for element in uiElements {
            element.layer.borderWidth = 2.0
            element.layer.borderColor = UIColor.gray.cgColor
            element.layer.cornerRadius = 8.0
        }
        
        updateImageView.layer.cornerRadius = updateImageView.frame.size.width / 2
        updateImageView.clipsToBounds = true
    }
    
    func defaultUserInfo() {
        updateNicknameTextField.text = loginUser.nickname
        updateNameTextField.text = loginUser.name
        updateGitHubUrlTextField.text = loginUser.githubUrl
        updateUrlTextField.text = loginUser.blogUrl
        updateTextView.text = loginUser.userIntro
        updateImageView.image = loginUser.profileImage
    }
    
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func completeButtonTapped(_ sender: UIButton) {
        
        let updatedProfileImage = updateImageView.image
        let updatedName = updateNameTextField.text ?? ""
        let updatedNickname = updateNicknameTextField.text ?? ""
        let updatedGitHubUrl = updateGitHubUrlTextField.text ?? ""
        let updatedBlogUrl = updateUrlTextField.text ?? ""
        let updatedUserIntro = updateTextView.text ?? ""
        dismiss(animated: true) { [weak self] in
            self?.delegate?.updateUserInformation(
                profileImage: updatedProfileImage,
                name: updatedName,
                nickname: updatedNickname,
                githubUrl: updatedGitHubUrl,
                blogUrl: updatedBlogUrl,
                userIntro: updatedUserIntro
            )
        }
    }
    
    @IBAction func imageButtonTapped(_ sender: UIButton) {
        
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 1
        config.filter = PHPickerFilter.images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    let scaledImage = self.scaleImage(image, toSize: self.updateImageView.frame.size)
                    self.updateImageView.layer.cornerRadius = self.updateImageView.frame.size.width / 2
                    self.updateImageView.clipsToBounds = true
                    self.updateImageView.image = scaledImage
                }
            }
        }
    }
    
    func scaleImage(_ image: UIImage, toSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage ?? image
    }
}

extension UpdateMyPageViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
    }
}
