#version 150

uniform sampler2D DiffuseSampler;

in vec2 texCoord;
in vec2 oneTexel;

uniform vec2 InSize;

out vec4 fragColor;

#define checkGridSpacing 0.01

void main() {

    bool found = false;
    fragColor = vec4(0.0,0.0,0.0,0.0);
    if (texCoord.x > 0.99 && texCoord.y > 0.99) {
        for(float i = 0.0; i <= 1.0; i += checkGridSpacing) {
            for(float j = 0.0; j <= 1.0; j += checkGridSpacing) {
                if(texture(DiffuseSampler, vec2(i, j)).rgb != vec3(0.0, 0.0, 0.0)) {
                    fragColor = texture(DiffuseSampler, vec2(i, j));
                    found = true;
                    break;
                }
            }
            if(found) break;
        }
    }
    
}