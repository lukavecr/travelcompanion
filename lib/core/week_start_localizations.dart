// VYGENEROVÁNO: python tool/gen_week_start.py – needitovat ručně.
// ignore_for_file: deprecated_member_use, annotate_overrides
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_settings.dart';

/// MaterialLocalizations se zvoleným prvním dnem týdne (0 = neděle, 1 = pondělí, 6 = sobota).
class WeekStartMaterialLocalizations implements MaterialLocalizations {
  WeekStartMaterialLocalizations(this._b, this.firstDayOfWeekIndex);
  final MaterialLocalizations _b;

  @override
  final int firstDayOfWeekIndex;

  @override
  String get openAppDrawerTooltip => _b.openAppDrawerTooltip;

  @override
  String get backButtonTooltip => _b.backButtonTooltip;

  @override
  String get clearButtonTooltip => _b.clearButtonTooltip;

  @override
  String get closeButtonTooltip => _b.closeButtonTooltip;

  @override
  String get deleteButtonTooltip => _b.deleteButtonTooltip;

  @override
  String get moreButtonTooltip => _b.moreButtonTooltip;

  @override
  String get nextMonthTooltip => _b.nextMonthTooltip;

  @override
  String get previousMonthTooltip => _b.previousMonthTooltip;

  @override
  String get firstPageTooltip => _b.firstPageTooltip;

  @override
  String get lastPageTooltip => _b.lastPageTooltip;

  @override
  String get nextPageTooltip => _b.nextPageTooltip;

  @override
  String get previousPageTooltip => _b.previousPageTooltip;

  @override
  String get showMenuTooltip => _b.showMenuTooltip;

  @override
  String aboutListTileTitle(String applicationName) => _b.aboutListTileTitle(applicationName);

  @override
  String get licensesPageTitle => _b.licensesPageTitle;

  @override
  String licensesPackageDetailText(int licenseCount) => _b.licensesPackageDetailText(licenseCount);

  @override
  String pageRowsInfoTitle(int firstRow, int lastRow, int rowCount, bool rowCountIsApproximate) => _b.pageRowsInfoTitle(firstRow, lastRow, rowCount, rowCountIsApproximate);

  @override
  String get rowsPerPageTitle => _b.rowsPerPageTitle;

  @override
  String tabLabel({required int tabIndex, required int tabCount}) => _b.tabLabel(tabIndex: tabIndex, tabCount: tabCount);

  @override
  String selectedRowCountTitle(int selectedRowCount) => _b.selectedRowCountTitle(selectedRowCount);

  @override
  String get cancelButtonLabel => _b.cancelButtonLabel;

  @override
  String get closeButtonLabel => _b.closeButtonLabel;

  @override
  String get continueButtonLabel => _b.continueButtonLabel;

  @override
  String get copyButtonLabel => _b.copyButtonLabel;

  @override
  String get cutButtonLabel => _b.cutButtonLabel;

  @override
  String get scanTextButtonLabel => _b.scanTextButtonLabel;

  @override
  String get okButtonLabel => _b.okButtonLabel;

  @override
  String get pasteButtonLabel => _b.pasteButtonLabel;

  @override
  String get selectAllButtonLabel => _b.selectAllButtonLabel;

  @override
  String get lookUpButtonLabel => _b.lookUpButtonLabel;

  @override
  String get searchWebButtonLabel => _b.searchWebButtonLabel;

  @override
  String get shareButtonLabel => _b.shareButtonLabel;

  @override
  String get viewLicensesButtonLabel => _b.viewLicensesButtonLabel;

  @override
  String get anteMeridiemAbbreviation => _b.anteMeridiemAbbreviation;

  @override
  String get postMeridiemAbbreviation => _b.postMeridiemAbbreviation;

  @override
  String get timePickerHourModeAnnouncement => _b.timePickerHourModeAnnouncement;

  @override
  String get timePickerMinuteModeAnnouncement => _b.timePickerMinuteModeAnnouncement;

  @override
  String get modalBarrierDismissLabel => _b.modalBarrierDismissLabel;

  @override
  String get menuDismissLabel => _b.menuDismissLabel;

  @override
  String get drawerLabel => _b.drawerLabel;

  @override
  String get popupMenuLabel => _b.popupMenuLabel;

  @override
  String get menuBarMenuLabel => _b.menuBarMenuLabel;

  @override
  String get dialogLabel => _b.dialogLabel;

  @override
  String get alertDialogLabel => _b.alertDialogLabel;

  @override
  String get searchFieldLabel => _b.searchFieldLabel;

  @override
  String get currentDateLabel => _b.currentDateLabel;

  @override
  String get selectedDateLabel => _b.selectedDateLabel;

  @override
  String get scrimLabel => _b.scrimLabel;

  @override
  String get bottomSheetLabel => _b.bottomSheetLabel;

  @override
  String scrimOnTapHint(String modalRouteContentName) => _b.scrimOnTapHint(modalRouteContentName);

  @override
  TimeOfDayFormat timeOfDayFormat({bool alwaysUse24HourFormat = false}) => _b.timeOfDayFormat(alwaysUse24HourFormat: alwaysUse24HourFormat);

  @override
  ScriptCategory get scriptCategory => _b.scriptCategory;

  @override
  String formatDecimal(int number) => _b.formatDecimal(number);

  @override
  String formatHour(TimeOfDay timeOfDay, {bool alwaysUse24HourFormat = false}) => _b.formatHour(timeOfDay, alwaysUse24HourFormat: alwaysUse24HourFormat);

  @override
  String formatMinute(TimeOfDay timeOfDay) => _b.formatMinute(timeOfDay);

  @override
  String formatTimeOfDay(TimeOfDay timeOfDay, {bool alwaysUse24HourFormat = false}) => _b.formatTimeOfDay(timeOfDay, alwaysUse24HourFormat: alwaysUse24HourFormat);

  @override
  String formatYear(DateTime date) => _b.formatYear(date);

  @override
  String formatCompactDate(DateTime date) => _b.formatCompactDate(date);

  @override
  String formatShortDate(DateTime date) => _b.formatShortDate(date);

  @override
  String formatMediumDate(DateTime date) => _b.formatMediumDate(date);

  @override
  String formatFullDate(DateTime date) => _b.formatFullDate(date);

  @override
  String formatMonthYear(DateTime date) => _b.formatMonthYear(date);

  @override
  String formatShortMonthDay(DateTime date) => _b.formatShortMonthDay(date);

  @override
  DateTime? parseCompactDate(String? inputString) => _b.parseCompactDate(inputString);

  @override
  List<String> get narrowWeekdays => _b.narrowWeekdays;

  @override
  String get dateSeparator => _b.dateSeparator;

  @override
  String get dateHelpText => _b.dateHelpText;

  @override
  String get selectYearSemanticsLabel => _b.selectYearSemanticsLabel;

  @override
  String get unspecifiedDate => _b.unspecifiedDate;

  @override
  String get unspecifiedDateRange => _b.unspecifiedDateRange;

  @override
  String get dateInputLabel => _b.dateInputLabel;

  @override
  String get dateRangeStartLabel => _b.dateRangeStartLabel;

  @override
  String get dateRangeEndLabel => _b.dateRangeEndLabel;

  @override
  String dateRangeStartDateSemanticLabel(String formattedDate) => _b.dateRangeStartDateSemanticLabel(formattedDate);

  @override
  String dateRangeEndDateSemanticLabel(String formattedDate) => _b.dateRangeEndDateSemanticLabel(formattedDate);

  @override
  String get invalidDateFormatLabel => _b.invalidDateFormatLabel;

  @override
  String get invalidDateRangeLabel => _b.invalidDateRangeLabel;

  @override
  String get dateOutOfRangeLabel => _b.dateOutOfRangeLabel;

  @override
  String get saveButtonLabel => _b.saveButtonLabel;

  @override
  String get datePickerHelpText => _b.datePickerHelpText;

  @override
  String get dateRangePickerHelpText => _b.dateRangePickerHelpText;

  @override
  String get calendarModeButtonLabel => _b.calendarModeButtonLabel;

  @override
  String get inputDateModeButtonLabel => _b.inputDateModeButtonLabel;

  @override
  String get timePickerDialHelpText => _b.timePickerDialHelpText;

  @override
  String get timePickerInputHelpText => _b.timePickerInputHelpText;

  @override
  String get timePickerHourLabel => _b.timePickerHourLabel;

  @override
  String get timePickerMinuteLabel => _b.timePickerMinuteLabel;

  @override
  String get invalidTimeLabel => _b.invalidTimeLabel;

  @override
  String get dialModeButtonLabel => _b.dialModeButtonLabel;

  @override
  String get inputTimeModeButtonLabel => _b.inputTimeModeButtonLabel;

  @override
  String get signedInLabel => _b.signedInLabel;

  @override
  String get hideAccountsLabel => _b.hideAccountsLabel;

  @override
  String get showAccountsLabel => _b.showAccountsLabel;

  @override
  String get reorderItemToStart => _b.reorderItemToStart;

  @override
  String get reorderItemToEnd => _b.reorderItemToEnd;

  @override
  String get reorderItemUp => _b.reorderItemUp;

  @override
  String get reorderItemDown => _b.reorderItemDown;

  @override
  String get reorderItemLeft => _b.reorderItemLeft;

  @override
  String get reorderItemRight => _b.reorderItemRight;

  @override
  String get expandedIconTapHint => _b.expandedIconTapHint;

  @override
  String get collapsedIconTapHint => _b.collapsedIconTapHint;

  @override
  String get expansionTileExpandedHint => _b.expansionTileExpandedHint;

  @override
  String get expansionTileCollapsedHint => _b.expansionTileCollapsedHint;

  @override
  String get expansionTileExpandedTapHint => _b.expansionTileExpandedTapHint;

  @override
  String get expansionTileCollapsedTapHint => _b.expansionTileCollapsedTapHint;

  @override
  String get expandedHint => _b.expandedHint;

  @override
  String get collapsedHint => _b.collapsedHint;

  @override
  String remainingTextFieldCharacterCount(int remaining) => _b.remainingTextFieldCharacterCount(remaining);

  @override
  String get refreshIndicatorSemanticLabel => _b.refreshIndicatorSemanticLabel;

  @override
  String get keyboardKeyAlt => _b.keyboardKeyAlt;

  @override
  String get keyboardKeyAltGraph => _b.keyboardKeyAltGraph;

  @override
  String get keyboardKeyBackspace => _b.keyboardKeyBackspace;

  @override
  String get keyboardKeyCapsLock => _b.keyboardKeyCapsLock;

  @override
  String get keyboardKeyChannelDown => _b.keyboardKeyChannelDown;

  @override
  String get keyboardKeyChannelUp => _b.keyboardKeyChannelUp;

  @override
  String get keyboardKeyControl => _b.keyboardKeyControl;

  @override
  String get keyboardKeyDelete => _b.keyboardKeyDelete;

  @override
  String get keyboardKeyEject => _b.keyboardKeyEject;

  @override
  String get keyboardKeyEnd => _b.keyboardKeyEnd;

  @override
  String get keyboardKeyEscape => _b.keyboardKeyEscape;

  @override
  String get keyboardKeyFn => _b.keyboardKeyFn;

  @override
  String get keyboardKeyHome => _b.keyboardKeyHome;

  @override
  String get keyboardKeyInsert => _b.keyboardKeyInsert;

  @override
  String get keyboardKeyMeta => _b.keyboardKeyMeta;

  @override
  String get keyboardKeyMetaMacOs => _b.keyboardKeyMetaMacOs;

  @override
  String get keyboardKeyMetaWindows => _b.keyboardKeyMetaWindows;

  @override
  String get keyboardKeyNumLock => _b.keyboardKeyNumLock;

  @override
  String get keyboardKeyNumpad1 => _b.keyboardKeyNumpad1;

  @override
  String get keyboardKeyNumpad2 => _b.keyboardKeyNumpad2;

  @override
  String get keyboardKeyNumpad3 => _b.keyboardKeyNumpad3;

  @override
  String get keyboardKeyNumpad4 => _b.keyboardKeyNumpad4;

  @override
  String get keyboardKeyNumpad5 => _b.keyboardKeyNumpad5;

  @override
  String get keyboardKeyNumpad6 => _b.keyboardKeyNumpad6;

  @override
  String get keyboardKeyNumpad7 => _b.keyboardKeyNumpad7;

  @override
  String get keyboardKeyNumpad8 => _b.keyboardKeyNumpad8;

  @override
  String get keyboardKeyNumpad9 => _b.keyboardKeyNumpad9;

  @override
  String get keyboardKeyNumpad0 => _b.keyboardKeyNumpad0;

  @override
  String get keyboardKeyNumpadAdd => _b.keyboardKeyNumpadAdd;

  @override
  String get keyboardKeyNumpadComma => _b.keyboardKeyNumpadComma;

  @override
  String get keyboardKeyNumpadDecimal => _b.keyboardKeyNumpadDecimal;

  @override
  String get keyboardKeyNumpadDivide => _b.keyboardKeyNumpadDivide;

  @override
  String get keyboardKeyNumpadEnter => _b.keyboardKeyNumpadEnter;

  @override
  String get keyboardKeyNumpadEqual => _b.keyboardKeyNumpadEqual;

  @override
  String get keyboardKeyNumpadMultiply => _b.keyboardKeyNumpadMultiply;

  @override
  String get keyboardKeyNumpadParenLeft => _b.keyboardKeyNumpadParenLeft;

  @override
  String get keyboardKeyNumpadParenRight => _b.keyboardKeyNumpadParenRight;

  @override
  String get keyboardKeyNumpadSubtract => _b.keyboardKeyNumpadSubtract;

  @override
  String get keyboardKeyPageDown => _b.keyboardKeyPageDown;

  @override
  String get keyboardKeyPageUp => _b.keyboardKeyPageUp;

  @override
  String get keyboardKeyPower => _b.keyboardKeyPower;

  @override
  String get keyboardKeyPowerOff => _b.keyboardKeyPowerOff;

  @override
  String get keyboardKeyPrintScreen => _b.keyboardKeyPrintScreen;

  @override
  String get keyboardKeyScrollLock => _b.keyboardKeyScrollLock;

  @override
  String get keyboardKeySelect => _b.keyboardKeySelect;

  @override
  String get keyboardKeyShift => _b.keyboardKeyShift;

  @override
  String get keyboardKeySpace => _b.keyboardKeySpace;
}


/// Delegát: texty Material v jazyce aplikace + první den týdne z nastavení.
class WeekStartMaterialDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  const WeekStartMaterialDelegate();

  @override
  bool isSupported(Locale locale) => GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async => WeekStartMaterialLocalizations(
      await GlobalMaterialLocalizations.delegate.load(locale), AppSettings.instance.weekStart);

  @override
  bool shouldReload(WeekStartMaterialDelegate old) => true;
}
