//
//  SleepController.swift
//  Sleep
//
//  Created by Julian Grosshauser on 06/01/16.
//  Copyright © 2016 Julian Grosshauser. All rights reserved.
//

import UIKit
import MediaPlayer

enum SleepError: String, ErrorType, CustomStringConvertible {

    case PlaylistNotFound = "Playlist not found"
    case CredentialsNotSet = "Credentials not set"
    case NetworkRequestFailed = "Network request failed"

    //MARK: CustomStringConvertible

    var description: String {
        return rawValue
    }
}

final class SleepController: UIViewController {

    //MARK: Properties

    @IBOutlet weak var sleepButton: UIButton!

    //MARK: Button Actions

    @IBAction func sleep(sender: UIButton) {
        turnOnAmp { [unowned self] response in
            do {
                try response()
                try self.playSleepPlaylist()
            } catch {
                dispatch_async(dispatch_get_main_queue()) {
                    let alertController = UIAlertController(title: "Error", message: String(error), preferredStyle: .Alert)
                    let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
                    alertController.addAction(alertAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }

    private func playSleepPlaylist() throws {
        let playlistQuery = MPMediaQuery.playlistsQuery()
        playlistQuery.addFilterPredicate(MPMediaPropertyPredicate(value: "Sleep 😴", forProperty: MPMediaPlaylistPropertyName))
        guard let playlist = playlistQuery.collections?.first else {
            throw SleepError.PlaylistNotFound
        }

        let musicPlayer = MPMusicPlayerController.systemMusicPlayer()
        musicPlayer.setQueueWithItemCollection(playlist)
        musicPlayer.repeatMode = .None
        musicPlayer.shuffleMode = .Songs
        musicPlayer.play()
    }

    private func turnOnAmp(completionHandler: (() throws -> Void) -> Void) {
        guard let loxoneCredentials = NSProcessInfo.processInfo().environment["LOXONE_CREDENTIALS"] where !loxoneCredentials.isEmpty else {
            completionHandler { throw SleepError.CredentialsNotSet }
            return
        }

        guard let credentialsData = loxoneCredentials.dataUsingEncoding(NSUTF8StringEncoding) else {
            fatalError("Couldn't convert credential string into NSData")
        }

        let authorizationHeaderValue = "Basic \(credentialsData.base64EncodedStringWithOptions([]))"

        guard let url = NSURL(string: "http://192.168.0.100/dev/sps/io/65f08a17-a3d7-11e3-b3a9cce5b9d46e42/on") else {
            fatalError("Malformed URL")
        }

        let request = NSMutableURLRequest(URL: url)
        request.setValue(authorizationHeaderValue, forHTTPHeaderField: "Authorization")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { _, response, error in
            guard let response = response as? NSHTTPURLResponse where response.statusCode == 200 && error == nil else {
                completionHandler { throw SleepError.NetworkRequestFailed }
                return
            }

            completionHandler {}
        }

        task.resume()
    }
}
