unit AVX;

interface

uses
  System.SysUtils;

const
  DLLPATH = '../../avx_delphi.dll';

function VLengthDouble:Integer; cdecl; external DLLPATH name 'vlength_double';
function VectorAdd(A, B, C: PDouble): Double; cdecl; external DLLPATH name 'vadd_double';
function VectorMul(A, B, C: PDouble): Double; cdecl; external DLLPATH name 'vmul_double';

implementation

end.
