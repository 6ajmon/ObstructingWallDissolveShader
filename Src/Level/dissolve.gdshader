// Dissolve effect shader that creates a line-of-sight dissolve effect between camera and target
// Objects dissolve with animated noise when they obstruct the view to the target cube
shader_type spatial;
render_mode blend_mix, cull_disabled;

// Position of the target cube we want to see through obstacles
uniform vec3 cube_position;
// Radius of the dissolve line effect
uniform float line_radius = 1.0;
// Start point of the dissolve transition (lower values = more dissolved)
uniform float transition_in : hint_range(-1.0, 1.0) = -0.5;
// End point of the dissolve transition (higher values = less dissolved)
uniform float transition_out : hint_range(-1.0, 1.0) = 0.5;

// 3D noise textures for dissolve and color effects (set in code)
uniform sampler3D dissolve_noise_texture;
uniform sampler3D hue_noise_texture;

// Animation parameters
uniform float animation_speed : hint_range(0.1, 5.0) = 0.6;
uniform float wave_amplitude : hint_range(0.0, 2.0) = 0.5;
uniform float rotation_speed : hint_range(0.0, 2.0) = 0.2;

// Rotates a 3D position around the Y-axis by the given angle
vec3 rotate_y(vec3 pos, float angle) {
    float cos_a = cos(angle);
    float sin_a = sin(angle);
    return vec3(
        pos.x * cos_a - pos.z * sin_a,
        pos.y,
        pos.x * sin_a + pos.z * cos_a
    );
}

// Converts HSV color to RGB color space
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
    // Get world position of current fragment and camera position
    vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 camera_pos = INV_VIEW_MATRIX[3].xyz;

    // Calculate the line from camera to target cube
    vec3 line_dir = normalize(cube_position - camera_pos);
    vec3 line_start = camera_pos;
    
    // Find the closest point on the camera-to-cube line to this fragment
    vec3 to_fragment = world_pos - line_start;
    float proj_length = dot(to_fragment, line_dir);
    vec3 closest_point = line_start + line_dir * proj_length;
    
    // Calculate distance from fragment to the line of sight
    float dist_to_line = distance(world_pos, closest_point);
    
    // Check if fragment is between camera and cube (blocking the view)
    float dist_camera_to_cube = distance(camera_pos, cube_position);
    float dist_camera_to_fragment = distance(camera_pos, world_pos);
    bool is_between_camera_and_cube = dist_camera_to_fragment < dist_camera_to_cube;
    
    // Animated time for dynamic effects
    float time = TIME * animation_speed;
    
    // Create animated position with rotation and wave distortion
    vec3 animated_pos = rotate_y(world_pos, time * rotation_speed);
    
    // Add wave distortion to create more organic movement
    animated_pos.x += sin(time + world_pos.y * 2.0) * wave_amplitude;
    animated_pos.z += cos(time + world_pos.x * 2.0) * wave_amplitude;
    
    // Sample dissolve noise with animated coordinates
    vec3 noise_coords = animated_pos * 0.1 + vec3(time * 0.1, 0.0, 0.0);
    float dissolve_noise = texture(dissolve_noise_texture, noise_coords).r;
    
    // Calculate dissolve cutoff based on distance to line of sight
    float cutoff = 1.0 - smoothstep(transition_in, transition_out, dist_to_line - line_radius);
    
    // Discard fragments that are blocking the view and below the dissolve threshold
    if (is_between_camera_and_cube && dissolve_noise < cutoff) {
        discard;
    }
    
    // Apply different rendering for back faces vs front faces
    if (FRONT_FACING == false) {
        // Back faces get animated hue-shifted emission color
        vec3 hue_coords = animated_pos * 0.05 + vec3(0.0, time * 0.05, 0.0);
        float hue_offset = texture(hue_noise_texture, hue_coords).r;
        vec3 hsv = vec3(hue_offset, 0.85, 0.75);
        vec3 rgb = hsv2rgb(hsv);
        EMISSION = rgb;
        ALBEDO = vec3(0);
    } else {
        // Front faces are white
        ALBEDO = vec3(1.0, 1.0, 1.0);
    }
}