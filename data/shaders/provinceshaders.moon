export *

shader_province_f  = [[
  vec4 draw_border(Image image, vec2 screen_cords) {
    vec4 pix = Texel(image, screen_cords);

    return pix;
  }

  vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_cords)
  {
    return draw_border(image, screen_cords);
  }
]]