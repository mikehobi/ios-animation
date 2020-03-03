//
// Animation.swift
// 2020 Instrument Marketing
//

import UIKit

/// Animation Executable
public typealias AnimationBlock = () -> Void

/// Animation Protocol
public protocol AnimationProtocol {}

/// Animation
public struct Animation: AnimationProtocol {
    var animation: AnimationBlock
    var duration: TimeInterval
    var delay: TimeInterval?
    var easing: CAMediaTimingFunction

    /// Animation
    /// - Parameters:
    ///   - animation: An executable block of code to be animated
    ///   - duration: The duration of the animation
    ///   - delay: The delay of the animation
    ///   - easing: The easing of the animation
    init(
        _ animation: @escaping AnimationBlock,
        duration: TimeInterval,
        delay: TimeInterval? = nil,
        easing: CAMediaTimingFunction = .easeInOutSine) {
        self.animation = animation
        self.duration = duration
        self.delay = delay
        self.easing = easing
    }

    /// Method to fire animation
    /// - Parameter completion: Animation completion, returns a boolean value if the animation succeeded
    public func start(completion: ((Bool) -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setAnimationTimingFunction(easing)
        UIView.animate(
            withDuration: duration,
            delay: delay ?? 0,
            animations: animation,
            completion: completion)
        CATransaction.commit()
    }

    typealias Sequence = AnimationSequence
    typealias Stagger = AnimationStagger
    typealias Parallel = AnimationParallel
    typealias Wait = AnimationWait
}

/// Animation Wait
public struct AnimationWait: AnimationProtocol {
    var duration: TimeInterval

    /// Wait
    /// Executes no Animation, allows for timelines to be manipulated to avoid delays.
    /// - Parameter duration: Time to wait
    init(_ duration: TimeInterval) {
        self.duration = duration
    }
}

/// Animation Sequence
public struct AnimationSequence: AnimationProtocol {
    public var animations: [AnimationProtocol]
    var delay: TimeInterval
    var interval: TimeInterval

    /// Sequence
    /// - Parameters:
    ///   - animations: An array of executable AnimationProtocols
    ///   - interval: The interval time between each sequenced Animation
    ///   - delay: The delay to start the Sequence
    init(
        _ animations: [AnimationProtocol],
        interval: TimeInterval = 0,
        delay: TimeInterval = 0) {
        self.animations = animations
        self.delay = delay
        self.interval = interval
    }

    /// Method to fire off sequence
    /// - Parameter completion: Seqeunce completion
    public func start(completion: ((Bool) -> Void)? = nil) {
        AnimationSequence.sequence(animations, startDelay: delay) {
            completion?(true)
        }
    }

    /// Appends an animation block to the end of the sequence
    /// - Parameter animation: AnimationProtocol to be added
    mutating func append(_ animation: AnimationProtocol) {
        animations.append(animation)
    }

    /// Inserts an animation block to the end of the sequence
    /// - Parameters:
    ///   - animation: AnimationProtocol to be added
    ///   - index: Index in sequence for Animation to be added
    mutating func insert(_ animation: AnimationProtocol, at index: Int) {
        animations.insert(animation, at: index)
    }

    /// Private sequence method
    /// - Parameters:
    ///   - blocks: AnimationProtocol
    ///   - startDelay: Delay duration of sequence
    ///   - completion: Completion block fired at end of sequence
    private static func sequence(
        _ blocks: [AnimationProtocol],
        startDelay: TimeInterval = 0,
        completion: (() -> Void)? = nil) {
        func iterate(index: Int) {
            guard let block = blocks.get(at: index) else {
                return
            }
            switch block {
            case is Animation:
                guard let block = block as? Animation else { return }
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(block.easing)
                UIView.animate(
                    withDuration: block.duration,
                    delay: block.delay ?? 0,
                    animations: block.animation,
                    completion: { _ in
                        if index == blocks.count - 1 {
                            completion?()
                            return
                        }
                        iterate(index: index + 1)

                })
                CATransaction.commit()
            case is Animation.Stagger:
                guard let block = block as? Animation.Stagger else { return }
                block.start { _ in
                    if index == blocks.count - 1 {
                        completion?()
                        return
                    }
                    iterate(index: index + 1)
                }
            case is Animation.Sequence:
                guard let block = block as? Animation.Sequence else { return }
                block.start { _ in
                    if index == blocks.count - 1 {
                        completion?()
                        return
                    }
                    iterate(index: index + 1)
                }
            case is Animation.Parallel:
                guard let block = block as? Animation.Parallel else { return }
                block.start { _ in
                    if index == blocks.count - 1 {
                        completion?()
                        return
                    }
                    iterate(index: index + 1)
                }
            case is Animation.Wait:
                guard let block = block as? Animation.Wait else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + block.duration) {
                    if index == blocks.count - 1 {
                        completion?()
                        return
                    }
                    iterate(index: index + 1)
                }
            default:
                break
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            iterate(index: 0)
        }
    }
}

/// Animation Stagger
public struct AnimationStagger: AnimationProtocol {
    var animations: [AnimationProtocol]
    var interval: TimeInterval
    var delay: TimeInterval?

    /// An array of animations that is fired one after the other with a defined staggered interval
    ///
    /// Note: It's not advised to use `AnimationStagger` with a `0.0` duration interval.
    /// Use for `Animation.Sequence` for more reliability.
    ///
    /// - Parameters:
    ///   - animations: Ordered array of animations to be fired
    ///   - interval: Interval between firing of each animation
    ///   - delay: Delay duration for the entire stagger sequence
    init(
        _ animations: [AnimationProtocol],
        interval: TimeInterval = 0,
        delay: TimeInterval? = nil) {
        self.animations = animations
        self.interval = interval
        self.delay = delay
    }

    /// Method to fire off stagger sequence
    /// - Parameter completion: Stagger sequence completion
    public func start(completion: ((Bool) -> Void)? = nil) {
        AnimationStagger.stagger(animations, interval: interval) {
            completion?(true)
        }
    }

    /// Appends an animation block to the end of the sequence
    /// - Parameter animation: AnimationProtocol to be added
    mutating func append(_ animation: AnimationProtocol) {
        animations.append(animation)
    }

    /// Inserts an animation block to the end of the sequence
    /// - Parameters:
    ///   - animation: AnimationProtocol to be added
    ///   - index: Index in sequence for Animation to be added
    mutating func insert(_ animation: AnimationProtocol, at index: Int) {
        animations.insert(animation, at: index)
    }

    /// Private stagger method
    /// - Parameters:
    ///   - blocks: AnimationProtocol
    ///   - interval: Interval until next animation is fired
    ///   - startDelay: Delay duration of sequence
    ///   - completion: Completion block fired at end of sequence
    private static func stagger(
        _ blocks: [AnimationProtocol],
        interval: TimeInterval,
        startDelay: TimeInterval = 0,
        completion: (() -> Void)? = nil) {
        func iterate(index: Int, closure: ((Bool) -> Void)? = nil) {
            guard let block = blocks.get(at: index) else {
                return
            }
            switch block {
            case is Animation:
                guard let block = block as? Animation else { return }
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(block.easing)
                UIView.animate(
                    withDuration: block.duration,
                    delay: block.delay ?? 0,
                    animations: block.animation,
                    completion: closure)
                CATransaction.commit()
            case is Animation.Stagger:
                guard let block = block as? Animation.Stagger else { return }
                block.start(completion: closure)
            case is Animation.Sequence:
                guard let block = block as? Animation.Sequence else { return }
                block.start(completion: closure)
            case is Animation.Parallel:
                guard let block = block as? Animation.Parallel else { return }
                block.start(completion: closure)
            case is Animation.Wait:
                guard let block = block as? Animation.Wait else { return }
                DispatchQueue.main.asyncAfter(deadline: .now() + block.duration) {
                    closure?(true)
                }
            default:
                break
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                let nmxtIndex = index + 1
                iterate(index: index + 1) { _ in
                    if nmxtIndex == blocks.count - 1 {
                        completion?()
                    }
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            iterate(index: 0)
        }
    }
}

/// Animation Parallel
public struct AnimationParallel: AnimationProtocol {
    var animations: [AnimationProtocol]
    var delay: TimeInterval

    /// An array of animations that are started in parallel
    /// - Parameters:
    ///   - animations: Array of animations
    ///   - delay: Delay to start parallel
    init(
        _ animations: [AnimationProtocol],
        delay: TimeInterval = 0) {
        self.animations = animations
        self.delay = delay
    }

    /// Method to fire off parallel animation
    /// - Parameter completion: Parallel animation completion
    public func start(completion: ((Bool) -> Void)? = nil) {
        AnimationParallel.parallel(animations, startDelay: delay) {
            completion?(true)
        }
    }

    /// Appends an animation block to the end of the sequence
    /// - Parameter animation: AnimationProtocol to be added
    mutating func append(_ animation: AnimationProtocol) {
        animations.append(animation)
    }

    /// Inserts an animation block to the end of the sequence
    /// - Parameters:
    ///   - animation: AnimationProtocol to be added
    ///   - index: Index in sequence for Animation to be added
    mutating func insert(_ animation: AnimationProtocol, at index: Int) {
        animations.insert(animation, at: index)
    }

    static func parallel(
        _ blocks: [AnimationProtocol],
        startDelay: TimeInterval = 0,
        completion: (() -> Void)? = nil) {
        func iterate(index: Int, closure: ((Bool) -> Void)? = nil) {
            guard let block = blocks.get(at: index) else {
                return
            }
            switch block {
            case is Animation:
                guard let block = block as? Animation else { return }
                CATransaction.begin()
                CATransaction.setAnimationTimingFunction(block.easing)
                UIView.animate(
                    withDuration: block.duration,
                    delay: block.delay ?? 0,
                    animations: block.animation,
                    completion: closure)
                CATransaction.commit()
            case is Animation.Stagger:
                guard let block = block as? Animation.Stagger else { return }
                block.start(completion: closure)
            case is Animation.Sequence:
                guard let block = block as? Animation.Sequence else { return }
                block.start(completion: closure)
            case is Animation.Parallel:
                guard let block = block as? Animation.Stagger else { return }
                block.start(completion: closure)
            default:
                break
            }
            let nmxtIndex = index + 1
            iterate(index: index + 1) { _ in
                if nmxtIndex == blocks.count - 1 {
                    completion?()
                }
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            iterate(index: 0)
        }
    }
}

extension Collection {
    func get(at index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public extension CAMediaTimingFunction {
    /// CSS default ease
    static let ease = CAMediaTimingFunction(controlPoints: 0.17, 0.67, 0.83, 0.67)
    static let easeInSine = CAMediaTimingFunction(controlPoints: 0.47, 0, 0.745, 0.715)
    static let easeOutSine = CAMediaTimingFunction(controlPoints: 0.39, 0.575, 0.565, 1)
    static let easeInOutSine = CAMediaTimingFunction(controlPoints: 0.445, 0.05, 0.55, 0.95)
    static let easeInQuad = CAMediaTimingFunction(controlPoints: 0.55, 0.085, 0.68, 0.53)
    static let easeOutQuad = CAMediaTimingFunction(controlPoints: 0.25, 0.46, 0.45, 0.94)
    static let easeInOutQuad = CAMediaTimingFunction(controlPoints: 0.455, 0.03, 0.515, 0.955)
    static let easeInCubic = CAMediaTimingFunction(controlPoints: 0.55, 0.055, 0.675, 0.19)
    static let easeOutCubic = CAMediaTimingFunction(controlPoints: 0.215, 0.61, 0.355, 1)
    static let easeInOutCubic = CAMediaTimingFunction(controlPoints: 0.645, 0.045, 0.355, 1)
    static let easeInQuart = CAMediaTimingFunction(controlPoints: 0.895, 0.03, 0.685, 0.22)
    static let easeOutQuart = CAMediaTimingFunction(controlPoints: 0.165, 0.84, 0.44, 1)
    static let easeInOutQuart = CAMediaTimingFunction(controlPoints: 0.77, 0, 0.175, 1)
    static let easeInQuint = CAMediaTimingFunction(controlPoints: 0.755, 0.05, 0.855, 0.06)
    static let easeOutQuint = CAMediaTimingFunction(controlPoints: 0.23, 1, 0.32, 1)
    static let easeInOutQuint = CAMediaTimingFunction(controlPoints: 0.86, 0, 0.07, 1)
    static let easeInExpo = CAMediaTimingFunction(controlPoints: 0.95, 0.05, 0.795, 0.035)
    static let easeOutExpo = CAMediaTimingFunction(controlPoints: 0.19, 1, 0.22, 1)
    static let easeInOutExpo = CAMediaTimingFunction(controlPoints: 1, 0, 0, 1)
    static let easeInCirc = CAMediaTimingFunction(controlPoints: 0.6, 0.04, 0.98, 0.335)
    static let easeOutCirc = CAMediaTimingFunction(controlPoints: 0.075, 0.82, 0.165, 1)
    static let easeInOutCirc = CAMediaTimingFunction(controlPoints: 0.785, 0.135, 0.15, 0.86)
    static let easeInBack = CAMediaTimingFunction(controlPoints: 0.6, -0.28, 0.735, 0.045)
    static let easeOutBack = CAMediaTimingFunction(controlPoints: 0.175, 0.885, 0.32, 1.275)
    static let easeInOutBack = CAMediaTimingFunction(controlPoints: 0.68, -0.55, 0.265, 1.55)
}
