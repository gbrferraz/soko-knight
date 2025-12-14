#version 330

in vec2 fragTexCoord;
in vec4 fragColor;
out vec4 finalColor;

uniform sampler2D texture0;
uniform vec4 colDiffuse;
uniform vec2 renderSize;

uniform float time;

// -- CONFIG --
const float curvature = 6.0;
const float vignetteOpacity = 0.3;
const float abberationOffset = 0.001;
const float brightnessMultiplier = 1.5;

// INTERFERENCE
const float rollSpeed = 2.0;
const float rollsize = 8.0;
const float rollOpacity = 0.01;

// --- BLEEDING ---
const float bleedDist = 1.0;
const float bleedStrength = 0.3;

// --- BLOOM ---
const float bloomSpread = 0.1;
const float bloomIntensity = 3.0;
const float bloomThreshold = 0.2;

// --- NOISE ---
const float noiseIntensity = 0.05; // Adjust this (0.0 to 1.0)

vec2 curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    vec2 offset = uv.yx / curvature;
    uv = uv + uv * offset * offset;
    uv = uv * 0.5 + 0.5;
    return uv;
}

// Helper to calculate luminance (brightness)
float getLuma(vec3 c) {
    return dot(c, vec3(0.299, 0.587, 0.114));
}

// Pseudo-random generator
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    vec2 uv = fragTexCoord;
    vec2 curvedUV = curve(uv);

    // Border Clean up
    vec2 edgeSmoothness = vec2(0.02);
    vec2 border = smoothstep(vec2(0.0), edgeSmoothness, curvedUV) * smoothstep(vec2(1.0), vec2(1.0) - edgeSmoothness, curvedUV);
    float borderMask = border.x * border.y;

    // --- Chromatic Aberration & Bleeding ---
    float oneX = 1.0 / renderSize.x;
    float oneY = 1.0 / renderSize.y; 

    float sL = -bleedDist * oneX;
    float sR = bleedDist * oneX;

    float wC = 1.0;
    float wS = bleedStrength; 
    float totalW = wC + wS + wS;

    vec3 color;

    // RED Channel
    float r_c = texture(texture0, vec2(curvedUV.x + abberationOffset,      curvedUV.y)).r;
    float r_l = texture(texture0, vec2(curvedUV.x + abberationOffset + sL, curvedUV.y)).r;
    float r_r = texture(texture0, vec2(curvedUV.x + abberationOffset + sR, curvedUV.y)).r;
    color.r = (r_c * wC + r_l * wS + r_r * wS) / totalW;

    // GREEN Channel
    float g_c = texture(texture0, vec2(curvedUV.x,      curvedUV.y)).g;
    float g_l = texture(texture0, vec2(curvedUV.x + sL, curvedUV.y)).g;
    float g_r = texture(texture0, vec2(curvedUV.x + sR, curvedUV.y)).g;
    color.g = (g_c * wC + g_l * wS + g_r * wS) / totalW;

    // BLUE Channel
    float b_c = texture(texture0, vec2(curvedUV.x - abberationOffset,      curvedUV.y)).b;
    float b_l = texture(texture0, vec2(curvedUV.x - abberationOffset + sL, curvedUV.y)).b;
    float b_r = texture(texture0, vec2(curvedUV.x - abberationOffset + sR, curvedUV.y)).b;
    color.b = (b_c * wC + b_l * wS + b_r * wS) / totalW;

    // --- BLOOM CALCULATION ---
    vec3 blur = vec3(0.0);
    float samples = 0.0;

    for(float i = -2.0; i <= 2.0; i++) {
        for(float j = -2.0; j <= 2.0; j++) {
            vec2 offset = vec2(i * oneX, j * oneY) * bloomSpread;
            vec3 sCol = texture(texture0, curvedUV + offset).rgb;
            float luma = getLuma(sCol);
            float thresh = max(0.0, luma - bloomThreshold); 
            blur += sCol * thresh;
            samples += 1.0;
        }
    }

    blur /= samples; 
    color += blur * bloomIntensity; 

    // --- Rolling Interference Bar ---
    float roll = sin(curvedUV.y * rollsize + time * rollSpeed);
    color -= roll * rollOpacity; 

    // Aperture Grille
    float grille = 0.85 + 0.15 * sin(gl_FragCoord.x * 3.14159 * 0.8);
    color *= grille;

    // Scanlines
    float scanlineCount = renderSize.y; 
    float s = sin(curvedUV.y * scanlineCount * 3.14159 * 2.0); 
    float flicker = sin(time * 10.0) * 0.02; 
    float scanLineWeight = (s * 0.5 + 0.5) * (0.5 + flicker) + 0.5;
    color *= scanLineWeight;

    // --- NOISE ADDITION ---
    // Generate noise based on UV and Time to create animated static
    float noise = random(curvedUV + mod(time, 10.0));
    
    // Mix it into the color (simulates analog signal noise)
    color = mix(color, vec3(noise), noiseIntensity);

    // Vignette
    float vig = (0.0 + 1.0 * 16.0 * curvedUV.x * curvedUV.y * (1.0 - curvedUV.x) * (1.0 - curvedUV.y));
    color *= vec3(pow(vig, vignetteOpacity));

    color *= brightnessMultiplier;
    color *= borderMask;

    finalColor = vec4(color, 1.0);
}
