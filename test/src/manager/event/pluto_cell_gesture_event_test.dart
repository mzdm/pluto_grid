import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../matcher/pluto_object_matcher.dart';
import '../../../mock/mock_pluto_event_manager.dart';
import '../../../mock/mock_pluto_state_manager.dart';

void main() {
  PlutoStateManager stateManager;
  PlutoEventManager eventManager;

  var eventBuilder = ({
    @required PlutoGestureType gestureType,
    Offset offset,
    PlutoCell cell,
    PlutoColumn column,
    int rowIdx,
  }) =>
      PlutoCellGestureEvent(
        gestureType: gestureType,
        offset: offset ?? Offset.zero,
        cell: cell ?? PlutoCell(value: 'value'),
        column: column ??
            PlutoColumn(
              title: 'column',
              field: 'column',
              type: PlutoColumnType.text(),
            ),
        rowIdx: rowIdx ?? 0,
      );

  setUp(() {
    stateManager = MockPlutoStateManager();
    eventManager = MockPlutoEventManager();
    when(stateManager.eventManager).thenReturn(eventManager);
  });

  group('onTapUp', () {
    test(
      'When, '
      'hasFocus = false, '
      'isCurrentCell = true, '
      'Then, '
      'setKeepFocus(true) 가 호출 되고, '
      'isCurrentCell 가 true 인 경우 return 되어야 한다.',
      () {
        // given
        when(stateManager.hasFocus).thenReturn(false);
        when(stateManager.isCurrentCell(any)).thenReturn(true);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(gestureType: PlutoGestureType.onTapUp);
        event.handler(stateManager);

        // then
        verify(stateManager.setKeepFocus(true)).called(1);
        // return 이후 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setEditing(any));
        verifyNever(stateManager.setCurrentCell(any, any));
      },
    );

    test(
      'When, '
      'hasFocus = false, '
      'isCurrentCell = false, '
      'isSelectingInteraction = false, '
      'PlutoMode = normal, '
      'isEditing = true, '
      'Then, '
      'setKeepFocus(true) 가 호출 되고, '
      'setCurrentCell 이 호출 되어야 한다.',
      () {
        // given
        when(stateManager.hasFocus).thenReturn(false);
        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
        when(stateManager.mode).thenReturn(PlutoMode.normal);
        when(stateManager.isEditing).thenReturn(true);
        clearInteractions(stateManager);

        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setKeepFocus(true)).called(1);
        verify(stateManager.setCurrentCell(cell, rowIdx)).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setEditing(any));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isCurrentCell = true, '
      'isSelectingInteraction = false, '
      'PlutoMode = normal, '
      'isEditing = false, '
      'Then, '
      'setEditing(true) 가 호출 되어야 한다.',
      () {
        // given
        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isCurrentCell(any)).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
        when(stateManager.mode).thenReturn(PlutoMode.normal);
        when(stateManager.isEditing).thenReturn(false);
        clearInteractions(stateManager);

        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setEditing(true)).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setKeepFocus(true));
        verifyNever(stateManager.setCurrentCell(any, any));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = true, '
      'keyPressed.shift = true, '
      'Then, '
      'setCurrentSelectingPosition 가 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        final columnIdx = 1;
        final rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(true);
        when(stateManager.keyPressed).thenReturn(PlutoKeyPressed(shift: true));
        when(stateManager.columnIndex(any)).thenReturn(columnIdx);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(
          stateManager.setCurrentSelectingPosition(
              cellPosition: PlutoCellPosition(
            columnIdx: columnIdx,
            rowIdx: rowIdx,
          )),
        ).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setKeepFocus(true));
        verifyNever(stateManager.toggleSelectingRow(any));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = true, '
      'keyPressed.ctrl = true, '
      'Then, '
      'toggleSelectingRow 가 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(true);
        when(stateManager.keyPressed).thenReturn(PlutoKeyPressed(ctrl: true));
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(
          stateManager.toggleSelectingRow(rowIdx),
        ).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setKeepFocus(true));
        verifyNever(stateManager.setCurrentSelectingPosition(
          cellPosition: anyNamed('cellPosition'),
        ));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = false, '
      'PlutoMode = select, '
      'isCurrentCell = true, '
      'Then, '
      'handleOnSelected 가 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
        when(stateManager.mode).thenReturn(PlutoMode.select);
        when(stateManager.isCurrentCell(any)).thenReturn(true);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.handleOnSelected()).called(1);
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.setCurrentCell(any, any));
      },
    );

    test(
      'When, '
      'hasFocus = true, '
      'isSelectingInteraction = false, '
      'PlutoMode = select, '
      'isCurrentCell = false, '
      'Then, '
      'setCurrentCell 가 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        when(stateManager.hasFocus).thenReturn(true);
        when(stateManager.isSelectingInteraction()).thenReturn(false);
        when(stateManager.mode).thenReturn(PlutoMode.select);
        when(stateManager.isCurrentCell(any)).thenReturn(false);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onTapUp,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setCurrentCell(cell, rowIdx));
        // 호출 되지 않아야 할 메소드
        verifyNever(stateManager.handleOnSelected());
      },
    );
  });

  group('onLongPressStart', () {
    test(
      'When, '
      'isCurrentCell = false, '
      'Then, '
      'setCurrentCell, setSelecting 이 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(false);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onLongPressStart,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.isCurrentCell(cell));
        verify(stateManager.setCurrentCell(cell, rowIdx, notify: false));
        verify(stateManager.setSelecting(true));
      },
    );

    test(
      'When, '
      'isCurrentCell = true, '
      'Then, '
      'setCurrentCell 이 호출 되지 않아야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(true);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onLongPressStart,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verifyNever(stateManager.setCurrentCell(cell, rowIdx, notify: false));
      },
    );

    test(
      'When, '
      'isCurrentCell = false, '
      'selectingMode = Row, '
      'Then, '
      'toggleSelectingRow 가 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.selectingMode).thenReturn(PlutoSelectingMode.row);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onLongPressStart,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.toggleSelectingRow(rowIdx));
      },
    );
  });

  group('onLongPressMoveUpdate', () {
    test(
      'setCurrentSelectingPositionWithOffset, addEvent 가 호출 되어야 한다.',
      () {
        // given
        final offset = const Offset(2.0, 3.0);
        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        when(stateManager.isCurrentCell(any)).thenReturn(false);
        when(stateManager.selectingMode).thenReturn(PlutoSelectingMode.row);
        clearInteractions(stateManager);

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onLongPressMoveUpdate,
          offset: offset,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setCurrentSelectingPositionWithOffset(offset));
        verify(eventManager.addEvent(
            argThat(PlutoObjectMatcher<PlutoMoveUpdateEvent>(rule: (event) {
          return event.offset == offset;
        }))));
      },
    );
  });

  group('onLongPressEnd', () {
    test(
      'setSelecting 이 false 로 호출 되어야 한다.',
      () {
        // given
        final cell = PlutoCell(value: 'value');
        final rowIdx = 1;

        // when
        var event = eventBuilder(
          gestureType: PlutoGestureType.onLongPressEnd,
          cell: cell,
          rowIdx: rowIdx,
        );
        event.handler(stateManager);

        // then
        verify(stateManager.setSelecting(false));
      },
    );
  });
}
