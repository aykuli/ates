# frozen_string_literal: true

describe TasksProducer do
  subject(:producer) { described_class.new(validator:, logger:) }

  let(:logger) { instance_double(Recorder::Agent) }
  let(:validator) { instance_double(TasksValidator) }

  describe 'produce_async' do
    subject(:produce_async) { producer.produce_async(task, task_event, version: 1) }

    let(:task) { create(:task) }
    let(:version) { 1 }

    context 'valid' do
      let(:task_event) { States::CREATED }

      it 'produces task.created event if event valid' do
        expect(producer).to receive(:produce_async)
        # expect(validator).to receive(:valid?).with(task, States::CREATED, version: 1).and_return(true)
      end
    end

    # context "invalid" do
    #   let(:task_event) { FFaker.Lorem.word }
    #
    #   it 'is not produces task.created event if event invalid' do
    #     expect(validator).to receive(:valid?).with(:event,States::CREATED, version: 1).and_return(false)
    #
    #   end
    # end
  end
end
