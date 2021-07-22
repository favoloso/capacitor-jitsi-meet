//
//  JitsiMeetViewController.swift
//  Plugin
//
//  Created by Calvin Ho on 1/25/19.
//  Copyright © 2019 Max Lynch. All rights reserved.
//

import Foundation
import UIKit
import JitsiMeetSDK

public class JitsiMeetViewController: UIViewController {

    var jitsiMeetView: JitsiMeetView!
    var url: String = ""
    var roomName: String = ""
    var token: String? = nil
    var startWithAudioMuted: Bool = false
    var startWithVideoMuted: Bool = false
    var chatEnabled: Bool = true
    var inviteEnabled: Bool = true
    var callIntegrationEnabled: Bool = true
    var email: String? = nil
    var displayName: String? = nil
    var avatarUrl: String? = nil
    let userLocale = NSLocale.current as NSLocale
    weak var delegate: JitsiMeetViewControllerDelegate?
    var pipViewCoordinator: PiPViewCoordinator?

    public override func viewDidLoad() {
        super.viewDidLoad()
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::viewDidLoad");
        self.view.backgroundColor = .clear;
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);

        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::viewDidAppear");
        
        jitsiMeetView = JitsiMeetView();
        jitsiMeetView?.delegate = self

        if  userLocale.countryCode?.contains("CN") ?? false ||
            userLocale.countryCode?.contains("CHN") ?? false ||
            userLocale.countryCode?.contains("MO") ?? false ||
            userLocale.countryCode?.contains("HK") ?? false {
            print("currentLocale is China so we cannot use CallKit.")
            callIntegrationEnabled = false
        }

        let userInfo = JitsiMeetUserInfo()
        userInfo.displayName = self.displayName
        userInfo.email = self.email
        userInfo.avatar = URL(string: self.avatarUrl ?? "")

        let options = JitsiMeetConferenceOptions.fromBuilder({ builder in
            builder.serverURL = URL(string: self.url)
            builder.room = self.roomName
            builder.subject = " "
            builder.token = self.token
            builder.audioMuted = self.startWithAudioMuted
            builder.videoMuted = self.startWithVideoMuted
            builder.setFeatureFlag("chat.enabled", withBoolean: self.chatEnabled)
            builder.setFeatureFlag("invite.enabled", withBoolean: self.inviteEnabled)
            builder.setFeatureFlag("call-integration.enabled", withBoolean: self.callIntegrationEnabled)

            builder.userInfo = userInfo
        })
        jitsiMeetView.join(options)
        
        // Enable jitsimeet view to be a view that can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: view)

        // animate in
        jitsiMeetView.alpha = 0
        pipViewCoordinator?.show()
    }

    public override func viewWillTransition(to size: CGSize,
                                            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        let rect = CGRect(origin: CGPoint.zero, size: size)
        pipViewCoordinator?.resetBounds(bounds: rect)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::leaveConference");

        jitsiMeetView.delegate = self
        jitsiMeetView.leave()

    }
}

protocol JitsiMeetViewControllerDelegate: AnyObject {
    func onConferenceJoined()

    func onConferenceLeft()
}

// MARK: JitsiMeetViewDelegate
extension JitsiMeetViewController: JitsiMeetViewDelegate {
    @objc public func conferenceJoined(_ data: [AnyHashable : Any]!) {
        delegate?.onConferenceJoined()
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::conference joined");
    }

    @objc public func conferenceTerminated(_ data: [AnyHashable : Any]!) {
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::conference left");
        delegate?.onConferenceLeft()
        DispatchQueue.main.async {
            self.pipViewCoordinator?.hide() // TODO Aggiungere cleanup
        }
        
        // TODO Gestire con `willMove` ecc.
//        self.dismiss(animated: true, completion: nil); // e.g. user ends the call. This is preferred over conferenceLeft to shorten the white screen while exiting the room
    }
    
    @objc public func enterPicture(inPicture data: [AnyHashable : Any]!) {
        print("[Jitsi iOS] Enter PIP");
        self.jitsiMeetView.layer.cornerRadius = 8;
        self.jitsiMeetView.layer.masksToBounds = true;
        DispatchQueue.main.async {
            self.pipViewCoordinator?.enterPictureInPicture()
        }
//        self.jitsiMeetView.layer.masksToBounds = true;
//        self.jitsiMeetView.translatesAutoresizingMaskIntoConstraints = false;
//        self.jitsiMeetView.widthAnchor.constraint(equalToConstant: 120.0).isActive = true;
//        self.jitsiMeetView.heightAnchor.constraint(equalToConstant: 120.0).isActive = true;
//        self.jitsiMeetView.rightAnchor.constraint(lessThanOrEqualTo: self.view.rightAnchor, constant: 40.0).isActive = true;
//        self.jitsiMeetView.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: 40.0).isActive = true;
    }
}
