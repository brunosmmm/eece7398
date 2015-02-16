
declare double @sqrt(double)

%pixel = type { double, double } ;struct Pixel

define double @getPixelDistance(%pixel* %pixels) {
entry:
       %t0 = getelementptr %pixel* %pixels, i32 0, i32 0 ;double* %t0: &(pixels[0].x)
       %t1 = load double* %t0 ;double %t1: pixels[0].x

       %t2 = getelementptr %pixel* %pixels, i32 1, i32 0 ;double* %t0: &(pixels[1].x)
       %t3 = load double* %t2 ;double %t3: pixels[1].x

       %t4 = fsub double %t3, %t1 ;double %t4: pixels[1].x - pixels[0].x = dist_x

       %t5 = getelementptr %pixel* %pixels, i32 0, i32 1 ;double* %t5: &(pixels[0].y)
       %t6 = load double* %t5 ;double %t6: pixels[0].y

       %t7 = getelementptr %pixel* %pixels, i32 1, i32 1 ;double* %t7: &(pixels[1].y)
       %t8 = load double* %t7 ;double %t8: pixels[1].y

       %t9 = fsub double %t8, %t6 ;double %t9: pixels[1].y - pixels[0].y = dist_y

       %t10 = fmul double %t4, %t4 ;double %t10: dist_x * dist_x
       %t11 = fmul double %t9, %t9 ;double %t11: dist_y * dist_y

       %t12 = fadd double %t10, %t11 ;double %t12: dist_x^2 + dist_y^2
       %t13 = call double @sqrt(double %t12) ;double %t13: sqrt(dist_x^2 + dist_y^2)
       ret double %t13
}