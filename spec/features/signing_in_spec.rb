require_relative 'web_helpers'

feature 'signing in' do
  let!(:user) do
    User.create(first_name: "Alan",
                last_name: "Shearer",
                username: "alan123",
                email: "alan@nufc.com",
                password: "password123",
                password_confirmation: "password123")
  end
  it 'allows a user to sign in' do
    sign_in
    expect(current_path).to eq '/peeps/peepdeck'
    expect(page).to have_button "PEEP"
  end

  it 'authenticates a vaild email and password' do
    authenticated_user = User.authenticate(user.email, user.password)
    expect(authenticated_user).to eq user
  end

  it 'does not allow a user to sign in when entering a password incorrectly' do
    sign_in_with_incorrect_password
    expect(current_path).to eq '/sessions'
    expect(page).to have_content "The email or password is incorrect"
  end

  it 'does not allow a user to sign in when entering an unegistered email' do
    sign_in_with_unregistered_email
    expect(current_path).to eq '/sessions'
    expect(page).to have_content "The email or password is incorrect"
  end
end