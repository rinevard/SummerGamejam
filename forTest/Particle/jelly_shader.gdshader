shader_type canvas_item;

void fragment() {
    vec2 uv = UV;
    vec2 center = vec2(0.5, 0.5);
    float dist = distance(uv, center);
    
    // 创建一个简单的圆形渐变
    float alpha = smoothstep(0.5, 0.3, dist);
    
    // 添加一些波动效果
    float wave = sin(uv.x * 10.0 + TIME * 2.0) * 0.05;
    uv.y += wave;
    
    // 使用纹理颜色,但调整透明度
    COLOR = texture(TEXTURE, uv);
    COLOR.a *= alpha * 0.7;
}