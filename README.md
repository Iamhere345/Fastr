# Fastr

## Project Postmortem

This project has been archived. It's codebase it hard to work with and has not been actively worked for 6 months. The most recent changes to Fastr are in the IMD repository, and a replacement for Fastr may come in the future. Fastr didn't really live up to it's goals – it certainly wasn't bloatware-free or lightweight, and it had horrible api for creating commands. Features like `*` and `+` were pretty broken and the whole architecture was flawed. It is not reccomended to use Fastr in new work.

Fastr is a bloat ware free, lightweight, highly configurable roblox admin system designed to be easy to use.

## Links
 - [Docs](https://iamhere345.github.io/Fastr)
 - [Trello](https://trello.com/b/tsQIMnkb/fastr)

## Installation
 
### With Rojo

#### Downloading

##### using CLI
 - cd to your desired directory
 - `git clone https://github.com/Iamhere345/Fastr.git`

##### Using github releases
 - go to the github releases page and download the latest stable release
 - extract the zip file in your desired directory

#### Installing

#### Using CLI
- run `foreman install` (if you don't have foreman you can [download it here](https://github.com/Roblox/foreman), or you can use a manually installed version of rojo. This is only nessesary if you want to contribute to Fastr)
 - run `rojo serve`
 - connect to the rojo instance in studio using the rojo plugin (if you don't have the rojo plugin use `rojo plugin install`)

#### Alternative Installation
 - run `rojo serve` using your installation of rojo (if you don't have rojo refer to roblox installation method or download rojo [here](https://github.com/rojo-rbx/rojo)
 - connect to the rojo instance using the rojo plugin

### With Roblox

download either of these models and add them to your roblox game. (note: the loader version does not include the source code of Fastr, instead it requires Fastr (it can be configured to require the stable, unstable and experimental versions of Fastr). The Source version comes with all of Fastr's source code, which means you can modify it to your liking, but it won't automatically update.)

- [Source version](https://www.roblox.com/library/7768369303/)
- [Loader version](https://www.roblox.com/library/7981503602/)

 
## Branches
 
### main
all stable features should be pushed to this branch and it is reccomended you use this over the other branches
 
### unstable
the development version of Fastr that is actively worked on. Features may be untested

### experimental
where new features are evaluated. May also be untested

## Features
 
### WIP, view docs site for more info
