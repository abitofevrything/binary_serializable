import 'package:analyzer/dart/element/element.dart';
import 'package:binary_serializable/binary_serializable.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class BinarySerializableGenerator
    extends GeneratorForAnnotation<BinarySerializable> {
  @override
  Future<String> generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) async {
    final binarySerializableLibrary = await buildStep.resolver.libraryFor(
      AssetId('binary_serializable', 'lib/binary_serializable.dart'),
    );
    final binaryTypeElement =
        binarySerializableLibrary.exportNamespace.get('BinaryType');
    if (binaryTypeElement is! InterfaceElement) {
      throw Exception('Unable to locate BinaryType');
    }
    final binaryTypeChecker =
        TypeChecker.fromStatic(binaryTypeElement.thisType);

    final (clazz, constructor) = switch (element) {
      ConstructorElement() => (element.enclosingElement, element),
      ClassElement() => (
          element,
          element.constructors.singleWhere(
            (constructor) => constructor.name == '',
            orElse: () => throw Exception('No default constructor found'),
          )
        ),
      _ => throw Exception('Invalid target ${element.kind.displayName}'),
    };

    final fieldBinaryTypes = <String>[];
    final fieldNames = <String>[];
    final arguments = <String>[];

    for (final parameter in constructor.parameters) {
      if (parameter is! FieldFormalParameterElement) {
        throw Exception(
            'Parameters must be formal parameters (${parameter.name})');
      }

      FieldElement? field;
      InterfaceElement? scope = clazz;
      do {
        field = scope!.getField(parameter.name);
        scope = scope.supertype?.element;
      } while (field == null && scope != null);

      if (field == null) {
        throw Exception('Unable to find field ${parameter.name}');
      }

      ElementAnnotation? binaryTypeAnnotation;
      bool foundDefiniteAnnotation = false;
      for (final annotation in field.metadata) {
        final value = annotation.computeConstantValue();
        final type = value?.type;
        if (value == null || type == null) continue;

        if (annotation.constantEvaluationErrors?.isNotEmpty == true) {
          // For potentially ungenerated types.
          binaryTypeAnnotation ??= annotation;
        } else if (binaryTypeChecker.isAssignableFromType(type)) {
          if (binaryTypeAnnotation != null && foundDefiniteAnnotation) {
            throw Exception('Duplicate type definition (${field.name})');
          }

          final asBinaryType = type.asInstanceOf(binaryTypeElement)!;
          if (!asBinaryType.typeArguments.single
              .isStructurallyEqualTo(field.type)) {
            throw Exception('Mismatched binary type (${field.name})');
          }

          binaryTypeAnnotation = annotation;
          foundDefiniteAnnotation = true;
        }
      }

      if (binaryTypeAnnotation == null) {
        throw Exception('Missing binary type annotation (${field.name})');
      }

      var binaryType = binaryTypeAnnotation.toSource().substring(1);
      if (binaryTypeAnnotation.element?.kind == ElementKind.CONSTRUCTOR) {
        binaryType = 'const $binaryType';
      }

      fieldBinaryTypes.add(binaryType);
      fieldNames.add(parameter.name);
      arguments.add(
          parameter.isNamed ? '${parameter.name}: ${field.name}' : field.name);
    }

    if (fieldNames.isEmpty) {
      throw Exception('No fields found');
    }

    final writeCommands = [
      for (int i = 0; i < fieldNames.length; i++)
        'builder.add(${fieldBinaryTypes[i]}.encode(input.${fieldNames[i]}));',
    ];

    final constructorName = switch (constructor.name) {
      '' => clazz.name,
      final constructorName => '${clazz.name}.$constructorName',
    };

    final currentConversion = fieldNames.contains('currentConversion')
        ? 'this.currentConversion'
        : 'currentConversion';
    final initialConversion = fieldNames.contains('initialConversion')
        ? 'this.initialConversion'
        : 'initialConversion';

    var startConversionBody = '''
onValue($constructorName(${arguments.join(', ')}));
$currentConversion = $initialConversion;
''';

    for (int i = fieldNames.length - 1; i >= 0; i--) {
      final conversionTarget = i == 0 ? 'return' : '$currentConversion =';

      startConversionBody = '''
  $conversionTarget ${fieldBinaryTypes[i]}.startConversion((${fieldNames[i]}) {
  $startConversionBody
  });
''';
    }

    return '''
const ${clazz.name[0].toLowerCase() + clazz.name.substring(1)}Type = ${clazz.name}Type();

class ${clazz.name}Type extends BinaryType<${clazz.name}> {
  const ${clazz.name}Type();

  @override
  Uint8List encode(${clazz.name} input) {
    final builder = BytesBuilder(copy: false);
    ${writeCommands.join('\n    ')}
    return builder.takeBytes();
  }

  @override
  BinaryConversion<${clazz.name}> startConversion(void Function(${clazz.name}) onValue) =>
      _${clazz.name}Conversion(onValue);
}

class _${clazz.name}Conversion extends CompositeBinaryConversion<${clazz.name}> {
  _${clazz.name}Conversion(super.onValue);
  
  @override
  BinaryConversion startConversion() {
    $startConversionBody
  }
}
''';
  }
}
