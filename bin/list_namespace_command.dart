import 'dart:async';

import 'package:args/src/arg_results.dart';
import 'package:console/console.dart';

import 'linkie.dart';
import 'types.dart';

class ListNamespacesCommand extends LinkieCommand {
  ListNamespacesCommand() : super("list-namespaces", "List the namespaces known to this version of linkie");

  @override
  FutureOr<void> execute(ArgResults args) {
    final namespaces = Namespace.values;
    logger.info("${namespaces.length} known namespaces\n");

    print(TextPen().blue().text("name".padRight(16)).text("api".padRight(16)).text("abbreviation").normal());

    for (var namespace in namespaces) {
      print("${namespace.name.padRight(16)}${namespace.apiName.padRight(16)}${namespace.abbr ?? ""}");
    }
  }
}
