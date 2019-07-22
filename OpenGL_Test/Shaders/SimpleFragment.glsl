//varying lowp vec4 frag_Color;
//varying highp vec2 frag_TexCoord;
//
//void main(void) {
//    if(frag_TexCoord.x < 0.95 && frag_TexCoord.x > 0.05 && frag_TexCoord.y < 0.95 && frag_TexCoord.y > 0.05){
//        gl_FragColor = frag_Color;
//    } else {
//        gl_FragColor = vec4(0.0,0.0,0.0,1.0);
//    }
//}

precision highp float;
precision highp int;

uniform float time;
uniform float speed;

uniform sampler2D u_Texture;
uniform vec2 strength;
varying vec2 vUv;

// From https://stackoverflow.com/a/36176935/743464
vec2 sineWave( vec2 p ) {
    // wave distortion
    float x = sin( 25.0 * p.y + 30.0 * p.x + time * speed) * (0.1 * strength.x);
    float y = sin( -25.0 * p.y + 30.0 * p.x + time * speed) * (0.1 * strength.y);
    return vec2(p.x+x, p.y+y);
}

void main(void) {
    
    vec3 color = texture2D( u_Texture, sineWave(vUv) ).rgb;
    gl_FragColor = vec4( color, 1.0 );
    
}
