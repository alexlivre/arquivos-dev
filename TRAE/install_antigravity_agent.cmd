@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM ============================================================
REM Antigravity setup installer (copy validated .agent structure)
REM Source folder must contain:

REM - .agent\skills\page-copywriter-pro\SKILL.md
REM - .agent\skills\seo-landing-page-specialist-ptbr\SKILL.md
REM - .agent\skills\ui-ux-landing-page-pro\SKILL.md
REM - .agent\skills\web-performance-optimizer-no-layout-ptbr\SKILL.md
REM - INKPAGE_UI_KIT.md

REM ============================================================

echo.
echo === Antigravity .agent bootstrapper (validated) ===
echo.

set "SRC=%~dp0"
set "SRC_AGENT=%SRC%.agent"


set "REQ2=%SRC_AGENT%\skills\page-copywriter-pro\SKILL.md"
set "REQ3=%SRC_AGENT%\skills\seo-landing-page-specialist-ptbr\SKILL.md"
set "REQ4=%SRC_AGENT%\skills\ui-ux-landing-page-pro\SKILL.md"
set "REQ5=%SRC_AGENT%\skills\web-performance-optimizer-no-layout-ptbr\SKILL.md"
set "SRC_KIT=%SRC%INKPAGE_UI_KIT.md"

echo Source folder:
echo "%SRC%"
echo.

REM ---- Validate source structure ----
if not exist "%SRC_AGENT%\" (
  echo ERROR: Missing source folder ".agent": "%SRC_AGENT%"
  exit /b 1
)


if not exist "%REQ2%" ( echo ERROR: Missing "%REQ2%" & exit /b 1 )
if not exist "%REQ3%" ( echo ERROR: Missing "%REQ3%" & exit /b 1 )
if not exist "%REQ4%" ( echo ERROR: Missing "%REQ4%" & exit /b 1 )
if not exist "%REQ5%" ( echo ERROR: Missing "%REQ5%" & exit /b 1 )
if not exist "%SRC_KIT%" ( echo ERROR: Missing "%SRC_KIT%" & exit /b 1 )

echo OK: Source structure validated.
echo.

set /P "PROJECT=Enter full path to your PROJECT root (where .agent should be created): "

if "%PROJECT%"=="" (
  echo ERROR: Project path is empty.
  exit /b 1
)

if not exist "%PROJECT%\" (
  echo ERROR: Project path not found: "%PROJECT%"
  exit /b 1
)

set "DST_AGENT=%PROJECT%\.agent"


echo.
echo Creating destination folders...
if not exist "%DST_AGENT%\" mkdir "%DST_AGENT%"

echo.
echo Copying ".agent" structure (skills)...
xcopy "%SRC_AGENT%\*" "%DST_AGENT%\" /E /I /Y >nul
if errorlevel 1 (
  echo ERROR: XCOPY failed.
  exit /b 1
)

echo.
echo Copying INKPAGE_UI_KIT.md...
copy /Y "%SRC_KIT%" "%PROJECT%\" >nul
if errorlevel 1 (
  echo ERROR: Copy failed for INKPAGE_UI_KIT.md.
  exit /b 1
)


REM ---- Validate destination structure ----
echo.
echo Validating destination structure...


set "DREQ2=%DST_AGENT%\skills\page-copywriter-pro\SKILL.md"
set "DREQ3=%DST_AGENT%\skills\seo-landing-page-specialist-ptbr\SKILL.md"
set "DREQ4=%DST_AGENT%\skills\ui-ux-landing-page-pro\SKILL.md"
set "DREQ5=%DST_AGENT%\skills\web-performance-optimizer-no-layout-ptbr\SKILL.md"


if not exist "%DREQ2%" ( echo ERROR: Missing "%DREQ2%" & exit /b 1 )
if not exist "%DREQ3%" ( echo ERROR: Missing "%DREQ3%" & exit /b 1 )
if not exist "%DREQ4%" ( echo ERROR: Missing "%DREQ4%" & exit /b 1 )
if not exist "%DREQ5%" ( echo ERROR: Missing "%DREQ5%" & exit /b 1 )
if not exist "%PROJECT%\INKPAGE_UI_KIT.md" ( echo ERROR: Missing "%PROJECT%\INKPAGE_UI_KIT.md" & exit /b 1 )



echo OK: Destination validated.
echo.
echo Done.
echo Created/updated:

echo "%DST_AGENT%\skills\page-copywriter-pro\SKILL.md"
echo "%DST_AGENT%\skills\seo-landing-page-specialist-ptbr\SKILL.md"
echo "%DST_AGENT%\skills\ui-ux-landing-page-pro\SKILL.md"
echo "%DST_AGENT%\skills\web-performance-optimizer-no-layout-ptbr\SKILL.md"
echo "%PROJECT%\INKPAGE_UI_KIT.md"

echo.

endlocal
exit /b 0
