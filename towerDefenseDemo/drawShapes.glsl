#ifdef GL_ES
precision mediump float;
#endif
uniform vec2 u_mouse;
uniform vec4 lines[50]; //unifrom
uniform float thick[50]; //uniform
uniform vec2 enemies[924]; 

vec4 red = vec4(1.0,0.0,0.0,1.0);
vec4 black = vec4(0.004,0.004,0.004,1.0);
vec4 result;

vec2 project(vec2 A, vec2 B, vec2 C){
    vec2 L = B-A;
    float K = dot(C-A,L);
    K/= dot(L,L);
    return A+L*K;
}
vec2 constrain (vec2 amt, vec2 low, vec2 high){
    return min(max(amt,min(low,high)),max(low,high));
}

bool closerThan(float len, vec2 A, vec2 B){
  vec2 del = A-B;
  del*=del;
  len*=len;
  return del.x+del.y < len;
}

bool line (vec4 lin, float thickness){
    vec2 start = vec2(lin.xy);
    vec2 end = vec2(lin.zw);
    vec2 D = constrain(project(start,end,gl_FragCoord.xy),start,end);
    if ( closerThan ( thickness,gl_FragCoord.xy,D) ) { 
        return true; 
    }
    return false;
}

void main() {
	result = black;
    for (int i = 0; i<50; i++){
    	if (line(lines[i],thick[i])){
        	result =red;
    	}
    }

 
 	for (int i = 0; i<924; i++){
    	if (closerThan(2.,enemies[i].xy ,  gl_FragCoord.xy)) result = red;
    }
	gl_FragColor = result;
}
