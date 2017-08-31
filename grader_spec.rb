require_relative './grader'

RSpec.describe Grader do
  let!(:grader) { Grader.new(answer_key, grades: grades) }
  let(:answer_key) { %w(A B C D) }
  let(:grades) { [75, 50, 100] }

  # the answer key contains the list of correct answers in order
  it 'knows about an answer key' do
    expect(grader.answer_key).to be_kind_of(Array)
    expect(grader.answer_key).to eq(answer_key)
  end

  # the grader has a way to keep track of all the tests it has scored
  it 'knows about grades' do
    grader = Grader.new(answer_key, grades: [75, 50, 100])
    expect(grader.grades).to be_kind_of(Array)
    expect(grader.grades).not_to be_empty
  end

  # grade a given student's test
  describe '#score' do
    let(:answers) { ['D', 'B', 'C', 'D'] }

    it 'returns the percent of correct answers when compared to the answer key' do
      expect(grader.score(answers)).to eq(75.0)
    end

    it 'keeps track of grades it has scored' do
      expect { grader.score(answers) }.to change { grader.grades.count }.by(1)
      expect(grader.grades.last).to eq(75.0)
    end

    # given that this is a multiple-choice grader, non-ABCD answers are invalid
    context 'when passed impossible answers' do
      let(:answers) { ['Apple', 'Banana', 'Celery', 'Delicious'] }

      it 'raises an ArgumentError' do
        expect { grader.score(answers) }.to raise_error(ArgumentError)
      end
    end

    # it's possible that a valid answer is not one of the correct answers
    context 'when passed valid answers outside of the answer_key' do
      let(:grader) { Grader.new(['A', 'B', 'C']) }
      
      it 'does not raise an error' do
        expect { grader.score(['A', 'B', 'D']) }.not_to raise_error
      end
    end

    context 'when passed more answers than necessary' do
      let(:answers) { ['A', 'B', 'C'] }
      let(:answer_key) { ['A', 'B'] }

      it 'raises an ArgumentError' do
        expect { grader.score(answers) }.to raise_error(ArgumentError)
      end
    end

    # the student didn't finish the test in time
    context 'when passed fewer answers than necessary' do
      let(:answers) { ['A', 'B'] }

      it 'counts the last missing answers as incorrect' do
        expect(grader.score(answers)).to eq(50.0)
      end
    end

    # the student forgot to answer a question
    context 'when passed nil for an answer' do
      let(:answers) { ['A', 'B', nil, 'D'] }

      it 'counts the nil as incorrect' do
        expect(grader.score(answers)).to eq(75.0)
      end
    end
  end

  # the grading scale:
  # A: 100 - 90
  # B: 89 - 80
  # C: 79 - 75
  # D: 74 - 70 D
  # F: below 70
  describe '.letter_grade' do
    it 'returns a letter grade when passed a numerical score' do
      expect(Grader.letter_grade(90.0)).to eq('A')
      expect(Grader.letter_grade(80.0)).to eq('B')
      expect(Grader.letter_grade(75.0)).to eq('C')
      expect(Grader.letter_grade(70.0)).to eq('D')
      expect(Grader.letter_grade(60.0)).to eq('F')
    end
  end

  # when the highest score on a test is less than 100, a teacher may want to
  # curve each grade to account for unexpected test difficulty. curving bumps
  # the highest grade up to 100 and adds the difference in points to all other
  # scores.
  context 'curving' do
    let(:grades) { [75, 50, 25] }

    describe '#curve' do
      it 'returns the original grades with the curve applied' do
        expect(grader.curve).to eq([100, 75, 50])
      end
    end

    describe '#curve_points' do
      it 'returns the number of points the grades will be curved' do
        expect(grader.curve_points).to eq(25)
      end
    end
  end

  context 'reporting' do
    let(:grader) { Grader.new(answer_key, grades: [75, 100, 50]) }

    describe '#average_score' do
      it 'calculates the average grade among all submitted tests' do
        expect(grader.average_score).to eq(75.0)
      end
    end

    describe '#high_score' do
      it 'returns the top grade among all submitted tests' do
        expect(grader.high_score).to eq(100)
      end
    end

    describe '#low_score' do
      it 'returns the lowest grade among all submitted tests' do
        expect(grader.low_score).to eq(50)
      end
    end
  end
end
