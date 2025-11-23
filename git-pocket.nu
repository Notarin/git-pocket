# This command doesn't do anything yet.
#
# This command will likely just be an alias for the `pocket` subcommand in the future.
def main []: nothing -> nothing {
  print "Nothing to see here yet!"
}

# Add the staged changes to a new pocket.
@example "Creates a pocket named my-new-pocket" { git pocket my-new-pocket }
def "main pocket" [
  pocket_name: string # The name of the pocket to create
  --force (-f) # Whether to overwrite pre-existing pockets
]: nothing -> nothing {
  if (check_if_pocket_exists $pocket_name) and (not $force) {
    error make {
      msg: "Pocket name collision!"
      label: {
        text: "This pocket already exists."
        span: (metadata $pocket_name).span
      }
      help: "If you're sure you want to overwrite it, try the --force flag."
    }
  }
  let treehash: string = git write-tree;
  git update-ref $"refs/pockets/($pocket_name)" $treehash;
  print $"Pocket '($pocket_name)' created at ($treehash)";
}

# Check if a pocket already exists.
def check_if_pocket_exists [
  pocket_name: string # The name of the pocket to check for
]: nothing -> bool {
  let refs: table<hash: string, ref_path: string> = git show-ref | parse "{hash} {ref_path}";
  ($refs | where ref_path == $"refs/pockets/($pocket_name)" | length) > 0
}
