//attribute vec4 a_Position;
//attribute vec2 a_texCoord;
//
//uniform vec4 u_Color;
//uniform highp mat4 u_modelViewMatrix;
//uniform highp mat4 u_projectionMatrix;
//
//varying lowp vec4 frag_Color;
//varying highp vec2 frag_TexCoord;
//
//void main(void) {
//    frag_Color = u_Color;
//    frag_TexCoord = a_texCoord;
//    gl_Position = u_projectionMatrix * u_modelViewMatrix * a_Position;
//}

precision highp float;
precision highp int;

uniform mat4 u_modelViewMatrix;
uniform mat4 u_projectionMatrix;

varying vec2 vUv;

attribute vec3 position;
attribute vec2 uv;

void main() {
    
    vUv = uv;
    gl_Position = u_projectionMatrix * u_modelViewMatrix * vec4( position, 1.0 );
    
}
