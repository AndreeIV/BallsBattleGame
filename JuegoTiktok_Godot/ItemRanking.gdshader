shader_type canvas_item;

void fragment() {
    // 🎯 Calculamos la distancia desde el centro (0.5, 0.5)
    float dist = distance(UV, vec2(0.5));
    
    // ✂️ Recortamos todo lo que esté fuera del radio 0.5
    COLOR = texture(TEXTURE, UV);
    COLOR.a *= step(dist, 0.5);
}