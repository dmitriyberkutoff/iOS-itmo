//
//  ViewController.swift
//  ios-itmo-2022-assignment2
//
//  Created by rv.aleksandrov on 29.09.2022.
//

import UIKit
import SwiftUI


class ViewController: UIViewController {
    @IBOutlet private var table: UITableView!
    
    private var refresh: UIRefreshControl!
    private var dates = [String: Int]()
    private var dataSource = [DatedFilms]()
    private var sortedDS = [DatedFilms]()
    private var years = Set<String>()
    private var idSet = Set<Int>()
    
    private let cashedImages = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Фильмы"
        
        Server.postImage(image: UIImage(systemName: "multiply.circle") ?? UIImage()) {
            FilmSettings.noPosterId = $0
        }
        
        DispatchQueue.global().async {
            self.getFilms(id: 1, cnt: 0) {
                let json = $0
                self.addToData(name: json.data.movie.title, director: json.data.movie.director, year: String(json.data.movie.relise_date), rate: json.data.movie.rating, poster: json.data.movie.poster_id)
                self.idSet.insert($1)
            }
        }
        
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(onRefresh), for: .valueChanged)

        table.dataSource = self
        table.delegate = self
        table.register(UINib(nibName: "FilmCell", bundle: nil), forCellReuseIdentifier: "FilmCell")
        table.refreshControl = refresh
    }
    

    @IBAction func onButtonPress(_ sender: UIButton) {
        guard let film = UIStoryboard(name: "FilmController", bundle: nil).instantiateInitialViewController() as? FilmController else { return }
        film.delegate = self
        self.navigationController?.pushViewController(film, animated: true)
    }
    
    @objc
    private func onRefresh() {
        getFilms(id: 1, cnt: 0) {
            let json = $0
            self.addToData(name: json.data.movie.title, director: json.data.movie.director, year: String(json.data.movie.relise_date), rate: json.data.movie.rating, poster: json.data.movie.poster_id)
            self.idSet.insert($1)
        }
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
    
    func getFilms(id: Int, cnt: Int, completion: @escaping (Server.FilmPostResponse, Int) -> Void) {
        if cnt > 100 {
            return
        }
        if idSet.contains(id) {
            getFilms(id: id+1, cnt: cnt, completion: completion)
            return
        }
        let url = URL(string: Server.filmsUrl + String(id))
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue(Server.token, forHTTPHeaderField: "Authorization")
        let task = Server.session.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let json = try decoder.decode(Server.FilmPostResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(json, id)
                    }
                    self.getFilms(id: id+1, cnt: cnt, completion: completion)
                } catch {
                    self.getFilms(id: id+1, cnt: cnt+1, completion: completion)
                }
            } else {
                return
            }
        }
        task.resume()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let HC = UIHostingController(rootView: ContentView(film: dataSource[indexPath.section].films[indexPath.row], rv: self, index: indexPath))
        self.navigationController?.pushViewController(HC, animated: true)
        self.navigationController?.isNavigationBarHidden = true;
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
            DispatchQueue.global().async {
                Server.getImage(id: film.poster) {
                    let image = $0
                    DispatchQueue.main.async {
                        self.cashedImages.setObject(image, forKey: film.poster as NSString)
                        cell.poster.image = image
                    }
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
            Server.deleteFilm(id: inId)
            
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
    
    func changeRating(indexPath: IndexPath, rate: Int) {
        self.dataSource[indexPath.section].films[indexPath.row].rate = rate
        
        table.reconfigureRows(at: [indexPath])
    }
    
    func deselectFilm(index: IndexPath, animated: Bool) {
        table.deselectRow(at: index, animated: animated)
    }
    
}

extension ViewController: TableDelegate {
    
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
        
        Server.postFilm(name: name, director: director, year: year, rate: rate, poster: poster) {
            self.dataSource[index].films[self.dataSource[index].films.count-1].id = $0
            self.idSet.insert($0)
        }
    }
}

protocol TableDelegate: AnyObject {
    func addInformation(name: String, director: String, date: String, rate: Int, poster: String)
}
