#!/usr/bin/awk

BEGIN {
  FS=OFS="/"
}

{
  if ($3~/^github.com/) {
    if ($6~/^raw$/) {
      $3 = "raw.githubusercontent.com";

      for (i = 1; i <= NF; ++i)
        if (i != 6)
          printf("%s%s", $i, (i == NF) ? "\n" : OFS)
    }
  } else {
    if ($3~/^rawcdn.githack.com$/) {
      $3 = "raw.githubusercontent.com";
      print
    } else {
      print
    }
  }
}
