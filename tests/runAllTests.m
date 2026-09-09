function results = runAllTests()
%RUNALLTESTS  Run the full test suite and print a summary.
thisDir = fileparts(mfilename('fullpath'));
suite = matlab.unittest.TestSuite.fromFolder(thisDir);
runner = matlab.unittest.TestRunner.withTextOutput();
results = runner.run(suite);
fprintf('\n%d passed, %d failed, %d incomplete (of %d total)\n', nnz([results.Passed]), nnz([results.Failed]), nnz([results.Incomplete]), numel(results));
end
