shader_type canvas_item;

uniform vec2 offset = vec2(0.0, 0.0);
uniform vec2 scale = vec2(10.0, 17.77);

void vertex() {
	// Called for every vertex the material is visible on.
}

float rand2dTo1d(vec2 value, vec2 dotDir) {
	vec2 smallValue = sin(value);
	float random = dot(smallValue, dotDir);
	random = fract(sin(random) * 143758.5453);
	return random;
}

vec2 rand2dTo2d(vec2 value){
	return vec2(
		rand2dTo1d(value, vec2(12.989, 78.233)),
		rand2dTo1d(value, vec2(39.346, 11.135))
	);
}

vec2 voronoiNoise(vec2 value){
    vec2 baseCell = floor(value);

    float minDistToCell = 10.0;
	vec2 closest_cell;
    for(int x=-1; x<=1; x++){
        for(int y=-1; y<=1; y++){
            vec2 cell = baseCell + vec2(float(x), float(y));
            vec2 cellPosition = cell + rand2dTo2d(cell);
            vec2 toCell = cellPosition - value;
            float distToCell = length(toCell);
            if(distToCell < minDistToCell){
                minDistToCell = distToCell;
				closest_cell = cell;
            }
        }
    }
	float random = rand2dTo1d(closest_cell, vec2(12.989, 78.233));
    return vec2(minDistToCell, random);
}

void fragment() {
	float x = voronoiNoise(SCREEN_UV * scale + offset).y;
	COLOR.rgb = vec3(x, x, x);
	// Called for every pixel the material is visible on.
}
