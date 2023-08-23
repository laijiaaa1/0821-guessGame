//
//  ViewController.swift
//  0821-wordGarden
//
//  Created by laijiaaa1 on 2023/8/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var wordguess: UILabel!
    @IBOutlet weak var wordRemaining: UILabel!
    @IBOutlet weak var wordMissed: UILabel!
    @IBOutlet weak var wordsInGame: UILabel!
    @IBOutlet weak var flowerImageView: UIImageView!
    @IBOutlet weak var gameStatusMessage: UILabel!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var guessedLetterButton: UIButton!
    @IBOutlet weak var guessedLetterText: UITextField!
    @IBOutlet weak var wordBeingRevaeled: UILabel!
   
    var wordsToGuess = ["SWIFT", "DOG", "CAT"]
    var currentWordIndex = 0
    var wordToGuess = ""
    var lettersGuessed = ""
    let maxNumberOfWrongGuesses = 8
    var wrongguessesremaining = 8
    var wordsGuessCount = 0
    var wordsMissedcount = 0
    var guessCount = 0
    var audioplayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let text = guessedLetterText.text!
        guessedLetterButton.isEnabled = !(text.isEmpty)
        wordToGuess = wordsToGuess[currentWordIndex]
        wordBeingRevaeled.text = "_" + String(repeating: " _", count: wordToGuess.count-1)
        updategamestatuslabels()
        
    }

    func updateUIafterGuess(){
        guessedLetterText.resignFirstResponder()
        guessedLetterText.text! = ""
        guessedLetterButton.isEnabled = false
    }
    
    func formatRevealedWord(){
        var revealedWord = ""
        
        //loop through a;; ;etters in wordToGuess
        for letter in wordToGuess{
            if lettersGuessed.contains(letter){
                revealedWord = revealedWord + "\(letter)"
            }else{
                revealedWord = revealedWord + "_ "
            }
        }
        revealedWord.removeLast()
        wordBeingRevaeled.text = revealedWord
    }
    func updateafterwinorlose(){
        currentWordIndex += 1
        guessedLetterText.isEnabled = false
        guessedLetterButton.isEnabled = false
        playAgainButton.isHidden = false
      
        updategamestatuslabels()
    }
    func updategamestatuslabels(){
        
        wordguess.text = "Words Guessed: \(wordsGuessCount)"
        wordMissed.text = "Words Missed: \(wordsMissedcount)"
        wordRemaining.text = "Words to Guess: \(wordToGuess.count-(wordsGuessCount + wordsMissedcount))"
        wordsInGame.text = "Words in Game: \(wordsToGuess.count)"
    }
    
    func drawFlowerAndPlaySound(currentLetterGuessed:String){
        if wordToGuess.contains(currentLetterGuessed) == false {
            wrongguessesremaining = wrongguessesremaining-1
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                UIView.transition(with: self.flowerImageView, duration: 0.5,
                    options: .transitionCrossDissolve ,
                    animations: {self.flowerImageView.image = UIImage(named: "wilt\(self.wrongguessesremaining)")}) { (_) in
                    if self.wrongguessesremaining != 0 {
                    self.flowerImageView.image = UIImage(named: "flower\(self.wrongguessesremaining)")
                    }else{
                        self.playSound(name: "word-not-guessed")
                        UIView.transition(with: self.flowerImageView,
                        duration: 0.5,
                        options: .transitionCrossDissolve,
                        animations: {self.flowerImageView.image = UIImage(named: "flower\(self.wrongguessesremaining)")}, completion:nil)
                                          
                    }
                    
                }
                self.playSound(name: "incorrect")
            }
        }else{
            playSound(name: "correct")
        }
    }
    
    func guessALetter(){
        // get current letter guessed and add it to all letterGuessed
        let currentLetterGuessed = guessedLetterText.text!
        lettersGuessed = lettersGuessed + currentLetterGuessed
        
        //format and show revealedword in wordBeingRevealed to include new guess
        formatRevealedWord()
        drawFlowerAndPlaySound(currentLetterGuessed: currentLetterGuessed)
        //update gameStatusMessage
        guessCount += 1
//        var guesses = "Guesses"
//        if guessCount == 1{
//            guesses = "Guess"
//        }else{
//            guesses = "Guesses"
//        }
        let guesses = (guessCount == 1 ? "Guess" : "Guesses")
        gameStatusMessage.text = "You've Made \(guessCount) Guessed."
        
        if wordBeingRevaeled.text?.contains("_") == false{
            gameStatusMessage.text = "You've guessed it! It took you \(guessCount) guesses to guess the word."
            wordsGuessCount += 1
            playSound(name: "word-guessed")
            updateafterwinorlose()
        }else if wrongguessesremaining == 0{
            gameStatusMessage.text = "So sorry. You're all out of guesses."
            wordsMissedcount += 1
//            playSound(name: "word-not-guessed")
            updateafterwinorlose()
        }
        if currentWordIndex == wordsToGuess.count{
            gameStatusMessage.text! += "\n\nYou've tried all of the words! Restart from the brginning?"
        }
    }
        
    func playSound(name:String){
        if let sound = NSDataAsset(name: name){
            do{
                try audioplayer = AVAudioPlayer(data: sound.data)
                audioplayer.play()
            }catch{
                print("Error: \(error.localizedDescription). Could not initialize AVAudioPlayer object")
            }
        }else {
            print("Error:Could not read data from file \(name)")
        }
    }
    
    @IBAction func guessedLetterFieldChange(_ sender: UITextField) {
        //防呆，空值則無法按輸入按鈕
        //一次輸入一個值
        sender.text = String(sender.text?.last ?? " ").trimmingCharacters(in: .whitespaces).uppercased()
        guessedLetterButton.isEnabled = !(sender.text!.isEmpty)
    }
    @IBAction func doneKeyPressed(_ sender: UITextField) {
        guessALetter()
        //this dismiss the keyboard
        updateUIafterGuess()
    }
    @IBAction func playAgainButtonPressed(_ sender: UIButton) {
        if currentWordIndex == wordToGuess.count{
            currentWordIndex = 0
            wordsGuessCount = 0
            wordsMissedcount = 0
        }
        
        playAgainButton.isHidden = true
        guessedLetterText.isEnabled = true
        guessedLetterButton.isEnabled = false
        wordToGuess = wordsToGuess[currentWordIndex]
        wrongguessesremaining = maxNumberOfWrongGuesses
        
        wordBeingRevaeled.text = "_" + String(repeating: " _", count: wordToGuess.count-1)
        guessCount = 0
        flowerImageView.image = UIImage(named: "flower\(maxNumberOfWrongGuesses)")
        lettersGuessed = ""
        updategamestatuslabels()
        gameStatusMessage.text = "You've Made Zero Guesses"
    }
    
    @IBAction func guessLetterButtonPressed(_ sender: UIButton) {
        guessALetter()
        //this dismiss the keyboard
        updateUIafterGuess()
    }
}

