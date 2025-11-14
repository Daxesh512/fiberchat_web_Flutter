double getContentScreenWidth(double w) {
  return w > 820 ? (w - (w / 3)) : w;
}

bool isWideScreen(double w) {
  return w > 820 ? true : false;
}
