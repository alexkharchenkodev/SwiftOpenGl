//precision highp float;
//
//uniform sampler2D u_Texture;
//uniform sampler2D u_Mask;
//uniform lowp int u_Mode;
//
//uniform float time;
//uniform float speed;
//
//varying lowp vec4 frag_Color;
//varying lowp vec2 frag_TexCoord;
//
//void main(void) {
//    highp vec4 maskColor = texture2D(u_Mask, frag_TexCoord);
//    highp vec4 texColor = texture2D(u_Texture, frag_TexCoord);
//
//    if(u_Mode == 1){
//        if(maskColor.r == 1.0 && maskColor.g == 0.0 && maskColor.b == 0.0){
//            gl_FragColor = vec4(texColor.r, texColor.g, texColor.b, texColor.a);
//        } else{
//            gl_FragColor = vec4(1.0,1.0,1.0,1.0);
//        }
//    } else {
//        gl_FragColor = vec4(texColor.r, texColor.g, texColor.b, texColor.a);
//    }
//
//    if(maskColor.r == 0.0 && maskColor.g == 0.0 && maskColor.b == 0.0){
//        gl_FragColor = vec4(0.0,0.0,0.0,1.0);
//    }
//}
precision highp float;
precision highp int;

uniform float time;
uniform float speed;

uniform sampler2D image;
uniform vec2 strength;
varying vec2 vUv;

#define BlendLinearDodgef               BlendAddf
#define BlendLinearBurnf                BlendSubstractf
#define BlendAddf(base, blend)          min(base + blend, 1.0)
#define BlendSubstractf(base, blend)    max(base + blend - 1.0, 0.0)
#define BlendLightenf(base, blend)      max(blend, base)
#define BlendDarkenf(base, blend)       min(blend, base)
#define BlendLinearLightf(base, blend)  (blend < 0.5 ? BlendLinearBurnf(base, (2.0 * blend)) : BlendLinearDodgef(base, (2.0 * (blend - 0.5))))
#define BlendScreenf(base, blend)       (1.0 - ((1.0 - base) * (1.0 - blend)))
#define BlendOverlayf(base, blend)      (base < 0.5 ? (2.0 * base * blend) : (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)))
#define BlendSoftLightf(base, blend)    ((blend < 0.5) ? (2.0 * base * blend + base * base * (1.0 - 2.0 * blend)) : (sqrt(base) * (2.0 * blend - 1.0) + 2.0 * base * (1.0 - blend)))
#define BlendColorDodgef(base, blend)   ((blend == 1.0) ? blend : min(base / (1.0 - blend), 1.0))
#define BlendColorBurnf(base, blend)    ((blend == 0.0) ? blend : max((1.0 - ((1.0 - base) / blend)), 0.0))
#define BlendVividLightf(base, blend)   ((blend < 0.5) ? BlendColorBurnf(base, (2.0 * blend)) : BlendColorDodgef(base, (2.0 * (blend - 0.5))))
#define BlendPinLightf(base, blend)     ((blend < 0.5) ? BlendDarkenf(base, (2.0 * blend)) : BlendLightenf(base, (2.0 *(blend - 0.5))))
#define BlendHardMixf(base, blend)      ((BlendVividLightf(base, blend) < 0.5) ? 0.0 : 1.0)
#define BlendReflectf(base, blend)      ((blend == 1.0) ? blend : min(base * base / (1.0 - blend), 1.0))

// Component wise blending
#define Blend(base, blend, funcf)       vec3(funcf(base.r, blend.r), funcf(base.g, blend.g), funcf(base.b, blend.b))

#define BlendNormal(base, blend)        (blend)
#define BlendLighten                    BlendLightenf
#define BlendDarken                     BlendDarkenf
#define BlendMultiply(base, blend)      (base * blend)
#define BlendAverage(base, blend)       ((base + blend) / 2.0)
#define BlendAdd(base, blend)           min(base + blend, vec3(1.0))
#define BlendSubstract(base, blend)     max(base + blend - vec3(1.0), vec3(0.0))
#define BlendDifference(base, blend)    abs(base - blend)
#define BlendNegation(base, blend)      (vec3(1.0) - abs(vec3(1.0) - base - blend))
#define BlendExclusion(base, blend)     (base + blend - 2.0 * base * blend)
#define BlendScreen(base, blend)        Blend(base, blend, BlendScreenf)
#define BlendOverlay(base, blend)       Blend(base, blend, BlendOverlayf)
#define BlendSoftLight(base, blend)     Blend(base, blend, BlendSoftLightf)
#define BlendHardLight(base, blend)     BlendOverlay(blend, base)
#define BlendColorDodge(base, blend)    Blend(base, blend, BlendColorDodgef)
#define BlendColorBurn(base, blend)     Blend(base, blend, BlendColorBurnf)
#define BlendLinearDodge                BlendAdd
#define BlendLinearBurn                 BlendSubstract

#define BlendLinearLight(base, blend)   Blend(base, blend, BlendLinearLightf)
#define BlendVividLight(base, blend)    Blend(base, blend, BlendVividLightf)
#define BlendPinLight(base, blend)      Blend(base, blend, BlendPinLightf)
#define BlendHardMix(base, blend)       Blend(base, blend, BlendHardMixf)
#define BlendReflect(base, blend)       Blend(base, blend, BlendReflectf)
#define BlendGlow(base, blend)          BlendReflect(blend, base)
#define BlendPhoenix(base, blend)       (min(base, blend) - max(base, blend) + vec3(1.0))
#define BlendOpacity(base, blend, F, O) (F(base, blend) * O + blend * (1.0 - O))

// From https://stackoverflow.com/a/36176935/743464
vec2 sineWave( vec2 p ) {
    // wave distortion
    float x = p.x;//( p.x - time / speed * 0.8);//( 25.0 * p.y + 30.0 * p.x + time * speed) * (0.1 * strength.x);
    
    float y = sin( -25.0 * p.y + 30.0 * p.x + time * speed) * (0.1 * strength.y);
    
    return vec2(p.x + x, p.y);
}

vec2 sineWave2( vec2 p ) {
    // wave distortion
    float x = ( p.x - time / speed * 0.7);//( 25.0 * p.y + 30.0 * p.x + time * speed) * (0.1 * strength.x);
    
    float y = sin( -25.0 * p.y + 30.0 * p.x + time * speed) * (0.1 * strength.y);
    
    return vec2(p.x + x, p.y);
}

void main() {
    
    vec3 color = texture2D(image, sineWave(vUv)).rgb;
    vec3 color2 = texture2D( image, sineWave2(vUv) ).rgb;
    vec3 result = BlendOverlay(color, color2);
    
    
    gl_FragColor = vec4( result, 1.0 );
    
}
