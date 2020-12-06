//
//  CreateSession.swift
//  Dinder
//
//  Created by Luke on 11/3/20.
//

import SwiftUI
import CoreLocation
import Combine

struct CreateSession: View {
    @EnvironmentObject var session: SessionStore
    
    @State var timeLimit: Int = 1
    @State var radius: Int = 1
    
    @State var fetchPipeline: AnyCancellable? = nil
    
    var locationManger = LocationDelegate()
    
    var form: some View {
        VStack {
            Spacer()
            Text("Share this code:")
                .dinderTitleStyle()
            if let code = session.sessionCode {
                Text(verbatim: "\(code)")
                    .dinderTitleStyle()
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .onAppear(perform: session.createSession)
            }
            Spacer()
            HStack {
                Text("Travel Radius:")
                    .dinderRegularStyle()
                Stepper(value: $radius, in: 1...30) {
                    Text("\(radius) mile")
                        .dinderRegularStyle()
                }
            }.padding()
            HStack {
                Text("Time Limit:")
                    .dinderRegularStyle()
                Stepper(value: $timeLimit, in: 1...10) {
                    Text("\(timeLimit) minutes")
                        .dinderRegularStyle()
                }
            }.padding()
            Spacer()
            Text("Party of \(session.numParticipants)")
                .dinderRegularStyle()
            Button(action: start) {
                Text("Start")
            }.disabled(session.sessionCode == nil)
            Spacer()
        }.buttonStyle(DinderButtonStyle())
    }
    
    var body: some View {
        Group {
            if !session.sessionLive {
                form
            } else if session.sessionLive && session.restaurantList == nil {
                VStack {
                    Text("Fetching Restaraunt List")
                        .dinderTitleStyle()
                    ProgressView()
                }
            } else if session.sessionLive {
                LiveSession(created: true)
            }
        }
        .onReceive(loadJsonFromBundle(filename: "response", fileExtension: "json"), perform: updateRestaurantList)
        .onDisappear {
            if !session.sessionLive {
                session.deleteSession()
            }
        }
    }
    
    func updateRestaurantList(list: RestaurantList?) {
        guard let list = list else {
            return
        }
        session.updateRestaurantList(list: list)
    }
    
    func start() {
        session.updateSessionTime(time: timeLimit)
        session.updateSessionRadius(radius: radius)
        session.startSession()
        
        //Uncomment to use acutal location
        //fetchRestaurants()
    }
    
    func fetchRestaurants() {
        let (latitude, longitude) = locationManger.getLastLocation()
        let meters = Int(Double(radius) * 1609.344)
        
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(latitude),\(longitude)&radius=\(meters)&type=restaurant&key=AIzaSyDNvJmFkPt54ZFAqa3O0U4ZdDGaFsyB3fk"
        
        fetchPipeline = downloadJsonAsync(from: url)
            .sink(receiveCompletion: {
                print("error getting resaurants \($0)")
            }, receiveValue: updateRestaurantList)
    }
}

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var locationManager = CLLocationManager()
    var lastLocation: CLLocation?
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    func getLastLocation() -> (String, String){
        guard let location = lastLocation else {
            return ("", "")
        }
        
        return (location.coordinate.latitude.description, location.coordinate.longitude.description)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastLocation = location
            print("Found user's location: \(location)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

struct CreateSession_Previews: PreviewProvider {
    static var previews: some View {
        let session = SessionStore()
        session.signIn(email: "test@example.com", password: "qwerty", handler: {_,_  in})
        
        return Group {
            CreateSession().environmentObject(session)
        }
    }
}
