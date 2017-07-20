class FiguresController < ApplicationController

  get '/figures' do
    @figures = Figure.all
    erb :'figures/index'
  end

  get '/figures/new' do
    @titles = Title.all
    @landmarks = Landmark.all
    erb :'figures/new'
  end

  get '/figures/:id' do
    @figure = Figure.find(params[:id])
    erb :'figures/show'
  end

  post '/figures' do
    @figure = Figure.create(name: params[:figure][:name])
    @titles, @landmarks = [], []

    if params[:figure][:title_ids]
      @titles << params[:figure][:title_ids].map {|e| Title.find(e)}
    end
    if params[:title][:name] != ""
      @titles << Title.create(name: params[:title][:name])
    end

    if params[:figure][:landmark_ids]
      @landmarks << params[:figure][:landmark_ids].map {|e| Landmark.find(e)}
    end

    if params[:landmark][:name] != ""
      @landmarks << Landmark.create(params[:landmark])
    end

    @figure.titles << @titles.flatten
    @figure.landmarks << @landmarks.flatten
    redirect "/figures/#{@figure.id}"
  end

  get '/figures/:id/edit' do
    @figure = Figure.find(params[:id])
    @titles = Title.all
    @landmarks = Landmark.all
    erb :'figures/edit'
  end

  patch '/figures/:id' do
    @figure = Figure.find(params[:id])
    @figure.name = params[:figure][:name]

    if params[:landmark][:name].present?
      landmark = Landmark.create(params[:landmark])
      landmark.figure_id = @figure.id
      landmark.save
    end

    if params[:figure][:landmark_ids].blank?
      @figure.landmarks.each do |landmark|
        landmark.figure_id = nil
        landmark.save
      end
    end

    if params[:figure][:landmark_ids].present?
      params[:figure][:landmark_ids].each do |id|
        landmark = Landmark.find(id)
        landmark.figure_id = @figure.id
        landmark.save
      end
    end

    if params[:figure][:title_ids].blank?
      @figure.titles = []
    end

    if params[:title][:name].present?
      title = Title.create(params[:title])
      title.figures << @figure
      title.save
    end

    if params[:figure][:title_ids].present?
      params[:figure][:title_ids].each do |id|
        title = Title.find(id)
        @figure.titles << title
      end
    end

    @figure.save

    redirect "/figures/#{@figure.id}"
  end

end
