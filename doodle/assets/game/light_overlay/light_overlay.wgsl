
struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) world_position: vec4<f32>,
    @location(1) world_normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
};

struct LightConfig {
    pos: vec4<f32>,
    size: f32,
};
@group(1) @binding(0)
var<uniform> light_config: LightConfig;

fn circle(st: vec2<f32>, center: vec2<f32>, radius: f32) -> f32{
    let dist = st-center;
    let smoothness = 1.5;
	return smoothstep(radius-(radius*smoothness),
                         radius+(radius*smoothness),
                         dot(dist,dist)*4.0);
}
@fragment
fn fragment(in: VertexOutput) -> @location(0) vec4<f32> {
    var color = vec4<f32>(0.0,0.0,0.0, 0.99);
    var light_position_2d = vec2<f32>(light_config.pos.xyz.x, light_config.pos.xyz.y);
    color = color * (circle(in.world_position.xy, light_position_2d, light_config.size*1000.) );

    return color;
}