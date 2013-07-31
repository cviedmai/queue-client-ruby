require 'spec_helper'

describe Viki::Queue do
  describe 'authentication' do
    # it 'should fail is wrong username/pasword is given' do
    #   Viki::Queue.configure do |c|
    #     c.writer = {
    #       username: 'wrong',
    #       password: 'alsowrong',
    #       host: 'localhost',
    #       port: 5672
    #     }
    #   end
    #   expect{ Viki::Queue.service.create_message(:kitten, '22k') }.to(
    #     raise_error(Bunny::PossibleAuthenticationFailureError))
    # end
  end
end