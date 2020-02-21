//
//  ViewController.swift
//  Animation
//
//  Created by Mike Hobizal on 1/9/20.
//  Copyright © 2020 Mike Hobizal. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let redBox1 = UIView()
        redBox1.backgroundColor = .red

        let redBox2 = UIView()
        redBox2.backgroundColor = .red

        let redBox3 = UIView()
        redBox3.backgroundColor = .red

        let stack = UIStackView(arrangedSubviews: [redBox1, redBox2, redBox3])
        stack.axis = .vertical
        stack.distribution = .fillEqually

        view.addSubview(stack)
        stack.frame = CGRect(x: 0, y: 0, width: 100, height: 500)



        let blueBox1 = UIView()
        blueBox1.backgroundColor = .blue

        let blueBox2 = UIView()
        blueBox2.backgroundColor = .blue

        let blueBox3 = UIView()
        blueBox3.backgroundColor = .blue

        let blueStack = UIStackView(arrangedSubviews: [blueBox1, blueBox2, blueBox3])
        blueStack.axis = .vertical
        blueStack.distribution = .fillEqually

        view.addSubview(blueStack)
        blueStack.frame = CGRect(x: 240, y: 0, width: 100, height: 500)

        let anim1 = AnimationSequence([
            Animation({ redBox1.alpha = 0.5 }, duration: 1.0),
            Animation({ redBox2.alpha = 0.5 }, duration: 1.0),
            Animation({ redBox3.alpha = 0.5 }, duration: 1.0),
        ], interval: 5.0)

        let anim2 = AnimationStagger([
            Animation({ blueBox1.alpha = 0.5 }, duration: 1.0),
            Animation({ blueBox2.alpha = 0.5 }, duration: 1.0),
            Animation({ blueBox3.alpha = 0.5 }, duration: 1.0),
        ], interval: 0.2)

        let anim3 = AnimationStagger([
            AnimationSequence([
                Animation({ redBox1.alpha = 1.0 }, duration: 1.0),
                Animation({ redBox1.alpha = 0.1 }, duration: 1.0),
                Animation({ redBox1.alpha = 1.0 }, duration: 1.0),
            ]),
            AnimationSequence([
                Animation({ redBox2.alpha = 1.0 }, duration: 1.0),
                Animation({ redBox2.alpha = 0.1 }, duration: 1.0),
                Animation({ redBox2.alpha = 1.0 }, duration: 1.0),
            ]),
            AnimationSequence([
                Animation({ redBox3.alpha = 1.0 }, duration: 1.0),
                Animation({ redBox3.alpha = 0.1 }, duration: 1.0),
                Animation({ redBox3.alpha = 1.0 }, duration: 1.0),
            ])
        ], interval: 0.5)

        let anim4 = AnimationSequence([
            AnimationStagger([
                Animation({ redBox1.alpha = 0.1 }, duration: 1.0),
                Animation({ redBox2.alpha = 0.1 }, duration: 1.0),
                Animation({ redBox3.alpha = 0.1 }, duration: 1.0),
                Animation({ blueBox1.alpha = 0.1 }, duration: 1.0),
                Animation({ blueBox2.alpha = 0.1 }, duration: 1.0),
                Animation({ blueBox3.alpha = 0.1 }, duration: 1.0),
            ], interval: 0.4),
            AnimationStagger([
                AnimationStagger([
                    Animation({ redBox1.alpha = 1.0 }, duration: 1.0),
                    Animation({ redBox2.alpha = 1.0 }, duration: 1.0),
                    Animation({ redBox3.alpha = 1.0 }, duration: 1.0),
                    ], interval: 0.1),
                AnimationStagger([
                    Animation({ blueBox1.alpha = 1.0 }, duration: 1.0),
                    Animation({ blueBox2.alpha = 1.0 }, duration: 1.0),
                    Animation({ blueBox3.alpha = 1.0 }, duration: 1.0),
                ], interval: 0.1),
            ], interval: 0.1)
        ])

        let anim5 = AnimationParallel([
            Animation({ redBox1.transform = CGAffineTransform(translationX: 40, y: 0) }, duration: 1, easing: .easeInOutSine),
            Animation({ redBox2.transform = CGAffineTransform(translationX: 40, y: 0) }, duration: 1, easing: .easeInOutSine),
            Animation({ redBox3.transform = CGAffineTransform(translationX: 40, y: 0) }, duration: 1, easing: .easeInOutSine),
            Animation({ blueBox1.transform = CGAffineTransform(translationX: 40, y: 0) }, duration: 1, easing: .easeInOutSine),
            Animation({ blueBox2.transform = CGAffineTransform(translationX: 40, y: 0) }, duration: 1, easing: .easeInOutSine),
            Animation({ blueBox3.transform = CGAffineTransform(translationX: 40, y: 0) }, duration: 1, easing: .easeInOutSine),
        ])

        AnimationSequence([ anim5]).start()
    }
}

