// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchResultMemberEntry _$SearchResultMemberEntryFromJson(
        Map<String, dynamic> json) =>
    SearchResultMemberEntry(
      json['a'] as String?,
      json['b'] as String,
      json['c'] as String?,
      json['o'] as String?,
      json['i'] as String,
      json['n'] as String?,
      json['d'] as String?,
      json['e'] as String,
      json['f'] as String?,
      (json['z'] as num).toDouble(),
      json['t'] as String,
    );

Map<String, dynamic> _$SearchResultMemberEntryToJson(
        SearchResultMemberEntry instance) =>
    <String, dynamic>{
      'a': instance.ownerObf,
      'b': instance.ownerIntermediary,
      'c': instance.ownerNamed,
      'o': instance.obf,
      'i': instance.intermediary,
      'n': instance.named,
      'd': instance.descObf,
      'e': instance.descIntermediary,
      'f': instance.descNamed,
      'z': instance.score,
      't': instance.memberType,
    };

SearchResultClassEntry _$SearchResultClassEntryFromJson(
        Map<String, dynamic> json) =>
    SearchResultClassEntry(
      json['o'] as String?,
      json['i'] as String,
      json['n'] as String?,
      (json['z'] as num).toDouble(),
      json['t'] as String,
    );

Map<String, dynamic> _$SearchResultClassEntryToJson(
        SearchResultClassEntry instance) =>
    <String, dynamic>{
      'o': instance.obf,
      'i': instance.intermediary,
      'n': instance.named,
      'z': instance.score,
      't': instance.memberType,
    };
