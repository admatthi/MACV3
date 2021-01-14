//
//  MediaViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 12/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//
import UIKit
import MediaPlayer

class MediaViewController: UITableViewController, MPMediaPickerControllerDelegate  {
    
    var sounds:[String] = ["newtrack2","bell","tickle"]
    var mediaItem: MPMediaItem?
    var mediaLabel: String!
    var mediaID: String!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillDisappear(_ animated: Bool) {
        performSegue(withIdentifier: Id.soundUnwindIdentifier, sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor =  UIColor.gray
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        header.textLabel?.frame = header.frame
        header.textLabel?.textAlignment = .left
        header.contentView.backgroundColor = .clear 
//        header.textLabel?.tintColor = .white
//        header.textLabel?.textColor = .white
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        if section == 0 {
            return 1
        }
        else if section == 1 {
            return 1
        }
        else if section == 2 {
            return 1
        }
        else {
            return sounds.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { if section == 0 {
            return nil
        }
        else if section == 1 {
            return nil
        }
        else if section == 2 {
            return "SONGS"
        }
        else {
            return "RINGTONS"
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: Id.musicIdentifier)
        if(cell == nil) {
            cell = UITableViewCell(
                style: UITableViewCell.CellStyle.default, reuseIdentifier: Id.musicIdentifier)
        }
        cell!.backgroundColor = #colorLiteral(red: 0.1725008786, green: 0.1724130809, blue: 0.1806807518, alpha: 1)
        cell?.tintColor = .white
        cell!.textLabel?.textColor = .white
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell!.textLabel!.text = "More Tones"
            }
        }
        else if indexPath.section == 1 {
            cell!.textLabel!.text = "Vibration"
            cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell!.textLabel!.text = "Pick a song"
                cell!.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
            }
        }
        else if indexPath.section == 3 {
            let sound = sounds[indexPath.row]
            cell!.textLabel!.text = sound
            
            if cell!.textLabel!.text == mediaLabel {
                cell!.accessoryType = UITableViewCell.AccessoryType.checkmark
            }
        }
        
        return cell!
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mediaPicker = MPMediaPickerController(mediaTypes: MPMediaType.anyAudio)
        mediaPicker.delegate = self
        mediaPicker.prompt = "Select any song!"
        mediaPicker.allowsPickingMultipleItems = false
        if indexPath.section == 2 {
            if indexPath.row == 0 {
                self.present(mediaPicker, animated: true, completion: nil)
            }
        }
        else if indexPath.section == 3 {
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = UITableViewCell.AccessoryType.checkmark
            let sound = sounds[indexPath.row]
            mediaLabel = sound
            cell?.setSelected(true, animated: true)
            cell?.setSelected(false, animated: true)
            let cells = tableView.visibleCells
            for c in cells {
                let section = tableView.indexPath(for: c)?.section
                if (section == indexPath.section && c != cell) {
                    c.accessoryType = UITableViewCell.AccessoryType.none
                }
            }
        }
    }
    
    
    //MPMediaPickerControllerDelegate
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems  mediaItemCollection:MPMediaItemCollection) -> Void {
        if !mediaItemCollection.items.isEmpty {
            let aMediaItem = mediaItemCollection.items[0]
        
            self.mediaItem = aMediaItem
            mediaID = (self.mediaItem?.value(forProperty: MPMediaItemPropertyPersistentID)) as! String
            //self.dismiss(animated: true, completion: nil)
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
