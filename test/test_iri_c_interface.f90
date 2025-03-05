program test
use, intrinsic :: iso_c_binding, only: c_float, c_int
use, intrinsic :: iso_fortran_env, only: error_unit
use iri_c_interface
implicit none

integer(kind=c_int), dimension(50) :: options
integer(kind=c_int) :: coordinate_system
real(kind=c_float) :: latitude_north ![Degrees].
real(kind=c_float) :: longitude_east ![Degrees].
integer(kind=c_int) :: year !Year in format YYYY.
integer(kind=c_int) :: date !Date in format MMDD.
real(kind=c_float) :: hour !Hour
real(kind=c_float) :: height_lower !Lowest height [km].
real(kind=c_float) :: height_upper !Highest height [km].
real(kind=c_float) :: dheight !Height grid spacing [km].
real(kind=c_float), dimension(20000) :: output
real(kind=c_float), dimension(100) :: additional_output

integer :: i
integer, dimension(13), parameter :: off_switch_indices = &
  [4, 5, 6, 21, 23, 28, 29, 30, 33, 35, 39, 40, 47]

!Test data at: 2019/ 301/12.0UT  geog Lat/Long/Alt= 37.8/ 284.6/  80.0 */
integer, parameter :: test_num_altitudes = 53
real(kind=c_float), dimension(53), parameter :: test_altitude  = [ & ![km]
   80.0,   90.0,  100.0,  110.0,  120.0, &
  130.0,  140.0,  150.0,  160.0,  170.0, &
  180.0,  190.0,  200.0,  210.0,  220.0, &
  230.0,  240.0,  250.0,  260.0,  270.0, &
  280.0,  290.0,  300.0,  310.0,  320.0, &
  330.0,  340.0,  350.0,  360.0,  370.0, &
  380.0,  390.0,  400.0,  410.0,  420.0, &
  430.0,  440.0,  450.0,  460.0,  470.0, &
  480.0,  490.0,  500.0,  510.0,  520.0, &
  530.0,  540.0,  550.0,  560.0,  570.0, &
  580.0,  590.0,  600.0 &
]
integer(kind=c_int), dimension(53), parameter :: test_electron_density = [ & ![cm-3]
    350,    4290,    28903,   33598,   27700, &
  29683,    36024,   42439,   51444,   68039, &
  89466,   109099,  124708,  135113,  140368, &
  141587,  140199,  136790,  131806,  125688, &
  118837,  111592,  104224,   96939,   89886, &
   83162,   76828,   70917,   65437,   60385, &
   55744,   51494,   47608,   44061,   40825, &
   37874,   35182,   32727,   30485,   28437, &
   26564,   24850,   23279,   21838,   20515, &
   19298,   18177,   17144,   16190,   15308, &
   14492,   13736,   13034 &
]
integer(kind=c_int) :: electron_density

options(:) = 1
do i = 1, size(off_switch_indices)
  options(off_switch_indices(i)) = 0
enddo
coordinate_system = 0
year = 2019
date = 0301
hour = 12 + 25
height_lower = test_altitude(1)
height_upper = test_altitude(53)
dheight = test_altitude(2) - test_altitude(1)
latitude_north = 37.8
longitude_east = -75.4
call iri_main(options, coordinate_system, &
              latitude_north, longitude_east, &
              year, date, hour, height_lower, &
              height_upper, dheight, output, &
              additional_output)

do i = 1, test_num_altitudes
  electron_density = int(output((i - 1)*20 + 1)*1.e-6 + .5)
  if (electron_density .ne. test_electron_density(i)) then
    write(error_unit, *) "Error: Bad electron density: ", electron_density, &
                         " != ", test_electron_density(i), " at ", &
                         test_altitude(i)
    stop 1
  endif
enddo

end program test
