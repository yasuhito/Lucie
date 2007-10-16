define ensure_key_value( $file, $key, $value, $delimiter = " " ) {
  # append line if "$key" not in "$file"
  exec { "echo '$key$delimeter$value' >> $file":
    unless => "grep -qe '^$key[[:space:]]*$delimeter' -- $file",
    path => "/bin:/usr/bin"
  }

  # update it if it already exists...
  exec { "sed -i '' 's/^$key$delimeter.*$/$key$delimeter$value/g' $file":
    unless => "grep -xqe '$key[[:space:]]*$delimeter[[:space:]]*$value' -- $file",
    path => "/bin:/usr/bin"
  }
}


### Local variables:
### mode: Puppet
### coding: utf-8
### indent-tabs-mode: nil
### End:
