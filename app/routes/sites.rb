class Main
  get "/sites/new" do
    mustache :new_site
  end

  post '/sites' do
    @site = Site.new(params['site'])
    if @site.save

    else

    end
  end

  get "/sites/:id" do
    @site = Site[params[:id]]
    mustache :show_site
  end

  get "/sites/:id/edit" do
    @site = Site[params[:id]]
    mustache :edit_site
  end

  put "/sites/:id" do
    @site = Site[params[:id]]

    if @site.update(params[:site])
      redirect "/sites/#{@site.id}"
    else
      mustache :edit_site
    end
  end
end
