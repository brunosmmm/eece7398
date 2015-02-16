
#include <stdio.h>
#include <math.h>

struct Pixel {
  double x;
  double y;
};

double getPixelDistance_c(struct Pixel *pixels)
{

  double dist_x = pixels[1].x - pixels[0].x;
  double dist_y = pixels[1].y - pixels[0].y;
  return sqrt(dist_x*dist_x + dist_y*dist_y);
}

double getPixelDistance(struct Pixel *pixels);


int main(void)
{

  struct Pixel two_pixels[2];

  two_pixels[0].x = 1.0;
  two_pixels[0].y = 2.5;
  two_pixels[1].x = 4.0;
  two_pixels[1].y = 3.0;

  double r_c = getPixelDistance_c(two_pixels);
  double r_ll = getPixelDistance(two_pixels);

  printf("C : %f\n", r_c);
  printf("LLVM : %f\n", r_ll);

  return 0;
}
