# DelphiMatrixBenchmark - HPC Matrix Multiplication Test Suite

[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2011-blue)](https://www.microsoft.com/en-us/windows/windows-11)
[![Delphi](https://img.shields.io/badge/RAD%20Studio-Delphi%2012.1-red)](https://www.embarcadero.com/products/delphi)

`DelphiMatrixBenchmark` is the core reproducibility and benchmarking suite for the HPC-Delphi academic project. It provides a robust framework to execute, validate, and measure the performance of multiple matrix multiplication implementations, orchestrating native Delphi routines alongside high-performance C libraries (SIMD, OpenMP, and MPI).

## Features

- **Algorithm Orchestration**: Centralizes the execution of diverse matrix multiplication strategies, including naive sequential, Strassen, SIMD (AVX/SSE2) vectorized, OpenMP multi-threaded, and MSMPI distributed approaches.
- **Automated Validation**: Includes a dedicated validation engine (`Benchmark/Validator.pas`) to guarantee mathematical correctness across all implementations before measuring performance.
- **Performance Metrics**: Accurately measures execution times and computational throughput to generate comparative performance datasets.
- **Extensible Factory Architecture**: Utilizes a Factory pattern (`Matrix/Factory.pas`) to easily integrate new algorithms or third-party wrappers.

## Explicit Requirements & Dependencies

To compile and execute this benchmark suite, your environment must strictly satisfy all dependencies listed below. They are divided into proprietary modules developed specifically for this research, and external third-party software.

### 1. Development Environment
- **IDE**: RAD Studio (Delphi 12.1 Community Edition or higher).
- **Target OS**: Windows 11 (64-bit architecture is mandatory for large matrix memory allocation).

### 2. Internal HPC-Delphi Dependencies (Core Modules)
These are the specialized C libraries developed as part of this suite. For each of these modules, you must compile their respective GitHub repositories to obtain the `.dll` binaries, and you must include their interface folders in Delphi's `Search Path`.

| Library Module | HPC Purpose | Required Binary | Interface Wrapper (.pas) |
| :--- | :--- | :--- | :--- |
| **`offc_delphi`** | Core C matrix algorithms (Sequential, OpenMP, Strassen) | `offc_delphi.dll` | `OffC.pas` |
| **`vector_simd_delphi`** | Hardware-accelerated Intel SIMD vector operations | `vector_simd_delphi.dll` | `VectorSIMD.pas` |
| **`mpi_delphi`** | MSMPI bindings for distributed-memory computing | `mpi_delphi.dll` | `MPI.pas` |

### 3. External / Third-Party Dependencies
This suite integrates external software to validate and compare performance against industry standards.

- **Microsoft MPI (MSMPI)**: Required for the distributed algorithms.
  - *Runtime*: MSMPI must be installed on the host operating system to execute the benchmark.
  - *SDK*: (v10.1+) The headers and libraries are required during the C-side compilation of `mpi_delphi`.
- **[Insert Other Third-Party Libraries Here]**: *e.g., Intel MKL, OpenBLAS, or any other proprietary math DLLs you are integrating. Specify their DLL names and wrapper requirements here once reviewed.*

## Project Structure

```text
DelphiMatrixBenchmark/
│
├── Benchmark/              # Core benchmarking logic
│   ├── Config.pas          # Suite configuration and parameters
│   ├── Result.pas          # Data structures for metrics
│   ├── Runner.pas          # Execution controller
│   └── Validator.pas       # Mathematical correctness checks
├── Matrix/                 # Implementations and interfaces
│   ├── Factory.pas         # Multiplier instantiation
│   ├── DelphiStrassen.pas  # Native Strassen implementation
│   ├── FastMath.pas        # Low-level mathematical routines
│   └── ...                 # Additional algorithm units
├── Form.pas / Form.dfm     # Graphical User Interface
├── DelphiMatrixBenchmark.dpr # Main project file
├── CITATION.cff            # Academic citation metadata
└── README.md               # Project documentation
```

## Setup & Compilation Instructions

To guarantee a reproducible environment and avoid polluting the global Windows `PATH`, follow these strict configuration steps:

### Step 1: Interface Integration (Search Path)
Open `DelphiMatrixBenchmark.dproj` in RAD Studio. Navigate to **Project > Options > Delphi Compiler > Search path**.
You must add the absolute or relative paths pointing to the directories containing the `.pas` interfaces for ALL dependencies (both internal and third-party). 
*Example: `..\offc_delphi\wrappers\`*

### Step 2: Local DLL Deployment
Do **not** install the external DLLs system-wide. 
1. Compile the internal HPC-Delphi libraries from their source repositories.
2. Gather all required third-party math DLLs.
3. Copy all these `.dll` files directly into the compiler's output directory where the `DelphiMatrixBenchmark.exe` is generated. Depending on your build configuration, this is typically:
   - `Win64\Debug\`
   - `Win64\Release\`

### Step 3: Compilation
Build the project strictly for the **64-bit Windows** platform. Executing in 32-bit mode will result in out-of-memory exceptions when handling matrices larger than 2048x2048.

## Running the Benchmark

1. Execute `DelphiMatrixBenchmark.exe`.
2. Configure the matrix dimensions (N x N) and the block sizes for the recursive algorithms using the UI.
3. Select the specific implementations you wish to compare.
4. Run the suite. The application automatically validates the correctness of the results against a standard sequential baseline before logging the execution times for your dataset.

## Academic Citation

If you use this benchmarking suite or the associated data in your research, please cite it using the metadata provided in the `CITATION.cff` file located in the root of this repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.