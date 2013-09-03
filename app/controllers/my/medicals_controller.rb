# encoding: utf-8

# 录音微博
class My::MedicalsController < WeiboController

	def index
		@mrs = Qa::MedicalRecord.where(:user_id => current_user.id).desc("created_at")
		@mr = Qa::MedicalRecord.new
	end

  def create
		
		@mr = Qa::MedicalRecord.new(params[:qa_medical_record]) 
		@mr.user_id = current_user.id
		if @mr.save
			flash[:notice] = "提示：文件上传成功"
			redirect_to :action => :index	
		else
			flash[:notice] = "提示：文件不能大于5M"
			redirect_to :action => :index	
		end		  
    
  end
  
  def changetitle
  	@mr = Qa::MedicalRecord.find(params[:id])
  	@mr.title = params[:title]
  	
		if @mr.save
   	 	respond_to do |format|
    	  	format.json { render :json => @mr.as_json }
    	end  
    end
  
  end
  
  def destroy
  	@mr = Qa::MedicalRecord.find(params[:id])
  	@mr.record.delete
  	@mr.destroy
  	redirect_to :action => :index
  end
  
  def my_medicals
  	@mrs = Qa::MedicalRecord.where(:user_id => current_user.id).desc("created_at")

 	 	respond_to do |format|
  	  	format.json { render :json => @mrs.as_json }
  	end  
  	
  end
  
  def destroy_batch
   	@mList = params[:msgList]
   	@mArray = @mList.split(",").to_a
   	@mArray.each do |m|
   		begin
	   		@mr = Qa::MedicalRecord.find(m.to_s)
   			@mr.destroy
    	rescue 
    		puts "noting"	
    	end
   	end
   	
   	respond_to do |format| 
   		format.json{ render :json => @mArray.as_json}
   	end
  
  end
  
end
