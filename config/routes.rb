#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'convert' do |convert_routes|
    convert_routes.connect "convert/htmltotextile", :conditions => { :method => [:post, :put] }, :action => 'htmltotextile'
  end
end
