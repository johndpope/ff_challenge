## Installation

Open the Xcode Project in Xcode 9+ and run on the simulator. This project _will not_
run on device, only sim.

A few notes:

- You may need to change the development team. To do that, top on the project at the
top of the file navigator and switch to the General tab. Team name is under 'Signing'.
- You also need Swift 4+ installed (should be the case if you have Xcode 9 installed).
- Press the Begin button in the simulator to start processing routes.

## Summary

This project is designed to run in Xcode, on the iPhone simulator. It will output to
the console and a text file. I wrote the program in Swift as that is the language I
have been writing in exclusively for the past several months, and I was interested
to see how it could be done

I decided to solve the problem using a genetic algorithm, as most of my experience is
in mobile development, focussed on UI, networking and etc, instead of algorithm design.
I reasoned that the genetic approach gave me a faster way of finding a solution without
'tinkering', because the program will try to solve it for me.

The basic implementation of the Reproducing protocol and Genetic class were based upon
the genetic algorithms chapter of _Classic Computer Science Problems in Swift_ by David
Kopec, modified to fit the problem and to work in Swift 4.1. The implementation of Routes
and all other classes, along with fine tuning the algorithm was written from whole cloth.

## Additional

- Swift doesn't include CSV parsing out of the box, and I found it easier to convert the
file to txt. That's why there are two versions of _Kiosk Coords_ in the bundle.
- There is one location ('Medical College of Wisconsin') that has an address in Milwaukee
but coordinates in Chicago. I left this uncorrected.
- You can modify the settings for the experiment in `ViewController.swift`. This includes
the population size, number of generations and other factors. From what I saw, increasing
the number of generations gets a better result than increasing the population.
- In my limited experiments, I never got total distance driven by both drivers below
458 KM. Given that Milwaukee is around 300 KM roundtrip from Chicago, I feel pretty
confident that 450 KM is a reasonable lower bound for this problem.

## Roadmap

In this experiment I used straight-line distance (i.e. delivery by drone). It would be
interesting to convert to driving distance and see if that changes things. Likewise, I
could see adding 'weights' to the paths based upon speed limits, typical traffic patterns,
etc. That could bring this closer to real-world best routes.

Finally, I did some minor performance tuning, but this could be improved. In particular,
everything runs on the main thread right now. Running in parallel should speed things up.
