require 'spec_helper'

describe ProjectsController do

  #TODO split specs into 'logged in' vs 'not logged in'
  before :each do
    #TODO YA refactor to a helper method to stub the logged in user
    user = double('user')
    request.env['warden'].stub :authenticate! => user
    controller.stub :current_user => user
  end

  describe '#index' do
    it 'should render index page for projects' do
      get :index
      expect(response).to render_template 'index'
    end

    it 'should assign variables to be rendered by view' do
      projects = [double(Project), double(Project)]
      Project.stub(:all).and_return(projects)
      get :index
      expect(assigns(:projects)).to eq projects
    end
  end

  describe '#show' do

    it 'assigns the requested project as @project' do
      project = double(Project)
      Project.stub(:find).and_return(project)
      get :show, { :id => project.to_param }
      assigns(:project).should eq(project)
    end
  end

  describe '#new' do
    it 'should render a new project page' do
      get :new
      assigns(:project).should be_a_new(Project)
      expect(response).to render_template 'new'
    end
  end

  describe '#create' do
    before(:each) do
      @params = {
          project: {
              id: 1,
              title: 'Title 1',
              description: 'Description 1',
              status: 'Status 1'
          }
      }
      @project = mock_model(Project, id: 1)
      Project.stub(:new).and_return(@project)
    end

    it 'assigns a newly created project as @project' do
      @project.stub(:save)
      post :create, @params
      expect(assigns(:project)).to eq @project
    end

    context 'successful save' do

      it 'redirects to show' do
        @project.stub(:save).and_return(true)

        post :create, @params

        expect(response).to redirect_to(project_path(1))
      end
      it 'assigns successful message' do
        @project.stub(:save).and_return(true)

        post :create, @params

        #TODO YA add a show view_spec to check if flash is actually displayed
        expect(flash[:notice]).to eql('Project was successfully created.')
      end
    end

    context 'unsuccessful save' do
      it 'renders new template' do
        @project.stub(:save).and_return(false)

        post :create, @params

        expect(response).to render_template :new
      end

      it 'assigns failure message' do
        @project.stub(:save).and_return(false)

        post :create, @params

        expect(flash[:alert]).to eql('Project was not saved. Please check the input.')
      end
    end
  end

  describe '#edit' do
    before(:each) do
      @project = double(Project)
      Project.stub(:find).and_return(@project)
      get :edit, id: 'show'
    end

    it 'renders the edit template' do
      expect(response).to render_template 'edit'
    end

    it 'assigns the requested project as @project' do
      expect(assigns(:project)).to eq(@project)
    end
  end

  describe '#destroy' do
    before :each do
      @project = double(Project)
      Project.stub(:find).and_return(@project)
    end
    it 'receives destroy call' do
      expect(@project).to receive(:destroy)
      delete :destroy, id: 'test'
    end

    context 'on successful delete' do
      before(:each) do
        @project.stub(:destroy).and_return(true)
        delete :destroy, id: 'test'
      end
      it 'redirects to index' do
        expect(response).to redirect_to(projects_path)
      end
      it 'shows the correct message' do
        expect(flash[:notice]).to eq 'Project was successfully deleted.'
      end
    end

    context 'on unsuccessful delete' do
      before do
        @project.stub(:destroy).and_return(false)
        delete :destroy, id: 'test'
      end
      it 'redirects to index' do
        expect(response).to redirect_to(projects_path)
      end
      it 'shows the correct message' do
        expect(flash[:notice]).to eq 'Project was not successfully deleted.'
      end
    end
  end

#TODO YA need to refactor the specs below, as there are duplication with the above specs
#TODO YA need to refactor to account for introduced model validations


  describe '#update' do
    describe 'with valid params' do

      it 'assigns the requested project as @project' do
        project = Project.create! valid_attributes
        put :update, { :id => project.to_param, :project => valid_attributes }, valid_session
        assigns(:project).should eq(project)
      end

      it 'redirects to the project' do
        project = Project.create! valid_attributes
        put :update, { :id => project.to_param, :project => valid_attributes }, valid_session
        response.should redirect_to(project)
      end
    end

    describe 'with invalid params' do
      it 'assigns the project as @project' do
        project = Project.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        put :update, { :id => project.to_param, :project => { "title" => "invalid value" } }, valid_session
        assigns(:project).should eq(project)
      end

      it 're-renders the edit template' do
        project = Project.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Project.any_instance.stub(:save).and_return(false)
        put :update, { :id => project.to_param, :project => { "title" => "invalid value" } }, valid_session
        response.should render_template("edit")
      end
    end
  end


end
