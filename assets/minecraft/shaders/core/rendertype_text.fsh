#version 150

#moj_import <fog.glsl>

#define BORDER_RADIUS 2.0

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

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) discard;
    if (isShadow == 1.0) discard;

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

    if (circle(radius - BORDER_RADIUS * guiScale)) fragColor = vec4(0.3, 0.3, 0.3, 1.0);
    if (circle(radius)) discard;
}
