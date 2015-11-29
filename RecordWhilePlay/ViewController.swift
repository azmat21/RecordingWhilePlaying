//
//  ViewController.swift
//  RecordWhilePlay
//
//  Created by Ezmet on 11/29/15.
//  Copyright © 2015 Ezmet. All rights reserved.
//

import UIKit

class ViewController: UIViewController,EZAudioPlayerDelegate,EZMicrophoneDelegate, EZRecorderDelegate {
    
    @IBOutlet weak var lbPlayStatus: UILabel!
    @IBOutlet weak var lbRecorderStatus: UILabel!
    
    var audioFile :EZAudioFile!
    var audioPlayer :EZAudioPlayer!
    var microphone :EZMicrophone!
    var recorder :EZRecorder!
    var isRecording = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let session = AVAudioSession.sharedInstance()
        
        do{
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try session.setActive(true)
            try session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        }catch{
            print("some exceptiops")
        }
        
        self.microphone = EZMicrophone(delegate: self)
        self.audioPlayer = EZAudioPlayer(delegate: self)
        self.audioPlayer.shouldLoop = true
        
        let filePath = NSBundle.mainBundle().pathForResource("simple-drum-beat", ofType: "wav")
        self.openFileWithPath(filePath!)
        
    }
    
    @IBAction func actionPlay(sender: AnyObject) {
        if (self.audioPlayer.isPlaying){
            self.audioPlayer.pause()
            self.lbPlayStatus.text! = "music status:Pause"
        }else{
            self.audioPlayer.play()
            self.lbPlayStatus.text! = "music status:Playing Backgournd Music"
        }
    }
    
    @IBAction func actionStartRecording(sender: AnyObject){
        self.microphone.startFetchingAudio()
        self.recorder = EZRecorder(URL:self.testUrlPath() , clientFormat: self.microphone.audioStreamBasicDescription(), fileType: EZRecorderFileType.M4A, delegate: self)
        self.isRecording = true
        self.lbRecorderStatus.text! = "recorder status: Recording"
    }
    
    @IBAction func actionStopRecording(){
        if(self.recorder != nil){
            self.recorder.closeAudioFile()
            self.microphone.stopFetchingAudio()
            self.isRecording = false
            self.lbRecorderStatus.text! = "recorder status: Stop"
        }
    }
    
    @IBAction func actionPlayAudio(sender: AnyObject){
        let playFile = EZAudioFile(URL: self.testUrlPath())
        self.audioPlayer.playAudioFile(playFile)
        self.lbPlayStatus.text! += "music status: Playing Recoding Audio"
    }
    
    
    func openFileWithPath(filePathUrl: String){
        self.audioFile = EZAudioFile(URL: NSURL(fileURLWithPath: filePathUrl))
        self.audioPlayer.audioFile = self.audioFile
    }
    func testUrlPath()->NSURL{
        let paths = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let basePath = paths[0]
        print(basePath+"/EZAudioTest.m4a")
        return NSURL(fileURLWithPath: basePath+"/EZAudioTest.m4a")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: MicroPhone Delegate
    func microphone(microphone: EZMicrophone!, hasBufferList bufferList: UnsafeMutablePointer<AudioBufferList>, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        if(self.isRecording){
            self.recorder.appendDataFromBufferList(bufferList, withBufferSize: bufferSize)
        }
    }


}

