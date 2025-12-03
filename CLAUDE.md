# CLAUDE.md - OpenGL Template Project Guide

**Last Updated:** 2025-12-03
**Project:** OpenGL ES 3.0 Template with OBJ Loader
**Language:** C++17
**Platform:** Cross-platform (Windows, Linux, macOS)

## Overview

This is a self-contained OpenGL ES 3.0 template project featuring a complete 3D model loader and renderer. The project demonstrates modern OpenGL programming practices with embedded dependencies (GLAD, GLFW, GLM) and serves as both a learning resource and rapid prototyping template.

**Key Features:**
- OBJ file loader supporting positions, normals, and texture coordinates
- First-person camera with mouse controls
- Modern OpenGL ES 3.0 shaders (vertex/fragment)
- Multiple build systems (CMake, Make, Windows batch scripts)
- Cross-platform compatibility

---

## Repository Structure

```
/home/user/OpenGL_Template/
├── main.cpp                      # Main application (384 lines)
├── CMakeLists.txt                # CMake build configuration
├── Makefile                      # GNU Make build configuration
├── build_static.bat              # Windows static linking build script
├── build_dll.bat                 # Windows DLL linking build script
├── README.md                     # Basic project documentation
├── .gitignore                    # Git ignore (*.dll, *.exe)
│
├── glad_4.6/                     # OpenGL 4.6 loader
│   ├── include/
│   │   ├── glad/glad.h           # GLAD header (3,694 lines)
│   │   └── KHR/khrplatform.h     # KHR platform definitions
│   └── src/glad.c                # GLAD implementation (1,833 lines)
│
├── glfw_3.4/                     # GLFW 3.4 windowing library
│   ├── include/GLFW/
│   │   ├── glfw3.h               # GLFW header (6,547 lines)
│   │   └── glfw3native.h         # Native platform access
│   ├── lib-mingw-w64/            # MinGW 64-bit binaries
│   ├── lib-vc2013/ ... lib-vc2022/ # Visual Studio libraries
│   └── docs/html/                # API documentation
│
├── glm_0.9.9.8/                  # GLM math library (header-only)
│   ├── glm/
│   │   ├── glm.hpp               # Main GLM header
│   │   ├── gtc/                  # Core utilities (matrix_transform, type_ptr)
│   │   ├── gtx/                  # Extended features
│   │   ├── vec*.hpp              # Vector types (vec2, vec3, vec4)
│   │   └── mat*.hpp              # Matrix types (mat2-mat4)
│   └── doc/                      # Documentation
│
└── models/                       # 3D model assets
    ├── cube.obj                  # Simple cube (741 bytes)
    ├── pyramid.obj               # Simple pyramid (741 bytes)
    └── cat.obj                   # Complex cat model (5.0 MB)
```

---

## Code Architecture

### Core Components (main.cpp:1-385)

#### 1. Data Structures

**Vertex Structure** (main.cpp:50-54)
```cpp
struct Vertex {
    glm::vec3 pos;      // 3D position
    glm::vec3 nor;      // Normal vector
    glm::vec2 tex;      // Texture coordinates (UV)
};
```

**ObjData Container** (main.cpp:57-60)
```cpp
struct ObjData {
    std::vector<Vertex> vertices;           // Vertex array
    std::vector<unsigned short> indices;    // Index array for rendering
};
```

#### 2. Camera System (main.cpp:63-90)

**Camera Class:**
- Position-based first-person camera
- Euler angle rotation (Yaw/Pitch)
- `GetViewMatrix()` - Returns lookAt transformation
- `ProcessMouseMovement()` - Handles mouse input with sensitivity and pitch clamping

**Global Camera Instance:** (main.cpp:92)
```cpp
Camera camera;
```

**Mouse Callback:** (main.cpp:94-107)
- Registered with GLFW via `glfwSetCursorPosCallback()`
- Handles first-mouse-movement initialization
- Delta calculation for smooth camera movement

#### 3. OBJ File Loader (main.cpp:110-197)

**Function Signature:**
```cpp
bool loadOBJ(const std::string& filename, ObjData& objData)
```

**Supported OBJ Formats:**
- `v x y z` - Vertex positions
- `vn x y z` - Vertex normals
- `vt u v` - Texture coordinates
- `f` faces with formats:
  - `v` - Position only
  - `v/vt` - Position + texture
  - `v//vn` - Position + normal
  - `v/vt/vn` - Position + texture + normal

**Implementation Details:**
- Uses temporary arrays for positions/normals/texcoords
- Lambda function `parseVertex` for face index parsing (main.cpp:151-181)
- Handles 1-indexed OBJ format (converts to 0-indexed)
- Provides default values for missing attributes
- Logs vertex count, index count, and triangle count

#### 4. Shader Management

**Embedded GLSL ES 3.0 Shaders:**

**Vertex Shader** (main.cpp:13-31)
- Inputs: position (location 0), normal (location 1), texCoord (location 2)
- Uniforms: worldMat, viewMat, projMat
- Outputs: v_normal, v_texCoord
- Transforms normals using inverse transpose of world matrix

**Fragment Shader** (main.cpp:34-47)
- Inputs: v_normal, v_texCoord
- Output: fragColor (location 0)
- Renders using normal-based coloring: `vec4(0.5 * v_normal + 0.5, 1.0)`

**Shader Compilation** (main.cpp:200-213)
```cpp
unsigned int compileShader(unsigned int type, const char* source)
```
- Creates shader, compiles source
- Error checking with `glGetShaderiv(GL_COMPILE_STATUS)`
- Logs compilation errors to console

**Program Linking** (main.cpp:216-231)
```cpp
unsigned int createProgram(unsigned int vertexShader, unsigned int fragmentShader)
```
- Attaches shaders, links program
- Error checking with `glGetProgramiv(GL_LINK_STATUS)`
- Logs linking errors to console

#### 5. Main Application Flow (main.cpp:233-385)

**Initialization Sequence:**
1. Parse command-line arguments for OBJ file path (default: `models/cube.obj`)
2. Initialize GLFW library
3. Set OpenGL 3.3 Core Profile context
4. Create 800x600 window
5. Setup mouse callback and disable cursor
6. Initialize GLAD loader
7. Enable depth testing

**OpenGL Setup:**
1. Compile vertex and fragment shaders
2. Create and link shader program
3. Load OBJ file into `ObjData`
4. Create Array Buffer Object (ABO) for vertices
5. Create Element Array Buffer Object (EABO) for indices
6. Configure vertex attributes (position, normal, texCoord)
7. Get uniform locations (worldMat, viewMat, projMat)

**Render Loop:** (main.cpp:339-376)
```cpp
while (!glfwWindowShouldClose(window)) {
    // Delta time calculation
    // ESC key check for exit
    // Clear color and depth buffers
    // Update world matrix (rotation animation)
    // Update view matrix (camera)
    // Update projection matrix (perspective)
    // Upload uniforms to shader
    // Draw elements
    // Swap buffers and poll events
}
```

**Transformation Pipeline:**
- World Matrix: Per-object rotation (animated with time)
- View Matrix: Camera transformation via `glm::lookAt()`
- Projection Matrix: Perspective with 45° FOV, 800/600 aspect, 0.1-100.0 depth range

**Cleanup:**
- Delete buffer objects
- Delete shader program
- Terminate GLFW

---

## Build Systems

### 1. Windows Batch Scripts (MinGW)

**Static Linking:** `build_static.bat`
```batch
g++ main.cpp glad_4.6/src/glad.c -mconsole ^
-I"glfw_3.4/include" ^
-I"glad_4.6/include" ^
-I"glm_0.9.9.8" ^
-L"glfw_3.4/lib-mingw-w64" ^
-lglfw3 -lopengl32 -lgdi32 -luser32 -lshell32 ^
-o main.exe
```

**DLL Linking:** `build_dll.bat`
```batch
g++ main.cpp glad_4.6/src/glad.c -mconsole ^
-I"glfw_3.4/include" ^
-I"glad_4.6/include" ^
-I"glm_0.9.9.8" ^
-L"glfw_3.4/lib-mingw-w64" ^
-lglfw3dll -lopengl32 -lgdi32 -luser32 -lshell32 ^
-o main.exe
# Automatically copies glfw3.dll to current directory
```

**Usage:**
```cmd
build_static.bat          # Builds and runs with cube model
build_dll.bat             # Builds with DLL linking and runs
main.exe models/cat.obj   # Run with custom model
```

### 2. GNU Make (Linux/Unix)

**File:** `Makefile`

**Targets:**
- `make all` - Build all executables (expects gles_example.cpp, gles_obj_loader.cpp, simple_triangle.cpp)
- `make glad.o` - Compile GLAD source
- `make clean` - Remove binaries
- `make run` - Execute default example
- `make run-obj` - Execute OBJ loader with cube
- `make run-pyramid` - Execute OBJ loader with pyramid

**Configuration:**
```makefile
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra
INCLUDES = -I./glad/include -I/usr/include
LIBS = -lglfw -lGL -ldl -lpthread
```

**Note:** Makefile references source files not present in current state (gles_example.cpp, gles_obj_loader.cpp, simple_triangle.cpp). To use with current `main.cpp`, add a custom target:
```makefile
main: main.cpp glad.o
	$(CXX) $(CXXFLAGS) $(INCLUDES) main.cpp glad.o $(LIBS) -o main
```

### 3. CMake (Cross-Platform)

**File:** `CMakeLists.txt`

**Configuration:**
```cmake
cmake_minimum_required(VERSION 3.10)
project(OpenGLES_Examples)
set(CMAKE_CXX_STANDARD 17)
```

**Dependencies:**
- `find_package(glfw3 REQUIRED)` - System GLFW
- `find_package(glm REQUIRED)` - System GLM
- GLAD compiled from source in project

**Expected Targets:** (Not present in current state)
- `gles_example`
- `gles_obj_loader`
- `simple_triangle`

**Build Instructions:**
```bash
mkdir build && cd build
cmake ..
make
./gles_example
```

**Note:** CMakeLists.txt expects source files not present. To use with `main.cpp`, add:
```cmake
add_executable(main main.cpp)
target_link_libraries(main glad glfw glm::glm ${CMAKE_DL_LIBS})
target_include_directories(main PRIVATE ${GLAD_DIR}/include)
```

---

## Dependencies

### GLAD 4.6 (OpenGL Loader)
- **Version:** 4.6 Core Profile
- **Generated:** 2025-12-02 with glad 0.1.36
- **Purpose:** Runtime OpenGL function pointer loading
- **Files:** `glad_4.6/include/glad/glad.h`, `glad_4.6/src/glad.c`
- **Note:** Must be compiled with application (not header-only)

### GLFW 3.4 (Windowing)
- **Version:** 3.4
- **Purpose:** Window creation, OpenGL context, input handling
- **Platforms:**
  - Windows: MinGW 64-bit, Visual Studio 2013-2022
  - Linux: System package (`libglfw3-dev`)
  - macOS: Homebrew (`brew install glfw`)
- **Linking Options:** Static (`libglfw3.a`, `glfw3.lib`) or DLL (`glfw3.dll`)

### GLM 0.9.9.8 (Math Library)
- **Version:** 0.9.9.8
- **Purpose:** GLSL-like C++ math (vectors, matrices, transformations)
- **Type:** Header-only library
- **Key Headers:**
  - `glm/glm.hpp` - Core types
  - `glm/gtc/matrix_transform.hpp` - Transform functions (translate, rotate, scale, lookAt, perspective)
  - `glm/gtc/type_ptr.hpp` - Memory access for uniform uploads

---

## Development Workflows

### Quick Start (Windows)

1. **Build and run with static linking:**
   ```cmd
   build_static.bat
   ```

2. **Build with DLL linking:**
   ```cmd
   build_dll.bat
   ```

3. **Run with custom model:**
   ```cmd
   main.exe models/cat.obj
   ```

### Linux Development

1. **Install system dependencies:**
   ```bash
   sudo apt-get install libglfw3-dev libglm-dev
   ```

2. **Build with Make:**
   ```bash
   # Add main target to Makefile first
   make main
   ./main models/cube.obj
   ```

3. **Build with CMake:**
   ```bash
   mkdir build && cd build
   cmake ..
   make
   ```

### Adding New Models

1. Place OBJ file in `models/` directory
2. Ensure OBJ file includes:
   - Vertex positions (`v x y z`)
   - Vertex normals (`vn x y z`) - optional but recommended
   - Texture coordinates (`vt u v`) - optional
   - Faces (`f v1/vt1/vn1 v2/vt2/vn2 v3/vt3/vn3`)
3. Run with: `main.exe models/yourmodel.obj`

### Extending the Code

**Adding Textures:**
1. Add texture loading (use stb_image.h)
2. Update fragment shader to sample texture
3. Pass texture coordinates from vertex shader
4. Bind texture before drawing

**Adding Lighting:**
1. Add light position/color uniforms
2. Update fragment shader with Phong/Blinn-Phong model
3. Pass world-space positions from vertex shader
4. Calculate lighting in fragment shader

**Multiple Objects:**
1. Load multiple OBJ files into separate `ObjData` structures
2. Create separate VBO/EBO pairs for each object
3. Render each object with different world matrices

---

## Key Conventions for AI Assistants

### Code Style

1. **C++ Standard:** C++17 (required)
   - Use standard library: `std::vector`, `std::string`, `std::ifstream`
   - Prefer `auto` for complex iterators
   - Use raw string literals for shaders: `R"(...)"`

2. **Naming Conventions:**
   - Classes: PascalCase (`Camera`)
   - Functions: camelCase (`loadOBJ`, `compileShader`)
   - Variables: camelCase (`worldMatrix`, `vertexShader`)
   - Constants: PascalCase or UPPER_CASE
   - Buffer objects: lowercase acronyms (`abo`, `eabo`)

3. **OpenGL Conventions:**
   - Use modern OpenGL (3.3+ Core Profile)
   - Prefer Vertex Array Objects (VAO) for production code
   - Use `glm::value_ptr()` for uniform uploads
   - Enable error checking in development builds

4. **File Organization:**
   - Headers: GLAD first, then GLFW, then GLM
   - Order: `#include <glad/glad.h>` must come before `<GLFW/glfw3.h>`
   - Embedded shaders at top of file for easy access

### Common Pitfalls

1. **GLAD/GLFW Order:**
   ```cpp
   #include <glad/glad.h>  // MUST be first
   #include <GLFW/glfw3.h>  // MUST be second
   ```

2. **OBJ Indexing:**
   - OBJ files use 1-based indexing
   - Always subtract 1 when parsing indices
   - Handle missing indices gracefully

3. **Matrix Multiplication Order:**
   - GLM uses column-major order (like GLSL)
   - Transformation order: `projection * view * world * position`

4. **Vertex Attributes:**
   - Use `offsetof()` for struct member offsets
   - Ensure stride matches `sizeof(Vertex)`
   - Enable vertex attributes before binding buffers

5. **Build System Paths:**
   - Use relative paths from project root
   - Windows: Use quotes for paths with spaces
   - CMake: Use `${CMAKE_SOURCE_DIR}` for absolute paths

### Testing Changes

1. **Shader Modifications:**
   - Check compilation errors in console output
   - Validate uniform locations are not -1
   - Test with simple colors before complex calculations

2. **OBJ Loader Changes:**
   - Test with simple models first (cube.obj)
   - Verify vertex/index counts match expected values
   - Check normal visualization (current shader shows normals as colors)

3. **Camera Changes:**
   - Test mouse sensitivity
   - Verify pitch clamping (-89° to +89°)
   - Check for gimbal lock issues

### Performance Considerations

1. **Model Loading:**
   - Current implementation duplicates vertices (no vertex deduplication)
   - For large models, consider implementing vertex cache
   - Use `unsigned int` indices for models >65,535 vertices

2. **Rendering:**
   - Single draw call per object (good)
   - Consider batching for multiple objects
   - Use instancing for repeated objects

3. **GLM Math:**
   - Header-only library has compilation overhead
   - Consider precompiled headers for large projects
   - Use GLM_FORCE_INLINE for performance builds

### Debugging Tips

1. **OpenGL Errors:**
   ```cpp
   GLenum err;
   while((err = glGetError()) != GL_NO_ERROR) {
       std::cout << "OpenGL error: " << err << std::endl;
   }
   ```

2. **Shader Debugging:**
   - Use simple output colors first
   - Visualize normals: `fragColor = vec4(0.5 * v_normal + 0.5, 1.0)`
   - Check uniform uploads with debug prints

3. **File Loading:**
   - Print file paths before loading
   - Check file existence with `std::ifstream::is_open()`
   - Verify working directory matches expectations

---

## Git Workflow

**Current Branch:** `claude/claude-md-mipc0sxnll44db4f-01Eaqt5AJTsAaABRyALqsETt`

### Commit History
```
9a83d68 - 6th Commit (Latest: main.cpp rewrite, models added)
7f53d9e - readme Update
470869b - Fifth Commit
476cecf - Fourth Commit
2a1daa1 - Add .gitignore
```

### .gitignore
```
glfw3.dll
main.exe
```

**Note:** Consider adding:
```
*.o
build/
*.out
.vscode/
.vs/
```

---

## Platform-Specific Notes

### Windows (MinGW/MSVC)

**MinGW:**
- Use included libraries in `glfw_3.4/lib-mingw-w64/`
- Link with: `-lopengl32 -lgdi32 -luser32 -lshell32`
- Static linking recommended for portability

**Visual Studio:**
- Use libraries from `glfw_3.4/lib-vc20XX/` matching VS version
- Link with: `opengl32.lib gdi32.lib user32.lib shell32.lib`
- Set subsystem to Console (`/SUBSYSTEM:CONSOLE`)

**DLL Deployment:**
- Copy `glfw3.dll` to executable directory
- Or add DLL directory to PATH

### Linux

**Required Packages:**
```bash
sudo apt-get install build-essential libglfw3-dev libglm-dev
```

**System Libraries:**
- GLFW: `-lglfw`
- OpenGL: `-lGL`
- Dynamic loader: `-ldl`
- Threading: `-lpthread`

**X11 Dependencies:**
- GLFW requires X11 development headers
- Install: `sudo apt-get install xorg-dev`

### macOS

**Homebrew Dependencies:**
```bash
brew install glfw glm
```

**Frameworks:**
- Link with: `-framework OpenGL -framework Cocoa -framework IOKit`
- CMake handles this automatically with `find_package(glfw3)`

---

## Extending the Template

### Adding External Shaders

1. Create `shaders/` directory
2. Store shaders as `.vert` and `.frag` files
3. Implement file loading:
   ```cpp
   std::string loadShaderFile(const std::string& path) {
       std::ifstream file(path);
       std::stringstream buffer;
       buffer << file.rdbuf();
       return buffer.str();
   }
   ```

### Adding Texture Support

1. Include stb_image.h (single-header library)
2. Load texture:
   ```cpp
   int width, height, channels;
   unsigned char* data = stbi_load("texture.png", &width, &height, &channels, 0);
   ```
3. Create OpenGL texture:
   ```cpp
   unsigned int texture;
   glGenTextures(1, &texture);
   glBindTexture(GL_TEXTURE_2D, texture);
   glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
   glGenerateMipmap(GL_TEXTURE_2D);
   ```

### Implementing Lighting

1. Update vertex shader to output world position
2. Add uniform for light position
3. Implement Phong model in fragment shader:
   ```glsl
   vec3 norm = normalize(v_normal);
   vec3 lightDir = normalize(lightPos - fragPos);
   float diff = max(dot(norm, lightDir), 0.0);
   vec3 diffuse = diff * lightColor;
   ```

---

## Troubleshooting

### Build Errors

**"Cannot find -lglfw":**
- Windows: Verify library path in `-L` flag
- Linux: Install `libglfw3-dev`
- macOS: Install via `brew install glfw`

**"undefined reference to glad":**
- Ensure `glad.c` is compiled and linked
- Check include path for `glad/glad.h`

**"GL/gl.h not found":**
- Install OpenGL development headers
- Linux: `sudo apt-get install mesa-common-dev`

### Runtime Errors

**"Failed to initialize GLFW":**
- Check if display server is running (X11/Wayland on Linux)
- Verify graphics drivers are installed

**"Failed to create GLFW window":**
- Reduce OpenGL version requirement
- Check if GPU supports OpenGL 3.3+
- Try compatibility profile instead of core

**"Failed to initialize GLAD":**
- Ensure `glfwMakeContextCurrent()` is called before `gladLoadGLLoader()`
- Verify OpenGL context creation succeeded

**Black screen / No rendering:**
- Check shader compilation errors
- Verify vertex attributes are enabled
- Ensure depth testing is enabled
- Check if model is within view frustum

### Model Loading Issues

**"Failed to open OBJ file":**
- Verify file path is correct
- Check working directory
- Use absolute path for testing

**Incorrect rendering:**
- Verify face format parsing
- Check index calculation (0-based vs 1-based)
- Ensure normals are normalized
- Validate texture coordinates are in [0,1]

---

## Version Information

**Libraries:**
- GLAD: 4.6 Core Profile
- GLFW: 3.4
- GLM: 0.9.9.8

**OpenGL:**
- Context: 3.3 Core Profile
- Shaders: ES 3.0 (compatible with desktop 3.3+)

**C++ Standard:** C++17

**Last Updated:** 2025-12-03

---

## Resources

**Documentation:**
- GLFW: https://www.glfw.org/documentation.html
- GLAD: https://glad.dav1d.de/
- GLM: https://github.com/g-truc/glm/blob/master/manual.md
- OpenGL: https://docs.gl/

**Tutorials:**
- LearnOpenGL: https://learnopengl.com/
- OpenGL Tutorial: http://www.opengl-tutorial.org/

**OBJ Format:**
- Wavefront OBJ: https://en.wikipedia.org/wiki/Wavefront_.obj_file

---

## Summary for AI Assistants

**When working with this codebase:**

1. **Always read before modifying** - Understand existing code structure
2. **Test with simple models first** - Use cube.obj before cat.obj
3. **Follow OpenGL conventions** - GLAD before GLFW, enable before use
4. **Maintain C++17 compliance** - Use modern features appropriately
5. **Preserve cross-platform support** - Test build systems don't break
6. **Document shader changes** - GLSL errors are cryptic
7. **Respect the template nature** - Keep it simple and educational
8. **Verify build systems** - Changes should work on all platforms

**This template prioritizes:**
- Educational clarity over performance
- Self-containment over external dependencies
- Simplicity over features
- Cross-platform compatibility over platform-specific optimizations

**Current state notes:**
- Build system files (CMakeLists.txt, Makefile) reference non-existent source files
- Only `main.cpp` is present with complete implementation
- Windows batch scripts are fully functional
- All dependencies are bundled (no package manager required)
