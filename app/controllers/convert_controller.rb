require 'diff'
require 'undress/textile'

# Nikolay Gniteev (c) 2012 (godhart@gmail.com)
# Adopted from redmine_wysiwyg_textile by P.J.Lawrence and Alexey Kalmykov

class ConvertController < ApplicationController
  unloadable

  def htmltotextile
    @text=params[:content][:text]
    @text=Undress(@text, {:project_id => params[:project_id], :id => params[:id]}).to_textile
    render :partial => 'textile'
  end

end

