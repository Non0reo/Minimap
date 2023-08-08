#version 150

uniform sampler2D DiffuseSampler;
// uniform sampler2D DataSampler;
// uniform sampler2D FinalSampler;
// uniform sampler2D PrevSampler;

uniform float Time;
uniform vec2 InSize;

uniform float MinimapSize;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

void glowingShader() {
    vec4 center = texture(DiffuseSampler, texCoord);
    vec4 left = texture(DiffuseSampler, texCoord - vec2(oneTexel.x, 0.0));
    vec4 right = texture(DiffuseSampler, texCoord + vec2(oneTexel.x, 0.0));
    vec4 up = texture(DiffuseSampler, texCoord - vec2(0.0, oneTexel.y));
    vec4 down = texture(DiffuseSampler, texCoord + vec2(0.0, oneTexel.y));
    float leftDiff  = abs(center.a - left.a);
    float rightDiff = abs(center.a - right.a);
    float upDiff    = abs(center.a - up.a);
    float downDiff  = abs(center.a - down.a);
    float total = clamp(leftDiff + rightDiff + upDiff + downDiff, 0.0, 1.0);
    vec3 outColor = center.rgb * center.a + left.rgb * left.a + right.rgb * right.a + up.rgb * up.a + down.rgb * down.a;
    fragColor = vec4(outColor * 0.2, total);
}

void circle() {
    vec2 center = vec2(0.5, 0.5);
    float radius = 0.5;
    float dist = distance(center, texCoord);
    if(dist < radius) fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}

void main(){
    
    glowingShader();
    circle();
    // vec4 texture = texture(DiffuseSampler, texCoord);
    //if(texture.r > 0.5) discard;

    // vec4 t = texture(FinalSampler, texCoord);
    //if(finalTexture.r > 0.5) fragColor = vec4(1.0, 0.0, 0.0, 1.0);

    //fragColor = texture(DiffuseSampler, texCoord);


}
