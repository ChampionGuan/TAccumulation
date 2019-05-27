chcp 65001
@echo off
echo 正在生成apk文件
@set unity="G:\Program Files\Unity17.4.24f1\Editor\unity.exe"
@set path="E:\2_champion\temp\temp"
%unity% -projectPath %path% -quit -batchmode -executeMethod APKBuild.Build -logFile build.log
echo 生成apk成功！！
pause