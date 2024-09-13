import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:binary_serializable/binary_serializable.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class FieldInformation {
  final String name;
  final String binaryType;
  final String type;
  final bool isInPrelude;

  FieldInformation({
    required this.name,
    required this.binaryType,
    required this.type,
    required this.isInPrelude,
  });
}

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
    final binarySerializableElement =
        binarySerializableLibrary.exportNamespace.get('BinarySerializable');
    if (binaryTypeElement is! InterfaceElement) {
      throw Exception('Unable to locate BinaryType');
    }
    if (binarySerializableElement is! InterfaceElement) {
      throw Exception('Unable to locate BinarySerializable');
    }
    final binaryTypeChecker =
        TypeChecker.fromStatic(binaryTypeElement.thisType);
    final binarySerializableChecker =
        TypeChecker.fromStatic(binarySerializableElement.thisType);

    final (clazz, constructor) = switch (element) {
      ConstructorElement() => (element.enclosingElement3, element),
      ClassElement() => (
          element,
          element.constructors.singleWhere(
            (constructor) => constructor.name == '',
            orElse: () => throw Exception('No default constructor found'),
          )
        ),
      _ => throw Exception('Invalid target ${element.kind.displayName}'),
    };

    InterfaceElement? findSerializableSuperclass(InterfaceElement element) {
      bool isSerializable(Element element) {
        return binarySerializableChecker.firstAnnotationOf(element) != null ||
            (element is InterfaceElement &&
                element.constructors.any(isSerializable));
      }

      final supertype = element.supertype?.element;
      if (supertype != null) {
        if (isSerializable(supertype)) {
          return supertype;
        }

        if (findSerializableSuperclass(supertype)
            case final serializableSupertype?) {
          return serializableSupertype;
        }
      }

      InterfaceElement? serializableInterface;
      for (final interfaceType in element.interfaces) {
        final interface = interfaceType.element;
        if (isSerializable(element)) {
          if (serializableInterface != null) {
            throw Exception(
                'Cannot generate serialization code for classes with multiple serializable interfaces.');
          }
          serializableInterface = interface;
        } else if (findSerializableSuperclass(interface)
            case final serializableSupertype?) {
          if (serializableInterface != null) {
            throw Exception(
                'Cannot generate serialization code for classes with multiple serializable interfaces.');
          }
          serializableInterface = serializableSupertype;
        }
      }

      return serializableInterface;
    }

    List<FieldInformation> getFieldInformation(InterfaceElement element) {
      final result = <FieldInformation>[];

      if (findSerializableSuperclass(element) case final supertype?) {
        result.addAll(getFieldInformation(supertype));
      }

      for (var child in element.children.toList()
        ..sort((e1, e2) => e1.nameOffset.compareTo(e2.nameOffset))) {
        final DartType fieldType;
        if (child is FieldElement) {
          fieldType = child.type;
        } else if (child case PropertyAccessorElement(isGetter: true)) {
          fieldType = child.returnType;
        } else {
          continue;
        }

        ElementAnnotation? binaryTypeAnnotation;
        bool foundDefiniteAnnotation = false;
        for (final annotation in child.metadata) {
          final value = annotation.computeConstantValue();
          final type = value?.type;
          if (value == null || type == null) continue;

          if (annotation.constantEvaluationErrors?.isNotEmpty == true) {
            // For potentially ungenerated types.
            binaryTypeAnnotation ??= annotation;
          } else if (binaryTypeChecker.isAssignableFromType(type)) {
            if (binaryTypeAnnotation != null && foundDefiniteAnnotation) {
              throw Exception('Duplicate type definition (${child.name})');
            }

            final asBinaryType = type.asInstanceOf(binaryTypeElement)!;
            if (!asBinaryType.typeArguments.single
                .isStructurallyEqualTo(fieldType)) {
              throw Exception('Mismatched binary type (${child.name})');
            }

            binaryTypeAnnotation = annotation;
            foundDefiniteAnnotation = true;
          }
        }

        if (result.where((field) => field.name == child.name).firstOrNull !=
            null) {
          if (binaryTypeAnnotation != null) {
            throw Exception(
                'Cannot declare the binary type of an inherited serializable field');
          }
          continue;
        }

        if (binaryTypeAnnotation == null) {
          continue;
        }

        var binaryType = binaryTypeAnnotation.toSource().substring(1);
        if (binaryTypeAnnotation.element?.kind == ElementKind.CONSTRUCTOR) {
          binaryType = 'const $binaryType';
        }

        result.add(FieldInformation(
          name: child.name!,
          binaryType: binaryType,
          type: fieldType.toString(),
          isInPrelude: child is PropertyAccessorElement && child.isAbstract,
        ));
      }

      return result;
    }

    final fields = getFieldInformation(clazz);

    if (fields.isEmpty) {
      throw Exception('No fields found');
    }

    final firstAscii =
        clazz.name.split('').indexWhere((c) => RegExp('[a-zA-Z]').hasMatch(c));
    final camelCasedName = clazz.name.substring(0, firstAscii) +
        clazz.name[firstAscii].toLowerCase() +
        clazz.name.substring(firstAscii + 1);

    String generateConversion(
      String className,
      String targetType,
      String startConversionBody,
      List<FieldInformation> fields,
    ) {
      final currentConversion =
          fields.any((field) => field.name == 'currentConversion')
              ? 'this.currentConversion'
              : 'currentConversion';

      for (final field in fields.reversed) {
        final conversionTarget =
            field == fields.first ? 'return' : '$currentConversion =';

        startConversionBody = '''
  $conversionTarget ${field.binaryType}.startConversion((${field.name}) {
  $startConversionBody
  });
''';
      }

      return '''
class _${className}Conversion extends CompositeBinaryConversion<$targetType> {
  _${className}Conversion(super.onValue);
  
  @override
  BinaryConversion startConversion() {
    $startConversionBody
  }
}
''';
    }

    String generateConcreteType() {
      final serializedFields = <(ParameterElement, FieldInformation)>[];
      final fieldsIterator = fields.iterator;
      for (final parameter in constructor.parameters) {
        do {
          if (!fieldsIterator.moveNext()) {
            throw Exception(
                'Constructor fields out of order or not present in class');
          }
        } while (fieldsIterator.current.name != parameter.name);

        serializedFields.add((parameter, fieldsIterator.current));
      }

      final writeCommands = [
        for (final field in fields)
          'builder.add(${field.binaryType}.encode(input.${field.name}));',
      ];

      final constructorName = switch (constructor.name) {
        '' => clazz.name,
        final constructorName => '${clazz.name}.$constructorName',
      };

      final arguments = serializedFields.map((e) {
        final (parameter, field) = e;

        if (parameter.isNamed) {
          return '${parameter.name}: ${field.name}';
        }

        return field.name;
      });

      return '''
const ${camelCasedName}Type = ${clazz.name}Type();

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

${generateConversion(
        clazz.name,
        clazz.name,
        'onValue($constructorName(${arguments.join(', ')}));',
        fields,
      )}
''';
    }

    List<InterfaceElement> findDirectSerializableSubtypes(
        InterfaceElement element) {
      final result = <InterfaceElement>[];
      final namespaces = [
        clazz.library.publicNamespace,
        ...clazz.library.importedLibraries.map((e) => e.exportNamespace),
      ];
      for (final namespace in namespaces) {
        for (final declaration in namespace.definedNames.values) {
          if (declaration is! InterfaceElement) continue;

          if (declaration.supertype == element.thisType ||
              element.interfaces
                  .any((interface) => interface == element.thisType)) {
            if (binarySerializableChecker.firstAnnotationOf(declaration) !=
                null) {
              result.add(declaration);
            }
          }
        }
      }

      return result;
    }

    Future<String> generateAbstractType() async {
      final preludeTypes =
          fields.where((f) => f.isInPrelude).map((f) => f.type);

      final preludeType =
          '(${preludeTypes.join(', ')}${preludeTypes.length == 1 ? ',' : ''})';

      final preludeFields =
          fields.where((f) => f.isInPrelude).map((f) => f.name);

      final instancePreludeLiteral =
          '(${preludeFields.map((f) => 'instance.$f').join(',')}${preludeFields.length == 1 ? ',' : ''})';

      final preludeLiteral =
          '(${preludeFields.join(',')}${preludeFields.length == 1 ? ',' : ''})';

      if (preludeTypes.isEmpty) {
        throw Exception('No prelude in abstract class');
      }

      final subtypes = findDirectSerializableSubtypes(clazz);
      if (subtypes.isEmpty) {
        print(
            'No subtypes found; import files containing subtypes annotated with @BinarySerializable() to support converting them.');
      }

      final subtypeEntries = [];
      subtypeLoop:
      while (subtypes.isNotEmpty) {
        final subtype = subtypes.removeLast();

        final fieldValues = [];
        for (final preludeField in preludeFields) {
          final getter =
              subtype.thisType.lookUpGetter2(preludeField, clazz.library);
          if (getter == null) {
            print(
                'Unable to generate subtype prelude for ${subtype.name} (getter $preludeField not found)');
            continue subtypeLoop;
          }
          final node = await buildStep.resolver.astNodeFor(getter);
          if (node is! MethodDeclaration) {
            print(
                'Unable to generate subtype prelude for ${subtype.name} (node $preludeField not found)');
            continue subtypeLoop;
          }
          final body = node.body;
          if (body is! ExpressionFunctionBody) {
            if (subtype is ClassElement && subtype.isAbstract) {
              final subSubtypes = findDirectSerializableSubtypes(
                  subtype.declaration as InterfaceElement);
              if (subSubtypes.isNotEmpty) {
                subtypes.addAll(subSubtypes);
                continue subtypeLoop;
              }
            }

            print(
                'Unable to generate subtype prelude for ${subtype.name} (expression $preludeField not found)');
            continue subtypeLoop;
          }
          fieldValues.add(body.expression.toSource());
        }

        final preludeValue =
            '(${fieldValues.join(', ')}${fieldValues.length == 1 ? ',' : ''})';

        final firstAscii = subtype.name
            .split('')
            .indexWhere((c) => RegExp('[a-zA-Z]').hasMatch(c));
        final camelCasedName = subtype.name.substring(0, firstAscii) +
            subtype.name[firstAscii].toLowerCase() +
            subtype.name.substring(firstAscii + 1);

        subtypeEntries.add('$preludeValue: ${camelCasedName}Type');
      }

      return '''
const ${camelCasedName}Type = ${clazz.name}Type();

class ${clazz.name}Type extends MultiBinaryType<${clazz.name}, $preludeType> {
  const ${clazz.name}Type() : super(const {${subtypeEntries.join(',')}});

  @override
  $preludeType extractPrelude(${clazz.name} instance) => $instancePreludeLiteral;

  @override
  BinaryConversion<$preludeType> startPreludeConversion(void Function($preludeType) onValue) => _${clazz.name}PreludeConversion(onValue);
}

${generateConversion(
        '${clazz.name}Prelude',
        preludeType,
        'onValue($preludeLiteral);',
        fields,
      )}
''';
    }

    final ignoreInvalidLint =
        '// ignore_for_file: missing_override_of_must_be_overridden, duplicate_ignore\n\n';

    if (clazz is ClassElement && clazz.isAbstract) {
      return ignoreInvalidLint + await generateAbstractType();
    } else {
      return ignoreInvalidLint + generateConcreteType();
    }
  }
}
