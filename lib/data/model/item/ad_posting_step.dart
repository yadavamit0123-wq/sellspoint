enum AdPostingStep {
  adType('adTypeTitle', 'adTypeSubtitle'),
  category('categoryTitle', 'categorySubtitle'),
  baseDetails('baseDetailsTitle', 'baseDetailsSubtitle'),
  customFields('customFieldsTitle', 'customFieldsSubtitle'),
  mediaUpload('mediaUploadTitle', 'mediaUploadSubtitle'),
  location('locationTitle', 'locationSubtitle');

  const AdPostingStep(this.title, this.subtitle);

  final String title;
  final String subtitle;
}
