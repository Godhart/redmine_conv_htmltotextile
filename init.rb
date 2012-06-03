require 'redmine'

Redmine::Plugin.register :redmine_conv_htmltotextile do
  name 'Redmine HTML-to-Textile conversion plugin'
  author 'Nikolay Gniteev (godhart@gmail.com)'
  description 'Adds server-side HTML-to-textile conversion. Requires HPRICOT gem.'
  version '0.2.1'
  url 'https://github.com/Godhart/redmine_conv_htmltotextile'
  author_url 'http://'
end
