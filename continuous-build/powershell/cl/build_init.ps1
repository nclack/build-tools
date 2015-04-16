withvs14
$root=Split-Path -parent $MyInvocation.MyCommand.Path
$build=join-path $root build
if(!(test-path $build)) {
    mkdir $build
}
cd build
cd ..
