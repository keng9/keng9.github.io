#import bevy_sprite::mesh2d_view_bindings   globals
#import bevy_sprite::mesh2d_functions as mesh_functions
#import bevy_sprite::mesh2d_bindings       mesh
#import bevy_sprite::mesh2d_vertex_output  MeshVertexOutput
#import bevy_sprite::mesh2d_view_bindings  view

// custom MeshVerTexOutput
// source code from https://github.com/bevyengine/bevy/blob/10f5c9206847ae01b8dc833c2680562e7bd46664/crates/bevy_sprite/src/mesh2d/mesh2d.wgsl#L10


struct Vertex {
    @location(0) position: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) uv: vec2<f32>,
};

fn snap(x: f32, snap: f32) -> f32 {
    return snap * round(x / snap);
}
fn rand(co: vec2<f32>, time: f32) -> f32 {
    let snapped_time = snap(time, 0.2);
    return fract(sin(dot(co, vec2<f32>(12.9898, 78.233) + vec2<f32>(snapped_time, snapped_time))) * 43758.5453 );
}


@vertex
fn vertex(vertex: Vertex) -> MeshVertexOutput {
    var out: MeshVertexOutput;
    out.uv = vertex.uv;
    let time = globals.time;
    // Generate a pseudo-random displacement based on the 2D position and snapped time
    let noise_scale = 1.2;
    let displacement: vec3<f32> = vec3<f32>(
        rand(vertex.position.xy, time )* noise_scale,
        rand(vertex.position.yz, time) * noise_scale,
        rand(vertex.position.zx, time) * noise_scale,
    );

    let displaced_position: vec3<f32> = vertex.position + displacement;

    out.world_position = mesh_functions::mesh2d_position_local_to_world(
        mesh.model,
        vec4<f32>(displaced_position, 1.0)
    );
    out.position = mesh_functions::mesh2d_position_world_to_clip(out.world_position);

    out.world_normal = mesh_functions::mesh2d_normal_local_to_world(vertex.normal);

    return out;
}


@group(1) @binding(0)
var my_texture: texture_2d<f32>;
@group(1) @binding(1)
var my_sample: sampler;


fn random3(co: vec3<f32>) -> vec3<f32> {
  let magic: vec3<f32> = vec3<f32>(12.9898, 78.233, 37.719);
  return fract(sin(dot(co, magic)) * vec3<f32>(43758.5453, 22578.1459, 19642.34907));
}

@fragment
fn fragment(
    @builtin(front_facing) is_front: bool,
    in: MeshVertexOutput
) -> @location(0) vec4<f32> {
    // change fragment effect
    let noise_scale: vec2<f32> = vec2<f32>(0.01, 0.01);
    let noise: vec2<f32> = random3(vec3<f32>(in.uv, 0.0)).xy * noise_scale;

    let uv: vec2<f32> = in.uv + noise;
    let color: vec4<f32> = textureSample(my_texture, my_sample, uv);
    return color;
}
