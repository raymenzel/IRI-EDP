program main
use, intrinsic :: iso_c_binding, only: c_float, c_int
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

options(:) = 1
do i = 1, size(off_switch_indices)
  options(off_switch_indices(i)) = 0
enddo
coordinate_system = 1
year = 2000
date = 0101
hour = 0.
height_lower = 80.
height_upper = 600.
dheight = 10.
latitude_north = 35.7
longitude_east = 284.6
call iri_main(options, coordinate_system, &
              latitude_north, longitude_east, &
              year, date, hour, height_lower, &
              height_upper, dheight, output, &
              additional_output)
end program main
