#version 150

#moj_import <fog.glsl>

#define BORDER_RADIUS 2.0
#define CURSOR_SIZE 2.5

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;
uniform vec2 ScreenSize;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

in float isMap;
in float isShadow;
in float radius;
in vec2 MinimapSize;
flat in int guiScale;

out vec4 fragColor;

bool circle(float radius){
    return distance(gl_FragCoord.xy, ScreenSize - MinimapSize) > radius && isMap == 1.0;
}

bool triangle(in vec2 pixelCoord, vec2 basePos){
    vec2 gap = pixelCoord - basePos;
    return abs(gap.x * CURSOR_SIZE) < -gap.y + CURSOR_SIZE * guiScale && pixelCoord.y > basePos.y - CURSOR_SIZE * guiScale;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) discard;
    if (isShadow == 1.0) discard;

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

    if (circle(radius - BORDER_RADIUS * guiScale)) fragColor = vec4(0.3, 0.3, 0.3, 1.0);
    if (circle(radius)) discard;

    ///TODO: Remplacer par une custom font
    if(triangle(gl_FragCoord.xy, ScreenSize - MinimapSize)) fragColor = vec4(1.0, 1.0, 0.0, 1.0);

}
