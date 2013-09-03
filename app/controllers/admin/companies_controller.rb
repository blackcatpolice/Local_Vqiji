## encoding: utf-8
##
##
class Admin::CompaniesController < Admin::BaseController
  
  #
  def index
    @companies = Company.all
  end
  
  
  def import
   @tmp = Tmp::File.create!(:file => params[:file],:uploader_id => current_user.id)
   #
   Spreadsheet.client_encoding = 'UTF-8'
   @path_file = "#{Rails.root}/public/#{@tmp.file.to_s}"
   book = Spreadsheet.open @path_file
   @worksheet = book.worksheet 0
  end
  
  def save
    @tmp = Tmp::File.find(params[:id]);
    @path_file = "#{Rails.root}/public/#{@tmp.file.to_s}"
    book = Spreadsheet.open @path_file
    @worksheet = book.worksheet 0
    Company.save_by_sheet @worksheet
  end
  
  def show
  end
  
end
