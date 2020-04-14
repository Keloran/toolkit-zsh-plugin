# Toolkit that I use almost everyday

### ThirdParty Additions
- [Premek's MV](https://gist.github.com/premek/6e70446cfc913d3c929d7cdbfe896fef)

## Utils
```
projects = goto ~/Documents/Projects
```
This is especially useful if you have icloud documents synced, only problem is that .git also gets synced

```
cleanOpenWith
```
This cleans the "open with" menu on osx

```
updatedb
```
This runs the updatedb command, or it launches the locate plist which osx tells you to run if you havent yet

```
filemerge
```
This launches FileMerge which comes with Xcode

```
mkd $0

e.g.
mkd tester
```
This creates the directory and then moves you into that directory

```
digga $0

e.g.
digga google.com
```
This runs dig on the domain and gives all the info for it
```
updateSys
```
This runs all the update commands for a mac (well all the ones I use,
- brew update/upgrade
- brew cask upgrade
- mas outdated
- zplug update

## Docker
```
cleanDockerImages
```
Does what it says

```
dockerRemoveDangling
```
Does what it says

```
dockerUpdateAll
```
This runs through all your images and grabs the "latest" tagged version of them

```
dockerPsClean
```
This is used to get rid of any stale/exited images and clean the list, so that you can use the same name again

```
dockerStop
dockerStart
dockerRestart
```
These commands use either docker-compose, docker.sh (custom file you create to do various things, e.g build databases) and do their counterparts
e.g. dockerStart will run build the image and stick it into daemon mode

```
dockerExec $0

e.g.
dockerExec app
```
This will launch sh or any program you specify on that container, e.g. docker app starter will run "starter" on app container, either docker-compose or standard docker

```
dockerAWS $1 $2 $3

e.g.
dockerAWS tester 12345 eu-west-2
```
This will try and push the container tester to ECR in eu-west-2 under teh 12345 account
