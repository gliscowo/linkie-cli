import 'dart:async';
import 'dart:math';

import 'package:args/src/arg_results.dart';
import 'package:console/console.dart';

import 'io.dart';
import 'linkie.dart';
import 'types.dart';

class SearchCommand extends QueryCommand {
  SearchCommand()
      : super("search", "Look up a name in one mapping set",
            requiredArgCount: 2, argsDescription: "<query> <namespace>");

  @override
  FutureOr<void> execute(ArgResults args) async {
    final query = args.rest[0];
    final namespaceString = args.rest[1];

    final namespace = parseEnum(Namespace.values, namespaceString, "namespace");

    final filters = this.filters;
    final responses = await search(query, namespace, "1.19",
        allowClasses: filters.classes, allowFields: filters.fields, allowMethods: filters.methods);

    logger.info("${Color.BLUE}${responses.length} ${ansiReset}results\n");

    int length = responses.isNotEmpty
        ? responses.map((e) => e.result.length).reduce((value, element) => max(value, element))
        : 0;

    for (var response in responses) {
      response.printToConsole(namespaceString, length);
    }
  }
}
