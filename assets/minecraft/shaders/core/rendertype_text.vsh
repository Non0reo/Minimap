#version 150

#moj_import <fog.glsl>
#moj_import <matrix.glsl>

#define PI 3.141592653
#define SCALE 0.0
//#define RADIUS 100.0 //Uncomment line to set custom radius
#define MINIMAP_X 50.0 //offest from top right corner
#define MINIMAP_Y 50.0

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;
uniform sampler2D Sampler0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform float GameTime;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

out float isMap;
out float isShadow;
out float radius;
out vec2 MinimapSize;
flat out int guiScale;

vec2 ScrSize = ceil(2 / vec2(ProjMat[0][0], -ProjMat[1][1]));

//From McTsts
int getGuiScale(mat4 ProjMat, vec2 ScreenSize) {
    return int(round(ScreenSize.x * ProjMat[0][0] / 2));
}

void main() {
    float time = GameTime * 1000;
    float playerYaw = atan(IViewRotMat[0].z, IViewRotMat[0].x);

    guiScale = getGuiScale(ProjMat, ScreenSize);
    MinimapSize = vec2(MINIMAP_X, MINIMAP_Y) * guiScale;
    isMap = 0.0;
    isShadow = 0.0;
    
    ivec2 TexSize = ivec2(textureSize(Sampler0, 0));
    vec3 pos = Position;
    
    vec4 texture = texelFetch(Sampler2, UV2 / 16, 0);
    vec4 texture_origin = texelFetch(Sampler0, ivec2(TexSize.x - 1, 0), 0);
    if(texture_origin == vec4(1.0, 1.0, 0.0, 1.0)) isMap = 1.0; //Check if the texture is has a yellow marker (is a map)
    
    if(isMap == 1.0 && Position.z == 0.0) {
        isShadow = 1.0;
    } else if(isMap == 1.0){
        vec2 centerPos = ScrSize / 2.0; //Center of the screen

        //Scale Img
        pos.xy += (centerPos - pos.xy) * -SCALE;

        //Rotate Img
        pos.xy -= centerPos; //Translate the image to the origin
        pos.xy = mat2_rotate_z(playerYaw) * pos.xy + centerPos; // Rotate the image around 0,0 and set the image back to the center

        //Move Img
        vec2 MinimapCoord = vec2(ScrSize.x, 0) + vec2(-MinimapSize.x, MinimapSize.y) / guiScale;
        pos.xy += MinimapCoord - centerPos;
        //radius = min(abs(MinimapCoord.x), abs(MinimapCoord.y));
        radius = min(abs(MinimapSize.x), abs(MinimapSize.y));
        
        #ifdef RADIUS //Custom Radius
            radius = RADIUS;
        #endif

        vertexColor = texture;

    }
    else vertexColor = Color * texture;

    texCoord0 = UV0;
    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
}
