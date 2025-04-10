unit OpenMPMatrix;

interface

uses
  System.SysUtils;

const
  DLLPATH = '../../openmp_matrix_delphi.dll';

procedure MMSeqGustavson(A, B, C: PDouble; M, K, N: Integer); cdecl; external DLLPATH name 'mm_seq_gustavson';
procedure MMParGustavson(A, B, C: PDouble; M, K, N, T: Integer); cdecl; external DLLPATH name 'mm_par_gustavson';
procedure MMSeqStrassen(A, B, C: PDouble; M, K, N: Integer); cdecl; external DLLPATH name 'mm_seq_strassen';
procedure MMParStrassen(A, B, C: PDouble; M, K, N, T: Integer); cdecl; external DLLPATH name 'mm_par_strassen';

implementation

end.

