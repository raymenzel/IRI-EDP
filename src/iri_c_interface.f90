module iri_c_interface
use, intrinsic :: iso_c_binding, only: c_float, c_int
implicit none


contains


!Wrapper for IRI to ensure the correct types are passed between c and fortran.
subroutine iri_main(options, coordinate_system, &
                    latitude_north, longitude_east, &
                    year, date, hour, height_lower, &
                    height_upper, dheight, output, &
                    additional_output) bind(c, name="iri_main")

  integer(kind=c_int), dimension(50), intent(in) :: options !IRI options.
  integer(kind=c_int), intent(in), value :: coordinate_system !IRI coordinate system.
  real(kind=c_float), intent(in), value :: latitude_north ![Degrees north].
  real(kind=c_float), intent(in), value :: longitude_east ![Degrees east].
  integer(kind=c_int), intent(in), value :: year !Year in format YYYY.
  integer(kind=c_int), intent(in), value :: date !Date in format MMDD.
  real(kind=c_float), intent(in), value :: hour !Hour in UTC.
  real(kind=c_float), intent(in), value :: height_lower !Lowest height [km].
  real(kind=c_float), intent(in), value :: height_upper !Highest height [km].
  real(kind=c_float), intent(in), value :: dheight !Height grid spacing [km].
  real(kind=c_float), dimension(20000), intent(inout) :: output !IRI output.
  real(kind=c_float), dimension(100), intent(inout) :: additional_output !Additional IRI output.

  integer :: i
  integer :: j
  logical, dimension(50) :: jf
  real, dimension(100) :: oarr
  real, dimension(20, 1000) :: outf

  ! Convert from integer to logical.
  do i = 1, 50
    jf(i) = options(i) .ne. 0
  enddo

  ! Read input files.
  call read_ig_rz()
  call readapf107()

  ! Call the fortran routine with the correct types and kinds.
  call iri_sub(jf, int(coordinate_system), &
               real(latitude_north), real(longitude_east), &
               int(year), int(date), real(hour), &
               real(height_lower), real(height_upper), &
               real(dheight), outf, oarr)

  !Flatten and convert the types of the output.
  do j = 1, 1000
    do i = 1, 20
      output((j - 1)*20 + i) = real(outf(i, j), kind=c_float)
    enddo
  enddo
  do i = 1, 100
    additional_output(i) = real(oarr(i), kind=c_float)
  enddo
end subroutine iri_main


end module iri_c_interface
