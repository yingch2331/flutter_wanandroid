class StatusEvent {
  String labelId;
  int status;
  int cid;

  StatusEvent(this.labelId, this.status, {this.cid});
}


class PageChangeEvent {
  int page;
  PageChangeEvent(this.page);
}