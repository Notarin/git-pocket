def main [] {
  print "Nothing to see here yet!"
}

def "main pocket" [
  pocket_name: string
] {
  let treehash: string = git write-tree;
  git update-ref $"refs/pockets/($pocket_name)" $treehash;
  print $"Pocket '($pocket_name)' created at ($treehash)";
}
