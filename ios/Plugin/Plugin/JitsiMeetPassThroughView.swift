//
//  JitsiMeetPassThroughView.swift
//  Plugin
//
//  Created by Leonardo Ascione on 22/07/2021.
//

import Foundation
import UIKit
import JitsiMeetSDK

/**
 * Pass-Through view in order to allow user interaction behind
 * the Jitsi PiP container viewcontroller.
 */
public class JitsiMeetPassThroughView: UIView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event);
        return view == self ? nil : view;
    }
}
