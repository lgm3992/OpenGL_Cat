@echo off
chcp 65001 >nul
echo [진행] DLL 빌드...

g++ main.cpp glad_4.6/src/glad.c -mconsole -Iglfw_3.4/include -Iglad_4.6/include -Iglm_0.9.9.8 -Lglfw_3.4/lib-mingw-w64 -lglfw3 -lopengl32 -lgdi32 -luser32 -lshell32 -shared -o main.dll

if %errorlevel%==0 (
    copy glfw_3.4\lib-mingw-w64\glfw3.dll . >nul
    echo [성공] DLL+glfw3.dll 준비됨
) else (
    echo [실패] DLL 빌드 실패!
    pause
    exit /b 1
)

echo [진행] 실행파일 빌드...
g++ main.cpp glad_4.6/src/glad.c -mconsole -Iglfw_3.4/include -Iglad_4.6/include -Iglm_0.9.9.8 -L. -Lglfw_3.4/lib-mingw-w64 -lmain -lglfw3 -lopengl32 -lgdi32 -luser32 -lshell32 -o main_test.exe

if %errorlevel%==0 (
    echo [완료] OpenGL 창 실행!
    main_test.exe
) else (
    echo [실패] 실행파일 빌드 실패!
)

pause
