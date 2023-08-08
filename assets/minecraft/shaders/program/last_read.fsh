#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;
in vec2 oneTexel;

out vec4 fragColor;

void main(){
    
    vec4 texture = texture(DiffuseSampler, texCoord);
    if(texture.r > 0.5) vec4(1.0, 0.0, 0.0, 1.0);

    fragColor = texture;
    
    fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
