unit MMImplementations;

interface

uses
  MatrixUtils, MMGustavson, MMStrassen;

type
  TMMImplementation = record
    Name: string;
    Proc: TMM;
  end;

const
  AvailableImpl: array [0 .. 8] of TMMImplementation =
    ((Name: '[Native Delphi]     Gustavson (Sequential)';
    Proc: SeqGustavsonNativeDelphi),
    (Name: '[NativeDelphi]      Strassen  (Sequential)';
    Proc: SeqStrassenNativeDelphi),
    (Name: '[System.Threading]  Gustavson (Parallel)';
    Proc: ParGustavsonSystemThreading),
    (Name: '[SystemThreading]   Strassen  (Parallel)';
    Proc: ParStrassenSystemThreading),
    (Name: '[OmniThreadLibrary] Gustavson (Parallel)';
    Proc: ParGustavsonOmniThreadLibrary),
    (Name: '[OpenMPMatrix]      Gustavson (Sequential)';
    Proc: SeqGustavsonOpenMPMatrix),
    (Name: '[OpenMPMatrix]      Gustavson (Parallel)';
    Proc: ParGustavsonOpenMPMatrix),
    (Name: '[OpenMPMatrix]      Strassen  (Sequential)';
    Proc: SeqStrassenOpenMPMatrix),
    (Name: '[OpenMPMatrix]      Strassen  (Parallel)';
    Proc: ParStrassenOpenMPMatrix));

implementation
end.
