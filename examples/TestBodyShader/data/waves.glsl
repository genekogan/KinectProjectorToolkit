#define PROCESSING_COLOR_SHADER

uniform float time;
uniform vec2 resolution;

void main( void ) {

	vec2 position = ( gl_FragCoord.xy / resolution.xy );

	float color = 0.0;
	color += sin( position.x * cos( time / 15.0 ) * 10.0 )  +  cos( position.y * cos( time / 15.0 ) * 10.0 );
	color += sin( position.y * sin( time / 10.0 ) * 20.0 )  +  cos( position.x * sin( time / 25.0 ) * 25.0 );
	color += sin( position.x * sin( time / 50.0 ) * 40.0 )  +  sin( position.y * sin( time / 35.0 ) * 50.0 );

	color *= sin( time / 10.0 ) * 0.5;

	float r = color;
	float g = color * 0.5;
	float b = 0.5 + sin( color + time / 3.0 ) * 0.5;
	
	gl_FragColor = vec4(r, g, b, 1.0 );

}