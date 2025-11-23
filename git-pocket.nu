# This command doesn't do anything yet.
#
# This command will likely just be an alias for the `pocket` subcommand in the future.
def main []: nothing -> nothing {
  print "Nothing to see here yet!"
}

# Add the staged changes to a new pocket.
def "main pocket" [
  pocket_name: string # The name of the pocket to create
  --force (-f) # Whether to overwrite pre-existing pockets
]: nothing -> nothing {
  let treehash: string = git write-tree;
  git update-ref $"refs/pockets/($pocket_name)" $treehash;
  print $"Pocket '($pocket_name)' created at ($treehash)";
}
