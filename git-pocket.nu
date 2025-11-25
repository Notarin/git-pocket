# Manage git pockets.
#
# Pockets are similar to git stashes.
# Where they differ is that pockets are much simpler, missing features like stage/unstaged differentiation, long messages, etc.
# While stashes require multiple commits as well as reflog support under the hood, pockets simply use what little they need.
# Instead of using up to three commits objects and abusing the reflog like stashes, a pocket is just simply a single commit object, as well as a ref pointing to it for identification.
#
# Running `git pocket` without any subcommands will default to the `new` subcommand.
def main [
  pocket_name?: string # The name of the pocket to create
  --force (-f) # Whether to overwrite pre-existing pockets
]: nothing -> nothing {
  if $pocket_name == null {
    # The command was plainly run, best to show help.
    # Though it isn't easy, as we don't have a direct way to run the --help flag here.
    print "No subcommand provided, nor pocket name. Are you looking for help?";
    print "Due to the way git expects subcommands to work, `git pocket --help` will not run the underlying help command.";
    print "Instead try `git-pocket --help`.";
    return;
  }
  # Really not a fan of what I had to do here.
  # While a spread arg exists, I can take one, but I cant call `main new` with it.
  if $force {
    git pocket new $pocket_name --force
  } else {
    git pocket new $pocket_name
  }
}

# Add the staged changes to a new pocket.
@example "Creates a pocket named my-new-pocket" { git pocket new my-new-pocket }
def "main new" [
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
  # Check if anything is actually staged to pocket.
  if (git diff --staged | length) == 0 {
    print "No staged changes to pocket.";
    exit 1;
  }
  let tree_hash: string = git write-tree;
  # When making the commit, we give it a message that is just the pocket name again.
  # For right now, this is just a slightly useful placeholder, as giving it an empty message is not allowed,
  # and the work it would take to figure out giving it an empty message is not worth it when naming it the same thing as the pocket may be useful.
  # Of course this is subject to change. AAMOF, it will likely be very soon that a custom message flag is implemented.
  let commit_hash: string = git commit-tree $tree_hash -p HEAD -m $"Pocket '($pocket_name)'";
  git update-ref $"refs/pockets/($pocket_name)" $commit_hash;
  # Revert the staged changes, as they are now pocketed.
  git show $"refs/pockets/($pocket_name)" | git apply -R --index;
  print $"Pocket '($pocket_name)' created at ($commit_hash)";
}

# Check if a pocket already exists.
def check_if_pocket_exists [
  pocket_name: string # The name of the pocket to check for
]: nothing -> bool {
  let refs: table<hash: string, ref_path: string> = git show-ref | parse "{hash} {ref_path}";
  ($refs | where ref_path == $"refs/pockets/($pocket_name)" | length) > 0
}

# Lists existing pockets.
@example "Lists all existing pockets" { git pocket list }
def "main list" []: nothing -> string {
  let refs: table<hash: string, ref_path: string> = git show-ref | parse "{hash} {ref_path}";
  let pocket_refs: table<hash: string, ref_path: string> = $refs | where ref_path =~ "^refs/pockets/.*";

  let pockets: table<name: string, hash: string> = $pocket_refs | each {|row| {name: ($row.ref_path | str replace -r '^refs/pockets/' '') hash: $row.hash} };
  $pockets | each {|pocket| $"($pocket.name) ($pocket.hash)" } | str join "\n"
}

# Applies a pocket to the worktree, leaving the pocket intact.
@example "Applies the pocket named my-pocket to the worktree" { git pocket apply my-pocket }
def "main apply" [
  pocket_name: string # The name of the pocket to apply to the worktree
]: nothing -> nothing {
  git show $"refs/pockets/($pocket_name)" | git apply;
  print $"Applied pocket '($pocket_name)' to the worktree."
}

# Applies a pocket to the worktree and deletes the pocket.
@example "Applies and deletes the pocket named my-pocket" { git pocket pop my-pocket }
def "main pop" [
  pocket_name: string # The name of the pocket to apply to the worktree and delete
]: nothing -> nothing {
  git show $"refs/pockets/($pocket_name)" | git apply;
  git update-ref -d $"refs/pockets/($pocket_name)";
  print $"Applied and deleted pocket '($pocket_name)'."
}

# Delete a pocket.
@example "Deletes the pocket named my-pocket" { git pocket remove my-pocket }
def "main remove" [
  pocket_name: string # The name of the pocket to delete
]: nothing -> nothing {
  git update-ref -d $"refs/pockets/($pocket_name)";
  print $"Deleted pocket '($pocket_name)'."
}
