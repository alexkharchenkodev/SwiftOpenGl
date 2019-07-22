//uniform variables have the same value among all procceeded vertices
//uniform highp mat4 u_modelViewMatrix;
//uniform highp mat4 u_projectionMatrix;
//
//attribute vec4 a_position;
//attribute vec4 a_color;
//attribute vec2 a_texCoord;
//
//varying lowp vec4 frag_Color;
//varying lowp vec2 frag_TexCoord;
//
//void main(){
//    gl_Position = u_projectionMatrix * u_modelViewMatrix * a_position;
//    frag_TexCoord = a_texCoord;
//    frag_Color = a_color;
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
