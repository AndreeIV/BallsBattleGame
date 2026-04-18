shader_type canvas_item;

// Control de brillo: 1.0 es normal, 0.0 es negro, 2.0 es el doble de luz
uniform float brillo : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    float dist = distance(UV, vec2(0.5, 0.5));
    
    if (dist > 0.5) {
        discard; 
    } else {
        vec4 tex_color = texture(TEXTURE, UV);
        
        // Multiplicamos los colores por el valor de brillo
        vec3 color_final = tex_color.rgb * brillo;
        
        // El clamp asegura que no "explote" el brillo hacia el neón 
        // a menos que tú subas el valor de brillo por encima de 1.0
        COLOR = vec4(color_final, tex_color.a);
    }
}