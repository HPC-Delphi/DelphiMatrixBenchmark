unit Factory;

interface

uses
  System.Generics.Collections, Multiplier, MultImpls;

type
  TFactory = class
  public
    class function GetAvailable: TArray<string>;
    class function CreateByName(const Name: string): IMultiplier;
  end;

implementation

class function TFactory.GetAvailable: TArray<string>;
begin
  Result := ['Base', 'OffC-Base', 'OptiVec-VectorLib', 'IntelSIMD', 'OffC-AVX2',
    'ASM', 'PPL', 'OTL', 'OffC-OMP', 'PPL+IntelSIMD', 'OffC-OMP+AVX2', 'ALGLIB',
    'LINALG', 'mrmath', 'OffC-MKL'
{$IFDEF MPI}
    , 'MPI+Base', 'MPI+PPL+IntelSIMD', 'MPI+OffC-OMP+AVX2', 'MPI+OffC-MKL'
{$ENDIF}
    ]
end;

class function TFactory.CreateByName(const Name: string): IMultiplier;
begin
  // Base
  if Name = 'Base' then
    Result := TBase.Create
  else if Name = 'OffC-Base' then
    Result := TOffCBase.Create
    // Vec
  else if Name = 'OptiVec-VectorLib' then
    Result := TOptiVecVectorLib.Create
  else if Name = 'IntelSIMD' then
    Result := TIntelSIMD.Create
  else if Name = 'OffC-AVX2' then
    Result := TOffCAVX2.Create
  else if Name = 'ASM' then
    Result := TASM.Create
    // Par
  else if Name = 'PPL' then
    Result := TPPL.Create
  else if Name = 'OTL' then
    Result := TOTL.Create
  else if Name = 'OffC-OMP' then
    Result := TOffCOMP.Create
    // Par+Vec
  else if Name = 'PPL+IntelSIMD' then
    Result := TPPLIntelSIMD.Create
  else if Name = 'OffC-OMP+AVX2' then
    Result := TOffCOMPAVX2.Create
    // Linear Algebra
  else if Name = 'ALGLIB' then
    Result := TALGLIB.Create
  else if Name = 'LINALG' then
    Result := TLinearAlgebra.Create
  else if Name = 'mrmath' then
    Result := Tmrmath.Create
  else if Name = 'OffC-MKL' then
    Result := TOffCMKL.Create
{$IFDEF MPI}
  else if Name = 'MPI+Base' then
    Result := TMPIBase.Create
  else if Name = 'MPI+PPL+IntelSIMD' then
    Result := TMPIPPLIntelSIMD.Create
  else if Name = 'MPI+OffC-OMP+AVX2' then
    Result := TMPIOffCOMPAVX2.Create
  else if Name = 'MPI+OffC-MKL' then
    Result := TMPIOffCMKL.Create
{$ENDIF}
  else
    Result := nil;
end;

end.
