module ApplicationHelper
  def javascript_embed_file(file)
    raw('<script>' + Rails.application.assets.find_asset(file + '.js').source + '</script>')
  end
end
