# Obstructing Wall Dissolve Shader Demo Project
![unknown_replay_2025 09 18-19 20online-video-cutter com-ezgif com-cut](https://github.com/user-attachments/assets/b09b3cc2-a225-4e6b-86df-91683c4c251e)


### This demo project was made in Godot 4.4.1 for [Obstructing Wall Dissolve Shader](https://godotshaders.com/shader/obstructing-wall-dissolve/).

## How to use the shader
You need to set the dissolve and hue noise textures, as well as the object's GlobalPosition in your code. If your object is moving and you want to see it through walls with this shader, update these values every frame.


## How it works
The shader creates a virtual line between the camera and the target object (e.g. player or cube). Each wall pixel checks if it is close to this line. If so, the shader calculates a dissolve effect using 3D noise, animation, and color transitions. As a result, the wall partially disappears along the path between the camera and the object, revealing it when it is obstructed.

### Key steps:
1. **Line of sight calculation**: The shader receives the camera and object positions and determines the line between them.
2. **Pixel detection on the line**: Wall pixels close to this line are marked for dissolving.
3. **Animated noise**: 3D noise (`dissolve_noise_texture`) is used to create irregular dissolve edges.
4. **Color effect**: Additional noise (`hue_noise_texture`) gives subtle color changes to the dissolve effect.
5. **Parameterization**: Shader parameters (radius, transitions, animation speeds) can be modified in the Inspector or via code.


## Project structure

```
ObstructingWallDissolveShader/
├── Src/
│   ├── Camera/
│   │   └── FreeRoamCamera.cs         # Free-roam 3D camera
│   └── Level/
│       ├── CubeMovement.cs          # Cube movement (target object)
│       ├── ShaderUpdater.cs         # Updates shader parameters
│       ├── dissolve.gdshader        # Wall dissolve shader
│       └── ...
├── README.md
└── ...
```


## How to run

1. Open the project in Godot 4.4.1 or newer.
2. Run the `Src/Level/Level.tscn` scene.
3. Control the camera with mouse and keyboard (WASD, Shift, Space).
4. Observe the wall dissolve effect when the cube is obstructed. You can also turn the cube movement on and off.


## Code and shaders

- **dissolve.gdshader**: `spatial` shader, supports parameters:
  - `cube_position` (target position)
  - `line_radius` (effect radius)
  - `dissolve_noise_texture`, `hue_noise_texture` (noise textures)
  - animation: speed, amplitude, rotation
- **ShaderUpdater.cs**: Script generates 3D noise textures and passes them to the shader, updates the target position every frame.
- **CubeMovement.cs**: Simple cube movement (sinusoidal on X axis).
- **FreeRoamCamera.cs**: FP camera with mouse and speed boost support.