# DelphiMatrixBenchmark

DelphiMatrixBenchmark is a Delphi-based application designed to evaluate and compare the performance of matrix multiplication across various scenarios. The project includes a graphical user interface (GUI) that allows users to configure and execute benchmarks dynamically. This tool is particularly useful for analyzing the scalability and efficiency of different matrix multiplication algorithms, including parallelized implementations.

## Features

### 1. **Dynamic Configuration**
The GUI enables users to:
- Set the dimensions of the input matrices (A and B).
- Configure relevant parameters such as the number of threads and iterations.
This flexibility allows for the execution of diverse tests, making it possible to assess the scalability of the algorithms under varying workloads.

### 2. **Algorithm Selection**
The application supports multiple matrix multiplication algorithms, including:
- Native Delphi implementations.
- Optimized versions provided by an external DLL.
This feature facilitates a direct comparison of the performance of native implementations versus those enhanced with an external library.

### 3. **Performance Evaluation**
The application includes a variety of implementations to:
- Evaluate the benefits introduced by the C compiler.
- Assess the impact of parallelization using OpenMP.
The results are presented in a clear and concise manner, enabling users to analyze the performance metrics such as total execution time, average time, and scalability.

## How It Works

1. **Input Configuration**: Users specify the matrix dimensions and other parameters through the GUI.
2. **Algorithm Selection**: Users select one or more algorithms to benchmark.
3. **Benchmark Execution**: The application runs the selected algorithms and measures their performance.
4. **Results Visualization**: The results are displayed in both tabular and graphical formats, allowing for easy comparison.

## Use Cases

- **Academic Research**: Ideal for studying the performance of matrix multiplication algorithms in different environments.
- **Algorithm Comparison**: Facilitates a detailed comparison of native and parallelized implementations.

## Getting Started

### Prerequisites
- Delphi IDE (compatible with the project version).
- Windows operating system (64-bit).

### Installation
1. Clone the repository:
   ```bash
   git clone https://git.galdo.dev/daniel/DelphiMatrixBenchmark.git
   ```
2. Open the project in Delphi IDE.
3. Build and run the application.

### Usage
1. Launch the application.
2. Configure the matrix dimensions and parameters.
3. Select the algorithms to benchmark.
4. Click "Run Benchmark" to execute the tests.
5. View the results in the "Results" section.

## License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.