# Toolkit for docker and various mac utils
#
# Author: Keloran

# if [[ ${commands[docker]} ]]; then
#   source <(docker completion zsh)
# fi

# Projects
if [[ -d $HOME/Documents/Projects ]]; then
  alias projects='cd ~/Documents/Projects'
fi

# Docker
function cleanDockerImages() {
  docker ps -a | grep 'Exited' | awk '{print $1}' | xargs docker rm
  docker images -aq | xargs docker rmi
}

function dockerRemoveDangling() {
  docker images -f 'dangling=true' -q | awk '{print $1}' | xargs -L1 docker rmi
}

function dockerUpdateAll() {
  docker images --format '{{.Repository}} {{.Tag}}' | awk '{print $1 ":" $2}' | grep -iv 'repository' | xargs -L1 docker pull
}

function dockerPsClean() {
  docker ps -a --format '{{.Names}} {{.Status}}' | grep 'Exited' | awk '{print $1}' | xargs docker rm
}

function dockerClean() {
  if [[ ${commands[docker-clean]} ]]; then
    docker-clean
  fi
}

function dockerStop() {
  if [[ -e $(pwd)Makefile ]]; then
    MakeDown=$(grep '^[^#[:space:]].*:' Makefile | grep docker-down)
    if [[ -n $MakeDown ]]; then
      make docker-down
      dockerClean
      return
    fi
  fi

  if [[ -e $(pwd)/docker-compose.yml ]]; then
    docker-compose stop
    yes | docker-compose rm
    dockerPsClean
    dockerClean
    return
  fi

  dockerpath=$(basename "${PWD##*/}" | tr '[:upper:]' '[:lower:]')
  docker stop "${dockerpath}"_build
  docker rmi "${dockerpath}"_build
  dockerPsClean
  dockerClean
}

function dockerStart() {
  dockerStop

  if [[ -e $(pwd)/Makefile ]]; then
    MakeUp=$(grep '^[^#[:space:]].*:' Makefile | grep docker-up)
    if [[ -n $MakeUp ]]; then
      make docker-up
      return
    fi
  fi


  if [[ -e $(pwd)/docker.sh ]]; then
    sh -c "$(pwd)"/docker.sh
    return
  fi

  if [[ -e $(pwd)/docker-compose.yml ]]; then
    docker-compose build
    docker-compose up -d
    docker-compose ps
    return
  fi

  dockerpath=$(basename "${PWD##*/}" | tr '[:upper:]' '[:lower:]')
  docker build -t "${dockerpath}" .
  docker run -P --rm -d -it --name "${dockerpath}"_build "${dockerpath}"
}

function dockerExec() {
  if [[ -e $(pwd)/docker-compose.yml ]]; then
    if [[ -z $1 ]]; then
      echo "need a container to execute into"
      docker-compose ps -a
    else
      if [[ -z $2 ]]; then
        docker-compose exec "$1" sh
      else
        docker-compose exec "$1" "$2"
      fi
    fi
    return
  fi

  dockerpath=$(basename "${PWD##/*}" | tr '[:upper:]' '[:lower"]')
  if [[ -z $1 ]]; then
    docker exec "${dockerpath}"_build sh
  else
    docker exec "${dockerpath}"_build "$1"
  fi
}

function dockerLogs() {
  if [[ -e $(pwd)/docker-compose.yml ]]; then
    if [[ -z $1 ]]; then
      docker-compose logs -f
    else
      docker-compose logs -f "$1"
    fi
    return
  fi

  dockerpath=$(basename "${PWD##*/}" | tr '[:upper:]' '[:lower:]')
  docker logs -f "${dockerpath}"_build
}

function dockerRestart() {
  if [[ -e $(pwd)/docker-compose.yml ]] && [[ -n $1 ]]; then
    docker-compose stop "$1"
    docker-compose up -d "$1"
  else
    dockerStop
    dockerStart
  fi
}

function dockerAWS() {
  repoName=$1
  accountNumber=$2
  location=$3

  aws ecr get-login --no-include-email --region "${location}"
  docker build -t "${repoName}"
  docker tag "${repoName}":latest "${accountNumber}".dkr."${location}".amazonaws.com/"${repoName}":latest
  docker push "${accountNumber}".dkr.ecr."${location}"/"${repoName}":latest
}

alias docker-start='dockerStart'
alias docker-start-logs='dockerStart && docker-logs'
alias docker-stop='dockerStop'
alias docker-logs='docker-compose logs -f'
alias docker-restart='docker-stop && docker-start'
alias dpsa='docker ps -a'

# Mac
if [[ ! -f /var/db/locate.database ]]; then
  alias updatedb='sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist'
else
  alias updatedb='sudo /usr/libexec/locate.updatedb'
fi
alias filemerge='open -a FileMerge'

function cleanOpenWith() {
  /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user
  killall Finder
}

# Utils
function mkd() {
  mkdir -p "$1" && cd "$1" || return
}

if [[ ${commands[colordiff]} ]]; then
  function cdiff() {
    colordiff -u "$@"
  }
fi

if [[ ${commands[dig]} ]]; then
  function digga() {
    dig +nocmd "$1" ANY +multiline +noall +answer
  }
fi

function updateSys() {
  if [[ -f $ZSH/oh-my-zsh.sh ]]; then
    omz update
  fi

  if [[ ${commands[brew]} ]]; then
    brew update
    brew upgrade
    brew upgrade --cask
    brew cleanup
  fi

  if [[ ${commands[mas]} ]]; then
    mas outdated
  fi

  zplugs=$(declare -f zplug > /dev/null; echo $?)
  if [[ ${zplugs} == 0 ]]; then
    zplug update
  fi
}

function mvi() {
  if [[ "$#" -ne 1 ]]; then
    command mv "$@"
    return
  fi
  if [[ ! -f "$1" ]]; then
    command file "$@"
    return
  fi
  read -eir "$1" newFilename
  mv -v "$1" "$newFilename"
}

function kubePort() {
	PORT=
	SVC=$(kubectl get pod | grep "$1" | sed 's/\ .*//')
	SERVICE_NAME=$2

	case $SERVICE_NAME in
		mysql)
			PORT=3306
			;;
		bianca)
			PORT=9111
			;;
	esac

	if [[ "$SERVICE_NAME" == "" ]]; then
		echo "Service Needed"
		return
	fi

	if [[ "$PORT" == "" ]]; then
		echo "You need a port to forward"
		return
	fi

	echo "Forwarding for $SERVICE_NAME"
	kubectl port-forward "$SVC" $PORT:$PORT
}
