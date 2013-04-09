# -*- coding: utf-8 -*-
ActiveAdmin.register_page "Dashboard" do

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }
  page_action :foobar, :method => :post do
    redirect_to :dashboard
  end

  content :title => proc{ I18n.t("active_admin.dashboard") } do

    panel "TEMPLATE" do
      template_path = 
      br do
        "現在登録されているファイル："
        link_to(Lise::Application.config.template_unix_path, Lise::Application.config.template_path)
      end
      form :method => :post, :enctype => 'multipart/form-data', :action => admin_dashboard_foobar_path do
        input :type => 'hidden', :name => 'authenticity_token', :value => form_authenticity_token
        
      end
    end

    panel "Excel to HTML" do

    end


  end # content
end
