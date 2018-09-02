module ApplicationHelper
  def trim_string(str)
    if str.length > 40
      str[0..40] + "..."
    else
      str
    end
  end
end
