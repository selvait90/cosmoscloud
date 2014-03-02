require 'dropbox_sdk'
require 'securerandom'
require 'google_drive/google_docs'
require 'google/api_client'

APP_KEY = '8s12gve6904qgu2'
APP_SECRET = 'pnu1radoh2qeqmo'


class CosmosesController < ApplicationController

 before_filter :google_drive_login, :only => [:list]

 GOOGLE_CLIENT_ID = "1044029776463-btpt14q2kat08idl3t802895g8913p63.apps.googleusercontent.com"
 GOOGLE_CLIENT_SECRET = "2OyQAbSyyhLrEmAmZuQPlIvm"
 #GOOGLE_CLIENT_ID = "1059033759759.apps.googleusercontent.com"
 #GOOGLE_CLIENT_SECRET = "HWmFIwzer2VbIXwD3c7nCWLH"
 GOOGLE_CLIENT_REDIRECT_URI = "https://localhost:3000/oauth2callback"
  # you better put constant like above in environments file, I have put it just for simplicity

    def list
        client = get_dropbox_client
        unless client
            redirect_to(:action => 'auth_start') and return
        end
        @dropbox_docs = []
        path = "/"

        metadata = client.metadata(path, file_limit=25000, list=true, hash=nil, rev=nil, include_deleted=false)
        for dfile in metadata['contents']
        	name = dfile['path']
        	@dropbox_docs << name[1..-1]
       	end
       	google_session = GoogleDrive.login_with_oauth(session[:google_token])
    	@google_docs = []
    	for file in google_session.files
      		@google_docs  << file.title     
    	end
        #drivelist = get_dr.slice!(-)
        #render :inline => "#{metadata['contents']} \n\n\n"
        #render json: metadata

    end

    def main
        client = get_dropbox_client
        unless client
            redirect_to(:action => 'auth_start') and return
        end

        account_info = client.account_info

        # Show a file upload page
        render :inline =>
            "#{account_info['email']} <br/><%= form_tag({:action => :upload}, :multipart => true) do %><%= file_field_tag 'file' %><%= submit_tag 'Upload' %><% end %>"
    end

    def upload
        client = get_dropbox_client
        unless client
            redirect_to(:action => 'auth_start') and return
        end

        begin
            # Upload the POST'd file to Dropbox, keeping the same name
            resp = client.put_file(params[:file].original_filename, params[:file].read)
            render :text => "Upload successful.  File now at #{resp['path']}"
        rescue DropboxAuthError => e
            session.delete(:access_token)  # An auth error means the access token is probably bad
            logger.info "Dropbox auth error: #{e}"
            render :text => "Dropbox auth error"
        rescue DropboxError => e
            logger.info "Dropbox API error: #{e}"
            render :text => "Dropbox API error"
        end
    end

   	# dropbox 
    def get_dropbox_client
        if session[:access_token]
            begin
                access_token = session[:access_token]
                DropboxClient.new(access_token)
            rescue
                # Maybe something's wrong with the access token?
                session.delete(:access_token)
                raise
            end
        end
    end

    def get_web_auth()
        redirect_uri = url_for(:action => 'auth_finish')
        DropboxOAuth2Flow.new(APP_KEY, APP_SECRET, redirect_uri, session, :dropbox_auth_csrf_token)
    end

    def auth_start
        authorize_url = get_web_auth().start()

        # Send the user to the Dropbox website so they can authorize our app.  After the user
        # authorizes our app, Dropbox will redirect them here with a 'code' parameter.
        redirect_to authorize_url
    end

    def auth_finish
        begin
            access_token, user_id, url_state = get_web_auth.finish(params)
            session[:access_token] = access_token
            redirect_to :action => 'list'
        rescue DropboxOAuth2Flow::BadRequestError => e
            render :text => "Error in OAuth 2 flow: Bad request: #{e}"
        rescue DropboxOAuth2Flow::BadStateError => e
            logger.info("Error in OAuth 2 flow: No CSRF token in session: #{e}")
            redirect_to(:action => 'auth_start')
        rescue DropboxOAuth2Flow::CsrfError => e
            logger.info("Error in OAuth 2 flow: CSRF mismatch: #{e}")
            render :text => "CSRF error"
        rescue DropboxOAuth2Flow::NotApprovedError => e
            render :text => "Not approved?  Why not, bro?"
        rescue DropboxOAuth2Flow::ProviderError => e
            logger.info "Error in OAuth 2 flow: Error redirect from Dropbox: #{e}"
            render :text => "Strange error."
        rescue DropboxError => e
            logger.info "Error getting OAuth 2 access token: #{e}"
            render :text => "Error communicating with Dropbox servers."
        end
    end

    ######################## Google Drive ########################
  def list_google_docs
    google_session = GoogleDrive.login_with_oauth(session[:google_token])
    @google_docs = []
    for file in google_session.files
      @google_docs  << file.title     
    end
  end

  def download_google_docs
    file_name = params[:doc_upload]
    file_path = Rails.root.join('tmp',"doc_#{file_name}")
    google_session = GoogleDrive.login_with_oauth(session[:google_token])
    file = google_session.file_by_title(file_name)
    file.download_to_file(file_path)
    redirect_to list_google_doc_path
  end

  def set_google_drive_token
    google_doc = GoogleDrive::GoogleDocs.new(GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET,
                GOOGLE_CLIENT_REDIRECT_URI)
    oauth_client = google_doc.create_google_client
    auth_token = oauth_client.auth_code.get_token(params[:code], 
                 :redirect_uri => GOOGLE_CLIENT_REDIRECT_URI)
    session[:google_token] = auth_token.token if auth_token
    redirect_to dashboard_path
  end

  def google_drive_login
    unless current_user
            redirect_to log_in_path
    end 
    unless session[:google_token].present?
      google_drive = GoogleDrive::GoogleDocs.new(GOOGLE_CLIENT_ID,GOOGLE_CLIENT_SECRET,
                     GOOGLE_CLIENT_REDIRECT_URI)
      auth_url = google_drive.set_google_authorize_url
      redirect_to auth_url
    end
  end
end
