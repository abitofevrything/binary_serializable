import 'built_in/bool_benchmark.dart' as bool_benchmark;
import 'built_in/buffer_benchmark.dart' as buffer_benchmark;
import 'built_in/int_benchmark.dart' as int_benchmark;
import 'built_in/float_benchmark.dart' as float_benchmark;
import 'built_in/string_benchmark.dart' as string_benchmark;
import 'composite_benchmark.dart' as composite_benchmark;

void main() {
  bool_benchmark.main();
  buffer_benchmark.main();
  int_benchmark.main();
  float_benchmark.main();
  string_benchmark.main();
  composite_benchmark.main();
}
