//
//  RatingBlock.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 12.10.2022.
//

import UIKit

class RatingClass: UIView {
    
    public var save: Bool = false
    
    var rate: Int = 0
    
    weak var delegate: EditingDelegate?
    
    private func star(tag: Int) -> UIButton {
        let b = UIButton()
        b.translatesAutoresizingMaskIntoConstraints = false
        b.tag = tag
        b.setImage(UIImage(named: "StarGray.png"), for: .normal)
        b.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return b
    }

    private lazy var star1 = star(tag: 1)
    private lazy var star2 = star(tag: 2)
    private lazy var star3 = star(tag: 3)
    private lazy var star4 = star(tag: 4)
    private lazy var star5 = star(tag: 5)
    
    private lazy var label: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.text = "Ваша оценка"
        l.textColor = .systemGray
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        
        rate = UserDefaults.standard.integer(forKey: FilmSettings.Keys.rating.rawValue)
        if rate != 0 {
            switch rate {
            case 1: didTapButton(sender: star1)
            case 2: didTapButton(sender: star2)
            case 3: didTapButton(sender: star3)
            case 4: didTapButton(sender: star4)
            case 5: didTapButton(sender: star5)
            default:
                return
            }
        }
        
        addSubview(star1)
        addSubview(star2)
        addSubview(star3)
        addSubview(star4)
        addSubview(star5)
        addSubview(label)

        NSLayoutConstraint.activate([
            star1.topAnchor.constraint(equalTo: topAnchor),
            star2.topAnchor.constraint(equalTo: topAnchor),
            star3.topAnchor.constraint(equalTo: topAnchor),
            star4.topAnchor.constraint(equalTo: topAnchor),
            star5.topAnchor.constraint(equalTo: topAnchor),
            
            star3.centerXAnchor.constraint(equalTo: centerXAnchor),
            star2.trailingAnchor.constraint(equalTo: star3.leadingAnchor, constant: -12),
            star1.trailingAnchor.constraint(equalTo: star2.leadingAnchor, constant: -12),
            star4.leadingAnchor.constraint(equalTo: star3.trailingAnchor, constant: 12),
            star5.leadingAnchor.constraint(equalTo: star4.trailingAnchor, constant: 12),
            
            label.topAnchor.constraint(equalTo: star3.bottomAnchor, constant: 20),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    @objc
    private func didTapButton(sender: UIButton) {
        save = true
        rate = sender.tag
        FilmSettings.rating = rate
        delegate?.didChangeValidation()
        switch sender.tag {
        case 1:
            star1.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star2.setImage(UIImage(named: "StarGray.png"), for: .normal)
            star3.setImage(UIImage(named: "StarGray.png"), for: .normal)
            star4.setImage(UIImage(named: "StarGray.png"), for: .normal)
            star5.setImage(UIImage(named: "StarGray.png"), for: .normal)
            label.text = "Ужасно"
        case 2:
            star1.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star2.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star3.setImage(UIImage(named: "StarGray.png"), for: .normal)
            star4.setImage(UIImage(named: "StarGray.png"), for: .normal)
            star5.setImage(UIImage(named: "StarGray.png"), for: .normal)
            label.text = "Плохо"
        case 3:
            star1.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star2.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star3.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star4.setImage(UIImage(named: "StarGray.png"), for: .normal)
            star5.setImage(UIImage(named: "StarGray.png"), for: .normal)
            label.text = "Нормально"
        case 4:
            star1.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star2.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star3.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star4.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star5.setImage(UIImage(named: "StarGray.png"), for: .normal)
            label.text = "Хорошо"
        case 5:
            star1.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star2.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star3.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star4.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            star5.setImage(UIImage(named: "StarYellow.png"), for: .normal)
            label.text = "AMAZING!"
        default:
            return
        }
    }
}
