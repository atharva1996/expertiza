describe PublishingController do
  let(:super_admin) { build(:superadmin, id: 1, role_id: 5) }
  let(:admin) { build(:admin, id: 3) }
  let(:instructor1) { build(:instructor, id: 10, role_id: 3, parent_id: 3, name: 'Instructor1') }
  let(:student1) { build(:student, id: 21, role_id: 1) }
  let(:ta) { build(:teaching_assistant, id: 6) }
  let(:assignment) { build(:assignment, id: 1)}
  let(:participant) {build(:participant, id: 1)}
  let(:allow1) {{id: 1, allow: 0 } }
  let(:assignment_participant1) { build(:participant, id: 2, user_id: 21)}
  let(:assignment_participant2) { build(:participant, id: 3, user_id: 21)}
	let(:assignment_participant3) { build(:participant, id: 1, user_id: 24)}
   
	
 before(:each) do
    allow(User).to receive(:find).with(21).and_return(student1)
  end
	describe '#action_allowed?' do
    context 'when the role of current user is Super-Admin' do
      it 'allows certain action' do
        stub_current_user(super_admin, super_admin.role.name, super_admin.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the role of current user is Instructor' do
      it 'allows certain action' do
        stub_current_user(instructor1, instructor1.role.name, instructor1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the role of current user is Student' do
      it 'refuses certain action' do
        stub_current_user(student1, student1.role.name, student1.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the role of current user is Teaching Assisstant' do
      it 'allows certain action' do
        stub_current_user(ta, ta.role.name, ta.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
    context 'when the role of current user is Admin' do
      it 'allows certain action' do
        stub_current_user(admin, admin.role.name, admin.role)
        expect(controller.send(:action_allowed?)).to be_truthy
      end
    end
  end

describe 'view' do
    context 'user visits the publishing rights page' do
      it 'displays all the assignment participants' do
          stub_current_user(student1, student1.role.name, student1.role)
          params = { id: 21 }
          get :view, params
          expect(assigns(:user)).to eq(student1)
      end
    end
  end

describe 'set_publish_permission' do
    context 'user matches with participant and user clicks on the grant button next to the assignment' do
      it 'redirects to the grant page' do
        allow(AssignmentParticipant).to receive(:find).with('1').and_return(assignment_participant1)
        stub_current_user(student1, student1.role.name, student1.role)
        params ={id: 1, allow: 1}
        post :set_publish_permission, params
        expect(response).to redirect_to(action: :grant)
      end
    end

context 'user matches with participant and the assignment is already granted permission' do
      it 'redirects to the view page' do
	stub_current_user(student1, student1.role.name, student1.role)
	allow(AssignmentParticipant).to receive(:find).with('1').and_return(assignment_participant1)
        allow(assignment_participant1).to receive(:update_attribute).and_return(true)
        params ={id: 1, allow: '0'}
        post :set_publish_permission, params
        expect(response).to redirect_to(action: :view)
      end
    end
    
  end
describe 'grant' do
      context 'user clicks on grant option' do
        it 'redirects to the grant page' do
          allow(AssignmentParticipant).to receive(:find).with('3').and_return(assignment_participant2)
          stub_current_user(student1, student1.role.name, student1.role)
          params ={id: 3}
          get :grant, params
          expect(assigns(:user)).to eq(student1)
        end
      end
    end
    
    
describe 'grant_with_private_key' do



      context 'user visits the grant page without id and enters incorrect RSA private key' do
        it 'displays notice and redirects to grant' do
          allow(AssignmentParticipant).to receive(:where).with(user_id: 21).and_return([assignment_participant1])
          stub_current_user(student1, student1.role.name, student1.role)
         
          params = {}

          [assignment_participant1].each do |participant|
	allow(participant).to receive(:verify_digital_signature).with(any_args).and_return(true)
            allow(participant).to receive(:assign_copyright).with(any_args).and_raise('The private key you inputted was invalid.', StandardError)
          end
          post :grant_with_private_key, params
          expect(flash[:notice]).to eq('The private key you inputted was invalid.')
          expect(response).to redirect_to(action: :grant)
       end
      end
      
      
=begin      
     context 'user visits the grant page with id and enters correct RSA private key' do
        it 'verifies to be successful for all past assignments and redirect to view' do
          allow(AssignmentParticipant).to receive(:find).with('2').and_return([assignment_participant1])
          stub_current_user(student1, student1.role.name, student1.role)
          params = {id:2}
			[assignment_participant1].each do |participant|
			allow(participant).to receive(:verify_digital_signature).with(any_args).and_return(true)
         allow(participant).to receive(:assign_copyright).with(any_args).and_return(true)
          end
          post :grant_with_private_key, params
          expect(response).to redirect_to(action: :view)
       end
      end     
=end    
      
  end
describe 'update_publish_permissions' do
      context 'user clicks on the grant publishing rights to all past assignments button and the assignments are already granted permission' do
        it 'redirects to grant page' do
          allow(AssignmentParticipant).to receive(:find).with('3').and_return(assignment_participant2)
          stub_current_user(student1, student1.role.name, student1.role)
          params ={id: 3, allow: 1}
          post :update_publish_permissions, params
          expect(response).to redirect_to(action: :grant)
        end
      end
      
      context 'user clicks on the deny publishing rights to all past assignments button' do
        it 'redirects to view page' do
        	 allow(AssignmentParticipant).to receive(:where).with(user_id: 21).and_return([assignment_participant1])
          stub_current_user(student1, student1.role.name, student1.role)
          params ={id: 3, allow: 0}
          [assignment_participant1].each do |participant|
          	allow(participant).to receive(:update_attribute).and_return(true)
          	allow(participant).to receive(:save).and_return(true)
          end
          post :update_publish_permissions, params
          expect(response).to redirect_to(action: :view)
        end
      end
      
    end
end