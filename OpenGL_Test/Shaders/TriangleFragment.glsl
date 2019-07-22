varying lowp vec4 frag_Color;
varying highp vec2 frag_TexCoord;

void main(void) {
    if(frag_TexCoord.x >= 0.95 || (frag_TexCoord.y >= 0.95) || (frag_TexCoord.x + frag_TexCoord.y - 1.0 <= 0.05)){
        gl_FragColor = vec4(0.0,0.0,0.0,1.0);
    } else{
        gl_FragColor = frag_Color;
    }
}
