class SubversionLogParser
  def parse_log lines
    if lines.empty?
      return []
    end
    entries = XmlSimple.xml_in( lines.join, 'ForceArray' => [ 'logentry','path' ] )[ 'logentry' ] || []
    entries.map do | entry |
      parse_revision entry
    end
  end


  UPDATE_PATTERN = /^(...)  (\S.*)$/


  def parse_update(lines)
    lines[0..-2].collect do |line|
      match = UPDATE_PATTERN.match(line)
      if match
        operation, file = match[1..2]
        ChangesetEntry.new(operation, file)
      else
        nil
      end
    end.compact
  end


  def parse_info xml
    info = XmlSimple.xml_in( xml.to_s, 'ForceArray' => false )[ 'entry' ]
    Subversion::Info.new( info[ 'revision' ].to_i, info[ 'commit' ][ 'revision' ].to_i, info[ 'commit' ][ 'author' ] )
  end


  private
  

  def parse_revision(hash)
    changesets = hash.fetch('paths', {}).fetch('path', {}).map do |entry| 
      ChangesetEntry.new(entry['action'], entry['content'])
    end
    
    date = hash['date'] ? DateTime.parse(hash['date']) : nil
    message = hash['msg'] == {} ? nil : hash['msg']
    Revision.new(hash['revision'].to_i, hash['author'], date, message, changesets)
  end
end


### Local variables:
### mode: Ruby
### coding: utf-8-unix
### indent-tabs-mode: nil
### End:
