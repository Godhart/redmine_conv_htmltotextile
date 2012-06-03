# redmine_conv_htmltotextile

is HTML to Textile conversion plugin for Redmine.

# Installation

1. Copy the plugin directory into the `vendor/plugins` directory (make sure the name is redmine_conv_htmltotextile)
2. Install hpricot gem: `gem install hpricot`
3. Run bundler: `bundle install --without development test` _all other options you usualy provide_
4. Run migration: `rake db:migrate:plugins` _(don't forget to be in the root redmine directory when doing this)_
5. Restart Redmine: `touch tmp/restart.txt` _(don't forget to be in the root redmine directory when doing this)_

# Usage

There is no direct usage for this plugin. It's supplement for [redmine_aloha_wiki](https://github.com/Godhart/redmine_aloha_wiki) plugin and also could be used by any other plugins for HTML to textile conversion.

It provides 'convert/htmltotextile' controller for AJAX requests and takes following arguments as input:

* content[text] _as a text to be converted_
* project\_id _as origin project of wiki page. It's used to distinguish inner and outer wiki links_
* id _as a wiki page name. It's reserved for further use_

Output is a result of conversion in plain text.

# Disclaimer

Plugin provided "as is" under copyleft license and it'll always be like this.

Plugin is tested only for Redmine v.1.4. There is no guarantee that it would work for other versions of Redmine.

I'm real newbie to Ruby, Rails, Redmine and not doing well with HTML things so you may find some ugly things within code. A good advice is always welcomed.

# Word of thanks

Thanks to P.J.Lawrence who started [redmine_wysiwyg_textile](https://github.com/kalmykov/redmine_wysiwyg_textile) plugin and Alexey Kalmykov who made some corrections as I've heavily used that plugin to get HTML to textile conversion in my redmine_conv_htmltotextile plugin. Actualy I took it's core and did some adjustments.

[Stackoverflow](http://stackoverflow.com) people as it's there I found most answers to my questions (thank's to Google but anyway...)

World of opensource
