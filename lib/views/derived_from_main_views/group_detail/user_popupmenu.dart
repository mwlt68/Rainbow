  enum UserPopUpMenuOptions{
    Detail,
    Remove
  }

  extension ParseToString on UserPopUpMenuOptions {
    String toShortString() {
      return this.toString().split('.').last;
    }
  }