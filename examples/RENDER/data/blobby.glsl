#define PROCESSING_COLOR_SHADER

#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;

#define N 16

void main( void ) {
	vec2 v=(gl_FragCoord.xy-(resolution*0.5))/min(resolution.y,resolution.x)*10.0;
	float t=time *0.3,r=2.0;
	for (int i=1;i<N;i++){
		float d=(3.14159265 / float(N))*(float(i)*14.0);
		r+=length(vec2(v.y,v.x))+1.21;
		v = vec2(v.x+cos(v.y+cos(r)+d)+cos(t),v.y-sin(v.x+cos(r)+d)+sin(t));
	}
        r = (sin(r*0.007)*0.5)+0.5;
	r = pow(r, 20.0);
	r += pow(max(r-0.35,0.0)*4.0,3.0);
	r += pow(max(r-4.875,0.1)*2.0,6.0);
	r /= 3;
	gl_FragColor = vec4(r, r, r, 1.0 );
}
