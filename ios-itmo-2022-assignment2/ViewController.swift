//
//  ViewController.swift
//  ios-itmo-2022-assignment2
//
//  Created by rv.aleksandrov on 29.09.2022.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private var table: UITableView!
    
    private var refresh: UIRefreshControl!
    private var dates = [String: Int]()
    private var dataSource = [DatedFilms]()
    private var sortedDS = [DatedFilms]()
    private var years = Set<String>()
    private var idSet = Set<Int>()
    
    private let cashedImages = NSCache<NSString, UIImage>()
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Фильмы"
        
        postImage(image: UIImage(systemName: "multiply.circle") ?? UIImage()) {
            FilmSettings.noPosterId = $0
        }
        
        getFilms(id: 1, cnt: 0)
        
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        table.dataSource = self
        table.delegate = self
        table.register(UINib(nibName: "FilmCell", bundle: nil), forCellReuseIdentifier: "FilmCell")
        table.refreshControl = refresh
    }
    
    private func getFilms(id: Int, cnt: Int) {
        if cnt > 100 {
            return
        }
        if idSet.contains(id) {
            getFilms(id: id+1, cnt: cnt)
            return
        }
        let url = URL(string: "http://127.0.0.1:3131/movies/" + String(id))
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("Bearer I1eWeEjojeDmAI5Es6Tqso9mT6eo2ZO0ijkhA4qkSDdXDT61uYEsDt99eQQzwZvhNrJfjRXFq8iwoAsJBTmAhvS1yaFtdwFoTIYcMRgOxGKto87xP5eii0shcAY5z19gHukrbLQkOEpQjXHq1MFifaiYFfO8zAoLpdmq5po5QPUZxDuvDyn68SWLVtCP1l2CetzjfRrOwKnL5bsoR5AMFKEaoSLalLGmQeoRoIVAvXvGmuPSsjhqJo6qc3eTuiX", forHTTPHeaderField: "Authorization")
        let task = self.session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(FilmPostResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.addToData(name: json.data.movie.title, director: json.data.movie.director, year: String(json.data.movie.relise_date), rate: json.data.movie.rating, poster: json.data.movie.poster_id)
                        self.idSet.insert(id)
                    }
                    self.getFilms(id: id+1, cnt: cnt)
                } catch {
                    self.getFilms(id: id+1, cnt: cnt+1)
                }
            } else {
                return
            }
        }
        task.resume()
    }
    
    private func getImage(id: String, completion: @escaping (UIImage) -> Void) {
        let url = URL(string: "http://127.0.0.1:3131/image/" + id)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("Bearer I1eWeEjojeDmAI5Es6Tqso9mT6eo2ZO0ijkhA4qkSDdXDT61uYEsDt99eQQzwZvhNrJfjRXFq8iwoAsJBTmAhvS1yaFtdwFoTIYcMRgOxGKto87xP5eii0shcAY5z19gHukrbLQkOEpQjXHq1MFifaiYFfO8zAoLpdmq5po5QPUZxDuvDyn68SWLVtCP1l2CetzjfRrOwKnL5bsoR5AMFKEaoSLalLGmQeoRoIVAvXvGmuPSsjhqJo6qc3eTuiX", forHTTPHeaderField: "Authorization")
        let task = self.session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completion(UIImage(data: data) ?? UIImage())
            } else {
                return
            }
        }
        task.resume()
    }

    @IBAction func onButtonPress(_ sender: UIButton) {
        guard let film = UIStoryboard(name: "FilmController", bundle: nil).instantiateInitialViewController() as? FilmController else { return }
        film.delegate = self
        self.navigationController?.pushViewController(film, animated: true)
    }
    
    @objc
    private func onRefresh() {
        getFilms(id: 1, cnt: 0)
        table.reloadData()
        self.refresh.endRefreshing()
    }
    
    private func findIndex(year: String) -> (Bool, Int) {
        var index = 0
        while (index < dataSource.count && year >= dataSource[index].year) {
            if dataSource[index].year == year {
                return (true, index)
            }
            index += 1
        }
        return (false, index)
    }
    
    private func addToData(name: String, director: String, year: String, rate: Int, poster: String) {
        let (contains, index) = findIndex(year: year)
        table.performBatchUpdates({
            if (contains) {
                dataSource[index].films.append(Film(name: name, director: director, date: year, rate: rate, poster: poster))
            } else {
                years.insert(year)
                dataSource.insert(DatedFilms(year: year, films: [Film(name: name, director: director, date: year, rate: rate, poster: poster)]), at: index)
                table.insertSections(IndexSet(integer: index), with: .automatic)
            }
            table.insertRows(at: [IndexPath(row: dataSource[index].films.count-1, section: index)], with: .fade)
        })
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataSource.isEmpty {
            return 0
        }
        return dataSource[section].films.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: "FilmCell") as? FilmCell else {
            return UITableViewCell()
        }
        let film = dataSource[indexPath.section].films[indexPath.row]
        cell.setupView(with: film)
        if let image = cashedImages.object(forKey: NSString(string: film.poster)) {
            cell.poster.image = image
        } else {
            getImage(id: film.poster) {
                let image = $0
                DispatchQueue.main.async {
                    self.cashedImages.setObject(image, forKey: film.poster as NSString)
                    cell.poster.image = image
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if dataSource.isEmpty {
            return "ups"
        }
        return dataSource[section].year
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Удалить") {
            _,_,_ in
            let inId = self.dataSource[indexPath.section].films[indexPath.row].id
            let url = URL(string: "http://127.0.0.1:3131/movies/" + String(inId))
            var request = URLRequest(url: url!)
            request.httpMethod = "DELETE"
            request.addValue("Bearer I1eWeEjojeDmAI5Es6Tqso9mT6eo2ZO0ijkhA4qkSDdXDT61uYEsDt99eQQzwZvhNrJfjRXFq8iwoAsJBTmAhvS1yaFtdwFoTIYcMRgOxGKto87xP5eii0shcAY5z19gHukrbLQkOEpQjXHq1MFifaiYFfO8zAoLpdmq5po5QPUZxDuvDyn68SWLVtCP1l2CetzjfRrOwKnL5bsoR5AMFKEaoSLalLGmQeoRoIVAvXvGmuPSsjhqJo6qc3eTuiX", forHTTPHeaderField: "Authorization")
            let task = self.session.dataTask(with: request)
            task.resume()
            
            self.table.performBatchUpdates({
                self.dataSource[indexPath.section].films.remove(at: indexPath.row)
                self.table.deleteRows(at: [indexPath], with: .fade)
                
                if self.dataSource[indexPath.section].films.isEmpty {
                    self.years.remove(self.dataSource[indexPath.section].year)
                    self.dataSource.remove(at: indexPath.section)
                    self.table.deleteSections(IndexSet(integer: indexPath.section), with: .fade)
                }
            })
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return Array(years).sorted()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    
}

extension ViewController: TableDelegate {
    func postFilm(name: String, director: String, year: String, rate: Int, poster: String, completion: @escaping (Int) -> Void) {
        let url = URL(string: "http://127.0.0.1:3131/movies/")
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
        request.addValue("Bearer I1eWeEjojeDmAI5Es6Tqso9mT6eo2ZO0ijkhA4qkSDdXDT61uYEsDt99eQQzwZvhNrJfjRXFq8iwoAsJBTmAhvS1yaFtdwFoTIYcMRgOxGKto87xP5eii0shcAY5z19gHukrbLQkOEpQjXHq1MFifaiYFfO8zAoLpdmq5po5QPUZxDuvDyn68SWLVtCP1l2CetzjfRrOwKnL5bsoR5AMFKEaoSLalLGmQeoRoIVAvXvGmuPSsjhqJo6qc3eTuiX", forHTTPHeaderField: "Authorization")
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
            completion(curId)
        }
        task.resume()
    }
    
    func postImage(image: UIImage, completion: @escaping (String) -> Void) {
        let url = URL(string: "http://127.0.0.1:3131/image/upload")
        var request = URLRequest(url: url!)
        let data = image.jpegData(compressionQuality: 1.0)
        request.httpMethod = "POST"
        request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer I1eWeEjojeDmAI5Es6Tqso9mT6eo2ZO0ijkhA4qkSDdXDT61uYEsDt99eQQzwZvhNrJfjRXFq8iwoAsJBTmAhvS1yaFtdwFoTIYcMRgOxGKto87xP5eii0shcAY5z19gHukrbLQkOEpQjXHq1MFifaiYFfO8zAoLpdmq5po5QPUZxDuvDyn68SWLVtCP1l2CetzjfRrOwKnL5bsoR5AMFKEaoSLalLGmQeoRoIVAvXvGmuPSsjhqJo6qc3eTuiX", forHTTPHeaderField: "Authorization")
        request.httpBody = data
        let task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            let decoder = JSONDecoder()
            let id = try! decoder.decode(ImagePostResponse.self, from: data).data.poster_id
            completion(id)
        }
        task.resume()
    }
    
    func addInformation(name: String, director: String, date: String, rate: Int, poster: String) {
        let year = date
        let (contains, index) = findIndex(year: year)
        table.performBatchUpdates({
            if (contains) {
                dataSource[index].films.append(Film(name: name, director: director, date: date, rate: rate, poster: poster))
            } else {
                years.insert(year)
                dataSource.insert(DatedFilms(year: year, films: [Film(name: name, director: director, date: date, rate: rate, poster: poster)]), at: index)
                table.insertSections(IndexSet(integer: index), with: .automatic)
            }
            table.insertRows(at: [IndexPath(row: dataSource[index].films.count-1, section: index)], with: .fade)
        })
        
        postFilm(name: name, director: director, year: year, rate: rate, poster: poster) {
            self.dataSource[index].films[self.dataSource[index].films.count-1].id = $0
            self.idSet.insert($0)
        }
    }
}

protocol TableDelegate: AnyObject {
    func addInformation(name: String, director: String, date: String, rate: Int, poster: String)
    
    func postImage(image: UIImage, completion: @escaping (String) -> Void)
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
