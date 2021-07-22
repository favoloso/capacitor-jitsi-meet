//
//  JitsiMeetPassThroughView.swift
//  Plugin
//
//  Created by Leonardo Ascione on 22/07/2021.
//  Copyright © 2021 Max Lynch. All rights reserved.
//

import Foundation
import UIKit
import JitsiMeetSDK

public class JitsiMeetPassThroughView: UIView {
    public override func layoutSubviews() {
        print("OK caricata JitsiMeetPassThroughView")
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event);
        let viewTypeName = String(describing: type(of: view));
        if (view != self) {
            print("[Jitsi] Ok Drag - Jitsi meet view [\(viewTypeName)]")
            return view
        }
        print("[Jitsi] NO Drag - passthrough [\(viewTypeName)]")
        return nil
    }
}
