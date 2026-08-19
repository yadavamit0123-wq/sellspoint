enum PostedSince {
  allTime('all_time', 'all-time'),
  today('today', 'today'),
  within1Week('within_1_week', 'within-1-week'),
  within2Week('within_2_week', 'within-2-week'),
  within1Month('within_1_month', 'within-1-month'),
  within3Month('within_3_month', 'within-3-month');

  const PostedSince(this.label, this.value);

  final String label;
  final String value;
}

enum ItemStatus {
  review('review', 'review'),
  approved('approved', 'approved'),
  softRejected('soft rejected', 'soft_rejected'),
  permanentRejected('permanent rejected', 'permanent_rejected'),
  soldOut('sold out', 'sold_out'),
  expired('expired', 'expired'),
  inactive('inactive', 'inactive'),
  resubmitted('resubmitted', 'resubmitted'),
  unknown('unknown', 'unknown');

  const ItemStatus(this.value, this.label);

  final String value;
  final String label;

  static ItemStatus parse(String value) {
    return ItemStatus.values.firstWhere(
      (element) => element.value == value,
      orElse: () => ItemStatus.unknown,
    );
  }
}

enum NotificationType {
  notification('notification'),
  itemUpdate('item-update'),
  itemEdit('item-edit'),
  chat('chat'),
  offer('offer'),
  payment('payment'),
  jobApplication('job-application'),
  applicationStatus('application-status'),
  itemReview('item-review'),
  verificationStatus('verifcation-request-update'),
  blog('blog'),
  unknown('');

  const NotificationType(this.key);

  final String key;

  static NotificationType? parse(String value) {
    final normalized = value.toLowerCase().replaceAll(
      RegExp('[^A-Za-z0-9]+'),
      '-',
    );

    return NotificationType.values.firstWhere(
      (element) => element.key == normalized,
      orElse: () => NotificationType.unknown,
    );
  }
}
