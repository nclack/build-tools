# withvs14
cd build
write-host "Building ..."
MSBuild.exe .\scratch.sln /target:scratch /m /nologo /clp:"Verbosity=minimal;ShowTimestamp;"
mv src\Debug\game.dll src\Debug\game_tmp.dll -Force
mv src\Debug\game.pdb src\Debug\game_tmp.pdb -Force
MSBuild.exe .\scratch.sln /target:game /m /nologo /clp:"Verbosity=minimal;ShowTimestamp;"
write-host "...Done"
cd ..

