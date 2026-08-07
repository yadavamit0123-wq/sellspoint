/// Wizard steps for in-app post-ad ([AdPostingCubit]).
enum AdPostingStep {
  adType('adListing', 'postAdSubtitle'),
  category('selectTheCategory', 'postAdStepDetails'),
  baseDetails('postAdStepDetails', 'description'),
  customFields('additionals', 'description'),
  mediaUpload('uploadPictures', 'max5Images');

  const AdPostingStep(this.titleKey, this.subtitleKey);

  final String titleKey;
  final String subtitleKey;
}
