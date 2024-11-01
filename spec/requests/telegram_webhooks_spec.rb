RSpec.describe TelegramWebhooksController, telegram_bot: :rails do
  # describe '#start!' do
  #   subject { -> { dispatch_command :start } }
  #   it { should respond_with_message 'Hi there!' }
  # end

  # describe '#help!' do
  #   subject { -> { dispatch_command :help } }
  #   it { should respond_with_message(/Available cmds/) }
  # end

  # describe 'memoizing with /memo' do
  #   let(:memo) { ->(text) { dispatch_command :memo, text } }
  #   let(:remind_me) { -> { dispatch_command :remind_me } }
  #   let(:text) { 'asd qwe' }

  #   it 'memoizes from the single message' do
  #     expect(&remind_me).to respond_with_message 'Nothing to remind'
  #     expect { memo[text] }.to respond_with_message 'Remembered!'
  #     expect(&remind_me).to respond_with_message text
  #     expect(&remind_me).to respond_with_message 'Nothing to remind'
  #   end

  #   it 'memoizes text from subsequest message' do
  #     expect { memo[''] }.to respond_with_message 'What should I remember?'
  #     expect { dispatch_message text }.to respond_with_message 'Remembered!'
  #     expect(&remind_me).to respond_with_message text
  #   end
  # end

  # describe '#keyboard!' do
  #   subject { -> { dispatch_command :keyboard } }
  #   it 'shows keyboard' do
  #     should respond_with_message 'Select something with keyboard:'
  #     expect(bot.requests[:sendMessage].last[:reply_markup]).to be_present
  #   end

  #   context 'when keyboard button selected' do
  #     subject { -> { dispatch_message 'Smth' } }
  #     before { dispatch_command :keyboard }
  #     it { should respond_with_message "You've selected: Smth" }
  #   end
  # end

  # describe '#inline_keyboard!' do
  #   subject { -> { dispatch_command :inline_keyboard } }

  #   it 'shows inline keyboard' do
  #     should respond_with_message 'Check my inline keyboard:'
  #     expect(bot.requests[:sendMessage].last.dig(:reply_markup, :inline_keyboard)).to be_present
  #   end
  # end

  # describe '#callback_query', :callback_query do
  #   let(:data) { 'no_alert' }
  #   it { should answer_callback_query('Simple answer') }

  #   context 'with alert' do
  #     let(:data) { 'alert' }
  #     it { should answer_callback_query(/ALERT/) }
  #   end
  # end

  # describe '#chosen_inline_result' do
  #   subject { -> { dispatch(chosen_inline_result: payload) } }
  #   let(:fetch) { -> { dispatch_command :last_chosen_inline_result } }
  #   let(:payload) { { from: { id: 123 }, result_id: 456 } }

  #   it 'memoizes chosen_inline_result' do
  #     expect(&fetch).to respond_with_message 'Mention me to initiate inline query'
  #     subject.call
  #     expect(&fetch).to respond_with_message "You've chosen result ##{payload[:result_id]}"
  #   end
  # end

  # describe '#message' do
  #   subject { -> { dispatch_message text } }
  #   let(:text) { 'some plain text' }
  #   it { should respond_with_message "You wrote: #{text}" }
  # end

  # context 'for unsupported command' do
  #   subject { -> { dispatch_command :makeMeGreatBot } }
  #   it { should respond_with_message 'Can not perform makeMeGreatBot' }
  # end

  # context 'for unsupported feature' do
  #   subject { -> { dispatch time_travel: { back_to: :the_future } } }
  #   it 'does nothing' do
  #     subject.call
  #     expect(response).to be_ok
  #   end
  # end
end
