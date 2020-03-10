//
//  ContentView.swift
//  LittleWalk
//
//  Created by Scheggia on 28/02/2020.
//  Copyright © 2020 Flowprocess. All rights reserved.
//

import SwiftUI
import AppFoundation
import CoreData

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    var interactor: FlickrInteractorType
    var context: NSManagedObjectContext
    var subtitle: String {
        switch viewModel.status {
        case .active:
            return "Walking..."
        case .inactive:
            return "Stopped"
        case .cleaned:
            return "Cleaned!"
        }
    }
    @State var presentAlert: Bool = false

    var body: some View {
        VStack {
            HStack {
                Button(action: {
                    if self.interactor.isAutorized(self.viewModel) {
                        self.interactor.start(contentViewModel: self.viewModel)
                    } else {
                        self.presentAlert = true
                    }
                }) {
                    Text("Start").padding(.all, 8).background(Color.green.opacity(0.5)).cornerRadius(8).padding()
                }
                Spacer()
                Button(action: {
                    self.interactor.stop(self.viewModel)
                }) {
                    Text("Stop").padding(.all, 8).background(Color.red.opacity(0.5)).cornerRadius(12).padding()
                }
                Spacer()
                Button(action: {
                    self.interactor.reset(self.viewModel)
                }) {
                    Text("Reset").padding(.all, 8).background(Color.red.opacity(0.5)).cornerRadius(12).padding()
                }
            }
            Text(self.subtitle)
            LittleWalkView(interactor: interactor, request: interactor.fetchRequest()).environment(\.managedObjectContext, context)
        }.alert(isPresented: $presentAlert) {
            Alert(title: Text("Location not enabled"),
                  message: Text(viewModel.noAuthoriationMessage),
                  dismissButton: Alert.Button.default(Text("OK")) { self.presentAlert = false })
        }
    }
}

struct LittleWalkView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    var interactor: FlickrInteractorType
    var request: FetchRequest<MOPhoto>
    var photos: FetchedResults<MOPhoto> {
        request.wrappedValue
    }

    var body: some View {
        List(photos) { photo in
            ImageElement(url: photo.url, title: photo.title, interactor: self.interactor)
        }
    }
}

struct ImageElement: View {
    var url: String?
    var title: String?
    @State var image: UIImage?

    var interactor: FlickrInteractorType


    var body: some View {
        VStack {
            Text(title ?? "")
            if image != nil {
                Image(uiImage: image ?? UIImage())
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 160, maxHeight: 160)
                    .clipped()
            }
        }.onAppear{
            self.interactor.loadImage(urlString: self.url) { image in
                self.image = image
            }
        }.frame(height: 200)

    }

}
