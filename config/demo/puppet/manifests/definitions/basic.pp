define ensure_key_value( $file, $key, $value, $delimiter = " " ) {
  # append line if "$key" not in "$file"
  exec { "echo '$key$delimiter$value' >> $file":
    unless => "grep -qe '^$key[[:space:]]*$delimiter' -- $file",
    path => "/bin:/usr/bin"
  }

  # update it if it already exists...
  exec { "sed -i -e 's/^$key$delimiter.*$/$key$delimiter$value/g' $file":
    unless => "grep -xqe '$key[[:space:]]*$delimiter[[:space:]]*$value' -- $file",
    path => "/bin:/usr/bin"
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
