public static class HelperMethods {
  //processing
  public static boolean touching(PVector p1, PVector s1, PVector p2, PVector s2) {
    if ((abs(p1.x - p2.x) <= (s1.x+s2.x)/2.)
      &&(abs(p1.y - p2.y) <= (s1.y+s2.y)/2.)) {
      return true;
    }
    return false;
  }
  
  //greenfoot
  public static boolean touching(int p1x, int p1y, int s1, int p2x, int p2y, int s2) {
    if ((abs(p1x - p2x) <= (s1+s2)/2.)
      &&(abs(p1y - p2y) <= (s1+s2)/2.)) {
      return true;
    }
    
    return false;
  }
}
