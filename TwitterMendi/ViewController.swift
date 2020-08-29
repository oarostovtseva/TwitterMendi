//
//  ViewController.swift
//  TwitterMendi
//
//  Created by Olena Rostovtseva on 25.08.2020.
//  Copyright © 2020 orost. All rights reserved.
//

import CoreML
import SwifteriOS
import SwiftyJSON
import UIKit

class ViewController: UIViewController {
    let swifter = Swifter(consumerKey: getTwitterApiKey(), consumerSecret: getTwitterSecretKey())

    let sentimentClassifier = TweetSentimentClassifier()

    @IBOutlet var sentimentLabel: UILabel!
    @IBOutlet var textField: UITextField!

    let tweetCount = 100

    @IBAction func predict(_ sender: UIButton) {
        if let searchText = textField.text {
            fetchTweets(text: searchText)
        }
    }

    private func fetchTweets(text searchText: String) {
        swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { result, _ in
            var tweets = [TweetSentimentClassifierInput]()
            for i in 0..<100 {
                if let tweet = result[i]["full_text"].string {
                    tweets.append(TweetSentimentClassifierInput(text: tweet))
                }
            }
            self.makePrediction(tweets)
        }) { error in
            print("There was an error with the Twitter API request \(error)")
        }
    }

    private func makePrediction(_ tweets: [TweetSentimentClassifierInput]) {
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            var sentimentScore = 0
            for pred in predictions {
                let sentiment = pred.label
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            self.updateUI(score: sentimentScore)
        } catch {
            fatalError("There was an error with making a predictoin, \(error)")
        }
    }

    private func updateUI(score: Int) {
        if score > 20 {
            sentimentLabel.text = "😍"
        } else if score > 10 {
            sentimentLabel.text = "😃"
        } else if score > 0 {
            sentimentLabel.text = "🙂"
        } else if score == 0 {
            sentimentLabel.text = "😐"
        } else if score > -10 {
            sentimentLabel.text = "😕"
        } else if score > -20 {
            sentimentLabel.text = "😡"
        } else {
            sentimentLabel.text = "🤮"
        }
    }
}

func getTwitterApiKey() -> String {
    var nsDictionary: NSDictionary?
    if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
        nsDictionary = NSDictionary(contentsOfFile: path)
    }
    return nsDictionary?["API key"] as! String
}

func getTwitterSecretKey() -> String {
    var nsDictionary: NSDictionary?
    if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist") {
        nsDictionary = NSDictionary(contentsOfFile: path)
    }
    return nsDictionary?["API secret"] as! String
}
