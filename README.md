# KomootChallenge
Challenge from Komoot


I choose to use SwiftUI and Combine, just to demostrate my attitude to learn new things and paradigm, instead of the more classical one. If I would have not chose to use Combine and SwiftUI, I would be probably used a Clean Swift Architecture.

The architecture of the project is simple:

ContentView: contain all the views structure
FlickrInteractor: hold all the business logic (distance over 100 mts, call the Flickr APIs, ...)
LocationNotifier: take care of all the location problems 
FlickrAPI: make network calls for images and for the flickrSearch
DataStore: persist the Photos (Models) 

Using combine and the @FetchResult feature we can make the list of photos react to added/removed models from the persistent store making it a react model.

I used a similar approch in my last project, where the dataStore was holding the updates of the models coming from the network, from a socket or from a push notification, potentially on the same object. 

I had tried to put more enphasis as well on the unit tests and tes coverage because I firmly belive that are excellent in asuring more quality in the code.

Using CoreData and the @FetchResult is still leaving few CoreData "traces" in the project, when in an idel world would be better isolate in its own container. If isolated the object that persist the model could be replaced without any consequences on the rest of the project. A possible solution would be update the ViewModel to hold the list of pictures and fetch the results only on a new location receive, as well as move the @FetchResult at ViewModelLevel
                                        
Unless you want to wait a few seconds before the updated pictures come through, I would suggest to test in the simulator with Bicycle ride or free way drive.
                                            
