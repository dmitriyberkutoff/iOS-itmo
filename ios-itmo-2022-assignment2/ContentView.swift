//
//  FilmInfoView.swift
//  ios-itmo-2022-assignment2
//
//  Created by mac on 20.12.2022.
//

import SwiftUI
import UIKit

struct ContentView: View {
    
    var film: Film
    let maxHeight: CGFloat = UIScreen.main.bounds.height
    var root: ViewController = ViewController()
    var index: IndexPath = IndexPath()
    @State var orientationChanged = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .makeConnectable()
            .autoconnect()
    @State var orientation = UIDevice.current.orientation
    @State var textRate: String?
    @State var uiImage = UIImage()
    @State var image = Image(uiImage: UIColor.black.image())
    @State var inProgress = true
    
    init(film: Film, rv: ViewController, index: IndexPath) {
        self.film = film
        self.textRate = String(film.rate)
        self.root = rv
        self.index = index
    }
    var body: some View {
        NavigationView {
            ZStack {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity,
                           minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .edgesIgnoringSafeArea(.all)
                if inProgress {
                    ProgressView().tint(.white).aspectRatio(100, contentMode: .fill)
                }
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [.clear, .clear, .black, .black]), startPoint: .top, endPoint: .bottom)
                        .padding(.top, orientation.isLandscape ? 0 : maxHeight / 3)
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        Text(film.name)
                            .foregroundColor(.white)
                            .font(.custom("FProText-Semibold", size: 30))
                        Text(film.director)
                            .foregroundColor(.gray)
                            .font(.custom("SFProText-Regular", size: 20))
                        Text(film.date)
                            .foregroundColor(.gray)
                        HStack {
                            Text(String(textRate ?? String(film.rate)) + " / 5").foregroundColor(.white)
                                .font(.custom("SF Pro Text", size: 24))
                            getStar(tag: 1)
                            getStar(tag: 2)
                            getStar(tag: 3)
                            getStar(tag: 4)
                            getStar(tag: 5)
                        }
                    }.padding(.top, orientation.isLandscape ? maxHeight / 4 : maxHeight / 1.5)
                }.onAppear() {
                    Server.getImage(id: film.poster) {
                        self.inProgress = false
                        let image = $0
                        withAnimation {
                            self.image = Image(uiImage: image)
                        }
                        self.uiImage = image
                    }
                }.onReceive(orientationChanged) { _ in
                    self.orientation = UIDevice.current.orientation
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        shareImage()
                    }) {
                        Image(systemName: "arrowshape.turn.up.right.fill").foregroundColor(.white)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        root.navigationController?.popViewController(animated: true)
                        root.navigationController?.isNavigationBarHidden = false
                        root.deselectFilm(index: index, animated: true)
                    }) {
                        Image(systemName: "chevron.left").foregroundColor(.white)
                    }
                }
            }
        }
    }
    
    private func getStar(tag: Int) -> some View {
        return Button(action: {
            onTap(tag: tag)
        }){
            Image(film.rate > tag-1 ? "StarYellow" : "StarGray")
                .resizable()
                .frame(width: 25, height: 25)
        }
    }
    
    private func onTap(tag: Int) {
        textRate = String(tag)
        if film.rate != tag {
            film.rate = tag
            
            Server.changeRate(id: film.id, rate: film.rate) {
                root.changeRating(indexPath: self.index, rate: film.rate)
            }
        }
    }
    
    private func shareImage() {
        let activityViewController = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
        
        let viewController = Coordinator.topViewController()
        activityViewController.popoverPresentationController?.sourceView = viewController?.view
        viewController?.present(activityViewController, animated: true, completion: nil)
      }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(film: Film(name: "name", director: "director", date: "2003", rate: 3, poster: "5e926945-31a8-4e64-a85a-01f4dd29f2ee"), rv: ViewController(), index: IndexPath())
    }
}
