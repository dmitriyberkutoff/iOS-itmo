//
//  RatingTableController.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 21.10.2022.
//

import UIKit
import Photos
import PhotosUI

private func randomString(length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  return String((0..<length).map{ _ in letters.randomElement()! })
}

class FilmController: UIViewController {
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    var delegate: TableDelegate?
    
    private var allowedYears: [String] = [String]()
    
    private lazy var headline: UILabel = {
        let lab = UILabel()
        lab.translatesAutoresizingMaskIntoConstraints = false
        lab.text = "Фильм"
        lab.textColor = .black
        lab.font = lab.font.withSize(30)
        return lab
    }()
    
    private lazy var saveButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Сохранить", for: .normal)
        b.layer.cornerRadius = 15
        b.alpha = 0.4
        b.backgroundColor = .systemGreen
        b.setTitleColor(.white, for: .normal)
        return b
    }()
    
    private lazy var randomButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Случайные данные", for: .normal)
        b.layer.cornerRadius = 15
        b.backgroundColor = .systemBlue
        b.setTitleColor(.white, for: .normal)
        return b
    }()
    
    private lazy var datePicker: UIPickerView = {
        let dp = UIPickerView(frame: .zero)
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.delegate = self
        dp.dataSource = self
        return dp
    }()
    
    private lazy var posterBack: UIImageView = {
        var v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        v.layer.borderWidth = 1.0
        v.layer.borderColor = UIColor.systemGray2.cgColor
        return v
    }()
    
    private lazy var imagePickerButton: UIButton = {
        var b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.setTitle("Выбрать изображение", for: .normal)
        b.setTitleColor(.systemGray, for: .normal)
        return b
    }()
    
    private lazy var nameFilm = NamedField()
    private lazy var directorFilm = NamedField()
    private lazy var dateFilm = NamedField()
    private lazy var rating = RatingClass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 1900..<2022 {
            allowedYears.append(String(i))
        }
        
        let date = FilmSettings.year
        if date != "" {
            dateFilm.textField.text = date
        }
        
        nameFilm.configureView(conf_label: "Название", conf_text: "Название фильма", minL: 1, maxL: 10)
        directorFilm.configureView(conf_label: "Режиссёр", conf_text: "Режиссер фильма", minL: 3, maxL: 10)
        dateFilm.configureView(conf_label: "Год", conf_text: "Год выпуска")
        
        view.addSubview(headline)
        view.addSubview(rating)
        view.addSubview(saveButton)
        view.addSubview(randomButton)
        view.addSubview(nameFilm)
        view.addSubview(directorFilm)
        view.addSubview(dateFilm)
        view.addSubview(posterBack)
        view.addSubview(imagePickerButton)
        nameFilm.delegate = self
        directorFilm.delegate = self
        dateFilm.delegate = self
        rating.delegate = self
        
        randomButton.addTarget(self, action: #selector(randomFill), for: .touchUpInside)
        imagePickerButton.addTarget(self, action: #selector(openPicker), for: .touchUpInside)
        
        datePicker.sizeToFit()
        dateFilm.textField.inputView = datePicker
        dateFilm.textField.inputAccessoryView = createToolbar()
        
        saveButton.isEnabled = false
        saveButton.addTarget(self, action: #selector(addFilm), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            headline.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headline.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            posterBack.topAnchor.constraint(equalTo: headline.bottomAnchor, constant: 20),
            posterBack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            posterBack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            posterBack.heightAnchor.constraint(equalToConstant: 150),

            imagePickerButton.leadingAnchor.constraint(equalTo: posterBack.leadingAnchor),
            imagePickerButton.trailingAnchor.constraint(equalTo: posterBack.trailingAnchor),
            imagePickerButton.topAnchor.constraint(equalTo: posterBack.topAnchor),
            imagePickerButton.bottomAnchor.constraint(equalTo: posterBack.bottomAnchor),

            nameFilm.topAnchor.constraint(equalTo: posterBack.bottomAnchor, constant: 16),
            nameFilm.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameFilm.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            directorFilm.topAnchor.constraint(equalTo: nameFilm.bottomAnchor, constant: 16),
            directorFilm.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            directorFilm.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateFilm.topAnchor.constraint(equalTo: directorFilm.bottomAnchor, constant: 16),
            dateFilm.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateFilm.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            rating.topAnchor.constraint(equalTo: dateFilm.bottomAnchor, constant: 30),
            rating.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            rating.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            saveButton.heightAnchor.constraint(equalToConstant: 52),
            saveButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -26),
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            randomButton.heightAnchor.constraint(equalToConstant: 52),
            randomButton.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -8),
            randomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            randomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

        ])
    }
    
    private func createToolbar() -> UIToolbar {
        let tb = UIToolbar()
        tb.sizeToFit()
        
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(endChosingDate))
        tb.setItems([done], animated: true)
        
        return tb
    }
    
    @objc
    func endChosingDate() {
        self.view.endEditing(true)
    }
    
    @objc
    func openPicker() {
        openPHPicker()
    }
    
    @objc
    func addFilm() {
        var posterId: String = FilmSettings.noPosterId
        if let image = posterBack.image {
            delegate?.postImage(image: image) {
                posterId = $0
                
                DispatchQueue.main.async {
                    self.delegate?.addInformation(name: self.nameFilm.textField.text!, director: self.directorFilm.textField.text!, date: self.dateFilm.textField.text!, rate: self.rating.rate, poster: posterId)
                    FilmSettings.rating = 0
                    FilmSettings.year = ""
                    
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            delegate?.addInformation(name: nameFilm.textField.text!, director: directorFilm.textField.text!, date: dateFilm.textField.text!, rate: rating.rate, poster: posterId)
            FilmSettings.rating = 0
            FilmSettings.year = ""
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc
    private func randomFill(sender: UIButton) {
        nameFilm.textField.text = randomString(length: Int.random(in: 1..<10))
        directorFilm.textField.text = randomString(length: Int.random(in: 3..<10))
        dateFilm.textField.text = String(Int.random(in: 1900..<2022))
        
        nameFilm.validation()
        directorFilm.validation()
        dateFilm.validation()
    }
}

extension FilmController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        allowedYears.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        allowedYears[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dateFilm.textField.text = allowedYears[row]
        dateFilm.delegate?.didChangeValidation()
    }
}

extension FilmController: EditingDelegate {
    func didChangeValidation() {
        guard let t1 = nameFilm.textField.text, !t1.isEmpty,
              let t2 = directorFilm.textField.text, !t2.isEmpty,
              let t3 = dateFilm.textField.text, !t3.isEmpty, rating.save else {
                saveButton.isEnabled = false
                saveButton.alpha = 0.4
                return
        }
        FilmSettings.year = dateFilm.textField.text
        saveButton.isEnabled = true
        saveButton.alpha = 1.0
    }
    
    func disableSave() {
        saveButton.isEnabled = false
        saveButton.alpha = 0.4
    }
}

extension FilmController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: .none)
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else { return }
                DispatchQueue.main.async {
                    self.posterBack.image = image
                    self.imagePickerButton.alpha = 0
                }
            }
        }
    }

    func openPHPicker() {
        var phPickerConfig = PHPickerConfiguration(photoLibrary: .shared())
        phPickerConfig.selectionLimit = 1
        phPickerConfig.filter = PHPickerFilter.any(of: [.images, .livePhotos])
        let phPickerVC = PHPickerViewController(configuration: phPickerConfig)
        phPickerVC.delegate = self
        present(phPickerVC, animated: true)
   }
}

protocol EditingDelegate: AnyObject {
    func didChangeValidation()
    
    func disableSave()
}
