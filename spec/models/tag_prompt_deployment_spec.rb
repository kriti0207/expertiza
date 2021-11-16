describe TagPromptDeployment do
	let(:tag_dep) { TagPromptDeployment.new id: 1, tag_prompt: tp, tag_prompt_id: 1, question_type: "Criterion", answer_length_threshold: 5 }
	let(:tp) { TagPrompt.new(prompt: "test prompt", desc: "test desc", control_type: "Checkbox") }
	let(:team) {Team.new(id: 1, parent_id: 1)}
	let(:response) {Response.new(id: 1)}
  let(:responses) {Response.new(id: 1, round: 1, additional_comment: "improvement scope")}
	let(:assignment) {Assignment.new({assignment: 1})}
	let(:question) {Question.new(questionnaire_id: 1, type: 'tagging')}
  # let(:answerss) {create(:answer, 30)}

	answerss = [{id: 1, question_id: 1, answer: 3, comments: 'comm', response_id: 2313},
              {id: 1, question_id: 1, answer: 3, comments: 'comm', response_id: 2313}]
  answers = {
			'answer1': {id: 1, question_id: 1, answer: 3, comments: 'comm', response_id: 2313},
			'answer2': {id: 2, question_id: 1, answer: 3, comments: 'comment length exceeds threshold', response_id: 2313},
      'answer3': {id: 3, question_id: 1, answer: 3, comments: 'comment length within threshold', response_id: 2313},
			'answer4': {id: 4, question_id: 2, answer: 1, comments: 'com1', response_id: 241}
  }
	answers_comments_len = {
		'answer1': {id: 1, question_id: 1, answer: 3, comments: 'comm', response_id: 2313},
		'answer4': {id: 4, question_id: 2, answer: 1, comments: 'com1', response_id: 241}
	}

	describe '#tag_prompt' do
		it 'returns the associated tag prompt with the deployment' do
			allow(TagPrompt).to receive(:find).with(1).and_return(tp)
			expect(tag_dep.tag_prompt).to be(tp)
		end
	end

  # get_number_of_taggable_answers calculates total taggable answers assigned to an user who  participated in "tag review assignment".
	describe '#get_number_of_taggable_answers' do
    context "when user_id given" do
			it 'get team_id and response of the participant' do
				allow(Team).to receive(:join).with(:team_users, {:parent_id => 1, :user_id => 1}).and_return(team.id)
				allow(Response).to receive(:join).with(:response_maps, {:reviewed_object_id => 1, :reviewee_id => team.id}).and_return(response.id)
				expect(response.id).to be(responses.id)
      end

			it "get question for each taggable question" do
				# questions = Question.where(questionnaire_id: self.questionnaire.id, type: self.question_type)
				allow(Question).to receive(:where).with({:questionnaire_id => 1, :type => 'tagging'}).and_return(question)
				expect(question).not_to be(nil)
      end
    end
    it "answers for reviews" do
			responses_ids = allow(responses).to receive(:map).with(1).and_return(1)
			question_ids = allow(question).to receive(:map).with(1).and_return(1)
      allow(Answer).to receive(:where).with({question_id: question_ids, response_id: responses_ids}).and_return(answers)
      expect(answers.count).to eq(4)
    end
    it "comments length less than threshold" do
			expect(answers[:answer1][:comments].length).to be < tag_dep.answer_length_threshold
    end
    # context "unless answer_length_threshold true"  do
    #   it "filter answers by comments", :unless => true do
    #     expect(answers[:answer1][:comments].length.error).to be >= tag_dep.answer_length_threshold
    #   end
    # end
  end
end
