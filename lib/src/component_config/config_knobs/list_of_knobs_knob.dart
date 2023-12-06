// Copyright (C) 2023 Intel Corporation
// SPDX-License-Identifier: BSD-3-Clause
//
// list_of_knobs_knob.dart
// A knob for holding a list of other knobs.
//
// 2023 December 5
// Author: Max Korbel <max.korbel@intel.com>

import 'dart:collection';

import 'package:rohd_hcl/rohd_hcl.dart';

/// A knob wich holds a collection of other [ConfigKnob]s.
class ListOfKnobsKnob extends ConfigKnob<int> {
  /// A function that should generate the initial [ConfigKnob] for the
  /// `index`th element in the collection.
  final ConfigKnob<dynamic> Function(int index) generateKnob;

  /// Stores the knobs in a [Map] so that if the count decreases and then
  /// increases again, the old knob will be restored into [knobs].
  final Map<int, ConfigKnob<dynamic>> _subKnobs = {};

  /// The name of this collection of knobs.
  final String name;

  /// The number of elements in the collection.
  int get count => value;
  set count(int newValue) => value = newValue;

  /// The [List] of [ConfigKnob]s collected by this knob.
  List<ConfigKnob<dynamic>> get knobs => UnmodifiableListView(List.generate(
        value,
        (i) => _subKnobs.update(
          i,
          (value) => value,
          ifAbsent: () => generateKnob(i),
        ),
        growable: false,
      ));

  /// Creates a new collection of [count] knobs, each initially generated by
  /// [generateKnob], and named [name].
  ListOfKnobsKnob(
      {required int count, required this.generateKnob, this.name = 'List'})
      : super(value: count);

  @override
  Map<String, dynamic> toJson() =>
      {'knobs': knobs.map((e) => e.toJson()).toList()};

  @override
  void loadJson(Map<String, dynamic> decodedJson) {
    final knobsList = decodedJson['knobs'] as List<dynamic>;
    value = knobsList.length;

    for (final (i, knob) in knobs.indexed) {
      knob.loadJson(knobsList[i] as Map<String, dynamic>);
    }
  }
}
