//
//  FilmCell.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 22.10.2022.
//

import UIKit

class FilmCell: UITableViewCell {
    @IBOutlet private var name: UILabel!
    @IBOutlet private var director: UILabel!
    @IBOutlet private var day: UILabel!
    @IBOutlet private var star1: UIImageView!
    @IBOutlet private var star2: UIImageView!
    @IBOutlet private var star3: UIImageView!
    @IBOutlet private var star4: UIImageView!
    @IBOutlet private var star5: UIImageView!
    @IBOutlet public var poster: UIImageView!
    
    func setupView(with film: Film) {
        name.text = film.name
        director.text = film.director
        day.text = film.date
        changeRating(rate: film.rate)
    }
    
    private func changeRating(rate: Int) {
        switch rate {
        case 1:
            star1.image = UIImage(named: "StarYellow.png")
            star2.image = UIImage(named: "StarGray.png")
            star3.image = UIImage(named: "StarGray.png")
            star4.image = UIImage(named: "StarGray.png")
            star5.image = UIImage(named: "StarGray.png")
        case 2:
            star1.image = UIImage(named: "StarYellow.png")
            star2.image = UIImage(named: "StarYellow.png")
            star3.image = UIImage(named: "StarGray.png")
            star4.image = UIImage(named: "StarGray.png")
            star5.image = UIImage(named: "StarGray.png")
        case 3:
            star1.image = UIImage(named: "StarYellow.png")
            star2.image = UIImage(named: "StarYellow.png")
            star3.image = UIImage(named: "StarYellow.png")
            star4.image = UIImage(named: "StarGray.png")
            star5.image = UIImage(named: "StarGray.png")
        case 4:
            star1.image = UIImage(named: "StarYellow.png")
            star2.image = UIImage(named: "StarYellow.png")
            star3.image = UIImage(named: "StarYellow.png")
            star4.image = UIImage(named: "StarYellow.png")
            star5.image = UIImage(named: "StarGray.png")
        case 5:
            star1.image = UIImage(named: "StarYellow.png")
            star2.image = UIImage(named: "StarYellow.png")
            star3.image = UIImage(named: "StarYellow.png")
            star4.image = UIImage(named: "StarYellow.png")
            star5.image = UIImage(named: "StarYellow.png")
        default:
            return
        }
    }
}
