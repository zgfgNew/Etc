@echo off
setlocal EnableDelayedExpansion

REM Set working directory to the directory where the batch file is located
cd /d "%~dp0"

REM Define the source for payload-dumper-go.exe and 7z.exe
set "payloadDumper=C:\Portable applications\payload-dumper-go\payload-dumper-go.exe"
set "sevenZip=C:\Program Files\7-Zip\7z.exe"

REM Loop through all zip files in the directory
for %%f in (*.zip) do (
    REM Create a folder named after the zip file (without extension)
    set "zipName=%%~nf"
    set "zipFolder=%~dp0!zipName!"
    
    REM Create the directory
    mkdir "!zipFolder!"
    
    REM Extract the zip file to the directory
    echo Extracting %%f to "!zipFolder!"
    "%sevenZip%" x "%%f" -o"!zipFolder!" -y
    
    REM Copy payload-dumper-go.exe to the extracted folder
    copy "%payloadDumper%" "!zipFolder!"
    
    REM Change to the zip folder
    cd /d "!zipFolder!"
    
    REM Run payload-dumper-go with specified parameters
    payload-dumper-go.exe -c 4 -p product,system,vendor payload.bin

    REM Find the subfolder with the random name
    for /d %%d in (extracted_*) do (
        set "randomSubfolder=%%d"
    )
    
    REM Check if the random subfolder was found
    if not defined randomSubfolder (
        echo Error: No subfolder found with name starting with "extracted_"
        exit /b 1
    )

    REM Extract build.prop from system.img
    echo Extracting system.img contents from "!randomSubfolder!"
    "%sevenZip%" x "!randomSubfolder!\system.img" "system/build.prop" -o"!zipFolder!" -y

    REM Move and rename system/build.prop to the root of the extracted zip folder
    if exist "!zipFolder!\system\build.prop" move "!zipFolder!\system\build.prop" "!zipFolder!\build.prop"

    REM Extract build.prop from product.img
    echo Extracting product.img contents from "!randomSubfolder!"
    "%sevenZip%" x "!randomSubfolder!\product.img" "build.prop" -o"!zipFolder!\product" -y

    REM Move and rename product/build.prop to the root of the extracted zip folder as product-build.prop
    if exist "!zipFolder!\product\build.prop" move "!zipFolder!\product\build.prop" "!zipFolder!\product-build.prop"
    
    REM Extract build.prop from vendor.img
    echo Extracting vendor.img contents from "!randomSubfolder!"
    "%sevenZip%" x "!randomSubfolder!\vendor.img" "build.prop" -o"!zipFolder!\vendor" -y

    REM Move and rename vendor/build.prop to the root of the extracted zip folder as vendor-build.prop
    if exist "!zipFolder!\vendor\build.prop" move "!zipFolder!\vendor\build.prop" "!zipFolder!\vendor-build.prop"

    REM Remove all files and subfolders except the build.prop files
    echo Cleaning up extracted folder
    for /d %%d in ("!zipFolder!\*") do (
        if /I not "%%~nxd"=="build.prop" (
            if /I not "%%~nxd"=="product-build.prop" (
                if /I not "%%~nxd"=="vendor-build.prop" (
                    rd /s /q "%%d"
                )
            )
        )
    )
    for %%f in ("!zipFolder!\*") do (
        if /I not "%%~nxf"=="build.prop" (
            if /I not "%%~nxf"=="product-build.prop" (
                if /I not "%%~nxf"=="vendor-build.prop" (
                    del /q "%%f"
                )
            )
        )
    )

    REM Change back to the working directory
    cd /d "%~dp0"
)

endlocal
