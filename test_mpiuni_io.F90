program test_mpiuni_io
  use ESMF
  implicit none

  type(ESMF_ArraySpec) :: arraySpec3d
  type(ESMF_ArraySpec) :: arraySpec2d
  type(ESMF_Grid) :: grid
  type(ESMF_Mesh) :: mesh
  type(ESMF_Field) :: srcfield, dstfield
  type(ESMF_RouteHandle) :: routehandle
  integer :: rc

  character(len=*), parameter :: data_dir = "/opt/homebrew/opt/python@3.11/Frameworks/Python.framework/Versions/3.11/lib/python3.11/site-packages/esmpy/data/"
  character(len=*), parameter :: datafile = data_dir // "so_Omon_GISS-E2.nc"
  character(len=*), parameter :: meshfile = data_dir // "mpas_uniform_10242_dual_counterclockwise.nc"

  call ESMF_Initialize(logkindflag=ESMF_LOGKIND_MULTI, defaultCalkind=ESMF_CALKIND_GREGORIAN, rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  grid = ESMF_GridCreate(filename=datafile, rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  ! Note that there is a level dimension for this field, hence rank 3
  call ESMF_ArraySpecSet(arraySpec3d, typekind=ESMF_TYPEKIND_R8, rank=3, rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  srcfield = ESMF_FieldCreate(grid, arraySpec3d, staggerloc=ESMF_STAGGERLOC_CENTER, &
       name='so', ungriddedLBound=[1], ungriddedUBound=[33], rc=rc)

  call ESMF_FieldRead(srcfield, datafile, variableName='so', timeslice=2, rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  call ESMF_FieldWrite(srcfield, 'srcfield.nc', variableName='so', overwrite=.true., rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  mesh = ESMF_MeshCreate(meshfile, ESMF_FILEFORMAT_ESMFMESH, rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  ! This has 1 spatial dimension plus 1 level dimension
  call ESMF_ArraySpecSet(arraySpec2d, typekind=ESMF_TYPEKIND_R8, rank=2, rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)  
  dstfield = ESMF_FieldCreate(mesh, arraySpec2d, &
       name='so', ungriddedLBound=[1], ungriddedUBound=[33], rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  call ESMF_FieldRegridStore(srcfield, dstfield, &
       regridmethod=ESMF_REGRIDMETHOD_BILINEAR, unmappedaction=ESMF_UNMAPPEDACTION_IGNORE, &
       routehandle=routehandle, rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)
  call ESMF_FieldRegrid(srcfield, dstfield, routehandle, rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  call ESMF_FieldWrite(dstfield, 'dstfield.nc', variableName='so', overwrite=.true., rc=rc)
  if (ESMF_LogFoundError(rcToCheck=rc, msg=ESMF_LOGERR_PASSTHRU, &
       line=__LINE__, file=__FILE__)) call ESMF_Finalize(endflag=ESMF_END_ABORT)

  call ESMF_Finalize()

end program test_mpiuni_io
