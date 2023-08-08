#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;
in vec2 oneTexel;

uniform vec2 InSize;

out vec4 fragColor;

void main() {

    vec4 InTexel = texture(DiffuseSampler, texCoord);
    fragColor = InTexel;
    
}
