export *

shader_province_f = (provinces) ->
  print "Provinces:", provinces
  "

#define PROVINCES #{provinces}

struct Province {
  vec4 color;
  vec4 country;
};

extern Province provinceidxs[PROVINCES];
extern int provinces;

vec4 draw_border(Image image, vec2 screen_cords) {
  vec4 pix = Texel(image, screen_cords);

  for (int i = 0; i < provinces; i++) {
    Province cc = provinceidxs[i];
    if(cc.color == pix) {
      return cc.country;
    }
  }
  return vec4(0.0, 0.0, 0.0, 1.0);
}

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_cords)
{
  return draw_border(image, uvs);
}
  "