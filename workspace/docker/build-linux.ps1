#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
Set-PSDebug -Trace 0

# Windows 8.1
# docker -c win run -it <tag> cmd
# docker context create linux --description "Linux containers (Docker Toolbox)" --default-stack-orchestrator=swarm --docker "host=tcp://192.168.99.100:2376,ca=%userprofile%\.docker\machine\machines\default\ca.pem,cert=%userprofile%\.docker\machine\machines\default\cert.pem,key=%userprofile%\.docker\machine\machines\default\key.pem"
# Windows 10
# docker context create linux --description "Linux containers (Docker Toolbox)" --default-stack-orchestrator=swarm --docker "host=tcp://192.168.99.100:2376,ca=$env:userprofile\.docker\machine\machines\default\ca.pem,cert=$env:userprofile\.docker\machine\machines\default\cert.pem,key=$env:userprofile\.docker\machine\machines\default\key.pem"

$cfg = "release"
([string]$args).split('-') | %{
    if ($_.Split(' ')[0].ToUpper() -eq "c") {
        $cfg = $_.Split(' ')[1]
        echo "build config is $cfg..."
    }
}

docker -c linux run -it -v /z/workspace:/mnt `
    --rm ice-ubuntu-base /bin/bash -c "cd mnt/; /mnt/build-linux.sh -c $cfg"
