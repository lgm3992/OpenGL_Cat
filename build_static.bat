@echo off
chcp 65001 >nul

g++ main.cpp glad_4.6/src/glad.c -mconsole -I"glfw_3.4/include" -I"glad_4.6/include" -I"glm_0.9.9.8" -L"glfw_3.4/lib-mingw-w64" -lglfw3 -lopengl32 -lgdi32 -luser32 -lshell32 -o main.exe

if %errorlevel%==0 (
    echo [성공] 빌드 성공! main.exe 실행합니다.
    main.exe
) else (
    echo [실패] 빌드 에러!
)

pause
