import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

/// A centralized registry for all icon assets used throughout the application.
///
/// Rather than referencing third-party icon libraries (like [PhosphorIcons])
/// directly in screen and widget implementations, all icons are mapped here.
/// This minimizes coupling, simplifies switching or updating the icon pack
/// in the future, and provides a single location to locate application icons.
// TODO(I): Name the properties according to use-case instead of Icon Library
abstract final class AppIcons {
  // Navigation & Actions
  static const IconData arrowRight = PhosphorIcons.arrowRight;
  static const IconData arrowsClockwise = PhosphorIcons.arrowsClockwise;
  static const IconData caretDown = PhosphorIcons.caretDown;
  static const IconData caretLeft = PhosphorIcons.caretLeft;
  static const IconData caretRight = PhosphorIcons.caretRight;
  static const IconData caretUp = PhosphorIcons.caretUp;
  static const IconData check = PhosphorIcons.check;
  static const IconData checkBold = PhosphorIcons.checkBold;
  static const IconData checkCircleFill = PhosphorIcons.checkCircleFill;
  static const IconData checkSquareFill = PhosphorIcons.checkSquareFill;
  static const IconData plus = PhosphorIcons.plus;
  static const IconData x = PhosphorIcons.x;
  static const IconData copy = PhosphorIcons.copy;
  static const IconData downloadSimple = PhosphorIcons.downloadSimple;
  static const IconData uploadSimple = PhosphorIcons.uploadSimple;
  static const IconData trash = PhosphorIcons.trash;
  static const IconData shareNetwork = PhosphorIcons.shareNetwork;
  static const IconData pauseFill = PhosphorIcons.pauseFill;
  static const IconData playFill = PhosphorIcons.playFill;
  static const IconData playCircle = PhosphorIcons.playCircle;
  static const IconData playCircleFill = PhosphorIcons.playCircleFill;
  static const IconData signOut = PhosphorIcons.signOut;
  static const IconData dotsThreeVertical = PhosphorIcons.dotsThreeVertical;
  static const IconData dotsThreeOutlineVertical =
      PhosphorIcons.dotsThreeOutlineVertical;
  static const IconData funnelSimple = PhosphorIcons.funnelSimple;
  static const IconData sliders = PhosphorIcons.sliders;
  static const IconData gpsFixFill = PhosphorIcons.gpsFixFill;
  static const IconData speakerLow = PhosphorIcons.speakerLow;
  static const IconData speakerHigh = PhosphorIcons.speakerHigh;
  static const IconData speakerX = PhosphorIcons.speakerX;
  static const IconData prohibit = PhosphorIcons.prohibit;

  // Interface & Settings
  static const IconData bell = PhosphorIcons.bell;
  static const IconData bugFill = PhosphorIcons.bugFill;
  static const IconData eye = PhosphorIcons.eye;
  static const IconData eyeSlash = PhosphorIcons.eyeSlash;
  static const IconData heart = PhosphorIcons.heart;
  static const IconData heartFill = PhosphorIcons.heartFill;
  static const IconData star = PhosphorIcons.star;
  static const IconData starFill = PhosphorIcons.starFill;
  static const IconData starHalfFill = PhosphorIcons.starHalfFill;
  static const IconData lock = PhosphorIcons.lock;
  static const IconData magnifyingGlass = PhosphorIcons.magnifyingGlass;
  static const IconData user = PhosphorIcons.user;
  static const IconData userFill = PhosphorIcons.userFill;
  static const IconData userGear = PhosphorIcons.userGear;
  static const IconData moon = PhosphorIcons.moon;
  static const IconData globe = PhosphorIcons.globe;
  static const IconData translate = PhosphorIcons.translate;
  static const IconData warning = PhosphorIcons.warningFill;
  static const IconData warningCircle = PhosphorIcons.warningCircle;
  static const IconData warningOctagon = PhosphorIcons.warningOctagon;
  static const IconData question = PhosphorIcons.question;
  static const IconData info = PhosphorIcons.info;
  static const IconData sealCheckFill = PhosphorIcons.sealCheckFill;
  static const IconData sealQuestion = PhosphorIcons.sealQuestion;
  static const IconData sealWarning = PhosphorIcons.sealWarning;
  static const IconData shieldCheck = PhosphorIcons.shieldCheck;
  static const IconData sparkleFill = PhosphorIcons.sparkleFill;
  static const IconData thumbsUp = PhosphorIcons.thumbsUp;
  static const IconData thumbsUpFill = PhosphorIcons.thumbsUpFill;
  static const IconData thumbsDown = PhosphorIcons.thumbsDown;
  static const IconData thumbsDownFill = PhosphorIcons.thumbsDownFill;

  // Media, Content & Communication
  static const IconData article = PhosphorIcons.article;
  static const IconData camera = PhosphorIcons.camera;
  static const IconData cameraFill = PhosphorIcons.cameraFill;
  static const IconData cameraPlus = PhosphorIcons.cameraPlus;
  static const IconData images = PhosphorIcons.images;
  static const IconData imagesFill = PhosphorIcons.imagesFill;
  static const IconData fileFill = PhosphorIcons.fileFill;
  static const IconData filePdf = PhosphorIcons.filePdf;
  static const IconData microphoneFill = PhosphorIcons.microphoneFill;
  static const IconData paperPlaneRightFill = PhosphorIcons.paperPlaneRightFill;
  static const IconData paperclip = PhosphorIcons.paperclip;
  static const IconData chatCircleText = PhosphorIcons.chatCircleText;
  static const IconData chatCircleTextFill = PhosphorIcons.chatCircleTextFill;
  static const IconData chatDots = PhosphorIcons.chatDots;
  static const IconData envelopeSimple = PhosphorIcons.envelopeSimple;
  static const IconData phone = PhosphorIcons.phone;
  static const IconData phoneFill = PhosphorIcons.phoneFill;
  static const IconData headset = PhosphorIcons.headset;
  static const IconData note = PhosphorIcons.note;
  static const IconData notepad = PhosphorIcons.notepad;
  static const IconData receipt = PhosphorIcons.receipt;
  static const IconData shoppingBagOpen = PhosphorIcons.shoppingBagOpen;
  static const IconData shoppingBagOpenFill = PhosphorIcons.shoppingBagOpenFill;
  static const IconData sketchLogo = PhosphorIcons.sketchLogo;
  static const IconData trendUp = PhosphorIcons.trendUp;
  static const IconData clock = PhosphorIcons.clock;
  static const IconData clockClockwise = PhosphorIcons.clockClockwise;
  static const IconData clockCounterClockwise =
      PhosphorIcons.clockCounterClockwise;
  static const IconData calendarDots = PhosphorIcons.calendarDots;
  static const IconData calendarDotsFill = PhosphorIcons.calendarDotsFill;
  static const IconData mapPin = PhosphorIcons.mapPin;
  static const IconData mapPinFill = PhosphorIcons.mapPinFill;
  static const IconData mapPinLine = PhosphorIcons.mapPinLine;
  static const IconData pencilSimpleLine = PhosphorIcons.pencilSimpleLine;
  static const IconData houseFill = PhosphorIcons.houseFill;
  static const IconData houseLine = PhosphorIcons.houseLine;
  static const IconData houseLineFill = PhosphorIcons.houseLineFill;
  static const IconData gridFour = PhosphorIcons.gridFour;
  static const IconData gridFourFill = PhosphorIcons.gridFourFill;
  static const IconData squareSplitVertical = PhosphorIcons.squareSplitVertical;
  static const IconData squareSplitVerticalFill =
      PhosphorIcons.squareSplitVerticalFill;
  static const IconData squaresFourFill = PhosphorIcons.squaresFourFill;
  static const IconData wallet = PhosphorIcons.wallet;
  static const IconData gift = PhosphorIcons.gift;
}
