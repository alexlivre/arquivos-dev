@echo off
setlocal

cd /d "C:\code\GitHub\inkpage" || exit /b 1

git fetch origin
git reset --hard origin/main

echo.
echo OK: sincronizado com origin/main.
pause
