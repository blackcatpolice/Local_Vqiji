# encoding: utf-8
require 'spec_helper'

describe 'User Sign In' do
  let(:user) { create :user }
  
  before(:each) { visit '/sign_in' }
  
  it 'user should sign in by email' do
    within('form.form-signin') do
      fill_in('user_login', with: user.email)
      fill_in('user_password', with: user.password)
      find('input[type=submit]').click
    end
    
    page.current_path.should == root_path
    #page.should have_text(user.name)
  end

  it 'user should sign in by job_no' do
    within('form.form-signin') do
      fill_in('user_login', with: user.job_no)
      fill_in('user_password', with: user.password)
      find('input[type=submit]').click
    end
    
    page.current_path.should == root_path
    # page.should have_text(user.name)
  end

  it 'user should sign in fail when login(email/job_no) don\'t exist' do
    within('form.form-signin') do
      fill_in('user_login', with: user.email * 2 + '!@#!@')
      fill_in('user_password', with: user.password)
      find('input[type=submit]').click
    end
    
    page.current_path.should == sign_in_path
    page.should have_text(I18n.t('devise.failure.not_found_in_database'))
  end

  it 'user should sign in fail when password don\'t correct' do
    within('form.form-signin') do
      fill_in('user_login', with: user.email)
      fill_in('user_password', with: user.password * 2 + '!@#!@')
      find('input[type=submit]').click
    end
    
    page.current_path.should == sign_in_path
    page.should have_text(I18n.t('devise.failure.invalid'))
  end
end
