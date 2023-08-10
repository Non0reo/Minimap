#version 150

#moj_import <fog.glsl>
#moj_import <matrix.glsl>

#define PI 3.141592653
#define SCALE 50 //Also the size of the map divided by 2
//#define RADIUS 100.0 //Uncomment line to set custom radius
#define MINIMAP_X 50.0 //offest from top right corner
#define MINIMAP_Y 50.0
#define PRECISION 512

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
    int mapId = 0;
    int vertexId = gl_VertexID % 4;
    
    vec4 texture = texelFetch(Sampler2, UV2 / 16, 0);
    vec4 texture_origin = texelFetch(Sampler0, ivec2(TexSize.x - 1, 0), 0);
    if(texture_origin.a != 1.0 && texture_origin.a != 0.0) { //Check if the texture is has a yellow marker (is a map)
        isMap = 1.0;
        mapId = int(texture_origin.a * 256.0 - 250); //0: top left, 1: top right, 2: bottom left, 3: bottom right
    }
    
    //pos.z == 0.0 is the shadow
    //pos.z == 0.03 is the map

    vec2[4] dirVector = vec2[4](
        vec2(-1.0, 1.0),
        vec2(1.0, 1.0),
        vec2(1.0, -1.0),
        vec2(-1.0, -1.0)
    );

    vec4 tempColor = vec4(0.0);

    if(isMap == 1.0 && Position.z == 0.0) {
        isShadow = 1.0;
        vertexColor = texture;
    }
    if(isMap == 1.0 && Position.z == 0.03/* 0.035 */){
        vec2 centerPos = ScrSize / 2.0; //Center of the screen

        vec2 tempCoords = vec2(0.0);
        tempCoords = centerPos + dirVector[mapId] * SCALE * guiScale; //Dispatch the maps aound the center of the screen
        tempCoords += dirVector[vertexId] * SCALE * guiScale; //Dispatch the vertexes around the center of the map
        pos.xy = tempCoords;

        //pos.xy += vec2(512.0, 0) /* / 2.0 */;

        // vec3 color = Color.rgb;
        //r*2^16+g*2^8+b
        // Convertir les composantes de couleur en entiers normalisés (0-255)
        int r = int(Color.r * 255.0);
        int g = int(Color.g * 255.0);
        int b = int(Color.b * 255.0);

        // Empaqueter les composantes de couleur en un seul entier (format RGB sur 1 int)
        float rgbValue = (r << 16) | (g << 8) | b;

        vec2 worldPosition = vec2(mod((rgbValue / PRECISION), PRECISION), mod(rgbValue, PRECISION)) / (PRECISION/4) - 2.0; ///INFO: "/ 128 - 2.0" permet de restraindre la permet de restraindre la valeur entre -2 et 2 et la soustrait de 2 pour mettre le 0,0 en haut a gauche
        //worldPosition : x,z
        /*         
            ///INPORTANT : 
            La minimap se déplace dans l'intervale -2 et 2 sur les deux axes

            Exemples :
            //worldPosition = vec2(-2.0, -2.0); //Coin supérieur gauche
            //worldPosition = vec2(0.0, 0.0); //Centre
        */
        //tempColor = vec4(worldPosition, 0.0, 1.0);

        //Rotate Img
        pos.xy -= centerPos; //Translate the image to the origin
        pos.xy = mat2_rotate_z(playerYaw + radians(-90.0)) * pos.xy + mat2_rotate_z(playerYaw) * vec2(SCALE * -worldPosition.x, SCALE * -worldPosition.y) * guiScale + centerPos;
        // Rotate the image around 0,0 ; Add an offset from 0,0 thank to the color (player pos) ; and set the image back to the center

        //Move Img
        vec2 MinimapCoord = vec2(ScrSize.x, 0) + vec2(-MinimapSize.x, MinimapSize.y) / guiScale;
        pos.xy += MinimapCoord - centerPos;
        ///INFO: Activer la ligne du dessus pour positionner la minimap en haut a droite
        
        #ifdef RADIUS
            radius = RADIUS;
        #else
            //radius = min(abs(MinimapCoord.x), abs(MinimapCoord.y));
            radius = min(abs(MinimapSize.x), abs(MinimapSize.y));
        #endif
        vertexColor = (1,1,1,1) * texture;
    }
    else vertexColor = Color * texture;

    texCoord0 = UV0;
    vertexDistance = fog_distance(ModelViewMat, IViewRotMat * Position, FogShape);
    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1.0);
}
