@echo off
setlocal enabledelayedexpansion

REM Uso: git-link.bat https://github.com/usuario/repo.git
if "%~1"=="" (
  echo Uso: %~nx0 ^<repo_url^>
  exit /b 1
)

set "REPO_URL=%~1"

REM Usa a pasta atual
git init >nul

REM Se origin existe, atualiza a URL; senao, cria
git remote get-url origin >nul 2>nul
if %errorlevel%==0 (
  git remote set-url origin "%REPO_URL%"
) else (
  git remote add origin "%REPO_URL%"
)

git fetch origin
git checkout -B main origin/main

echo OK: pasta ligada ao repo e main alinhada com origin/main
