withvs14
$root=Split-Path -parent $MyInvocation.MyCommand.Path
$build=join-path $root build
if(!(test-path $build)) {
    mkdir $build
}
cd build
cmake -G "Visual Studio 14 Win64" ..
cd ..
