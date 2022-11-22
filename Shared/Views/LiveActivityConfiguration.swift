//
//  LiveActivityConfiguration.swift
//  Shuttle Tracker
//
//  Created by Tommy Truong on 11/22/22.
//

import Foundation
import NotificationCenter

extension ContentView {
    func createActivity() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            
            if let error = error {
                // Handle the error here.
            }
            
            // Enable or disable features based on the authorization.
        }
        
        let attributes = GroceryDeliveryAppAttributes(numberOfGroceyItems: 12)
        let contentState = GroceryDeliveryAppAttributes.LiveDeliveryData(courierName: "Mike", deliveryTime: .now + 120)
        do {
            let _ = try Activity<GroceryDeliveryAppAttributes>.request(
                attributes: attributes,
                contentState: contentState,
                pushType: .token)
        } catch (let error) {
            print(error.localizedDescription)
        }
    }
    func update(activity: Activity<GroceryDeliveryAppAttributes>) {
        Task {
            let updatedStatus = GroceryDeliveryAppAttributes.LiveDeliveryData(courierName: "Adam",
                                                                              deliveryTime: .now + 150)
            await activity.update(using: updatedStatus)
        }
    }
    
    func end(activity: Activity<GroceryDeliveryAppAttributes>) {
        Task {
            await activity.end(dismissalPolicy: .immediate)
        }
    }
    func endAllActivity() {
        Task {
            for activity in Activity<GroceryDeliveryAppAttributes>.activities{
                await activity.end(dismissalPolicy: .immediate)
            }
        }
    }
    func listAllDeliveries() {
        var activities = Activity<GroceryDeliveryAppAttributes>.activities
        activities.sort { $0.id > $1.id }
        self.activities = activities
    }
}
