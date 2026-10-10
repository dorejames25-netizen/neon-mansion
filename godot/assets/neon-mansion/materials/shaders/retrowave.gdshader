shader_type spatial;
render_mode unshaded, cull_disabled;
uniform vec4 stone_color : source_color = vec4(0.32,0.20,0.43,1.0);
uniform bool floor_surface = false;
uniform bool tiled_wall = false;
uniform sampler2D reference_art : source_color, filter_linear_mipmap;
uniform sampler2D style_art : source_color, filter_linear_mipmap;
uniform vec4 painted_wall_rect = vec4(0.07,0.30,0.08,0.09);
uniform float painted_strength : hint_range(0.0,1.0) = 0.22;
uniform sampler2D projection_mask : hint_default_white, filter_linear;
uniform mat4 reference_view;
uniform mat4 reference_projection;
uniform float artwork_blend : hint_range(0.0,1.0) = 0.0;
uniform float grid_speed = 0.070;
uniform float grid_opacity = 0.96;
varying vec3 world_pos;
varying vec3 world_normal;
float hash(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
float noise(vec2 p){vec2 i=floor(p),f=fract(p);f=f*f*(3.0-2.0*f);return mix(mix(hash(i),hash(i+vec2(1,0)),f.x),mix(hash(i+vec2(0,1)),hash(i+vec2(1,1)),f.x),f.y);}
void vertex(){world_pos=(MODEL_MATRIX*vec4(VERTEX,1)).xyz;world_normal=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 vec3 n=abs(world_normal);
 vec2 p=floor_surface?world_pos.xz:(n.x>n.z?world_pos.zy:world_pos.xy);
 vec2 grid=p*(floor_surface?vec2(0.72):(tiled_wall?vec2(4.0,8.0):vec2(1.1,2.1)));
 if(!floor_surface && !tiled_wall){grid.x+=mod(floor(grid.y),2.0)*0.5;}
 vec2 cell=fract(grid);
 float edge=min(min(cell.x,1.0-cell.x),min(cell.y,1.0-cell.y));
 float aa=max(fwidth(edge),0.001);
 float mortar=smoothstep(0.010-aa,0.024+aa,edge);
 float id=hash(floor(grid));
 vec2 patch=abs(fract(p*0.08)*2.0-1.0);
 vec3 painted=texture(style_art,painted_wall_rect.xy+patch*painted_wall_rect.zw).rgb;
 float luma=dot(painted,vec3(0.2126,0.7152,0.0722));
 float wear=clamp(luma/0.075,0.65,1.3);
 vec3 base=stone_color.rgb*(0.86+id*0.18);
 base*=mix(1.0,wear,painted_strength);
 // Authored face-value bands establish form before any lighting is installed.
 float facing=floor_surface?1.0:mix(0.72,0.94,step(n.x,n.z));
 facing*=floor_surface?1.0:mix(1.0,0.72,smoothstep(0.45,0.8,n.y));
 float distress=step(0.94,noise(p*12.0))*0.14;
 base*=facing*(1.0-distress);
 if(tiled_wall){base=stone_color.rgb*(0.96+id*0.06)*facing;}
 if(floor_surface){
   base=vec3(0.065,0.024,0.105)*(0.94+noise(p*2.0)*0.06);
   ALBEDO=base;
 }else{
   ALBEDO=tiled_wall?mix(vec3(0.035,0.018,0.055),base,mortar):base;
 }
 // Slow surface-space travel, subtle enough to preserve the inked architecture.
 // Vertical walls and horizontal floors only; the barrel vault stays panelled.
 float wall_mask=1.0-smoothstep(0.10,0.35,n.y);
 float grid_mask=floor_surface?1.0:(tiled_wall?wall_mask:0.0);
 vec2 moving=p*0.72+vec2(0.0,TIME*grid_speed);
 vec2 distance_to_line=abs(fract(moving+0.5)-0.5);
 vec2 width=max(fwidth(moving),vec2(0.001));
 vec2 lines=1.0-smoothstep(vec2(0.011),vec2(0.011)+width,distance_to_line);
 float grid_line=max(lines.x,lines.y);
 vec3 grid_color=mix(vec3(0.95,0.015,0.80),vec3(0.015,0.90,1.0),0.5+0.5*sin(p.y*0.35+TIME*0.15));
 ALBEDO=mix(ALBEDO,grid_color,grid_line*grid_opacity*grid_mask);
 // Fine printed halftone, filtered away at distance to avoid shimmer.
 vec2 dots=p*30.0;
 float dot_ink=1.0-smoothstep(0.12,0.24,length(fract(dots)-0.5));
 float dot_visibility=1.0-smoothstep(0.35,0.8,max(fwidth(dots.x),fwidth(dots.y)));
 ALBEDO*=1.0-dot_ink*dot_visibility*0.10;
 vec4 projected=reference_projection*reference_view*vec4(world_pos,1);
 vec2 art_uv=projected.xy/max(projected.w,0.001)*0.5+0.5;art_uv.y=1.0-art_uv.y;
 float inside=step(0.0,art_uv.x)*step(art_uv.x,1.0)*step(0.0,art_uv.y)*step(art_uv.y,1.0)*step(0.001,projected.w);
 ALBEDO=mix(ALBEDO,texture(reference_art,art_uv).rgb,artwork_blend*texture(projection_mask,art_uv).r*inside);
 ROUGHNESS=1.0;METALLIC=0.0;SPECULAR=0.0;
}
