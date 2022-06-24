#!/usr/bin/mawk -f

BEGIN {
  FS=OFS="/"
}

{
  if ($3~/^github.com/ || $3~/^gitee.com/) {
    if ($6~/^raw$/) {
      $3 = "raw.githubusercontent.com";

      for (i = 1; i <= NF; ++i)
        if (i != 6)
          printf("%s%s", $i, (i == NF) ? "\n" : OFS)
    }
  } else if ($3~/^rawcdn.githack.com$/) {
    $3 = "raw.githubusercontent.com";
    print
  } else if ($3~/^gitcdn./) {
    $3 = "raw.githubusercontent.com";

    for (i = 1; i <= NF; ++i)
      if (i != 4)
        printf("%s%s", $i, (i == NF) ? "\n" : OFS)
  } else {
    print
  }
}
