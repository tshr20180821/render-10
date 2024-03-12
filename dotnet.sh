#!/bin/bash

set -x

export PS4='+(${BASH_SOURCE}:${LINENO}): '

curl -sSLO https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

apt-get -qq update

DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends dotnet-sdk-8.0

dotnet --help

export HOME=/tmp/usr

mkdir ${HOME}

dotnet new console -o con1

pushd con1

echo "namespace HelloWorld;" >Program.cs
echo "" >>Program.cs
echo "class Program" >>Program.cs
echo "{" >>Program.cs
echo "    static void Main(string[] args)" >>Program.cs
echo "    {" >>Program.cs
echo "        Console.WriteLine(\"Hello\");" >>Program.cs
echo "    }" >>Program.cs
echo "}" >>Program.cs

dotnet build

ls -lang
ls -lang bin/

popd
