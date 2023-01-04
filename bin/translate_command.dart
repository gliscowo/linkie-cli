import 'dart:async';
import 'dart:math';

import 'package:args/src/arg_results.dart';
import 'package:console/console.dart';

import 'io.dart';
import 'linkie.dart';
import 'types.dart';

class TranslateCommand extends QueryCommand {
  TranslateCommand()
      : super("translate", "Translate a name from one mapping set to another",
            requiredArgCount: 3, argsDescription: "<query> <namespace> <target namespace>");

  @override
  FutureOr<void> execute(ArgResults args) async {
    final query = args.rest[0];
    final namespaceString = args.rest[1];
    final translateString = args.rest[2];

    final namespace = parseEnum(Namespace.values, namespaceString, "namespace", Namespace.parse);
    final translate = parseEnum(Namespace.values, translateString, "namespace", Namespace.parse);

    var responses = await search(query, namespace, parameters.version,
        translateTo: translate,
        allowClasses: parameters.classes,
        allowFields: parameters.fields,
        allowMethods: parameters.methods);

    int length = responses.isNotEmpty
        ? responses
            .map((e) => max(e.result.length, e.translated!.length))
            .reduce((value, element) => max(value, element))
        : 0;

    logger.info("${Color.BLUE}${responses.length} ${ansiReset}results\n");

    for (var response in responses) {
      response.printToConsole(namespace.name, length, translatedNamespace: translate.name);
    }
  }
}
