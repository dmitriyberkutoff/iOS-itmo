//
//  Server.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 23.12.2022.
//

import Foundation
import UIKit

struct Server {
    static let ip = "http://127.0.0.1:3131"
    static let getImageUrl = ip + "/image/"
    static let filmsUrl = ip + "/movies/"
    static let postImageUrl = ip + "/image/upload"
    
    static let token = "Bearer I1eWeEjojeDmAI5Es6Tqso9mT6eo2ZO0ijkhA4qkSDdXDT61uYEsDt99eQQzwZvhNrJfjRXFq8iwoAsJBTmAhvS1yaFtdwFoTIYcMRgOxGKto87xP5eii0shcAY5z19gHukrbLQkOEpQjXHq1MFifaiYFfO8zAoLpdmq5po5QPUZxDuvDyn68SWLVtCP1l2CetzjfRrOwKnL5bsoR5AMFKEaoSLalLGmQeoRoIVAvXvGmuPSsjhqJo6qc3eTuiX"
    
    static let session = URLSession(configuration: URLSessionConfiguration.default)
    
    static func getImage(id: String, completion: @escaping (UIImage) -> Void) {
        let url = URL(string: getImageUrl + id)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    completion(UIImage(data: data) ?? UIImage())
                }
            } else {
                return
            }
        }
        task.resume()
    }
    
    
    static func deleteFilm(id: Int) {
        let url = URL(string: filmsUrl + String(id))
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request)
        
        DispatchQueue.global().async{
            task.resume()
        }
    }
    
    static func changeRate(id: Int, rate: Int, completion: @escaping () -> Void) {
        let url = URL(string: filmsUrl + String(id))
        var request = URLRequest(url: url!)
        let data = ["rating": rate]
        request.httpMethod = "PATCH"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = try! JSONSerialization.data(withJSONObject: data, options: [])
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let _ = data else {
                return
            }
            guard error == nil else {
                return
            }
            DispatchQueue.main.async {
                completion()
            }
        }
        DispatchQueue.global().async {
            task.resume()
        }
    }

    static func postFilm(name: String, director: String, year: String, rate: Int, poster: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: filmsUrl)
        var request = URLRequest(url: url!)
        let data = ["movie": [
                "title": name,
                "director": director,
                "relise_date": Int(year) ?? 2000,
                "rating": rate,
                "poster_id": poster,
                "created_at": Int(Date().timeIntervalSince1970)]]
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        let body = try! JSONSerialization.data(withJSONObject: data, options: [])
        request.httpBody = body
        var curId = 0
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            let json = try! decoder.decode(FilmPostResponse.self, from: data)
            curId = json.data.movie.id
            DispatchQueue.main.async {
                completion(curId)
            }
        }
        DispatchQueue.global().async {
            task.resume()
        }
    }
    
    static func postImage(image: UIImage, completion: @escaping (String) -> Void) {
        let url = URL(string: postImageUrl)
        var request = URLRequest(url: url!)
        let data = image.jpegData(compressionQuality: 1.0)
        request.httpMethod = "POST"
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.addValue(token, forHTTPHeaderField: "Authorization")
        request.httpBody = data
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            let id = try! decoder.decode(ImagePostResponse.self, from: data).data.poster_id
            DispatchQueue.main.async {
                completion(id)
            }
        }
        DispatchQueue.global().async {
            task.resume()
        }
    }
    
    struct InfoMovie: Codable {
        let id: Int
        let title: String
        let director: String
        let relise_date: Int
        let rating: Int
        let poster_id: String
        let created_at: Int
    }

    struct MoviePostResponse: Codable {
        let movie: InfoMovie
    }

    struct FilmPostResponse: Codable {
        let error: Int
        let message: String
        let data: MoviePostResponse
    }

    struct ImageInfo: Codable {
        let poster_id: String
    }

    struct ImagePostResponse: Codable {
        let error: Int
        let message: String
        let data: ImageInfo
    }
}
