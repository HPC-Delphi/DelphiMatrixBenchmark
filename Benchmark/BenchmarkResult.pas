unit BenchmarkResult;

interface

type
  TBenchmarkResult = record
    Name: string;
    TotalTime: Double;
    AvgTime: Double;
    MinTime: Double;
    MaxTime: Double;
    IsValid: Boolean;
  end;

implementation

end.
