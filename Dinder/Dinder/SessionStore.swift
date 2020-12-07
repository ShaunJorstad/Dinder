//
//  SessionStore.swift
//  Dinder
//
//  Created by Shaun Jorstad on 11/1/20.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore
import Combine
import CodableFirebase

class SessionStore : ObservableObject {
    let db = Firestore.firestore()
    var didChange = PassthroughSubject<SessionStore, Never>()
    var pushed = false
    @Published var session: User? { didSet { self.didChange.send(self) }}
    var handle: AuthStateDidChangeListenerHandle?
    @Published var sessionCode: Int? = nil
    @Published var numParticipants: Int = 0
    @Published var sessionLive = false
    @Published var result = ""
    @Published var finished = false
    @Published var sessionError: String? = nil
    @Published var sessionDeleted = false
    @Published var restaurantList: RestaurantList? = nil
    @Published var likedRestaurants = [Restaurant]()
    @Published var createdSession = false
    
    func joinSession(joinCode: Int) {
        db.collection("Sessions").document("\(joinCode)").updateData([
            "participants": FieldValue.increment(Int64(1)),
            "likes.\(self.session!.uid)": []
        ]) { err in
            if err != nil {
                self.sessionError = "Error: could not join the session"
            } else {
                withAnimation {
                    self.sessionCode = joinCode
                }
                self.watchSession()
            }
        }
    }
    
    func leaveSession() {
        if let code = self.sessionCode {
            db.collection("Sessions").document("\(code)").updateData([
                "participants": FieldValue.increment(Int64(-1)),
                "likes.\(self.session!.uid)": FieldValue.delete()
            ]) { err in
                if err != nil {
                    self.sessionError = "Error: could not leave the session"
                } else {
                    withAnimation {
                        self.sessionCode = nil
                        self.numParticipants = 0
                        self.sessionLive = false
                        self.result = ""
                    }
                }
            }
        }
    }
    
    func deleteSession() {
        if let code = sessionCode {
            db.collection("Sessions").document("\(code)").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                    withAnimation {
                        self.sessionCode = nil
                        self.numParticipants = 0
                        self.sessionLive = false
                        self.result = ""
                    }
                }
            }
        }
    }
    
    func endSession() {
        db.collection("Sessions").document("\(sessionCode!)").updateData([
            "live": false,
            "finished": true
        ])
    }
    
    func calcResult(likes: [[String]]) {
        //TODO: calculate the result and push that to the database
        var intersect: Set<String> = Set(likes[0])
        
        for list in likes {
            let tmp: Set<String> = Set(list)
            intersect = intersect.intersection(tmp)
        }

        let selection: String = intersect.randomElement() ?? "Error"
        db.collection("Sessions").document("\(sessionCode!)").updateData([
            "result": selection
        ])
        
    }
    
    func startSession() {
        db.collection("Sessions").document("\(sessionCode!)").updateData([
            "live": true
        ])
        watchSession()
    }
    
    func pushResults() {
        if !pushed {
            var results: [String] = [String]()
            for restaurant in likedRestaurants {
                results.append(restaurant.name)
            }
            db.collection("Sessions").document("\(sessionCode!)").updateData([
                "likes": FieldValue.arrayUnion(results)
            ])
        }
    }
    
    func watchSession() {
        db.collection("Sessions").document("\(sessionCode!)")
            .addSnapshotListener { documentSnapshot, error in
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
              guard let data = document.data() else {
                withAnimation {
                    self.sessionCode = nil
                    self.numParticipants = 0
                    self.result = ""
                    self.sessionError = "Session deleted"
                    self.sessionDeleted = true
                }
                return
              }
                
                print("Current data: \(data["live"] ?? "did not exist")")
                if let live = data["live"], live as! Bool != self.sessionLive {
                    withAnimation {
                        self.sessionLive = live as! Bool
                    }
                }
                if let participants = data["participants"] {
                    withAnimation {
                        self.numParticipants = (participants as! Int)
                    }
                }
                if let result = data["result"], result as! String != "" {
                    withAnimation {
                        self.result = result as! String
                    }
                }
                if let value = data["restaurantList"] as? [String: Any] {
                    if !value.isEmpty {
                        self.restaurantList = try? FirestoreDecoder().decode(RestaurantList.self, from: value)
                    }
                }
                if let finished = data["finished"] as? Bool {
                    withAnimation {
                        self.finished = finished
                    }
                    if finished == true {
                        self.pushResults()
                    }
                }
                if let likes = data["likes"] as? [[String]] {
                    if likes.count == self.numParticipants && self.createdSession {
                        self.calcResult(likes: likes)
                    }
                }
                
            }
    }
    
    func updateSessionTime(time: Int) {
        db.collection("Sessions").document("\(sessionCode!)").updateData([
            "time": time
        ])
    }
    
    func updateSessionRadius(radius: Int) {
        db.collection("Sessions").document("\(sessionCode!)").updateData([
            "radius": radius
        ])
    }
    
    func updateRestaurantList(list: RestaurantList) {
        if let data = try? FirestoreEncoder().encode(list) {
            db.collection("Sessions").document("\(sessionCode!)").updateData([
                "restaurantList": data
            ])
        }
    }
    
    func createSession() {
        self.sessionCode = Int.random(in: 1000...9999)
//        var likesDict: [String: [String]] = [:]
//        likesDict["\(session!.uid)"] = []
        var likesArray: [[String]] = [[String]]()
        db.collection("Sessions").document("\(sessionCode!)").setData([
            "code": "\(sessionCode!)",
            "radius": 25,
            "time": 5,
            "participants": 1,
            "live": false,
            "likes": likesArray,
            "result": "",
            "finished": false,
            "restaurantList": []
        ])
        watchSession()
    }
    
    func getEmail() -> String {
        return session?.email ?? "no specified user"
    }

    func listen () {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user)")
                print("Got user email: \(String(describing: user.email))")
                self.session = User(
                    uid: user.uid,
                    email: user.email
                )
            } else {
                // if we don't have a user, set our session to nil
                self.session = nil
            }
        }
    }
    
    func signUp(
            email: String,
            password: String,
            handler: @escaping AuthDataResultCallback
            ) {
            Auth.auth().createUser(withEmail: email, password: password, completion: handler)
        }

    func signIn(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
        ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }
    
    func sendPasswordResetEmail(
        email: String,
        handler: @escaping (Error?) -> Void
        ) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: handler)
        if (!signOut()) {
            sessionError = "could not sign out"
        }
        
    }

    func signOut () -> Bool {
        do {
            try Auth.auth().signOut()
            self.session = nil
            return true
        } catch {
            return false
        }
    }
    
    func delete () {
        let user = Auth.auth().currentUser
        user?.delete { error in
            if error != nil {
                
            } else {
                self.session = nil
            }
        }
    }
    
    func unbind () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

class User {
    var uid: String
    var email: String?

    init(uid: String, email: String?) {
        self.uid = uid
        self.email = email
    }

}
