//
//  NearbyAirQualityWidgetLiveActivity.swift
//  NearbyAirQualityWidget
//
//  Created by Akylbek Oralov on 10.04.2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct NearbyAirQualityWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct NearbyAirQualityWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: NearbyAirQualityWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension NearbyAirQualityWidgetAttributes {
    fileprivate static var preview: NearbyAirQualityWidgetAttributes {
        NearbyAirQualityWidgetAttributes(name: "World")
    }
}

extension NearbyAirQualityWidgetAttributes.ContentState {
    fileprivate static var smiley: NearbyAirQualityWidgetAttributes.ContentState {
        NearbyAirQualityWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: NearbyAirQualityWidgetAttributes.ContentState {
         NearbyAirQualityWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: NearbyAirQualityWidgetAttributes.preview) {
   NearbyAirQualityWidgetLiveActivity()
} contentStates: {
    NearbyAirQualityWidgetAttributes.ContentState.smiley
    NearbyAirQualityWidgetAttributes.ContentState.starEyes
}
