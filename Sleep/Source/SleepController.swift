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
        do {
            try playSleepPlaylist()
        } catch {
            let alertController = UIAlertController(title: "Error", message: String(error), preferredStyle: .Alert)
            let alertAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
            alertController.addAction(alertAction)
            presentViewController(alertController, animated: true, completion: nil)
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
}
