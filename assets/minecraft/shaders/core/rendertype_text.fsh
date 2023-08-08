#version 150

#moj_import <fog.glsl>

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
in vec2 MinimapPos;

out vec4 fragColor;

bool dist(vec2 a, vec2 b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2)) < 40;
}

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) discard;
    if (isShadow == 1.0) discard;

    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);

    if (distance(gl_FragCoord.xy, ScreenSize - MinimapSize) > radius && isMap == 1.0) {
        discard;
        //fragColor = vec4( 0.996078431372549 ,  0.00392156862745098 ,  0.49411764705882355 , 1.0);
    }

    /* if (distance(gl_FragCoord.xy, MinimapPos) < radius && isMap == 1.0) {
        //discard;
        fragColor = vec4( 0.996078431372549 ,  0.00392156862745098 ,  0.49411764705882355 , 1.0);
    } */

    //if(gl_FragCoord.x == MinimapPosOut.x) fragColor = vec4(0.83, 0.0, 1.0, 1.0);



    //fragColor = (gl_FragCoord.x, gl_FragCoord.y, 0.0, 1.0);

    
}
