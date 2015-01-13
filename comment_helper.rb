class CommentHelper

  def self.parse_body(body, command)
    regex = Regexp.new("#{command}:(\\\w*)")
    if(match_data = regex.match body)
      return match_data.captures[0]
    end
  end
end
