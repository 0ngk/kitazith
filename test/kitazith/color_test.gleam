import kitazith/color

pub fn from_rgb_test() {
  assert color.from_rgb(red: 255, green: 0, blue: 0) == 0xFF0000
  assert color.from_rgb(red: 0, green: 255, blue: 0) == 0x00FF00
  assert color.from_rgb(red: 0, green: 0, blue: 255) == 0x0000FF
  assert color.from_rgb(red: 88, green: 101, blue: 242) == 5_793_266
  assert color.from_rgb(red: 0, green: 0, blue: 0) == 0
  assert color.from_rgb(red: 255, green: 255, blue: 255) == 0xFFFFFF
}
