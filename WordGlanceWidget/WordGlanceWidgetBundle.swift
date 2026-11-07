//
//  WordGlanceWidgetBundle.swift
//  WordGlanceWidget
//
//  Created by Bryce Hills on 11/6/26.
//

import WidgetKit
import SwiftUI

@main
struct WordGlanceWidgetBundle: WidgetBundle {
    var body: some Widget {
        WordGlanceWidget()
        WordGlanceWidgetControl()
        WordGlanceWidgetLiveActivity()
    }
}
