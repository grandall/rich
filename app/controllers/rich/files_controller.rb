module Rich
  class FilesController < ApplicationController

    before_filter :authenticate_rich_user

    layout "rich/application"
    
    def index
      @type = params[:type]
      query = if @type == 'image'
        RichFile.images
      elsif @type == 'video'
        RichFile.videos
      else
        RichFile.files
      end.order('created_at DESC')
      query = query.where(:owner_type => params[:scope_type], :owner_id => :params[:scope_id]) if params[:scoped] == 'true'
      @items = query.page params[:page]
      
      # stub for new file
      @rich_asset = RichFile.new
      
      respond_to do |format|
        format.js
        format.html
      end
      
    end
    
    def show
      # show is used to retrieve single files through XHR requests after a file has been uploaded
      
      if(params[:id])
        # list all files
        @file = RichFile.find(params[:id])
        render :layout => false
      else 
        render :text => "File not found"
      end
      
    end
    
    def create
      @file = RichFile.new(:simplified_type => params[:simplified_type]) #make sure the type is set

      @file.permission = params[:permission] if (params[:permission].present? && params[:permission] != 'undefined')
      
      if(params[:scoped] == 'true')
        @file.owner_type = params[:scope_type]
        @file.owner_id = params[:scope_id].to_i
      end
      
      # use the file from Rack Raw Upload
      if(params[:file])
        @file.rich_file = params[:file]
      end
      
      if @file.save
        render :json => { :success => true, :rich_id => @file.id }
      else
        render :json => { :success => false, 
                          :error => "Could not upload your file:\n- "+@file.errors.to_a[-1].to_s,
                          :params => params.inspect }
      end
    end
    
    def destroy  
      if(params[:id])
        rich_file = RichFile.delete(params[:id])
        @fileid = params[:id]
      end
    end
    
  end
end
