"											\n\
#ifdef GL_ES								\n\
precision lowp float;						\n\
#endif										\n\
\n\
varying vec4 v_fragmentTint;				\n\
varying vec4 v_fragmentColor;				\n\
varying vec2 v_texCoord;					\n\
\n\
uniform sampler2D CC_Texture0;				\n\
\n\
void main()									\n\
{											\n\
//Assumes incoming texture color DOES NOT use premultiplied alpha											\n\
\n\
//mix the texture color with our tint color (shades as opaque paint)									\n\
vec4 color = vec4(mix(texture2D(CC_Texture0, v_texCoord).rgb, v_fragmentTint.rgb, v_fragmentTint.a), texture2D(CC_Texture0, v_texCoord).a);		\n\
\n\
gl_FragColor = color * v_fragmentColor;										\n\
}																										\n\
";