// ignore_for_file: annotate_overrides

import 'dart:math';

import 'package:console/console.dart';
import 'package:json_annotation/json_annotation.dart';

import 'io.dart';
import 'linkie.dart';

part 'types.g.dart';

enum Namespace {
  yarn("yarn"),
  intermediary("intermediary"),
  plasma("plasma"),
  quilt("quilt-mappings"),
  mojang("mojang"),
  mcp("mcp");

  final String apiName;
  const Namespace(this.apiName);
}

abstract class SearchResultEntry {
  final String? obf, intermediary, named, memberType;
  SearchResultEntry(this.obf, this.intermediary, this.named, this.memberType);

  factory SearchResultEntry.parse(JsonObject json) {
    if (json.containsKey("a")) {
      return SearchResultMemberEntry.fromJson(json);
    } else {
      return SearchResultClassEntry.fromJson(json);
    }
  }

  String get formatted;
  String get formattedIntermediary;
  String get formattedUnmapped;

  int get length;
}

@JsonSerializable()
class SearchResultMemberEntry implements SearchResultEntry {
  @JsonKey(name: "a")
  final String? ownerObf;
  @JsonKey(name: "b")
  final String ownerIntermediary;
  @JsonKey(name: "c")
  final String? ownerNamed;
  @JsonKey(name: "o")
  final String? obf;
  @JsonKey(name: "i")
  final String intermediary;
  @JsonKey(name: "n")
  final String? named;
  @JsonKey(name: "d")
  final String? descObf;
  @JsonKey(name: "e")
  final String descIntermediary;
  @JsonKey(name: "f")
  final String? descNamed;
  @JsonKey(name: "z")
  final double score;
  @JsonKey(name: "t")
  final String memberType;

  SearchResultMemberEntry(this.ownerObf, this.ownerIntermediary, this.ownerNamed, this.obf, this.intermediary,
      this.named, this.descObf, this.descIntermediary, this.descNamed, this.score, this.memberType);

  factory SearchResultMemberEntry.fromJson(Map<String, dynamic> json) {
    print("Reading json: $json");
    return _$SearchResultMemberEntryFromJson(json);
  }

  String get formatted => "$ownerNamed.$named";
  String get formattedIntermediary => "$ownerIntermediary.$intermediary";
  String get formattedUnmapped => "$ownerObf.$obf";

  int get length => max(formatted.length, max(formattedIntermediary.length, formattedUnmapped.length));
}

@JsonSerializable()
class SearchResultClassEntry implements SearchResultEntry {
  @JsonKey(name: "o")
  final String? obf;
  @JsonKey(name: "i")
  final String intermediary;
  @JsonKey(name: "n")
  final String? named;
  @JsonKey(name: "z")
  final double score;
  @JsonKey(name: "t")
  final String memberType;

  SearchResultClassEntry(this.obf, this.intermediary, this.named, this.score, this.memberType);

  factory SearchResultClassEntry.fromJson(Map<String, dynamic> json) => _$SearchResultClassEntryFromJson(json);

  @override
  String get formatted => named ?? obf ?? "<unknown>";
  String get formattedIntermediary => intermediary;
  String get formattedUnmapped => obf ?? "<unknown>";

  int get length => max(formatted.length, max(formattedIntermediary.length, formattedUnmapped.length));
}

enum MappingType {
  clazz("C", 0x6419e6),
  method("M", 0x1fb2a6),
  field("F", 0xd926a9);

  final String prefix;
  final int color;
  const MappingType(this.prefix, this.color);

  String get formatted => rgb(prefix, color);
}

class SearchResponse {
  final SearchResultEntry result;
  final SearchResultEntry? translated;
  final MappingType type;

  SearchResponse(JsonObject json)
      : result = SearchResultEntry.parse(json),
        translated = json.containsKey("l") ? SearchResultEntry.parse(json["l"]) : null,
        type = json.containsKey("a") ? (json["t"] == "f" ? MappingType.field : MappingType.method) : MappingType.clazz;

  void printToConsole(String namespace, int padding, {String? translatedNamespace}) {
    var singleLine = !showIntermediary && !showUnmapped && translated == null;
    if (singleLine) {
      print("${type.formatted} ${result.formatted.padRight(padding)}");
    } else {
      print("${type.formatted} ${result.formatted.padRight(padding)}  |  ${Color.LIGHT_GRAY}$namespace$ansiReset");
    }

    if (showIntermediary) {
      print("  ${result.formattedIntermediary.padRight(padding)}  |  ${Color.LIGHT_GRAY}intermediary$ansiReset");
    }

    if (showUnmapped) {
      print("  ${result.formattedUnmapped.padRight(padding)}  |  ${Color.LIGHT_GRAY}unmapped$ansiReset");
    }

    if (translated != null) {
      print("  ${translated!.formatted.padRight(padding)}  |  ${Color.LIGHT_GRAY}${translatedNamespace!}$ansiReset\n");
    }

    if (!singleLine) print("");
  }
}
