import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:console/console.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

import 'search_command.dart';
import 'translate_command.dart';
import 'types.dart';

bool showIntermediary = false;
bool showUnmapped = false;
int maxResults = 100;

bool useHttps = true;
String host = "linkieapi.shedaniel.me";

const encoder = JsonEncoder.withIndent("    ");
const versionNumber = "0.1.2";
final client = Client();

final logger = Logger("linkie");

typedef JsonObject = Map<String, dynamic>;

Future<void> main(List<String> args) async {
  Console.init();

  Logger.root.onRecord.listen((event) {
    final color = levelToColor(event.level);
    TextPen()
        .setColor(color)
        .text(event.level.name.toLowerCase())
        .white()
        .text(": ")
        .normal()
        .text(event.message)
        .print();
  });

  final runner = CommandRunner("linkie", "yes it links the things");

  runner.argParser.addFlag("intermediary",
      abbr: "i", help: "Show intermediary names", negatable: false, callback: (value) => showIntermediary = value);
  runner.argParser.addFlag("unmapped",
      abbr: "u", help: "Show unmapped names", negatable: false, callback: (value) => showUnmapped = value);
  runner.argParser.addOption("max", abbr: "m", help: "How many results to show", defaultsTo: "100", callback: (value) {
    int? max = int.tryParse(value!);
    if (max == null || max < 0) {
      logger.severe("malformed max result count '$value'");
      exit(0);
    }

    maxResults = max;
  });
  runner.argParser.addOption("host", help: "Target a different API instance than https://linkieapi.shedaniel.me",
      callback: (value) {
    if (value != null) {
      final uri = Uri.tryParse(value);
      if (uri == null) {
        logger.severe("malformed API host '$value'");
        exit(0);
      }

      if (uri.authority.isEmpty) {
        logger.severe("malformed API host '$value'");
        exit(0);
      }

      useHttps = uri.scheme == "https";
      host = uri.authority;
    }

    logger.info("linkie cli v$versionNumber");
    logger.info("targeting ${Color.BLUE}${useHttps ? "https://" : "http://"}$host\n");
  });

  runner.addCommand(TranslateCommand());
  runner.addCommand(SearchCommand());
  await runner.run(args);

  client.close();
}

// namespace=yarn&query=method_34741&version=1.19&limit=50&allowClasses=true&allowFields=true&allowMethods=true&translate=quilt-mappings
Future<Iterable<SearchResponse>> search(String query, Namespace namespace, String? version,
    {bool allowClasses = true, bool allowMethods = true, bool allowFields = true, Namespace? translateTo}) {
  return client
      .get(
          (useHttps ? Uri.https : Uri.http)(host, "/api/search", {
            "namespace": namespace.apiName,
            "query": query,
            if (version != null) "version": version,
            "limit": maxResults.toString(),
            "allowClasses": allowClasses.toString(),
            "allowMethods": allowMethods.toString(),
            "allowFields": allowFields.toString(),
            if (translateTo != null) "translate": translateTo.apiName
          }),
          // make sure the API can identify us, as rate limits may be different
          headers: {HttpHeaders.userAgentHeader: "linkie-cli / $versionNumber"})
      .then((value) => jsonDecode(value.body))
      .then((value) => (value["entries"] ?? []) as List<dynamic>)
      .then((value) => [for (var response in value) SearchResponse(response)]);
}

Color levelToColor(Level level) {
  if (level.value > 900) {
    return Color.RED;
  } else if (level.value > 800) {
    return Color.YELLOW;
  } else if (level.value < 700) {
    return Color.LIGHT_GRAY;
  } else {
    return Color.WHITE;
  }
}

abstract class LinkieCommand extends Command<void> {
  @override
  final String name, description;

  final int _requiredArgCount;
  final String _argsDescription;

  LinkieCommand(this.name, this.description, {requiredArgCount = 0, String? argsDescription})
      : _requiredArgCount = requiredArgCount,
        _argsDescription = argsDescription ?? "";

  @override
  Future<void> run() async {
    var args = argResults!;
    if (args.rest.length < _requiredArgCount) {
      printUsage();
      return;
    } else {
      return await execute(args);
    }
  }

  @override
  String get invocation => super.invocation.replaceAll("[arguments]", _argsDescription);

  FutureOr<void> execute(ArgResults args);
}

abstract class QueryCommand extends LinkieCommand {
  QueryCommand(super.name, super.description, {super.requiredArgCount, super.argsDescription}) {
    argParser.addFlag("classes", abbr: "c", negatable: false, help: "Include classes");
    argParser.addFlag("fields", abbr: "f", negatable: false, help: "Include fields");
    argParser.addFlag("methods", abbr: "m", negatable: false, help: "Include methods");
    argParser.addOption("game-version", abbr: "v", help: "The game version for which to query mappings");
  }

  QueryParameters get parameters {
    var args = argResults!;

    var classes = args.wasParsed("classes");
    var fields = args.wasParsed("fields");
    var methods = args.wasParsed("methods");
    var version = args["game-version"] as String?;

    if (!(classes || fields || methods)) return QueryParameters(true, true, true, version);
    return QueryParameters(classes, fields, methods, version);
  }
}

class QueryParameters {
  final bool classes, fields, methods;
  final String? version;
  QueryParameters(this.classes, this.fields, this.methods, this.version);
}
